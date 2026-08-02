import 'package:flutter/foundation.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'desktop_service.dart';

/// 데스크톱 토스트 알림(local_notifier) 래퍼.
/// Windows 에선 액션센터 토스트로 표시된다.
///
/// 설정 토글(기본 ON)로 전체 on/off — 구간 전환·완료 알림이 방해가 되는
/// 사용자(회의 중 화면 공유 등)를 위해. prefs 에 저장된다.
class DesktopNotificationService {
  static bool _ready = false;

  static const _kEnabled = 'desktop_notifications_enabled';
  static final ValueNotifier<bool> enabledListenable =
      ValueNotifier<bool>(true);
  static bool get enabled => enabledListenable.value;

  static Future<void> init() async {
    if (!isDesktop) return;
    try {
      final p = await SharedPreferences.getInstance();
      enabledListenable.value = p.getBool(_kEnabled) ?? true;
    } catch (_) {}
    await localNotifier.setup(appName: 'Analog Timer');
    _ready = true;
  }

  static Future<void> setEnabled(bool v) async {
    enabledListenable.value = v;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kEnabled, v);
    } catch (_) {}
  }

  static Future<void> notify(String title, String body) async {
    if (!_ready || !enabled) return;
    final notification = LocalNotification(title: title, body: body);
    await notification.show();
  }
}
