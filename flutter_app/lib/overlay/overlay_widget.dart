import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../main.dart' show parseLocaleTag, OverlayApp;

class TimerOverlayWidget extends StatefulWidget {
  const TimerOverlayWidget({super.key});

  @override
  State<TimerOverlayWidget> createState() => _TimerOverlayWidgetState();
}

class _TimerOverlayWidgetState extends State<TimerOverlayWidget>
    with TickerProviderStateMixin {
  // 오버레이 엔진에서 직접 호출 가능한 채널 (moveOverlay는 메인앱 채널이라 사용 불가)
  static const _overlayCh = MethodChannel('x-slayer/overlay');

  // IPC 상태
  bool _timerActive = false;
  bool _timerDone = false;
  bool _timerRunning = false; // running vs paused 구분
  bool _swActive = false;
  bool _swRunning = false; // sw 실제 실행 여부 (active=버튼 표시, running=아이콘)
  String _timerLabel = '';
  String _timerRemain = '--:--';
  String _swElapsed = '';
  String _clockTime = '';
  Color _timerColor = const Color(0xFFE07A52);
  double _timerFrac = 0.0;
  bool _ending = false;
  int _segRemainMs = 0;
  int _swElapsedMs = 0;
  double? _swStartAngleRad;

  // 메인 앱이 shareData로 전달한 실제 화면 크기 (dp)
  int _screenWidthDp = 400;
  int _screenHeightDp = 800;

  // UI 상태
  bool _expanded = true;
  bool _wasDragging = false;
  Offset? _dragStartPos;

  // 크기 조절
  int? _customExpandedW; // null = 기본 42% 공식
  double? _pinchInitW; // 핀치 시작 시 기준 너비
  bool _resizeInFlight = false;

  // 컨트롤 버튼(36dp×3) + 여백 기준 최소 사용 가능 너비
  static const _minOverlayW = 160;
  // 핸들 탭으로 순환할 프리셋 (화면 너비 대비 비율)
  static const _sizePresets = [0.42, 0.58, 0.75];

  int get _effectiveExpandedW {
    final custom = _customExpandedW;
    if (custom != null) {
      return custom.clamp(_minOverlayW, (_screenWidthDp * 0.9).round());
    }
    return (_screenWidthDp * 0.42).round().clamp(_minOverlayW, _screenWidthDp);
  }

  int get _effectiveExpandedH => _effectiveExpandedW + 56;

  bool _nextCounting = false;
  double _nextPct = 0.0;
  DateTime? _nextStart;
  static const _nextDelay = Duration(seconds: 2);

  Timer? _clockTimer;
  Timer? _nextFrameTimer;
  Timer? _displayTimer;
  DateTime? _displayLastTick;
  DateTime _now = DateTime.now();

  late AnimationController _chaseCtrl;
  late AnimationController _blinkCtrl;

  @override
  void initState() {
    super.initState();
    _updateClock();
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateClock(),
    );

    _chaseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    FlutterOverlayWindow.overlayListener.listen((data) async {
      if (data == null) return;
      try {
        final map = jsonDecode(data as String) as Map<String, dynamic>;

        // 오버레이가 보낸 action이 릴레이돼 돌아온 경우 — 상태 초기화 방지
        if (map.containsKey('action')) return;

        // locale 동기화 — 메인 앱 언어 변경 즉시 반영
        final localeTag = map['localeTag'] as String?;
        if (localeTag != null) {
          OverlayApp.updateLocale(parseLocaleTag(localeTag));
        }

        // command 처리 — 메인 앱에서 resizeOverlay를 직접 못 하므로 위젯이 대신 실행
        final command = map['command'] as String?;
        if (command == 'hide') {
          await FlutterOverlayWindow.resizeOverlay(1, 1, true);
          return;
        }
        if (command == 'show') {
          final w = map['screenWidthDp'] as int? ?? _screenWidthDp;
          setState(() {
            _screenWidthDp = w;
            _expanded = true;
          });
          await FlutterOverlayWindow.resizeOverlay(
            _effectiveExpandedW,
            _effectiveExpandedH,
            true,
          );
          await _moveOverlay(0, 53);
          return;
        }

        final wasEnding = _ending;
        final newTimerActive = map['timerActive'] as bool? ?? false;
        final newTimerDone = map['timerDone'] as bool? ?? false;
        setState(() {
          _timerActive = newTimerActive || newTimerDone; // done 상태도 컨트롤 표시
          _timerDone = newTimerDone;
          _timerRunning = map['timerRunning'] as bool? ?? false;
          _timerLabel = map['timerLabel'] as String? ?? '';
          _timerRemain = map['timerRemain'] as String? ?? '--:--';
          _swActive = map['swActive'] as bool? ?? false;
          _swRunning = map['swRunning'] as bool? ?? false;
          _swElapsed = map['swElapsed'] as String? ?? '';
          final colorVal = map['timerColorValue'] as int?;
          if (colorVal != null) _timerColor = Color(colorVal);
          _timerFrac = (map['timerFrac'] as num?)?.toDouble() ?? 0.0;
          _ending = map['ending'] as bool? ?? false;
          _segRemainMs = map['segRemainMs'] as int? ?? 0;
          _swElapsedMs = map['swElapsedMs'] as int? ?? 0;
          _swStartAngleRad = (map['swStartAngleRad'] as num?)?.toDouble();
          _screenWidthDp = map['screenWidthDp'] as int? ?? _screenWidthDp;
          _screenHeightDp = map['screenHeightDp'] as int? ?? _screenHeightDp;
        });
        // 타이머가 비활성/완료되면 진행 중인 다음 카운트다운 취소
        if (!newTimerActive && !newTimerDone && _nextCounting) {
          _cancelNextCountdown();
        }
        if (_ending && !wasEnding) {
          _blinkCtrl.repeat(reverse: true);
        } else if (!_ending && wasEnding) {
          _blinkCtrl
            ..stop()
            ..value = 1.0;
        }
        _syncDisplayTimer();
      } catch (_) {}
    });
  }

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
    final elapsed = DateTime.now().difference(_nextStart!);
    final pct = (elapsed.inMilliseconds / _nextDelay.inMilliseconds).clamp(
      0.0,
      1.0,
    );
    setState(() => _nextPct = pct);
    if (pct >= 1.0) {
      _cancelNextCountdown();
      _sendAction('timer_next');
      return;
    }
    _nextFrameTimer = Timer(const Duration(milliseconds: 16), _animNext);
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _nextFrameTimer?.cancel();
    _displayTimer?.cancel();
    _chaseCtrl.dispose();
    _blinkCtrl.dispose();
    super.dispose();
  }

  String _fmtMs(int ms) {
    final total = (ms.clamp(0, ms) ~/ 1000);
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _syncDisplayTimer() {
    final shouldRun = _timerRunning || _swRunning;
    if (shouldRun) {
      _displayLastTick = DateTime.now();
      if (_displayTimer == null) {
        _displayTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
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
      }
    } else if (_displayTimer != null) {
      _displayTimer?.cancel();
      _displayTimer = null;
      _displayLastTick = null;
    }
  }

  void _updateClock() {
    if (!mounted) return;
    final now = DateTime.now();
    setState(() {
      _now = now;
      _clockTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  Color get _effectiveTimerColor =>
      _ending ? const Color(0xFFE05252) : _timerColor;

  Color _shadeColor(Color color, double amount) {
    return Color.fromARGB(
      (color.a * 255).round(),
      (color.r * 255 + 255 * amount).round().clamp(0, 255),
      (color.g * 255 + 255 * amount).round().clamp(0, 255),
      (color.b * 255 + 255 * amount).round().clamp(0, 255),
    );
  }

  Future<void> _moveOverlay(double x, double y) async {
    try {
      await _overlayCh.invokeMethod<bool>('updateOverlayPosition', {
        'x': x.round(),
        'y': y.round(),
      });
    } catch (_) {}
  }

  Future<void> _resetPosition() => _moveOverlay(0, 53);

  Future<void> _setOverlaySize(int w, int h) async {
    if (_resizeInFlight) return;
    _resizeInFlight = true;
    setState(() => _customExpandedW = w);
    try {
      await FlutterOverlayWindow.resizeOverlay(w, h, true);
    } finally {
      _resizeInFlight = false;
    }
  }

  void _onScaleStart(ScaleStartDetails d) {
    if (d.pointerCount >= 2) _pinchInitW = _effectiveExpandedW.toDouble();
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (d.pointerCount < 2 || _pinchInitW == null) return;
    final maxW = (_screenWidthDp * 0.9).round();
    final newW = (_pinchInitW! * d.scale)
        .clamp(_minOverlayW.toDouble(), maxW.toDouble())
        .round();
    _setOverlaySize(newW, newW + 56);
  }

  void _onScaleEnd(ScaleEndDetails _) => _pinchInitW = null;

  void _onPointerDown(PointerDownEvent e) {
    _wasDragging = false;
    _dragStartPos = e.position;
  }

  void _cycleOverlaySize() {
    final currentW = _effectiveExpandedW;
    final screenW = _screenWidthDp;
    // 현재 크기에 가장 가까운 프리셋 인덱스 찾기
    int curIdx = 0;
    double minDiff = double.infinity;
    for (int i = 0; i < _sizePresets.length; i++) {
      final diff = (currentW - screenW * _sizePresets[i]).abs();
      if (diff < minDiff) {
        minDiff = diff;
        curIdx = i;
      }
    }
    final nextIdx = (curIdx + 1) % _sizePresets.length;
    final newW = (screenW * _sizePresets[nextIdx]).round().clamp(
      _minOverlayW,
      (screenW * 0.9).round(),
    );
    _setOverlaySize(newW, newW + 56);
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_dragStartPos != null && !_wasDragging) {
      if ((e.position - _dragStartPos!).distance > 8.0) {
        _wasDragging = true;
      }
    }
  }

  Future<void> _toggleExpanded(BuildContext ctx) async {
    if (!_expanded) {
      setState(() => _expanded = true);
      await FlutterOverlayWindow.resizeOverlay(
        _effectiveExpandedW,
        _effectiveExpandedH,
        true,
      );
    } else {
      setState(() {
        _expanded = false;
      });
      await FlutterOverlayWindow.resizeOverlay(_screenWidthDp, 150, true);
      await _moveOverlay(0, 53);
    }
  }

  Future<void> _sendAction(String action) async {
    await FlutterOverlayWindow.shareData({'action': action});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 1×1dp 프리웜 상태에서 overflow 방지
        if (constraints.maxWidth < 60 || constraints.maxHeight < 60) {
          return const SizedBox.shrink();
        }
        return Material(
          color: Colors.transparent,
          child: _expanded
              ? _buildLargeView(context)
              : _buildSmallPill(context),
        );
      },
    );
  }

  // ─── 확장 클록뷰 ─────────────────────────────────────────────────────────

  Widget _buildLargeView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 시계 (탭 → 축소 / 더블탭 → 정위치 / 네이티브 드래그가 이동 담당)
        // Listener: 스크린 절대좌표로 드래그 감지 → 드래그 후 onTap 오발 억제
        Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          child: GestureDetector(
            onTap: () {
              if (!_wasDragging) _toggleExpanded(context);
            },
            onDoubleTap: _resetPosition,
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onScaleEnd: _onScaleEnd,
            behavior: HitTestBehavior.translucent,
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    painter: _OverlayClockPainter(
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
                    IgnorePointer(child: _buildClockCenterInfo()),
                  // 크기 순환 버튼 — enableDrag:true로 인해 드래그는 항상 윈도우 이동,
                  // 탭으로 프리셋(42%→58%→75%)을 순환하는 방식으로 대체
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: GestureDetector(
                      onTap: _cycleOverlaySize,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.open_in_full,
                          color: Colors.white.withValues(alpha: 0.45),
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 컨트롤 버튼 행
        _buildControlBar(context),
      ],
    );
  }

  Widget _buildControlBar(BuildContext context) {
    const btnSize = 36.0;
    final timerColor = _effectiveTimerColor;
    const swColor = Color(0xFF2EA84A);

    Widget btn(
      IconData icon,
      Color color,
      VoidCallback onTap, {
      double fill = 0.0,
    }) {
      Widget inner = Container(
        width: btnSize,
        height: btnSize,
        decoration: BoxDecoration(
          color: const Color(0xCC1A1A1C),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        ),
        child: Icon(icon, color: color, size: 16),
      );

      if (fill > 0) {
        inner = ClipOval(
          child: SizedBox(
            width: btnSize,
            height: btnSize,
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

    // spaceEvenly: 버튼 개수에 관계없이 오버레이 너비 안에서 균등 배치
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_timerActive) ...[
          btn(
            _timerDone
                ? Icons.replay
                : (_timerRunning ? Icons.pause : Icons.play_arrow),
            timerColor,
            () {
              if (!_timerDone) setState(() => _timerRunning = !_timerRunning);
              _syncDisplayTimer();
              _sendAction('timer_toggle');
            },
          ),
          // ⏭ → 탭 후 2초 카운트다운, 완료 시 실행 / 탭 시 취소 (done 상태엔 숨김)
          if (!_timerDone)
            btn(
              _nextCounting ? Icons.close : Icons.skip_next,
              _nextCounting
                  ? const Color(0xFFFFC107)
                  : timerColor.withValues(alpha: 0.7),
              _nextCounting ? _cancelNextCountdown : _startNextCountdown,
              fill: _nextCounting ? _nextPct : 0.0,
            ),
        ],
        if (_swActive || _swElapsedMs > 0)
          btn(_swRunning ? Icons.stop : Icons.play_arrow, swColor, () {
            setState(() => _swRunning = !_swRunning);
            _syncDisplayTimer();
            _sendAction('sw_toggle');
          }),
        btn(Icons.close, Colors.white54, () => _sendAction('overlay_hide')),
      ],
    );
  }

  // 시계 배경(흰 면판·링·침)과 겹치는 텍스트 시인성 향상 — 흰색 외곽선 stroke
  Widget _strokeText(
    String text,
    TextStyle fillStyle, {
    Color strokeColor = Colors.white,
    double strokeWidth = 2.0,
  }) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontFamily: fillStyle.fontFamily,
            fontSize: fillStyle.fontSize,
            fontWeight: fillStyle.fontWeight,
            fontFeatures: fillStyle.fontFeatures,
            letterSpacing: fillStyle.letterSpacing,
            height: fillStyle.height,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..strokeJoin = StrokeJoin.round
              ..color = strokeColor,
          ),
        ),
        Text(text, style: fillStyle),
      ],
    );
  }

  Widget _buildClockCenterInfo() {
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
                  _strokeText(
                    _timerLabel,
                    TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _effectiveTimerColor.withValues(alpha: 0.75),
                    ),
                    strokeWidth: 1.5,
                  ),
                _strokeText(
                  _timerRemain,
                  TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: _effectiveTimerColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  strokeWidth: 3.0,
                ),
              ],
              if (_swActive)
                _strokeText(
                  '⏲ $_swElapsed',
                  const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2EA84A),
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                  strokeWidth: 2.0,
                ),
            ],
          ),
        );
      },
    );
  }

  // ─── 축소 Pill ────────────────────────────────────────────────────────────

  Widget _buildSmallPill(BuildContext context) {
    final String borderMode;
    if (_timerActive) {
      borderMode = 'progress';
    } else if (_swActive) {
      borderMode = 'chase';
    } else {
      borderMode = 'idle';
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: () {
            if (!_wasDragging) _toggleExpanded(context);
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            child: AnimatedBuilder(
              animation: Listenable.merge([_chaseCtrl, _blinkCtrl]),
              builder: (context, child) {
                return CustomPaint(
                  foregroundPainter: _PillBorderPainter(
                    mode: borderMode,
                    frac: _timerFrac,
                    timerColor: _effectiveTimerColor,
                    chasePhase: _chaseCtrl.value,
                  ),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xEE1A1A1C),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF2E2E32), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildPillContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillContent() {
    const valueStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 24,
      height: 1,
      fontWeight: FontWeight.w700,
      fontFeatures: [FontFeature.tabularFigures()],
    );
    const labelStyle = TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 12,
      letterSpacing: 0.5,
      height: 1,
      fontWeight: FontWeight.w600,
    );

    if (!_timerActive && !_swActive) {
      return Text(
        _clockTime,
        style: valueStyle.copyWith(color: const Color(0xFF9E9A97)),
      );
    }

    Widget? timerSection;
    if (_timerActive) {
      final tColor = _effectiveTimerColor;
      final tLabelColor = _ending
          ? const Color(0xFFE05252)
          : _shadeColor(_timerColor, -0.18);
      final hasLabel = _timerLabel.isNotEmpty;

      Widget content = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: hasLabel
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: hasLabel ? 2 : 0, right: 5),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: tColor, shape: BoxShape.circle),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasLabel) ...[
                Text(
                  _timerLabel,
                  style: labelStyle.copyWith(color: tLabelColor),
                ),
                const SizedBox(height: 2),
              ],
              Text(_timerRemain, style: valueStyle.copyWith(color: tColor)),
            ],
          ),
        ],
      );

      if (_ending) {
        content = FadeTransition(
          opacity: Tween<double>(begin: 0.15, end: 1.0).animate(_blinkCtrl),
          child: content,
        );
      }
      timerSection = content;
    }

    Widget? swSection;
    if (_swActive) {
      swSection = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 5),
            decoration: const BoxDecoration(
              color: Color(0xFF2EA84A),
              shape: BoxShape.circle,
            ),
          ),
          Text(
            _swElapsed,
            style: valueStyle.copyWith(color: const Color(0xFF2EA84A)),
          ),
        ],
      );
    }

    if (timerSection != null && swSection != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [timerSection, const SizedBox(width: 12), swSection],
      );
    }
    return timerSection ?? swSection ?? const SizedBox.shrink();
  }
}

