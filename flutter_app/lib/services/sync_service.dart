import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 기기 간 동기화 — 페어링(6자리 코드) 후 roomId 로 타이머/프리셋/설정을
/// 공유한다. 데스크톱·모바일 공용(web 제외). 충돌은 last-write-wins(ts).
///
/// 적용은 앱이 콜백(onTimer/onPresets/onSettings)으로 받아 처리한다.
class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  static const String _base = 'https://analog-timer-kappa.vercel.app/api';
  static const String _kRoomId = 'sync_room_id';
  static const String _kDeviceId = 'sync_device_id';

  String? _roomId;
  String? _deviceId;
  Timer? _pullTimer;
  final Map<String, int> _lastTs = {}; // kind별 마지막 적용 ts(자기 push 포함)

  bool get supported => !kIsWeb;
  bool get connected => _roomId != null;
  String? get roomId => _roomId;

  /// pull 로 받은 데이터를 앱에 반영하는 콜백.
  void Function(Map<String, dynamic> data)? onTimer;
  void Function(List<dynamic> data)? onPresets;
  void Function(Map<String, dynamic> data)? onSettings;

  Future<void> init() async {
    if (!supported) return;
    final p = await SharedPreferences.getInstance();
    _deviceId = p.getString(_kDeviceId) ?? _genId();
    await p.setString(_kDeviceId, _deviceId!);
    _roomId = p.getString(_kRoomId);
    if (_roomId != null) {
      _startPull();
      unawaited(_pull());
    }
  }

  /// 페어링 코드 발급 — 이 기기가 새 기기를 초대(없으면 첫 room 생성).
  Future<({String code, String roomId})?> createPairing() async {
    if (!supported) return null;
    final res = await _post('$_base/pair', {
      'action': 'create',
      if (_roomId != null) 'roomId': _roomId,
    });
    final code = res?['code'] as String?;
    final room = res?['roomId'] as String?;
    if (code == null || room == null) return null;
    await _setRoom(room);
    return (code: code, roomId: room);
  }

  /// 코드로 참여 — 다른 기기의 6자리 코드를 입력해 같은 room 에 합류.
  Future<bool> joinWithCode(String code) async {
    if (!supported) return false;
    final res = await _post('$_base/pair', {'action': 'redeem', 'code': code});
    final room = res?['roomId'] as String?;
    if (room == null) return false;
    await _setRoom(room);
    await _pull(); // 합류 즉시 현재 상태 받기
    return true;
  }

  Future<void> disconnect() async {
    _pullTimer?.cancel();
    _pullTimer = null;
    _roomId = null;
    _lastTs.clear();
    final p = await SharedPreferences.getInstance();
    await p.remove(_kRoomId);
  }

  Future<void> _setRoom(String room) async {
    _roomId = room;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kRoomId, room);
    _startPull();
  }

  void _startPull() {
    _pullTimer?.cancel();
    _pullTimer = Timer.periodic(const Duration(seconds: 5), (_) => _pull());
  }

  // ── push ──────────────────────────────────────────────────────
  Future<void> pushTimer(Map<String, dynamic> data) => _push('timer', data);
  Future<void> pushPresets(List<dynamic> data) => _push('presets', data);
  Future<void> pushSettings(Map<String, dynamic> data) => _push('settings', data);

  Future<void> _push(String kind, dynamic data) async {
    if (!connected || !supported) return;
    final ts = DateTime.now().millisecondsSinceEpoch;
    _lastTs[kind] = ts; // 자기 push 는 pull 시 재적용하지 않도록 선기록
    await _post('$_base/sync?roomId=$_roomId', {
      'deviceId': _deviceId,
      'kind': kind,
      'data': data,
      'ts': ts,
    });
  }

  // ── pull ──────────────────────────────────────────────────────
  Future<void> _pull() async {
    if (!connected || !supported) return;
    final res = await _get('$_base/sync?roomId=$_roomId');
    if (res == null) return;
    _applyKind('timer', res['timer'],
        (d) => onTimer?.call(d as Map<String, dynamic>));
    _applyKind('presets', res['presets'],
        (d) => onPresets?.call(d as List<dynamic>));
    _applyKind('settings', res['settings'],
        (d) => onSettings?.call(d as Map<String, dynamic>));
  }

  void _applyKind(String kind, dynamic entry, void Function(dynamic) apply) {
    if (entry is! Map) return;
    final ts = (entry['ts'] as num?)?.toInt();
    final data = entry['data'];
    if (ts == null || data == null) return;
    if (ts <= (_lastTs[kind] ?? 0)) return; // 이미 본 것(또는 자기 것)
    _lastTs[kind] = ts;
    apply(data);
  }

  // ── http ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> _post(
      String url, Map<String, dynamic> body) async {
    HttpClient? c;
    try {
      c = HttpClient()..connectionTimeout = const Duration(seconds: 8);
      final req = await c.postUrl(Uri.parse(url));
      req.headers.contentType = ContentType.json;
      req.add(utf8.encode(jsonEncode(body)));
      final res = await req.close().timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        await res.drain<void>();
        return null;
      }
      return jsonDecode(await utf8.decoder.bind(res).join())
          as Map<String, dynamic>;
    } catch (_) {
      return null;
    } finally {
      c?.close(force: true);
    }
  }

  Future<Map<String, dynamic>?> _get(String url) async {
    HttpClient? c;
    try {
      c = HttpClient()..connectionTimeout = const Duration(seconds: 8);
      final req = await c.getUrl(Uri.parse(url));
      final res = await req.close().timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        await res.drain<void>();
        return null;
      }
      return jsonDecode(await utf8.decoder.bind(res).join())
          as Map<String, dynamic>;
    } catch (_) {
      return null;
    } finally {
      c?.close(force: true);
    }
  }

  String _genId() {
    final r = Random.secure();
    return List.generate(
        12, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }
}
