import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:window_manager/window_manager.dart';
import 'l10n/app_localizations.dart';
import 'services/persistence_service.dart';
import 'theme/app_theme.dart';
import 'features/timer/bloc/timer_bloc.dart';
import 'features/stopwatch/bloc/stopwatch_bloc.dart';
import 'home_screen.dart';
import 'overlay/overlay_widget.dart';
import 'overlay/desktop_overlay.dart';
import 'services/desktop_service.dart';
import 'services/desktop_notification_service.dart';
import 'services/desktop_overlay_service.dart';
import 'services/telemetry_service.dart';
import 'services/sync_service.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  // 로케일별 날짜·요일 포맷용 심볼 초기화(메인/오버레이 진입점 모두 커버).
  await initializeDateFormatting();

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
  await TelemetryService.instance.init();
  await SyncService.instance.init();
  _installErrorHandlers();
  runApp(const AnalogTimerApp());
}

/// Dart 레벨 에러(위젯 빌드/프레임워크/비동기)를 텔레메트리로 전송.
/// 네이티브 크래시는 여기서 못 잡으며, 다음 실행의 비정상종료 감지가 담당한다.
void _installErrorHandlers() {
  final prev = FlutterError.onError;
  FlutterError.onError = (details) {
    prev?.call(details); // 콘솔 출력 등 기본 동작 보존
    TelemetryService.instance.reportDartError(details.exception, details.stack);
  };
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    TelemetryService.instance.reportDartError(error, stack);
    return true;
  };
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

/// 'en' / 'ko' / 'zh_Hant' 같은 태그를 Locale 로 파싱.
Locale parseLocaleTag(String tag) {
  final parts = tag.split(RegExp('[_-]'));
  if (parts.length >= 2) {
    return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
  }
  return Locale(parts[0]);
}

class AnalogTimerApp extends StatefulWidget {
  const AnalogTimerApp({super.key});

  /// 자식 위젯에서 언어를 바꿀 때 호출(null=시스템 기본값).
  static void setLocale(BuildContext context, Locale? locale) {
    context.findAncestorStateOfType<_AnalogTimerAppState>()?._apply(locale);
  }

  @override
  State<AnalogTimerApp> createState() => _AnalogTimerAppState();
}

class _AnalogTimerAppState extends State<AnalogTimerApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final tag = await PersistenceService.loadLocale();
    if (tag != null && mounted) setState(() => _locale = parseLocaleTag(tag));
  }

  void _apply(Locale? locale) {
    setState(() => _locale = locale);
    // scriptCode 가 있으면 'zh_Hant' 형태로 저장.
    final tag = locale == null
        ? null
        : (locale.scriptCode != null
              ? '${locale.languageCode}_${locale.scriptCode}'
              : locale.languageCode);
    PersistenceService.saveLocale(tag);
  }

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
        locale: _locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomeScreen(),
      ),
    );
  }
}
