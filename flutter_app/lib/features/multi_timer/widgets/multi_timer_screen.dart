import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../services/persistence_service.dart';
import '../../../services/haptic_service.dart';
import '../../../services/tts_service.dart';
import '../../../services/desktop_notification_service.dart';
import '../../../overlay/multi_overlay_service.dart';
import '../../../overlay/overlay_coordinator.dart';
import '../bloc/multi_timer_bloc.dart';
import '../bloc/multi_timer_event.dart';
import '../bloc/multi_timer_state.dart';
import '../models/countdown_timer.dart';

String _fmt(int ms) {
  final total = (ms / 1000).ceil();
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  final mm = m.toString().padLeft(2, '0');
  final ss = s.toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
}

class MultiTimerScreen extends StatelessWidget {
  /// 하단 탭으로 임베드될 때 true — 뒤로가기 화살표를 숨긴다.
  final bool embedded;
  const MultiTimerScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    // 복원(async)은 _MultiTimerView.initState 에서 dispatch.
    return BlocProvider(
      create: (_) => MultiTimerBloc(),
      child: _MultiTimerView(embedded: embedded),
    );
  }
}

class _MultiTimerView extends StatefulWidget {
  final bool embedded;
  const _MultiTimerView({this.embedded = false});
  @override
  State<_MultiTimerView> createState() => _MultiTimerViewState();
}

class _MultiTimerViewState extends State<_MultiTimerView> {
  Timer? _saveTrailing;
  DateTime _lastSave = DateTime.fromMillisecondsSinceEpoch(0);
  static const _saveInterval = Duration(milliseconds: 1500);

  // 네이티브 멀티 오버레이 상태 — 사용자가 개별로 띄우기 선택한 타이머 id들.
  final Set<String> _overlayIds = {};
  final Map<String, String> _lastPushed = {};

  /// 원탭 등록용 프리셋 — {'name': String, 'durationMs': int}.
  List<Map<String, dynamic>> _presets = [];

