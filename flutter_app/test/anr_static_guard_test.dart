import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// [ANR-정적가드] 소스에서 "알려진 ANR 원인" 패턴이 되살아나면 실패한다.
///
/// 행위 테스트로 검증 불가능한(네이티브 Kotlin) 또는 하네스 비용이 큰(HomeScreen
/// 위젯) 불변식을 소스 텍스트 검사로 값싸게 고정한다. 리팩터에 취약하므로 진짜
/// 회귀락은 행위 테스트(multi_timer_anr_guard_test.dart)이고, 이건 조기경보·이중화.
///
/// 실행 CWD 는 flutter_app/ (flutter test 관례).
void main() {
  /// `//` 로 시작하는 라인(주석)을 제거해 주석 속 언급은 무시한다.
  String stripLineComments(String src) =>
      src.split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');

  test('[ANR#1] MainActivity 오버레이 경로에 startForegroundService 호출 없음', () {
    // FGS 데드라인 ANR(ForegroundServiceDidNotStartInTimeException) 원인.
    // 오버레이는 앱 포그라운드에서 켜지므로 startService 로 시작해야 한다.
    final f = File(
      'android/app/src/main/kotlin/dev/analogtimer/analog_timer/MainActivity.kt',
    );
    expect(f.existsSync(), isTrue, reason: 'MainActivity.kt 경로 확인 필요');
    final code = stripLineComments(f.readAsStringSync());
    expect(
      code.contains('startForegroundService('),
      isFalse,
      reason:
          'startForegroundService() 재도입 = FGS 데드라인 ANR 위험. startService() 를 사용하라.',
    );
  });

  test('[ANR#2] MultiTimerBloc 티커 간격 >= 200ms', () {
    // 촘촘한 티커(16ms)는 리스트를 60fps 재빌드해 메인스레드 포화 → 입력 굶김 ANR.
    final f = File('lib/features/multi_timer/bloc/multi_timer_bloc.dart');
    expect(f.existsSync(), isTrue);
    final code = f.readAsStringSync();
    final re = RegExp(
      r'Timer\.periodic\(\s*const\s+Duration\(milliseconds:\s*(\d+)',
    );
    final matches = re.allMatches(code).toList();
    expect(matches, isNotEmpty, reason: '티커가 사라짐 — 검사 대상 부재(테스트 갱신 필요)');
    for (final m in matches) {
      final ms = int.parse(m.group(1)!);
      expect(
        ms,
        greaterThanOrEqualTo(200),
        reason: '티커 간격 ${ms}ms — 200ms 미만은 UI 과다 재빌드로 입력 굶김/ANR 위험.',
      );
    }
  });

  test('[ANR#2] HomeScreen 클록 티커에 active 게이트 존재', () {
    // 비활성 탭(IndexedStack)에서 60fps 시계 재빌드를 멈춰 메인스레드 부하를 없앤다.
    final f = File('lib/home_screen.dart');
    expect(f.existsSync(), isTrue);
    final code = f.readAsStringSync();
    expect(
      code.contains('!widget.active'),
      isTrue,
      reason: 'HomeScreen 클록 티커의 active 게이트가 사라짐 — 숨겨진 탭에서 60fps 재빌드 재발 위험.',
    );
  });

  test('[ANR#2] RootShell 이 HomeScreen 에 active 전달', () {
    final f = File('lib/root_shell.dart');
    expect(f.existsSync(), isTrue);
    final code = f.readAsStringSync();
    expect(
      RegExp(r'HomeScreen\(\s*active:').hasMatch(code),
      isTrue,
      reason: 'RootShell 이 active 를 전달하지 않으면 게이트가 항상 true(기본값)로 무력화된다.',
    );
  });
}
