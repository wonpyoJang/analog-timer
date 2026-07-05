import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 크래시·환경 텔레메트리. 데스크톱(Windows/macOS) 전용 — web/mobile 에선 no-op.
///
/// 핵심: 네이티브 크래시(앱이 통째로 죽는 경우)는 Dart 가 그 순간을 못 잡으므로,
/// "정상 종료 플래그"를 두고 **다음 실행 시** 비정상 종료를 감지해 리포트한다.
/// 첫 실행 1회 동의(consent) 전에는 아무것도 전송하지 않고 보류한다.
class TelemetryService {
  TelemetryService._();
  static final TelemetryService instance = TelemetryService._();

  static const String _endpoint =
      'https://analog-timer-kappa.vercel.app/api/telemetry';
  static const String _appVersion = '0.3.1+5';

  static const String _kConsent = 'telemetry_consent'; // bool? (null=미정)
  static const String _kDeviceId = 'telemetry_device_id';
  static const String _kLastState = 'telemetry_last_state';
  static const String _kPending = 'telemetry_pending_crash';

  /// 정상 종료 마커 — 네이티브 종료 직전(main.cpp)과 Dart 양쪽이 남긴다.
  /// 시작 시 존재하면 직전 세션이 정상 종료된 것. 없으면 크래시(첫 실행 제외).
  File get _cleanFlag =>
      File('${Directory.systemTemp.path}${Platform.pathSeparator}analog_timer_clean.flag');

  /// breadcrumb 전용 파일 — SharedPreferences 는 메인/위젯 엔진이 각자 캐시를
  /// 통째로 파일에 flush 하므로, 위젯이 prefs 를 쓰면(위치/스케일) 메인이 추가한
  /// breadcrumb 가 날아간다. 메인만 쓰는 별도 파일로 분리해 그 race 를 피한다.
  File get _crumbFile {
    // systemTemp 는 위젯 엔진 teardown 시 Flutter 가 정리하며 같이 지워질 수 있어,
    // 앱 데이터 디렉토리(prefs 옆)에 둔다.
    final base = (Platform.isWindows && Platform.environment['APPDATA'] != null)
        ? '${Platform.environment['APPDATA']}\\dev.analogtimer\\analog_timer'
        : Directory.systemTemp.path;
    return File('$base${Platform.pathSeparator}analog_timer_breadcrumbs.json');
  }

  Future<List<Map<String, dynamic>>> _readCrumbs() async {
    try {
      if (await _crumbFile.exists()) {
        return (jsonDecode(await _crumbFile.readAsString()) as List)
            .cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return <Map<String, dynamic>>[];
  }

  bool _enabled = false;
  String? _deviceId;
  Map<String, dynamic> _env = {};

  bool get supported =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS);

  /// 동의 상태 — true/false/null(아직 안 물음).
  Future<bool?> consent() async {
    if (!supported) return false;
    final p = await SharedPreferences.getInstance();
    return p.containsKey(_kConsent) ? p.getBool(_kConsent) : null;
  }

  /// 동의 설정(첫 실행 다이얼로그 / 설정 토글). true 면 보류된 크래시도 전송.
  Future<void> setConsent(bool v) async {
    if (!supported) return;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kConsent, v);
    _enabled = v;
    if (v) await _flushPending();
  }

  /// 앱 시작 직후 호출 — 비정상 종료 감지 + 환경 수집.
  Future<void> init() async {
    if (!supported) return;
    final p = await SharedPreferences.getInstance();
    _enabled = p.getBool(_kConsent) ?? false;
    final existedId = p.getString(_kDeviceId);
    final firstRun = existedId == null;
    _deviceId = existedId ?? _genId();
    if (firstRun) await p.setString(_kDeviceId, _deviceId!);

    // 직전 종료 판정: 마커가 있으면 정상 종료, 없으면 크래시(첫 실행은 제외).
    bool cleanLast;
    try {
      cleanLast = await _cleanFlag.exists();
    } catch (_) {
      cleanLast = true; // 판정 불가 시 오탐 방지
    }
    try {
      if (cleanLast) await _cleanFlag.delete();
    } catch (_) {}

    unawaited(_collectEnv()); // 백그라운드 환경 수집

    // 이전 세션의 breadcrumb(크래시 직전 행동 맥락) 로드 후, 새 세션 위해 비운다.
    final prevCrumbs = await _readCrumbs();
    try {
      if (await _crumbFile.exists()) await _crumbFile.delete();
    } catch (_) {}

    if (!cleanLast && !firstRun) {
      final lastStateRaw = p.getString(_kLastState);
      final crash = <String, dynamic>{
        'type': 'crash',
        'crashKind': 'native',
        'message':
            '비정상 종료 감지 — 이전 세션이 정상 종료 플래그를 남기지 못함(네이티브 크래시 가능성)',
        'lastState': lastStateRaw != null ? jsonDecode(lastStateRaw) : null,
        'breadcrumbs': prevCrumbs.isNotEmpty ? prevCrumbs : null,
      };
      await p.setString(_kPending, jsonEncode(crash));
      if (_enabled) await _flushPending();
    }

    // TDR 자가 재시작 감지 — 네이티브 워치독이 GPU 드라이버 리셋을 감지해 앱을
    // 재시작했으면 마커가 남아있다. 마커 파일은 네이티브의 재시작 폭주 방지에
    // 쓰이므로 삭제하지 않고, mtime 기준으로 이미 리포트한 것만 건너뛴다.
    await _reportTdrRestartIfAny(p);
  }

