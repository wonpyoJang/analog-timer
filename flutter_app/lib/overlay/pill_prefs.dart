import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:screen_retriever/screen_retriever.dart';

/// pill 서브윈도우 공용 위치 저장 — 이름별 전용 JSON 파일.
///
/// SharedPreferences 금지(서브엔진의 prefs 스냅샷 재작성이 메인 상태를
/// 롤백시키는 race — desktop_overlay.dart 참고). 창(이름)마다 별도 파일이라
/// pill 엔진 간 경합도 없다.
File pillPrefsFile(String name) {
  final appdata = Platform.environment['APPDATA'];
  final base = (Platform.isWindows && appdata != null)
      ? '$appdata\\dev.analogtimer\\analog_timer'
      : Directory.systemTemp.path;
  return File('$base${Platform.pathSeparator}analog_timer_pill_$name.json');
}

Future<Offset?> loadPillPos(String name) async {
  try {
    final f = pillPrefsFile(name);
    if (await f.exists()) {
      final m = (jsonDecode(await f.readAsString()) as Map)
          .cast<String, dynamic>();
      final x = (m['x'] as num?)?.toDouble();
      final y = (m['y'] as num?)?.toDouble();
      if (x != null && y != null) return Offset(x, y);
    }
  } catch (_) {}
  return null;
}

Future<void> savePillPos(String name, Offset pos) async {
  try {
    final f = pillPrefsFile(name);
    await f.parent.create(recursive: true);
    await f.writeAsString(jsonEncode({'x': pos.dx, 'y': pos.dy}));
  } catch (_) {}
}

/// 저장된 위치가 현재 어느 디스플레이에도 없으면(모니터 해제 등) 무시.
Future<bool> pillPosOnAnyDisplay(Offset pos, Size pillSize) async {
  try {
    final displays = await screenRetriever.getAllDisplays();
    for (final d in displays) {
      final p = d.visiblePosition ?? Offset.zero;
      final s = d.visibleSize ?? d.size;
      if (pos.dx >= p.dx - pillSize.width + 40 &&
          pos.dx <= p.dx + s.width - 40 &&
          pos.dy >= p.dy - 10 &&
          pos.dy <= p.dy + s.height - 30) {
        return true;
      }
    }
  } catch (_) {}
  return false;
}
