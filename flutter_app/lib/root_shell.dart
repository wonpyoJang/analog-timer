import 'dart:async';

import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'features/water/water_screen.dart';
import 'services/water_reminder_service.dart';
import 'l10n/app_localizations.dart';
import 'features/multi_timer/widgets/multi_timer_screen.dart';
import 'features/workout/workout_screen.dart';
import 'features/prep/prep_screen.dart';
import 'services/haptic_service.dart';
import 'services/deep_link_router.dart';
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
  Timer? _waterTimer;

  @override
  void initState() {
    super.initState();
    // 딥링크가 요청한 탭으로 전환(§3). 콜드 스타트로 이미 설정된 값도 즉시 반영.
    DeepLinkRouter.instance.requestedTab.addListener(_onTabRequest);
    _onTabRequest();
    // 물 마시기 알림(인앱) — 앱 실행 중 1분마다 예정 시각 도래 확인 → 배너.
    if (isAndroid || isIOS) {
      _waterTimer = Timer.periodic(
        const Duration(seconds: 60),
        (_) => _checkWater(),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncWaterNotif();
        _checkWater();
      });
    }
  }

  Future<void> _checkWater() async {
    if (!mounted) return;
    if (await WaterReminderService.instance.isDueNow() && mounted) {
      showWaterBanner(context);
    }
  }

  bool _waterNotifSynced = false;

  /// 알림 문구를 l10n 으로 세팅하고 백그라운드 예약을 동기화(앱 시작 시 1회).
  void _syncWaterNotif() {
    if (_waterNotifSynced || !mounted) return;
    _waterNotifSynced = true;
    final l = AppLocalizations.of(context);
    WaterReminderService.instance
      ..notifTitle = l.waterBannerTitle
      ..notifBody = l.waterNotifBody
      ..syncSchedule();
  }

  void _onTabRequest() {
    final t = DeepLinkRouter.instance.requestedTab.value;
    if (t == null || isDesktop) return;
    DeepLinkRouter.instance.requestedTab.value = null;
    if (mounted && t != _index && t >= 0 && t < 5) {
      setState(() => _index = t);
    }
  }

  @override
  void dispose() {
    _waterTimer?.cancel();
    DeepLinkRouter.instance.requestedTab.removeListener(_onTabRequest);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 데스크톱: 하단 탭은 이질적이라 두지 않되, 모바일과 동일하게 IndexedStack 으로
    // 멀티 타이머 화면을 살려둔다. 라우트 push/pop 방식이면 화면을 떠날 때
    // MultiTimerBloc 이 dispose 되어 티커·완료 알림·영속화가 모두 멈춘다.
    // 전환은 홈 헤더의 '멀티' 버튼과 멀티 화면의 뒤로가기로 한다.
    if (isDesktop) {
      return IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            active: _index == 0,
            onOpenMultiTimer: () => setState(() => _index = 1),
          ),
          MultiTimerScreen(
            embedded: true,
            onBack: () => setState(() => _index = 0),
          ),
        ],
      );
    }

    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: _index,
        children: [
          // active=false 면 HomeScreen 이 60fps 시계 재빌드를 멈춘다 — 숨겨진 탭에서
          // 메인스레드를 포화시켜 오버레이 드래그/토글을 굶기는 것을 방지.
          HomeScreen(active: _index == 0),
          const MultiTimerScreen(embedded: true),
          const WorkoutScreen(),
          const PrepScreen(),
          const SettingsScreen(embedded: true),
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
          _NavItem(
            Icons.fitness_center_outlined,
            Icons.fitness_center,
            l.workoutTab,
          ),
          _NavItem(
            Icons.checklist_rtl_outlined,
            Icons.checklist_rtl,
            l.prepTab,
          ),
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
