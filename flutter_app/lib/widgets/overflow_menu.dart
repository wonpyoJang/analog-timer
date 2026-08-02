import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/desktop_service.dart';
import '../services/sync_service.dart';
import '../services/telemetry_service.dart';
import '../theme/app_theme.dart';

/// 헤더 ⋯ 오버플로 메뉴 — 관리·복구 기능을 한 뎁스 아래로 접는다.
///
/// 배경: "기능이 많아 불안하다"는 실사용 피드백. 헤더에 아이콘 7개가 같은
/// 무게로 노출되던 것을 [위젯 토글 + ⋯] 2개로 줄이고, 나머지는 이 메뉴로.
/// 기능은 하나도 삭제하지 않는다 — 발견 경로만 바꾼다.
///
/// 복구 계열(위젯 새로고침 / 앱 재시작 / 오류 리포트)은 "문제 해결" 그룹으로
/// 묶고, **자동 감지·복구가 이미 동작 중**임을 안내해 사용자가 직접 누를 일이
/// 거의 없다는 것을 알린다(= 불안 완화가 이 메뉴의 핵심 목적).
class OverflowMenuItem {
  final IconData icon;
  final String label;
  final String? hint;
  final bool chevron;
  final bool accent;
  final VoidCallback onTap;
  const OverflowMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.hint,
    this.chevron = false,
    this.accent = false,
  });
}

/// 헤더의 ⋯ 버튼. 탭하면 앵커 아래에 메뉴를 띄운다.
class OverflowMenuButton extends StatelessWidget {
  /// 설정 / 기기 동기화 / 오류 리포트 / 단축키 — 화면 전환은 호출측이 처리.
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenSync;
  final VoidCallback onOpenTelemetry;
  final VoidCallback onShowShortcuts;

  /// 위젯 새로고침 — 위젯이 켜져 있을 때만 노출된다.
  final bool widgetOn;
  final VoidCallback onRefreshWidget;

  const OverflowMenuButton({
    super.key,
    required this.onOpenSettings,
    required this.onOpenSync,
    required this.onOpenTelemetry,
    required this.onShowShortcuts,
    required this.widgetOn,
    required this.onRefreshWidget,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Tooltip(
      message: l.menuMore,
      child: GestureDetector(
        onTap: () => _show(context),
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.more_horiz, size: 16, color: AppColors.muted),
        ),
      ),
    );
  }

  Future<void> _show(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final box = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (box == null || overlay == null) return;
    // 버튼 오른쪽 끝에 맞춰 아래로 펼친다(시안: top 82, right 14).
    final anchor = box.localToGlobal(box.size.bottomRight(Offset.zero),
        ancestor: overlay);
    final position = RelativeRect.fromLTRB(
      anchor.dx - 252,
      anchor.dy + 6,
      overlay.size.width - anchor.dx,
      0,
    );

    final items = <OverflowMenuItem>[
      OverflowMenuItem(
        icon: Icons.settings_outlined,
        label: l.settings,
        hint: l.menuSettingsHint,
        chevron: true,
        onTap: onOpenSettings,
      ),
      if (SyncService.instance.supported)
        OverflowMenuItem(
          icon: Icons.devices_outlined,
          label: l.syncPageTitle,
          chevron: true,
          onTap: onOpenSync,
        ),
      OverflowMenuItem(
        icon: Icons.keyboard_outlined,
        label: l.menuShortcuts,
        hint: '?',
        onTap: onShowShortcuts,
      ),
    ];
    final trouble = <OverflowMenuItem>[
      // 레이블은 메뉴 전용 단문(툴팁 문장을 재사용하면 줄이 넘친다).
      if (widgetOn)
        OverflowMenuItem(
          icon: Icons.refresh,
          label: l.menuRefreshWidget,
          onTap: onRefreshWidget,
        ),
      if (isDesktop)
        OverflowMenuItem(
          icon: Icons.restart_alt,
          label: l.menuRestartApp,
          accent: true,
          onTap: () => DesktopService.instance.restart(),
        ),
      if (TelemetryService.instance.supported)
        OverflowMenuItem(
          icon: Icons.flag_outlined,
          label: l.menuErrorReports,
          chevron: true,
          onTap: onOpenTelemetry,
        ),
    ];

    await showMenu<void>(
      context: context,
      position: position,
      color: const Color(0xFF141416),
      elevation: 12,
      constraints: const BoxConstraints(minWidth: 252, maxWidth: 252),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      items: [
        for (final it in items) _row(it),
        if (trouble.isNotEmpty) ...[
          const PopupMenuDivider(height: 11),
          _header(l.menuTroubleshoot),
          for (final it in trouble) _row(it),
          _note(l.menuAutoRecoveryNote),
        ],
      ],
    );
  }

  PopupMenuItem<void> _row(OverflowMenuItem it) => PopupMenuItem<void>(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        onTap: it.onTap,
        child: Row(
          children: [
            SizedBox(
              width: 18,
              child: Icon(it.icon,
                  size: 15,
                  color: it.accent ? AppColors.accent : AppColors.muted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                it.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  color: it.accent ? AppColors.accent : AppColors.text,
                ),
              ),
            ),
            // 힌트는 폭을 제한한다 — 무제한이면 긴 번역(영어·독일어)이 공간을
            // 다 먹어 정작 레이블이 잘린다(실제 발생).
            if (it.hint != null) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 108),
                child: Text(
                  it.hint!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontSize: 11.5, color: AppColors.faint),
                ),
              ),
            ],
            if (it.chevron) ...[
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, size: 15, color: AppColors.faint),
            ],
          ],
        ),
      );

  /// 그룹 헤더 — 탭 불가(enabled:false)라 메뉴가 닫히지 않는다.
  PopupMenuItem<void> _header(String text) => PopupMenuItem<void>(
        enabled: false,
        height: 26,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10.5,
            letterSpacing: 1.6,
            color: AppColors.faint,
          ),
        ),
      );

  /// 자동 복구 안내 — 이 메뉴의 존재 이유(불안 완화)를 직접 말해주는 문구.
  PopupMenuItem<void> _note(String text) => PopupMenuItem<void>(
        enabled: false,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.swGreen.withValues(alpha: 0.07),
            border:
                Border.all(color: AppColors.swGreen.withValues(alpha: 0.18)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.swGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.5,
                    color: Color(0xFF8FBF9C),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
