import 'dart:io';
import 'platform_info.dart';

/// 네이티브 확인 대화상자.
///
/// **Flutter 다이얼로그를 쓰지 않는 이유**: 재시작이 가장 필요한 순간은 렌더가
/// 죽어 화면이 얼어붙었을 때다. 그 상태에서 Flutter 로 그린 확인창은 보이지
/// 않는다(그리는 주체가 죽었으므로). OS 가 그리는 네이티브 창이어야 한다.
///
/// WScript.Shell Popup 을 쓰는 이유: .NET 어셈블리 로드 없이 빠르고,
/// **자동 타임아웃**을 지원해 "N초 후 자동 진행" 형태를 그대로 만들 수 있다.
/// system-modal(4096) 이라 always-on-top 위젯 위에도 뜬다.
///
/// 반환: true=확인, false=취소, null=타임아웃/실패(응답 없음).
Future<bool?> nativeConfirm({
  required String title,
  required String message,
  int timeoutSeconds = 0,
}) async {
  if (!isWindows) return true; // 다른 플랫폼은 호출측이 별도 처리
  String esc(String s) => s.replaceAll("'", "''");
  // 4096(system modal) + 1(확인/취소)
  final script =
      "exit (New-Object -ComObject WScript.Shell).Popup("
      "'${esc(message)}', $timeoutSeconds, '${esc(title)}', 4097)";
  try {
    final r =
        await Process.run('powershell', [
          '-NoProfile',
          '-Command',
          script,
        ]).timeout(
          Duration(seconds: timeoutSeconds > 0 ? timeoutSeconds + 20 : 600),
        );
    if (r.exitCode == 1) return true;
    if (r.exitCode == 2) return false;
    return null; // -1(타임아웃) 등
  } catch (_) {
    return null;
  }
}
