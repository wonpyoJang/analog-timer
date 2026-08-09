import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/review_prompt_service.dart';
import 'app_dialog.dart';
import 'feedback_page.dart';

enum _ReviewChoice { never, later, accept }

/// 사용후기 유도 다이얼로그 — 타이머 완주 직후 등 "좋은 순간"에만 호출된다.
/// 노출 여부 판정(shouldPrompt)은 호출측이 아니라 여기서 일괄 처리한다.
/// 3지선다라 Stacked 다이얼로그(showAppActions)로 표시한다.
Future<void> maybeShowReviewPrompt(BuildContext context) async {
  final svc = ReviewPromptService.instance;
  if (!await svc.shouldPrompt()) return;
  if (!context.mounted) return;
  await svc.recordPromptShown();
  if (!context.mounted) return;

  final l = AppLocalizations.of(context);
  final choice = await showAppActions<_ReviewChoice>(
    context,
    title: l.reviewPromptTitle,
    body: l.reviewPromptBody,
    actions: [
      AppAction(
        l.reviewPromptAccept,
        variant: AppBtn.pri,
        value: _ReviewChoice.accept,
      ),
      AppAction(
        l.reviewPromptLater,
        variant: AppBtn.gho,
        value: _ReviewChoice.later,
      ),
      AppAction(
        l.reviewPromptNever,
        variant: AppBtn.txt,
        value: _ReviewChoice.never,
      ),
    ],
  );
  // 백오프는 recordPromptShown 이 이미 기록 — "나중에"/닫기는 다음 쿨다운 후 재노출.
  switch (choice) {
    case _ReviewChoice.never:
      await svc.dismissForever();
    case _ReviewChoice.accept:
      await svc.markDone();
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const FeedbackPage(initialCategory: 'other'),
        ),
      );
    case _ReviewChoice.later:
    case null:
      break;
  }
}
