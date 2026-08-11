import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

/// 예약/즉시 로컬 알림 래퍼(물 알림·루틴 알람 공통 토대).
/// zonedSchedule 로 앱이 꺼져 있어도 정시에 울린다(백그라운드 전달).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool get isSupported => defaultTargetPlatform == TargetPlatform.android;

  static const waterChannel = 'water_reminder';
  static const routineChannel = 'routine_alarm';

  Future<void> init() async {
    if (_ready || !isSupported) return;
    tzdata.initializeTimeZones();
    _setLocalByOffset();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
    final impl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await impl?.createNotificationChannel(
      const AndroidNotificationChannel(
        waterChannel,
        '물 마시기 알림',
        description: '물 마실 시간 알림',
        importance: Importance.defaultImportance,
      ),
    );
    await impl?.createNotificationChannel(
      const AndroidNotificationChannel(
        routineChannel,
        '루틴 알람',
        description: '루틴 시작·단계 알람',
        importance: Importance.high,
      ),
    );
    _ready = true;
  }

  /// IANA 이름 조회 플러그인 없이 로컬 타임존 설정 — 지금 기기 오프셋과 같은 오프셋을
  /// 가진 tz 로케이션을 찾아 tz.local 로 지정. 못 찾으면 UTC 유지(스케줄 어긋날 수 있음).
  void _setLocalByOffset() {
    final offset = DateTime.now().timeZoneOffset;
    for (final loc in tz.timeZoneDatabase.locations.values) {
      if (tz.TZDateTime.now(loc).timeZoneOffset == offset) {
        tz.setLocalLocation(loc);
        return;
      }
    }
    if (kDebugMode) debugPrint('[notif] no tz match for $offset → UTC');
  }

  /// 알림 권한(13+) + 정확 알람 권한 요청. granted 여부 반환.
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    if (!_ready) await init();
    final impl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await impl?.requestNotificationsPermission() ?? false;
    await impl?.requestExactAlarmsPermission();
    return granted;
  }

  Future<void> showNow(
    int id,
    String title,
    String body, {
    bool routine = false,
  }) async {
    if (!isSupported) return;
    if (!_ready) await init();
    await _plugin.show(id, title, body, _details(routine));
  }

  /// [when] 에 알림 예약(앱 종료 시에도 발화). 과거면 예약 안 함.
  Future<void> scheduleAt(
    int id,
    String title,
    String body,
    DateTime when, {
    bool routine = false,
  }) async {
    if (!isSupported) return;
    if (!_ready) await init();
    if (when.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(when, tz.local),
      _details(routine),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel(int id) async {
    if (isSupported) await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    if (isSupported) await _plugin.cancelAll();
  }

  NotificationDetails _details(bool routine) => NotificationDetails(
    android: AndroidNotificationDetails(
      routine ? routineChannel : waterChannel,
      routine ? '루틴 알람' : '물 마시기 알림',
      importance: routine ? Importance.high : Importance.defaultImportance,
      priority: routine ? Priority.high : Priority.defaultPriority,
    ),
  );
}
