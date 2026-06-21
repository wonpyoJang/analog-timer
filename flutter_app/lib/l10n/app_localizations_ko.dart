// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '아날로그 타이머';

  @override
  String get save => '저장';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get manage => '관리';

  @override
  String get timerSection => '타이머';

  @override
  String get btnStart => '시작';

  @override
  String get btnPause => '일시정지';

  @override
  String get btnResume => '다시 시작';

  @override
  String get btnRunning => '진행 중…';

  @override
  String get btnNext => '다음';

  @override
  String get btnReset => '초기화';

  @override
  String get stopwatchSection => '스톱워치';

  @override
  String get btnLap => '랩';

  @override
  String lapToast(int num, String time) {
    return '랩 $num    $time';
  }

  @override
  String get timerSegments => '타이머 세그먼트';

  @override
  String get addSegment => '+ 세그먼트 추가';

  @override
  String get loopToggle => '연속 반복';

  @override
  String get minutesUnit => '분';

  @override
  String get segmentColor => '세그먼트 색상';

  @override
  String get segments => '세그먼트';

  @override
  String get savePresetChip => '현재 구성 저장';

  @override
  String presetApplied(String name) {
    return '프리셋 추가 · $name';
  }

  @override
  String get noSegmentsToSave => '저장할 세그먼트가 없습니다';

  @override
  String get savePresetTitle => '프리셋 저장';

  @override
  String get presetNameHint => '예: 공부 50/10';

  @override
  String get presetName => '프리셋 이름';

  @override
  String get presetManageTitle => '프리셋 관리';

  @override
  String get newPreset => '새 프리셋';

  @override
  String get editPreset => '프리셋 편집';

  @override
  String get deletePresetTitle => '프리셋 삭제';

  @override
  String deletePresetConfirm(String name) {
    return '\'$name\' 을(를) 삭제할까요?';
  }

  @override
  String get noPresets => '저장된 프리셋이 없습니다.\n우측 상단 \"새 프리셋\" 으로 추가하세요.';

  @override
  String get enterName => '이름을 입력하세요';

  @override
  String get atLeastOneSegment => '세그먼트를 1개 이상 추가하세요';

  @override
  String get legendTimer => '타이머 — 안쪽 나선';

  @override
  String get legendStopwatch => '스톱워치 — 바깥 링';

  @override
  String get statusDone => '완료';

  @override
  String get statusWaiting => '대기 중';

  @override
  String get widget => '위젯';

  @override
  String get widgetOn => '위젯 ON';

  @override
  String get notifyTimerDoneTitle => '타이머 완료';

  @override
  String get notifyTimerDoneBody => '모든 세그먼트를 마쳤습니다 🎉';

  @override
  String get notifySegmentDoneTitle => '세그먼트 완료';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev 완료 · 다음: $next';
  }

  @override
  String get language => '언어';

  @override
  String get languageSystem => '시스템 기본값';

  @override
  String get presetPomodoro => '뽀모도로 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => '딥워크 90/20';

  @override
  String get segFocus => '집중';

  @override
  String get segBreak => '휴식';

  @override
  String get stopwatchLaps => '스톱워치 랩';

  @override
  String get noLaps => '랩 기록 없음';

  @override
  String get timerLogTitle => '타이머 로그';

  @override
  String get noEvents => '이벤트 없음';

  @override
  String lapLabel(int num) {
    return '랩 $num';
  }

  @override
  String logStart(String name) {
    return '시작: $name';
  }

  @override
  String get logPaused => '일시정지';

  @override
  String get logReset => '리셋';

  @override
  String logSkipped(String name) {
    return '건너뜀: $name';
  }

  @override
  String logDone(String name) {
    return '완료: $name';
  }

  @override
  String get logAllDone => '모든 세그먼트 완료 🎉';

  @override
  String logLoop(String count) {
    return '🔁 루프 $count회 완료';
  }

  @override
  String get batteryLow => '배터리 부족 — 충전해 주세요';

  @override
  String get batteryMon => '배터리';

  @override
  String get batteryMonOn => '배터리 ON';

  @override
  String get settings => '설정';

  @override
  String get settingsBattery => '배터리 모니터링';

  @override
  String get settingsBatteryDesc => '배터리가 20% 이하로 내려가면 경고';

  @override
  String get settingsLanguage => '언어';
}
