import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'features/timer/bloc/timer_bloc.dart';
import 'features/timer/bloc/timer_event.dart';
import 'features/timer/bloc/timer_state.dart';
import 'features/stopwatch/bloc/stopwatch_bloc.dart';
import 'features/stopwatch/bloc/stopwatch_event.dart';
import 'features/stopwatch/bloc/stopwatch_state.dart';
import 'features/timer/widgets/timer_controls.dart';
import 'features/timer/widgets/segment_editor.dart';
import 'features/stopwatch/widgets/stopwatch_controls.dart';
import 'widgets/clock_painter.dart';
import 'widgets/bottom_panels.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'overlay/overlay_service.dart';
import 'live_activity/live_activity_service.dart';
import 'services/persistence_service.dart';
import 'services/desktop_service.dart';
import 'services/desktop_notification_service.dart';
import 'services/sync_service.dart';
import 'features/timer/models/segment.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _clockTimer;
  Timer? _persistTimer;
  DateTime _now = DateTime.now();
  bool _overlayOn = false;
  int _syncTick = 0;
  bool _inBackground = false;

  // 데스크톱 전용 — 멀티기기 동기화 / 트레이 / 알림
  final SyncService _sync = SyncService();
  Timer? _trayTimer;
  TimerState? _prevTimer;
  bool _applyingRemote = false; // 원격 이벤트 적용 중 echo 발신 방지

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    LiveActivityService.init();
    _prevTimer = context.read<TimerBloc>().state;
    _startTimer();
    if (Platform.isAndroid) {
      _listenOverlayCommands();
      _restoreState();
    } else if (isDesktop) {
      _initDesktop();
      _restoreState();
    }
    // 30초마다 자동 저장 — 앱 강제 종료 직전 저장 실패를 보완
    _persistTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _saveState();
    });
  }

  Future<void> _restoreState() async {
    final overlayOn = await PersistenceService.loadOverlayOn();
    final now = DateTime.now().millisecondsSinceEpoch;

    // 타이머 상태 복원
    final timerData = await PersistenceService.loadTimerState();
    if (timerData != null && mounted) {
      try {
        final segs = (timerData['segments'] as List)
            .map((e) => Segment.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        final statusStr = timerData['status'] as String? ?? 'idle';
        var status = TimerStatus.values.firstWhere(
          (e) => e.name == statusStr,
          orElse: () => TimerStatus.idle,
        );
        var currentSeg = (timerData['currentSeg'] as num?)?.toInt() ?? 0;
        var segRemainMs = (timerData['segRemainMs'] as num?)?.toInt() ?? 0;
        final loop = timerData['loop'] as bool? ?? false;
        final savedAtMs = (timerData['savedAtMs'] as num?)?.toInt();

        if (status == TimerStatus.running &&
            savedAtMs != null &&
            segs.isNotEmpty) {
          final elapsed = (now - savedAtMs).clamp(0, 86400000); // max 24h
          (currentSeg, segRemainMs, status) = _advanceTimer(
            segs,
            currentSeg,
            segRemainMs,
            elapsed,
            loop,
          );
        }

        context.read<TimerBloc>().add(
          TimerRestore(
            segments: segs,
            currentSeg: currentSeg,
            segRemainMs: segRemainMs,
            status: status,
            loop: loop,
          ),
        );
      } catch (_) {}
    }

    // 스톱워치 상태 복원
    final swData = await PersistenceService.loadSwState();
    if (swData != null && mounted) {
      try {
        var elapsedMs = (swData['elapsedMs'] as num?)?.toInt() ?? 0;
        final wasRunning = swData['running'] as bool? ?? false;
        final savedAtMs = (swData['savedAtMs'] as num?)?.toInt();
        final angle = (swData['startAngleRadians'] as num?)?.toDouble();

        if (wasRunning && savedAtMs != null) {
          final elapsed = (now - savedAtMs).clamp(0, 86400000);
          elapsedMs += elapsed;
        }

        if (elapsedMs > 0 || wasRunning) {
          context.read<StopwatchBloc>().add(
            StopwatchRestore(
              elapsedMs: elapsedMs,
              running: wasRunning,
              startAngleRadians: angle,
            ),
          );
        }
      } catch (_) {}
    }

    if (!mounted) return;

    // 오버레이 복원 — 첫 프레임 이후로 지연
    // initState 중에는 overlay 엔진이 준비되지 않을 수 있고, isActive()가
    // 이전 세션 잔류 상태를 반환해 레이스 컨디션 발생 가능
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (overlayOn && await OverlayService.isPermissionGranted) {
        final screenW = MediaQuery.of(context).size.width.round();
        await OverlayService.show(screenWidthDp: screenW);
        if (mounted) setState(() => _overlayOn = true);
      } else {
        _prewarmOverlay();
      }
    });
  }

  /// 앱이 닫혀 있던 동안 타이머가 흘렀다면 세그먼트를 진행시켜 반환
  (int seg, int remainMs, TimerStatus status) _advanceTimer(
    List<Segment> segments,
    int currentSeg,
    int segRemainMs,
    int elapsedMs,
    bool loop,
  ) {
    int remain = segRemainMs - elapsedMs;
    int seg = currentSeg;

    while (remain <= 0) {
      seg++;
      if (seg >= segments.length) {
        if (loop) {
          seg = 0;
        } else {
          return (segments.length - 1, 0, TimerStatus.done);
        }
      }
      remain += segments[seg].duration.inMilliseconds;
    }

    return (seg, remain, TimerStatus.running);
  }

  Future<void> _saveState() async {
    if (!mounted) return;
    final timerState = context.read<TimerBloc>().state;
    final swState = context.read<StopwatchBloc>().state;

    await PersistenceService.saveOverlayOn(_overlayOn);
    await PersistenceService.saveTimerState(
      segments: timerState.segments.map((s) => s.toJson()).toList(),
      currentSeg: timerState.currentSeg,
      segRemainMs: timerState.segRemainMs,
      status: timerState.status.name,
      loop: timerState.loop,
    );
    await PersistenceService.saveSwState(
      elapsedMs: swState.elapsedMs,
      running: swState.running,
      startAngleRadians: swState.startAngleRadians,
    );
  }

  void _listenOverlayCommands() {
    // ignore: prefer_const_constructors
    EventChannel('x-slayer/overlay_to_main').receiveBroadcastStream().listen((
      data,
    ) {
      if (data == null || !mounted) return;
      try {
        final map = Map<String, dynamic>.from(data as Map);
        final action = map['action'] as String?;
        if (action == null) return;
        switch (action) {
          case 'timer_toggle':
            final s = context.read<TimerBloc>().state;
            if (s.status == TimerStatus.running) {
              context.read<TimerBloc>().add(const TimerPause());
            } else if (s.status == TimerStatus.paused) {
              context.read<TimerBloc>().add(const TimerStart());
            }
            // BLoC는 <1ms 안에 처리 — 80ms 대기 불필요, 다음 이벤트 루프 턴에 sync
            Future(() {
              if (mounted) _syncOverlay();
            });
          case 'timer_next':
            context.read<TimerBloc>().add(const TimerNext());
            Future(() {
              if (mounted) _syncOverlay();
            });
          case 'sw_toggle':
            context.read<StopwatchBloc>().add(const StopwatchToggle());
            Future(() {
              if (mounted) _syncOverlay();
            });
          case 'overlay_hide':
            OverlayService.hide();
            setState(() => _overlayOn = false);
        }
      } catch (_) {}
    });
  }

  // 앱 시작 시 오버레이 서비스를 1×1px으로 미리 켜둠 → 첫 "위젯 ON" 즉시 반응
  Future<void> _prewarmOverlay() async {
    if (!await OverlayService.isPermissionGranted) return;
    if (await FlutterOverlayWindow.isActive()) return;
    await FlutterOverlayWindow.showOverlay(
      height: 1,
      width: 1,
      alignment: OverlayAlignment.topCenter,
      positionGravity: PositionGravity.none,
      enableDrag: false,
      overlayTitle: 'Analog Timer',
    );
  }

  void _startTimer() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) return;
      final now = DateTime.now();
      if (_inBackground) {
        // 백그라운드: UI 리빌드 없이 시간만 갱신, 오버레이 동기화는 유지
        _now = now;
      } else {
        setState(() => _now = now);
      }
      _syncTick = (_syncTick + 1) % 3; // 6틱(~96ms) → 3틱(~48ms)
      if (_syncTick == 0) {
        _syncOverlay();
        _syncLiveActivity();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _inBackground = true;
      _saveState();
    } else if (state == AppLifecycleState.detached) {
      _clockTimer?.cancel();
      _clockTimer = null;
      _inBackground = false;
    } else if (state == AppLifecycleState.resumed) {
      _inBackground = false;
      if (_clockTimer == null) _startTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clockTimer?.cancel();
    _persistTimer?.cancel();
    _trayTimer?.cancel();
    _sync.dispose();
    super.dispose();
  }

  // ── 데스크톱 통합 ────────────────────────────────────────────
  Future<void> _initDesktop() async {
    _sync.onRemoteEvent = _applyRemoteSyncEvent;
    DesktopService.instance.onQuit = () async {
      await _saveState();
      await DesktopService.instance.quit();
    };
    _trayTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateTray();
    });
    _updateTray();
  }

  void _updateTray() {
    final ts = context.read<TimerBloc>().state;
    final active =
        ts.status == TimerStatus.running || ts.status == TimerStatus.paused;
    final seg = ts.currentSegment;
    final tooltip = active && seg != null
        ? 'Analog Timer — ${seg.name} ${_fmt(ts.segRemainMs)}'
        : 'Analog Timer';
    final menuStatus = active && seg != null
        ? '${seg.name} · ${_fmt(ts.segRemainMs)}'
        : (ts.status == TimerStatus.done ? '완료' : '대기 중');
    DesktopService.instance.updateTray(tooltip: tooltip, menuStatus: menuStatus);
  }

  /// 타이머 상태 전이 시: (1) 세그먼트 완료 알림, (2) 동기화 이벤트 발신.
  /// segRemainMs 만 바뀌는 매 틱은 listenWhen 에서 걸러진다.
  void _onTimerTransition(TimerState cur) {
    final prev = _prevTimer;
    _prevTimer = cur;
    if (prev == null) return;

    // (1) 알림
    if (cur.status == TimerStatus.done && prev.status != TimerStatus.done) {
      DesktopNotificationService.notify('타이머 완료', '모든 세그먼트를 마쳤습니다 🎉');
    } else if (cur.currentSeg != prev.currentSeg &&
        cur.status == TimerStatus.running &&
        prev.status == TimerStatus.running) {
      final prevName = prev.currentSeg < prev.segments.length
          ? prev.segments[prev.currentSeg].name
          : '';
      final curName = cur.currentSegment?.name ?? '';
      DesktopNotificationService.notify('세그먼트 완료', '$prevName 완료 · 다음: $curName');
    }

    // (2) 동기화 발신 — 원격 적용으로 인한 변화면 echo 금지
    if (_applyingRemote || _sync.roomId.value == null) return;
    String? action;
    if (cur.status == TimerStatus.idle && prev.status != TimerStatus.idle) {
      action = 'reset';
    } else if (cur.status == TimerStatus.paused &&
        prev.status != TimerStatus.paused) {
      action = 'pause';
    } else if (cur.currentSeg != prev.currentSeg) {
      action = 'next';
    } else if (cur.status == TimerStatus.running &&
        prev.status != TimerStatus.running) {
      action = prev.status == TimerStatus.paused ? 'resume' : 'start';
    }
    if (action != null) {
      _sync.emit(
        action: action,
        remainingMs: cur.segRemainMs,
        segIdx: cur.currentSeg,
        segments: SyncCodec.toWebSegments(cur.segments),
        loop: cur.loop,
      );
    }
  }

  void _applyRemoteSyncEvent(SyncEvent e) {
    if (!mounted) return;
    _applyingRemote = true;
    final cur = context.read<TimerBloc>().state;
    var segs = SyncCodec.fromWebSegments(e.segments);
    if (segs.isEmpty) segs = cur.segments;
    var seg = e.segIdx.clamp(0, segs.length - 1);
    var remain = e.remainingMs;
    TimerStatus status;
    switch (e.action) {
      case 'start':
      case 'resume':
        final elapsed = DateTime.now().millisecondsSinceEpoch - e.timestamp;
        remain = (e.remainingMs - elapsed).clamp(0, 86400000);
        status = TimerStatus.running;
      case 'pause':
        status = TimerStatus.paused;
      case 'reset':
        seg = 0;
        remain = 0;
        status = TimerStatus.idle;
      case 'next':
        status =
            cur.status == TimerStatus.idle ? TimerStatus.paused : TimerStatus.running;
      default:
        status = TimerStatus.running;
    }
    context.read<TimerBloc>().add(
      TimerRestore(
        segments: segs,
        currentSeg: seg,
        segRemainMs: remain,
        status: status,
        loop: e.loop,
      ),
    );
    // 적용으로 인한 상태 변화가 리스너를 한 번 트리거한 뒤 해제(no-op 변화 대비 타임아웃).
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _applyingRemote = false;
    });
  }

  String _fmt(int ms) {
    final total = (ms.clamp(0, ms) / 1000).truncate();
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _syncLiveActivity() {
    if (!Platform.isIOS) return;
    final timerState = context.read<TimerBloc>().state;
    final swState = context.read<StopwatchBloc>().state;
    final timerActive =
        timerState.status == TimerStatus.running ||
        timerState.status == TimerStatus.paused;
    final swActive = swState.running || swState.elapsedMs > 0;
    LiveActivityService.update(
      timerActive: timerActive,
      timerLabel: timerState.currentSegment?.name ?? '',
      timerRemain: timerActive ? _fmt(timerState.segRemainMs) : '--:--',
      swActive: swActive,
      swElapsed: swActive ? _fmt(swState.elapsedMs) : '',
    );
  }

  void _syncOverlay() {
    if (!_overlayOn || !Platform.isAndroid) return;
    final timerState = context.read<TimerBloc>().state;
    final swState = context.read<StopwatchBloc>().state;
    final timerActive =
        timerState.status == TimerStatus.running ||
        timerState.status == TimerStatus.paused;
    final swActive = swState.running || swState.elapsedMs > 0;

    final seg = timerState.currentSegment;
    final segTotalMs = seg?.duration.inMilliseconds ?? 1;
    final timerFrac = (timerActive && segTotalMs > 0)
        ? (timerState.segRemainMs / segTotalMs).clamp(0.0, 1.0)
        : 0.0;

    final mq = MediaQuery.of(context);
    final screenW = mq.size.width.round();
    final screenH = mq.size.height.round();

    OverlayService.updateState(
      timerActive: timerActive,
      timerRunning: timerState.status == TimerStatus.running,
      timerLabel: seg?.name ?? '',
      timerRemain: timerActive ? _fmt(timerState.segRemainMs) : '--:--',
      swActive: swActive,
      swRunning: swState.running,
      swElapsed: swActive ? _fmt(swState.elapsedMs) : '',
      timerColorValue: seg?.color.toARGB32() ?? 0xFFE07A52,
      timerFrac: timerFrac,
      ending: timerActive && timerState.segRemainMs <= 10000,
      segRemainMs: timerState.segRemainMs,
      swElapsedMs: swState.elapsedMs,
      swStartAngleRad: swState.startAngleRadians,
      screenWidthDp: screenW,
      screenHeightDp: screenH,
    );
  }

  Future<void> _toggleOverlay() async {
    if (!Platform.isAndroid) return;
    if (!await OverlayService.isPermissionGranted) {
      await OverlayService.requestPermission();
      return;
    }
    if (_overlayOn) {
      await OverlayService.hide();
      setState(() => _overlayOn = false);
      PersistenceService.saveOverlayOn(false);
    } else {
      final screenW = MediaQuery.of(context).size.width.round();
      await OverlayService.show(screenWidthDp: screenW);
      setState(() => _overlayOn = true);
      PersistenceService.saveOverlayOn(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      backgroundColor: AppColors.bg,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  children: [
                    // Title + overlay toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            '⏱ ANALOG TIMER',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.bebasNeue(
                              fontSize: 34,
                              letterSpacing: 4,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                        if (Platform.isAndroid) ...[
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _toggleOverlay,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _overlayOn
                                    ? AppColors.accent.withAlpha(0x33)
                                    : AppColors.surface,
                                border: Border.all(
                                  color: _overlayOn
                                      ? AppColors.accent
                                      : AppColors.border,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _overlayOn ? '위젯 ON' : '위젯',
                                style: TextStyle(
                                  color: _overlayOn
                                      ? AppColors.accent
                                      : AppColors.muted,
                                  fontSize: 11,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (isDesktop) ...[
                      _DesktopSyncBar(sync: _sync),
                      const SizedBox(height: 16),
                    ],

                    _ClockWidget(now: _now),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 16,
                      children: [
                        _Legend(
                          color: AppColors.timerOrange,
                          label: '타이머 — 안쪽 나선',
                        ),
                        _Legend(color: AppColors.swGreen, label: '스톱워치 — 바깥 링'),
                      ],
                    ),
                    const SizedBox(height: 8),

                    _ProgressBar(),
                    const SizedBox(height: 20),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(child: TimerControls()),
                        SizedBox(width: 16),
                        Expanded(child: StopwatchControls()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const SegmentEditor(),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(child: LapList()),
                        SizedBox(width: 10),
                        Expanded(child: TimerLog()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!isDesktop) return scaffold;
    // 데스크톱: 타이머 상태 전이를 감지해 알림/동기화 발신. segRemainMs 만
    // 바뀌는 매 프레임은 무시하고 status/세그먼트/loop 변화에만 반응한다.
    return BlocListener<TimerBloc, TimerState>(
      listenWhen: (p, c) =>
          p.status != c.status ||
          p.currentSeg != c.currentSeg ||
          p.loop != c.loop ||
          !identical(p.segments, c.segments),
      listener: (_, state) => _onTimerTransition(state),
      child: scaffold,
    );
  }
}

class _ClockWidget extends StatelessWidget {
  final DateTime now;
  const _ClockWidget({required this.now});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, timerState) {
        return BlocBuilder<StopwatchBloc, StopwatchState>(
          builder: (context, swState) {
            return Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: CustomPaint(
                    painter: ClockPainter(
                      timerState: timerState,
                      swState: swState,
                      now: now,
                    ),
                  ),
                ),
                _CenterInfo(timerState: timerState, swState: swState),
              ],
            );
          },
        );
      },
    );
  }
}

