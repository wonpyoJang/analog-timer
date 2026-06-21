import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'l10n/app_localizations.dart';
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
import 'widgets/date_label.dart';
import 'widgets/language_picker.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'overlay/overlay_service.dart';
import 'live_activity/live_activity_service.dart';
import 'pip/pip_service.dart';
import 'services/persistence_service.dart';
import 'services/native_widget_service.dart';
import 'services/desktop_service.dart';
import 'services/desktop_notification_service.dart';
import 'services/desktop_overlay_service.dart';
import 'features/timer/models/segment.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _clockTimer;
  Timer? _persistTimer;
  Timer? _overlayHealthTimer;
  DateTime _now = DateTime.now();
  bool _overlayOn = false;
  bool _overlayShowInFlight = false; // concurrent show() race guard
  bool _pendingOverlayEnable = false; // permission 요청 후 복귀 시 자동 시작 플래그
  int _syncTick = 0;
  int _nativeTick = 0;
  bool _inBackground = false;

  // 데스크톱 전용 — 트레이 / 알림 / 플로팅 오버레이 위젯
  Timer? _trayTimer;
  TimerState? _prevTimer;
  bool _desktopOverlayOn = false;

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
    } else if (Platform.isIOS) {
      _loadIosWidgetPref();
    } else if (isDesktop) {
      _initDesktop();
      _restoreState();
    }
    // 30초마다 자동 저장 — 앱 강제 종료 직전 저장 실패를 보완
    _persistTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _saveState();
    });
  }

  Future<void> _loadIosWidgetPref() async {
    final on = await PersistenceService.loadOverlayOn();
    if (mounted) setState(() => _overlayOn = on);
    if (on) await PipService.start();
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
      // 데스크톱: 위젯(오버레이 서브윈도우)이 켜져 있던 상태면 시작 시 복원.
      if (isDesktop) {
        if (overlayOn) {
          await DesktopOverlayService.instance.show(_overlayStateMap());
          if (mounted) setState(() => _desktopOverlayOn = true);
        }
        return;
      }
      if (overlayOn && await OverlayService.isPermissionGranted) {
        if (!mounted) return;
        final screenW = MediaQuery.of(context).size.width.round();
        await OverlayService.show(screenWidthDp: screenW);
        if (mounted) {
          setState(() => _overlayOn = true);
          _syncHealthTimer();
        }
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
      final dur = segments[seg].duration.inMilliseconds;
      // 0ms 세그먼트는 무한 루프를 유발하므로 즉시 완료 처리
      if (dur <= 0) return (seg, 0, TimerStatus.done);
      remain += dur;
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
            } else if (s.status == TimerStatus.paused ||
                s.status == TimerStatus.done) {
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
            // hide는 fire-and-forget OK — resizeOverlay(1,1)이므로 실패해도 health timer가 복원
            unawaited(OverlayService.hide());
            setState(() => _overlayOn = false);
            _syncHealthTimer();
            PersistenceService.saveOverlayOn(false);
            NativeWidgetService.cancelNotification();
        }
      } catch (_) {}
    });
  }

  // 앱 시작 시 오버레이 서비스를 1×1px으로 미리 켜둠 → 첫 "위젯 ON" 즉시 반응
  Future<void> _prewarmOverlay() async {
    if (!await OverlayService.isPermissionGranted) return;
    if (await FlutterOverlayWindow.isActive()) return;
    // focusPointer, enableDrag 는 showOverlay 시 WindowManager에 등록되며
    // resizeOverlay로는 변경 불가 — show()와 동일하게 맞춰야 버튼 탭이 동작함
    await FlutterOverlayWindow.showOverlay(
      height: 1,
      width: 1,
      alignment: OverlayAlignment.topCenter,
      positionGravity: PositionGravity.none,
      enableDrag: true,
      flag: OverlayFlag.focusPointer,
      overlayTitle: 'Analog Timer',
    );
  }

  // STT-08 헬퍼: 권한이 실제 허용된 경우에만 overlay 시작 (requestPermission 호출 없음)
  Future<void> _startOverlayIfPermitted() async {
    if (!await OverlayService.isPermissionGranted) return;
    if (!mounted || _overlayOn) return;
    final screenW = MediaQuery.of(context).size.width.round();
    await OverlayService.show(screenWidthDp: screenW);
    if (!mounted) return;
    setState(() => _overlayOn = true);
    _syncHealthTimer();
    PersistenceService.saveOverlayOn(true);
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
      _syncTick = (_syncTick + 1) % 3;
      if (_syncTick == 0) {
        _syncOverlay();
        _syncLiveActivity();
        _syncDesktopOverlay();
      }
      _nativeTick = (_nativeTick + 1) % 62; // ~1초마다
      if (_nativeTick == 0) _syncNativeWidget();
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
      if (_overlayOn && Platform.isAndroid) _restoreOverlayIfDead();
      // STT-08: 권한 요청 화면에서 돌아왔을 때 권한이 허용됐으면 자동 시작
      // _toggleOverlay() 직접 호출 금지 — 거부 시 _pendingOverlayEnable=true 재설정 후
      // requestPermission() 재호출 → paused/resumed 무한 루프 발생
      if (_pendingOverlayEnable && Platform.isAndroid) {
        _pendingOverlayEnable = false;
        unawaited(_startOverlayIfPermitted());
      }
    }
  }

  // isActive()가 stale-true인 경우: 서비스가 살아있다고 판단했지만 실제론 죽은 상태.
  // resume 시 isActive()를 재확인해서 false면 show()로 재시작.
  // _overlayShowInFlight: health timer와 resumed 이벤트의 동시 호출 race 방지
  Future<void> _restoreOverlayIfDead() async {
    if (_overlayShowInFlight) return;
    if (!await FlutterOverlayWindow.isActive()) {
      if (!mounted) return;
      _overlayShowInFlight = true;
      try {
        final screenW = MediaQuery.of(context).size.width.round();
        await OverlayService.show(screenWidthDp: screenW);
      } finally {
        _overlayShowInFlight = false;
      }
    }
  }

  // 인-포어그라운드 OOM kill 감지 — 포커스 전환 없이 서비스가 죽는 경우를
  // resumed 이벤트가 잡지 못하므로 10초 주기로 직접 확인
  void _syncHealthTimer() {
    if (_overlayOn && Platform.isAndroid) {
      _overlayHealthTimer ??= Timer.periodic(
        const Duration(seconds: 10),
        (_) => _restoreOverlayIfDead(),
      );
    } else {
      _overlayHealthTimer?.cancel();
      _overlayHealthTimer = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clockTimer?.cancel();
    _persistTimer?.cancel();
    _overlayHealthTimer?.cancel();
    _trayTimer?.cancel();
    super.dispose();
  }

  // ── 데스크톱 통합 ────────────────────────────────────────────
  Future<void> _initDesktop() async {
    // 오버레이(서브윈도우) 버튼 → 메인으로 전달되는 액션 처리
    DesktopOverlayService.instance.onAction = _handleOverlayAction;
    // 종료 직전 상태 저장만 — 실제 종료(exit)와 오버레이 정리는
    // DesktopService.quit() 및 프로세스 종료가 담당한다.
    DesktopService.instance.onQuit = () async {
      await _saveState();
    };
    _trayTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateTray();
    });
    _updateTray();
  }

  /// 플로팅 오버레이 위젯(항상 위) 토글.
  Future<void> _toggleDesktopOverlay() async {
    if (_desktopOverlayOn) {
      await DesktopOverlayService.instance.hide();
      setState(() => _desktopOverlayOn = false);
    } else {
      await DesktopOverlayService.instance.show(_overlayStateMap());
      setState(() => _desktopOverlayOn = true);
    }
  }

  /// 오버레이 서브윈도우 버튼에서 올라온 액션을 메인 타이머/스톱워치에 반영.
  void _handleOverlayAction(String action) {
    if (!mounted) return;
    switch (action) {
      case 'timer_toggle':
        final s = context.read<TimerBloc>().state;
        if (s.status == TimerStatus.running) {
          context.read<TimerBloc>().add(const TimerPause());
        } else if (s.status == TimerStatus.paused ||
            s.status == TimerStatus.idle ||
            s.status == TimerStatus.done) {
          context.read<TimerBloc>().add(const TimerStart());
        }
      case 'timer_next':
        context.read<TimerBloc>().add(const TimerNext());
      case 'sw_toggle':
        context.read<StopwatchBloc>().add(const StopwatchToggle());
      case 'overlay_hide':
        DesktopOverlayService.instance.hide();
        setState(() => _desktopOverlayOn = false);
    }
  }

  /// 오버레이로 보낼 현재 타이머/스톱워치 상태 스냅샷.
  Map<String, dynamic> _overlayStateMap() {
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
    return {
      'timerActive': timerActive,
      'timerRunning': timerState.status == TimerStatus.running,
      'timerLabel': seg?.name ?? '',
      'timerRemain': timerActive ? _fmt(timerState.segRemainMs) : '--:--',
      'swActive': swActive,
      'swRunning': swState.running,
      'swElapsed': swActive ? _fmt(swState.elapsedMs) : '',
      'timerColorValue': seg?.color.toARGB32() ?? 0xFFE07A52,
      'timerFrac': timerFrac,
      'ending': timerActive && timerState.segRemainMs <= 10000,
      'segRemainMs': timerState.segRemainMs,
      'swElapsedMs': swState.elapsedMs,
      'swStartAngleRad': swState.startAngleRadians,
    };
  }

  void _updateTray() {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    final ts = context.read<TimerBloc>().state;
    final active =
        ts.status == TimerStatus.running || ts.status == TimerStatus.paused;
    final seg = ts.currentSegment;
    final tooltip = active && seg != null
        ? 'Analog Timer — ${seg.name} ${_fmt(ts.segRemainMs)}'
        : 'Analog Timer';
    final menuStatus = active && seg != null
        ? '${seg.name} · ${_fmt(ts.segRemainMs)}'
        : (ts.status == TimerStatus.done ? l.statusDone : l.statusWaiting);
    DesktopService.instance.updateTray(
      tooltip: tooltip,
      menuStatus: menuStatus,
    );
  }

  /// 타이머 상태 전이 시 세그먼트 완료 / 전체 완료 데스크톱 알림.
  /// segRemainMs 만 바뀌는 매 틱은 listenWhen 에서 걸러진다.
  void _onTimerTransition(TimerState cur) {
    final prev = _prevTimer;
    _prevTimer = cur;
    if (prev == null) return;
    if (!mounted) return;
    final l = AppLocalizations.of(context);

    if (cur.status == TimerStatus.done && prev.status != TimerStatus.done) {
      DesktopNotificationService.notify(
        l.notifyTimerDoneTitle,
        l.notifyTimerDoneBody,
      );
    } else if (cur.currentSeg != prev.currentSeg &&
        cur.status == TimerStatus.running &&
        prev.status == TimerStatus.running) {
      final prevName = prev.currentSeg < prev.segments.length
          ? prev.segments[prev.currentSeg].name
          : '';
      final curName = cur.currentSegment?.name ?? '';
      DesktopNotificationService.notify(
        l.notifySegmentDoneTitle,
        l.notifySegmentDoneBody(prevName, curName),
      );
    }
  }

  String _fmt(int ms) {
    if (ms <= 0) return '00:00';
    final total = (ms / 1000).truncate();
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _syncLiveActivity() {
    if (!Platform.isIOS || !_overlayOn) return;
    final timerState = context.read<TimerBloc>().state;
    final swState = context.read<StopwatchBloc>().state;
    final timerActive =
        timerState.status == TimerStatus.running ||
        timerState.status == TimerStatus.paused;
    final timerDone = timerState.status == TimerStatus.done;
    final swActive = swState.running || swState.elapsedMs > 0;
    final seg = timerState.currentSegment;
    final segTotalMs = seg?.duration.inMilliseconds ?? 1;
    final timerFrac = (timerActive && segTotalMs > 0)
        ? (timerState.segRemainMs / segTotalMs).clamp(0.0, 1.0)
        : 0.0;
    final timerColorValue = seg?.color.toARGB32() ?? 0xFFE07A52;
    final timerLabel = seg?.name ?? '';
    final timerRemain = timerActive ? _fmt(timerState.segRemainMs) : '--:--';
    final ending = timerActive && timerState.segRemainMs <= 10000;
    final swElapsed = swActive ? _fmt(swState.elapsedMs) : '';

    LiveActivityService.update(
      timerActive: timerActive,
      timerRunning: timerState.status == TimerStatus.running,
      timerDone: timerDone,
      timerLabel: timerLabel,
      timerRemain: timerRemain,
      timerColorValue: timerColorValue,
      timerFrac: timerFrac,
      ending: ending,
      segRemainMs: timerState.segRemainMs,
      swActive: swActive,
      swRunning: swState.running,
      swElapsed: swElapsed,
      swElapsedMs: swState.elapsedMs,
    );

    PipService.update(
      timerActive: timerActive,
      timerRunning: timerState.status == TimerStatus.running,
      timerDone: timerDone,
      timerLabel: timerLabel,
      timerRemain: timerRemain,
      timerColorValue: timerColorValue,
      timerFrac: timerFrac,
      ending: ending,
      swActive: swActive,
      swRunning: swState.running,
      swElapsed: swElapsed,
    );
  }

  void _syncNativeWidget() {
    if (!Platform.isAndroid) return;
    final timerState = context.read<TimerBloc>().state;
    final swState = context.read<StopwatchBloc>().state;
    final timerActive =
        timerState.status == TimerStatus.running ||
        timerState.status == TimerStatus.paused;
    final swActive = swState.running || swState.elapsedMs > 0;
    final seg = timerState.currentSegment;

    NativeWidgetService.updateState(
      timerActive: timerActive,
      timerLabel: seg?.name ?? '',
      timerTime: timerActive ? _fmt(timerState.segRemainMs) : '--:--',
      swTime: swActive ? _fmt(swState.elapsedMs) : '',
      timerColor: seg?.color.toARGB32() ?? 0xFFE07A52,
    );
  }

  void _syncDesktopOverlay() {
    if (!_desktopOverlayOn || !isDesktop) return;
    DesktopOverlayService.instance.update(_overlayStateMap());
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

    final timerDone = timerState.status == TimerStatus.done;
    OverlayService.updateState(
      timerActive: timerActive,
      timerRunning: timerState.status == TimerStatus.running,
      timerLabel: seg?.name ?? '',
      timerRemain: timerActive ? _fmt(timerState.segRemainMs) : '--:--',
      timerDone: timerDone,
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
      localeTag: _currentLocaleTag(context),
    );
  }

  /// 현재 앱 locale → 'ko' / 'zh_Hant' 형태 태그
  static String _currentLocaleTag(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.scriptCode != null) {
      return '${locale.languageCode}_${locale.scriptCode}';
    }
    return locale.languageCode;
  }

  Future<void> _toggleOverlay() async {
    if (Platform.isIOS) {
      if (_overlayOn) {
        await PipService.stop();
        await LiveActivityService.end();
        setState(() => _overlayOn = false);
        PersistenceService.saveOverlayOn(false);
      } else {
        setState(() => _overlayOn = true);
        PersistenceService.saveOverlayOn(true);
        await PipService.start();
        _syncLiveActivity();
      }
      return;
    }
    if (!Platform.isAndroid) return;
    if (!await OverlayService.isPermissionGranted) {
      _pendingOverlayEnable = true;
      await OverlayService.requestPermission();
      return;
    }
    if (!mounted) return;
    if (_overlayOn) {
      await OverlayService.hide();
      if (!mounted) return;
      setState(() => _overlayOn = false);
      _syncHealthTimer();
      PersistenceService.saveOverlayOn(false);
    } else {
      final screenW = MediaQuery.of(context).size.width.round();
      await OverlayService.show(screenWidthDp: screenW);
      if (!mounted) return;
      setState(() => _overlayOn = true);
      _syncHealthTimer();
      PersistenceService.saveOverlayOn(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
                    // Title + overlay toggle + language picker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '⏱ ${l.appTitle}',
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ),
                        if (Platform.isAndroid || Platform.isIOS) ...[
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
                                _overlayOn ? l.widgetOn : l.widget,
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
                        if (isDesktop) ...[
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _toggleDesktopOverlay,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _desktopOverlayOn
                                    ? AppColors.accent.withAlpha(0x33)
                                    : AppColors.surface,
                                border: Border.all(
                                  color: _desktopOverlayOn
                                      ? AppColors.accent
                                      : AppColors.border,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _desktopOverlayOn ? l.widgetOn : l.widget,
                                style: TextStyle(
                                  color: _desktopOverlayOn
                                      ? AppColors.accent
                                      : AppColors.muted,
                                  fontSize: 11,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => showLanguagePicker(context),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.language,
                              size: 16,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _DateLine(now: _now),
                    const SizedBox(height: 16),

                    _ClockWidget(now: _now),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 16,
                      children: [
                        _Legend(
                          color: AppColors.timerOrange,
                          label: l.legendTimer,
                        ),
                        _Legend(
                          color: AppColors.swGreen,
                          label: l.legendStopwatch,
                        ),
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

class _DateLine extends StatelessWidget {
  final DateTime now;
  const _DateLine({required this.now});

  @override
  Widget build(BuildContext context) {
    return Text(
      formatDateLine(now, Localizations.localeOf(context).languageCode),
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
        color: AppColors.text.withAlpha(0xAA),
        fontFeatures: const [FontFeature.tabularFigures()],
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

const _kTextHalo = [
  Shadow(offset: Offset(-1.5, 0), blurRadius: 3, color: Colors.white),
  Shadow(offset: Offset(1.5, 0), blurRadius: 3, color: Colors.white),
  Shadow(offset: Offset(0, -1.5), blurRadius: 3, color: Colors.white),
  Shadow(offset: Offset(0, 1.5), blurRadius: 3, color: Colors.white),
];

class _CenterInfo extends StatelessWidget {
  final TimerState timerState;
  final StopwatchState swState;
  const _CenterInfo({required this.timerState, required this.swState});

  String _fmtMs(int ms) {
    if (ms <= 0) return '00:00';
    final total = ms ~/ 1000;
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
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: seg.color,
                shadows: _kTextHalo,
              ),
            ),
            Text(
              _fmtMs(timerState.segRemainMs),
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 44,
                fontWeight: FontWeight.w700,
                color: seg.color,
                fontFeatures: const [FontFeature.tabularFigures()],
                shadows: _kTextHalo,
              ),
            ),
          ] else ...[
            Text(
              '--:--',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 44,
                fontWeight: FontWeight.w700,
                color: Color(0x44E07A52),
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
          if (swState.running || swState.elapsedMs > 0)
            Text(
              '⏱ ${_fmtMs(swState.elapsedMs)}',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.swGreen,
                fontFeatures: [FontFeature.tabularFigures()],
                shadows: _kTextHalo,
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
