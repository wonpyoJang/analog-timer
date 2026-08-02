// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '模拟计时器';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get manage => '管理';

  @override
  String get timerSection => '计时器';

  @override
  String get btnStart => '开始';

  @override
  String get btnPause => '暂停';

  @override
  String get btnResume => '继续';

  @override
  String get btnRunning => '进行中…';

  @override
  String get btnNext => '下一个';

  @override
  String get btnReset => '重置';

  @override
  String get stopwatchSection => '秒表';

  @override
  String get btnLap => '计圈';

  @override
  String lapToast(int num, String time) {
    return '第 $num 圈    $time';
  }

  @override
  String get timerSegments => '计时区段';

  @override
  String get addSegment => '+ 添加区段';

  @override
  String get loopToggle => '循环';

  @override
  String get minutesUnit => '分钟';

  @override
  String get segmentColor => '区段颜色';

  @override
  String get segments => '区段';

  @override
  String get savePresetChip => '保存当前';

  @override
  String presetApplied(String name) {
    return '已添加预设 · $name';
  }

  @override
  String get noSegmentsToSave => '没有可保存的区段';

  @override
  String get savePresetTitle => '保存预设';

  @override
  String get presetNameHint => '例如 学习 50/10';

  @override
  String get presetName => '预设名称';

  @override
  String get presetManageTitle => '管理预设';

  @override
  String get newPreset => '新建预设';

  @override
  String get editPreset => '编辑预设';

  @override
  String get deletePresetTitle => '删除预设';

  @override
  String deletePresetConfirm(String name) {
    return '删除“$name”？';
  }

  @override
  String get noPresets => '没有已保存的预设。\n点击右上角的“新建预设”添加一个。';

  @override
  String get enterName => '请输入名称';

  @override
  String get atLeastOneSegment => '请至少添加一个区段';

  @override
  String get legendTimer => '计时器 — 内圈螺旋';

  @override
  String get legendStopwatch => '秒表 — 外圈';

  @override
  String get statusDone => '完成';

  @override
  String get statusWaiting => '就绪';

  @override
  String get widget => '小组件';

  @override
  String get widgetOn => '小组件已开启';

  @override
  String get notifyTimerDoneTitle => '计时完成';

  @override
  String get notifyTimerDoneBody => '所有区段已完成 🎉';

  @override
  String get notifySegmentDoneTitle => '区段完成';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev 已完成 · 下一个：$next';
  }

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get presetPomodoro => '番茄钟 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => '深度工作 90/20';

  @override
  String get segFocus => '专注';

  @override
  String get segBreak => '休息';

  @override
  String get stopwatchLaps => '计圈记录';

  @override
  String get noLaps => '暂无计圈';

  @override
  String get timerLogTitle => '计时日志';

  @override
  String get noEvents => '暂无事件';

  @override
  String lapLabel(int num) {
    return '第 $num 圈';
  }

  @override
  String logStart(String name) {
    return '开始：$name';
  }

  @override
  String get logPaused => '已暂停';

  @override
  String get logReset => '已重置';

  @override
  String logSkipped(String name) {
    return '已跳过：$name';
  }

  @override
  String logDone(String name) {
    return '已完成：$name';
  }

  @override
  String get logAllDone => '所有区段已完成 🎉';

  @override
  String logLoop(String count) {
    return '🔁 第 $count 轮完成';
  }

  @override
  String get batteryLow => '电量不足 — 请充电';

  @override
  String get batteryMon => '电量';

  @override
  String get batteryMonOn => '电量 ON';

  @override
  String get settings => '设置';

  @override
  String get settingsBattery => '电量监控';

  @override
  String get settingsBatteryDesc => '电量低于20%时发出警告';

  @override
  String get settingsLanguage => '语言';

  @override
  String get modeLabelLog => '日志';

  @override
  String get modeLabelToday => '今天';

  @override
  String get modeLabelPlan => '计划';

  @override
  String get dayLogTitle => '当日记录';

  @override
  String get dayLogEmpty => '这一天没有活动记录';

  @override
  String get dayPlanTitle => '当日计划';

  @override
  String get dayPlanEmpty => '这一天没有计划';

  @override
  String get planSaveAsCurrent => '保存为计划';

  @override
  String get planLoadIntoTimer => '载入计时器';

  @override
  String get planSave => '保存';

  @override
  String get telemetryConsentTitle => 'Help improve Analog Timer';

  @override
  String get telemetryConsentBody =>
      'If the app closes unexpectedly, anonymous diagnostics (device environment and error logs) are sent to the developer to help find the cause. No personal information or timer content is included. You can turn this off anytime in settings.';

  @override
  String get telemetryAllow => 'Allow';

  @override
  String get telemetryDeny => 'Don\'t send';

  @override
  String get telemetryReportSetting => 'Send diagnostics';

  @override
  String get feedbackTitle => 'Send feedback';

  @override
  String get feedbackEntry => 'Send feedback to the developer';

  @override
  String get feedbackEntryDesc =>
      'Report a bug or request a feature (photos/videos welcome)';

  @override
  String get feedbackCategoryBug => 'Bug';

  @override
  String get feedbackCategoryFeature => 'Feature request';

  @override
  String get feedbackCategoryOther => 'Other';

  @override
  String get feedbackMessageHint =>
      'Describe the bug or the feature you\'d like…';

  @override
  String get feedbackContactHint =>
      'Contact (optional — email etc. for follow-up)';

  @override
  String get feedbackAttachPhoto => 'Attach photo';

  @override
  String get feedbackAttachVideo => 'Attach video';

  @override
  String get feedbackRecordVoice => 'Record voice';

  @override
  String get feedbackRecording => 'Recording… tap to stop';

  @override
  String get feedbackMicDenied =>
      'Microphone unavailable — check permission in system settings';

  @override
  String get feedbackSend => 'Send';

  @override
  String get feedbackSent => 'Thanks! Your feedback has been sent.';

  @override
  String get feedbackFailed =>
      'Failed to send — check your network and try again';

  @override
  String get feedbackMessageRequired => 'Please write a message first';

  @override
  String get feedbackIncludeLogs =>
      'Include diagnostic logs (device info & recent actions — no personal data)';

  @override
  String get reviewPromptTitle => 'Enjoying Analog Timer?';

  @override
  String get reviewPromptBody =>
      'You just finished a session — nice work! 🎉\nIf you have a moment, tell the developer what you like or what could be better. It really helps.';

  @override
  String get reviewPromptAccept => 'Share thoughts';

  @override
  String get reviewPromptLater => 'Later';

  @override
  String get reviewPromptNever => 'Don\'t ask again';

  @override
  String get syncPageTitle => 'Device pairing';

  @override
  String get syncConnected => '✓ Connected';

  @override
  String syncRoomLabel(String id) {
    return 'Room: $id';
  }

  @override
  String get syncRoomDesc =>
      'Timer, presets, and settings are shared across every device in this room.';

  @override
  String get syncAddDevice => 'Add another device';

  @override
  String get syncInviteTitle => 'Invite from this device';

  @override
  String get syncInviteDesc =>
      'Scan the QR or enter the 6-digit code on the other device.';

  @override
  String get syncCreateCode => 'Generate invite code';

  @override
  String get syncJoinTitle => 'Join with a code';

  @override
  String get syncJoinDesc =>
      'Enter the 6-digit code shown on the other device.';

  @override
  String get syncJoinBtn => 'Connect';

  @override
  String get syncDisconnect => 'Disconnect';

  @override
  String get syncExpiry => 'Scan or enter within 5 minutes';

  @override
  String get syncErrorNetwork => 'Couldn\'t get a code — check your network';

  @override
  String get syncErrorCode => 'Wrong or expired code';

  @override
  String get syncErrorCodeLen => 'Enter the 6-digit code';

  @override
  String get syncScanQr => 'Scan QR';

  @override
  String get syncScanCancel => 'Cancel';

  @override
  String get tipWidgetToggle => 'Show or hide the floating widget';

  @override
  String get tipWidgetRefresh =>
      'Refresh the widget (use if it is frozen or missing)';

  @override
  String get tipAppRestart =>
      'Restart the app to fix a frozen screen — records and elapsed time are kept';

  @override
  String get tipOverlayOpacity => 'Adjust widget transparency';

  @override
  String get tipOverlayResize => 'Drag to resize the widget';

  @override
  String get tipOverlayHide => 'Hide the widget';

  @override
  String get tipStopwatchToggle => 'Start or stop the stopwatch';

  @override
  String get settingsTts => 'Voice announcements';

  @override
  String get settingsTtsDesc =>
      'Speak segment changes and timer completion aloud';

  @override
  String get settingsTtsSample => 'Voice announcements are on';

  @override
  String get ttsOnboardBody =>
      'Segment changes like this can also be announced by voice';

  @override
  String get ttsOnboardEnable => 'Try it';

  @override
  String get ttsVoiceMissingHint =>
      'For natural announcements, add your language\'s voice in Windows Settings > Time & Language > Speech';

  @override
  String get menuMore => 'More';

  @override
  String get menuSettingsHint => 'Language · notifications · battery';

  @override
  String get menuTroubleshoot => 'TROUBLESHOOT';

  @override
  String get menuAutoRecoveryNote =>
      'Auto detection and recovery is on — you rarely need these.';

  @override
  String get shortcutSheetTitle => 'Keyboard shortcuts';

  @override
  String get shortcutGlobalSection => 'Anywhere (global)';

  @override
  String get shortcutInAppSection => 'When this window is focused';

  @override
  String get shortcutTimerToggle => 'Start / pause timer';

  @override
  String get shortcutTimerNext => 'Next segment';

  @override
  String get shortcutSwToggle => 'Start / stop stopwatch';

  @override
  String get shortcutSwLap => 'Lap';

  @override
  String get shortcutWidgetToggle => 'Toggle widget';

  @override
  String get keysHintTimerToggle =>
      'Tip: Space or Ctrl+Alt+Space also starts/pauses the timer';

  @override
  String get keysHintTimerNext =>
      'Tip: N or Ctrl+Alt+N also skips to the next segment';

  @override
  String get keysHintSwToggle =>
      'Tip: the S key also starts/stops the stopwatch';

  @override
  String get keysHintSwLap => 'Tip: L or Ctrl+Alt+L also records a lap';

  @override
  String get menuShortcuts => 'Shortcuts';

  @override
  String get settingsHotkeys => 'Global shortcuts';

  @override
  String get settingsHotkeysDesc =>
      'Work from any app. Tap an item below to change its keys. In-app: Space, N, S, L, W';

  @override
  String get hotkeyReset => 'Restore defaults';

  @override
  String get hotkeyRecordPrompt => 'Press the new key combination';

  @override
  String get hotkeyNeedModifier =>
      'Include Ctrl, Alt or Win (Shift alone would hijack normal typing)';

  @override
  String get hotkeyDuplicate => 'Already used by another action';

  @override
  String get hotkeyTakenWarning => 'Taken by another app — tap to change';

  @override
  String get hotkeyRecordCaution =>
      'This combo will stop working in other apps that use it';

  @override
  String get settingsTtsVoice => 'Voice style';

  @override
  String get settingsTtsVoiceDefault => 'System default';

  @override
  String get settingsTtsVoicePreview => 'This is how announcements will sound';

  @override
  String get menuRefreshWidget => 'Refresh widget';

  @override
  String get menuRestartApp => 'Restart app';

  @override
  String get menuErrorReports => 'Error reports';

  @override
  String get overlayLongPressHint => '长按时钟，然后点按想要移动到的位置圆点';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => '類比計時器';

  @override
  String get save => '儲存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '刪除';

  @override
  String get manage => '管理';

  @override
  String get timerSection => '計時器';

  @override
  String get btnStart => '開始';

  @override
  String get btnPause => '暫停';

  @override
  String get btnResume => '繼續';

  @override
  String get btnRunning => '進行中…';

  @override
  String get btnNext => '下一個';

  @override
  String get btnReset => '重設';

  @override
  String get stopwatchSection => '碼錶';

  @override
  String get btnLap => '計圈';

  @override
  String lapToast(int num, String time) {
    return '第 $num 圈    $time';
  }

  @override
  String get timerSegments => '計時區段';

  @override
  String get addSegment => '+ 新增區段';

  @override
  String get loopToggle => '循環';

  @override
  String get minutesUnit => '分鐘';

  @override
  String get segmentColor => '區段顏色';

  @override
  String get segments => '區段';

  @override
  String get savePresetChip => '儲存目前';

  @override
  String presetApplied(String name) {
    return '已新增預設 · $name';
  }

  @override
  String get noSegmentsToSave => '沒有可儲存的區段';

  @override
  String get savePresetTitle => '儲存預設';

  @override
  String get presetNameHint => '例如 讀書 50/10';

  @override
  String get presetName => '預設名稱';

  @override
  String get presetManageTitle => '管理預設';

  @override
  String get newPreset => '新增預設';

  @override
  String get editPreset => '編輯預設';

  @override
  String get deletePresetTitle => '刪除預設';

  @override
  String deletePresetConfirm(String name) {
    return '刪除「$name」？';
  }

  @override
  String get noPresets => '沒有已儲存的預設。\n點選右上角的「新增預設」加入一個。';

  @override
  String get enterName => '請輸入名稱';

  @override
  String get atLeastOneSegment => '請至少新增一個區段';

  @override
  String get legendTimer => '計時器 — 內圈螺旋';

  @override
  String get legendStopwatch => '碼錶 — 外圈';

  @override
  String get statusDone => '完成';

  @override
  String get statusWaiting => '就緒';

  @override
  String get widget => '小工具';

  @override
  String get widgetOn => '小工具已開啟';

  @override
  String get notifyTimerDoneTitle => '計時完成';

  @override
  String get notifyTimerDoneBody => '所有區段已完成 🎉';

  @override
  String get notifySegmentDoneTitle => '區段完成';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev 已完成 · 下一個：$next';
  }

  @override
  String get language => '語言';

  @override
  String get languageSystem => '跟隨系統';

  @override
  String get presetPomodoro => '番茄鐘 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => '深度工作 90/20';

  @override
  String get segFocus => '專注';

  @override
  String get segBreak => '休息';

  @override
  String get stopwatchLaps => '計圈記錄';

  @override
  String get noLaps => '尚無計圈';

  @override
  String get timerLogTitle => '計時記錄';

  @override
  String get noEvents => '尚無事件';

  @override
  String lapLabel(int num) {
    return '第 $num 圈';
  }

  @override
  String logStart(String name) {
    return '開始：$name';
  }

  @override
  String get logPaused => '已暫停';

  @override
  String get logReset => '已重設';

  @override
  String logSkipped(String name) {
    return '已跳過：$name';
  }

  @override
  String logDone(String name) {
    return '已完成：$name';
  }

  @override
  String get logAllDone => '所有區段已完成 🎉';

  @override
  String logLoop(String count) {
    return '🔁 第 $count 輪完成';
  }

  @override
  String get batteryLow => '電量不足 — 請充電';

  @override
  String get batteryMon => '電量';

  @override
  String get batteryMonOn => '電量 ON';

  @override
  String get settings => '設定';

  @override
  String get settingsBattery => '電量監控';

  @override
  String get settingsBatteryDesc => '電量低於20%時發出警告';

  @override
  String get settingsLanguage => '語言';

  @override
  String get modeLabelLog => '紀錄';

  @override
  String get modeLabelToday => '今天';

  @override
  String get modeLabelPlan => '計畫';

  @override
  String get dayLogTitle => '當日紀錄';

  @override
  String get dayLogEmpty => '這天沒有活動紀錄';

  @override
  String get dayPlanTitle => '當日計畫';

  @override
  String get dayPlanEmpty => '這天沒有計畫';

  @override
  String get planSaveAsCurrent => '儲存為計畫';

  @override
  String get planLoadIntoTimer => '載入計時器';

  @override
  String get planSave => '儲存';

  @override
  String get overlayLongPressHint => '長按時鐘，然後點按想要移動到的位置圓點';
}