// ─── Pill 테두리 progress 링 ─────────────────────────────────────────────────

class _PillBorderPainter extends CustomPainter {
  final String mode;
  final double frac;
  final Color timerColor;
  final double chasePhase;

  const _PillBorderPainter({
    required this.mode,
    required this.frac,
    required this.timerColor,
    required this.chasePhase,
  });

  Path _buildPillPath(Size size) {
    const inset = 1.0;
    const x = inset, y = inset;
    final W = size.width - inset * 2;
    final H = size.height - inset * 2;
    final r = min(H / 2, 24.0);
    final cx = x + W / 2;

    final path = Path();
    path.moveTo(cx, y);
    path.lineTo(x + W - r, y);
    path.arcToPoint(
      Offset(x + W, y + r),
      radius: Radius.circular(r),
      clockwise: true,
    );
    if (H > 2 * r + 0.1) path.lineTo(x + W, y + H - r);
    path.arcToPoint(
      Offset(x + W - r, y + H),
      radius: Radius.circular(r),
      clockwise: true,
    );
    path.lineTo(x + r, y + H);
    path.arcToPoint(
      Offset(x, y + H - r),
      radius: Radius.circular(r),
      clockwise: true,
    );
    if (H > 2 * r + 0.1) path.lineTo(x, y + r);
    path.arcToPoint(
      Offset(x + r, y),
      radius: Radius.circular(r),
      clockwise: true,
    );
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (mode == 'idle') return;

    final path = _buildPillPath(size);
    final metricsList = path.computeMetrics().toList();
    if (metricsList.isEmpty) return;
    final pm = metricsList.first;
    final totalLen = pm.length;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    if (mode == 'progress') {
      final arcLen = totalLen * frac.clamp(0.0, 1.0);
      if (arcLen < 0.5) return;
      paint.color = timerColor;
      canvas.drawPath(pm.extractPath(0, arcLen), paint);
    } else if (mode == 'chase') {
      const chaseArcFrac = 0.26;
      final arcLen = totalLen * chaseArcFrac;
      final startLen = totalLen * chasePhase;
      final endLen = startLen + arcLen;

      paint.color = const Color(0xFF2EA84A);
      if (endLen <= totalLen) {
        canvas.drawPath(pm.extractPath(startLen, endLen), paint);
      } else {
        canvas.drawPath(pm.extractPath(startLen, totalLen), paint);
        canvas.drawPath(pm.extractPath(0, endLen - totalLen), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_PillBorderPainter old) =>
      old.mode != mode ||
      old.frac != frac ||
      old.timerColor != timerColor ||
      old.chasePhase != chasePhase;
}

// ─── 확장 클록 페인터 — 메인 앱 ClockPainter와 동일한 디자인 ──────────────────
class _OverlayClockPainter extends CustomPainter {
  final DateTime now;
  final bool timerActive;
  final int segRemainMs;
  final Color segColor;
  final bool swActive;
  final int swElapsedMs;
  final double? swStartAngleRad;

  const _OverlayClockPainter({
    required this.now,
    required this.timerActive,
    required this.segRemainMs,
    required this.segColor,
    required this.swActive,
    required this.swElapsedMs,
    required this.swStartAngleRad,
  });

  double _minuteHandAngle() {
    final m = now.minute;
    final s = now.second;
    final ms = now.millisecond;
    return ((m + (s + ms / 1000) / 60) / 60) * 2 * pi - pi / 2;
  }

  void _drawFace(Canvas canvas, double cx, double cy, double R) {
    canvas.drawCircle(Offset(cx, cy), R, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(cx, cy),
      R,
      Paint()
        ..color = const Color(0xFF111111)
        ..style = PaintingStyle.stroke
        ..strokeWidth = R * 0.044, // 7px at R=160
    );
    canvas.drawCircle(
      Offset(cx, cy),
      R - R * 0.038, // 6px offset at R=160
      Paint()
        ..color = const Color(0xFF555555)
        ..style = PaintingStyle.stroke
        ..strokeWidth = R * 0.009, // 1.5px at R=160
    );
  }

  void _drawTimerSpiral(Canvas canvas, double cx, double cy, double R) {
    if (!timerActive || segRemainMs <= 0) return;
    final remainMin = segRemainMs / 60000.0;
    final minAngle = _minuteHandAngle();
    final ringW = R * 0.100; // 16px at R=160
    final gap = R * 0.019; // 3px  at R=160
    final step = ringW + gap;
    final innermost = R * 0.088; // 14px at R=160
    final rOuter = R * 0.79;
    final fullLaps = remainMin ~/ 60;
    final partialMin = remainMin % 60;
    for (int ring = 0; ring < fullLaps; ring++) {
      final r = innermost + ring * step + ringW / 2;
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = segColor.withAlpha(0x77)
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringW
          ..strokeCap = StrokeCap.butt,
      );
    }
    if (partialMin > 0) {
      final sweep = (partialMin / 60) * 2 * pi;
      final innerR = innermost + fullLaps * step;
      final path = Path();
      path.arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: rOuter),
        minAngle,
        sweep,
        true,
      );
      path.arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: innerR),
        minAngle + sweep,
        -sweep,
        false,
      );
      path.close();
      canvas.drawPath(path, Paint()..color = segColor.withAlpha(0xCC));
      canvas.drawPath(
        path,
        Paint()
          ..color = segColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawStopwatchRings(Canvas canvas, double cx, double cy, double R) {
    if (!swActive || swElapsedMs <= 0) return;
    final elapsedMin = swElapsedMs / 60000.0;
    final ringW = R * 0.081; // 13px at R=160
    final gap = R * 0.013; // 2px  at R=160
    final step = ringW + gap;
    final outermost = R - R * 0.056; // R-9 at R=160
    final innerLimit = R * 0.225; // 36px at R=160
    final maxRings = ((outermost - innerLimit) / step).floor();
    final fullLaps = elapsedMin ~/ 60;
    final partialMin = elapsedMin % 60;
    final startAngle = swStartAngleRad ?? _minuteHandAngle();
    const swColor = Color(0xFF2EA84A);
    for (int ring = 0; ring < min(fullLaps, maxRings); ring++) {
      final r = outermost - ring * step - ringW / 2;
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = swColor.withAlpha(0x77)
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringW
          ..strokeCap = StrokeCap.butt,
      );
    }
    final curRing = min(fullLaps, maxRings - 1);
    if (curRing >= 0 && partialMin > 0) {
      final r = outermost - curRing * step - ringW / 2;
      final sweep = (partialMin / 60) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle,
        sweep,
        false,
        Paint()
          ..color = swColor.withAlpha(0xCC)
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringW
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawTicks(Canvas canvas, double cx, double cy, double R) {
    // 모든 오프셋·굵기를 R 비례값으로 — 메인앱 ClockPainter(R≈160) 기준 환산
    final rOuter = R - R * 0.044; // R-7 at R=160
    for (int i = 0; i < 60; i++) {
      final angle = (i / 60) * 2 * pi - pi / 2;
      final isQ = i % 15 == 0;
      final isM = i % 5 == 0;
      final r0 = isQ
          ? R -
                R *
                    0.138 // R-22 at R=160
          : isM
          ? R -
                R *
                    0.100 // R-16 at R=160
          : R - R * 0.056; // R-9  at R=160
      canvas.drawLine(
        Offset(cx + cos(angle) * r0, cy + sin(angle) * r0),
        Offset(cx + cos(angle) * rOuter, cy + sin(angle) * rOuter),
        Paint()
          ..color = isQ
              ? Colors.black
              : isM
              ? const Color(0xFF333333)
              : const Color(0xFFAAAAAA)
          ..strokeWidth = isQ
              ? R *
                    0.031 // 5px at R=160
              : isM
              ? R *
                    0.016 // 2.5px at R=160
              : R *
                    0.006 // 1px at R=160
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawNumbers(Canvas canvas, double cx, double cy, double R) {
    if (R < 10) return; // 1×1px 프리웜 상태에서 음수 fontSize 방지
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 1; i <= 12; i++) {
      final angle = (i / 12) * 2 * pi - pi / 2;
      tp.text = TextSpan(
        text: '$i',
        style: TextStyle(
          color: const Color(0xFF111111),
          fontSize: (R * 0.13).clamp(1.0, double.infinity),
          fontWeight: FontWeight.w900,
          fontFamily: 'Pretendard',
        ),
      );
      tp.layout();
      final numR = R * 0.781; // R-35 at R=160
      final dx = cx + cos(angle) * numR - tp.width / 2;
      final dy = cy + sin(angle) * numR - tp.height / 2;
      tp.paint(canvas, Offset(dx, dy));
    }
  }

  void _drawHand(
    Canvas canvas,
    double cx,
    double cy,
    double angle,
    double len,
    double width,
    Color color,
  ) {
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + cos(angle) * len, cy + sin(angle) * len),
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawHands(Canvas canvas, double cx, double cy, double R) {
    final h = now.hour % 12;
    final m = now.minute;
    final s = now.second;
    final ms = now.millisecond;
    final secA = ((s + ms / 1000) / 60) * 2 * pi - pi / 2;
    final minA = ((m + (s + ms / 1000) / 60) / 60) * 2 * pi - pi / 2;
    final hourA = ((h + m / 60) / 12) * 2 * pi - pi / 2;
    _drawHand(
      canvas,
      cx,
      cy,
      hourA,
      R * 0.48,
      R * 0.063,
      const Color(0xFF111111),
    ); // 10px at R=160
    _drawHand(
      canvas,
      cx,
      cy,
      minA,
      R * 0.66,
      R * 0.044,
      const Color(0xFF111111),
    ); // 7px at R=160
    _drawHand(
      canvas,
      cx,
      cy,
      secA,
      R * 0.79,
      R * 0.013,
      const Color(0xFFDD2222),
    ); // 2px at R=160
    _drawHand(
      canvas,
      cx,
      cy,
      secA + pi,
      R * 0.17,
      R * 0.013,
      const Color(0xFFDD2222),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      R * 0.063, // 10px at R=160
      Paint()..color = const Color(0xFFDD2222),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      R * 0.025,
      Paint()..color = Colors.white,
    ); // 4px at R=160
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final R = size.width / 2 - 4;
    _drawFace(canvas, cx, cy, R);
    _drawTimerSpiral(canvas, cx, cy, R);
    _drawStopwatchRings(canvas, cx, cy, R);
    _drawTicks(canvas, cx, cy, R);
    _drawNumbers(canvas, cx, cy, R);
    _drawHands(canvas, cx, cy, R);
  }

  @override
  bool shouldRepaint(_OverlayClockPainter old) =>
      old.now.second != now.second ||
      old.now.millisecond != now.millisecond ||
      old.timerActive != timerActive ||
      old.segRemainMs != segRemainMs ||
      old.segColor != segColor ||
      old.swActive != swActive ||
      old.swElapsedMs != swElapsedMs ||
      old.swStartAngleRad != swStartAngleRad;
}
