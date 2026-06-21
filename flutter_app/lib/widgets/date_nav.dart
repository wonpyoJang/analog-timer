import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'date_label.dart';

enum DateViewMode { past, today, future }

class DateNav extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime today;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;

  const DateNav({
    super.key,
    required this.selectedDate,
    required this.today,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
  });

  DateViewMode get _mode {
    final sel = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final tod = DateTime(today.year, today.month, today.day);
    if (sel.isBefore(tod)) return DateViewMode.past;
    if (sel.isAfter(tod)) return DateViewMode.future;
    return DateViewMode.today;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final mode = _mode;
    final isToday = mode == DateViewMode.today;

    final modeLabel = switch (mode) {
      DateViewMode.past => l.modeLabelLog,
      DateViewMode.today => l.modeLabelToday,
      DateViewMode.future => l.modeLabelPlan,
    };

    final modeColor = switch (mode) {
      DateViewMode.past => AppColors.muted,
      DateViewMode.today => AppColors.accent,
      DateViewMode.future => AppColors.swGreen,
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _NavButton(icon: Icons.chevron_left, onTap: onPrev),
        GestureDetector(
          onTap: isToday ? null : onToday,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatDateLine(selectedDate, lang),
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                  color: AppColors.text.withAlpha(0xAA),
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: modeColor.withAlpha(0x22),
                  border: Border.all(color: modeColor.withAlpha(0x66)),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  modeLabel,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: modeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        _NavButton(
          icon: Icons.chevron_right,
          // 오늘로부터 최대 30일 미래까지만 허용
          onTap: selectedDate.isBefore(today.add(const Duration(days: 30)))
              ? onNext
              : null,
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Icon(
          icon,
          size: 22,
          color: onTap != null ? AppColors.muted : AppColors.border,
        ),
      ),
    );
  }
}
