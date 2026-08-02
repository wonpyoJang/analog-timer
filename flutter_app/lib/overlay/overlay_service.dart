import 'dart:convert';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../services/persistence_service.dart';
import '../services/platform_info.dart';
import '../services/text_scale_service.dart';
import '../services/colorblind_service.dart';
import '../services/high_contrast_service.dart';

class OverlayService {
  static Future<bool> get isPermissionGranted async {
    if (!isAndroid) return false;
    return FlutterOverlayWindow.isPermissionGranted();
  }

  static Future<void> requestPermission() async {
    if (!isAndroid) return;
    await FlutterOverlayWindow.requestPermission();
  }

  static Future<void> show({int screenWidthDp = 400}) async {
    if (!isAndroid) return;
    if (!await FlutterOverlayWindow.isPermissionGranted()) return;

    final expandedW = (screenWidthDp * 0.42).round().clamp(150, screenWidthDp);
    final expandedH = expandedW + 56;

    if (!await FlutterOverlayWindow.isActive()) {
      // 서비스가 없는 경우 — showOverlay로 생성 후 엔진 초기화 대기
      await FlutterOverlayWindow.showOverlay(
        height: expandedH,
        width: expandedW,
        alignment: OverlayAlignment.topCenter,
        positionGravity: PositionGravity.none,
        enableDrag: true,
        flag: OverlayFlag.focusPointer,
        overlayTitle: 'Analog Timer',
      );
      // 오버레이 Flutter 엔진이 ready 될 때까지 대기 (저사양 기기 대응)
      await Future.delayed(const Duration(milliseconds: 800));
    }

    // 길게 누르기 온보딩 — 편집 모드 미사용자에 한해 최대 3회 노출
    final hintCount = await PersistenceService.loadOverlayHintCount();
    final showHint = hintCount < 3;
    if (showHint) {
      await PersistenceService.saveOverlayHintCount(hintCount + 1);
    }

    // isActive 여부에 관계없이 항상 'show' 전달
    // — 이전 세션에서 서비스가 살아있지만 엔진이 죽은 경우(레이스)도 커버
    await FlutterOverlayWindow.shareData(
      jsonEncode({
        'command': 'show',
        'screenWidthDp': screenWidthDp,
        'hintLongPress': showHint,
      }),
    );
  }

  static Future<void> hide() async {
    if (!isAndroid) return;
    if (!await FlutterOverlayWindow.isActive()) return;
    // closeOverlay 금지 — 재오픈 시 JNI SIGSEGV 유발
    // 오버레이 위젯에 hide 명령 전달 → 위젯이 resizeOverlay(1,1) 호출
    await FlutterOverlayWindow.shareData(jsonEncode({'command': 'hide'}));
  }

  static Future<void> updateState({
    required bool timerActive,
    required bool timerRunning,
    required String timerLabel,
    required String timerRemain,
    bool timerDone = false,
    required bool swActive,
    required bool swRunning,
    required String swElapsed,
    int timerColorValue = 0xFFE07A52,
    double timerFrac = 0.0,
    bool ending = false,
    int segRemainMs = 0,
    int swElapsedMs = 0,
    double? swStartAngleRad,
    int screenWidthDp = 400,
    int screenHeightDp = 800,
    String? localeTag,
    bool batteryLow = false,
    int batteryLevel = -1,
  }) async {
    if (!isAndroid) return;
    await FlutterOverlayWindow.shareData(
      jsonEncode({
        'timerActive': timerActive,
        'timerRunning': timerRunning,
        'timerLabel': timerLabel,
        'timerRemain': timerRemain,
        'timerDone': timerDone,
        'swActive': swActive,
        'swRunning': swRunning,
        'swElapsed': swElapsed,
        'timerColorValue': timerColorValue,
        'timerFrac': timerFrac,
        'ending': ending,
        'segRemainMs': segRemainMs,
        'swElapsedMs': swElapsedMs,
        'swStartAngleRad': swStartAngleRad,
        'screenWidthDp': screenWidthDp,
        'screenHeightDp': screenHeightDp,
        if (localeTag != null) 'localeTag': localeTag,
        'batteryLow': batteryLow,
        'batteryLevel': batteryLevel,
        // 인앱 글씨 배율 라이브 전파 — 오버레이 isolate가 반영
        'textScale': TextScaleService.instance.scale,
        // 색맹 모드 라이브 전파
        'colorblind': ColorblindService.instance.enabled,
        // 고대비 모드 라이브 전파
        'highContrast': HighContrastService.instance.enabled,
      }),
    );
  }
}
