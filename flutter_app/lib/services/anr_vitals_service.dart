import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'platform_info.dart';

/// 프로덕션 ANR-free 비율 측정(Android 전용, 2차 보강).
///
/// 6σ(99.99966%) 판정의 1차 권위 소스는 **Play Console Android Vitals**다(전체 설치
/// 기반, 사용자-인지 ANR율). 자체 표본으로 3.4/1e6 를 유의하게 추정하려면 수백만 세션이
/// 필요해 소규모 배포로는 도달 불가하다. 이 서비스는 그 방향성 KPI 를 향한 **조기 신호·
/// 버전 회귀 자체 확인·breadcrumb 맥락** 용도다.
///
/// 동작(앱 콜드스타트마다):
///  1) 세션 카운터(분모) +1
///  2) 네이티브 `getHistoricalProcessExitReasons`(API30+) 로 커서 이후 종료 이력 수집
///  3) REASON_ANR 만큼 분자 +1, 이벤트 적재, 커서 갱신(중복 방지)
///  4) rollup(sessions/anrSessions 증분) 적재 후, **동의 시에만** 서버 전송
///
/// 프라이버시: 기존 `telemetry_consent` 동의가 true 일 때만 전송. 미동의면 로컬 카운트만
/// 한다(전송 0). Android 동의 UI 연동은 후속(현재 미노출 → 사실상 로컬 집계까지).
class AnrVitalsService {
  AnrVitalsService._();
  static final AnrVitalsService instance = AnrVitalsService._();

  static const _channel = MethodChannel('dev.analogtimer/anr_vitals');
  static const String _endpoint =
      'https://analog-timer-kappa.vercel.app/api/telemetry';

  // 기존 텔레메트리와 공유(동일 사용자·동의).
  static const _kConsent = 'telemetry_consent';
  static const _kDeviceId = 'telemetry_device_id';
  // ANR 지표 전용.
  static const _kCursor = 'anr_exit_cursor_ms';
  static const _kSessionCount = 'anr_session_count';
  static const _kAnrCount = 'anr_count';
  static const _kPending = 'anr_vitals_pending';

  bool get supported => isAndroid;

  Future<void> init() async {
    if (!supported) return;
    try {
      final p = await SharedPreferences.getInstance();

      // (1) 세션(콜드스타트) 카운터 = 분모.
      final sessions = (p.getInt(_kSessionCount) ?? 0) + 1;
      await p.setInt(_kSessionCount, sessions);

      // (2) 네이티브 종료 이력 수집(커서 이후분만).
      final cursor = p.getInt(_kCursor) ?? 0;
      final res = await _channel.invokeMapMethod<String, dynamic>('collect', {
        'sinceMs': cursor,
      });
      if (res == null) return;

      final measurable = res['measurable'] == true;
      final versionName = (res['versionName'] ?? '').toString();
      final versionCode = (res['versionCode'] as num?)?.toInt() ?? 0;
      final sdkInt = (res['sdkInt'] as num?)?.toInt() ?? 0;
      final exits = (res['exits'] as List?) ?? const [];

      // (3) 새 ANR 처리 + 커서 갱신.
      var newAnr = 0;
      var maxTs = cursor;
      final events = <Map<String, dynamic>>[];
      for (final e in exits.cast<Map>()) {
        final ts = (e['timestampMs'] as num?)?.toInt() ?? 0;
        if (ts > maxTs) maxTs = ts;
        if (e['isAnr'] == true) {
          newAnr++;
          // 서버(api/telemetry.js)는 필드 화이트리스트로 저장하고 임의 필드는 extra 로만
          // 보존한다 → ANR 전용 수치는 extra 에 담아 유실 방지.
          events.add({
            'type': 'anr',
            'crashKind': 'anr',
            'message': (e['description'] ?? '').toString(),
            'extra': {
              'atMs': ts,
              'userPerceived': e['userPerceived'] == true,
              'importance': e['importance'],
              'processName': e['processName'],
              'pssKb': e['pssKb'],
              'rssKb': e['rssKb'],
            },
          });
        }
      }
      if (maxTs > cursor) await p.setInt(_kCursor, maxTs);
      final anrTotal = (p.getInt(_kAnrCount) ?? 0) + newAnr;
      if (newAnr > 0) await p.setInt(_kAnrCount, anrTotal);

      // (4) rollup + 이벤트 적재.
      events.add({
        'type': 'vitals_rollup',
        'extra': {
          'sessions': sessions,
          'anrSessions': anrTotal,
          'anrMeasurable': measurable,
          'sdkInt': sdkInt,
          'atMs': DateTime.now().millisecondsSinceEpoch,
        },
      });

      final appVersion = versionName.isEmpty
          ? null
          : '$versionName+$versionCode';
      for (final ev in events) {
        await _enqueue(p, ev);
      }
      await _flush(p, appVersion);
    } catch (_) {
      // 지표 수집은 앱 동작에 영향 주지 않는다(전부 흡수).
    }
  }

  // ----- 큐/전송 (동의 게이팅) -----

  Future<bool> _consented(SharedPreferences p) async =>
      p.containsKey(_kConsent) && (p.getBool(_kConsent) ?? false);

  Future<void> _enqueue(SharedPreferences p, Map<String, dynamic> ev) async {
    final list = (jsonDecode(p.getString(_kPending) ?? '[]') as List).toList();
    list.add(ev);
    while (list.length > 20) {
      list.removeAt(0);
    }
    await p.setString(_kPending, jsonEncode(list));
  }

  Future<void> _flush(SharedPreferences p, String? appVersion) async {
    if (!await _consented(p)) return; // 미동의 → 로컬 카운트만
    final raw = p.getString(_kPending);
    if (raw == null || raw == '[]') return;
    final deviceId = p.getString(_kDeviceId) ?? _genId();
    if (!p.containsKey(_kDeviceId)) await p.setString(_kDeviceId, deviceId);

    final remain = <dynamic>[];
    for (final ev in (jsonDecode(raw) as List)) {
      final ok = await _send(
        deviceId,
        appVersion,
        (ev as Map).cast<String, dynamic>(),
      );
      if (!ok) remain.add(ev);
    }
    await p.setString(_kPending, jsonEncode(remain));
  }

  Future<bool> _send(
    String deviceId,
    String? appVersion,
    Map<String, dynamic> body,
  ) async {
    HttpClient? client;
    try {
      final payload = <String, dynamic>{
        'deviceId': deviceId,
        if (appVersion != null) 'appVersion': appVersion,
        'platform': 'android',
        'osVersion': Platform.operatingSystemVersion,
        ...body,
      };
      client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
      final req = await client.postUrl(Uri.parse(_endpoint));
      req.headers.contentType = ContentType.json;
      req.add(utf8.encode(jsonEncode(payload)));
      final res = await req.close().timeout(const Duration(seconds: 10));
      await res.drain<void>();
      return res.statusCode == 200;
    } catch (_) {
      return false;
    } finally {
      client?.close(force: true);
    }
  }

  String _genId() {
    final rnd = Random.secure();
    return List.generate(
      16,
      (_) => rnd.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }
}
