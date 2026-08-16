import 'package:flutter/services.dart';
import 'platform_info.dart';

/// iOS 홈 화면 위젯(HomeTimerWidget) 데이터 브리지.
/// 앱이 타이머/스톱워치 상태를 앱 그룹에 기록하고 WidgetKit 타임라인을 리로드한다.
/// 카운트다운은 위젯의 Text(timerInterval:)가 처리하므로 상태 변경 시에만 호출.
class HomeWidgetService {
  static const _channel = MethodChannel('analog_timer/home_widget');

  static Future<void> update(Map<String, dynamic> data) async {
    if (!isIOS) return;
    try {
      await _channel.invokeMethod('update', data);
    } catch (_) {}
  }
}
