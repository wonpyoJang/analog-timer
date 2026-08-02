import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/persistence_service.dart';
import '../../../services/sync_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/a11y.dart';
import '../bloc/timer_bloc.dart';
import '../bloc/timer_event.dart';
import '../models/preset.dart';
import '../models/segment.dart';
import 'preset_manage_page.dart';

/// 세그먼트 구성을 프리셋(템플릿)으로 저장하고 한 번에 불러오는 칩 바.
class PresetBar extends StatefulWidget {
  const PresetBar({super.key});

  @override
  State<PresetBar> createState() => _PresetBarState();
}

class _PresetBarState extends State<PresetBar> {
  List<Preset> _userPresets = const [];
  Set<String> _hidden = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
    // pull 로 원격 프리셋/hidden defaults 가 반영되면 tick → 화면 재로드.
    SyncService.instance.presetRefreshSignal.addListener(_onSyncRefresh);
  }

  @override
  void dispose() {
    SyncService.instance.presetRefreshSignal.removeListener(_onSyncRefresh);
    super.dispose();
  }

  void _onSyncRefresh() {
    if (mounted) _load();
  }

  Future<void> _load() async {
    final raw = await PersistenceService.loadPresets();
    // 기본 프리셋은 더 이상 prefs에 저장하지 않는다. raw가 null이면 빈 리스트.
    // 기존 영어 기본 프리셋이 저장돼 있으면 사용자 목록에서 걸러낸다(마이그레이션).
    final list = raw == null
        ? <Preset>[]
        : raw
              .map(Preset.fromJson)
              .where((p) => !Preset.builtinEnNames.contains(p.name))
              .toList();
    final hidden = (await PersistenceService.loadHiddenDefaults()).toSet();
    if (!mounted) return;
    setState(() {
      _userPresets = list;
      _hidden = hidden;
      _loaded = true;
    });
  }

  Future<void> _persist() async {
    final json = _userPresets.map((p) => p.toJson()).toList();
    await PersistenceService.savePresets(json);
    // 로컬 저장 성공 후 원격에도 전파 — 실패는 무시(다음 사용자 편집에서 재시도).
    unawaited(SyncService.instance.pushPresets(json));
  }

  void _apply(Preset p) {
    final l = AppLocalizations.of(context);
    // 교체가 아니라 현재 세그먼트 목록 끝에 덧붙인다.
    context.read<TimerBloc>().add(TimerSegmentsAppended(p.freshSegments()));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(l.presetApplied(p.name)),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _openManage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PresetManagePage()),
    );
    // 관리 화면에서 추가/수정/삭제된 내용을 칩 바에 반영.
    if (mounted) _load();
  }

  Future<void> _saveCurrent() async {
    final l = AppLocalizations.of(context);
    final state = context.read<TimerBloc>().state;
    final messenger = ScaffoldMessenger.of(context);
    if (state.segments.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l.noSegmentsToSave)));
      return;
    }
    final name = await _promptName();
    if (!mounted || name == null || name.trim().isEmpty) return;
    final preset = Preset(
      name: name.trim(),
      loop: state.loop,
      segments: [
        for (final s in state.segments)
          Segment(name: s.name, minutes: s.minutes, color: s.color),
      ],
    );
    setState(() => _userPresets = [..._userPresets, preset]);
    await _persist();
  }

  Future<String?> _promptName() {
    final l = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          l.savePresetTitle,
          style: const TextStyle(color: AppColors.text, fontSize: 15),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.text, fontSize: 13),
          decoration: InputDecoration(
            hintText: l.presetNameHint,
            hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.timerOrange),
            ),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(
              l.cancel,
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: Text(
              l.save,
              style: const TextStyle(color: AppColors.timerOrange),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox(height: 0);
    final l = AppLocalizations.of(context);
    final defaults = Preset.defaultsFor(l);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final p in defaults)
            if (!_hidden.contains(p.builtinKey))
              _PresetChip(
                preset: p,
                deletable: false,
                onApply: () => _apply(p),
              ),
          for (final e in _userPresets.asMap().entries)
            _PresetChip(
              preset: e.value,
              deletable: true,
              onApply: () => _apply(e.value),
              onDelete: () async {
                setState(() {
                  final next = [..._userPresets]..removeAt(e.key);
                  _userPresets = next;
                });
                await _persist();
              },
            ),
          _SaveChip(onTap: _saveCurrent),
          _ManageChip(onTap: _openManage),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final Preset preset;
  final VoidCallback onApply;
  final VoidCallback? onDelete;
  final bool deletable;
  const _PresetChip({
    required this.preset,
    required this.onApply,
    this.onDelete,
    required this.deletable,
  });

  @override
  Widget build(BuildContext context) {
    final dot = preset.segments.isNotEmpty
        ? preset.segments.first.color
        : AppColors.muted;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111113),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.only(left: 10, right: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onApply,
            behavior: HitTestBehavior.opaque,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: dot,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      preset.name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (deletable) ...[
            const SizedBox(width: 2),
            AccessibleIconButton(
              label: '${AppLocalizations.of(context).delete}: ${preset.name}',
              onTap: onDelete,
              child: const MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 14, color: AppColors.muted),
                ),
              ),
            ),
          ] else
            const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _SaveChip extends StatelessWidget {
  final VoidCallback onTap;
  const _SaveChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.timerOrange.withAlpha(0x88)),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bookmark_add_outlined,
                size: 14,
                color: AppColors.timerOrange,
              ),
              const SizedBox(width: 5),
              Text(
                l.savePresetChip,
                style: const TextStyle(
                  color: AppColors.timerOrange,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManageChip extends StatelessWidget {
  final VoidCallback onTap;
  const _ManageChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tune, size: 14, color: AppColors.muted),
              const SizedBox(width: 5),
              Text(
                l.manage,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
