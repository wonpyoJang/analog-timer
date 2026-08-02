import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../l10n/app_localizations.dart';
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
  String _clockTime = '';
  Color _timerColor = const Color(0xFFE07A52);
  double _timerFrac = 0.0;
  bool _ending = false;
  double? _swStartAngleRad;

  // 배터리 경고
  bool _batteryLow = false;
  int _batteryLevel = -1;

  // IPC 앵커 — IPC 수신 시각 + 그 시점의 값. 이후 경과 시간으로 현재값 계산
  int _ipcSegRemainMs = 0;
  int _ipcSwElapsedMs = 0;
  DateTime? _ipcTimerReceivedAt;
  DateTime? _ipcSwReceivedAt;

  int get _segRemainMs {
    if (_ipcTimerReceivedAt == null) return _ipcSegRemainMs;
    if (!_timerRunning) return _ipcSegRemainMs;
    final elapsed = DateTime.now()
        .difference(_ipcTimerReceivedAt!)
        .inMilliseconds;
    return max(0, _ipcSegRemainMs - elapsed);
  }

  int get _swElapsedMs {
    if (_ipcSwReceivedAt == null) return _ipcSwElapsedMs;
    if (!_swRunning) return _ipcSwElapsedMs;
    final elapsed = DateTime.now().difference(_ipcSwReceivedAt!).inMilliseconds;
    return _ipcSwElapsedMs + elapsed;
  }

  String get _timerRemain => _fmtMs(_segRemainMs);
  String get _swElapsed => _fmtMs(_swElapsedMs);

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

  // 위치 그리드 (드래그 불가 기기 대응) — 현재 선택된 앵커 (row*3+col)
  static const _topY = 53.0;
  int _gridIdx = 1;

  // 편집 모드 — 길게 누르면 크기·위치 버튼 표시, 5초 무조작 시 자동 숨김
  bool _editMode = false;
  Timer? _editModeTimer;

  // 길게 누르기 온보딩 힌트 — show 커맨드의 hintLongPress로 활성화
  bool _showHint = false;
  Timer? _hintTimer;

  // 축소 pill 창 맞춤 — 데드존 최소화용 측정·리사이즈 상태
  final GlobalKey _pillMeasureKey = GlobalKey();
  Size? _lastPillWinSize;
  bool _pillFitScheduled = false;

  void _schedulePillFit() {
    if (_pillFitScheduled) return;
    _pillFitScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pillFitScheduled = false;
      _fitWindowToPill();
    });
  }

  Future<void> _fitWindowToPill() async {
    if (_expanded || !mounted || _resizeInFlight) return;
    final box =
        _pillMeasureKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    // 그림자(blur 12, offset y4)까지 담을 여백 — 64 미만은 프리웜 가드에 걸림
    final w = (box.size.width.ceil() + 16).clamp(64, _screenWidthDp);
    final h = (box.size.height.ceil() + 20).clamp(64, 200);
    final next = Size(w.toDouble(), h.toDouble());
    final last = _lastPillWinSize;
    if (last != null &&
        (next.width - last.width).abs() < 2 &&
        (next.height - last.height).abs() < 2) {
      return;
    }
    _lastPillWinSize = next;
    await FlutterOverlayWindow.resizeOverlay(w, h, true);
  }

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

  late AnimationController _chaseCtrl;
  late AnimationController _blinkCtrl;
  late AnimationController _batteryBlinkCtrl;

  @override
  void initState() {
    super.initState();
    _updateClock();
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateClock(),
    );
    _chaseCtrl =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 2000),
          )
          ..repeat()
          // vsync 드리븐 리스너 — Dart Timer.periodic은 오버레이 isolate 스로틀링 시 동작 안 함.
          // Choreographer 기반 AnimationController는 스로틀링 무관하게 매 프레임마다 실행됨.
          ..addListener(() {
            if (mounted) setState(() {});
          });

    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _batteryBlinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    FlutterOverlayWindow.overlayListener.listen((data) async {
      if (data == null || data is! String || !mounted) return;
      try {
        final map = jsonDecode(data) as Map<String, dynamic>;

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
          // 편집 캔버스가 떠 있으면 정리 — 풀스크린 창이 1×1로 줄며 종료
          _editModeTimer?.cancel();
          _stopNudgeRepeat();
          _lastPillWinSize = null;
          if (_editMode) setState(() => _editMode = false);
          await FlutterOverlayWindow.resizeOverlay(1, 1, true);
          return;
        }
        if (command == 'show') {
          final w = map['screenWidthDp'] as int? ?? _screenWidthDp;
          final hint = map['hintLongPress'] as bool? ?? false;
          _editModeTimer?.cancel();
          _stopNudgeRepeat();
          setState(() {
            _screenWidthDp = w;
            _expanded = true;
            _editMode = false;
            _showHint = hint;
          });
          if (hint) {
            _hintTimer?.cancel();
            _hintTimer = Timer(const Duration(seconds: 8), () {
              if (mounted) setState(() => _showHint = false);
            });
          }
          _lastPillWinSize = null;
          await FlutterOverlayWindow.resizeOverlay(
            _effectiveExpandedW,
            _effectiveExpandedH,
            true,
          );
          await _moveOverlay(0, 53);
          return;
        }

        final wasEnding = _ending;
        final wasBatteryLow = _batteryLow;
        final newTimerActive = map['timerActive'] as bool? ?? false;
        final newTimerDone = map['timerDone'] as bool? ?? false;
        final ipcNow = DateTime.now();
        setState(() {
          _timerActive = newTimerActive || newTimerDone; // done 상태도 컨트롤 표시
          _timerDone = newTimerDone;
          _timerRunning = map['timerRunning'] as bool? ?? false;
          _timerLabel = map['timerLabel'] as String? ?? '';
          _swActive = map['swActive'] as bool? ?? false;
          _swRunning = map['swRunning'] as bool? ?? false;
          final colorVal = map['timerColorValue'] as int?;
          if (colorVal != null) _timerColor = Color(colorVal);
          _timerFrac = (map['timerFrac'] as num?)?.toDouble() ?? 0.0;
          _ending = map['ending'] as bool? ?? false;
          _ipcSegRemainMs = map['segRemainMs'] as int? ?? 0;
          _ipcSwElapsedMs = map['swElapsedMs'] as int? ?? 0;
          _ipcTimerReceivedAt = ipcNow;
          _ipcSwReceivedAt = ipcNow;
          _swStartAngleRad = (map['swStartAngleRad'] as num?)?.toDouble();
          _screenWidthDp = map['screenWidthDp'] as int? ?? _screenWidthDp;
          _screenHeightDp = map['screenHeightDp'] as int? ?? _screenHeightDp;
          _batteryLow = map['batteryLow'] as bool? ?? false;
          _batteryLevel = map['batteryLevel'] as int? ?? -1;
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
        if (_batteryLow && !wasBatteryLow) {
          _batteryBlinkCtrl.repeat(reverse: true);
        } else if (!_batteryLow && wasBatteryLow) {
          _batteryBlinkCtrl
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
    _editModeTimer?.cancel();
    _hintTimer?.cancel();
    _dpadRepeat?.cancel();
    _chaseCtrl.dispose();
    _blinkCtrl.dispose();
    _batteryBlinkCtrl.dispose();
    super.dispose();
  }

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

  // displayTimer는 initState에서 시작해 항상 실행 — 호출 불필요 (호환성 유지)
  void _syncDisplayTimer() {}

  void _updateClock() {
    if (!mounted) return;
    final now = DateTime.now();
    setState(() {
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

  Future<Offset> _getOverlayPosition() async {
    try {
      final res = await _overlayCh.invokeMethod<Map>('getOverlayPosition');
      return Offset(
        (res?['x'] as num?)?.toDouble() ?? 0,
        (res?['y'] as num?)?.toDouble() ?? 0,
      );
    } catch (_) {
      return Offset.zero;
    }
  }

  // 3×3 위치 그리드 — 화면 9앵커 좌표 (x: 좌/중/우, y: 상/중/하)
  ({List<double> xs, List<double> ys}) _gridAnchors() {
    final winH = _effectiveExpandedH;
    final maxX = ((_screenWidthDp - _effectiveExpandedW) / 2).clamp(
      0.0,
      5000.0,
    );
    final midY = ((_screenHeightDp - winH) / 2).clamp(_topY, 5000.0);
    // 하단은 네비게이션 바·제스처 영역을 피해 90dp 여유
    final botY = (_screenHeightDp - winH - 90).toDouble().clamp(_topY, 5000.0);
    return (xs: [-maxX, 0.0, maxX], ys: [_topY, midY, botY]);
  }

  int _nearestAnchorIdx(Offset pos) {
    final a = _gridAnchors();
    int nearest(List<double> ts, double v) {
      var bestIdx = 0;
      var bestDist = double.infinity;
      for (var i = 0; i < ts.length; i++) {
        final d = (ts[i] - v).abs();
        if (d < bestDist) {
          bestDist = d;
          bestIdx = i;
        }
      }
      return bestIdx;
    }

    return nearest(a.ys, pos.dy) * 3 + nearest(a.xs, pos.dx);
  }

  // 편집 캔버스 — 창을 풀스크린으로 넓히고 시계를 창 내 좌표(_editPos)로
  // 이동시킨다. 컨트롤은 화면에 고정되고, 이동은 setState만이라 부드럽다.
  Offset _editPos = Offset.zero; // 시계 사각형 좌상단 (dp, 화면 좌표)

  double get _editCenterOff => (_screenWidthDp - _effectiveExpandedW) / 2;

  Offset _editPosToParams() =>
      Offset(_editPos.dx - _editCenterOff, _editPos.dy);

  // D-pad 미세 이동 — 탭 8dp, 홀드 시 50ms마다 4dp 연속 이동
  static const _nudgeTapStep = 8.0;
  static const _nudgeHoldStep = 4.0;
  Timer? _dpadRepeat;

  void _nudgeBy(double dx, double dy) {
    final maxLeft = (_screenWidthDp - _effectiveExpandedW).toDouble();
    final maxTop = (_screenHeightDp - _effectiveExpandedH - 24).toDouble();
    setState(() {
      _editPos = Offset(
        (_editPos.dx + dx).clamp(0.0, maxLeft),
        (_editPos.dy + dy).clamp(0.0, maxTop),
      );
      _gridIdx = _nearestAnchorIdx(_editPosToParams());
    });
    _restartEditModeTimer();
  }

  void _startNudgeRepeat(double ux, double uy) {
    _dpadRepeat?.cancel();
    _dpadRepeat = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _nudgeBy(ux * _nudgeHoldStep, uy * _nudgeHoldStep);
    });
  }

  void _stopNudgeRepeat() {
    _dpadRepeat?.cancel();
    _dpadRepeat = null;
  }

  Future<void> _resetPosition() {
    _gridIdx = 1; // 상단 중앙 앵커
    return _moveOverlay(0, _topY);
  }

  Future<void> _setOverlaySize(int w, int h) async {
    if (_resizeInFlight) return;
    setState(() => _customExpandedW = w);
    // 편집 캔버스는 풀스크린 유지 — 실제 창 크기는 _finishEdit에서 반영
    if (_editMode) return;
    _resizeInFlight = true;
    _lastPillWinSize = null;
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

  Future<void> _enterEditMode() async {
    if (_editMode) return;
    HapticFeedback.mediumImpact();
    _hintTimer?.cancel();
    final pos = await _getOverlayPosition();
    if (!mounted) return;
    setState(() {
      _editMode = true;
      _showHint = false;
      _editPos = Offset(_editCenterOff + pos.dx, pos.dy);
      _gridIdx = _nearestAnchorIdx(pos);
    });
    _restartEditModeTimer();
    // 온보딩 학습 완료 — 메인 앱이 힌트 카운트를 영구 종료 처리
    _sendAction('hint_learned');
    // 창을 풀스크린으로 — 컨트롤을 화면에 고정, 시계는 창 내 좌표로 이동.
    // enableDrag:false로 편집 중 네이티브 창 드래그 잠금
    await _moveOverlay(0, 0);
    await FlutterOverlayWindow.resizeOverlay(
      _screenWidthDp,
      _screenHeightDp,
      false,
    );
  }

  /// 편집 종료 — 창을 시계 크기로 되돌리고 편집 좌표를 실제 창 위치로 반영
  Future<void> _finishEdit() async {
    _editModeTimer?.cancel();
    _stopNudgeRepeat();
    if (!_editMode) return;
    final p = _editPosToParams();
    setState(() => _editMode = false);
    await FlutterOverlayWindow.resizeOverlay(
      _effectiveExpandedW,
      _effectiveExpandedH,
      true,
    );
    await _moveOverlay(p.dx, p.dy);
  }

  void _restartEditModeTimer() {
    _editModeTimer?.cancel();
    _editModeTimer = Timer(const Duration(seconds: 8), () {
      _finishEdit();
    });
  }

  Future<void> _toggleExpanded(BuildContext ctx) async {
    if (!_expanded) {
      _lastPillWinSize = null;
      setState(() => _expanded = true);
      await FlutterOverlayWindow.resizeOverlay(
        _effectiveExpandedW,
        _effectiveExpandedH,
        true,
      );
    } else {
      // 창 축소는 post-frame의 _fitWindowToPill이 pill 실측 크기로 수행
      setState(() {
        _expanded = false;
      });
      await _resetPosition();
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
          child: _editMode
              ? _buildEditCanvas()
              : _expanded
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
            onLongPress: _enterEditMode,
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
                  // 길게 누르기 온보딩 힌트 — 신규 사용자에게 최대 3회 노출
                  if (_showHint)
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 36,
                      child: IgnorePointer(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xE61A1A1C),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.touch_app,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    ).overlayLongPressHint,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

  // ─── 편집 캔버스 (풀스크린) ──────────────────────────────────────────────
  // 창이 화면 전체를 덮어 컨트롤이 고정되고, 시계는 _editPos로만 움직인다.

  Widget _buildEditCanvas() {
    final w = _effectiveExpandedW.toDouble();
    final a = _gridAnchors();
    const accent = Color(0xFFE07A52);
    return Stack(
      children: [
        // 스크림 — 빈 곳 탭 = 편집 완료
        Positioned.fill(
          child: GestureDetector(
            onTap: _finishEdit,
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),
        ),
        // 9앵커 점 — 탭 한 번으로 해당 위치로 이동
        for (var row = 0; row < 3; row++)
          for (var col = 0; col < 3; col++)
            Positioned(
              left: _editCenterOff + a.xs[col] + w / 2 - 22,
              top: a.ys[row] + w / 2 - 22,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _editPos = Offset(_editCenterOff + a.xs[col], a.ys[row]);
                    _gridIdx = row * 3 + col;
                  });
                  _restartEditModeTimer();
                },
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Container(
                      width: _gridIdx == row * 3 + col ? 18 : 12,
                      height: _gridIdx == row * 3 + col ? 18 : 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _gridIdx == row * 3 + col
                            ? accent
                            : Colors.white70,
                        border: Border.all(color: Colors.black45, width: 1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        // 시계 미리보기 — 창이 고정이라 직접 드래그도 좌표 피드백 없이 부드러움
        Positioned(
          left: _editPos.dx,
          top: _editPos.dy,
          width: w,
          height: w,
          child: GestureDetector(
            onPanUpdate: (d) => _nudgeBy(d.delta.dx, d.delta.dy),
            behavior: HitTestBehavior.opaque,
            child: CustomPaint(
              painter: _OverlayClockPainter(
                timerActive: _timerActive,
                segRemainMs: _segRemainMs,
                segColor: _effectiveTimerColor,
                swActive: _swActive,
                swElapsedMs: _swElapsedMs,
                swStartAngleRad: _swStartAngleRad,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        // 하단 고정 컨트롤 — D-pad(미세 이동) + 크기 + 완료
        Positioned(
          left: 0,
          right: 0,
          bottom: 48,
          child: Center(child: _buildEditBar()),
        ),
      ],
    );
  }

  Widget _buildEditBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xE61A1A1C),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF3A3A3E), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 미세 조정 D-pad — 앵커 사이 위치가 필요할 때
          _dpadChip(Icons.keyboard_arrow_left, -1, 0),
          _dpadChip(Icons.keyboard_arrow_up, 0, -1),
          _dpadChip(Icons.keyboard_arrow_down, 0, 1),
          _dpadChip(Icons.keyboard_arrow_right, 1, 0),
          const SizedBox(width: 6),
          _cornerChipButton(Icons.open_in_full, () {
            _cycleOverlaySize();
            _restartEditModeTimer();
          }),
          const SizedBox(width: 6),
          _cornerChipButton(Icons.check, _finishEdit),
        ],
      ),
    );
  }

  /// D-pad 방향 칩 — 탭 1회 니지, 길게 누르면 연속 이동
  Widget _dpadChip(IconData icon, double ux, double uy) {
    return GestureDetector(
      onTap: () => _nudgeBy(ux * _nudgeTapStep, uy * _nudgeTapStep),
      onLongPressStart: (_) => _startNudgeRepeat(ux, uy),
      onLongPressEnd: (_) => _stopNudgeRepeat(),
      onLongPressCancel: _stopNudgeRepeat,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xCC1A1A1C),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF4A4A4E), width: 1),
          ),
          child: Icon(icon, color: Colors.white70, size: 16),
        ),
      ),
    );
  }

  // 흰 시계판·밝은 배경 위에서도 보이도록 어두운 원형 칩 배경 (X 버튼과 동일 톤)
  Widget _cornerChipButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xCC1A1A1C),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF4A4A4E), width: 1),
          ),
          child: Icon(icon, color: Colors.white70, size: 14),
        ),
      ),
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
              if (!_timerDone) {
                final now = DateTime.now();
                setState(() {
                  _ipcSegRemainMs = _segRemainMs;
                  _timerRunning = !_timerRunning;
                  _ipcTimerReceivedAt = now;
                });
              }
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
            final now = DateTime.now();
            setState(() {
              _ipcSwElapsedMs = _swElapsedMs;
              _swRunning = !_swRunning;
              _ipcSwReceivedAt = now;
            });
            _syncDisplayTimer();
            _sendAction('sw_toggle');
          }),
        btn(Icons.close, Colors.white54, () => _sendAction('overlay_hide')),
      ],
    );
  }

  static const _kTextHalo = [
    Shadow(offset: Offset(-1.5, 0), blurRadius: 3, color: Colors.white),
    Shadow(offset: Offset(1.5, 0), blurRadius: 3, color: Colors.white),
    Shadow(offset: Offset(0, -1.5), blurRadius: 3, color: Colors.white),
    Shadow(offset: Offset(0, 1.5), blurRadius: 3, color: Colors.white),
  ];

  Widget _buildClockCenterInfo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_blinkCtrl, _batteryBlinkCtrl]),
      builder: (context, _) {
        final opacity = _ending ? _blinkCtrl.value : 1.0;
        return Opacity(
          opacity: opacity.clamp(0.3, 1.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_batteryLow)
                FadeTransition(
                  opacity: Tween<double>(
                    begin: 0.25,
                    end: 1.0,
                  ).animate(_batteryBlinkCtrl),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _BatteryBadge(level: _batteryLevel),
                  ),
                ),
              if (_timerActive) ...[
                if (_timerLabel.isNotEmpty)
                  Text(
                    _timerLabel,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _effectiveTimerColor.withValues(alpha: 0.75),
                      shadows: _kTextHalo,
                    ),
                  ),
                Text(
                  _timerRemain,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: _effectiveTimerColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    shadows: _kTextHalo,
                  ),
                ),
              ],
              if (_swActive)
                Text(
                  '⏲ $_swElapsed',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2EA84A),
                    fontFeatures: [FontFeature.tabularFigures()],
                    shadows: _kTextHalo,
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

    // 매 빌드 후 pill 자연 크기에 창을 맞춤 — 투명 영역이 하부 앱
    // 터치를 삼키는 데드존 최소화
    _schedulePillFit();

    return Stack(
      children: [
        // 무제약 측정용 복제본 — 창 크기와 무관한 자연 크기를 얻어
        // FittedBox 축소로 인한 재측정 피드백 루프를 차단
        Offstage(
          child: UnconstrainedBox(
            alignment: Alignment.topLeft,
            child: KeyedSubtree(
              key: _pillMeasureKey,
              child: _pillVisual(borderMode),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Listener(
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: () {
                if (!_wasDragging) _toggleExpanded(context);
              },
              child: _pillVisual(borderMode),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pillVisual(String borderMode) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 44,
        minWidth: 44,
        maxWidth: _effectiveExpandedW.toDouble(),
      ),
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
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: _buildPillContent(),
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

    final content = (timerSection != null && swSection != null)
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [timerSection, const SizedBox(width: 12), swSection],
          )
        : (timerSection ?? swSection ?? const SizedBox.shrink());

    if (!_batteryLow) return content;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: Tween<double>(
            begin: 0.25,
            end: 1.0,
          ).animate(_batteryBlinkCtrl),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _BatteryBadge(level: _batteryLevel),
          ),
        ),
        content,
      ],
    );
  }
}

