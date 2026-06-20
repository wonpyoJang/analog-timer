import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'overlay_clock_painter.dart';

class TimerOverlayWidget extends StatefulWidget {
  const TimerOverlayWidget({super.key});

  @override
  State<TimerOverlayWidget> createState() => _TimerOverlayWidgetState();
}

class _TimerOverlayWidgetState extends State<TimerOverlayWidget>
    with TickerProviderStateMixin {
  // IPC 상태
  bool _timerActive = false;
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

        // command 처리 — 메인 앱에서 resizeOverlay를 직접 못 하므로 위젯이 대신 실행
        final command = map['command'] as String?;
        if (command == 'hide') {
          await FlutterOverlayWindow.resizeOverlay(1, 1, false);
          return;
        }
        if (command == 'show') {
          final w = map['screenWidthDp'] as int? ?? _screenWidthDp;
          final expandedW = (w * 0.42).round().clamp(150, w);
          final expandedH = expandedW + 56;
          setState(() {
            _screenWidthDp = w;
            _expanded = true;
          });
          await FlutterOverlayWindow.resizeOverlay(expandedW, expandedH, true);
          await FlutterOverlayWindow.moveOverlay(const OverlayPosition(0, 53));
          return;
        }

        final wasEnding = _ending;
        setState(() {
          _timerActive = map['timerActive'] as bool? ?? false;
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

  Future<void> _toggleExpanded(BuildContext ctx) async {
    final expandedW = (_screenWidthDp * 0.42).round().clamp(
      150,
      _screenWidthDp,
    );
    // 시계(정사각형) + 컨트롤 버튼 행(48dp) + 간격(8dp)
    final expandedH = expandedW + 56;

    if (!_expanded) {
      setState(() => _expanded = true);
      await FlutterOverlayWindow.resizeOverlay(expandedW, expandedH, true);
    } else {
      setState(() => _expanded = false);
      await FlutterOverlayWindow.resizeOverlay(_screenWidthDp, 150, true);
      await FlutterOverlayWindow.moveOverlay(const OverlayPosition(0, 53));
    }
  }

  Future<void> _sendAction(String action) async {
    await FlutterOverlayWindow.shareData({'action': action});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _expanded ? _buildLargeView(context) : _buildSmallPill(context),
    );
  }

  // ─── 확장 클록뷰 ─────────────────────────────────────────────────────────

  Widget _buildLargeView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 시계 (탭 → 축소)
        GestureDetector(
          onTap: () => _toggleExpanded(context),
          behavior: HitTestBehavior.translucent,
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
                  IgnorePointer(child: _buildClockCenterInfo()),
              ],
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
          btn(_timerRunning ? Icons.pause : Icons.play_arrow, timerColor, () {
            setState(() => _timerRunning = !_timerRunning);
            _syncDisplayTimer();
            _sendAction('timer_toggle');
          }),
          // ⏭ → 탭 후 5초 카운트다운 (좌→우 fill), 완료 시 실행 / 탭 시 취소
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
                  Text(
                    _timerLabel,
                    style: TextStyle(fontFamily: 'Pretendard',
                      fontSize: 15,
                      letterSpacing: 1.5,
                      color: _effectiveTimerColor.withValues(alpha: 0.75),
                    ),
                  ),
                Text(
                  _timerRemain,
                  style: TextStyle(fontFamily: 'Pretendard',
                    fontSize: 30,
                    color: _effectiveTimerColor,
                    letterSpacing: 1,
                  ),
                ),
              ],
              if (_swActive)
                Text(
                  '⏲ $_swElapsed',
                  style: TextStyle(fontFamily: 'Pretendard',
                    fontSize: 20,
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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _toggleExpanded(context),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
    );
  }

  Widget _buildPillContent() {
    final valueStyle = TextStyle(fontFamily: 'Pretendard',
      fontSize: 24,
      letterSpacing: 1,
      height: 1,
      fontWeight: FontWeight.w400,
    );
    final labelStyle = const TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 12,
      letterSpacing: 0.5,
      height: 1,
      fontWeight: FontWeight.w500,
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
