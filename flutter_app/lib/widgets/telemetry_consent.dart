import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/telemetry_service.dart';

/// 첫 실행 1회 동의 다이얼로그. consent 가 null(미정)일 때만 호출한다.
Future<void> showTelemetryConsent(BuildContext context) async {
  final l = AppLocalizations.of(context);
  final allow = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Text(
        l.telemetryConsentTitle,
        style: const TextStyle(color: AppColors.text, fontSize: 16),
      ),
      content: Text(
        l.telemetryConsentBody,
        style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l.telemetryDeny, style: const TextStyle(color: AppColors.muted)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            l.telemetryAllow,
            style: const TextStyle(color: AppColors.timerOrange, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
  await TelemetryService.instance.setConsent(allow ?? false);
}

/// 설정에서 진단 데이터 전송을 켜고 끄는 토글 다이얼로그.
Future<void> showTelemetrySettings(BuildContext context) async {
  final l = AppLocalizations.of(context);
  bool on = await TelemetryService.instance.consent() ?? false;
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          l.telemetryConsentTitle,
          style: const TextStyle(color: AppColors.text, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.telemetryConsentBody,
              style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Switch(
                  value: on,
                  onChanged: (v) async {
                    setLocal(() => on = v);
                    await TelemetryService.instance.setConsent(v);
                  },
                  activeThumbColor: AppColors.timerOrange,
                  activeTrackColor: AppColors.timerOrange.withAlpha(0x88),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Text(
                  l.telemetryReportSetting,
                  style: const TextStyle(color: AppColors.text, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel, style: const TextStyle(color: AppColors.muted)),
          ),
        ],
      ),
    ),
  );
}
