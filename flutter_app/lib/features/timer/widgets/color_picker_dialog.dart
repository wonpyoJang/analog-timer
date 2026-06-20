import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

/// 세그먼트 색상 선택 팔레트. 선택한 색을 반환(취소 시 null).
/// segment_editor 와 프리셋 편집에서 공용.
Future<Color?> showSegColorPicker(BuildContext context, Color current) {
  final l = AppLocalizations.of(context);
  final cur = current.toARGB32();
  return showDialog<Color>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.segmentColor,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final c in AppColors.segColors)
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx, c),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: c.toARGB32() == cur
                                ? AppColors.text
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: c.toARGB32() == cur
                            ? const Icon(Icons.check, size: 18, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
