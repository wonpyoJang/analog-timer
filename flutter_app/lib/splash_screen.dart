import 'dart:async';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'root_shell.dart';
import 'widgets/clock_painter.dart';
import 'features/timer/bloc/timer_state.dart';
import 'features/stopwatch/bloc/stopwatch_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;
  late final Animation<double> _fadeAnim;
  late final Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();

    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fade, curve: Curves.easeOut);

    _clockTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });

    Future.delayed(const Duration(milliseconds: 2200), _navigateHome);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 시스템 "동작 줄이기" — 페이드 인을 건너뛰고 즉시 표시(광과민/멀미 대응).
    if (MediaQuery.of(context).disableAnimations && _fade.value < 1.0) {
      _fade.value = 1.0;
    }
  }

  void _navigateHome() {
    if (!mounted) return;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: reduceMotion ? 0 : 500),
        pageBuilder: (_, _, _) => const RootShell(),
        transitionsBuilder: (_, anim, _, child) =>
            reduceMotion ? child : FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아날로그 시계 (현재 시각 live)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withAlpha(0x33),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: ClockPainter(
                    timerState: TimerState.initial(),
                    swState: StopwatchState.initial(),
                    now: _now,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // 앱 이름
              const Text(
                'ANALOG TIMER',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 5,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Focus · Time · Flow',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
