import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'overlay_clock_painter.dart';

const _kOverlayPosX = 'overlay_pos_x';
const _kOverlayPosY = 'overlay_pos_y';
const _overlaySize = Size(220, 270);

/// 서브윈도우(오버레이) 진입점 — frameless / always-on-top / skipTaskbar 로 구성 후 실행.
///
/// 서브윈도우에선 window_manager 의 getPosition / onWindowMoved 가 동작하지 않으므로,
/// 위치는 Dart 에서 직접 추적(드래그 시 setPosition)하고 prefs 에 저장한다.
Future<void> runDesktopOverlay(Map<String, dynamic> args) async {
  // 배경을 불투명 다크로 — 투명 레이어드 윈도우는 일부(구형/Intel) GPU 에서
  // 합성에 실패해 '회색 빈 화면'으로 뜨는 사례가 있어, 투명 의존을 제거한다.
  const opts = WindowOptions(
    size: _overlaySize,
    minimumSize: _overlaySize,
    backgroundColor: Color(0xFF0E0E0F),
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
    alwaysOnTop: true,
  );
  final prefs = await SharedPreferences.getInstance();
  final initialPos = await _resolveInitialPosition(prefs);
  await windowManager.waitUntilReadyToShow(opts, () async {
    await windowManager.setAsFrameless();
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setHasShadow(true);
    await windowManager.setPosition(initialPos);
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(
    DesktopOverlayApp(
      mainWindowId: args['mainWindowId'] as String? ?? '0',
      initial: args,
      initialPos: initialPos,
    ),
  );
}

/// 저장된 위치가 있으면 그것을, 없으면 기본 작업영역 우상단을 반환.
Future<Offset> _resolveInitialPosition(SharedPreferences prefs) async {
  final x = prefs.getDouble(_kOverlayPosX);
  final y = prefs.getDouble(_kOverlayPosY);
  if (x != null && y != null) return Offset(x, y);
  try {
    final display = await screenRetriever.getPrimaryDisplay();
    final size = display.visibleSize ?? display.size;
    final origin = display.visiblePosition ?? Offset.zero;
    return Offset(
      origin.dx + size.width - _overlaySize.width - 12,
      origin.dy + 12,
    );
  } catch (_) {
    return const Offset(60, 60);
  }
}

class DesktopOverlayApp extends StatelessWidget {
  final String mainWindowId;
  final Map<String, dynamic> initial;
  final Offset initialPos;
  const DesktopOverlayApp({
    super.key,
    required this.mainWindowId,
    required this.initial,
    required this.initialPos,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _OverlayBody(
        mainWindowId: mainWindowId,
        initial: initial,
        initialPos: initialPos,
      ),
    );
  }
}

class _OverlayBody extends StatefulWidget {
  final String mainWindowId;
  final Map<String, dynamic> initial;
  final Offset initialPos;
  const _OverlayBody({
    required this.mainWindowId,
    required this.initial,
    required this.initialPos,
  });

  @override
  State<_OverlayBody> createState() => _OverlayBodyState();
}

class _OverlayBodyState extends State<_OverlayBody>
    with TickerProviderStateMixin {
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
  late Offset _winPos; // Dart 측에서 추적하는 창 좌상단(논리 px)
  DateTime? _displayLastTick;
  late final AnimationController _blinkCtrl;

  // "다음" 버튼 2초 카운트다운 — 그 사이 다시 탭하면 취소(모바일/웹과 동일)
  bool _nextCounting = false;
  double _nextPct = 0.0;
  DateTime? _nextStart;
  Timer? _nextFrameTimer;
  static const _nextDelay = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _winPos = widget.initialPos;
    _applyState(widget.initial);
    _clockTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) {
        if (mounted) setState(() => _now = DateTime.now());
      },
    );
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
  }

  // push 사이(48ms)를 보간해 숫자가 부드럽게 흐르도록.
  void _syncDisplayTimer() {
    final shouldRun = _timerRunning || _swRunning;
    if (shouldRun) {
      _displayLastTick = DateTime.now();
      _displayTimer ??= Timer.periodic(const Duration(milliseconds: 16), (_) {
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

  // ── "다음" 2초 카운트다운(취소 가능) ──────────────────────────
  void _startNextCountdown() {
    setState(() {
      _nextCounting = true;
      _nextPct = 0.0;
      _nextStart = DateTime.now();
    });
    _animNext();
  }

  void _cancelNextCountdown() {
    _nextFrameTimer?.cancel();
    setState(() {
      _nextCounting = false;
      _nextPct = 0.0;
      _nextStart = null;
    });
  }

  void _animNext() {
    if (!_nextCounting || _nextStart == null || !mounted) return;
    final elapsed = DateTime.now().difference(_nextStart!).inMilliseconds;
    final pct = (elapsed / _nextDelay.inMilliseconds).clamp(0.0, 1.0);
    setState(() => _nextPct = pct);
    if (pct >= 1.0) {
      _cancelNextCountdown();
      _sendAction('timer_next');
      return;
    }
    _nextFrameTimer = Timer(const Duration(milliseconds: 16), _animNext);
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kOverlayPosX, _winPos.dx);
      await prefs.setDouble(_kOverlayPosY, _winPos.dy);
    } catch (_) {}
    _dragging = false;
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _displayTimer?.cancel();
    _nextFrameTimer?.cancel();
    _blinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0E0E0F),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E0F),
          border: Border.all(color: const Color(0xFF2E2E32)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                  Text(
                    _timerLabel,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 13,
                      letterSpacing: 1.2,
                      color: _effectiveTimerColor.withValues(alpha: 0.75),
                    ),
                  ),
                Text(
                  _timerRemain,
                  style: GoogleFonts.bebasNeue(
                    fontSize: 26,
                    color: _effectiveTimerColor,
                    letterSpacing: 1,
                  ),
                ),
              ],
              if (_swActive)
                Text(
                  '⏲ $_swElapsed',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 17,
                    color: const Color(0xFF2EA84A),
                    letterSpacing: 1,
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

    Widget btn(IconData icon, Color color, VoidCallback onTap,
        {double fill = 0.0}) {
      Widget inner = Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xCC1A1A1C),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, color: color, size: 16),
      );
      // 카운트다운 진행률을 좌→우 fill 로 표시
      if (fill > 0) {
        inner = ClipOval(
          child: SizedBox(
            width: 34,
            height: 34,
            child: Stack(
              children: [
                inner,
                Positioned.fill(
                  child: FractionallySizedBox(
                    widthFactor: fill,
                    alignment: Alignment.centerLeft,
                    child: Container(color: color.withValues(alpha: 0.35)),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return GestureDetector(onTap: onTap, child: inner);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_timerActive) ...[
          btn(_timerRunning ? Icons.pause : Icons.play_arrow, timerColor,
              () => _sendAction('timer_toggle')),
          // ⏭ 탭 → 2초 카운트다운(좌→우 fill), 완료 시 다음 / 카운트 중 탭 시 취소
          btn(
            _nextCounting ? Icons.close : Icons.skip_next,
            _nextCounting
                ? const Color(0xFFFFC107)
                : timerColor.withValues(alpha: 0.75),
            _nextCounting ? _cancelNextCountdown : _startNextCountdown,
            fill: _nextCounting ? _nextPct : 0.0,
          ),
        ],
        if (_swActive || _swElapsedMs > 0)
          btn(_swRunning ? Icons.stop : Icons.play_arrow, swColor,
              () => _sendAction('sw_toggle')),
        btn(Icons.close, Colors.white54, () => _sendAction('overlay_hide')),
      ],
    );
  }
}
