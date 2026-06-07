import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_theme.dart';
import '../bloc/timer_bloc.dart';
import '../bloc/timer_event.dart';
import '../bloc/timer_state.dart';

class TimerControls extends StatefulWidget {
  const TimerControls({super.key});

  @override
  State<TimerControls> createState() => _TimerControlsState();
}

class _TimerControlsState extends State<TimerControls> {
  bool _nextCounting = false;
  double _nextPct = 0;
  static const _nextDelay = Duration(seconds: 2);
  DateTime? _nextStart;

  void _startNextCountdown() {
    setState(() {
      _nextCounting = true;
      _nextPct = 0;
      _nextStart = DateTime.now();
    });
    _animNext();
  }

  void _cancelNext() {
    setState(() {
      _nextCounting = false;
      _nextPct = 0;
      _nextStart = null;
    });
  }

  void _animNext() {
    if (!_nextCounting || _nextStart == null) return;
    final elapsed = DateTime.now().difference(_nextStart!);
    final pct = (elapsed.inMilliseconds / _nextDelay.inMilliseconds).clamp(
      0.0,
      1.0,
    );
    setState(() => _nextPct = pct);
    if (pct >= 1.0) {
      _cancelNext();
      context.read<TimerBloc>().add(const TimerNext());
      return;
    }
    Future.delayed(const Duration(milliseconds: 16), _animNext);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        final isRunning = state.status == TimerStatus.running;
        final isIdle =
            state.status == TimerStatus.idle ||
            state.status == TimerStatus.done;

        return Column(
          children: [
            const Text(
              '⏱ TIMER',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                // START / PAUSE / RESUME
                _Btn(
                  label: isRunning
                      ? 'RUNNING…'
                      : (state.status == TimerStatus.paused
                            ? 'RESUME'
                            : 'START'),
                  enabled: !isRunning,
                  primary: true,
                  color: AppColors.timerOrange,
                  onTap: isRunning
                      ? null
                      : () => context.read<TimerBloc>().add(const TimerStart()),
                ),
                _Btn(
                  label: 'PAUSE',
                  enabled: isRunning,
                  onTap: isRunning
                      ? () => context.read<TimerBloc>().add(const TimerPause())
                      : null,
                ),
                // NEXT with countdown animation
                _NextBtn(
                  counting: _nextCounting,
                  pct: _nextPct,
                  enabled: !isIdle,
                  onTap: !isIdle
                      ? () {
                          if (_nextCounting) {
                            _cancelNext();
                          } else {
                            _startNextCountdown();
                          }
                        }
                      : null,
                ),
                _Btn(
                  label: 'RST',
                  danger: true,
                  onTap: () {
                    _cancelNext();
                    context.read<TimerBloc>().add(const TimerReset());
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool primary;
  final bool danger;
  final Color? color;
  final VoidCallback? onTap;

  const _Btn({
    required this.label,
    this.enabled = true,
    this.primary = false,
    this.danger = false,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.surface;
    Color fg = AppColors.text;
    Color border = AppColors.border;
    if (primary && color != null) {
      bg = color!;
      fg = Colors.white;
      border = color!;
    } else if (danger) {
      fg = AppColors.danger;
      border = const Color(0xFF554040);
    }
    if (!enabled) {
      bg = bg.withAlpha(0x88);
      fg = fg.withAlpha(0x88);
    }

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(color: fg, fontSize: 11, letterSpacing: 0.8),
        ),
      ),
    );
  }
}

class _NextBtn extends StatelessWidget {
  final bool counting;
  final double pct;
  final bool enabled;
  final VoidCallback? onTap;
  const _NextBtn({
    required this.counting,
    required this.pct,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E38),
                border: Border.all(color: AppColors.accent),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '▶ 다음',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            if (counting)
              Positioned.fill(
                child: FractionallySizedBox(
                  widthFactor: pct,
                  alignment: Alignment.centerLeft,
                  child: Container(color: AppColors.accent.withAlpha(0xAA)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
