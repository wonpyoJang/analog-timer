import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'l10n/app_localizations.dart';
import 'features/multi_timer/widgets/multi_timer_screen.dart';
import 'services/haptic_service.dart';
import 'services/platform_info.dart';
import 'settings_screen.dart';
import 'theme/app_theme.dart';

/// 앱 루트 셸 — 모바일에서 하단 탭으로 [타이머 / 멀티 타이머 / 설정] 전환.
///
/// 세 화면을 [IndexedStack] 으로 항상 살려두어 탭 전환이 즉시 이뤄지고 각 화면
/// 상태(진행 중 타이머, 스크롤 위치 등)가 보존된다. 데스크톱은 하단 탭이 이질적이라
/// 기존 [HomeScreen] + ⋯ 메뉴 방식을 그대로 쓴다.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // 데스크톱: 하단 탭 없이 기존 홈 화면(오버플로 메뉴로 이동).
    if (isDesktop) return const HomeScreen();

    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          MultiTimerScreen(embedded: true),
          SettingsScreen(embedded: true),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        index: _index,
        onTap: (i) {
          if (i == _index) return;
          HapticService.instance.selection();
          setState(() => _index = i);
        },
        items: [
          _NavItem(Icons.timer_outlined, Icons.timer, l.navTimer),
          _NavItem(Icons.timelapse_outlined, Icons.timelapse, l.navMulti),
          _NavItem(Icons.settings_outlined, Icons.settings, l.settings),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

/// 앱 다크 테마에 맞춘 커스텀 하단 탭 바(Material NavigationBar 대신 색 완전 제어).
class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;
  const _BottomNav({
    required this.index,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(child: _cell(context, i)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell(BuildContext context, int i) {
    final it = items[i];
    final selected = i == index;
    final color = selected ? AppColors.accent : AppColors.muted;
    return Semantics(
      button: true,
      selected: selected,
      label: it.label,
      child: InkResponse(
        onTap: () => onTap(i),
        radius: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? it.activeIcon : it.icon, size: 24, color: color),
            const SizedBox(height: 3),
            Text(
              it.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
