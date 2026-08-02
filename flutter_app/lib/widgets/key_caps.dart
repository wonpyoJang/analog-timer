import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 키캡 분리형 조합 표기 — "Ctrl+Shift+Alt+L" → [Ctrl][Shift][Alt][L].
///
/// 디자인 시안 결정(질문 1): 설정·치트시트·녹화 다이얼로그 모두 이 표기로
/// 통일한다. "키를 누른다"는 대상과 표기가 일치하고, 녹화 진행형([Ctrl][…])
/// 과도 자연스럽게 이어진다. 단일 뱃지는 폐기.
///
/// borderBottom 2px = 키캡의 입체감(시안 스펙).
class KeyCaps extends StatelessWidget {
  final String combo;

  /// 선점(미등록) 상태 디밍 — 45% (시안: 위험이 아니라 "미등록"이므로
  /// 빨간 테두리 대신 존재감만 낮춘다).
  final bool dim;
  final double fontSize;

  const KeyCaps({
    super.key,
    required this.combo,
    this.dim = false,
    this.fontSize = 11.5,
  });

  @override
  Widget build(BuildContext context) {
    final keys = combo.split('+');
    return Opacity(
      opacity: dim ? 0.45 : 1,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final k in keys)
            Container(
              padding: const EdgeInsets.fromLTRB(7, 3, 7, 4),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(5),
                border: const Border(
                  top: BorderSide(color: AppColors.border),
                  left: BorderSide(color: AppColors.border),
                  right: BorderSide(color: AppColors.border),
                  bottom: BorderSide(color: AppColors.border, width: 2),
                ),
              ),
              child: Text(
                k,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFC9C6C0),
                  height: 1.2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
