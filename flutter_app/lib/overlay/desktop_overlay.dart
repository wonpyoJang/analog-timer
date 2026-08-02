import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import 'dart:io';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';
import 'overlay_clock_painter.dart';
import '../services/desktop_service.dart';
import '../services/native_confirm.dart';
import '../services/telemetry_service.dart';
import '../widgets/date_label.dart';
import '../widgets/text_outline.dart';

const _kOverlayPosX = 'overlay_pos_x';
const _kOverlayPosY = 'overlay_pos_y';
const _kOverlayScale = 'overlay_scale';
const _kOverlayOpacity = 'overlay_opacity';

/// 위치/스케일 전용 파일 스토어 — 서브엔진이 SharedPreferences 를 쓰면 자기
/// 스냅샷 캐시로 파일 전체를 재작성해 메인 엔진이 저장한 타이머 상태/설정을
/// 롤백시킨다(breadcrumb/review 가 겪은 것과 동일한 race). 서브엔진의 prefs
/// 접근을 아예 없애기 위해 전용 JSON 파일을 쓴다.
File _overlayPrefsFile() {
  final appdata = Platform.environment['APPDATA'];
  final base = (Platform.isWindows && appdata != null)
      ? '$appdata\\dev.analogtimer\\analog_timer'
      : Directory.systemTemp.path;
  return File('$base${Platform.pathSeparator}analog_timer_overlay.json');
}

Future<Map<String, dynamic>> _loadOverlayPrefs() async {
  try {
    final f = _overlayPrefsFile();
    if (await f.exists()) {
      return (jsonDecode(await f.readAsString()) as Map).cast<String, dynamic>();
    }
  } catch (_) {}
  return {};
}

Future<void> _saveOverlayPrefs(Map<String, dynamic> updates) async {
  try {
    final f = _overlayPrefsFile();
    final m = await _loadOverlayPrefs()..addAll(updates);
    await f.parent.create(recursive: true);
    await f.writeAsString(jsonEncode(m));
  } catch (_) {}
}
const _overlayBase = Size(220, 270); // scale=1 기준(디자인) 크기
const _scaleMin = 0.7;
const _scaleMax = 1.8;

Size _sizeForScale(double s) => Size(_overlayBase.width * s, _overlayBase.height * s);

