import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../services/platform_info.dart';
import '../theme/app_theme.dart';

/// 커스텀 타이틀바 (데스크톱) — 시안의 34px 상단 바.
///
/// OS 기본 캡션(밝은 회색 바) 대신 앱 톤에 맞춘 어두운 바를 직접 그린다.
/// 창 이동은 [DragToMoveArea], 더블클릭은 최대화 토글.
///
/// 닫기는 `windowManager.close()` — 기존과 동일하게 WM_CLOSE 네이티브 경로를
/// 타므로 러너의 clean 마커 기록·janitor 정리가 그대로 유효하다(경로를 바꾸면
/// 크래시 오탐이 생긴다).
class DesktopTitleBar extends StatelessWidget {
  const DesktopTitleBar({super.key});

  static const double height = 34;

  @override
  Widget build(BuildContext context) {
    // MaterialApp.builder 는 Navigator 바깥이라 Material 조상이 없다 —
    // 감싸지 않으면 Text 가 디버그 스타일(노란 밑줄)로 그려진다.
    return Material(
      color: const Color(0xFF111112),
      child: SizedBox(
        height: height,
        child: DragToMoveArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF111112),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                // 앱 로고 — 어두운 바에서도 보이는 링 렌디션(작업표시줄과 동일).
                Image.asset(
                  'assets/icons/app_icon_small.png',
                  width: 14,
                  height: 14,
                  filterQuality: FilterQuality.medium,
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Analog Timer',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9C9A96)),
                  ),
                ),
                const _CaptionButton(kind: _CaptionKind.minimize),
                const _CaptionButton(kind: _CaptionKind.maximize),
                const _CaptionButton(kind: _CaptionKind.close),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _CaptionKind { minimize, maximize, close }

class _CaptionButton extends StatefulWidget {
  final _CaptionKind kind;
  const _CaptionButton({required this.kind});

  @override
  State<_CaptionButton> createState() => _CaptionButtonState();
}

class _CaptionButtonState extends State<_CaptionButton> {
  bool _hover = false;

  Future<void> _onTap() async {
    switch (widget.kind) {
      case _CaptionKind.minimize:
        await windowManager.minimize();
      case _CaptionKind.maximize:
        if (await windowManager.isMaximized()) {
          await windowManager.unmaximize();
        } else {
          await windowManager.maximize();
        }
      case _CaptionKind.close:
        await windowManager.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isClose = widget.kind == _CaptionKind.close;
    // 유니코드 글리프는 폰트에 따라 굵기·정렬이 들쭉날쭉해 아이콘으로 그린다.
    final icon = switch (widget.kind) {
      _CaptionKind.minimize => Icons.remove,
      _CaptionKind.maximize => Icons.crop_square,
      _CaptionKind.close => Icons.close,
    };
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          width: 36,
          height: 32,
          alignment: Alignment.center,
          // 닫기만 위험색 hover — Windows 표준 관습과 동일한 어포던스.
          color: _hover
              ? (isClose ? AppColors.danger : const Color(0x14FFFFFF))
              : Colors.transparent,
          child: Icon(
            icon,
            size: widget.kind == _CaptionKind.maximize ? 11 : 14,
            color: _hover && isClose ? Colors.white : const Color(0xFF8C8A86),
          ),
        ),
      ),
    );
  }
}

/// MaterialApp.builder 에 끼워 모든 라우트 위에 타이틀바를 얹는다.
/// 데스크톱이 아니면 그대로 통과(모바일·웹 영향 없음).
Widget withDesktopTitleBar(BuildContext context, Widget? child) {
  if (!isDesktop || child == null) return child ?? const SizedBox.shrink();
  return Column(
    children: [
      const DesktopTitleBar(),
      Expanded(child: child),
    ],
  );
}
