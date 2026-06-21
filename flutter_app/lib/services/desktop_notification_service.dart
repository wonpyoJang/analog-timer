import 'package:local_notifier/local_notifier.dart';
import 'desktop_service.dart';

/// 데스크톱 토스트 알림(local_notifier) 래퍼.
/// Windows 에선 액션센터 토스트로 표시된다.
class DesktopNotificationService {
  static bool _ready = false;

  static Future<void> init() async {
    if (!isDesktop) return;
    await localNotifier.setup(appName: 'Analog Timer');
    _ready = true;
  }

  static Future<void> notify(String title, String body) async {
    if (!_ready) return;
    final notification = LocalNotification(title: title, body: body);
    await notification.show();
  }
}
