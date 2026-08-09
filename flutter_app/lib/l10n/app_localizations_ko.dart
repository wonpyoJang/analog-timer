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
  String get loopToggle => '루프';

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
  String get navTimer => '타이머';

  @override
  String get navMulti => '멀티';

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
  String get settingsTelemetryDesc => '익명 진단·ANR 정보 전송 (개인정보 없음)';

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
  String get shortcutWidgetFocus => '위젯 포커스 (키보드 배치 시작)';

  @override
  String get shortcutWidgetBlur => '하던 앱으로 돌아가기';

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
  String hotkeyNeedModifier(String key) {
    return '거의 됐어요 — Ctrl·Alt·Win 중 하나를 $key와 함께 눌러주세요';
  }

  @override
  String hotkeyDuplicate(String action) {
    return '\"$action\" 이 이미 쓰는 조합이에요';
  }

  @override
  String hotkeyNow(String combo) {
    return '현재: $combo';
  }

  @override
  String get hotkeyTakenWarning => '다른 앱이 사용 중인 조합이에요 — 눌러서 바꿔주세요';

  @override
  String get hotkeyRecordCaution => '단축키가 켜져 있는 동안 다른 앱은 이 조합을 못 써요';

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

  @override
  String get overlayKbGuide1 => '←↑→↓ 이동 · Shift = 크게';

  @override
  String get overlayKbGuide2 => '1–9 구역 이동 · Tab 반전 · Esc 완료';

  @override
  String overlayKbHint(String combo) {
    return '팁: 키보드로도 옮길 수 있어요 — $combo';
  }

  @override
  String hotkeyRecordGuide1(String example) {
    return 'Ctrl이나 Alt를 먼저 누른 채 글자를 톡 — 예: $example';
  }

  @override
  String get hotkeyRecordGuide2 => '평소 안 쓰는 조합으로 고르세요 — Shift를 더하면 겹칠 일이 드물어요';

  @override
  String get settingsTextSize => '글씨 크기';

  @override
  String get textSizeSmall => '작게';

  @override
  String get textSizeNormal => '보통';

  @override
  String get textSizeLarge => '크게';

  @override
  String get textSizeXLarge => '아주 크게';

  @override
  String get textSizePreview => '타이머 25:00 미리보기';

  @override
  String get a11yClose => '닫기';

  @override
  String get a11yEditSegment => '구간 편집';

  @override
  String get a11yDismissBanner => '알림 닫기';

  @override
  String get settingsHaptics => '진동 피드백';

  @override
  String get settingsHapticsDesc => '시작·일시정지·완료 시 진동';

  @override
  String get settingsNotifications => '알림';

  @override
  String get settingsNotificationsDesc => '구간이 바뀌거나 타이머가 끝나면 알림으로 표시';

  @override
  String get settingsColorblind => '색맹 모드';

  @override
  String get settingsColorblindDesc => '스톱워치를 색이 아닌 점선 패턴으로 구분';

  @override
  String get settingsHourlyChime => '정각 시보';

  @override
  String get settingsHourlyChimeDesc => '매시 정각에 시간을 읽어줘요 · 밤 10시~아침 8시는 쉬어요';

  @override
  String hourlyChimeSpoken(String time) {
    return '$time입니다';
  }

  @override
  String get settingsHighContrast => '고대비';

  @override
  String get settingsHighContrastDesc => '보조 텍스트를 더 밝게 해 가독성 향상';

  @override
  String get multiTimerTitle => '멀티 타이머';

  @override
  String get multiTimerAdd => '타이머 추가';

  @override
  String get multiTimerNameHint => '타이머 이름';

  @override
  String get multiTimerEmpty => '아직 타이머가 없어요. +로 추가하세요.';

  @override
  String get multiTimerDone => '완료';

  @override
  String get multiTimerOverlayOn => '오버레이 켜기';

  @override
  String get multiTimerOverlayOff => '오버레이 끄기';

  @override
  String get multiTimerOverlayPermission =>
      '오버레이를 사용하려면 \'다른 앱 위에 표시\' 권한이 필요해요';

  @override
  String multiTimerOverlayLimit(int count) {
    return '오버레이는 최대 $count개까지 띄울 수 있어요';
  }

  @override
  String multiTimerAllDone(int count) {
    return '타이머 $count개 완료';
  }

  @override
  String get settingsOverlayMutex => '오버레이 하나만 표시';

  @override
  String get settingsOverlayMutexDesc =>
      '타이머 오버레이와 멀티 타이머 오버레이 중 하나를 켜면 다른 하나가 꺼집니다. 둘을 동시에 켤 때 생기는 지연을 방지합니다.';

  @override
  String get multiTimerPresetStudy => '공부 집중';

  @override
  String get multiTimerPresetDeskCleanup => '책상청소';

  @override
  String get multiTimerPresetRest => '휴식';

  @override
  String get multiTimerPresetBrushTeeth => '양치질';

  @override
  String get multiTimerPresetSave => '프리셋으로 저장';

  @override
  String get multiTimerPresetSaved => '프리셋 저장됨';

  @override
  String get multiTimerPresetDeleted => '프리셋 삭제됨';

  @override
  String get multiTimerPresetEdit => '프리셋 편집';

  @override
  String get multiTimerEditDone => '완료';

  @override
  String get multiTimerStateIdle => '대기';

  @override
  String get multiTimerStatePaused => '일시정지';

  @override
  String get multiTimerPresetEditHint => '칩을 탭하면 이름·시간이 입력란으로 복사돼요';

  @override
  String multiTimerPresetStarted(String name) {
    return '\'$name\' 타이머를 시작했어요';
  }

  @override
  String get settingsSounds => '효과음';

  @override
  String get settingsSoundsDesc => '칩 탭·시작·일시정지·완료 멜로디';

  @override
  String get soundSetPop => '소프트 팝';

  @override
  String get soundSetWood => '우드';

  @override
  String get soundSetGlass => '글라스';

  @override
  String get soundSetRetro => '레트로';

  @override
  String get workoutTab => '운동';

  @override
  String get workoutMyRoutines => '내 루틴';

  @override
  String get workoutNewRoutine => '＋ 새 루틴';

  @override
  String workoutRoutineN(int n) {
    return '루틴 $n';
  }

  @override
  String get workoutLibrary => '운동 라이브러리';

  @override
  String get workoutLibraryHint => '탭해서 추가 · 페이스 프리셋 내장';

  @override
  String get workoutEmptyRoutine => '아래 라이브러리에서 운동을 추가하세요';

  @override
  String get workoutRest => '세트 간 휴식';

  @override
  String get workoutRestCommon => '루틴 공통';

  @override
  String get workoutVoiceTone => '보이스 톤';

  @override
  String get workoutToneCoach => '🔥 코치';

  @override
  String get workoutToneCalm => '🌙 차분';

  @override
  String get workoutSpeakSection => '말해줄 것';

  @override
  String get workoutSpeakAllOff => '전부 개별 OFF 가능';

  @override
  String get workoutSayCount => '구령';

  @override
  String get workoutSayCountSub => '하나, 둘, 셋…';

  @override
  String get workoutSaySetAnn => '세트 시작/종료 안내';

  @override
  String get workoutSayCallout => '남은 시간 콜아웃';

  @override
  String get workoutSayCountdown => '휴식 카운트다운 3·2·1';

  @override
  String get workoutSayPreview => '다음 동작 예고';

  @override
  String get workoutSayCheer => '격려 멘트';

  @override
  String get workoutSayCheerSub => '차분 톤에선 최소화';

  @override
  String get workoutDucking => '음악 덕킹';

  @override
  String get workoutDuckingSub => '발화 중 음악 볼륨 낮춤';

  @override
  String get workoutSets => '세트';

  @override
  String get workoutReps => '횟수';

  @override
  String get workoutPace => '구령 페이스';

  @override
  String get workoutPaceFreeSub => '수동 종료(다음)까지 무한 카운트';

  @override
  String get workoutHoldTime => '유지 시간';

  @override
  String get workoutStart => '시작';

  @override
  String get workoutTtsNote => '🔊 TTS 구령이 재생됩니다';

  @override
  String workoutSetProgress(int cur, int total) {
    return '$cur / $total 세트';
  }

  @override
  String workoutRepOf(int n) {
    return '$n회 중';
  }

  @override
  String get workoutFreeCount => '자유 카운트';

  @override
  String get workoutFreeHint => '다음 ▶ 를 누르면 종료';

  @override
  String get workoutHold => '버티기';

  @override
  String get workoutRestLabel => '휴식';

  @override
  String workoutNextLabel(String name) {
    return '다음: $name';
  }

  @override
  String get workoutDoneTitle => '운동 완료!';

  @override
  String workoutDoneCount(int n) {
    return '$n개 동작 완료';
  }

  @override
  String get workoutStop => '종료';

  @override
  String get workoutSkip => '다음';

  @override
  String get workoutBackToStart => '처음으로';

  @override
  String get exSquat => '스쿼트';

  @override
  String get exPushup => '푸시업';

  @override
  String get exLunge => '런지';

  @override
  String get exBurpee => '버피';

  @override
  String get exCrunch => '크런치';

  @override
  String get exPlank => '플랭크';

  @override
  String get exWallsit => '월싯';

  @override
  String get exPullup => '턱걸이';

  @override
  String wsSetStart(String name, int set, int reps) {
    return '$name, $set세트 $reps회. 시작!';
  }

  @override
  String wsSetStartAgain(int set) {
    return '$set세트 시작!';
  }

  @override
  String wsTimeStart(String name, int dur) {
    return '$name $dur초. 시작!';
  }

  @override
  String wsFreeStart(String name) {
    return '$name, 자유 카운트. 시작!';
  }

  @override
  String get wsLastSet => '마지막 세트! 힘내요';

  @override
  String get wsHalfway => '절반 왔어요';

  @override
  String get wsTenLeft => '10초 남았어요';

  @override
  String wsSetDoneRest(int set, int rest) {
    return '$set세트 완료. $rest초 휴식하세요';
  }

  @override
  String wsExDoneRest(String name, int rest) {
    return '$name 완료. $rest초 휴식하세요';
  }

  @override
  String wsNextEx(String name, String amount) {
    return '다음은 $name, $amount';
  }

  @override
  String wsNextSet(int set) {
    return '다음은 $set세트';
  }

  @override
  String get wsAllDone => '운동 완료! 수고했어요';

  @override
  String wsAmountTime(int dur) {
    return '$dur초';
  }

  @override
  String wsAmountReps(int reps) {
    return '$reps회';
  }

  @override
  String get wsAmountFree => '자유 카운트';

  @override
  String workoutSummaryReps(int sets, int reps, String pace) {
    return '$sets세트 × $reps회 · ${pace}s';
  }

  @override
  String workoutSummaryTime(int dur) {
    return '$dur초 버티기';
  }

  @override
  String workoutSummaryFree(String pace) {
    return '자유 카운트 · ${pace}s';
  }

  @override
  String get workoutCustomAdd => '＋ 커스텀 운동';

  @override
  String get workoutCustomTitle => '커스텀 운동 만들기';

  @override
  String get workoutCustomNameHint => '운동 이름 (예: 데드리프트)';

  @override
  String get workoutTypeReps => '세트×횟수';

  @override
  String get workoutTypeTime => '시간';

  @override
  String get workoutTypeFree => '자유';

  @override
  String get workoutCustomRepsDesc => '기본 3세트×10회 · 페이스 2.0s — 루틴에서 수정';

  @override
  String get workoutCustomTimeDesc => '기본 30초 버티기 — 루틴에서 수정';

  @override
  String get workoutCustomFreeDesc => '무한 구령, 수동 종료 · 페이스 2.0s';

  @override
  String get workoutCustomCancel => '취소';

  @override
  String get workoutCustomCreate => '만들고 추가';

  @override
  String workoutSecsLeft(int t) {
    return '$t초 남음';
  }

  @override
  String get wsGetReady => '곧 시작! 준비하세요';

  @override
  String get prepTab => '체크리스트';

  @override
  String get prepTitle => '준비물';

  @override
  String get prepAutoReset => '매일 아침 자동 리셋 🌅';

  @override
  String get prepAutoResetHint => '🌙 표시 목록은 리셋되지 않아요';

  @override
  String get prepAllPacked => '전부 챙겼어요 ✓';

  @override
  String prepPackedCount(int n, int m) {
    return '$n/$m 챙김';
  }

  @override
  String get prepAllPackedGo => '전부 챙겼어요 — 출발! ✓';

  @override
  String get prepCongrats => '🎉 다 챙겼어요!';

  @override
  String get prepNewListHint => '새 목록 (예: 여행)';

  @override
  String get prepEdit => '편집';

  @override
  String get prepEditDone => '완료';

  @override
  String get prepAddItemHint => '항목 추가 후 Enter';

  @override
  String get prepDailyReset => '매일 아침 리셋';

  @override
  String get prepDailyResetHint => '끄면 수동 리셋 (여행 등 일회성 목록)';

  @override
  String get prepDeleteList => '목록 삭제';

  @override
  String get prepUncheckAll => '체크 모두 해제';

  @override
  String get prepEmptyItems => '항목이 없어요 — 편집을 눌러 추가';

  @override
  String get prepEmptyItemsEdit => '아래에서 항목을 추가하세요';

  @override
  String get careSection => '사운드 & 방해 관리';

  @override
  String get careQuietHours => '조용한 시간';

  @override
  String get careQuietHoursDesc => '22:00–07:00 자동으로 소리 대신 진동';

  @override
  String get carePreAlarm => '프리-알림';

  @override
  String get carePreAlarmDesc => '끝나기 전에 소리 없이 예고';

  @override
  String get carePreAlarmOff => '끄기';

  @override
  String carePreAlarmMin(int n) {
    return '$n분';
  }

  @override
  String get careTone => '알람 문구 톤';

  @override
  String get careToneDesc => '알림에 쓰는 말투';

  @override
  String get careToneWarm => '다정';

  @override
  String get careToneNeutral => '중립';

  @override
  String get careToneBrief => '간결';

  @override
  String get careTonePreview => '문구 미리보기';

  @override
  String doneMsgWarm(String name) {
    return '\'$name\' 끝났어요. 수고했어요 ☺';
  }

  @override
  String doneMsgNeutral(String name) {
    return '$name · 00:00';
  }

  @override
  String doneMsgBrief(String name) {
    return '$name 완료';
  }

  @override
  String preAlarmBanner(String name, int n) {
    return '\'$name\' $n분 남았어요';
  }

  @override
  String get preAlarmExtend => '+5분';

  @override
  String get catAll => '전체';

  @override
  String get catCooking => '요리';

  @override
  String get catFocus => '집중';

  @override
  String get catChore => '집안일';

  @override
  String get presetRecent => '최근';

  @override
  String get cookRamen => '라면';

  @override
  String get cookPasta => '파스타 삶기';

  @override
  String get cookEgg => '반숙 계란';

  @override
  String get cookSauce => '소스 졸이기';

  @override
  String get cookRice => '쌀 불리기';

  @override
  String get alarmDoneTitle => '타이머 완료';

  @override
  String alarmMultiDone(int n) {
    return '$n개 완료';
  }

  @override
  String alarmOf(String d) {
    return '$d 타이머';
  }

  @override
  String get alarmAck => '확인 ✓';

  @override
  String get alarmAckOnly => '확인만 하기';

  @override
  String alarmExtended(int n) {
    return '연장 · $n회';
  }

  @override
  String get alarmRealarmNote => '확인할 때까지 1분마다 다시 울려요';

  @override
  String get alarmRinging => '완료 · 울리는 중';

  @override
  String alarmAgoMin(int n, int r) {
    return '$n분 전 완료 · $r회 울림';
  }

  @override
  String get alarmStillRunning => '계속 진행 중';

  @override
  String get alarmNextUp => '다음 ↓';

  @override
  String ttsOverdue(String name, int n) {
    return '$name, $n분 지났어요';
  }

  @override
  String get careRealarm => '확인까지 재알림';

  @override
  String get careRealarmDesc => '완료된 타이머를 확인할 때까지 1분마다 다시 울림';

  @override
  String get loopToggleDesc => '여러 단계를 자동으로 반복해요';

  @override
  String get loopAddStep => '＋ 단계 추가 (최대 4)';

  @override
  String get loopRepeat => '반복 횟수';

  @override
  String get loopTotal => '총 소요 시간';

  @override
  String get loopSaveStart => '저장하고 시작';

  @override
  String loopStepTag(String step, int round, int total) {
    return '$step $round/$total';
  }

  @override
  String loopRoundStart(int n, String step) {
    return '$n회차 — $step 시작';
  }

  @override
  String loopStepStart(String step) {
    return '$step 시작';
  }

  @override
  String get loopSkipStep => '단계 건너뛰기';

  @override
  String get careIntervalCooking => '요리 간격';

  @override
  String get careIntervalChore => '집안일 간격';

  @override
  String get careIntervalOther => '그 외 간격';

  @override
  String get careTtsName => '이름 읽어주기 (TTS)';

  @override
  String get careTtsNameDesc => '\"파스타 삶기, 끝났어요\"';

  @override
  String get careKeepDone => '완료 흔적 유지';

  @override
  String get careKeepDoneDesc => '완료된 타이머를 리스트에 남겨둬요';

  @override
  String get statsTitle => '활동 통계';

  @override
  String get statsToday => '오늘';

  @override
  String get statsWeek => '이번 주';

  @override
  String get statsMonth => '이번 달';

  @override
  String statsFocusedTime(String period) {
    return '$period 집중한 시간';
  }

  @override
  String get statsSessions => '세션';

  @override
  String get statsStreak => '연속';

  @override
  String get statsBest => '최고';

  @override
  String statsDays(int n) {
    return '$n일';
  }

  @override
  String statsSessionsN(int n) {
    return '$n회';
  }

  @override
  String get statsLast7 => '최근 7일';

  @override
  String get statsByActivity => '활동별';

  @override
  String get statsEmpty => '아직 기록이 없어요 — 타이머를 완료하면 통계가 쌓여요';

  @override
  String statsInsightTop(String day, int n) {
    return '$day에 가장 오래 집중했어요. 지금 $n일 연속이에요!';
  }

  @override
  String get statsPrivacy => '데이터는 기기에만 저장돼요. 계정·클라우드 없음.';

  @override
  String statsHoursMin(int h, int m) {
    return '$h시간 $m분';
  }

  @override
  String statsMinOnly(int m) {
    return '$m분';
  }

  @override
  String get settingsStats => '활동 통계';

  @override
  String get settingsStatsDesc => '집중 시간·세션·연속 기록';

  @override
  String get onboardTitle => '알람이 꼭 울리도록 준비할게요';

  @override
  String get onboardSub => '딱 두 가지면 돼요. 다른 설정은 건드릴 필요 없이 바로 쓸 수 있어요.';

  @override
  String get onboardNotifTitle => '알림 허용';

  @override
  String get onboardNotifDesc => '타이머가 끝나면 알려드려요';

  @override
  String get onboardBatteryTitle => '백그라운드에서 계속 실행';

  @override
  String get onboardBatteryDesc =>
      '이걸 꺼두면 앱을 닫았을 때 알람이 조용히 멈출 수 있어요. \"제한 없음\"을 골라 주세요.';

  @override
  String get onboardGrant => '허용';

  @override
  String get onboardAllow => '허용하러 가기';

  @override
  String get onboardDone => '완료 ✓';

  @override
  String get onboardLater => '나중에 할게요';

  @override
  String get onboardStart => '시작하기';

  @override
  String get checkAlarmTitle => '알람이 멈출 수 있어요';

  @override
  String get checkAlarmDesc => '배터리 절약이 앱을 재우고 있어요. 1분이면 고쳐요.';

  @override
  String get checkAlarmNotifDesc => '알림이 꺼져 있어요 — 타이머가 알려줄 수 없어요.';

  @override
  String get checkFix => '점검';

  @override
  String get diagTitle => '알람이 안 울릴 때';

  @override
  String get diagSub => '앱이 직접 확인했어요. 1분이면 고칠 수 있어요.';

  @override
  String diagWarnTitle(int n) {
    return '$n가지를 고쳐야 해요';
  }

  @override
  String get diagWarnDesc => '지금 상태로는 앱을 닫은 뒤 알람이 울리지 않을 수 있어요.';

  @override
  String get diagAllGood => '모두 정상이에요';

  @override
  String get diagAllGoodDesc => '앱을 닫아도 알람이 울려요.';

  @override
  String get diagResult => '점검 결과';

  @override
  String get diagNotifTitle => '알림 허용';

  @override
  String get diagNotifOk => '알림이 화면에 표시돼요';

  @override
  String get diagNotifBad => '알림이 꺼져 있어요 — 타이머가 알려줄 수 없어요.';

  @override
  String get diagBatteryTitle => '배터리 절약 예외';

  @override
  String get diagBatteryOk => '앱이 잠들지 않아요';

  @override
  String get diagBatteryBad => '배터리 절약이 앱을 재우고 있어요. 예약된 알람이 늦거나 사라져요.';

  @override
  String get diagOverlayTitle => '다른 앱 위에 표시';

  @override
  String get diagOverlayOk => '오버레이 pill이 표시될 수 있어요';

  @override
  String get diagOverlayBad => '오버레이 pill이 나타나지 않아요.';

  @override
  String get diagFix => '고치기';

  @override
  String get diagFixAll => '한 번에 고치기';

  @override
  String get diagTestAlarm => '지금 테스트 알람 보내기';

  @override
  String get diagTestNote => '보낸 뒤 앱을 완전히 닫고도 울리는지 확인해 보세요.';

  @override
  String get diagTestSent => '테스트 알람을 보냈어요 — 알림을 확인하세요';

  @override
  String get settingsDiag => '알람이 안 울릴 때';

  @override
  String get settingsDiagDesc => '자가 점검: 권한·배터리';

  @override
  String get settingsGroupNotify => '알림 방식';

  @override
  String get settingsGroupDisplay => '화면 표시';

  @override
  String get settingsGroupData => '내 데이터';

  @override
  String get settingsGroupControl => '조작';

  @override
  String get settingsGroupHelp => '도움';

  @override
  String get settingsAlarmSection => '알람 · 재알림';

  @override
  String get settingsAlarmSectionDesc => '확인하기 전까지 다시 알려요';

  @override
  String get settingsSoundSection => '사운드';

  @override
  String get settingsSoundSectionDesc => '효과음과 진동';

  @override
  String get settingsVoiceSection => '음성 안내';

  @override
  String get settingsVoiceSectionDesc => '화면을 볼 수 없을 때 말로 알려줘요';

  @override
  String get alarmPageSub => '알람을 확인하기 전까지 다시 알려요.';

  @override
  String get soundPageSub => '탭하면 바로 들어볼 수 있어요.';

  @override
  String get voicePageSub => '화면을 볼 수 없을 때 말로 알려줘요.';

  @override
  String get settingsSpeechRate => '말하기 속도';

  @override
  String get speechRateSlow => '느리게';

  @override
  String get speechRateNormal => '보통';

  @override
  String get speechRateFast => '빠르게';

  @override
  String get grpAlarmBasic => '기본 동작';

  @override
  String get grpAlarmInterval => '다시 알림 간격';

  @override
  String get grpAlarmPrep => '끝나기 전';

  @override
  String get grpSoundSet => '사운드 세트';

  @override
  String get grpSoundFeedback => '피드백';

  @override
  String get grpVoiceUse => '사용';

  @override
  String get grpVoiceVoice => '목소리';

  @override
  String get grpVoicePreview => '미리듣기';

  @override
  String get grpVoiceWorkout => '운동';

  @override
  String get grpAlarmDone => '완료 메시지';

  @override
  String get settingsListSection => '리스트 표시';

  @override
  String get settingsListSectionDesc => '메인 화면 타이머 표시 방식';

  @override
  String get listPageSub => '메인 화면에 타이머가 어떻게 보일지 정해요.';

  @override
  String get grpListRing => '진행 링';

  @override
  String get listShowRing => '진행 링 보기';

  @override
  String get listShowRingDesc => '남은 시간을 링으로 한눈에';

  @override
  String get grpListSize => '카드 크기';

  @override
  String get listDensityCompact => '촘촘하게';

  @override
  String get listDensityNormal => '보통';

  @override
  String get listDensityLarge => '크게';

  @override
  String get grpListSort => '정렬';

  @override
  String get listSortRemain => '남은 시간 짧은 순';

  @override
  String get listSortCreated => '추가한 순서';

  @override
  String get grpListDone => '끝난 타이머';

  @override
  String get listKeepDone => '남겨두는 시간';

  @override
  String get listKeepOff => '바로 숨김';

  @override
  String get listDimDone => '끝난 것 흐리게';

  @override
  String get listDimDoneDesc => '완료된 타이머를 흐리게';

  @override
  String get settingsOverlaySection => '오버레이 pill';

  @override
  String get settingsOverlaySectionDesc => '다른 앱 위에 뜨는 타이머';

  @override
  String get overlayPageSub => '다른 앱을 쓰는 중에도 남은 시간이 보여요.';

  @override
  String get grpOverlayUse => '사용';

  @override
  String get overlayShowOver => '다른 앱 위에 표시';

  @override
  String get overlayShowOverDesc => '다른 앱 위에 표시 권한이 필요해요';

  @override
  String get overlayShowLock => '잠금화면에도 표시';

  @override
  String get overlayShowLockDesc => '기기에 따라 제한될 수 있어요';

  @override
  String get grpOverlaySize => '크기';

  @override
  String get overlaySizeSmall => '작게';

  @override
  String get overlaySizeNormal => '보통';

  @override
  String get overlaySizeLarge => '크게';

  @override
  String get grpOverlaySide => '붙는 위치';

  @override
  String get overlaySideLeft => '왼쪽 가장자리';

  @override
  String get overlaySideRight => '오른쪽 가장자리';

  @override
  String get grpOverlayContent => '표시 내용';

  @override
  String get overlayShowName => '타이머 이름';

  @override
  String get overlayShowNameDesc => '끄면 시간만 보여요';

  @override
  String get overlayAutoHide => '끝나면 자동으로 숨기기';

  @override
  String get overlayAutoHideDesc => '확인하면 사라져요';

  @override
  String get overlayGrantCta => '권한 주기';

  @override
  String get overlayPreviewHint => '드래그해서 위치를 옮길 수 있어요';

  @override
  String get overlayPreviewLabel => '미리보기';

  @override
  String get textTimerEntry => '말하거나 적기';

  @override
  String get textTimerEntryDesc => '“라면 사분반, 계란 육분”';

  @override
  String get textTimerTitle => '말하거나 적기';

  @override
  String get textTimerInputHint => '예: 라면 사분반, 계란 육분';

  @override
  String get textTimerHelper => '여러 개를 쉼표로 한 번에 적어도 돼요.';

  @override
  String get textTimerExamplesHead => '이렇게 적어보세요';

  @override
  String get textTimerOffline => '인터넷 없이 동작해요 · 아무것도 전송하지 않아요';

  @override
  String get textTimerParse => '해석하기';

  @override
  String get textTimerConfirmTitle => '이렇게 만들까요?';

  @override
  String get textTimerConfirmSub => '눌러서 빼거나 다시 적을 수 있어요.';

  @override
  String get textTimerRetype => '다시 적기';

  @override
  String textTimerStartN(int n) {
    return '$n개 시작';
  }

  @override
  String get textTimerSaveN => '프리셋으로 저장';

  @override
  String get textTimerUnparsed => '시간을 알 수 없어요 · 이 부분을 다시 적어주세요';

  @override
  String get textTimerFromPreset => '이미 있는 프리셋이라 색·알람을 가져왔어요';

  @override
  String get textTimerRangeShort => '짧은 쪽으로 잡았어요';

  @override
  String get textTimerEmpty => '아직 시작할 게 없어요';

  @override
  String get textTimerNoTime => '시간을 찾지 못했어요. “라면 4분”처럼 적어보세요.';

  @override
  String get settingsVoiceStart => '음성으로 시작';

  @override
  String get settingsVoiceStartDesc => '폰을 꺼내지 않고 말로 타이머를 켜요';

  @override
  String get voiceStartSub => '폰을 꺼내지 않고 말로 타이머를 켜요.';

  @override
  String get voiceHeroHint => '이렇게 말하면 25분 집중이 바로 시작돼요';

  @override
  String get voiceHeroQuote => '“헤이 구글, 집중 시작”';

  @override
  String get voiceRoutineHead => '자동으로 켜지게';

  @override
  String get voiceRoutineSub => '갤럭시 루틴에 등록하면 말하지 않아도 시작돼요.';

  @override
  String get voiceRecipeHead => '추천 레시피';

  @override
  String get recipeDesk => '책상에 앉으면 집중';

  @override
  String get recipeDeskWhen => '집 Wi-Fi + 평일 오후';

  @override
  String get recipeCharge => '무선 충전에 올리면 집중';

  @override
  String get recipeChargeWhen => '충전 시작 · 방해금지 함께';

  @override
  String get recipeWorkout => '운동 앱을 열면 TTS 모드';

  @override
  String get recipeWorkoutWhen => '특정 앱 실행';

  @override
  String get recipeSleep => '잘 때 전체 정지';

  @override
  String get recipeSleepWhen => '취침 모드 진입';

  @override
  String routineCopied(String name) {
    return '‘$name’ 링크를 복사했어요';
  }

  @override
  String get routineStepsHead => '이제 이렇게 하면 돼요';

  @override
  String get routineStep1 => '루틴 앱 열기';

  @override
  String get routineStep1Desc => '아래 버튼을 누르면 바로 열려요';

  @override
  String get routineStep2 => '동작에서 ‘앱 열기’ 선택';

  @override
  String get routineStep2Desc => '주소 칸에 길게 눌러 붙여넣기';

  @override
  String get routineStep3 => '조건을 고르고 저장';

  @override
  String get routineStep3Desc => 'Wi-Fi · 시간 · 장소 무엇이든';

  @override
  String get routineOpenApp => '루틴 앱 열기';

  @override
  String get routineCantOpen => '루틴 앱을 열지 못했어요. 링크는 복사됐어요 — 붙여넣어 주세요.';

  @override
  String get voiceStarted => '말로 시작함';

  @override
  String voiceStartedTimer(String name) {
    return '‘$name’ 시작했어요';
  }

  @override
  String get voiceStopHint => '여러 개가 실행 중이라 앱에서 골라주세요.';

  @override
  String get scFocus => '집중 25분';

  @override
  String get scRest => '휴식 5분';

  @override
  String get scStop => '타이머 정지';

  @override
  String get scStatus => '남은 시간';

  @override
  String get ocrEntry => '봉지·안내문 찍기';

  @override
  String get ocrEntryDesc => '조리시간을 읽어서 바로 만들어요';

  @override
  String get ocrCamera => '카메라로 찍기';

  @override
  String get ocrAlbum => '앨범에서 고르기';

  @override
  String get ocrReading => '글자를 읽는 중…';

  @override
  String get ocrNoTime => '시간을 찾지 못했어요 · 직접 맞춰주세요';

  @override
  String get ocrTitle => '봉지 찍기';

  @override
  String get seqParallel => '동시에 시작';

  @override
  String get seqSequential => '이어서 실행';

  @override
  String get seqNote => '한 단계가 끝나면 다음 단계가 이어서 시작돼요.';

  @override
  String get seqAckTitle => '확인 후 다음 시작';

  @override
  String get seqAckAuto => '자동 선택됨';

  @override
  String get seqAckOnNote => '한 단계 알람을 확인해야 다음이 시작돼요 (단계 사이 손 쓰는 조리).';

  @override
  String get seqAckOffNote => '한 단계가 끝나면 곧바로 다음이 시작돼요 (연속 과정).';

  @override
  String get seqFinishTogether => '동시 완료';

  @override
  String get seqFinishNote => '가장 긴 것부터 시작해 모두 같은 시각에 끝나요.';

  @override
  String seqFinishAt(String time) {
    return '모두 $time에 완료';
  }

  @override
  String get ftWaiting => '대기';

  @override
  String get ftStartArmed => '시작할 시간';

  @override
  String ftStartIn(String t) {
    return '$t 뒤 시작';
  }

  @override
  String get ftStartNow => '지금 시작';

  @override
  String ftDriftTitle(String name, int min) {
    return '$name이(가) $min분 늦게 끝나요';
  }

  @override
  String get ftDriftDesc => '실행 중인 것을 늘려 다시 맞추거나, 그대로 둘 수 있어요.';

  @override
  String ftDriftExtend(String name, int min) {
    return '$name +$min:00';
  }

  @override
  String get ftDriftLeave => '그대로 두기';

  @override
  String ftStartArmedMsg(String name) {
    return '$name 올리세요 — 확인하면 시작돼요';
  }

  @override
  String get undo => '되돌리기';

  @override
  String presetDeletedToast(String name) {
    return '$name을(를) 지웠어요';
  }

  @override
  String get waterTitle => '물 마시기 알림';

  @override
  String get waterToday => '오늘';

  @override
  String waterCups(int n, int goal) {
    return '$n / $goal잔';
  }

  @override
  String get waterWhenGroup => '언제 울릴까요';

  @override
  String get waterInterval => '일정 간격마다';

  @override
  String get waterFixed => '정해진 시각';

  @override
  String get waterActiveHours => '활동 시간대에만';

  @override
  String get waterWithTimer => '타이머 끝날 때 같이';

  @override
  String get waterWithTimerSub => '다른 알람을 확인할 때 물 알림을 얹어요';

  @override
  String get waterHowGroup => '알림 방식';

  @override
  String get waterIntensity => '강도';

  @override
  String get waterIntensitySub => '한 번만 울리고 물러나요 — 재알림 없음';

  @override
  String get waterBannerMode => '배너';

  @override
  String get waterOneSound => '한 번 소리';

  @override
  String get waterGoal => '하루 목표';

  @override
  String waterGoalCups(int n) {
    return '$n잔';
  }

  @override
  String get waterEnable => '물 알림 사용';

  @override
  String get waterNote =>
      '간격 타이머는 \"마셨어요\"를 누른 시점부터 다시 셈 · 정해진 시각과 30분 내로 겹치면 하나만 울림';

  @override
  String get waterBannerTitle => '물 한 잔';

  @override
  String waterBannerSub(int n, String time) {
    return '오늘 $n잔 · 다음 $time';
  }

  @override
  String get waterDrank => '마셨어요';

  @override
  String get waterLater30 => '30분 뒤';

  @override
  String get waterStopToday => '오늘은 그만';

  @override
  String get waterBgNote => '앱이 열려 있을 때 알림이 울려요. 백그라운드 전달은 준비 중입니다.';

  @override
  String get waterSettingsDesc => '간격·정해진 시각으로 물 마시기 알림';
}
