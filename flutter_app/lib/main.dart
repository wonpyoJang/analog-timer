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
import 'splash_screen.dart';
import 'overlay/overlay_widget.dart';
import 'overlay/desktop_overlay.dart';
import 'services/desktop_service.dart';
import 'services/desktop_notification_service.dart';
import 'services/desktop_overlay_service.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  if (isDesktop) {
    await windowManager.ensureInitialized();
    final overlayArgs = await _overlayArgsIfSubWindow();
    if (overlayArgs != null) {
      await runDesktopOverlay(overlayArgs);
      return;
    }
  }

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
void overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final tag = await PersistenceService.loadLocale();
  final locale = tag != null ? parseLocaleTag(tag) : null;
  runApp(OverlayApp(initialLocale: locale));
}

/// 오버레이 전용 앱 — shareData로 locale을 동적 변경 가능
class OverlayApp extends StatefulWidget {
  final Locale? initialLocale;
  const OverlayApp({this.initialLocale});

  static OverlayAppState? _instance;
  static void updateLocale(Locale? locale) => _instance?._apply(locale);

  @override
  State<OverlayApp> createState() => OverlayAppState();
}

class OverlayAppState extends State<OverlayApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    OverlayApp._instance = this;
  }

  void _apply(Locale? locale) {
    if (mounted) setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      home: const TimerOverlayWidget(),
    );
  }
}

/// 'en' / 'ko' / 'zh_Hant' 같은 태그를 Locale로 파싱.
Locale parseLocaleTag(String tag) {
  final parts = tag.split(RegExp('[_-]'));
  if (parts.length >= 2) {
    return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
  }
  return Locale(parts[0]);
}

class AnalogTimerApp extends StatefulWidget {
  const AnalogTimerApp({super.key});

  /// 자식 위젯에서 언어를 바꿀 때 호출 (null = 시스템 기본값).
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
        home: const SplashScreen(),
      ),
    );
  }
}
