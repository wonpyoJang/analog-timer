import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 사용자 피드백(버그/기능요청) 전송 — 사진·동영상 첨부 지원.
///
/// 첨부는 서버(4.5MB 제한)를 거치지 않고, 서버가 발급한 단기 업로드 토큰으로
/// Vercel Blob 에 **직접 스트리밍 PUT** 한다(동영상 수백 MB 도 OK).
class FeedbackService {
  FeedbackService._();
  static final FeedbackService instance = FeedbackService._();

  static const String _base = 'https://analog-timer-kappa.vercel.app/api';

  bool get supported => !kIsWeb;

  /// 파일 1개 업로드 → 첨부 메타(url/name/size/contentType) 반환. 실패 시 null.
  /// [onProgress] 는 0.0~1.0.
  Future<Map<String, dynamic>?> uploadAttachment(
    File file, {
    void Function(double progress)? onProgress,
  }) async {
    if (!supported) return null;
    final name = file.uri.pathSegments.last;
    final size = await file.length();
    final contentType = _guessType(name);
    if (contentType == null) return null;

    // 1) presigned 업로드 URL 발급 (서버가 OIDC 로 서명 — 클라이언트 인증 불필요)
    final tok = await _postJson('$_base/feedback', {
      'action': 'upload-token',
      'filename': name,
      'contentType': contentType,
      'size': size,
    });
    final uploadUrl = tok?['uploadUrl'] as String?;
    final pathname = tok?['pathname'] as String?;
    if (uploadUrl == null) return null;

    // 2) Blob 에 직접 스트리밍 PUT (파일을 통째로 메모리에 올리지 않음)
    HttpClient? c;
    try {
      c = HttpClient()..connectionTimeout = const Duration(seconds: 20);
      final req = await c.putUrl(Uri.parse(uploadUrl));
      req.headers.contentType = ContentType.parse(contentType);
      req.contentLength = size;
      var sent = 0;
      await for (final chunk in file.openRead()) {
        req.add(chunk);
        sent += chunk.length;
        onProgress?.call(sent / size);
        // 백프레셔 — 소켓 버퍼가 비워질 시간을 준다(대용량 안정성)
        if (sent % (4 << 20) < chunk.length) await req.flush();
      }
      final res = await req.close().timeout(const Duration(minutes: 30));
      final body = await utf8.decoder.bind(res).join();
      if (res.statusCode != 200) return null;
      // 응답 JSON 의 url 우선, 없으면 presigned URL 에서 공개 URL 유도
      String? url;
      try {
        final j = jsonDecode(body) as Map<String, dynamic>;
        url = (j['url'] ?? j['downloadUrl']) as String?;
      } catch (_) {}
      url ??= _publicUrlFrom(uploadUrl, pathname);
      if (url == null) return null;
      return {
        'url': url,
        'name': name,
        'size': size,
        'contentType': contentType,
      };
    } catch (_) {
      return null;
    } finally {
      c?.close(force: true);
    }
  }

  /// 피드백 제출. [attachments] 는 uploadAttachment 반환값 목록.
  Future<bool> submit({
    required String category, // bug | feature | other
    required String message,
    String? contact,
    List<Map<String, dynamic>> attachments = const [],
  }) async {
    if (!supported) return false;
    final p = await SharedPreferences.getInstance();
    final deviceId = p.getString('telemetry_device_id') ?? 'unknown';
    final res = await _postJson('$_base/feedback', {
      'deviceId': deviceId,
      'category': category,
      'message': message,
      if (contact != null && contact.trim().isNotEmpty) 'contact': contact.trim(),
      'attachments': attachments,
      'appVersion': '0.4.0+6',
      'platform': defaultTargetPlatform.name,
    });
    return res?['ok'] == true;
  }

  /// presigned URL(호스트에 스토어 ID 포함)에서 업로드 완료 후의 공개 URL 을 유도.
  String? _publicUrlFrom(String uploadUrl, String? pathname) {
    if (pathname == null) return null;
    try {
      final host = Uri.parse(uploadUrl).host; // <storeid>.blob.vercel-storage.com 형태
      final storeId = host.split('.').first;
      if (storeId.isEmpty) return null;
      return 'https://$storeId.public.blob.vercel-storage.com/$pathname';
    } catch (_) {
      return null;
    }
  }

  String? _guessType(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.jpg') || n.endsWith('.jpeg')) return 'image/jpeg';
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.gif')) return 'image/gif';
    if (n.endsWith('.webp')) return 'image/webp';
    if (n.endsWith('.heic')) return 'image/heic';
    if (n.endsWith('.mp4')) return 'video/mp4';
    if (n.endsWith('.mov')) return 'video/quicktime';
    if (n.endsWith('.webm')) return 'video/webm';
    if (n.endsWith('.mkv')) return 'video/x-matroska';
    return null;
  }

  Future<Map<String, dynamic>?> _postJson(
      String url, Map<String, dynamic> body) async {
    HttpClient? c;
    try {
      c = HttpClient()..connectionTimeout = const Duration(seconds: 10);
      final req = await c.postUrl(Uri.parse(url));
      req.headers.contentType = ContentType.json;
      req.add(utf8.encode(jsonEncode(body)));
      final res = await req.close().timeout(const Duration(seconds: 15));
      final s = await utf8.decoder.bind(res).join();
      if (res.statusCode != 200) return null;
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return null;
    } finally {
      c?.close(force: true);
    }
  }
}
