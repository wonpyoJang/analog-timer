import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/persistence_service.dart';
import '../../../theme/app_theme.dart';
import '../models/preset.dart';
import 'preset_edit_page.dart';

/// 프리셋 목록 관리 풀스크린 화면 — 새로 만들기 / 편집 / 삭제 / 순서.
class PresetManagePage extends StatefulWidget {
  const PresetManagePage({super.key});

  @override
  State<PresetManagePage> createState() => _PresetManagePageState();
}

class _PresetManagePageState extends State<PresetManagePage> {
  List<Preset> _userPresets = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await PersistenceService.loadPresets();
    // 사용자 프리셋만 로드(기존 영어 기본 프리셋은 제외). 기본은 build에서 생성.
    final list = raw == null
        ? <Preset>[]
        : raw
            .map(Preset.fromJson)
            .where((p) => !Preset.builtinEnNames.contains(p.name))
            .toList();
    if (!mounted) return;
    setState(() {
      _userPresets = list;
      _loaded = true;
    });
  }

  Future<void> _persist() => PersistenceService.savePresets(
    _userPresets.map((p) => p.toJson()).toList(),
  );

  Future<void> _new() async {
    final created = await Navigator.push<Preset>(
      context,
      MaterialPageRoute(builder: (_) => const PresetEditPage()),
    );
    if (created == null) return;
    setState(() => _userPresets = [..._userPresets, created]);
    await _persist();
  }

  Future<void> _edit(int i) async {
    final edited = await Navigator.push<Preset>(
      context,
      MaterialPageRoute(builder: (_) => PresetEditPage(initial: _userPresets[i])),
    );
    if (edited == null) return;
    final n = [..._userPresets];
    n[i] = edited;
    setState(() => _userPresets = n);
    await _persist();
  }

  Future<void> _delete(int i) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          l.deletePresetTitle,
          style: const TextStyle(color: AppColors.text, fontSize: 15),
        ),
        content: Text(
          l.deletePresetConfirm(_userPresets[i].name),
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel, style: const TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete, style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final n = [..._userPresets]..removeAt(i);
    setState(() => _userPresets = n);
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: Text(
          l.presetManageTitle,
          style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
        ),
        actions: [
          TextButton.icon(
            onPressed: _new,
            icon: const Icon(Icons.add, size: 18, color: AppColors.timerOrange),
            label: Text(
              l.newPreset,
              style: const TextStyle(color: AppColors.timerOrange, fontSize: 14),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: !_loaded
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 기본 프리셋(읽기 전용) — 현재 언어로 생성.
                for (final p in Preset.defaultsFor(l))
                  _PresetCard(preset: p, builtin: true),
                // 사용자 프리셋 — 편집/삭제 가능.
                for (final e in _userPresets.asMap().entries)
                  _PresetCard(
                    preset: e.value,
                    builtin: false,
                    onEdit: () => _edit(e.key),
                    onDelete: () => _delete(e.key),
                  ),
              ],
            ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  final Preset preset;
  final bool builtin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const _PresetCard({
    required this.preset,
    required this.builtin,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final summary = preset.segments
        .map((s) => '${s.name} ${s.minutes}${l.minutesUnit}')
        .join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 색 점들 — 세그먼트 미리보기
          Wrap(
            spacing: 3,
            children: [
              for (final s in preset.segments.take(6))
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        preset.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.text, fontSize: 14),
                      ),
                    ),
                    if (preset.loop) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.repeat, size: 13, color: AppColors.timerOrange),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (builtin)
            const Padding(
              padding: EdgeInsets.all(5),
              child: Icon(Icons.lock_outline, size: 18, color: AppColors.muted),
            )
          else ...[
            _IconBtn(icon: Icons.edit_outlined, color: AppColors.text, onTap: onEdit!),
            const SizedBox(width: 4),
            _IconBtn(icon: Icons.delete_outline, color: AppColors.danger, onTap: onDelete!),
          ],
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
