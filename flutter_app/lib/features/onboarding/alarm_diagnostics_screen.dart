import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/alarm_readiness_service.dart';
import '../../services/native_widget_service.dart';
import '../../theme/app_theme.dart';

/// 알람 점검 페이지(디자인 "설정 상세 페이지" §F) — 자가 진단 체크리스트.
///
/// 알림·배터리 예외·오버레이 3개를 앱이 직접 검사하고, 문제 항목만 "고치기"로
/// 해당 권한을 요청. 하단 테스트 알람으로 실제로 울리는지 즉시 확인.
class AlarmDiagnosticsScreen extends StatefulWidget {
  const AlarmDiagnosticsScreen({super.key});

  @override
  State<AlarmDiagnosticsScreen> createState() => _AlarmDiagnosticsScreenState();
}

class _AlarmDiagnosticsScreenState extends State<AlarmDiagnosticsScreen>
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
    if (state == AppLifecycleState.resumed) _svc.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _fixAll() async {
    if (!_svc.notificationsOk.value) await _svc.requestNotifications();
    if (!_svc.batteryExemptOk.value) await _svc.requestBatteryExempt();
    if (!_svc.overlayOk.value) await _svc.requestOverlay();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: AppColors.text,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l.diagTitle,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _svc.notificationsOk,
          _svc.batteryExemptOk,
          _svc.overlayOk,
        ]),
        builder: (context, _) {
          final items = <_Diag>[
            _Diag(
              ok: _svc.notificationsOk.value,
              title: l.diagNotifTitle,
              okDesc: l.diagNotifOk,
              badDesc: l.diagNotifBad,
              fix: _svc.requestNotifications,
            ),
            _Diag(
              ok: _svc.batteryExemptOk.value,
              title: l.diagBatteryTitle,
              okDesc: l.diagBatteryOk,
              badDesc: l.diagBatteryBad,
              fix: _svc.requestBatteryExempt,
            ),
            _Diag(
              ok: _svc.overlayOk.value,
              title: l.diagOverlayTitle,
              okDesc: l.diagOverlayOk,
              badDesc: l.diagOverlayBad,
              fix: _svc.requestOverlay,
            ),
          ];
          final badCount = items.where((d) => !d.ok).length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Text(
                  l.diagSub,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // 요약 배너
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (badCount > 0 ? AppColors.danger : AppColors.swGreen)
                        .withAlpha(0x14),
                    border: Border.all(
                      color:
                          (badCount > 0 ? AppColors.danger : AppColors.swGreen)
                              .withAlpha(0x4C),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        badCount > 0
                            ? l.diagWarnTitle(badCount)
                            : l.diagAllGood,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        badCount > 0 ? l.diagWarnDesc : l.diagAllGoodDesc,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12.5,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _GroupHead(l.diagResult),
              Container(
                color: AppColors.surface,
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      _DiagRow(diag: items[i], first: i == 0, l: l),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    if (badCount > 0)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _fixAll,
                          child: Text(
                            l.diagFixAll,
                            style: const TextStyle(
                              color: Color(0xFF141416),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    if (badCount > 0) const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF232326),
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await NativeWidgetService.testAlarm(
                            l.multiTimerTitle,
                            l.diagTestSent,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l.diagTestSent)),
                            );
                          }
                        },
                        child: Text(
                          l.diagTestAlarm,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.diagTestNote,
                      style: TextStyle(
                        color: AppColors.faint,
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Diag {
  final bool ok;
  final String title;
  final String okDesc;
  final String badDesc;
  final Future<bool> Function() fix;
  const _Diag({
    required this.ok,
    required this.title,
    required this.okDesc,
    required this.badDesc,
    required this.fix,
  });
}

class _DiagRow extends StatelessWidget {
  final _Diag diag;
  final bool first;
  final AppLocalizations l;
  const _DiagRow({required this.diag, required this.first, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          top: first
              ? BorderSide.none
              : const BorderSide(color: Color(0xFF232326)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (diag.ok ? AppColors.swGreen : AppColors.danger).withAlpha(
                0x26,
              ),
            ),
            child: Icon(
              diag.ok ? Icons.check : Icons.priority_high,
              size: 13,
              color: diag.ok ? AppColors.swGreen : AppColors.danger,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diag.title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  diag.ok ? diag.okDesc : diag.badDesc,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (!diag.ok) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => diag.fix(),
              child: Text(
                '${l.diagFix} ›',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GroupHead extends StatelessWidget {
  final String text;
  const _GroupHead(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 9),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        color: AppColors.faint,
        fontSize: 12,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
