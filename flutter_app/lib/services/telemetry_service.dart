import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
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
  static const String _appVersion = '0.4.2+9';

  static const String _kConsent = 'telemetry_consent'; // bool? (null=미정)
  static const String _kPendingEvents = 'telemetry_pending_events'; // 복구 이벤트 큐
  static const String _kDeviceId = 'telemetry_device_id';
  static const String _kLastState = 'telemetry_last_state';
  static const String _kPending = 'telemetry_pending_crash';

  /// 정상 종료 마커 — 네이티브 종료 직전(main.cpp)과 Dart 양쪽이 남긴다.
  /// 시작 시 존재하면 직전 세션이 정상 종료된 것. 없으면 크래시(첫 실행 제외).
  File get _cleanFlag =>
      File('${Directory.systemTemp.path}${Platform.pathSeparator}analog_timer_clean.flag');

  /// crumb/heartbeat 공용 데이터 디렉토리.
  /// systemTemp 는 위젯 엔진 teardown 시 Flutter 가 정리하며 같이 지워질 수 있어,
  /// 앱 데이터 디렉토리(prefs 옆)에 둔다.
  String get _dataBase =>
      (Platform.isWindows && Platform.environment['APPDATA'] != null)
          ? '${Platform.environment['APPDATA']}\\dev.analogtimer\\analog_timer'
          : Directory.systemTemp.path;

  /// breadcrumb 전용 파일 — SharedPreferences 는 메인/위젯 엔진이 각자 캐시를
  /// 통째로 파일에 flush 하므로, 위젯이 prefs 를 쓰면(위치/스케일) 메인이 추가한
  /// breadcrumb 가 날아간다. 메인만 쓰는 별도 파일로 분리해 그 race 를 피한다.
  File get _crumbFile =>
      File('$_dataBase${Platform.pathSeparator}analog_timer_breadcrumbs.json');

  /// UI heartbeat 파일 — 30초마다 {기록 시각 t, 마지막 렌더 프레임 시각 frame}.
  /// 다음 실행의 크래시 리포트가 읽어 freeze 시점을 특정한다:
  ///  - t 가 오래전에 멈춤 → 그 즈음 프로세스 정지/사망 (t = 사망 시각 상한)
  ///  - t 는 최신인데 frame 이 한참 전 → Dart 는 살아있는데 렌더만 죽음
  ///    (TDR 좀비 — 사용자 눈엔 "시계가 멈춘" 상태).
  ///    ※ 최소화/가림 상태도 frame 은 멈추므로 lastState·breadcrumb 과 함께 해석.
  File get _heartbeatFile =>
      File('$_dataBase${Platform.pathSeparator}analog_timer_heartbeat.json');

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
  int _lastFrameMs = 0;
  Timer? _heartbeatTimer;

  /// 마지막으로 렌더 프레임이 그려진 시각(ms). 0 이면 아직 첫 프레임 전.
  /// 멈춤(freeze) 워치독이 이 값의 나이로 "렌더가 죽었는지"를 판정한다.
  int get lastFrameMs => _lastFrameMs;

  Future<Map<String, dynamic>?> _readHeartbeat() async {
    try {
      if (await _heartbeatFile.exists()) {
        return (jsonDecode(await _heartbeatFile.readAsString()) as Map)
            .cast<String, dynamic>();
      }
    } catch (_) {}
    return null;
  }

  /// heartbeat 시작 — 메인 엔진 전용(init 에서만 호출됨).
  void _startHeartbeat() {
    if (!supported) return;
    try {
      SchedulerBinding.instance.addPersistentFrameCallback((_) {
        _lastFrameMs = DateTime.now().millisecondsSinceEpoch;
      });
    } catch (_) {}
    Future<void> beat() async {
      try {
        // 부모 디렉토리 보장 — 첫 실행/재설치 직후엔 아직 없을 수 있다.
        await _heartbeatFile.parent.create(recursive: true);
        await _heartbeatFile.writeAsString(jsonEncode({
          't': DateTime.now().millisecondsSinceEpoch,
          'frame': _lastFrameMs == 0 ? null : _lastFrameMs,
        }));
      } catch (_) {}
    }

    unawaited(beat());
    _heartbeatTimer?.cancel();
    // 10초 주기 — 네이티브 워치독의 Dart 프리즈 감지(60초 정체 판정)가 충분히
    // 빠르게 반응하도록. 쓰기 부하는 수십 바이트 파일 하나라 무시 가능.
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (_) => beat());
  }

  /// 복구 이벤트 보고 — 자동/수동 복구가 "왜, 어떤 상태에서" 발동했는지 서버에
  /// 남긴다(type: 'recovery'). 재시작 직전에 불려도 유실되지 않도록 prefs 큐에
  /// 먼저 적재하고 곧바로 전송을 시도한다 — 실패분은 다음 실행 init 이 재전송.
  /// 디버깅 컨텍스트(당시 프레임 나이·tdr 마커·타이머 상태·breadcrumbs) 자동 동봉.
  Future<void> reportRecovery(String kind,
      {String? message, Map<String, dynamic>? extra}) async {
    if (!supported) return;
    try {
      final p = await SharedPreferences.getInstance();
      final lastRaw = p.getString(_kLastState);
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final ev = <String, dynamic>{
        'type': 'recovery',
        'crashKind': kind,
        'message': message ?? '복구 발동 — $kind',
        'lastState': lastRaw != null ? jsonDecode(lastRaw) : null,
        'breadcrumbs': await _readCrumbs(),
        'extra': {
          ...?extra,
          'tdrFlag': await _tdrFlagDiag(),
          if (_lastFrameMs != 0)
            'frameAgeSec': ((nowMs - _lastFrameMs) / 1000).round(),
          'atMs': nowMs,
        },
      };
      await _enqueueEvent(p, ev);
      unawaited(_flushEvents());
    } catch (_) {}
  }

  Future<void> _enqueueEvent(
      SharedPreferences p, Map<String, dynamic> ev) async {
    final list = (jsonDecode(p.getString(_kPendingEvents) ?? '[]') as List)
        .toList();
    list.add(ev);
    while (list.length > 20) {
      list.removeAt(0);
    }
    await p.setString(_kPendingEvents, jsonEncode(list));
  }

  Future<void> _flushEvents() async {
    if (!_enabled || !supported) return;
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_kPendingEvents);
      if (raw == null || raw == '[]') return;
      final remain = <dynamic>[];
      for (final ev in (jsonDecode(raw) as List)) {
        if (!await _send((ev as Map).cast<String, dynamic>())) remain.add(ev);
      }
      await p.setString(_kPendingEvents, jsonEncode(remain));
    } catch (_) {}
  }

  /// 서브엔진(위젯)/외부에서 복구 마커 기록 — prefs 는 메인/위젯 엔진 간 flush
  /// 경합이 있어 쓰지 않고(breadcrumb 파일 분리와 같은 이유) systemTemp 파일
  /// 마커로 남긴다. 다음 실행의 _reportRecoveryMarkersIfAny 가 보고.
  Future<void> writeRecoveryMarker(
      String name, Map<String, dynamic> data) async {
    try {
      final f = File(
          '${Directory.systemTemp.path}${Platform.pathSeparator}analog_timer_$name.json');
      await f.writeAsString(jsonEncode(data));
    } catch (_) {}
  }

  /// 네이티브 워치독/서브엔진이 남긴 복구 마커(json) → recovery 리포트.
  ///  - freeze_restart: heartbeat 정체 → 팝업 → 자동 재시작 (main.cpp)
  ///  - janitor: 고아 위젯 좀비 정리 (main.cpp)
  ///  - widget_restart: 위젯 코너 재시작 버튼 (오버레이 엔진)
  /// mtime 을 prefs 에 기록해 중복 보고를 막고, 마커 시각 주변(−10분)의
  /// Windows 이벤트로그를 동봉해 원인 추적이 가능하게 한다.
  Future<void> _reportRecoveryMarkersIfAny(SharedPreferences p) async {
    for (final name in ['freeze_restart', 'janitor', 'widget_restart']) {
      try {
        final f = File(
            '${Directory.systemTemp.path}${Platform.pathSeparator}analog_timer_$name.json');
        if (!await f.exists()) continue;
        final mtime = (await f.lastModified()).millisecondsSinceEpoch;
        final key = 'telemetry_rcv_${name}_ms';
        if (mtime <= (p.getInt(key) ?? 0)) continue; // 이미 보고함
        await p.setInt(key, mtime);
        Map<String, dynamic> content = {};
        try {
          content =
              (jsonDecode(await f.readAsString()) as Map).cast<String, dynamic>();
        } catch (_) {}
        await _enqueueEvent(p, <String, dynamic>{
          'type': 'recovery',
          'crashKind': content['kind'] ?? name,
          'message': '복구 마커 감지(직전 세션) — ${content['kind'] ?? name}',
          'eventLog': await _collectEventLog(sinceMs: mtime - 600000),
          'extra': {
            'marker': content,
            'markerAtMs': mtime,
            'tdrFlag': await _tdrFlagDiag(),
          },
        });
      } catch (_) {}
    }
    unawaited(_flushEvents());
  }

  /// 워치독 tdr 마커 진단 — 이번 크래시가 "워치독이 아는 TDR" 맥락이었는지 판별.
  /// exists+ageMin 이 작으면 TDR 직후(폭주가드 감시 중 사용자 강제종료 등),
  /// exists=false 면 워치독이 전혀 감지 못 한 freeze/크래시.
  Future<Map<String, dynamic>> _tdrFlagDiag() async {
    if (!Platform.isWindows) return {'exists': false};
    try {
      final flag = File(
          '${Directory.systemTemp.path}${Platform.pathSeparator}analog_timer_tdr.flag');
      if (!await flag.exists()) return {'exists': false};
      final mtime = await flag.lastModified();
      return {
        'exists': true,
        'mtimeMs': mtime.millisecondsSinceEpoch,
        'ageMin': DateTime.now().difference(mtime).inMinutes,
      };
    } catch (_) {
      return {'exists': null}; // 판정 불가
    }
  }

  /// 직전 세션이 비정상 종료였는지 — init() 에서 판정된다.
  /// 사용후기 유도 등 "나쁜 경험 직후엔 하지 말아야 할 것"의 가드로 쓴다.
  bool lastSessionCrashed = false;

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
    if (v) {
      await _flushPending();
      await _flushEvents();
    }
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

    // 직전 세션의 heartbeat — freeze 시점 특정용 (새 세션이 덮어쓰기 전에 읽는다).
    final prevBeat = await _readHeartbeat();

    lastSessionCrashed = !cleanLast && !firstRun;
    if (!cleanLast && !firstRun) {
      final lastStateRaw = p.getString(_kLastState);
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final beatT = (prevBeat?['t'] as num?)?.toInt();
      final frameT = (prevBeat?['frame'] as num?)?.toInt();
      final crash = <String, dynamic>{
        'type': 'crash',
        'crashKind': 'native',
        'message':
            '비정상 종료 감지 — 이전 세션이 정상 종료 플래그를 남기지 못함(네이티브 크래시 가능성)',
        'lastState': lastStateRaw != null ? jsonDecode(lastStateRaw) : null,
        'breadcrumbs': prevCrumbs.isNotEmpty ? prevCrumbs : null,
        // 진단: 워치독 tdr 마커 + 직전 heartbeat.
        //  - beatGapMin: 마지막 생존 신호 → 이번 실행까지 공백(프로세스 사망 시각 상한)
        //  - frameLagAtBeatSec: 마지막 생존 시점에 렌더가 얼마나 밀려 있었나
        //    (수십 초 이상이면 "프로세스 생존 + 렌더 사망" = 시계 멈춤 좀비)
        'extra': {
          'tdrFlag': await _tdrFlagDiag(),
          if (prevBeat != null) 'prevHeartbeat': prevBeat,
          if (beatT != null) 'beatGapMin': ((nowMs - beatT) / 60000).round(),
          if (beatT != null && frameT != null)
            'frameLagAtBeatSec': ((beatT - frameT) / 1000).round(),
        },
      };
      await p.setString(_kPending, jsonEncode(crash));
    }

    // heartbeat 는 크래시 전송보다 먼저 시작 — _flushPending 의 이벤트로그 수집
    // (PowerShell, 수 초~수십 초)이 첫 heartbeat 를 지연시키면 그 사이 크래시 시
    // freeze 시점 데이터가 통째로 빈다.
    _startHeartbeat();

    // 전송 체인은 백그라운드로 — 이벤트로그 수집(PowerShell)이 앱 시작(runApp)을
    // 막지 않게. 순서는 보존(크래시 flush → TDR 리포트, _kPending 경합 방지)하고,
    // 실패해도 pending 은 prefs 에 남아 다음 기회에 재전송된다.
    unawaited(() async {
      if (lastSessionCrashed && _enabled) await _flushPending();
      // TDR 자가 재시작 감지 — 네이티브 워치독이 GPU 드라이버 리셋을 감지해 앱을
      // 재시작했으면 마커가 남아있다. 마커 파일은 네이티브의 재시작 폭주 방지에
      // 쓰이므로 삭제하지 않고, mtime 기준으로 이미 리포트한 것만 건너뛴다.
      await _reportTdrRestartIfAny(p);
      // 복구 마커(freeze_restart/janitor/widget_restart) + 이전 세션에 못 보낸
      // recovery 이벤트 큐 재전송.
      await _reportRecoveryMarkersIfAny(p);
    }());
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
  /// 지속성 빌드 에러는 매 프레임 발화하므로 스로틀(30초)+동일 메시지 dedup —
  /// 무제한 전송 시 HttpClient 소켓이 초당 수십 개씩 누적된다.
  DateTime? _lastDartReport;
  String? _lastDartMessage;
  Future<void> reportDartError(Object error, StackTrace? stack,
      {Map<String, dynamic>? lastState}) async {
    if (!supported) return;
    final now = DateTime.now();
    final msg = error.toString();
    if (_lastDartReport != null &&
        now.difference(_lastDartReport!) < const Duration(seconds: 30) &&
        msg == _lastDartMessage) {
      return;
    }
    _lastDartReport = now;
    _lastDartMessage = msg;
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

  /// 피드백에 동봉할 진단 스냅샷 — 기기 환경 + 최근 행동 흐름 + 마지막 상태 +
  /// Windows 이벤트로그. 개인정보·타이머 내용은 포함하지 않는다(텔레메트리와 동일 범위).
  Future<Map<String, dynamic>> diagnosticsSnapshot() async {
    if (!supported) return {};
    try {
      if (_env.isEmpty) await _collectEnv();
      final p = await SharedPreferences.getInstance();
      final lastRaw = p.getString(_kLastState);
      return {
        'env': _env,
        'breadcrumbs': await _readCrumbs(),
        'lastState': lastRaw != null ? jsonDecode(lastRaw) : null,
        'eventLog': await _collectEventLog(),
        'appVersion': _appVersion,
        'tdrFlag': await _tdrFlagDiag(),
        if (_lastFrameMs != 0)
          'lastFrameAgeSec':
              ((DateTime.now().millisecondsSinceEpoch - _lastFrameMs) / 1000)
                  .round(),
      };
    } catch (_) {
      return {};
    }
  }

  Future<void> _flushPending() async {
    if (!_enabled || !supported) return;
    final p = await SharedPreferences.getInstance();
    final pend = p.getString(_kPending);
    if (pend == null) return;
    final crash = jsonDecode(pend) as Map<String, dynamic>;
    // 이벤트로그 조회 시작점 = 마지막 생존 신호(heartbeat/breadcrumb) 시각.
    // 고정 1시간 윈도우는 재실행이 늦으면 실제 크래시 시점 로그를 놓친다.
    int? sinceMs;
    final ex = crash['extra'];
    if (ex is Map && ex['prevHeartbeat'] is Map) {
      sinceMs = (ex['prevHeartbeat']['t'] as num?)?.toInt();
    }
    final bc = crash['breadcrumbs'];
    if (bc is List && bc.isNotEmpty) {
      final lastT = (bc.last['t'] as num?)?.toInt();
      if (lastT != null && (sinceMs == null || lastT > sinceMs)) sinceMs = lastT;
    }
    crash['eventLog'] = await _collectEventLog(sinceMs: sinceMs);
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

  /// Application 오류 이벤트 중 앱 관련 항목(크래시 단서).
  /// 기본 최근 1시간(TDR 은 2시간). sinceMs 가 주어지면(크래시 리포트 경로)
  /// 그 시각-10분부터 조회 — 재실행이 며칠 늦어도 크래시 시점 로그를 놓치지 않는다.
  /// (최대 7일 캡, 출력 개수는 MaxEvents/First 로 기존과 동일하게 제한)
  Future<String> _collectEventLog({int? sinceMs}) async {
    if (!Platform.isWindows) return '';
    double hoursBack = 1;
    if (sinceMs != null) {
      final h =
          (DateTime.now().millisecondsSinceEpoch - sinceMs) / 3600000 + 0.17;
      hoursBack = h.clamp(1.0, 168.0);
    }
    final appH = hoursBack.toStringAsFixed(2);
    final tdrH = hoursBack.clamp(2.0, 168.0).toStringAsFixed(2);
    final out = <String>[];
    // 1) Application 오류(앱 크래시 — 예외코드/죽은 모듈)
    try {
      final ps =
          "Get-WinEvent -FilterHashtable @{LogName='Application';Level=2;StartTime=(Get-Date).AddHours(-$appH)} "
          r"-MaxEvents 25 -ErrorAction SilentlyContinue | "
          r"Where-Object { $_.Message -match 'analog_timer|flutter|0xc0000005|0xc0000409' } | "
          r"Select-Object -First 6 | "
          r"ForEach-Object { '[APP] ' + $_.TimeCreated.ToString('MM-dd HH:mm:ss') + ' ' + $_.ProviderName + ': ' + ($_.Message.Split([char]10))[0] }";
      final r = await Process.run('powershell', ['-NoProfile', '-Command', ps])
          .timeout(const Duration(seconds: 10));
      final s = (r.stdout as String).trim();
      if (s.isNotEmpty) out.add(s);
    } catch (_) {}
    // 2) System: GPU TDR(디스플레이 드라이버 타임아웃 리셋) — '갑자기·반복' 크래시의
    //    핵심 후보. 4101=드라이버 복구됨, 4099/4100=TDR, 14=nvlddmkm 등 드라이버 오류.
    try {
      final ps =
          "Get-WinEvent -FilterHashtable @{LogName='System';Id=4101,4099,4100,14;StartTime=(Get-Date).AddHours(-$tdrH)} "
          r"-MaxEvents 8 -ErrorAction SilentlyContinue | "
          r"Select-Object -First 8 | "
          r"ForEach-Object { '[TDR/' + $_.Id + '] ' + $_.TimeCreated.ToString('MM-dd HH:mm:ss') + ' ' + $_.ProviderName + ': ' + ($_.Message.Split([char]10))[0] }";
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
