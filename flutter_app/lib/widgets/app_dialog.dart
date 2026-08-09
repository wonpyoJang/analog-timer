import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// 팝업 디자인 시스템(디자인 "팝업 디자인 시스템.html") — Dialog·Sheet·Toast 통합.
///
/// 해부: mark(아이콘) → title → body → actions. 순서 고정, mark·body 생략 가능.
/// 규칙: 되돌리기 어려운 결정만 Dialog, 이미 일어난 일은 Toast(showAppToast).
/// 주 동작은 항상 오른쪽(스택은 위). scrim 탭=취소(Destructive·Input 제외).

const _surface2 = Color(0xFF232326); // AppColors 에 없는 시안 토큰
const _scrim = Color(0x9E000000); // rgba(0,0,0,.62), 블러 없음
const _dialogW = 340.0;
const _enter = Cubic(0.2, 0.8, 0.2, 1.0);

/// 버튼 종류 — pri(주) / gho(보조) / dan(파괴) / txt(약한 동작).
enum AppBtn { pri, gho, dan, txt }

/// mark 종류 — 없음 / 경고(danger) / 강조(accent) / 완료(green).
enum AppMark { none, warn, accent, ok }

/// 다이얼로그 액션 하나 — 라벨·종류·닫을 때 반환값.
class AppAction<T> {
  final String label;
  final AppBtn variant;
  final T? value;
  final bool enabled;
  const AppAction(
    this.label, {
    this.variant = AppBtn.gho,
    this.value,
    this.enabled = true,
  });
}

/// 디자인 시스템 버튼 — pressed(명도 조정)·disabled·최소 터치 높이 48 준수.
class AppDialogButton extends StatefulWidget {
  final String label;
  final AppBtn variant;
  final VoidCallback? onPressed;
  const AppDialogButton({
    super.key,
    required this.label,
    this.variant = AppBtn.gho,
    this.onPressed,
  });

  @override
  State<AppDialogButton> createState() => _AppDialogButtonState();
}

class _AppDialogButtonState extends State<AppDialogButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final (bg, fg, weight) = _style(widget.variant, _down, disabled);
    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _down = true),
        onTapCancel: disabled ? null : () => setState(() => _down = false),
        onTapUp: disabled ? null : (_) => setState(() => _down = false),
        onTap: disabled ? null : widget.onPressed,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: fg,
              fontSize: 15,
              height: 1,
              fontWeight: weight,
              letterSpacing: -0.15,
            ),
          ),
        ),
      ),
    );
  }

  /// (배경, 글자, 굵기) — 시안의 pressed(pri −8%, gho 살짝 밝게)·disabled 규칙.
  (Color, Color, FontWeight) _style(AppBtn v, bool down, bool dis) {
    const disBg = Color(0xFF242427);
    const disFg = Color(0xFF5A5A5F);
    switch (v) {
      case AppBtn.pri:
        if (dis) return (disBg, disFg, FontWeight.w700);
        final bg = down ? const Color(0xFFCFA435) : AppColors.accent;
        return (bg, const Color(0xFF141416), FontWeight.w700);
      case AppBtn.gho:
        if (dis) return (disBg, disFg, FontWeight.w600);
        final bg = down ? const Color(0xFF2D2D31) : _surface2;
        return (bg, AppColors.text, FontWeight.w600);
      case AppBtn.dan:
        if (dis) return (disBg, disFg, FontWeight.w700);
        final bg = down ? const Color(0xFFCE4A4A) : AppColors.danger;
        return (bg, Colors.white, FontWeight.w700);
      case AppBtn.txt:
        final bg = down ? _surface2 : Colors.transparent;
        return (bg, AppColors.faint, FontWeight.w600);
    }
  }
}

/// Dialog 본체(scrim 위에 뜨는 카드). 직접 쓰기보다 아래 show* 헬퍼를 사용.
class AppDialog extends StatelessWidget {
  final AppMark mark;
  final String title;
  final String? body;

  /// 본문 내 강조 조각(em) — 앞 문장 뒤에 붙여 text 색·500 으로 표시.
  final Widget? extra;
  final List<AppAction> actions;
  const AppDialog({
    super.key,
    this.mark = AppMark.none,
    required this.title,
    this.body,
    this.extra,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    // 스택 조건: 3개 이상 또는 라벨 8자 초과.
    final stack = actions.length >= 3 || actions.any((a) => a.label.length > 8);
    return Center(
      child: Container(
        width: _dialogW,
        margin: const EdgeInsets.symmetric(horizontal: 36),
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0xB3000000),
              blurRadius: 70,
              offset: Offset(0, 28),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mark != AppMark.none) ...[
              _MarkBox(mark),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 18,
                height: 1.35,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.22,
              ),
            ),
            if (body != null || extra != null) ...[
              const SizedBox(height: 9),
              _Body(body: body, extra: extra),
            ],
            const SizedBox(height: 22),
            _Actions(actions: actions, stack: stack),
          ],
        ),
      ),
    );
  }
}

