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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    LiveActivityService.init();
    _startTimer();
    if (Platform.isAndroid) {
      _listenOverlayCommands();
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
    super.dispose();
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
    return Scaffold(
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
