import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';
import 'theme/app_theme.dart';
import 'features/timer/bloc/timer_bloc.dart';
import 'features/stopwatch/bloc/stopwatch_bloc.dart';
import 'home_screen.dart';
import 'overlay/overlay_widget.dart';
import 'overlay/desktop_overlay.dart';
import 'services/desktop_service.dart';
import 'services/desktop_notification_service.dart';
import 'services/desktop_overlay_service.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 데스크톱: 이 엔진이 오버레이 서브윈도우로 띄워졌는지 판별.
  if (isDesktop) {
    await windowManager.ensureInitialized();
    final overlayArgs = await _overlayArgsIfSubWindow();
    if (overlayArgs != null) {
      await runDesktopOverlay(overlayArgs);
      return;
    }
  }

  // 메인 윈도우: 창 크기 고정 + 트레이 + 알림 + 오버레이 제어 초기화.
  // 모바일에선 아래 호출들이 모두 즉시 no-op 으로 빠진다.
  await DesktopService.bootstrapWindow();
  await DesktopNotificationService.init();
  await DesktopService.instance.init();
  await DesktopOverlayService.instance.init();
  runApp(const AnalogTimerApp());
}

/// 현재 엔진이 desktop_multi_window 서브윈도우(오버레이)면 그 인자 맵을, 아니면 null.
Future<Map<String, dynamic>?> _overlayArgsIfSubWindow() async {
  try {
    final controller = await WindowController.fromCurrentEngine();
    if (controller.arguments.isEmpty) return null;
    final data = jsonDecode(controller.arguments) as Map<String, dynamic>;
    return data['role'] == 'overlay' ? data : null;
  } catch (_) {
    return null; // 단일 창 런처 — 메인 윈도우로 진행.
  }
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