class _MarkBox extends StatelessWidget {
  final AppMark mark;
  const _MarkBox(this.mark);
  @override
  Widget build(BuildContext context) {
    final (bg, fg, glyph) = switch (mark) {
      AppMark.warn => (const Color(0x24E05252), AppColors.danger, '!'),
      AppMark.accent => (const Color(0x24F0C040), AppColors.accent, '⏱'),
      AppMark.ok => (const Color(0x292EA84A), AppColors.swGreen, '✓'),
      AppMark.none => (Colors.transparent, Colors.transparent, ''),
    };
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(13),
      ),
      alignment: Alignment.center,
      child: Text(glyph, style: TextStyle(color: fg, fontSize: 20)),
    );
  }
}

class _Body extends StatelessWidget {
  final String? body;
  final Widget? extra;
  const _Body({this.body, this.extra});
  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: AppColors.muted, fontSize: 14, height: 1.7);
    if (extra != null) {
      return DefaultTextStyle(
        style: style,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Flexible(child: extra!)],
        ),
      );
    }
    return Text(body ?? '', style: style);
  }
}

class _Actions extends StatelessWidget {
  final List<AppAction> actions;
  final bool stack;
  const _Actions({required this.actions, required this.stack});

  Widget _btn(BuildContext context, AppAction a) => AppDialogButton(
    label: a.label,
    variant: a.variant,
    onPressed: a.enabled ? () => Navigator.of(context).pop(a.value) : null,
  );

  @override
  Widget build(BuildContext context) {
    if (stack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _btn(context, actions[i]),
          ],
        ],
      );
    }
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 9),
          Expanded(child: _btn(context, actions[i])),
        ],
      ],
    );
  }
}

/// scrim 페이드 + 카드 scale .96→1 / y 8→0 (enter 180ms · exit fade 120ms).
Future<T?> _present<T>(
  BuildContext context,
  Widget child, {
  required bool dismissible,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: _scrim,
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, _, _) => child,
    transitionBuilder: (_, anim, _, c) {
      // exit(status.reverse)엔 fade만 — 시안 규칙.
      final entering = anim.status != AnimationStatus.reverse;
      final curved = CurvedAnimation(parent: anim, curve: _enter);
      Widget faded = FadeTransition(opacity: anim, child: c);
      if (!entering) return faded;
      return FadeTransition(
        opacity: anim,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - curved.value)),
          child: Transform.scale(scale: 0.96 + 0.04 * curved.value, child: c),
        ),
      );
    },
  );
}

// ── 헬퍼 ───────────────────────────────────────────────────────────────

/// Confirm — 되돌리기 쉬운 2지선다. true = 주 동작 확인.
Future<bool> showAppConfirm(
  BuildContext context, {
  required String title,
  String? body,
  required String confirmLabel,
  required String cancelLabel,
  AppMark mark = AppMark.none,
}) async {
  final r = await _present<bool>(
    context,
    AppDialog(
      mark: mark,
      title: title,
      body: body,
      actions: [
        AppAction(cancelLabel, variant: AppBtn.gho, value: false),
        AppAction(confirmLabel, variant: AppBtn.pri, value: true),
      ],
    ),
    dismissible: true,
  );
  return r == true;
}

/// Destructive — 파괴적 결정. danger mark + danger 동작. scrim 탭으로 안 닫힘.
Future<bool> showAppDestructive(
  BuildContext context, {
  required String title,
  String? body,
  Widget? bodyRich,
  required String confirmLabel,
  required String cancelLabel,
}) async {
  final r = await _present<bool>(
    context,
    AppDialog(
      mark: AppMark.warn,
      title: title,
      body: bodyRich == null ? body : null,
      extra: bodyRich,
      actions: [
        AppAction(cancelLabel, variant: AppBtn.gho, value: false),
        AppAction(confirmLabel, variant: AppBtn.dan, value: true),
      ],
    ),
    dismissible: false,
  );
  return r == true;
}

