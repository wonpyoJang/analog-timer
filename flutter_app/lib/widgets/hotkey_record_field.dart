import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../services/hotkey_service.dart';
import '../theme/app_theme.dart';
import 'key_caps.dart';

/// 자체 핫키 녹화 필드 — 패키지 HotKeyRecorder 를 쓰지 않는 이유:
/// 1) 표기가 맥 기호(⌃⇧⌥)라 Windows 사용자에게 오독을 유발
/// 2) 내부 로직이 블랙박스라 "조합이 안 잡힘" 류 문제를 진단·수정할 수 없음
///
/// 시안 스펙(핫키 설정 UI): 미리보기 박스까지 이 위젯이 그린다.
/// - 대기: dashed 테두리 + 깜빡이는 커서("입력을 듣고 있음")
/// - 수식키 진행: [Ctrl][Shift][…] 키캡 진행형
/// - 확정: solid 테두리 + 키캡, [error] true 면 danger 테두리
class HotkeyRecordField extends StatefulWidget {
  final HotKey? initial;
  final ValueChanged<HotKey> onRecorded;

  /// 확정된 조합이 유효하지 않을 때(수식키 부재/중복) 박스 테두리를 danger 로.
  final bool error;

  /// 어떤 키든 눌리기 시작하면 호출(수식키 홀드 포함) — 다이얼로그의
  /// 초심자 힌트를 숨기는 트리거(시안: 경험자에겐 방해 없음).
  final VoidCallback? onActivity;

  const HotkeyRecordField({
    super.key,
    this.initial,
    required this.onRecorded,
    this.error = false,
    this.onActivity,
  });

  @override
  State<HotkeyRecordField> createState() => _HotkeyRecordFieldState();
}

class _HotkeyRecordFieldState extends State<HotkeyRecordField> {
  HotKey? _recorded;
  List<HotKeyModifier> _heldMods = const [];

  // 대기 상태 깜빡이는 커서 (시안: 0.7s steps).
  Timer? _blink;
  bool _cursorOn = true;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    _blink = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (mounted && _recorded == null && _heldMods.isEmpty) {
        setState(() => _cursorOn = !_cursorOn);
      }
    });
  }

  @override
  void dispose() {
    _blink?.cancel();
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  static final _modKeys = {
    PhysicalKeyboardKey.controlLeft: HotKeyModifier.control,
    PhysicalKeyboardKey.controlRight: HotKeyModifier.control,
    PhysicalKeyboardKey.shiftLeft: HotKeyModifier.shift,
    PhysicalKeyboardKey.shiftRight: HotKeyModifier.shift,
    PhysicalKeyboardKey.altLeft: HotKeyModifier.alt,
    PhysicalKeyboardKey.altRight: HotKeyModifier.alt,
    PhysicalKeyboardKey.metaLeft: HotKeyModifier.meta,
    PhysicalKeyboardKey.metaRight: HotKeyModifier.meta,
  };

  List<HotKeyModifier> _currentMods() {
    final pressed = HardwareKeyboard.instance.physicalKeysPressed;
    final mods = <HotKeyModifier>{
      for (final e in _modKeys.entries)
        if (pressed.contains(e.key)) e.value,
    };
    return mods.toList();
  }

  bool _onKey(KeyEvent event) {
    if (!mounted) return false;
    if (event is KeyUpEvent) {
      setState(() => _heldMods = _currentMods());
      return true;
    }
    if (event is! KeyDownEvent) return false;
    widget.onActivity?.call();
    final key = event.physicalKey;
    if (_modKeys.containsKey(key)) {
      setState(() => _heldMods = _currentMods());
      return true;
    }
    final hk = HotKey(
      key: key,
      modifiers: _currentMods(),
      scope: HotKeyScope.system,
    );
    setState(() {
      _recorded = hk;
      _heldMods = const [];
    });
    widget.onRecorded(hk);
    return true; // 소비 — 다이얼로그 버튼 등으로 전파 방지
  }

  String _modsCombo() {
    final order = [
      HotKeyModifier.control,
      HotKeyModifier.shift,
      HotKeyModifier.alt,
      HotKeyModifier.meta,
    ];
    final parts = [
      for (final m in order)
        if (_heldMods.contains(m))
          switch (m) {
            HotKeyModifier.control => 'Ctrl',
            HotKeyModifier.shift => 'Shift',
            HotKeyModifier.alt => 'Alt',
            HotKeyModifier.meta => 'Win',
            _ => m.name,
          },
      '…',
    ];
    return parts.join('+');
  }

  @override
  Widget build(BuildContext context) {
    final waiting = _recorded == null && _heldMods.isEmpty;
    final Widget child;
    if (_heldMods.isNotEmpty) {
      child = KeyCaps(combo: _modsCombo(), fontSize: 13);
    } else if (_recorded != null) {
      child = KeyCaps(
          combo: HotkeyService.describeHotKey(_recorded!), fontSize: 13);
    } else {
      // 대기 — 깜빡이는 커서로 "입력을 듣고 있음"을 표현(시안).
      child = AnimatedOpacity(
        opacity: _cursorOn ? 1 : 0,
        duration: const Duration(milliseconds: 80),
        child: Container(width: 2, height: 18, color: AppColors.muted),
      );
    }
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(10),
        border: waiting
            ? null // dashed 는 아래 CustomPaint 로
            : Border.all(
                color: widget.error
                    ? AppColors.danger.withValues(alpha: 0.55)
                    : AppColors.border,
              ),
      ),
      foregroundDecoration: waiting
          ? _DashedBorder(
              color: widget.error
                  ? AppColors.danger.withValues(alpha: 0.55)
                  : AppColors.border,
            )
          : null,
      child: child,
    );
  }
}

/// dashed 테두리 데코레이션 (대기 상태 전용).
class _DashedBorder extends Decoration {
  final Color color;
  const _DashedBorder({required this.color});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _DashedBorderPainter(color);
}

class _DashedBorderPainter extends BoxPainter {
  final Color color;
  _DashedBorderPainter(this.color);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final rect = offset & (cfg.size ?? Size.zero);
    final rrect =
        RRect.fromRectAndRadius(rect.deflate(0.5), const Radius.circular(10));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const dash = 5.0, gap = 4.0;
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(
            metric.extractPath(d, (d + dash).clamp(0, metric.length)), paint);
        d += dash + gap;
      }
    }
  }
}
