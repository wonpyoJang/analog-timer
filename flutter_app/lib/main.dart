import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme/app_theme.dart';
import 'features/timer/bloc/timer_bloc.dart';
import 'features/stopwatch/bloc/stopwatch_bloc.dart';
import 'home_screen.dart';

void main() {
  runApp(const AnalogTimerApp());
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
