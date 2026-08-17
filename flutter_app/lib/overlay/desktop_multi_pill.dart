import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import '../services/high_contrast_service.dart';
import '../services/platform_info.dart';
import 'pill_prefs.dart';
import '../theme/app_theme.dart';

/// 데스크톱 멀티 오버레이 pill — 카운트다운 1개용 소형 always-on-top 창.
///
/// Android 네이티브 pill(MultiOverlayService.kt)의 데스크톱 대응. 메인 프로세스가
/// 상태 전이 시에만 push 하고, pill 은 [deadlineMs] 기준으로 잔여 시간을 자체
/// 계산한다. 창은 파괴되지 않고 hide/show 로 재사용된다(풀 — 핸들 누수 회피).
const _pillSize = Size(210, 64);

Future<void> runDesktopMultiPill(Map<String, dynamic> args) async {
  // AppColors.muted/faint 가 고대비 토글 getter 라 서비스 초기화 필요.
  await HighContrastService.instance.init();

  final slot = (args['slot'] as num?)?.toInt() ?? 0;
  // 저장된 위치(이전 세션 드래그) 우선, 없거나 화면 밖이면 우측 캐스케이드.
  Offset? pos = await loadPillPos('$slot');
  if (pos != null && !await pillPosOnAnyDisplay(pos, _pillSize)) pos = null;
  if (pos == null) {
    try {
      final d = await screenRetriever.getPrimaryDisplay();
      final visPos = d.visiblePosition ?? Offset.zero;
      final visSize = d.visibleSize ?? d.size;
      pos = Offset(
        visPos.dx + visSize.width - _pillSize.width - 16,
        visPos.dy + visSize.height * 0.35 + slot * (_pillSize.height + 10),
      );
    } catch (_) {
      pos = Offset(120.0 + slot * 30, 160.0 + slot * 80);
    }
  }
  // 클로저 캡처를 위해 non-null 로컬로 굳힌다.
  final resolvedPos = pos;

  // Windows: 투명 레이어드 윈도우 금지(일부 GPU 합성 실패) → 불투명 사각.
  // macOS: OS 가 창 모서리를 둥글게 처리해 사각 테두리가 잘림 → 투명 창 + 둥근 pill.
  final opts = WindowOptions(
    size: _pillSize,
    minimumSize: _pillSize,
    maximumSize: _pillSize,
    backgroundColor: isMacOS
        ? const Color(0x00000000)
        : const Color(0xFF0E0E0F),
    // Windows 만 작업표시줄에서 숨김. macOS 는 skipTaskbar 가 앱 전역
    // NSApp.setActivationPolicy(.accessory) 라, pill 하나로 메인 앱이 Dock·
    // Command+Tab 에서 사라진다 → macOS 는 끄고 .regular 유지.
    skipTaskbar: !isMacOS,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
    alwaysOnTop: true,
  );
  await windowManager.waitUntilReadyToShow(opts, () async {
    await windowManager.setAsFrameless();
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setHasShadow(true);
    await windowManager.setPosition(resolvedPos);
    await windowManager.show();
    // focus() 하지 않는다 — 생성 순간 타이핑 중이던 키를 뺏지 않기 위해
    // (단일 오버레이와 동일한 원칙).
  });
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: DesktopMultiPill(
        mainWindowId: args['mainWindowId'] as String? ?? '0',
        initial: args,
        slot: slot,
        initialPos: resolvedPos,
      ),
    ),
  );
}

class DesktopMultiPill extends StatefulWidget {
  final String mainWindowId;
  final Map<String, dynamic> initial;
  final int slot;
  final Offset initialPos;
  const DesktopMultiPill({
    super.key,
    required this.mainWindowId,
    required this.initial,
    required this.slot,
    required this.initialPos,
  });

  @override
  State<DesktopMultiPill> createState() => _DesktopMultiPillState();
}

class _DesktopMultiPillState extends State<DesktopMultiPill> {
  String _timerId = '';
  String _name = '';
  Color _color = AppColors.timerOrange;
  int _totalMs = 0;
  int _remainMs = 0;
  bool _running = false;
  bool _done = false;
  String _doneText = '';
  int _deadlineMs = 0;

  Timer? _ticker;
  Timer? _topmostTimer;
  bool _dragging = false;

  /// 창 위치 — 서브윈도우는 getPosition 이 동작하지 않아 직접 추적(단일
  /// 오버레이와 동일). 드래그 종료 시 커서-그랩오프셋으로 갱신·저장한다.
  late Offset _winPos;

