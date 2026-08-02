import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/hotkey_service.dart';
import 'key_caps.dart';
import '../services/platform_info.dart';
import '../theme/app_theme.dart';

/// 단축키 치트시트 — ⋯ 메뉴 "단축키" 또는 인앱 `?` 키로 연다.
Future<void> showShortcutSheet(BuildContext context) {
  final l = AppLocalizations.of(context);
  // 시안 결정 1: 조합 표기는 어디서나 키캡 분리형(KeyCaps)으로 통일.
  Widget key(String combo) => KeyCaps(combo: combo, fontSize: 12);
  Widget row(String label, List<String> combos) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        child: Row(
          children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.text))),
            for (var i = 0; i < combos.length; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text('·',
                      style: TextStyle(color: AppColors.muted, fontSize: 12)),
                ),
              key(combos[i]),
            ],
          ],
        ),
      );
  Widget section(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
        child: Text(title,
            style: const TextStyle(
                fontSize: 11, letterSpacing: 1.4, color: AppColors.faint)),
      );

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
    ),
    builder: (ctx) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 2, 18, 2),
            child: Text(l.shortcutSheetTitle,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text)),
          ),
          if (isDesktop) ...[
            section(l.shortcutGlobalSection),
            row(l.shortcutTimerToggle,
                [HotkeyService.instance.describe('timer_toggle')]),
            row(l.shortcutTimerNext,
                [HotkeyService.instance.describe('timer_next')]),
            row(l.shortcutSwLap,
                [HotkeyService.instance.describe('sw_lap')]),
            row(l.shortcutWidgetFocus,
                [HotkeyService.instance.describe('widget_focus')]),
          ],
          section(l.shortcutInAppSection),
          row(l.shortcutTimerToggle, const ['Space']),
          row(l.shortcutTimerNext, const ['N']),
          row(l.shortcutSwToggle, const ['S']),
          row(l.shortcutSwLap, const ['L']),
          if (isDesktop) row(l.shortcutWidgetToggle, const ['W']),
          if (isDesktop)
            row(l.shortcutWidgetMove, const ['←↑→↓', 'Shift+←↑→↓']),
          if (isDesktop)
            row(l.shortcutWidgetAnchor, const ['1–9']),
          if (isDesktop)
            row(l.shortcutWidgetMirror, const ['Tab', 'Shift+Tab']),
          if (isDesktop) row(l.shortcutWidgetBlur, const ['Esc']),
          row(l.shortcutSheetTitle, const ['?']),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
