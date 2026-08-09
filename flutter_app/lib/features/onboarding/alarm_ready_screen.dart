import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/alarm_readiness_service.dart';
import '../../theme/app_theme.dart';

/// 첫 실행 "알람 준비" 온보딩(디자인 "설정 구조 & 초기 설정" §1).
///
/// 사용자 결정은 2개뿐 — 알림 허용 + 배터리 예외. 나머지는 전부 기본값.
/// 건너뛰기 가능(건너뛰면 설정 상단 점검 카드로 계속 노출).
class AlarmReadyScreen extends StatefulWidget {
  const AlarmReadyScreen({super.key});

  @override
  State<AlarmReadyScreen> createState() => _AlarmReadyScreenState();
}

class _AlarmReadyScreenState extends State<AlarmReadyScreen>
    with WidgetsBindingObserver {
  final _svc = AlarmReadinessService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _svc.refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 시스템 권한 화면에서 돌아오면 상태 재확인.
    if (state == AppLifecycleState.resumed) _svc.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.onboardTitle,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l.onboardSub,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<bool>(
                valueListenable: _svc.notificationsOk,
                builder: (_, notifOk, _) => _StepCard(
                  n: 1,
                  done: notifOk,
                  active: !notifOk,
                  title: l.onboardNotifTitle,
                  desc: l.onboardNotifDesc,
                  action: notifOk ? null : l.onboardGrant,
                  onAction: () async {
                    await _svc.requestNotifications();
                  },
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                valueListenable: _svc.batteryExemptOk,
                builder: (_, batOk, _) => _StepCard(
                  n: 2,
                  done: batOk,
                  active: !batOk,
                  title: l.onboardBatteryTitle,
                  desc: l.onboardBatteryDesc,
                  action: batOk ? null : l.onboardAllow,
                  onAction: () async {
                    await _svc.requestBatteryExempt();
                  },
                ),
              ),
              const Spacer(),
              ValueListenableBuilder<bool>(
                valueListenable: _svc.notificationsOk,
                builder: (_, _, _) => ValueListenableBuilder<bool>(
                  valueListenable: _svc.batteryExemptOk,
                  builder: (_, _, _) {
                    final ready = _svc.allReady;
                    return Column(
                      children: [
                        if (ready)
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                l.onboardStart,
                                style: const TextStyle(
                                  color: Color(0xFF141416),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        else
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              l.onboardLater,
                              style: TextStyle(
                                color: AppColors.faint,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int n;
  final bool done;
  final bool active;
  final String title;
  final String desc;
  final String? action;
  final Future<void> Function() onAction;
  const _StepCard({
    required this.n,
    required this.done,
    required this.active,
    required this.title,
    required this.desc,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: active ? AppColors.accent : AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done
                  ? AppColors.swGreen.withAlpha(0x26)
                  : active
                  ? AppColors.accent.withAlpha(0x26)
                  : const Color(0xFF232326),
            ),
            child: Center(
              child: done
                  ? const Icon(Icons.check, size: 16, color: AppColors.swGreen)
                  : Text(
                      '$n',
                      style: TextStyle(
                        color: active ? AppColors.accent : AppColors.faint,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onAction,
                    child: Text(
                      action!,
                      style: const TextStyle(
                        color: Color(0xFF141416),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