/// Acknowledge — 이미 끝난 일 통지, 확인 버튼 하나.
Future<void> showAcknowledge(
  BuildContext context, {
  required String title,
  String? body,
  required String okLabel,
  AppMark mark = AppMark.ok,
}) {
  return _present<void>(
    context,
    AppDialog(
      mark: mark,
      title: title,
      body: body,
      actions: [AppAction(okLabel, variant: AppBtn.pri)],
    ),
    dismissible: true,
  );
}

/// Choice — 라디오 목록에서 하나 선택(최대 5). 선택값 반환, 취소 시 null.
Future<T?> showAppChoice<T>(
  BuildContext context, {
  required String title,
  required List<({T value, String label, String? note})> options,
  required T selected,
  required String confirmLabel,
  required String cancelLabel,
}) {
  return _present<T>(
    context,
    _ChoiceDialog<T>(
      title: title,
      options: options,
      selected: selected,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    ),
    dismissible: true,
  );
}

class _ChoiceDialog<T> extends StatefulWidget {
  final String title;
  final List<({T value, String label, String? note})> options;
  final T selected;
  final String confirmLabel;
  final String cancelLabel;
  const _ChoiceDialog({
    required this.title,
    required this.options,
    required this.selected,
    required this.confirmLabel,
    required this.cancelLabel,
  });
  @override
  State<_ChoiceDialog<T>> createState() => _ChoiceDialogState<T>();
}

class _ChoiceDialogState<T> extends State<_ChoiceDialog<T>> {
  late T _sel = widget.selected;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: _dialogW,
        margin: const EdgeInsets.symmetric(horizontal: 36),
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0xB3000000),
              blurRadius: 70,
              offset: Offset(0, 28),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 18,
                height: 1.35,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.22,
              ),
            ),
            const SizedBox(height: 18),
            for (var i = 0; i < widget.options.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _OptRow(
                label: widget.options[i].label,
                note: widget.options[i].note,
                on: widget.options[i].value == _sel,
                onTap: () => setState(() => _sel = widget.options[i].value),
              ),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: AppDialogButton(
                    label: widget.cancelLabel,
                    variant: AppBtn.gho,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: AppDialogButton(
                    label: widget.confirmLabel,
                    variant: AppBtn.pri,
                    onPressed: () => Navigator.of(context).pop(_sel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OptRow extends StatelessWidget {
  final String label;
  final String? note;
  final bool on;
  final VoidCallback onTap;
  const _OptRow({
    required this.label,
    this.note,
    required this.on,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: on,
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: on ? const Color(0x0FF0C040) : const Color(0xFF141416),
            border: Border.all(color: on ? AppColors.accent : AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: on ? AppColors.accent : Colors.transparent,
                  border: Border.all(
                    color: on ? AppColors.accent : const Color(0xFF3D3D42),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: on
                    ? const Text(
                        '✓',
                        style: TextStyle(
                          color: Color(0xFF141416),
                          fontSize: 11,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (note != null)
                Text(
                  note!,
                  style: TextStyle(color: AppColors.faint, fontSize: 12.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sheet — 하단 고정, 한 대상의 동작 3~5개. 드래그/스크림으로 닫힘. 선택값 반환.
Future<T?> showAppActionSheet<T>(
  BuildContext context, {
  required String title,
  required List<({T value, String label, bool danger})> actions,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: _scrim,
    isScrollControlled: true,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
          left: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        12,
        22,
        26 + MediaQuery.of(ctx).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              height: 1.35,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.22,
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _SheetRow(
              label: actions[i].label,
              danger: actions[i].danger,
              onTap: () => Navigator.of(ctx).pop(actions[i].value),
            ),
          ],
        ],
      ),
    ),
  );
}

class _SheetRow extends StatelessWidget {
  final String label;
  final bool danger;
  final VoidCallback onTap;
  const _SheetRow({
    required this.label,
    required this.danger,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFF141416),
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: danger ? AppColors.danger : AppColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Toast — 이미 일어난 일 알림. pill, 하단 safe area +16, 2.4s 자동 소멸,
/// 되돌리기 링크 최대 1. 동시에 1개만(기존 것 먼저 제거).
void showAppToast(
  BuildContext context,
  String message, {
  String? undoLabel,
  VoidCallback? onUndo,
  bool accent = false,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  HapticFeedback.selectionClick();
  messenger.showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 2400),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      content: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFF1D1D20),
            border: Border.all(color: const Color(0xFF35353A)),
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x99000000),
                blurRadius: 32,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent ? AppColors.accent : AppColors.swGreen,
                ),
              ),
              const SizedBox(width: 11),
              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (undoLabel != null && onUndo != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    messenger.hideCurrentSnackBar();
                    onUndo();
                  },
                  child: Text(
                    undoLabel,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
