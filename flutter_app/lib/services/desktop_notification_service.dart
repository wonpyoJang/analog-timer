import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'desktop_service.dart';
import 'platform_info.dart';

/// 데스크톱 토스트 알림 래퍼.
/// - Windows/Linux: local_notifier (Windows 액션센터 토스트)
/// - macOS: flutter_local_notifications(UNUserNotifications) — local_notifier 는
///   deprecated NSUserNotification 을 써 최신 macOS 에서 안 뜬다.
///
/// 설정 토글(기본 ON)로 전체 on/off — 구간 전환·완료 알림이 방해가 되는
/// 사용자(회의 중 화면 공유 등)를 위해. prefs 에 저장된다.
class DesktopNotificationService {
  static bool _ready = false;
  static final _fln = FlutterLocalNotificationsPlugin();
  static int _macId = 0;

  static const _kEnabled = 'desktop_notifications_enabled';
  static final ValueNotifier<bool> enabledListenable = ValueNotifier<bool>(
    true,
  );
  static bool get enabled => enabledListenable.value;

  static Future<void> init() async {
    if (!isDesktop) return;
    try {
      final p = await SharedPreferences.getInstance();
      enabledListenable.value = p.getBool(_kEnabled) ?? true;
    } catch (_) {}
    if (isMacOS) {
      const darwin = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestSoundPermission: true,
        requestBadgePermission: false,
      );
      await _fln.initialize(const InitializationSettings(macOS: darwin));
    } else {
      await localNotifier.setup(appName: 'Analog Timer');
    }
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
    if (isMacOS) {
      _macId = (_macId + 1) % 100000;
      await _fln.show(
        _macId,
        title,
        body,
        const NotificationDetails(
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBanner: true,
            presentSound: true,
          ),
        ),
      );
    } else {
      final notification = LocalNotification(title: title, body: body);
      await notification.show();
    }
  }
}