/// 서브윈도우(오버레이) 진입점 — frameless / always-on-top / skipTaskbar 로 구성 후 실행.
///
/// 서브윈도우에선 window_manager 의 getPosition / onWindowMoved 가 동작하지 않으므로,
/// 위치는 Dart 에서 직접 추적(드래그 시 setPosition)하고 prefs 에 저장한다.
Future<void> runDesktopOverlay(Map<String, dynamic> args) async {
  final ovPrefs = await _loadOverlayPrefs();
  final scale = ((ovPrefs[_kOverlayScale] as num?)?.toDouble() ?? 1.0)
      .clamp(_scaleMin, _scaleMax);
  final initialPos = await _resolveInitialPosition(ovPrefs, scale);
  // 배경을 불투명 다크로 — 투명 레이어드 윈도우는 일부(구형/Intel) GPU 에서
  // 합성에 실패해 '회색 빈 화면'으로 뜨는 사례가 있어, 투명 의존을 제거한다.
  final opts = WindowOptions(
    size: _sizeForScale(scale),
    minimumSize: _sizeForScale(_scaleMin),
    maximumSize: _sizeForScale(_scaleMax),
    backgroundColor: const Color(0xFF0E0E0F),
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
    alwaysOnTop: true,
  );
  await windowManager.waitUntilReadyToShow(opts, () async {
    await windowManager.setAsFrameless();
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setHasShadow(true);
    // 드래그 리사이즈가 비율을 유지하도록 종횡비 고정(미지원 플랫폼은 무시).
    try {
      await windowManager.setAspectRatio(
        _overlayBase.width / _overlayBase.height,
      );
    } catch (_) {}
    await windowManager.setPosition(initialPos);
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(
    DesktopOverlayApp(
      mainWindowId: args['mainWindowId'] as String? ?? '0',
      initial: args,
      initialPos: initialPos,
      initialScale: scale.toDouble(),
    ),
  );
}

/// 저장된 위치가 있으면 그것을, 없으면 기본 작업영역 우상단을 반환.
///
/// 저장 위치는 **현재 연결된 모니터 위에 있는지 검증**한다 — 외부 모니터에
/// 위젯을 두고 모니터를 분리하면 위젯이 화면 밖에 떠서 '사라진 것처럼' 보이는
/// 문제 방지(멀티모니터 사용자의 고전적 함정).
Future<Offset> _resolveInitialPosition(
  Map<String, dynamic> ovPrefs,
  double scale,
) async {
  final x = (ovPrefs[_kOverlayPosX] as num?)?.toDouble();
  final y = (ovPrefs[_kOverlayPosY] as num?)?.toDouble();
  if (x != null && y != null) {
    final saved = Offset(x, y);
    if (await _isOnAnyDisplay(saved, scale)) return saved;
    // 화면 밖 → 기본 위치로 폴백(아래로 진행)
  }
  try {
    final display = await screenRetriever.getPrimaryDisplay();
    final size = display.visibleSize ?? display.size;
    final origin = display.visiblePosition ?? Offset.zero;
    return Offset(
      origin.dx + size.width - _sizeForScale(scale).width - 12,
      origin.dy + 12,
    );
  } catch (_) {
    return const Offset(60, 60);
  }
}

/// 위젯 사각형이 현재 연결된 모니터 중 하나와 의미있게(드래그 가능한 상단부
/// 40px 이상) 겹치는지 확인. 판별 실패 시 true(보수적으로 저장 위치 존중).
Future<bool> _isOnAnyDisplay(Offset pos, double scale) async {
  try {
    final displays = await screenRetriever.getAllDisplays();
    if (displays.isEmpty) return true;
    final w = _sizeForScale(scale).width;
    for (final d in displays) {
      final dPos = d.visiblePosition ?? Offset.zero;
      final dSize = d.visibleSize ?? d.size;
      final overlapX = (pos.dx + w).clamp(dPos.dx, dPos.dx + dSize.width) -
          pos.dx.clamp(dPos.dx, dPos.dx + dSize.width);
      final topInside = pos.dy >= dPos.dy - 10 &&
          pos.dy + 40 <= dPos.dy + dSize.height;
      if (overlapX >= 60 && topInside) return true;
    }
    return false;
  } catch (_) {
    return true;
  }
}

class DesktopOverlayApp extends StatelessWidget {
  final String mainWindowId;
  final Map<String, dynamic> initial;
  final Offset initialPos;
  final double initialScale;
  const DesktopOverlayApp({
    super.key,
    required this.mainWindowId,
    required this.initial,
    required this.initialPos,
    required this.initialScale,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _OverlayBody(
        mainWindowId: mainWindowId,
        initial: initial,
        initialPos: initialPos,
        initialScale: initialScale,
      ),
    );
  }
}

class _OverlayBody extends StatefulWidget {
  final String mainWindowId;
  final Map<String, dynamic> initial;
  final Offset initialPos;
  final double initialScale;
  const _OverlayBody({
    required this.mainWindowId,
    required this.initial,
    required this.initialPos,
    required this.initialScale,
  });

  @override
  State<_OverlayBody> createState() => _OverlayBodyState();
}

class _OverlayBodyState extends State<_OverlayBody>
    with TickerProviderStateMixin, WindowListener {
  bool _timerActive = false;
  bool _timerRunning = false;
  bool _swActive = false;
  bool _swRunning = false;
  String _timerLabel = '';
  String _timerRemain = '--:--';
  String _swElapsed = '';
  Color _timerColor = const Color(0xFFE07A52);
  bool _ending = false;
  int _segRemainMs = 0;
  int _swElapsedMs = 0;
  double? _swStartAngleRad;

  DateTime _now = DateTime.now();
  Timer? _clockTimer;
  Timer? _displayTimer;
  Timer? _topmostTimer;
  late Offset _winPos; // Dart 측에서 추적하는 창 좌상단(논리 px)
  DateTime? _displayLastTick;
  late final AnimationController _blinkCtrl;

  // 창 투명도 — 사이클 버튼(100→85→70→50→30%)으로 조절, 전용 파일에 저장.
  // 호버 중에는 일시적으로 불투명하게 해 조작성을 보장한다.
  static const _opacitySteps = [1.0, 0.85, 0.7, 0.5, 0.3];
  double _opacity = 1.0;
  bool _hoverOpaque = false;

  // ── 키보드 배치 모드 안내 ─────────────────────────────────
  // 핫키(widget_focus)나 이동 키 사용 시 accent 테두리 + 키 가이드로
  // "지금 키보드가 위젯을 잡고 있다"를 보여준다. Esc/블러로 해제되고,
  // 블러 이벤트가 서브엔진에서 안 올 가능성에 대비해 8초 타임아웃 병행.
  bool _kbMode = false;
  Timer? _kbModeTimer;

  // 드래그 3회째 1회성 힌트 — "키보드로도 이동 가능" (맥락 힌트 서비스와
  // 같은 절제 원칙, 저장은 오버레이 전용 파일).
  String _focusCombo = '';
  bool _dragHintVisible = false;
  Timer? _dragHintTimer;

  void _enterKbMode() {
    if (!_kbMode && mounted) setState(() => _kbMode = true);
    _kbModeTimer?.cancel();
    _kbModeTimer = Timer(const Duration(seconds: 8), _exitKbMode);
  }

  void _exitKbMode() {
    _kbModeTimer?.cancel();
    _kbModeTimer = null;
    if (_kbMode && mounted) setState(() => _kbMode = false);
  }

  @override
  void onWindowBlur() => _exitKbMode();

  Future<void> _maybeShowDragHint() async {
    if (_focusCombo.isEmpty) return; // 핫키 꺼짐/조합 미전달 — 광고할 게 없음
    final m = await _loadOverlayPrefs();
    if (m['overlay_kb_hint_shown'] == true) return;
    final n = ((m['overlay_drag_count'] as num?)?.toInt() ?? 0) + 1;
    if (n < 3) {
      await _saveOverlayPrefs({'overlay_drag_count': n});
      return;
    }
    await _saveOverlayPrefs(
        {'overlay_drag_count': n, 'overlay_kb_hint_shown': true});
    if (!mounted) return;
    setState(() => _dragHintVisible = true);
    _dragHintTimer?.cancel();
    _dragHintTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _dragHintVisible = false);
    });
  }

  void _applyWindowOpacity() {
    unawaited(() async {
      try {
        await windowManager.setOpacity(_hoverOpaque ? 1.0 : _opacity);
      } catch (_) {} // 일부 환경(레이어드 미지원)에선 무시 — 불투명 유지
    }());
  }

  Future<void> _cycleOpacity() async {
    final i = _opacitySteps.indexWhere((v) => (v - _opacity).abs() < 0.01);
    setState(() => _opacity = _opacitySteps[(i + 1) % _opacitySteps.length]);
    _applyWindowOpacity();
    await _saveOverlayPrefs({_kOverlayOpacity: _opacity});
  }

  @override
  void initState() {
    super.initState();
    _winPos = widget.initialPos;
    // 키보드 이동 — 위젯 창 포커스 시 화살표.
    HardwareKeyboard.instance.addHandler(_onMoveKey);
    windowManager.addListener(this); // onWindowBlur → 키보드 모드 해제
    _applyState(widget.initial);
    // 저장된 투명도 적용
    unawaited(_loadOverlayPrefs().then((m) {
      final v = ((m[_kOverlayOpacity] as num?)?.toDouble() ?? 1.0);
      if (!mounted) return;
      setState(() => _opacity = v.clamp(0.3, 1.0));
      _applyWindowOpacity();
    }));
    _clockTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) {
        if (mounted) setState(() => _now = DateTime.now());
      },
    );
    // always-on-top 주기적 재확보 — 다른 창에 가려 '사라진 것처럼' 보이는 것 방지.
    _topmostTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        await windowManager.setAlwaysOnTop(true);
      } catch (_) {}
    });
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 1.0,
    );

    // 메인 윈도우 → 오버레이 상태 push 수신
    WindowController.fromCurrentEngine().then((controller) {
      controller.setWindowMethodHandler((call) async {
        if (call.method == 'update' && call.arguments is String) {
          try {
            final map = jsonDecode(call.arguments as String) as Map<String, dynamic>;
            _applyState(map);
          } catch (_) {}
        } else if (call.method == 'focus') {
          // 전역 핫키(widget_focus) → 키보드 배치 시작.
          try {
            await windowManager.focus();
          } catch (_) {}
          _enterKbMode(); // 테두리 + 키 가이드로 "키보드가 잡았다" 피드백
        }
        return null;
      });
    });
  }

  void _applyState(Map<String, dynamic> map) {
    if (!mounted) {
      _readState(map);
      return;
    }
    final wasEnding = _ending;
    setState(() => _readState(map));
    if (_ending && !wasEnding) {
      _blinkCtrl.repeat(reverse: true);
    } else if (!_ending && wasEnding) {
      _blinkCtrl
        ..stop()
        ..value = 1.0;
    }
    _syncDisplayTimer();
  }

  void _readState(Map<String, dynamic> map) {
    _timerActive = map['timerActive'] as bool? ?? false;
    _timerRunning = map['timerRunning'] as bool? ?? false;
    _timerLabel = map['timerLabel'] as String? ?? '';
    _timerRemain = map['timerRemain'] as String? ?? '--:--';
    _swActive = map['swActive'] as bool? ?? false;
    _swRunning = map['swRunning'] as bool? ?? false;
    _swElapsed = map['swElapsed'] as String? ?? '';
    final colorVal = (map['timerColorValue'] as num?)?.toInt();
    if (colorVal != null) _timerColor = Color(colorVal);
    _ending = map['ending'] as bool? ?? false;
    _segRemainMs = (map['segRemainMs'] as num?)?.toInt() ?? 0;
    _swElapsedMs = (map['swElapsedMs'] as num?)?.toInt() ?? 0;
    _swStartAngleRad = (map['swStartAngleRad'] as num?)?.toDouble();
    _focusCombo = map['widgetFocusCombo'] as String? ?? _focusCombo;
  }

  // push 사이(48ms)를 보간해 숫자가 부드럽게 흐르도록.
  //
  // 33ms(≈30fps) 보간 — 이 위젯은 별도 Flutter 엔진(두 번째 ViewController)이라
  // 60fps 지속 렌더는 일부 GPU/드라이버에서 누적 부하로 TDR(드라이버 타임아웃 리셋)
  // → 위젯/프로세스 크래시를 유발할 수 있다. 30fps 로도 숫자 흐름은 충분히 매끄럽고
  // GPU 부담은 절반으로 준다.
  void _syncDisplayTimer() {
    final shouldRun = _timerRunning || _swRunning;
    if (shouldRun) {
      _displayLastTick = DateTime.now();
      _displayTimer ??= Timer.periodic(const Duration(milliseconds: 33), (_) {
        if (!mounted) return;
        final now = DateTime.now();
        final elapsed = now.difference(_displayLastTick!).inMilliseconds;
        _displayLastTick = now;
        setState(() {
          if (_timerRunning && _segRemainMs > 0) {
            _segRemainMs = max(0, _segRemainMs - elapsed);
            _timerRemain = _fmtMs(_segRemainMs);
          }
          if (_swRunning) {
            _swElapsedMs += elapsed;
            _swElapsed = _fmtMs(_swElapsedMs);
          }
        });
      });
    } else if (_displayTimer != null) {
      _displayTimer?.cancel();
      _displayTimer = null;
      _displayLastTick = null;
    }
  }

  String _fmtMs(int ms) {
    final total = ms.clamp(0, ms) ~/ 1000;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _effectiveTimerColor =>
      _ending ? const Color(0xFFE05252) : _timerColor;

  Future<void> _sendAction(String action) async {
    try {
      await WindowController.fromWindowId(widget.mainWindowId)
          .invokeMethod('action', action);
    } catch (_) {}
  }

  // ── 크기 조절 (우하단 그립 드래그) ───────────────────────────
  // 네이티브 startResizing 으로 부드럽게 리사이즈(종횡비 고정). 릴리즈까지
  // await 가 블록되므로 그 후 커서 기준으로 최종 크기를 계산해 배율을 저장한다.
  bool _resizing = false;
  Future<void> _onResizeStart(DragStartDetails _) async {
    if (_resizing) return;
    _resizing = true;
    try {
      await windowManager.startResizing(ResizeEdge.bottomRight);
    } catch (_) {
      _resizing = false;
      return;
    }
    try {
      // 우하단 리사이즈 → 좌상단(_winPos)은 고정, 폭은 커서 − 좌상단.
      final cursor = await screenRetriever.getCursorScreenPoint();
      final width = (cursor.dx - _winPos.dx).clamp(
        _sizeForScale(_scaleMin).width,
        _sizeForScale(_scaleMax).width,
      );
      final scale =
          (width / _overlayBase.width).clamp(_scaleMin, _scaleMax).toDouble();
      await _saveOverlayPrefs({_kOverlayScale: scale});
    } catch (_) {}
    _resizing = false;
  }

  // 시계 영역 드래그 = 네이티브 startDragging 으로 부드럽게 이동(떨림 없음).
  //
  // 이전엔 onPanUpdate 마다 setPosition 했는데, 창이 움직이면 포인터의 로컬
  // 좌표가 함께 이동해 다음 delta 가 과보정되는 피드백 루프 → 떨림이 발생했다.
  // startDragging() 은 OS 의 이동 루프를 사용해 부드럽고, 릴리즈될 때까지 await
  // 가 블록되므로 그 후 커서 스크린좌표 − 그랩오프셋 으로 최종 위치를 저장한다.
  // (서브윈도우라 window_manager.getPosition() 은 0 을 반환해 쓸 수 없다.)
  bool _dragging = false;
  Future<void> _onDragStart(DragStartDetails _) async {
    if (_dragging) return;
    _dragging = true;
    Offset grab = Offset.zero;
    try {
      grab = (await screenRetriever.getCursorScreenPoint()) - _winPos;
    } catch (_) {}
    try {
      await windowManager.startDragging();
    } catch (_) {
      _dragging = false;
      return;
    }
    try {
      final cursor = await screenRetriever.getCursorScreenPoint();
      _winPos = cursor - grab;
      await _saveOverlayPrefs({
        _kOverlayPosX: _winPos.dx,
        _kOverlayPosY: _winPos.dy,
      });
    } catch (_) {}
    _dragging = false;
    unawaited(_maybeShowDragHint()); // 마우스 이동 직후가 키보드 대안을 알릴 적기
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onMoveKey);
    windowManager.removeListener(this);
    _kbModeTimer?.cancel();
    _dragHintTimer?.cancel();
    _posSaveDebounce?.cancel();
    _clockTimer?.cancel();
    _displayTimer?.cancel();
    _topmostTimer?.cancel();
    _blinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 내용은 고정 디자인 크기(_overlayBase)로 그리고, FittedBox 로 실제 창 크기에
    // 균일 스케일 → 크기 조절 시 시계·글자·버튼이 한꺼번에 비율대로 커지고 작아짐.
    return MouseRegion(
      onEnter: (_) {
        _hoverOpaque = true;
        _applyWindowOpacity();
      },
      onExit: (_) {
        _hoverOpaque = false;
        _applyWindowOpacity();
      },
      child: Material(
        color: const Color(0xFF0E0E0F),
        child: Stack(
        children: [
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: _overlayBase.width,
                height: _overlayBase.height,
                child: _buildContent(),
              ),
            ),
          ),
          // 좌상단 앱 재시작 — "시계 멈춤" 탈출구. 위젯은 별도 엔진이라 메인 창
          // 렌더가 얼어도 이 버튼은 살아 있을 수 있다. 메인을 거치지 않고 이
          // 엔진에서 직접 재기동을 예약하고 프로세스를 끝낸다(exit). 타이머는
          // 30초 주기 저장 + savedAtMs 벽시계 보정으로 이어지므로 손실 없음.
          Positioned(
            left: 0,
            top: 0,
            child: Tooltip(
              message: AppLocalizations.of(context).tipAppRestart,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _restartApp,
                child: const MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.restart_alt,
                      size: 13,
                      color: Color(0xAAF0C040), // accent — 복구 액션임을 드러낸다
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 좌하단 투명도 토글 — 타이머 조작이 아닌 '창 크롬' 컨트롤이므로
          // 컨트롤 행이 아니라 리사이즈 그립과 동급의 작은 코너 아이콘으로 둔다.
          Positioned(
            left: 0,
            bottom: 0,
            child: Tooltip(
              message: AppLocalizations.of(context).tipOverlayOpacity,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _cycleOpacity,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.opacity,
                      size: 12,
                      // 투명도를 낮춰둔 상태면 살짝 밝게 — 활성 상태 힌트
                      color: _opacity < 0.99
                          ? const Color(0xAAFFFFFF)
                          : const Color(0x55FFFFFF),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 우하단 리사이즈 그립 — 드래그로 창 크기 조절
          Positioned(
            right: 0,
            bottom: 0,
            child: Tooltip(
              message: AppLocalizations.of(context).tipOverlayResize,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: _onResizeStart,
                child: const MouseRegion(
                  cursor: SystemMouseCursors.resizeUpLeftDownRight,
                  child: Padding(
                    padding: EdgeInsets.all(3),
                    child: _ResizeGrip(),
                  ),
                ),
              ),
            ),
          ),
          // 키보드 배치 가이드 — 모드 동안만. FittedBox 밖(실픽셀)이라
          // 위젯을 작게 줄여도 글자가 같이 줄지 않는다.
          if (_kbMode)
            Positioned(
              left: 6,
              right: 6,
              bottom: 20,
              child: IgnorePointer(
                child: _hintBox([
                  AppLocalizations.of(context).overlayKbGuide1,
                  AppLocalizations.of(context).overlayKbGuide2,
                ]),
              ),
            ),
          // 드래그 3회째 1회성 힌트 — "키보드로도 이동 가능"
          if (_dragHintVisible && !_kbMode)
            Positioned(
              left: 6,
              right: 6,
              bottom: 20,
              child: IgnorePointer(
                child: _hintBox(
                    [AppLocalizations.of(context).overlayKbHint(_focusCombo)]),
              ),
            ),
        ],
        ),
      ),
    );
  }

  Widget _hintBox(List<String> lines) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xEE1A1A1C),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: const Color(0xFF2E2E32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final line in lines)
              Text(
                line,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 10,
                  height: 1.4,
                  color: Color(0xFFC9C6C0),
                ),
              ),
          ],
        ),
      );

  /// 키보드로 위젯 이동 — 위젯을 클릭(포커스)한 뒤 화살표.
  ///
  /// 화살표 10px 미세 이동, Shift+화살표 60px. 홀드 리핏(KeyRepeatEvent)
  /// 지원으로 꾹 누르면 연속 이동. 오버레이는 별도 엔진이라 이 핸들러는
  /// 위젯 창이 키보드 포커스일 때만 이벤트를 받는다 — 전역 핫키 오염 없음.
  /// (모바일의 3×3 그리드 편집과 달리 데스크톱은 정밀 배치가 목적)
  Timer? _posSaveDebounce;

  void _savePosDebounced() {
    // 홀드 리핏 중 매 이벤트 파일 쓰기 방지 — 이동이 멎으면 저장.
    _posSaveDebounce?.cancel();
    _posSaveDebounce = Timer(const Duration(milliseconds: 400), () {
      _saveOverlayPrefs({
        _kOverlayPosX: _winPos.dx,
        _kOverlayPosY: _winPos.dy,
      });
    });
  }

  bool _onMoveKey(KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) return false;
    final k = e.logicalKey;

    // Esc = 포커스 반환 — 키보드 배치를 마치고 하던 앱으로 돌아간다.
    if (k == LogicalKeyboardKey.escape) {
      _exitKbMode();
      unawaited(() async {
        try {
          await windowManager.blur();
        } catch (_) {}
      }());
      return true;
    }

    // Tab = 수평 대칭(좌↔우), Shift+Tab = 수직 대칭(상↔하) —
    // "위젯이 작업 영역을 가린다 → 반대편으로 휙"을 원탭으로.
    if (k == LogicalKeyboardKey.tab) {
      if (e is KeyRepeatEvent) return true; // 미러는 리핏 무의미
      _enterKbMode();
      unawaited(
          _mirror(horizontal: !HardwareKeyboard.instance.isShiftPressed));
      return true;
    }

    // 1~9 = 3×3 앵커 점프 — 숫자패드 배열이 곧 화면 배열
    // (7·8·9=상단, 4·5·6=중단, 1·2·3=하단). 모바일의 그리드 편집과 동일 개념.
    final anchor = _digitOf(k);
    if (anchor != null) {
      _enterKbMode();
      unawaited(_snapToAnchor(anchor));
      return true;
    }

    double dx = 0, dy = 0;
    if (k == LogicalKeyboardKey.arrowLeft) {
      dx = -1;
    } else if (k == LogicalKeyboardKey.arrowRight) {
      dx = 1;
    } else if (k == LogicalKeyboardKey.arrowUp) {
      dy = -1;
    } else if (k == LogicalKeyboardKey.arrowDown) {
      dy = 1;
    } else {
      return false;
    }
    _enterKbMode(); // 클릭 포커스로 진입한 사용자도 여기서 가이드를 만난다
    final step = HardwareKeyboard.instance.isShiftPressed ? 60.0 : 10.0;
    _winPos = Offset(_winPos.dx + dx * step, _winPos.dy + dy * step);
    unawaited(windowManager.setPosition(_winPos));
    _savePosDebounced();
    return true;
  }

  static int? _digitOf(LogicalKeyboardKey k) {
    const rows = [
      [LogicalKeyboardKey.digit1, LogicalKeyboardKey.numpad1],
      [LogicalKeyboardKey.digit2, LogicalKeyboardKey.numpad2],
      [LogicalKeyboardKey.digit3, LogicalKeyboardKey.numpad3],
      [LogicalKeyboardKey.digit4, LogicalKeyboardKey.numpad4],
      [LogicalKeyboardKey.digit5, LogicalKeyboardKey.numpad5],
      [LogicalKeyboardKey.digit6, LogicalKeyboardKey.numpad6],
      [LogicalKeyboardKey.digit7, LogicalKeyboardKey.numpad7],
      [LogicalKeyboardKey.digit8, LogicalKeyboardKey.numpad8],
      [LogicalKeyboardKey.digit9, LogicalKeyboardKey.numpad9],
    ];
    for (var i = 0; i < rows.length; i++) {
      if (rows[i].contains(k)) return i + 1;
    }
    return null;
  }

  /// 위젯(좌상단 기준)이 현재 놓인 모니터의 작업영역. 못 찾으면 primary.
  Future<(Offset, Size)> _currentDisplayArea() async {
    try {
      final displays = await screenRetriever.getAllDisplays();
      for (final d in displays) {
        final o = d.visiblePosition ?? Offset.zero;
        final s = d.visibleSize ?? d.size;
        if (_winPos.dx >= o.dx &&
            _winPos.dx < o.dx + s.width &&
            _winPos.dy >= o.dy &&
            _winPos.dy < o.dy + s.height) {
          return (o, s);
        }
      }
      final p = await screenRetriever.getPrimaryDisplay();
      return (p.visiblePosition ?? Offset.zero, p.visibleSize ?? p.size);
    } catch (_) {
      return (Offset.zero, const Size(1920, 1080));
    }
  }

  /// 현재 창 크기 — 리사이즈로 배율이 바뀌었을 수 있어 prefs 에서 읽는다.
  Future<Size> _currentWinSize() async {
    final m = await _loadOverlayPrefs();
    final s = ((m[_kOverlayScale] as num?)?.toDouble() ?? widget.initialScale)
        .clamp(_scaleMin, _scaleMax);
    return _sizeForScale(s.toDouble());
  }

  Future<void> _snapToAnchor(int n) async {
    const margin = 12.0;
    final (origin, area) = await _currentDisplayArea();
    final win = await _currentWinSize();
    final col = (n - 1) % 3; // 0=좌, 1=중, 2=우
    final rowFromBottom = (n - 1) ~/ 3; // 0=하단, 1=중단, 2=상단
    final xs = [
      origin.dx + margin,
      origin.dx + (area.width - win.width) / 2,
      origin.dx + area.width - win.width - margin,
    ];
    final ys = [
      origin.dy + area.height - win.height - margin,
      origin.dy + (area.height - win.height) / 2,
      origin.dy + margin,
    ];
    _winPos = Offset(xs[col], ys[rowFromBottom]);
    await windowManager.setPosition(_winPos);
    _savePosDebounced();
  }

  Future<void> _mirror({required bool horizontal}) async {
    final (origin, area) = await _currentDisplayArea();
    final win = await _currentWinSize();
    _winPos = horizontal
        ? Offset(
            2 * origin.dx + area.width - _winPos.dx - win.width, _winPos.dy)
        : Offset(
            _winPos.dx, 2 * origin.dy + area.height - _winPos.dy - win.height);
    await windowManager.setPosition(_winPos);
    _savePosDebounced();
  }

  /// 앱 재시작 — 메인 엔진을 거치지 않는 직접 경로(메인이 얼어 있어도 동작).
  /// 종료는 스크립트(taskkill)에 위임한다 — 서브엔진에서 exit() 를 부르면
  /// 엔진 teardown 레이스로 0xC0000005 가 날 수 있다.
  ///
  /// 확인창은 네이티브(system-modal) — 이 경로가 쓰이는 상황은 대개 메인 렌더가
  /// 죽어 있을 때라 Flutter 다이얼로그로는 고지가 보이지 않는다.
  /// (메인이 얼어 있으면 상태 저장 요청도 닿지 않지만, 타이머는 30초 주기 저장 +
  ///  savedAtMs 벽시계 보정으로 이어지므로 손실은 사실상 없다.)
  bool _restarting = false;
  Future<void> _restartApp() async {
    if (_restarting) return;
    _restarting = true;
    final ok = await nativeConfirm(
      title: DesktopService.restartTitle,
      message: DesktopService.restartMessage,
    );
    if (ok != true) {
      _restarting = false;
      return;
    }
    // 복구 마커 — 메인 엔진이 얼어 있어도 남길 수 있는 파일 경로. 다음 실행이
    // recovery 리포트로 전송(위젯 버튼 = 메인 freeze 의심 상황이므로 가치 높음).
    await TelemetryService.instance.writeRecoveryMarker('widget_restart', {
      'kind': 'widget_restart_button',
      'atMs': DateTime.now().millisecondsSinceEpoch,
    });
    await TelemetryService.instance.markCleanExit();
    await DesktopService.scheduleRelaunch(killSelf: true);
  }

  Widget _buildContent() {
    // 위젯 전체를 드래그 영역으로 — 빈 곳·날짜·시계 어디를 잡아도 창이 이동.
    // (컨트롤 바 버튼/리사이즈 그립은 자체 제스처가 우선 처리되어 예외)
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _onDragStart,
      child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0F),
        // 키보드 배치 모드 = accent 테두리 — 포커스가 위젯에 있음을 표시
        border: Border.all(
          color: _kbMode ? const Color(0xCCF0C040) : const Color(0xFF2E2E32),
          width: _kbMode ? 1.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            // 날짜·요일 — 시계 위 한 줄
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                formatDateLine(
                  _now,
                  Localizations.localeOf(context).languageCode,
                ),
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                  color: const Color(0xFFE8E6E0).withAlpha(0x99),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            // 시계 영역 = 드래그로 창 이동 (서브윈도우라 위치를 직접 추적)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: _onDragStart,
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      painter: OverlayClockPainter(
                        now: _now,
                        timerActive: _timerActive,
                        segRemainMs: _segRemainMs,
                        segColor: _effectiveTimerColor,
                        swActive: _swActive,
                        swElapsedMs: _swElapsedMs,
                        swStartAngleRad: _swStartAngleRad,
                      ),
                      child: const SizedBox.expand(),
                    ),
                    if (_timerActive || _swActive)
                      IgnorePointer(child: _centerInfo()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            _controlBar(),
          ],
        ),
      ),
    );
  }

  Widget _centerInfo() {
    return AnimatedBuilder(
      animation: _blinkCtrl,
      builder: (context, _) {
        final opacity = _ending ? _blinkCtrl.value : 1.0;
        return Opacity(
          opacity: opacity.clamp(0.3, 1.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_timerActive) ...[
                if (_timerLabel.isNotEmpty)
                  // 은은한 느낌은 라벨 전체 Opacity 로 준다(그림자도 같이 흐려짐).
                  Opacity(
                    opacity: 0.75,
                    child: OutlinedText(
                      _timerLabel,
                      strokeWidth: 1.2,
                      style: TextStyle(fontFamily: 'Pretendard',
                        fontSize: 13,
                        letterSpacing: 1.2,
                        color: _effectiveTimerColor,
                      ),
                    ),
                  ),
                OutlinedText(
                  _timerRemain,
                  strokeWidth: 2.4,
                  shadows: textOutline(offset: const Offset(0, 1.5), blur: 2.5),
                  style: TextStyle(fontFamily: 'Pretendard',
                    fontSize: 26,
                    color: _effectiveTimerColor,
                    letterSpacing: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
              if (_swActive)
                OutlinedText(
                  '⏲ $_swElapsed',
                  strokeWidth: 1.8,
                  style: TextStyle(fontFamily: 'Pretendard',
                    fontSize: 17,
                    color: const Color(0xFF2EA84A),
                    letterSpacing: 1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _controlBar() {
    const swColor = Color(0xFF2EA84A);
    final timerColor = _effectiveTimerColor;
    final l = AppLocalizations.of(context);

    // 접근성: 아이콘만 있는 버튼이라 호버 툴팁(+스크린리더 시맨틱)으로 용도 고지.
    Widget btn(IconData icon, Color color, VoidCallback onTap, String tip,
        {double size = 30}) {
      return Tooltip(
        message: tip,
        child: GestureDetector(
          onTap: onTap,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0xCC1A1A1C),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Icon(icon, color: color, size: size * 0.46),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_timerActive) ...[
          btn(_timerRunning ? Icons.pause : Icons.play_arrow, timerColor,
              () => _sendAction('timer_toggle'),
              _timerRunning ? l.btnPause : l.btnStart),
          // ⏭ 즉시 다음(카운트다운 없음)
          btn(Icons.skip_next, timerColor.withValues(alpha: 0.75),
              () => _sendAction('timer_next'), l.btnNext),
        ],
        if (_swActive || _swElapsedMs > 0)
          btn(_swRunning ? Icons.stop : Icons.play_arrow, swColor,
              () => _sendAction('sw_toggle'), l.tipStopwatchToggle),
        btn(Icons.close, Colors.white54, () => _sendAction('overlay_hide'),
            l.tipOverlayHide),
      ],
    );
  }
}

/// 우하단 리사이즈 그립(대각선 3줄).
class _ResizeGrip extends StatelessWidget {
  const _ResizeGrip();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(13, 13), painter: _GripPainter());
}

class _GripPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = const Color(0x88FFFFFF)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(s.width, s.height * 0.35), Offset(s.width * 0.35, s.height), p);
    canvas.drawLine(Offset(s.width, s.height * 0.62), Offset(s.width * 0.62, s.height), p);
    canvas.drawLine(Offset(s.width, s.height * 0.88), Offset(s.width * 0.88, s.height), p);
  }

  @override
  bool shouldRepaint(_GripPainter old) => false;
}