  @override
  void initState() {
    super.initState();
    _winPos = widget.initialPos;
    _apply(widget.initial);
    // 250ms 자체 틱 — 메인은 상태 전이 시에만 push 하므로 잔여 시간은 여기서 계산.
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted || !_running || _deadlineMs <= 0) return;
      final r = _deadlineMs - DateTime.now().millisecondsSinceEpoch;
      setState(() => _remainMs = r > 0 ? r : 0);
    });
    // always-on-top 주기적 재확보(단일 오버레이와 동일 패턴).
    _topmostTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        await windowManager.setAlwaysOnTop(true);
      } catch (_) {}
    });
    // 메인 → pill 상태 push 수신 (풀 재사용 시 새 타이머로 재배정도 이 경로).
    WindowController.fromCurrentEngine().then((controller) {
      controller.setWindowMethodHandler((call) async {
        if (call.method == 'update' && call.arguments is String) {
          try {
            final map =
                jsonDecode(call.arguments as String) as Map<String, dynamic>;
            if (mounted) setState(() => _apply(map));
          } catch (_) {}
        }
        return null;
      });
    });
  }

  void _apply(Map<String, dynamic> map) {
    _timerId = map['timerId'] as String? ?? _timerId;
    _name = map['name'] as String? ?? '';
    final colorVal = (map['colorValue'] as num?)?.toInt();
    if (colorVal != null) _color = Color(colorVal);
    _totalMs = (map['totalMs'] as num?)?.toInt() ?? 0;
    _remainMs = (map['remainMs'] as num?)?.toInt() ?? 0;
    _running = map['running'] as bool? ?? false;
    _done = map['done'] as bool? ?? false;
    _doneText = map['doneText'] as String? ?? '';
    _deadlineMs = (map['deadlineMs'] as num?)?.toInt() ?? 0;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _topmostTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendAction(String action) async {
    try {
      await WindowController.fromWindowId(
        widget.mainWindowId,
      ).invokeMethod('action', 'multi|$_timerId|$action');
    } catch (_) {}
  }

  // OS 이동 루프 드래그 — setPosition 피드백 떨림 없음(단일 오버레이와 동일).
  // startDragging 은 릴리즈까지 await 가 블록되므로, 종료 후 커서 스크린좌표에서
  // 그랩 오프셋을 빼 최종 위치를 계산하고 슬롯 파일에 저장한다.
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
      unawaited(savePillPos('${widget.slot}', _winPos));
    } catch (_) {}
    _dragging = false;
  }

  static String _fmt(int ms) {
    final total = (ms / 1000).ceil();
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final frac = _totalMs <= 0 ? 0.0 : (_remainMs / _totalMs).clamp(0.0, 1.0);
    // macOS: 투명 창 + 둥근 pill(채움+반경) — OS 둥근 모서리에 잘리지 않음.
    // Windows: 불투명 사각 + 사각 테두리(투명 레이어드 금지, 둥근 모서리 시 네
    // 귀퉁이가 검은 삼각형으로 비어져 보임).
    final radius = isMacOS ? BorderRadius.circular(16) : null;
    return Scaffold(
      backgroundColor: isMacOS
          ? const Color(0x00000000)
          : const Color(0xFF0E0E0F),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: _onDragStart,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isMacOS ? const Color(0xFF0E0E0F) : null,
            borderRadius: radius,
            border: Border.all(
              color: _done ? _color : AppColors.border,
              width: _done ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // 진행 링 + 재생/정지 토글.
              MouseRegion(
                cursor: _done ? MouseCursor.defer : SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _done ? null : () => _sendAction('toggle'),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(40, 40),
                          painter: _RingPainter(
                            color: _color,
                            frac: _done ? 1.0 : frac,
                          ),
                        ),
                        Icon(
                          _done
                              ? Icons.check
                              : (_running ? Icons.pause : Icons.play_arrow),
                          size: 18,
                          color: _done ? _color : AppColors.text,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_name.isNotEmpty)
                      Text(
                        _name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                    Text(
                      _done && _doneText.isNotEmpty
                          ? _doneText
                          : _fmt(_remainMs),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _done ? _color : AppColors.text,
                        fontSize: _done && _doneText.isNotEmpty ? 14 : 20,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              // 닫기 — 창은 hide 되어 풀로 돌아간다(메인이 처리).
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _sendAction('close'),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.close, size: 16, color: AppColors.faint),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final double frac;
  const _RingPainter({required this.color, required this.frac});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 3;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    if (frac > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -pi / 2,
        2 * pi * frac,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.frac != frac || old.color != color;
}