class _CenterInfo extends StatelessWidget {
  final TimerState timerState;
  final StopwatchState swState;
  const _CenterInfo({required this.timerState, required this.swState});

  String _fmtMs(int ms) {
    final total = (ms.clamp(0, ms) / 1000).truncate();
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final seg = timerState.currentSegment;
    final isActive =
        timerState.status == TimerStatus.running ||
        timerState.status == TimerStatus.paused;

    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive && seg != null) ...[
            Text(
              seg.name,
              style: GoogleFonts.bebasNeue(
                fontSize: 16,
                letterSpacing: 1.5,
                color: seg.color,
              ),
            ),
            Text(
              _fmtMs(timerState.segRemainMs),
              style: GoogleFonts.bebasNeue(
                fontSize: 48,
                color: seg.color,
                letterSpacing: 1,
              ),
            ),
          ] else ...[
            Text(
              '--:--',
              style: GoogleFonts.bebasNeue(
                fontSize: 48,
                color: AppColors.timerOrangeDark.withAlpha(0x44),
                letterSpacing: 1,
              ),
            ),
          ],
          if (swState.running || swState.elapsedMs > 0)
            Text(
              '⏱ ${_fmtMs(swState.elapsedMs)}',
              style: GoogleFonts.bebasNeue(
                fontSize: 30,
                color: AppColors.swGreen,
                letterSpacing: 1,
              ),
            ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        final pct = state.totalMs > 0
            ? (state.elapsedMs / state.totalMs).clamp(0.0, 1.0)
            : 0.0;
        final color = state.currentSegment?.color ?? AppColors.timerOrange;
        return Container(
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(99),
          ),
          child: FractionallySizedBox(
            widthFactor: pct,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 데스크톱 멀티기기 동기화 바 — 방 코드 생성/참가/나가기 + 연결 상태 표시.
class _DesktopSyncBar extends StatefulWidget {
  final SyncService sync;
  const _DesktopSyncBar({required this.sync});

  @override
  State<_DesktopSyncBar> createState() => _DesktopSyncBarState();
}

class _DesktopSyncBarState extends State<_DesktopSyncBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _join() {
    final code = _controller.text.trim();
    if (code.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').length < 4) return;
    widget.sync.join(code);
  }

  void _newRoom() {
    final code = SyncService.randomRoomCode();
    _controller.text = code;
    widget.sync.join(code);
  }

  Future<void> _copy(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('방 코드 복사됨: $code'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: widget.sync.roomId,
      builder: (context, room, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: room == null ? _offline() : _online(room),
        );
      },
    );
  }

  Widget _offline() {
    return Row(
      children: [
        const Icon(Icons.sync, size: 16, color: AppColors.muted),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 34,
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (_) => _join(),
              style: const TextStyle(color: AppColors.text, fontSize: 13),
              decoration: InputDecoration(
                hintText: '방 코드 (4~8자)',
                hintStyle:
                    const TextStyle(color: AppColors.muted, fontSize: 12),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                filled: true,
                fillColor: AppColors.bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        _btn('참가', _join),
        const SizedBox(width: 6),
        _btn('새 방', _newRoom, accent: true),
      ],
    );
  }

  Widget _online(String room) {
    return Row(
      children: [
        ValueListenableBuilder<SyncStatus>(
          valueListenable: widget.sync.status,
          builder: (context, st, _) => _dot(st),
        ),
        const SizedBox(width: 10),
        const Text('방 ', style: TextStyle(color: AppColors.muted, fontSize: 12)),
        SelectableText(
          room,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const Spacer(),
        _btn('복사', () => _copy(room)),
        const SizedBox(width: 6),
        _btn('나가기', widget.sync.leave),
      ],
    );
  }

  Widget _dot(SyncStatus st) {
    final (color, label) = switch (st) {
      SyncStatus.online => (AppColors.swGreen, '연결됨'),
      SyncStatus.connecting => (AppColors.accent, '연결 중'),
      SyncStatus.error => (AppColors.danger, '오류'),
      SyncStatus.offline => (AppColors.muted, '오프라인'),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }

  Widget _btn(String label, VoidCallback onTap, {bool accent = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: accent ? AppColors.accent.withAlpha(0x33) : AppColors.bg,
          border:
              Border.all(color: accent ? AppColors.accent : AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: accent ? AppColors.accent : AppColors.muted,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
