import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_theme.dart';
import '../bloc/stopwatch_bloc.dart';
import '../bloc/stopwatch_event.dart';
import '../bloc/stopwatch_state.dart';

class StopwatchControls extends StatelessWidget {
  const StopwatchControls({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StopwatchBloc, StopwatchState>(
      builder: (context, state) {
        return Column(
          children: [
            const Text(
              '⏲ STOPWATCH',
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
                _Btn(
                  label: state.running ? 'PAUSE' : 'START',
                  primary: true,
                  color: AppColors.swGreen,
                  onTap: () => context.read<StopwatchBloc>().add(
                    const StopwatchToggle(),
                  ),
                ),
                _Btn(
                  label: 'LAP',
                  onTap: () =>
                      context.read<StopwatchBloc>().add(const StopwatchLap()),
                ),
                _Btn(
                  label: 'RST',
                  danger: true,
                  onTap: () =>
                      context.read<StopwatchBloc>().add(const StopwatchReset()),
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
  final bool primary;
  final bool danger;
  final Color? color;
  final VoidCallback? onTap;

  const _Btn({
    required this.label,
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
    return GestureDetector(
      onTap: onTap,
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
