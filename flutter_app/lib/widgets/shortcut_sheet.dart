import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/platform_info.dart';
import '../theme/app_theme.dart';

/// 단축키 치트시트 — ⋯ 메뉴 "단축키" 또는 인앱 `?` 키로 연다.
Future<void> showShortcutSheet(BuildContext context) {
  final l = AppLocalizations.of(context);
  Widget key(String combo) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.bg,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(combo,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.text,
                fontFamily: 'Pretendard')),
      );
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
            row(l.shortcutTimerToggle, const ['Ctrl+Alt+Space']),
            row(l.shortcutTimerNext, const ['Ctrl+Alt+N']),
            row(l.shortcutSwLap, const ['Ctrl+Alt+L']),
          ],
          section(l.shortcutInAppSection),
          row(l.shortcutTimerToggle, const ['Space']),
          row(l.shortcutTimerNext, const ['N']),
          row(l.shortcutSwToggle, const ['S']),
          row(l.shortcutSwLap, const ['L']),
          if (isDesktop) row(l.shortcutWidgetToggle, const ['W']),
          row(l.shortcutSheetTitle, const ['?']),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
