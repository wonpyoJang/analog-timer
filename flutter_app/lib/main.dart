import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme/app_theme.dart';
import 'features/timer/bloc/timer_bloc.dart';
import 'features/stopwatch/bloc/stopwatch_bloc.dart';
import 'home_screen.dart';
import 'overlay/overlay_widget.dart';

void main() {
  runApp(const AnalogTimerApp());
}

// 오버레이 isolate 진입점 — flutter_overlay_window가 별도로 호출
@pragma('vm:entry-point')
void overlayMain() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TimerOverlayWidget(),
    ),
  );
}

class AnalogTimerApp extends StatelessWidget {
  const AnalogTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TimerBloc()),
        BlocProvider(create: (_) => StopwatchBloc()),
      ],
      child: MaterialApp(
        title: 'Analog Timer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const HomeScreen(),
      ),
    );
  }
}
