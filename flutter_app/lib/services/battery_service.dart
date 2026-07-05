import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 배터리 상태를 주기적으로 감시하고 저배터리 경고를 관리하는 서비스.
///
/// 동작 규칙:
/// - [threshold]% 이하이고 충전 중이 아닐 때 [lowBattery]가 true
/// - 경고는 회당 1회만 표시 (배터리가 임계값 초과 회복 후 재활성)
/// - [monitoringEnabled]가 false면 감시 중단, 배너 숨김
/// - Android/iOS에서만 동작 (데스크톱은 no-op)
class BatteryService {
  BatteryService._();
  static final BatteryService instance = BatteryService._();

  static const int threshold = 20;
  static const Duration _checkInterval = Duration(minutes: 5);
  static const String _prefKey = 'battery_monitor_enabled';

  final _battery = Battery();
  Timer? _timer;

  /// 저배터리 상태 여부 (충전 중이거나 임계값 초과 시 false)
  final ValueNotifier<bool> lowBattery = ValueNotifier(false);

  /// 현재 배터리 잔량 (0–100). 미지원 환경에서는 -1.
  final ValueNotifier<int> level = ValueNotifier(-1);

  /// 배터리 모니터링 활성화 여부. SharedPreferences로 영속.
  final ValueNotifier<bool> monitoringEnabled = ValueNotifier(true);

  bool _warningActive = false;

  /// 앱 시작 시 호출. 저장된 설정을 불러온 뒤 모니터링 시작.
  Future<void> start() async {
    if (!_isMobile) return;
    await _loadPref();
    if (monitoringEnabled.value) _startMonitor();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// 모니터링 on/off 토글. 설정을 SharedPreferences에 저장.
  Future<void> setEnabled(bool value) async {
    if (!_isMobile) return;
    monitoringEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);

    if (value) {
      _startMonitor();
    } else {
      stop();
      lowBattery.value = false;
      _warningActive = false;
    }
  }

  /// 사용자가 배너를 직접 닫을 때 호출. 배터리가 회복되기 전까지 재표시 안 함.
  void dismiss() => lowBattery.value = false;

  void _startMonitor() {
    _check();
    _timer ??= Timer.periodic(_checkInterval, (_) => _check());
  }

  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    monitoringEnabled.value = prefs.getBool(_prefKey) ?? true;
  }

  Future<void> _check() async {
    if (!_isMobile || !monitoringEnabled.value) return;
    try {
      final lvl = await _battery.batteryLevel;
      final state = await _battery.batteryState;

      level.value = lvl;

      final isCharging =
          state == BatteryState.charging || state == BatteryState.full;
      final shouldWarn = lvl <= threshold && !isCharging;

      if (!shouldWarn) {
        _warningActive = false;
        lowBattery.value = false;
        return;
      }

      if (!_warningActive) {
        _warningActive = true;
        lowBattery.value = true;
      }
    } catch (_) {
      // 배터리 API 미지원 기기는 무시
    }
  }

  bool get _isMobile => Platform.isAndroid || Platform.isIOS;
}
