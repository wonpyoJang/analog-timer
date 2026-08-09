import 'dart:async';
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
import 'overlay/overlay_coordinator.dart';
import 'services/desktop_service.dart';
import 'services/desktop_notification_service.dart';
import 'services/desktop_overlay_service.dart';
import 'services/telemetry_service.dart';
import 'services/anr_vitals_service.dart';
import 'services/sync_service.dart';
import 'services/hotkey_service.dart';
import 'services/tts_service.dart';
import 'services/text_scale_service.dart';
import 'services/haptic_service.dart';
import 'services/sound_service.dart';
import 'services/care_service.dart';
import 'services/list_display_service.dart';
import 'features/multi_timer/ai/timer_ai_service.dart';
import 'services/overlay_settings_service.dart';
import 'services/deep_link_service.dart';
import 'services/deep_link_router.dart';
import 'services/colorblind_service.dart';
import 'services/high_contrast_service.dart';
import 'widgets/desktop_title_bar.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  if (isDesktop) {
    await windowManager.ensureInitialized();
    final overlayArgs = await _overlayArgsIfSubWindow();
    if (overlayArgs != null) {
      // 서브엔진(위젯)의 Dart 에러도 텔레메트리에 잡히도록 핸들러 설치 —
      // 미설치 시 위젯 쪽 에러가 전량 미탐되어 '위젯이 검게 죽는' 원인을 놓친다.
      _installErrorHandlers();
      await runDesktopOverlay(overlayArgs);
      return;
    }
  }

  await DesktopService.bootstrapWindow();
  await DesktopNotificationService.init();
  await DesktopService.instance.init();
  await DesktopOverlayService.instance.init();
  await TelemetryService.instance.init();
  await TelemetryService.instance.loadConsentFlag(); // 동의 notifier 초기화(전 플랫폼)
  unawaited(AnrVitalsService.instance.init()); // Android ANR-free 지표(백그라운드)
  await SyncService.instance.init();
  await TtsService.instance.init();
  await TextScaleService.instance.init();
  await HapticService.instance.init();
  await SoundService.instance.init();
  await CareService.instance.init();
  await ListDisplayService.instance.init();
  await TimerAiService.instance.load(); // AI 폴백 플래그(기본 OFF, 다음 릴리스)
  await OverlaySettingsService.instance.init();
  await ColorblindService.instance.init();
  await HighContrastService.instance.init();
  await OverlayCoordinator.instance.init();
  await HotkeyService.instance.init();
  // 음성 딥링크(§3·§7) — 라우터에 연결 후 콜드 스타트 초기 링크 흡수.
  DeepLinkService.instance.onAction = DeepLinkRouter.instance.handle;
  await DeepLinkService.instance.init();
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
    // 텔레메트리 미지원 플랫폼(모바일)에서 true 를 반환하면 uncaught 비동기
    // 에러가 콘솔/logcat 출력조차 없이 소멸한다 — 수집 안 되면 기본 처리로.
    return TelemetryService.instance.supported;
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
void overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await TextScaleService.instance.init();
  await ColorblindService.instance.init();
  await HighContrastService.instance.init();
  final tag = await PersistenceService.loadLocale();
  final locale = tag != null ? parseLocaleTag(tag) : null;
  runApp(OverlayApp(initialLocale: locale));
}

/// 사용자 지정 글씨 배율을 시스템 배율에 곱해 앱 전역에 적용 — 저시력 접근성.
/// OS 접근성 배율을 존중(곱)하면서 최종값을 클램프해 레이아웃 파손을 막는다.
Widget withUserTextScale(BuildContext context, Widget? child) {
  final base = child ?? const SizedBox.shrink();
  // 고대비 토글 변경 시 전체 리빌드 → AppColors.muted/faint getter 재평가.
  return ValueListenableBuilder<bool>(
    valueListenable: HighContrastService.instance.enabledListenable,
    builder: (context, _, _) => ValueListenableBuilder<double>(
      valueListenable: TextScaleService.instance.scaleListenable,
      builder: (context, userScale, _) {
        final mq = MediaQuery.of(context);
        final system = mq.textScaler.scale(1.0); // 시스템 배율(1.0 기준 배수)
        final effective = (system * userScale).clamp(0.5, 2.0);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(effective)),
          child: base,
        );
      },
    ),
  );
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
      // 오버레이 엔진 첫 프레임이 흰색으로 번쩍이지 않도록 앱/테마 배경을 투명하게.
      // (home 의 TimerOverlayWidget 는 이미 투명 Material 이지만, MaterialApp 기본
      //  배경/scaffold 가 흰색이라 초기 프레임에 흰 플래시가 보였다.)
      color: Colors.transparent,
      theme: ThemeData(scaffoldBackgroundColor: Colors.transparent),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      builder: withUserTextScale,
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

  /// 원격 pull 로 받은 locale 반영 — 저장까지만, 다시 push 하지 않는다.
  static void setRemoteLocale(BuildContext context, Locale? locale) {
    context.findAncestorStateOfType<_AnalogTimerAppState>()?.applyRemoteLocale(
      locale,
    );
  }

  @override
  State<AnalogTimerApp> createState() => _AnalogTimerAppState();
}

class _AnalogTimerAppState extends State<AnalogTimerApp> {
  Locale? _locale;
  bool _applyingRemoteLocale = false;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final tag = await PersistenceService.loadLocale();
    if (tag != null && mounted) setState(() => _locale = parseLocaleTag(tag));
  }

  void _apply(Locale? locale, {bool remote = false}) {
    setState(() => _locale = locale);
    final tag = locale == null
        ? null
        : (locale.scriptCode != null
              ? '${locale.languageCode}_${locale.scriptCode}'
              : locale.languageCode);
    PersistenceService.saveLocale(tag);
    // 원격 적용이면 다시 push 하지 않는다(에코 방지).
    if (remote || _applyingRemoteLocale) return;
    _pushSettings(tag);
  }

  Future<void> _pushSettings(String? localeTag) async {
    if (!SyncService.instance.connected) return;
    final overlayOn = await PersistenceService.loadOverlayOn();
    final hidden = await PersistenceService.loadHiddenDefaults();
    unawaited(
      SyncService.instance.pushSettings({
        'locale': localeTag,
        'overlay_on': overlayOn,
        'hidden_defaults': hidden,
      }),
    );
  }

  /// HomeScreen 의 onSettings 콜백에서 원격 locale 을 반영할 때 사용.
  void applyRemoteLocale(Locale? locale) {
    _applyingRemoteLocale = true;
    _apply(locale, remote: true);
    _applyingRemoteLocale = false;
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
        // 커스텀 타이틀바(데스크톱) + 사용자 글씨 배율을 모든 라우트 위에.
        builder: (context, child) =>
            withUserTextScale(context, withDesktopTitleBar(context, child)),
        home: const SplashScreen(),
      ),
    );
  }
}
