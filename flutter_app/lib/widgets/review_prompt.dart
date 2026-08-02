import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/review_prompt_service.dart';
import 'feedback_page.dart';

/// 사용후기 유도 다이얼로그 — 타이머 완주 직후 등 "좋은 순간"에만 호출된다.
/// 노출 여부 판정(shouldPrompt)은 호출측이 아니라 여기서 일괄 처리한다.
Future<void> maybeShowReviewPrompt(BuildContext context) async {
  final svc = ReviewPromptService.instance;
  if (!await svc.shouldPrompt()) return;
  if (!context.mounted) return;
  await svc.recordPromptShown();
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      final l = AppLocalizations.of(ctx);
      return AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          l.reviewPromptTitle,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          l.reviewPromptBody,
          style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () async {
              await ReviewPromptService.instance.dismissForever();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(
              l.reviewPromptNever,
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                // "나중에" — 백오프는 recordPromptShown 이 이미 기록했으므로
                // 그냥 닫기만 하면 다음 쿨다운 후 재노출된다.
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  l.reviewPromptLater,
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ),
              const SizedBox(width: 4),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.timerOrange,
                ),
                onPressed: () async {
                  await ReviewPromptService.instance.markDone();
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) =>
                          const FeedbackPage(initialCategory: 'other'),
                    ),
                  );
                },
                child: Text(
                  l.reviewPromptAccept,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
