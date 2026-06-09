import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme/app_theme.dart';
import 'features/timer/bloc/timer_bloc.dart';
import 'features/stopwatch/bloc/stopwatch_bloc.dart';
import 'home_screen.dart';
import 'overlay/overlay_widget.dart';
import 'services/desktop_service.dart';
import 'services/desktop_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 데스크톱(Windows/macOS/Linux): 창 크기 고정 + 트레이 + 알림 초기화.
  // 모바일에선 아래 호출들이 모두 즉시 no-op 으로 빠진다.
  await DesktopService.bootstrapWindow();
  await DesktopNotificationService.init();
  await DesktopService.instance.init();
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
