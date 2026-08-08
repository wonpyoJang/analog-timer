import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/haptic_service.dart';
import '../../../theme/app_theme.dart';
import '../bloc/multi_timer_bloc.dart';
import '../bloc/multi_timer_event.dart';
import '../bloc/multi_timer_state.dart';
import '../models/countdown_timer.dart';

String _fmtClock(int ms) {
  final total = (ms / 1000).ceil();
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

/// 풀스크린 요리 알람(요리 시안 §1·§2) — 색+이름이 화면의 절반, +1:00/+5:00
/// 원탭, 확인 전까지 재알림. 동시 완료는 카드 스택(가장 오래 방치가 전면).
class AlarmScreen extends StatelessWidget {
  final MultiTimerBloc bloc;
  const AlarmScreen({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<MultiTimerBloc, MultiTimerState>(
        listener: (context, state) {
          // 모든 완료가 확인되면 자동 닫힘.
          if (!state.timers.any((t) => t.done && !t.acked)) {
            Navigator.of(context).maybePop();
          }
        },
        builder: (context, state) {
          final ringing = state.timers.where((t) => t.done && !t.acked).toList()
            ..sort((a, b) => a.doneAtMs.compareTo(b.doneAtMs)); // 오래 방치 우선
          if (ringing.isEmpty) return const SizedBox.shrink();
          final front = ringing.first;
          final idx = state.timers.indexWhere((t) => t.id == front.id);
          final color = AppColors
              .segColors[(idx < 0 ? 0 : idx) % AppColors.segColors.length];
          final running = state.timers.where((t) => t.running).toList();
          final agoMin =
              ((DateTime.now().millisecondsSinceEpoch - front.doneAtMs) / 60000)
                  .floor();

          return Scaffold(
            backgroundColor: AppColors.bg,
            body: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -1),
                  radius: 1.2,
                  colors: [color.withAlpha(0x2E), AppColors.bg],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                  child: Column(
                    children: [
                      Text(
                        ringing.length > 1
                            ? l.alarmMultiDone(ringing.length)
                            : l.alarmDoneTitle,
                        style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // 대형 링 — 00:00 + 원래 duration
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withAlpha(0x59),
                                    blurRadius: 48,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 220,
                              height: 220,
                              child: CircularProgressIndicator(
                                value: 1,
                                strokeWidth: 10,
                                valueColor: AlwaysStoppedAnimation(color),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '00:00',
                                  style: TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 44,
                                    fontWeight: FontWeight.w700,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l.alarmOf(_fmtClock(front.totalMs)),
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              front.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        front.extendCount > 0
                            ? l.alarmExtended(front.extendCount)
                            : l.alarmAgoMin(agoMin, agoMin + 1),
                        style: TextStyle(color: AppColors.muted, fontSize: 14),
                      ),
                      const Spacer(),
                      // 스택: 다음 완료 카드(§2 — 일괄 확인 없음)
                      if (ringing.length > 1)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF232326),
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ringing[1].name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                l.alarmNextUp,
                                style: TextStyle(
                                  color: AppColors.faint,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // +1:00 / +5:00 — 연장 = 확인으로 간주, 러닝 복귀
                      Row(
                        children: [
                          _QuickBtn(
                            label: '+1:00',
                            onTap: () {
                              HapticService.instance.light();
                              bloc.add(MtExtend(front.id, 60000));
                            },
                          ),
                          const SizedBox(width: 10),
                          _QuickBtn(
                            label: '+5:00',
                            onTap: () {
                              HapticService.instance.light();
                              bloc.add(MtExtend(front.id, 5 * 60000));
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // 확인 — 슬라이드 대신 대형 버튼(오탭 방지는 높이로)
                      SizedBox(
                        width: double.infinity,
                        height: 62,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () {
                            HapticService.instance.impact();
                            bloc.add(MtAck(front.id));
                          },
                          child: Text(
                            l.alarmAck,
                            style: const TextStyle(
                              color: Color(0xFF141416),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l.alarmRealarmNote,
                        style: TextStyle(color: AppColors.faint, fontSize: 12),
                      ),
                      // 계속 진행 중 목록(§2 하단)
                      if (running.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const Divider(height: 1, color: Color(0xFF1F1F22)),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l.alarmStillRunning,
                            style: TextStyle(
                              color: AppColors.faint,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        for (final t in running.take(2))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.segColors[state.timers
                                                .indexWhere(
                                                  (x) => x.id == t.id,
                                                ) %
                                            AppColors.segColors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    t.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text(
                                  _fmtClock(t.remainMs),
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Material(
      color: const Color(0xFF232326),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
