
import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'services/battery_service.dart';
import 'theme/app_theme.dart';
import 'widgets/language_picker.dart';
import 'widgets/feedback_page.dart';
import 'services/platform_info.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    // 현재 선택된 언어 이름 (시스템 기본이면 l.languageSystem)
    const langLabels = {
      'en': 'English',
      'ko': '한국어',
      'zh': '中文',
      'es': 'Español',
      'ar': 'العربية',
      'pt': 'Português',
      'fr': 'Français',
      'ja': '日本語',
      'de': 'Deutsch',
      'ru': 'Русский',
      'hi': 'हिन्दी',
      'id': 'Bahasa Indonesia',
      'it': 'Italiano',
      'tr': 'Türkçe',
    };
    final langLabel = langLabels[locale.languageCode] ?? l.languageSystem;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.text,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l.settings,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── 언어 ──────────────────────────────────────────────
          _SettingsTile(
            icon: Icons.language,
            iconColor: AppColors.accent,
            title: l.settingsLanguage,
            trailing: Text(
              langLabel,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                fontFamily: 'Pretendard',
              ),
            ),
            onTap: () => showLanguagePicker(context),
          ),

          const _Divider(),

          // ── 제작자에게 피드백 (버그/기능요청, 사진·동영상 첨부) ──────
          _SettingsTile(
            icon: Icons.send_outlined,
            iconColor: AppColors.timerOrange,
            title: l.feedbackEntry,
            subtitle: l.feedbackEntryDesc,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FeedbackPage()),
            ),
          ),

          const _Divider(),

          // ── 배터리 모니터링 (모바일 전용) ─────────────────────
          if (isAndroid || isIOS) ...[
            ValueListenableBuilder<bool>(
              valueListenable: BatteryService.instance.monitoringEnabled,
              builder: (ctx, enabled, _) => _SettingsTile(
                icon: Icons.battery_std,
                iconColor: const Color(0xFFB45309),
                title: l.settingsBattery,
                subtitle: l.settingsBatteryDesc,
                trailing: Switch(
                  value: enabled,
                  onChanged: BatteryService.instance.setEnabled,
                  activeThumbColor: const Color(0xFFB45309),
                  trackColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? const Color(0xFFB45309).withAlpha(0x55)
                        : AppColors.surface,
                  ),
                ),
                onTap: () => BatteryService.instance.setEnabled(!enabled),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.accent.withAlpha(0x22),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(0x22),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 68,
      endIndent: 0,
      color: AppColors.border,
    );
  }
}
