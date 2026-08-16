import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import '../services/high_contrast_service.dart';
import '../theme/app_theme.dart';
import 'pill_prefs.dart';

/// 데스크톱 물 위젯 pill — 오늘 잔 수/목표 진행 링 + 다음 알림 시각.
/// 링 탭 = 한 잔 기록(메인으로 액션 전달). 문자열은 메인이 l10n 으로 push.
const _pillSize = Size(210, 64);
const _waterBlue = Color(0xFF52B0E0);

Future<void> runDesktopWaterPill(Map<String, dynamic> args) async {
  await HighContrastService.instance.init();

  // 저장된 위치 우선, 없거나 화면 밖이면 우하단 기본.
  Offset? pos = await loadPillPos('water');
  if (pos != null && !await pillPosOnAnyDisplay(pos, _pillSize)) pos = null;
  if (pos == null) {
    try {
      final d = await screenRetriever.getPrimaryDisplay();
      final visPos = d.visiblePosition ?? Offset.zero;
      final visSize = d.visibleSize ?? d.size;
      pos = Offset(
        visPos.dx + visSize.width - _pillSize.width - 16,
        visPos.dy + visSize.height - _pillSize.height - 24,
      );
    } catch (_) {
      pos = const Offset(160, 240);
    }
  }
  final resolvedPos = pos;

  // 투명 레이어드 윈도우 금지(일부 GPU 합성 실패 — desktop_overlay.dart 참고).
  final opts = WindowOptions(
    size: _pillSize,
    minimumSize: _pillSize,
    maximumSize: _pillSize,
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
    await windowManager.setPosition(resolvedPos);
    await windowManager.show();
  });
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: DesktopWaterPill(
        mainWindowId: args['mainWindowId'] as String? ?? '0',
        initial: args,
        initialPos: resolvedPos,
      ),
    ),
  );
}

class DesktopWaterPill extends StatefulWidget {
  final String mainWindowId;
  final Map<String, dynamic> initial;
  final Offset initialPos;
  const DesktopWaterPill({
    super.key,
    required this.mainWindowId,
    required this.initial,
    required this.initialPos,
  });

  @override
  State<DesktopWaterPill> createState() => _DesktopWaterPillState();
}

class _DesktopWaterPillState extends State<DesktopWaterPill> {
  String _title = '';
  int _count = 0;
  int _goal = 8;
  String _nextHm = '—';

  Timer? _topmostTimer;
  bool _dragging = false;
  late Offset _winPos;

  @override
  void initState() {
    super.initState();
    _winPos = widget.initialPos;
    _apply(widget.initial);
    _topmostTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        await windowManager.setAlwaysOnTop(true);
      } catch (_) {}
    });
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
    _title = map['title'] as String? ?? _title;
    _count = (map['count'] as num?)?.toInt() ?? _count;
    _goal = (map['goal'] as num?)?.toInt() ?? _goal;
    _nextHm = map['nextHm'] as String? ?? _nextHm;
  }

  @override
  void dispose() {
    _topmostTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendAction(String action) async {
    try {
      await WindowController.fromWindowId(
        widget.mainWindowId,
      ).invokeMethod('action', 'water|$action');
    } catch (_) {}
  }

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
      unawaited(savePillPos('water', _winPos));
    } catch (_) {}
    _dragging = false;
  }

  @override
  Widget build(BuildContext context) {
    final frac = _goal <= 0 ? 0.0 : (_count / _goal).clamp(0.0, 1.0);
    final done = _goal > 0 && _count >= _goal;
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0F),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: _onDragStart,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          // 사각 테두리 — 창이 불투명 사각이라 둥근 모서리는 귀퉁이가 비어 보인다.
          decoration: BoxDecoration(
            border: Border.all(
              color: done ? _waterBlue : AppColors.border,
              width: done ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // 진행 링 + 탭 = 한 잔 기록.
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _sendAction('drank'),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(40, 40),
                          painter: _WaterRingPainter(frac: frac),
                        ),
                        const Icon(
                          Icons.local_drink_outlined,
                          size: 18,
                          color: _waterBlue,
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
                    if (_title.isNotEmpty)
                      Text(
                        _title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.muted, fontSize: 11),
                      ),
                    Text(
                      '$_count / $_goal  ·  $_nextHm',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: done ? _waterBlue : AppColors.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              // 닫기 — 메인이 위젯 설정을 끄고 창을 hide 한다.
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

class _WaterRingPainter extends CustomPainter {
  final double frac;
  const _WaterRingPainter({required this.frac});

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
          ..color = _waterBlue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_WaterRingPainter old) => old.frac != frac;
}
