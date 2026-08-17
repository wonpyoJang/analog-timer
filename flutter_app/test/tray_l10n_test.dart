import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:analog_timer/l10n/app_localizations.dart';

// 트레이 메뉴는 위젯 트리 밖에서 lookupAppLocalizations 로 라벨을 얻는다.
// ko/en 값과 부분 로케일(de)의 en 템플릿 폴백을 확정한다.
void main() {
  test(
    'tray labels: ko/en values + partial-locale fallback to en template',
    () {
      final ko = lookupAppLocalizations(const Locale('ko'));
      expect(ko.trayShow, '열기');
      expect(ko.trayMulti, '멀티 타이머');
      expect(ko.trayRestart, '다시 시작 (화면 멈춤 해소)');
      expect(ko.trayQuit, '종료');

      final en = lookupAppLocalizations(const Locale('en'));
      expect(en.trayShow, 'Open');
      expect(en.trayQuit, 'Quit');

      // de 는 부분 번역(114키) — 트레이 키 미포함이라 en 템플릿으로 폴백.
      final de = lookupAppLocalizations(const Locale('de'));
      expect(de.trayShow, 'Open');
      expect(de.trayQuit, 'Quit');
    },
  );
}
