import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'features/timer/bloc/timer_bloc.dart';
import 'features/timer/bloc/timer_state.dart';
import 'features/stopwatch/bloc/stopwatch_bloc.dart';
import 'features/stopwatch/bloc/stopwatch_state.dart';
import 'features/timer/widgets/timer_controls.dart';
import 'features/timer/widgets/segment_editor.dart';
import 'features/stopwatch/widgets/stopwatch_controls.dart';
import 'widgets/clock_painter.dart';
import 'widgets/bottom_panels.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 16ms tick for smooth second-hand animation
    _clockTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  // Title
                  Text(
                    '⏱ ANALOG TIMER',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 34,
                      letterSpacing: 4,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Clock canvas
                  _ClockWidget(now: _now),
                  const SizedBox(height: 8),

                  // Legend
                  Wrap(
                    spacing: 16,
                    children: [
                      _Legend(
                        color: AppColors.timerOrange,
                        label: '타이머 — 안쪽 나선',
                      ),
                      _Legend(color: AppColors.swGreen, label: '스톱워치 — 바깥 링'),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Progress bar
                  _ProgressBar(),
                  const SizedBox(height: 20),

                  // Dual controls
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(child: TimerControls()),
                      SizedBox(width: 16),
                      Expanded(child: StopwatchControls()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Segment editor
                  const SegmentEditor(),
                  const SizedBox(height: 12),

                  // Bottom panels
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(child: LapList()),
                      SizedBox(width: 10),
                      Expanded(child: TimerLog()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClockWidget extends StatelessWidget {
  final DateTime now;
  const _ClockWidget({required this.now});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, timerState) {
        return BlocBuilder<StopwatchBloc, StopwatchState>(
          builder: (context, swState) {
            return Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: CustomPaint(
                    painter: ClockPainter(
                      timerState: timerState,
                      swState: swState,
                      now: now,
                    ),
                  ),
                ),
                // Center overlay: segment name + remaining time
                _CenterInfo(timerState: timerState, swState: swState),
              ],
            );
          },
        );
      },
    );
  }
}

class _CenterInfo extends StatelessWidget {
  final TimerState timerState;
  final StopwatchState swState;
  const _CenterInfo({required this.timerState, required this.swState});

  String _fmtMs(int ms) {
    final total = (ms.clamp(0, ms) / 1000).truncate();
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final seg = timerState.currentSegment;
    final isActive =
        timerState.status == TimerStatus.running ||
        timerState.status == TimerStatus.paused;

    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive && seg != null) ...[
            Text(
              seg.name,
              style: GoogleFonts.bebasNeue(
                fontSize: 16,
                letterSpacing: 1.5,
                color: AppColors.timerOrangeDark,
              ),
            ),
            Text(
              _fmtMs(timerState.segRemainMs),
              style: GoogleFonts.bebasNeue(
                fontSize: 48,
                color: AppColors.timerOrangeDark,
                letterSpacing: 1,
              ),
            ),
          ] else ...[
            Text(
              '--:--',
              style: GoogleFonts.bebasNeue(
                fontSize: 48,
                color: AppColors.timerOrangeDark.withAlpha(0x44),
                letterSpacing: 1,
              ),
            ),
          ],
          if (swState.running || swState.elapsedMs > 0)
            Text(
              '⏲ ${_fmtMs(swState.elapsedMs)}',
              style: GoogleFonts.bebasNeue(
                fontSize: 15,
                color: AppColors.swGreen,
                letterSpacing: 1,
              ),
            ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        final pct = state.totalMs > 0
            ? (state.elapsedMs / state.totalMs).clamp(0.0, 1.0)
            : 0.0;
        final color = state.currentSegment?.color ?? AppColors.timerOrange;
        return Container(
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(99),
          ),
          child: FractionallySizedBox(
            widthFactor: pct,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        );
      },
    );
  }
}
