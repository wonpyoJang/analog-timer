import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../features/timer/bloc/timer_bloc.dart';
import '../features/timer/bloc/timer_state.dart';
import '../features/stopwatch/bloc/stopwatch_bloc.dart';
import '../features/stopwatch/bloc/stopwatch_state.dart';

String _fmt(int ms) {
  final total = (ms.clamp(0, ms) / 1000).truncate();
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  if (h > 0) {
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

/// 로그 타입을 현재 언어 메시지로 변환.
String _logMsg(AppLocalizations l, TimerLogEntry e) {
  switch (e.type) {
    case TimerLogType.start:
      return l.logStart(e.segName ?? '');
    case TimerLogType.pause:
      return l.logPaused;
    case TimerLogType.reset:
      return l.logReset;
    case TimerLogType.skip:
      return l.logSkipped(e.segName ?? '');
    case TimerLogType.done:
      return l.logDone(e.segName ?? '');
    case TimerLogType.allDone:
      return l.logAllDone;
    case TimerLogType.loop:
      return l.logLoop(e.segName ?? '');
  }
}

class LapList extends StatelessWidget {
  const LapList({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocBuilder<StopwatchBloc, StopwatchState>(
      builder: (context, state) {
        return _Panel(
          title: '⏲ ${l.stopwatchLaps}',
          child: state.laps.isEmpty
              ? Text(
                  l.noLaps,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Column(
                  children: state.laps
                      .asMap()
                      .entries
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l.lapLabel(e.key + 1),
                                style: const TextStyle(
                                  color: AppColors.swGreen,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                _fmt(e.value.lapMs),
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                _fmt(e.value.totalMs),
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }
}

class TimerLog extends StatelessWidget {
  const TimerLog({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        return _Panel(
          title: '⏱ ${l.timerLogTitle}',
          child: state.log.isEmpty
              ? Text(
                  l.noEvents,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Column(
                  children: state.log.reversed
                      .take(20)
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(top: 1, right: 6),
                                decoration: BoxDecoration(
                                  color: Color(e.colorValue),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                '${e.time.hour.toString().padLeft(2, '0')}:'
                                '${e.time.minute.toString().padLeft(2, '0')}:'
                                '${e.time.second.toString().padLeft(2, '0')} ',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 10,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _logMsg(l, e),
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;
  const _Panel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 140),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Flexible(child: SingleChildScrollView(reverse: true, child: child)),
        ],
      ),
    );
  }
}
