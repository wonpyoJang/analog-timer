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

  @override
  String get modeLabelLog => '로그';

  @override
  String get modeLabelToday => '오늘';

  @override
  String get modeLabelPlan => '계획';

  @override
  String get dayLogTitle => '이 날의 기록';

  @override
  String get dayLogEmpty => '이 날에는 기록이 없습니다';

  @override
  String get dayPlanTitle => '이 날의 계획';

  @override
  String get dayPlanEmpty => '이 날에는 계획이 없습니다';

  @override
  String get planSaveAsCurrent => '현재 세그먼트로 저장';

  @override
  String get planLoadIntoTimer => '타이머에 불러오기';

  @override
  String get planSave => '저장';

  @override
  String get telemetryConsentTitle => 'Analog Timer 개선에 참여';

  @override
  String get telemetryConsentBody =>
      '앱이 예기치 않게 종료되면, 원인 파악을 위해 익명 진단 정보(기기 환경·오류 로그)를 개발자에게 보냅니다. 개인정보나 타이머 내용은 포함되지 않습니다. 설정에서 언제든 끌 수 있습니다.';

  @override
  String get telemetryAllow => '허용';

  @override
  String get telemetryDeny => '보내지 않음';

  @override
  String get telemetryReportSetting => '진단 데이터 전송';

  @override
  String get feedbackTitle => '피드백 보내기';

  @override
  String get feedbackEntry => '제작자에게 피드백 보내기';

  @override
  String get feedbackEntryDesc => '버그 신고·기능 요청 (사진/동영상 첨부 가능)';

  @override
  String get feedbackCategoryBug => '버그';

  @override
  String get feedbackCategoryFeature => '기능 요청';

  @override
  String get feedbackCategoryOther => '기타';

  @override
  String get feedbackMessageHint => '버그 상황이나 원하는 기능을 적어주세요…';

  @override
  String get feedbackContactHint => '연락처 (선택 — 답변 받을 이메일 등)';

  @override
  String get feedbackAttachPhoto => '사진 첨부';

  @override
  String get feedbackAttachVideo => '동영상 첨부';

  @override
  String get feedbackRecordVoice => '음성 녹음';

  @override
  String get feedbackRecording => '녹음 중… 탭하여 종료';

  @override
  String get feedbackMicDenied => '마이크를 사용할 수 없습니다 — 시스템 설정에서 권한을 확인해주세요';

  @override
  String get feedbackSend => '보내기';

  @override
  String get feedbackSent => '감사합니다! 피드백이 전송되었습니다.';

  @override
  String get feedbackFailed => '전송 실패 — 네트워크 확인 후 다시 시도해주세요';

  @override
  String get feedbackMessageRequired => '내용을 먼저 적어주세요';

  @override
  String get feedbackIncludeLogs => '진단 로그 함께 보내기 (기기 환경·최근 사용 흐름 — 개인정보 미포함)';

  @override
  String get reviewPromptTitle => '아날로그 타이머, 잘 쓰고 계신가요?';

  @override
  String get reviewPromptBody =>
      '방금 세션을 완주하셨네요, 수고하셨습니다! 🎉\n잠깐 시간이 되시면 좋았던 점이나 아쉬운 점을 들려주세요. 개발에 큰 힘이 됩니다.';

  @override
  String get reviewPromptAccept => '의견 보내기';

  @override
  String get reviewPromptLater => '나중에';

  @override
  String get reviewPromptNever => '다시 묻지 않기';

  @override
  String get syncPageTitle => '기기 연결';

  @override
  String get syncConnected => '✓ 연결됨';

  @override
  String syncRoomLabel(String id) {
    return '방 코드: $id';
  }

  @override
  String get syncRoomDesc => '이 방의 모든 기기끼리 타이머·프리셋·설정이 동기화됩니다.';

  @override
  String get syncAddDevice => '다른 기기 더 추가';

  @override
  String get syncInviteTitle => '이 기기로 초대';

  @override
  String get syncInviteDesc => '다른 기기에서 QR을 스캔하거나 6자리 코드를 입력하면 연결됩니다.';

  @override
  String get syncCreateCode => '초대 코드 만들기';

  @override
  String get syncJoinTitle => '코드로 연결';

  @override
  String get syncJoinDesc => '다른 기기에 표시된 6자리 코드를 입력하세요.';

  @override
  String get syncJoinBtn => '연결';

  @override
  String get syncDisconnect => '연결 해제';

  @override
  String get syncExpiry => '5분 안에 다른 기기에서 스캔하거나 입력하세요';

  @override
  String get syncErrorNetwork => '코드 발급 실패 — 네트워크를 확인하세요';

  @override
  String get syncErrorCode => '코드가 틀리거나 만료되었습니다';

  @override
  String get syncErrorCodeLen => '6자리 코드를 입력하세요';

  @override
  String get syncScanQr => 'QR 스캔';

  @override
  String get syncScanCancel => '취소';

  @override
  String get tipWidgetToggle => '플로팅 위젯 켜기/끄기';

  @override
  String get tipWidgetRefresh => '위젯 새로고침 — 위젯이 멈추거나 사라졌을 때';

  @override
  String get tipAppRestart => '앱 다시 시작 (화면 멈춤 해소) — 기록과 경과 시간은 유지됩니다';

  @override
  String get tipOverlayOpacity => '위젯 투명도 조절';

  @override
  String get tipOverlayResize => '드래그하여 위젯 크기 조절';

  @override
  String get tipOverlayHide => '위젯 숨기기';

  @override
  String get tipStopwatchToggle => '스톱워치 시작/정지';

  @override
  String get settingsTts => '음성 안내';

  @override
  String get settingsTtsDesc => '세그먼트 전환과 타이머 완료를 소리로 알려줍니다';

  @override
  String get settingsTtsSample => '음성 안내가 켜졌습니다';

  @override
  String get ttsOnboardBody => '방금 같은 세그먼트 전환을 소리로도 알려드릴 수 있어요';

  @override
  String get ttsOnboardEnable => '켜보기';

  @override
  String get ttsVoiceMissingHint =>
      'Windows 설정 > 시간 및 언어 > 음성에서 한국어 음성을 추가하면 더 자연스러워요';

  @override
  String get menuMore => '더보기';

  @override
  String get menuSettingsHint => '언어 · 알림 · 배터리';

  @override
  String get menuTroubleshoot => '문제 해결';

  @override
  String get menuAutoRecoveryNote => '멈춤 자동 감지·복구 켜짐 — 보통 직접 누를 일이 없습니다.';

  @override
  String get shortcutSheetTitle => '키보드 단축키';

  @override
  String get shortcutGlobalSection => '어디서든 (전역)';

  @override
  String get shortcutInAppSection => '이 창이 포커스일 때';

  @override
  String get shortcutTimerToggle => '타이머 시작/일시정지';

  @override
  String get shortcutTimerNext => '다음 세그먼트';

  @override
  String get shortcutSwToggle => '스톱워치 시작/정지';

  @override
  String get shortcutSwLap => '랩';

  @override
  String get shortcutWidgetToggle => '위젯 켜기/끄기';

  @override
  String get shortcutWidgetMove => '위젯 이동 (위젯을 먼저 클릭)';

  @override
  String get shortcutWidgetAnchor => '위젯 3×3 그리드 스냅';

  @override
  String get shortcutWidgetMirror => '위젯 반대편으로 대칭 이동';

  @override
  String get keysHintTimerToggle =>
      '💡 Space 또는 Ctrl+Alt+Space로도 시작/일시정지할 수 있어요';

  @override
  String get keysHintTimerNext => '💡 N 또는 Ctrl+Alt+N으로도 다음 세그먼트로 넘어갈 수 있어요';

  @override
  String get keysHintSwToggle => '💡 S 키로도 스톱워치를 시작/정지할 수 있어요';

  @override
  String get keysHintSwLap => '💡 L 또는 Ctrl+Alt+L로도 랩을 찍을 수 있어요';

  @override
  String get menuShortcuts => '단축키';

  @override
  String get settingsHotkeys => '전역 단축키';

  @override
  String get settingsHotkeysDesc =>
      '다른 앱을 쓰는 중에도 동작해요. 아래 항목을 눌러 키를 바꿀 수 있어요. 창 안에선 Space·N·S·L·W';

  @override
  String get hotkeyReset => '기본값 복원';

  @override
  String get hotkeyRecordPrompt => '새 키 조합을 눌러주세요';

  @override
  String get hotkeyNeedModifier =>
      'Ctrl·Alt·Win 중 하나가 필요해요 (Shift만으로는 일반 타이핑을 가로채요)';

  @override
  String get hotkeyDuplicate => '다른 동작이 이미 쓰는 조합이에요';

  @override
  String get hotkeyTakenWarning => '다른 앱이 사용 중인 조합이에요 — 눌러서 바꿔주세요';

  @override
  String get hotkeyRecordCaution => '이 조합을 쓰는 다른 앱에서는 해당 키가 동작하지 않게 돼요';

  @override
  String get settingsTtsVoice => '음성 스타일';

  @override
  String get settingsTtsVoiceDefault => '시스템 기본';

  @override
  String get settingsTtsVoicePreview => '안내 음성은 이렇게 들려요';

  @override
  String get menuRefreshWidget => '위젯 새로고침';

  @override
  String get menuRestartApp => '앱 재시작';

  @override
  String get menuErrorReports => '오류 리포트';

  @override
  String get overlayLongPressHint => '시계를 길게 누르고, 원하는 위치의 점을 탭하세요';

  @override
  String get editCoachGrid => '탭해서 원하는 칸으로 이동';

  @override
  String get editCoachDpad => '화살표로 미세 조정 · 꾹 누르면 계속';

  @override
  String get editCoachControls => '⤢ 크기 · ⇄ 좌우 전환 · ✓ 완료';

  @override
  String get editCoachDismiss => '화면을 탭하면 시작합니다';
}