class _BatteryBadge extends StatelessWidget {
  final int level;
  const _BatteryBadge({required this.level});

  static const _amber = Color(0xFFB45309);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: _amber.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _amber.withValues(alpha: 0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.battery_alert, size: 12, color: _amber),
          if (level >= 0) ...[
            const SizedBox(width: 2),
            Text(
              '$level%',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _amber,
                height: 1,
              ),
            ),
          ],
        ],
      ),
    );
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
  final bool timerActive;
  final int segRemainMs;
  final Color segColor;
  final bool swActive;
  final int swElapsedMs;
  final double? swStartAngleRad;

  const _OverlayClockPainter({
    required this.timerActive,
    required this.segRemainMs,
    required this.segColor,
    required this.swActive,
    required this.swElapsedMs,
    required this.swStartAngleRad,
  });

  double _minuteHandAngle(DateTime now) {
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

  void _drawTimerSpiral(
    Canvas canvas,
    double cx,
    double cy,
    double R,
    DateTime now,
  ) {
    if (!timerActive || segRemainMs <= 0) return;
    final remainMin = segRemainMs / 60000.0;
    final minAngle = _minuteHandAngle(now);
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

  void _drawStopwatchRings(
    Canvas canvas,
    double cx,
    double cy,
    double R,
    DateTime now,
  ) {
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
    final startAngle = swStartAngleRad ?? _minuteHandAngle(now);
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

  void _drawHands(Canvas canvas, double cx, double cy, double R, DateTime now) {
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
    // _clockTimer 미작동 시에도 항상 실시간 시각 사용
    final now = DateTime.now();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final R = size.width / 2 - 4;
    _drawFace(canvas, cx, cy, R);
    _drawTimerSpiral(canvas, cx, cy, R, now);
    _drawStopwatchRings(canvas, cx, cy, R, now);
    _drawTicks(canvas, cx, cy, R);
    _drawNumbers(canvas, cx, cy, R);
    _drawHands(canvas, cx, cy, R, now);
  }

  @override
  bool shouldRepaint(_OverlayClockPainter old) => true;
}