  @override
  void initState() {
    super.initState();
    _restore();
    // 단일 오버레이가 켜지면 멀티 오버레이를 전부 닫도록 훅 등록(상호 배타).
    OverlayCoordinator.instance.closeMultiOverlays = _closeAllOverlaysForMutex;
    // l10n 이 필요한 기본 시드는 첫 프레임 후에(initState 에선 inherited 조회 불가).
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPresets());
  }

  /// 저장된 프리셋 로드 — 저장된 적이 없으면 기본 4종(공부/청소/휴식/양치질) 시드.
  Future<void> _loadPresets() async {
    var loaded = await PersistenceService.loadMultiTimerPresets();
    if (loaded == null && mounted) {
      final l = AppLocalizations.of(context);
      loaded = [
        {'name': l.multiTimerPresetStudy, 'durationMs': 25 * 60000},
        {'name': l.multiTimerPresetDeskCleanup, 'durationMs': 10 * 60000},
        {'name': l.multiTimerPresetRest, 'durationMs': 5 * 60000},
        {'name': l.multiTimerPresetBrushTeeth, 'durationMs': 3 * 60000},
      ];
      await PersistenceService.saveMultiTimerPresets(loaded);
    }
    if (mounted) setState(() => _presets = loaded ?? []);
  }

  /// 상호 배타 — 단일 오버레이 활성화 시 호출돼 멀티 오버레이를 전부 닫는다.
  Future<void> _closeAllOverlaysForMutex() async {
    if (_overlayIds.isEmpty) return;
    await MultiOverlayService.closeAll();
    _lastPushed.clear();
    if (mounted) setState(() => _overlayIds.clear());
  }

  Future<void> _restore() async {
    final data = await PersistenceService.loadMultiTimerState();
    if (data == null || !mounted) return;
    final rawList = (data['timers'] as List?) ?? const [];
    final savedAt = (data['savedAtMs'] as num?)?.toInt();
    final elapsed = savedAt == null
        ? 0
        : DateTime.now().millisecondsSinceEpoch - savedAt;
    final timers = rawList
        .map((e) => CountdownTimer.fromJson(e as Map<String, dynamic>))
        .map((t) {
          // 앱 꺼진 동안 running 이었으면 경과분 차감.
          if (t.running && elapsed > 0) {
            final r = t.remainMs - elapsed;
            if (r <= 0) {
              return t.copyWith(remainMs: 0, running: false, done: true);
            }
            return t.copyWith(remainMs: r);
          }
          return t;
        })
        .toList();
    if (mounted) context.read<MultiTimerBloc>().add(MtRestore(timers));
  }

  // 스로틀 저장 — 실행 중 매 틱 저장(16ms)은 막되, 최소 1.5s 간격으로 갱신하고
  // 마지막 상태를 트레일링 저장(디바운스는 틱마다 리셋돼 영영 저장 안 되는 버그가 있어 사용 안 함).
  void _save(MultiTimerState s) {
    _lastSave = DateTime.now();
    PersistenceService.saveMultiTimerState(
      s.timers.map((t) => t.toJson()).toList(),
    );
  }

  void _persist(MultiTimerState s) {
    final since = DateTime.now().difference(_lastSave);
    if (since >= _saveInterval) {
      _saveTrailing?.cancel();
      _save(s);
    } else {
      _saveTrailing?.cancel();
      _saveTrailing = Timer(_saveInterval - since, () => _save(s));
    }
  }

  void _onCompleted(BuildContext context, MultiTimerState s) {
    final ids = s.justCompleted;
    if (ids.isEmpty) return;
    HapticService.instance.impact(); // 여러 개 동시여도 1회
    final l = AppLocalizations.of(context);
    if (ids.length == 1) {
      final t = s.timers.firstWhere(
        (x) => x.id == ids.first,
        orElse: () => CountdownTimer(name: '', totalMs: 0),
      );
      DesktopNotificationService.notify(l.multiTimerTitle, t.name);
      if (t.name.isNotEmpty) {
        TtsService.instance.speak(
          t.name,
          localeTag: Localizations.localeOf(context).toLanguageTag(),
        );
      }
    } else {
      final msg = l.multiTimerAllDone(ids.length);
      DesktopNotificationService.notify(l.multiTimerTitle, msg);
      TtsService.instance.speak(
        msg,
        localeTag: Localizations.localeOf(context).toLanguageTag(),
      );
    }
  }

  /// 개별 타이머의 오버레이 위젯 켜기/끄기. 켤 때만 권한 확인.
  Future<void> _toggleOverlayFor(
    BuildContext context,
    CountdownTimer timer,
  ) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final bloc = context.read<MultiTimerBloc>();
    if (_overlayIds.contains(timer.id)) {
      MultiOverlayService.close(timer.id);
      _lastPushed.remove(timer.id);
      if (mounted) setState(() => _overlayIds.remove(timer.id));
      return;
    }
    // 상한 초과 방지 — 기기 화면의 겹침 없는 슬롯 수만큼 허용.
    final maxWindows = await MultiOverlayService.maxWindows();
    if (_overlayIds.length >= maxWindows) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.multiTimerOverlayLimit(maxWindows))),
      );
      return;
    }
    if (!await MultiOverlayService.isPermissionGranted) {
      await MultiOverlayService.requestPermission();
      if (!await MultiOverlayService.isPermissionGranted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l.multiTimerOverlayPermission)),
        );
        return;
      }
    }
    if (!mounted) return;
    // 상호 배타 — 단일 오버레이(2nd 엔진)를 꺼 플랫폼 스레드 경합 제거.
    unawaited(OverlayCoordinator.instance.onMultiOverlayEnabled());
    setState(() => _overlayIds.add(timer.id));
    _syncOverlays(l, bloc.state);
  }

  /// 선택된 타이머(_overlayIds)만 네이티브 오버레이 창에 반영. 표시 문구가 바뀐
  /// 창만 push(초 단위 throttle), 삭제됐거나 선택 해제된 타이머의 창은 닫는다.
  void _syncOverlays(AppLocalizations l, MultiTimerState state) {
    final byId = {for (final t in state.timers) t.id: t};
    // 목록에서 사라진 선택 항목은 정리.
    final gone = _overlayIds.where((id) => !byId.containsKey(id)).toList();
    for (final id in gone) {
      MultiOverlayService.close(id);
      _overlayIds.remove(id);
      _lastPushed.remove(id);
    }
    for (var i = 0; i < state.timers.length; i++) {
      final t = state.timers[i];
      if (!_overlayIds.contains(t.id)) continue;
      final color = AppColors.segColors[i % AppColors.segColors.length]
          .toARGB32();
      // 상태 전이(시작/정지/리셋/완료/이름·지속시간 변경) 시에만 push. 매초 남은시간은
      // 네이티브가 자체 계산하므로 key 에 remainMs/시간 문자열을 넣지 않는다.
      final key = '${t.name}|${t.running}|${t.done}|${t.totalMs}';
      if (_lastPushed[t.id] == key) continue;
      _lastPushed[t.id] = key;
      MultiOverlayService.show(
        id: t.id,
        name: t.name,
        colorValue: color,
        totalMs: t.totalMs,
        remainMs: t.remainMs,
        running: t.running,
        done: t.done,
        doneText: l.multiTimerDone,
      );
    }
  }

  @override
  void dispose() {
    _saveTrailing?.cancel();
    if (identical(
      OverlayCoordinator.instance.closeMultiOverlays,
      _closeAllOverlaysForMutex,
    )) {
      OverlayCoordinator.instance.closeMultiOverlays = null;
    }
    // 화면을 떠나면 bloc(ticker)이 정지 → 멈춘 pill이 남지 않도록 정리.
    if (_overlayIds.isNotEmpty) MultiOverlayService.closeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.embedded
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.text,
                  size: 18,
                ),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          l.multiTimerTitle,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: BlocConsumer<MultiTimerBloc, MultiTimerState>(
        listener: (context, state) {
          _persist(state);
          _onCompleted(context, state);
          _syncOverlays(l, state);
        },
        builder: (context, state) {
          if (state.timers.isEmpty) {
            return Center(
              child: Text(
                l.multiTimerEmpty,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 14),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.timers.length,
            separatorBuilder: (_, _) => const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: AppColors.border,
            ),
            itemBuilder: (context, i) => _TimerRow(
              timer: state.timers[i],
              color: AppColors.segColors[i % AppColors.segColors.length],
              overlayOn: _overlayIds.contains(state.timers[i].id),
              onToggleOverlay: MultiOverlayService.supported
                  ? () => _toggleOverlayFor(context, state.timers[i])
                  : null,
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddSheet(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final bloc = context.read<MultiTimerBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final nameCtrl = TextEditingController();
    Duration picked = const Duration(minutes: 3);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 프리셋 칩 — 탭 = 원탭 등록, 길게 = 삭제.
              if (_presets.isNotEmpty)
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presets.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final p = _presets[i];
                      final name = p['name'] as String? ?? '';
                      final ms = (p['durationMs'] as num?)?.toInt() ?? 0;
                      return GestureDetector(
                        onLongPress: () async {
                          _presets.removeAt(i);
                          await PersistenceService.saveMultiTimerPresets(
                            _presets,
                          );
                          setSheetState(() {});
                          if (mounted) setState(() {});
                          messenger.showSnackBar(
                            SnackBar(content: Text(l.multiTimerPresetDeleted)),
                          );
                        },
                        child: ActionChip(
                          backgroundColor: AppColors.bg,
                          side: BorderSide(
                            color: AppColors.accent.withAlpha(0x55),
                          ),
                          label: Text(
                            '$name ${_fmt(ms)}',
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 13,
                            ),
                          ),
                          onPressed: () {
                            if (ms <= 0) return;
                            bloc.add(MtAdd(name, ms));
                            Navigator.pop(ctx);
                          },
                        ),
                      );
                    },
                  ),
                ),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppColors.text),
                decoration: InputDecoration(
                  hintText: l.multiTimerNameHint,
                  hintStyle: TextStyle(color: AppColors.muted),
                ),
              ),
              SizedBox(
                height: 180,
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hms,
                  initialTimerDuration: picked,
                  onTimerDurationChanged: (d) => picked = d,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        final ms = picked.inMilliseconds;
                        if (ms <= 0) return;
                        final name = nameCtrl.text.trim().isEmpty
                            ? l.multiTimerTitle
                            : nameCtrl.text.trim();
                        bloc.add(MtAdd(name, ms));
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        l.multiTimerAdd,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: l.multiTimerPresetSave,
                    icon: Icon(
                      Icons.bookmark_add_outlined,
                      color: AppColors.muted,
                    ),
                    onPressed: () async {
                      final ms = picked.inMilliseconds;
                      if (ms <= 0) return;
                      final name = nameCtrl.text.trim().isEmpty
                          ? l.multiTimerTitle
                          : nameCtrl.text.trim();
                      // 같은 이름이 있으면 시간만 갱신(중복 칩 방지).
                      final idx = _presets.indexWhere((p) => p['name'] == name);
                      final entry = {'name': name, 'durationMs': ms};
                      if (idx >= 0) {
                        _presets[idx] = entry;
                      } else {
                        _presets.add(entry);
                      }
                      await PersistenceService.saveMultiTimerPresets(_presets);
                      setSheetState(() {});
                      if (mounted) setState(() {});
                      messenger.showSnackBar(
                        SnackBar(content: Text(l.multiTimerPresetSaved)),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerRow extends StatelessWidget {
  final CountdownTimer timer;
  final Color color;
  final bool overlayOn;
  final VoidCallback? onToggleOverlay;
  const _TimerRow({
    required this.timer,
    required this.color,
    this.overlayOn = false,
    this.onToggleOverlay,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bloc = context.read<MultiTimerBloc>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.text, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  timer.done ? l.multiTimerDone : _fmt(timer.remainMs),
                  style: TextStyle(
                    color: timer.done ? AppColors.accent : AppColors.muted,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              timer.running ? Icons.pause : Icons.play_arrow,
              color: AppColors.text,
            ),
            tooltip: timer.running ? l.btnPause : l.btnStart,
            onPressed: () => timer.running
                ? bloc.add(MtPause(timer.id))
                : bloc.add(MtStart(timer.id)),
          ),
          IconButton(
            icon: Icon(Icons.replay, color: AppColors.muted),
            tooltip: l.btnReset,
            onPressed: () => bloc.add(MtReset(timer.id)),
          ),
          if (onToggleOverlay != null)
            IconButton(
              icon: Icon(
                overlayOn
                    ? Icons.picture_in_picture
                    : Icons.picture_in_picture_outlined,
                color: overlayOn ? AppColors.accent : AppColors.muted,
              ),
              tooltip: overlayOn
                  ? l.multiTimerOverlayOff
                  : l.multiTimerOverlayOn,
              onPressed: onToggleOverlay,
            ),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.muted),
            tooltip: l.delete,
            onPressed: () => bloc.add(MtRemove(timer.id)),
          ),
        ],
      ),
    );
  }
}