  Future<void> _reportTdrRestartIfAny(SharedPreferences p) async {
    if (!Platform.isWindows) return;
    try {
      final flag = File(
          '${Directory.systemTemp.path}${Platform.pathSeparator}analog_timer_tdr.flag');
      if (!await flag.exists()) return;
      final mtime = (await flag.lastModified()).millisecondsSinceEpoch;
      const kReported = 'telemetry_tdr_reported_ms';
      if (mtime <= (p.getInt(kReported) ?? 0)) return; // 이미 리포트함
      await p.setInt(kReported, mtime);
      final crash = <String, dynamic>{
        'type': 'crash',
        'crashKind': 'tdr_restart',
        'message':
            'GPU TDR(드라이버 리셋) 감지 → 워치독이 앱 자가 재시작 (렌더 서피스 사망 복구)',
        'lastState': {'tdrFlagMtime': mtime},
      };
      await p.setString(_kPending, jsonEncode(crash));
      if (_enabled) await _flushPending();
    } catch (_) {}
  }

  /// 정상 종료 — 마커 생성(네이티브 main.cpp 가 주 경로, 이건 보조 안전망).
  Future<void> markCleanExit() async {
    if (!supported) return;
    try {
      await _cleanFlag.create();
    } catch (_) {}
  }

  /// 크래시 시 함께 올릴 마지막 상태(위젯 on/off, 타이머 running 등). 주기적으로 저장.
  Future<void> saveLastState(Map<String, dynamic> state) async {
    if (!supported) return;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLastState, jsonEncode(state));
  }

  /// 사용자 행동·상태 변화 기록(breadcrumb). 크래시 시 직전 맥락으로 함께 전송한다.
  /// 예: timer_start / timer_next / segment_change / overlay_on / overlay_drag.
  /// consent 무관하게 로컬 수집(전송만 동의 필요) — 빈도 낮은 이벤트만 심는다.
  Future<void> logEvent(String event, [Map<String, dynamic>? detail]) async {
    if (!supported) return;
    try {
      final list = await _readCrumbs();
      list.add({
        't': DateTime.now().millisecondsSinceEpoch,
        'e': event,
        if (detail != null) 'd': detail,
      });
      while (list.length > 25) {
        list.removeAt(0);
      }
      await _crumbFile.writeAsString(jsonEncode(list));
    } catch (_) {}
  }

  /// Dart 레벨 에러(FlutterError / PlatformDispatcher) 리포트.
  Future<void> reportDartError(Object error, StackTrace? stack,
      {Map<String, dynamic>? lastState}) async {
    if (!supported) return;
    await _send({
      'type': 'crash',
      'crashKind': 'dart',
      'message': error.toString(),
      'stack': stack?.toString(),
      if (lastState != null) 'lastState': lastState,
    });
  }

  /// 위젯(오버레이)이 혼자 사라져 재생성될 때 — 앱 프로세스는 살아있어 네이티브
  /// 크래시 감지(마커)에 안 걸리므로, 이 순간 직접 리포트한다(그 시점 GPU TDR/
  /// 이벤트로그 포함). 친구 증상 "위젯 혼자 반복적으로 사라짐"을 실시간 캡처하는 경로.
  DateTime? _lastWidgetReport;
  Future<void> reportWidgetGone(
      {Map<String, dynamic>? lastState,
      List<Map<String, dynamic>>? breadcrumbsOverride}) async {
    if (!supported || !_enabled) return;
    // 반복 재생성 환경에서 과도한 전송 방지 — 최소 30초 간격.
    final now = DateTime.now();
    if (_lastWidgetReport != null &&
        now.difference(_lastWidgetReport!) < const Duration(seconds: 30)) {
      return;
    }
    _lastWidgetReport = now;
    // 위젯 재생성 중엔 메인 엔진의 파일 접근이 일시적으로 깨지므로, 호출측이 재생성
    // 직전에 읽어 넘긴 breadcrumbsOverride 를 우선 사용한다.
    final crumbs = breadcrumbsOverride ?? await _readCrumbs();
    await _send({
      'type': 'widget_gone',
      'crashKind': 'widget',
      'message': '위젯(오버레이)이 사라져 재생성됨 — 앱 프로세스는 생존',
      'eventLog': await _collectEventLog(),
      'breadcrumbs': crumbs,
      if (lastState != null) 'lastState': lastState,
    });
  }

  /// 위젯 재생성 직전에 호출측이 breadcrumb 를 읽어두기 위한 public 접근자.
  Future<List<Map<String, dynamic>>> snapshotCrumbs() => _readCrumbs();

  Future<void> _flushPending() async {
    if (!_enabled || !supported) return;
    final p = await SharedPreferences.getInstance();
    final pend = p.getString(_kPending);
    if (pend == null) return;
    final crash = jsonDecode(pend) as Map<String, dynamic>;
    crash['eventLog'] = await _collectEventLog();
    if (await _send(crash)) await p.remove(_kPending);
  }

  Future<bool> _send(Map<String, dynamic> body) async {
    if (!_enabled || !supported) return false;
    HttpClient? client;
    try {
      if (_env.isEmpty) await _collectEnv();
      // breadcrumbs: crash(pending)는 body 에 이전 세션 것이 이미 있고, 그 외
      // (widget_gone/dart)는 현재 prefs 에서 읽어 채운다. prefs 는 메인/위젯 엔진이
      // 공유하므로 어느 엔진의 logEvent 든 모두 포함된다.
      if (!body.containsKey('breadcrumbs')) {
        final list = await _readCrumbs();
        if (list.isNotEmpty) body['breadcrumbs'] = list;
      }
      final payload = <String, dynamic>{
        'deviceId': _deviceId,
        'appVersion': _appVersion,
        ..._env,
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

  Future<void> _collectEnv() async {
    if (!supported) return;
    try {
      _env = {
        'platform': Platform.isWindows
            ? 'windows'
            : Platform.isMacOS
                ? 'macos'
                : 'other',
        'osVersion': Platform.operatingSystemVersion,
      };
      if (Platform.isWindows) {
        final r = await Process.run('powershell', [
          '-NoProfile',
          '-Command',
          '(Get-CimInstance Win32_VideoController | '
              'Select-Object -ExpandProperty Name) -join ", "',
        ]).timeout(const Duration(seconds: 8));
        final gpu = (r.stdout as String).trim();
        if (gpu.isNotEmpty) _env['gpu'] = gpu;
      }
    } catch (_) {
      // 환경 수집 실패해도 osVersion 만으로 진행
    }
  }

  /// 최근 1시간 Application 오류 이벤트 중 앱 관련 항목(크래시 단서).
  Future<String> _collectEventLog() async {
    if (!Platform.isWindows) return '';
    final out = <String>[];
    // 1) Application 오류(앱 크래시 — 예외코드/죽은 모듈)
    try {
      const ps =
          r"Get-WinEvent -FilterHashtable @{LogName='Application';Level=2;StartTime=(Get-Date).AddHours(-1)} "
          r"-MaxEvents 25 -ErrorAction SilentlyContinue | "
          r"Where-Object { $_.Message -match 'analog_timer|flutter|0xc0000005|0xc0000409' } | "
          r"Select-Object -First 6 | "
          r"ForEach-Object { '[APP] ' + $_.TimeCreated.ToString('HH:mm:ss') + ' ' + $_.ProviderName + ': ' + ($_.Message.Split([char]10))[0] }";
      final r = await Process.run('powershell', ['-NoProfile', '-Command', ps])
          .timeout(const Duration(seconds: 10));
      final s = (r.stdout as String).trim();
      if (s.isNotEmpty) out.add(s);
    } catch (_) {}
    // 2) System: GPU TDR(디스플레이 드라이버 타임아웃 리셋) — '갑자기·반복' 크래시의
    //    핵심 후보. 4101=드라이버 복구됨, 4099/4100=TDR, 14=nvlddmkm 등 드라이버 오류.
    try {
      const ps =
          r"Get-WinEvent -FilterHashtable @{LogName='System';Id=4101,4099,4100,14;StartTime=(Get-Date).AddHours(-2)} "
          r"-MaxEvents 8 -ErrorAction SilentlyContinue | "
          r"Select-Object -First 8 | "
          r"ForEach-Object { '[TDR/' + $_.Id + '] ' + $_.TimeCreated.ToString('HH:mm:ss') + ' ' + $_.ProviderName + ': ' + ($_.Message.Split([char]10))[0] }";
      final r = await Process.run('powershell', ['-NoProfile', '-Command', ps])
          .timeout(const Duration(seconds: 10));
      final s = (r.stdout as String).trim();
      if (s.isNotEmpty) out.add(s);
    } catch (_) {}
    return out.join('\n');
  }

  String _genId() {
    final rnd = Random.secure();
    return List.generate(
        16, (_) => rnd.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }
}
