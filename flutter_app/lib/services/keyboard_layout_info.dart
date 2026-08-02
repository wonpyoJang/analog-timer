import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'platform_info.dart';

/// 설치된 키보드 레이아웃으로 전역 핫키 기본 조합을 고르기 위한 판별.
///
/// 배경: 유럽계 레이아웃(독/프/스페인 등)에서 오른쪽 Alt(AltGr)는
/// Ctrl+Alt 와 동일하게 취급된다 — Ctrl+Alt+키를 전역 등록하면 그 키의
/// AltGr 문자 입력(€, ę, @ …)이 **시스템 전체에서** 막힌다. 그래서
/// AltGr 레이아웃이 하나라도 설치돼 있으면 기본 조합을 3-모디파이어
/// (Ctrl+Shift+Alt)로 유지하고, 없을 때만 누르기 쉬운 Ctrl+Alt 를 쓴다.
/// (Ctrl+Shift+Alt+키 4키 동시 입력은 멤브레인 키보드 고스팅으로
///  안 눌리는 환경이 있다 — 실사용 리포트)
///
/// 판별은 UI 로케일이 아니라 **설치된 자판 레이아웃**(GetKeyboardLayoutList,
/// HKL 하위 16비트 = 언어 ID) 기준 — 독일어 UI 에 US 자판을 쓰는 사용자를
/// 오판하지 않는다. 알 수 없는 레이아웃은 보수적으로 "AltGr 있음" 취급
/// (fail-safe: 최악이 '현행 유지'가 되도록).
final DynamicLibrary _user32 = DynamicLibrary.open('user32.dll');
final int Function(int, Pointer<IntPtr>) _getKeyboardLayoutList = _user32
    .lookupFunction<
      Int32 Function(Int32, Pointer<IntPtr>),
      int Function(int, Pointer<IntPtr>)
    >('GetKeyboardLayoutList');

/// AltGr 를 쓰지 않는 것이 확실한 자판 언어 ID 허용 목록.
/// (전체 LANGID — en-GB(0x0809)는 AltGr 가 있어 primary 언어만으로는
///  en-US 와 구분이 안 되므로 서브언어까지 본다)
const _noAltGrLangIds = {
  0x0412, // 한국어
  0x0409, // English (US)
  0x0411, // 일본어
  0x0404, 0x0804, 0x0c04, 0x1004, 0x1404, // 중국어(TW/PRC/HK/SG/MO)
  0x0419, // 러시아어(ЙЦУКЕН)
  0x0421, // 인도네시아어(US 배열)
};

/// 설치된 모든 레이아웃이 AltGr 없음이 확실할 때만 true.
/// Windows 외 데스크톱(mac/linux)과 판별 실패 시엔 false(현행 조합 유지).
bool computeSimpleComboSafe() {
  if (!isWindows) return false;
  try {
    final n = _getKeyboardLayoutList(0, nullptr);
    if (n <= 0) return false;
    final buf = calloc<IntPtr>(n);
    try {
      final got = _getKeyboardLayoutList(n, buf);
      if (got <= 0) return false;
      for (var i = 0; i < got; i++) {
        if (!_noAltGrLangIds.contains(buf[i] & 0xFFFF)) return false;
      }
      return true;
    } finally {
      calloc.free(buf);
    }
  } catch (_) {
    return false;
  }
}
