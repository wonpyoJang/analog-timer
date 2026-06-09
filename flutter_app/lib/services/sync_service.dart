import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../features/timer/models/segment.dart';

enum SyncStatus { offline, connecting, online, error }

/// 웹과 동일한 룸코드 동기화 프로토콜에서 받은 단일 이벤트.
/// (백엔드: `/api/room/{roomId}`, 24h TTL Upstash Redis)
class SyncEvent {
  final String action; // start | resume | pause | reset | next
  final int timestamp; // 발신 시각(ms) — start/resume 경과 보정용
  final int remainingMs;
  final int segIdx;
  final List<Map<String, dynamic>> segments; // 웹 포맷 {name, minutes, color}
  final bool loop;
  final String deviceId;
  final String? eventId;

  SyncEvent({
    required this.action,
    required this.timestamp,
    required this.remainingMs,
    required this.segIdx,
    required this.segments,
    required this.loop,
    required this.deviceId,
    this.eventId,
  });

  factory SyncEvent.fromJson(Map<String, dynamic> json) => SyncEvent(
        action: json['action'] as String? ?? '',
        timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
        remainingMs: (json['remaining_ms'] as num?)?.toInt() ?? 0,
        segIdx: (json['seg_idx'] as num?)?.toInt() ?? 0,
        segments: ((json['segments'] as List?) ?? const [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        loop: json['loop'] as bool? ?? false,
        deviceId: json['deviceId'] as String? ?? '',
        eventId: json['eventId'] as String?,
      );
}

/// Flutter [Segment] ↔ 웹 동기화 JSON 변환.
/// 웹은 color 를 '#rrggbb' 16진 문자열, minutes 를 number 로 사용한다.
class SyncCodec {
  static List<Map<String, dynamic>> toWebSegments(List<Segment> segments) =>
      segments
          .map((s) => {
                'name': s.name,
                'minutes': s.minutes,
                'color': _colorToHex(s.color),
              })
          .toList();

  static List<Segment> fromWebSegments(List<Map<String, dynamic>> raw) =>
      raw.map((m) {
        final minutes = (m['minutes'] as num?)?.round() ?? 1;
        return Segment(
          name: m['name']?.toString() ?? '',
          minutes: minutes.clamp(1, 600),
          color: _hexToColor(m['color']?.toString() ?? '#e07a52'),
        );
      }).toList();

  static String _colorToHex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  static Color _hexToColor(String s) {
    var h = s.replaceAll('#', '').trim();
    if (h.length == 6) h = 'ff$h';
    return Color(int.tryParse(h, radix: 16) ?? 0xFFE07A52);
  }
}

/// 룸코드 기반 멀티기기 동기화 클라이언트.
///
/// 웹앱과 동일한 REST 백엔드를 1초 간격으로 폴링하며, 로컬 타이머 동작은
/// [emit] 으로 발신한다. 자기 자신이 보낸 이벤트(deviceId 일치)는 무시한다.
class SyncService {
  // Vercel 웹 배포의 공개 엔드포인트 (서버 시크릿 불필요)
  static const _base = 'https://analog-timer-kappa.vercel.app/api/room';
  static const _kDeviceId = 'sync_device_id';

  final ValueNotifier<SyncStatus> status =
      ValueNotifier<SyncStatus>(SyncStatus.offline);
  final ValueNotifier<String?> roomId = ValueNotifier<String?>(null);

  /// 원격 이벤트 수신 콜백. 적용 중 echo 발신을 막는 책임은 호출측에 있다.
  void Function(SyncEvent event)? onRemoteEvent;

  String? _deviceId;
  String? _lastEventId;
  Timer? _poll;

  Future<void> _ensureDeviceId() async {
    if (_deviceId != null) return;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_kDeviceId);
    if (id == null) {
      id = _randomString(12, _lowerAlnum);
      await prefs.setString(_kDeviceId, id);
    }
    _deviceId = id;
  }

  static const _lowerAlnum = 'abcdefghijklmnopqrstuvwxyz0123456789';
  static const _roomAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  static String _randomString(int n, String alphabet) {
    final r = Random();
    return List.generate(n, (_) => alphabet[r.nextInt(alphabet.length)]).join();
  }

  /// 새 방 코드(6자리 대문자/숫자) 생성.
  static String randomRoomCode() => _randomString(6, _roomAlphabet);

  /// 방 참가 — 코드를 정규화하고 즉시 1회 조회 후 1초 폴링 시작.
  Future<void> join(String code) async {
    await _ensureDeviceId();
    final normalized =
        code.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (normalized.length < 4) return;
    roomId.value =
        normalized.substring(0, min(8, normalized.length));
    _lastEventId = null;
    status.value = SyncStatus.connecting;
    await _fetch();
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 1), (_) => _fetch());
  }

  void leave() {
    _poll?.cancel();
    _poll = null;
    roomId.value = null;
    _lastEventId = null;
    status.value = SyncStatus.offline;
  }

  Future<void> _fetch() async {
    final id = roomId.value;
    if (id == null) return;
    try {
      final res = await http
          .get(Uri.parse('$_base/$id'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) {
        status.value = SyncStatus.error;
        return;
      }
      status.value = SyncStatus.online;
      if (res.body.isEmpty || res.body == 'null') return;
      final data = jsonDecode(res.body);
      if (data is! Map) return;
      final eventId = data['eventId'] as String?;
      if (eventId == _lastEventId) return; // 변화 없음
      if (data['deviceId'] == _deviceId) {
        _lastEventId = eventId; // 내가 보낸 이벤트 — 무시
        return;
      }
      _lastEventId = eventId;
      onRemoteEvent?.call(SyncEvent.fromJson(Map<String, dynamic>.from(data)));
    } catch (_) {
      status.value = SyncStatus.error;
    }
  }

  Future<void> emit({
    required String action,
    required int remainingMs,
    required int segIdx,
    required List<Map<String, dynamic>> segments,
    required bool loop,
  }) async {
    final id = roomId.value;
    if (id == null || _deviceId == null) return;
    final body = jsonEncode({
      'action': action,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'remaining_ms': remainingMs,
      'seg_idx': segIdx,
      'segments': segments,
      'loop': loop,
      'deviceId': _deviceId,
    });
    try {
      final res = await http
          .post(
            Uri.parse('$_base/$id'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 5));
      final data = jsonDecode(res.body);
      if (data is Map) _lastEventId = data['eventId'] as String?;
    } catch (_) {
      // 발신 실패는 무시 — 다음 폴링에서 보정.
    }
  }

  void dispose() {
    _poll?.cancel();
    status.dispose();
    roomId.dispose();
  }
}
