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
  String get navTimer => '计时器';

  @override
  String get navMulti => '多个';

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
  String get settingsTelemetryDesc => '发送匿名诊断和 ANR 信息（不含个人数据）';

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
  String get shortcutMultiTimer => 'Open multiple timers';

  @override
  String get shortcutWidgetMove => 'Move widget (click the widget first)';

  @override
  String get shortcutWidgetAnchor => 'Snap widget to 3×3 grid';

  @override
  String get shortcutWidgetMirror => 'Flip widget to opposite side';

  @override
  String get shortcutWidgetFocus => 'Focus widget (start keyboard placement)';

  @override
  String get shortcutWidgetBlur => 'Return to previous app';

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
  String hotkeyNeedModifier(String key) {
    return 'Almost — hold Ctrl, Alt or Win together with $key';
  }

  @override
  String hotkeyDuplicate(String action) {
    return 'Already used by \"$action\"';
  }

  @override
  String hotkeyNow(String combo) {
    return 'now: $combo';
  }

  @override
  String get hotkeyTakenWarning => 'Taken by another app — tap to change';

  @override
  String get hotkeyRecordCaution =>
      'Other apps lose this combo while shortcuts are on';

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

  @override
  String get editCoachGrid => '点按方格即可移到该处';

  @override
  String get editCoachDpad => '方向键微调 · 长按可连续';

  @override
  String get editCoachControls => '⤢ 大小 · ⇄ 切换左右 · ✓ 完成';

  @override
  String get editCoachDismiss => '点按任意处开始';

  @override
  String get overlayKbGuide1 => '←↑→↓ move · Shift = bigger';

  @override
  String get overlayKbGuide2 => '1–9 snap · Tab mirror · Esc done';

  @override
  String overlayKbHint(String combo) {
    return 'Tip: move with keyboard — $combo';
  }

  @override
  String hotkeyRecordGuide1(String example) {
    return 'Hold Ctrl or Alt first, then tap a letter — like $example.';
  }

  @override
  String get hotkeyRecordGuide2 =>
      'Pick one you don\'t already use elsewhere — adding Shift makes clashes rare.';

  @override
  String get settingsTextSize => '文字大小';

  @override
  String get textSizeSmall => '小';

  @override
  String get textSizeNormal => '标准';

  @override
  String get textSizeLarge => '大';

  @override
  String get textSizeXLarge => '特大';

  @override
  String get textSizePreview => '计时器 25:00 预览';

  @override
  String get a11yClose => '关闭';

  @override
  String get a11yEditSegment => '编辑区间';

  @override
  String get a11yDismissBanner => '关闭提示';

  @override
  String get settingsHaptics => '触感反馈';

  @override
  String get settingsHapticsDesc => '开始、暂停和完成时振动';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsDesc =>
      'Toast when a segment changes or the timer completes';

  @override
  String get settingsColorblind => '色盲模式';

  @override
  String get settingsColorblindDesc => '用虚线而非仅颜色区分秒表';

  @override
  String get settingsHourlyChime => 'Hourly time announcement';

  @override
  String get settingsHourlyChimeDesc =>
      'Speaks the time on the hour · quiet 10 PM–8 AM';

  @override
  String hourlyChimeSpoken(String time) {
    return 'It\'s $time';
  }

  @override
  String get settingsHighContrast => '高对比度';

  @override
  String get settingsHighContrastDesc => '提亮次要文字以便阅读';

  @override
  String get multiTimerTitle => '多个计时器';

  @override
  String get multiTimerAdd => '添加计时器';

  @override
  String get multiTimerNameHint => '计时器名称';

  @override
  String get multiTimerEmpty => '还没有计时器，点 + 添加。';

  @override
  String get multiTimerDone => '完成';

  @override
  String get multiTimerOverlayOn => '显示悬浮窗';

  @override
  String get multiTimerOverlayOff => '隐藏悬浮窗';

  @override
  String get multiTimerOverlayPermission => '请允许“显示在其他应用上层”以使用悬浮窗';

  @override
  String multiTimerOverlayLimit(int count) {
    return '最多可显示 $count 个悬浮窗';
  }

  @override
  String multiTimerAllDone(int count) {
    return '$count 个计时器完成';
  }

  @override
  String get settingsOverlayMutex => 'Show one overlay at a time';

  @override
  String get settingsOverlayMutexDesc =>
      'Turning on the timer overlay or the multi-timer overlays turns off the other. Prevents lag from running both at once.';

  @override
  String get multiTimerPresetStudy => 'Study focus';

  @override
  String get multiTimerPresetDeskCleanup => 'Desk cleanup';

  @override
  String get multiTimerPresetRest => 'Break';

  @override
  String get multiTimerPresetBrushTeeth => 'Brush teeth';

  @override
  String get multiTimerPresetSave => 'Save as preset';

  @override
  String get multiTimerPresetSaved => 'Preset saved';

  @override
  String get multiTimerPresetDeleted => 'Preset deleted';

  @override
  String get multiTimerPresetEdit => 'Edit presets';

  @override
  String get multiTimerEditDone => 'Done';

  @override
  String get multiTimerStateIdle => 'Ready';

  @override
  String get multiTimerStatePaused => 'Paused';

  @override
  String get multiTimerPresetEditHint =>
      'Tap a preset to copy it into the fields';

  @override
  String multiTimerPresetStarted(String name) {
    return 'Started \'$name\'';
  }

  @override
  String get settingsSounds => 'Sound effects';

  @override
  String get settingsSoundsDesc => 'Chip taps, start/pause, completion melody';

  @override
  String get soundSetPop => 'Soft pop';

  @override
  String get soundSetWood => 'Wood';

  @override
  String get soundSetGlass => 'Glass';

  @override
  String get soundSetRetro => 'Retro';

  @override
  String get workoutTab => 'Workout';

  @override
  String get workoutMyRoutines => 'My routines';

  @override
  String get workoutNewRoutine => '+ New routine';

  @override
  String workoutRoutineN(int n) {
    return 'Routine $n';
  }

  @override
  String get workoutLibrary => 'Exercise library';

  @override
  String get workoutLibraryHint => 'tap to add · pace presets built in';

  @override
  String get workoutEmptyRoutine => 'Add exercises from the library below';

  @override
  String get workoutRest => 'Rest between sets';

  @override
  String get workoutRestCommon => 'shared across the routine';

  @override
  String get workoutVoiceTone => 'Voice tone';

  @override
  String get workoutToneCoach => '🔥 Coach';

  @override
  String get workoutToneCalm => '🌙 Calm';

  @override
  String get workoutSpeakSection => 'What to announce';

  @override
  String get workoutSpeakAllOff => 'each can be turned off';

  @override
  String get workoutSayCount => 'Rep count';

  @override
  String get workoutSayCountSub => 'one, two, three…';

  @override
  String get workoutSaySetAnn => 'Set start & end';

  @override
  String get workoutSayCallout => 'Time-left callouts';

  @override
  String get workoutSayCountdown => 'Rest countdown 3·2·1';

  @override
  String get workoutSayPreview => 'Next exercise preview';

  @override
  String get workoutSayCheer => 'Encouragement';

  @override
  String get workoutSayCheerSub => 'minimal in calm tone';

  @override
  String get workoutDucking => 'Music ducking';

  @override
  String get workoutDuckingSub => 'lowers music volume while speaking';

  @override
  String get workoutSets => 'Sets';

  @override
  String get workoutReps => 'Reps';

  @override
  String get workoutPace => 'Count pace';

  @override
  String get workoutPaceFreeSub => 'counts forever until you tap Next';

  @override
  String get workoutHoldTime => 'Hold time';

  @override
  String get workoutStart => 'Start';

  @override
  String get workoutTtsNote => '🔊 Spoken cues will play';

  @override
  String workoutSetProgress(int cur, int total) {
    return 'Set $cur of $total';
  }

  @override
  String workoutRepOf(int n) {
    return 'of $n reps';
  }

  @override
  String get workoutFreeCount => 'Free count';

  @override
  String get workoutFreeHint => 'tap Next to finish';

  @override
  String get workoutHold => 'Hold';

  @override
  String get workoutRestLabel => 'Rest';

  @override
  String workoutNextLabel(String name) {
    return 'Next: $name';
  }

  @override
  String get workoutDoneTitle => 'Workout complete!';

  @override
  String workoutDoneCount(int n) {
    return '$n exercises done';
  }

  @override
  String get workoutStop => 'Stop';

  @override
  String get workoutSkip => 'Next';

  @override
  String get workoutBackToStart => 'Back to start';

  @override
  String get exSquat => 'Squats';

  @override
  String get exPushup => 'Push-ups';

  @override
  String get exLunge => 'Lunges';

  @override
  String get exBurpee => 'Burpees';

  @override
  String get exCrunch => 'Crunches';

  @override
  String get exPlank => 'Plank';

  @override
  String get exWallsit => 'Wall sit';

  @override
  String get exPullup => 'Pull-ups';

  @override
  String wsSetStart(String name, int set, int reps) {
    return '$name, set $set, $reps reps. Go!';
  }

  @override
  String wsSetStartAgain(int set) {
    return 'Set $set. Go!';
  }

  @override
  String wsTimeStart(String name, int dur) {
    return '$name, $dur seconds. Go!';
  }

  @override
  String wsFreeStart(String name) {
    return '$name, free count. Go!';
  }

  @override
  String get wsLastSet => 'Last set! Push through';

  @override
  String get wsHalfway => 'Halfway there';

  @override
  String get wsTenLeft => 'Ten seconds left';

  @override
  String wsSetDoneRest(int set, int rest) {
    return 'Set $set done. Rest $rest seconds';
  }

  @override
  String wsExDoneRest(String name, int rest) {
    return '$name done. Rest $rest seconds';
  }

  @override
  String wsNextEx(String name, String amount) {
    return 'Next: $name, $amount';
  }

  @override
  String wsNextSet(int set) {
    return 'Next: set $set';
  }

  @override
  String get wsAllDone => 'Workout complete! Great job';

  @override
  String wsAmountTime(int dur) {
    return '$dur seconds';
  }

  @override
  String wsAmountReps(int reps) {
    return '$reps reps';
  }

  @override
  String get wsAmountFree => 'free count';

  @override
  String workoutSummaryReps(int sets, int reps, String pace) {
    return '$sets sets × $reps reps · ${pace}s';
  }

  @override
  String workoutSummaryTime(int dur) {
    return '${dur}s hold';
  }

  @override
  String workoutSummaryFree(String pace) {
    return 'free count · ${pace}s';
  }

  @override
  String get workoutCustomAdd => '+ Custom exercise';

  @override
  String get workoutCustomTitle => 'Create custom exercise';

  @override
  String get workoutCustomNameHint => 'Exercise name (e.g. Deadlift)';

  @override
  String get workoutTypeReps => 'Sets × reps';

  @override
  String get workoutTypeTime => 'Timed';

  @override
  String get workoutTypeFree => 'Free';

  @override
  String get workoutCustomRepsDesc =>
      'Default 3 sets × 10 reps · pace 2.0s — edit in routine';

  @override
  String get workoutCustomTimeDesc => 'Default 30s hold — edit in routine';

  @override
  String get workoutCustomFreeDesc =>
      'Endless count, manual finish · pace 2.0s';

  @override
  String get workoutCustomCancel => 'Cancel';

  @override
  String get workoutCustomCreate => 'Create & add';

  @override
  String workoutSecsLeft(int t) {
    return '${t}s left';
  }

  @override
  String get wsGetReady => 'Get ready! Starting soon';

  @override
  String get prepTab => 'Checklist';

  @override
  String get prepTitle => 'Packing';

  @override
  String get prepAutoReset => 'resets every morning 🌅';

  @override
  String get prepAutoResetHint => '🌙 lists are not auto-reset';

  @override
  String get prepAllPacked => 'All packed ✓';

  @override
  String prepPackedCount(int n, int m) {
    return '$n/$m packed';
  }

  @override
  String get prepAllPackedGo => 'All packed — go! ✓';

  @override
  String get prepCongrats => '🎉 All packed!';

  @override
  String get prepNewListHint => 'New list (e.g. Travel)';

  @override
  String get prepEdit => 'Edit';

  @override
  String get prepEditDone => 'Done';

  @override
  String get prepAddItemHint => 'Add item, then Enter';

  @override
  String get prepDailyReset => 'Reset every morning';

  @override
  String get prepDailyResetHint =>
      'off = manual reset (one-off lists like travel)';

  @override
  String get prepDeleteList => 'Delete list';

  @override
  String get prepUncheckAll => 'Uncheck all';

  @override
  String get prepEmptyItems => 'No items — tap Edit to add';

  @override
  String get prepEmptyItemsEdit => 'Add items below';

  @override
  String get careSection => 'Sound & interruptions';

  @override
  String get careQuietHours => 'Quiet hours';

  @override
  String get careQuietHoursDesc => '22:00–07:00 vibrate instead of sounds';

  @override
  String get carePreAlarm => 'Pre-alert';

  @override
  String get carePreAlarmDesc => 'silent heads-up before a timer ends';

  @override
  String get carePreAlarmOff => 'Off';

  @override
  String carePreAlarmMin(int n) {
    return '$n min';
  }

  @override
  String get careTone => 'Alert wording';

  @override
  String get careToneDesc => 'tone used in completion messages';

  @override
  String get careToneWarm => 'Warm';

  @override
  String get careToneNeutral => 'Neutral';

  @override
  String get careToneBrief => 'Brief';

  @override
  String get careTonePreview => 'Preview';

  @override
  String doneMsgWarm(String name) {
    return '\'$name\' is done. Nice work ☺';
  }

  @override
  String doneMsgNeutral(String name) {
    return '$name · 00:00';
  }

  @override
  String doneMsgBrief(String name) {
    return '$name done';
  }

  @override
  String preAlarmBanner(String name, int n) {
    return '\'$name\' — $n min left';
  }

  @override
  String get preAlarmExtend => '+5 min';

  @override
  String get catAll => 'All';

  @override
  String get catCooking => 'Cooking';

  @override
  String get catFocus => 'Focus';

  @override
  String get catChore => 'Chores';

  @override
  String get presetRecent => 'Recent';

  @override
  String get cookRamen => 'Ramen';

  @override
  String get cookPasta => 'Boil pasta';

  @override
  String get cookEgg => 'Soft-boiled egg';

  @override
  String get cookSauce => 'Reduce sauce';

  @override
  String get cookRice => 'Soak rice';

  @override
  String get alarmDoneTitle => 'Timer finished';

  @override
  String alarmMultiDone(int n) {
    return '$n finished';
  }

  @override
  String alarmOf(String d) {
    return '$d timer';
  }

  @override
  String get alarmAck => 'Done ✓';

  @override
  String get alarmAckOnly => 'Acknowledge';

  @override
  String alarmExtended(int n) {
    return 'Extended $n×';
  }

  @override
  String get alarmRealarmNote => 'Rings again every minute until you confirm';

  @override
  String get alarmRinging => 'Done · ringing';

  @override
  String alarmAgoMin(int n, int r) {
    return '$n min ago · rang $r×';
  }

  @override
  String get alarmStillRunning => 'Still running';

  @override
  String get alarmNextUp => 'Next ↓';

  @override
  String ttsOverdue(String name, int n) {
    return '$name, $n minutes over';
  }

  @override
  String get careRealarm => 'Re-ring until confirmed';

  @override
  String get careRealarmDesc =>
      'finished timers ring every minute until acknowledged';

  @override
  String get loopToggleDesc => 'auto-repeat multiple steps';

  @override
  String get loopAddStep => '+ Add step (max 4)';

  @override
  String get loopRepeat => 'Repeat';

  @override
  String get loopTotal => 'Total time';

  @override
  String get loopSaveStart => 'Save & start';

  @override
  String loopStepTag(String step, int round, int total) {
    return '$step $round/$total';
  }

  @override
  String loopRoundStart(int n, String step) {
    return 'Round $n — $step started';
  }

  @override
  String loopStepStart(String step) {
    return '$step started';
  }

  @override
  String get loopSkipStep => 'Skip step';

  @override
  String get careIntervalCooking => 'Cooking interval';

  @override
  String get careIntervalChore => 'Chores interval';

  @override
  String get careIntervalOther => 'Other interval';

  @override
  String get careTtsName => 'Speak timer name';

  @override
  String get careTtsNameDesc => '\"Boil pasta, finished\"';

  @override
  String get careKeepDone => 'Keep finished timers';

  @override
  String get careKeepDoneDesc => 'leave completed timers in the list';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsToday => 'Today';

  @override
  String get statsWeek => 'Week';

  @override
  String get statsMonth => 'Month';

  @override
  String statsFocusedTime(String period) {
    return '$period focused time';
  }

  @override
  String get statsSessions => 'Sessions';

  @override
  String get statsStreak => 'Streak';

  @override
  String get statsBest => 'Best';

  @override
  String statsDays(int n) {
    return '${n}d';
  }

  @override
  String statsSessionsN(int n) {
    return '${n}x';
  }

  @override
  String get statsLast7 => 'Last 7 days';

  @override
  String get statsByActivity => 'By activity';

  @override
  String get statsEmpty => 'No records yet — finish a timer to see stats';

  @override
  String statsInsightTop(String day, int n) {
    return 'You focused most on $day. Now on a $n-day streak!';
  }

  @override
  String get statsPrivacy => 'Data stays on this device. No account, no cloud.';

  @override
  String statsHoursMin(int h, int m) {
    return '${h}h ${m}m';
  }

  @override
  String statsMinOnly(int m) {
    return '${m}m';
  }

  @override
  String get settingsStats => 'Activity statistics';

  @override
  String get settingsStatsDesc => 'focused time, sessions, streak';

  @override
  String get onboardTitle => 'Let\'s make sure alarms ring';

  @override
  String get onboardSub =>
      'Just two things. Everything else works out of the box.';

  @override
  String get onboardNotifTitle => 'Allow notifications';

  @override
  String get onboardNotifDesc => 'so we can tell you when a timer ends';

  @override
  String get onboardBatteryTitle => 'Keep running in the background';

  @override
  String get onboardBatteryDesc =>
      'If this stays off, alarms can silently stop after you close the app. Choose \"Unrestricted\".';

  @override
  String get onboardGrant => 'Allow';

  @override
  String get onboardAllow => 'Go allow';

  @override
  String get onboardDone => 'Done ✓';

  @override
  String get onboardLater => 'I\'ll do it later';

  @override
  String get onboardStart => 'Start';

  @override
  String get checkAlarmTitle => 'Alarms may stop';

  @override
  String get checkAlarmDesc =>
      'Battery saver is putting the app to sleep. Takes a minute to fix.';

  @override
  String get checkAlarmNotifDesc =>
      'Notifications are off — timers can\'t alert you.';

  @override
  String get checkFix => 'Fix';

  @override
  String get diagTitle => 'When alarms don\'t ring';

  @override
  String get diagSub => 'We checked for you. Takes a minute to fix.';

  @override
  String diagWarnTitle(int n) {
    return '$n things need fixing';
  }

  @override
  String get diagWarnDesc =>
      'As is, alarms may not ring after you close the app.';

  @override
  String get diagAllGood => 'Everything looks good';

  @override
  String get diagAllGoodDesc =>
      'Alarms will ring even after you close the app.';

  @override
  String get diagResult => 'Check results';

  @override
  String get diagNotifTitle => 'Notifications allowed';

  @override
  String get diagNotifOk => 'Alerts can show on screen';

  @override
  String get diagNotifBad => 'Notifications are off — timers can\'t alert you.';

  @override
  String get diagBatteryTitle => 'Battery saver exception';

  @override
  String get diagBatteryOk => 'The app won\'t be put to sleep';

  @override
  String get diagBatteryBad =>
      'Battery saver is sleeping the app. Scheduled alarms get delayed or dropped.';

  @override
  String get diagOverlayTitle => 'Display over other apps';

  @override
  String get diagOverlayOk => 'The overlay pill can show';

  @override
  String get diagOverlayBad => 'The overlay pill won\'t appear.';

  @override
  String get diagFix => 'Fix';

  @override
  String get diagFixAll => 'Fix all';

  @override
  String get diagTestAlarm => 'Send a test alarm now';

  @override
  String get diagTestNote =>
      'Try closing the app after sending, to confirm it still rings.';

  @override
  String get diagTestSent => 'Test alarm sent — check your notifications';

  @override
  String get settingsDiag => 'When alarms don\'t ring';

  @override
  String get settingsDiagDesc => 'self-check: permissions & battery';

  @override
  String get settingsGroupNotify => 'Notifications';

  @override
  String get settingsGroupDisplay => 'Display';

  @override
  String get settingsGroupData => 'My data';

  @override
  String get settingsGroupControl => 'Controls';

  @override
  String get settingsGroupHelp => 'Help';

  @override
  String get settingsAlarmSection => 'Alarms & re-ring';

  @override
  String get settingsAlarmSectionDesc => 'Ring again until you confirm';

  @override
  String get settingsSoundSection => 'Sound';

  @override
  String get settingsSoundSectionDesc => 'Sound effects and vibration';

  @override
  String get settingsVoiceSection => 'Voice guidance';

  @override
  String get settingsVoiceSectionDesc => 'Spoken alerts when you can\'t look';

  @override
  String get alarmPageSub => 'We\'ll keep reminding you until you confirm.';

  @override
  String get soundPageSub => 'Tap any option to hear it.';

  @override
  String get voicePageSub =>
      'Speaks out loud when you can\'t look at the screen.';

  @override
  String get settingsSpeechRate => 'Speech rate';

  @override
  String get speechRateSlow => 'Slow';

  @override
  String get speechRateNormal => 'Normal';

  @override
  String get speechRateFast => 'Fast';

  @override
  String get grpAlarmBasic => 'Basic behavior';

  @override
  String get grpAlarmInterval => 'Re-ring interval';

  @override
  String get grpAlarmPrep => 'Before it ends';

  @override
  String get grpSoundSet => 'Sound set';

  @override
  String get grpSoundFeedback => 'Feedback';

  @override
  String get grpVoiceUse => 'Use';

  @override
  String get grpVoiceVoice => 'Voice';

  @override
  String get grpVoicePreview => 'Preview';

  @override
  String get grpVoiceWorkout => 'Workout';

  @override
  String get grpAlarmDone => 'Completion message';

  @override
  String get settingsListSection => 'List display';

  @override
  String get settingsListSectionDesc => 'How timers look on the main screen';

  @override
  String get listPageSub => 'Set how timers look on the main screen.';

  @override
  String get grpListRing => 'Progress ring';

  @override
  String get listShowRing => 'Show progress ring';

  @override
  String get listShowRingDesc => 'A filling ring shows time left at a glance';

  @override
  String get grpListSize => 'Card size';

  @override
  String get listDensityCompact => 'Compact';

  @override
  String get listDensityNormal => 'Normal';

  @override
  String get listDensityLarge => 'Large';

  @override
  String get grpListSort => 'Sort';

  @override
  String get listSortRemain => 'Least time left';

  @override
  String get listSortCreated => 'Order added';

  @override
  String get grpListDone => 'Finished timers';

  @override
  String get listKeepDone => 'Keep in list for';

  @override
  String get listKeepOff => 'Hide right away';

  @override
  String get listDimDone => 'Dim finished';

  @override
  String get listDimDoneDesc => 'Lower opacity for completed timers';

  @override
  String get settingsOverlaySection => 'Overlay pill';

  @override
  String get settingsOverlaySectionDesc => 'Floating timer over other apps';

  @override
  String get overlayPageSub => 'See time left while using other apps.';

  @override
  String get grpOverlayUse => 'Use';

  @override
  String get overlayShowOver => 'Show over other apps';

  @override
  String get overlayShowOverDesc => 'Needs the display-over-apps permission';

  @override
  String get overlayShowLock => 'Show on lock screen';

  @override
  String get overlayShowLockDesc => 'May be limited by your device';

  @override
  String get grpOverlaySize => 'Size';

  @override
  String get overlaySizeSmall => 'Small';

  @override
  String get overlaySizeNormal => 'Normal';

  @override
  String get overlaySizeLarge => 'Large';

  @override
  String get grpOverlaySide => 'Edge';

  @override
  String get overlaySideLeft => 'Left edge';

  @override
  String get overlaySideRight => 'Right edge';

  @override
  String get grpOverlayContent => 'Content';

  @override
  String get overlayShowName => 'Timer name';

  @override
  String get overlayShowNameDesc => 'Off shows time only';

  @override
  String get overlayAutoHide => 'Auto-hide when finished';

  @override
  String get overlayAutoHideDesc => 'Disappears once acknowledged';

  @override
  String get overlayGrantCta => 'Grant';

  @override
  String get overlayPreviewHint => 'Drag to move it';

  @override
  String get overlayPreviewLabel => 'Preview';

  @override
  String get textTimerEntry => 'Say or type';

  @override
  String get textTimerEntryDesc => '“Ramen 4 and a half min, egg 6 min”';

  @override
  String get textTimerTitle => 'Say or type';

  @override
  String get textTimerInputHint => 'e.g. 라면 사분반, 계란 육분';

  @override
  String get textTimerHelper => 'Write several at once, separated by commas.';

  @override
  String get textTimerExamplesHead => 'Try writing like this';

  @override
  String get textTimerOffline => 'Works offline · nothing is uploaded';

  @override
  String get textTimerParse => 'Read it';

  @override
  String get textTimerConfirmTitle => 'Make these?';

  @override
  String get textTimerConfirmSub => 'Tap a card to remove it, or rewrite.';

  @override
  String get textTimerRetype => 'Rewrite';

  @override
  String textTimerStartN(int n) {
    return 'Start $n';
  }

  @override
  String get textTimerSaveN => 'Save as presets';

  @override
  String get textTimerUnparsed => 'Couldn’t find a time · rewrite this part';

  @override
  String get textTimerFromPreset => 'Existing preset · kept its color & alarm';

  @override
  String get textTimerRangeShort => 'Picked the shorter side';

  @override
  String get textTimerEmpty => 'Nothing to start yet';

  @override
  String get textTimerNoTime => 'No time found. Try “ramen 4 min”.';

  @override
  String get settingsVoiceStart => 'Start by voice';

  @override
  String get settingsVoiceStartDesc => 'Turn on timers by talking, hands-free';

  @override
  String get voiceStartSub =>
      'Turn on a timer by talking — no need to pick up your phone.';

  @override
  String get voiceHeroHint => 'Say this and a 25-min focus starts right away';

  @override
  String get voiceHeroQuote => '“Hey Google, start focus”';

  @override
  String get voiceRoutineHead => 'Turn on automatically';

  @override
  String get voiceRoutineSub =>
      'Add to a Galaxy routine and it starts without you saying anything.';

  @override
  String get voiceRecipeHead => 'Suggested recipes';

  @override
  String get recipeDesk => 'Focus when I sit at my desk';

  @override
  String get recipeDeskWhen => 'Home Wi-Fi + weekday afternoon';

  @override
  String get recipeCharge => 'Focus when I put it on the charger';

  @override
  String get recipeChargeWhen => 'Charging starts · with Do Not Disturb';

  @override
  String get recipeWorkout => 'Voice mode when I open a workout app';

  @override
  String get recipeWorkoutWhen => 'A specific app launches';

  @override
  String get recipeSleep => 'Stop everything at bedtime';

  @override
  String get recipeSleepWhen => 'Bedtime mode begins';

  @override
  String routineCopied(String name) {
    return 'Copied the \'$name\' link';
  }

  @override
  String get routineStepsHead => 'Now do this';

  @override
  String get routineStep1 => 'Open the Routines app';

  @override
  String get routineStep1Desc => 'The button below opens it';

  @override
  String get routineStep2 => 'Pick ‘Open app’ as the action';

  @override
  String get routineStep2Desc => 'Long-press the address field and paste';

  @override
  String get routineStep3 => 'Choose a condition and save';

  @override
  String get routineStep3Desc => 'Wi-Fi · time · place — anything';

  @override
  String get routineOpenApp => 'Open Routines app';

  @override
  String get routineCantOpen =>
      'Couldn’t open the Routines app. The link is copied — paste it there.';

  @override
  String get voiceStarted => 'Started by voice';

  @override
  String voiceStartedTimer(String name) {
    return 'Started ‘$name’';
  }

  @override
  String get voiceStopHint =>
      'Several timers are running — open the app to choose.';

  @override
  String get scFocus => 'Focus 25 min';

  @override
  String get scRest => 'Break 5 min';

  @override
  String get scStop => 'Stop timer';

  @override
  String get scStatus => 'Time left';

  @override
  String get ocrEntry => 'Scan a package';

  @override
  String get ocrEntryDesc => 'Reads the cook time and makes it';

  @override
  String get ocrCamera => 'Take a photo';

  @override
  String get ocrAlbum => 'Pick from album';

  @override
  String get ocrReading => 'Reading text…';

  @override
  String get ocrNoTime => 'No time found — set it by hand';

  @override
  String get ocrTitle => 'Scan package';

  @override
  String get seqParallel => 'Start together';

  @override
  String get seqSequential => 'One after another';

  @override
  String get seqNote => 'Each step starts when the previous finishes.';

  @override
  String get seqAckTitle => 'Confirm before next';

  @override
  String get seqAckAuto => 'Auto-picked';

  @override
  String get seqAckOnNote =>
      'Next starts when you confirm each step — for hands-on recipes.';

  @override
  String get seqAckOffNote =>
      'Next starts right after each step — for continuous steps.';

  @override
  String get seqFinishTogether => 'Finish together';

  @override
  String get seqFinishNote =>
      'Starts with the longest first so everything finishes at the same time.';

  @override
  String seqFinishAt(String time) {
    return 'All done at $time';
  }

  @override
  String get ftWaiting => 'Waiting';

  @override
  String get ftStartArmed => 'Time to start';

  @override
  String ftStartIn(String t) {
    return 'starts in $t';
  }

  @override
  String get ftStartNow => 'Start now';

  @override
  String ftDriftTitle(String name, int min) {
    return '$name will finish $min min late';
  }

  @override
  String get ftDriftDesc => 'Extend the running one to realign, or leave it.';

  @override
  String ftDriftExtend(String name, int min) {
    return '$name +$min:00';
  }

  @override
  String get ftDriftLeave => 'Leave it';

  @override
  String ftStartArmedMsg(String name) {
    return 'Time to start $name — confirm to start';
  }

  @override
  String get undo => 'Undo';

  @override
  String presetDeletedToast(String name) {
    return 'Deleted $name';
  }

  @override
  String get waterTitle => 'Water reminder';

  @override
  String get waterToday => 'Today';

  @override
  String waterCups(int n, int goal) {
    return '$n / $goal cups';
  }

  @override
  String get waterWhenGroup => 'When to remind';

  @override
  String get waterInterval => 'Every interval';

  @override
  String get waterFixed => 'Fixed times';

  @override
  String get waterActiveHours => 'Active hours only';

  @override
  String get waterWithTimer => 'With timer end';

  @override
  String get waterWithTimerSub =>
      'Add a water nudge when you check another alarm';

  @override
  String get waterHowGroup => 'How it alerts';

  @override
  String get waterIntensity => 'Intensity';

  @override
  String get waterIntensitySub => 'Rings once and steps back — no re-alarm';

  @override
  String get waterBannerMode => 'Banner';

  @override
  String get waterOneSound => 'One sound';

  @override
  String get waterGoal => 'Daily goal';

  @override
  String waterGoalCups(int n) {
    return '$n cups';
  }

  @override
  String get waterEnable => 'Use water reminder';

  @override
  String get waterNote =>
      'Interval counts from when you tap \"Drank\". Merges with a fixed time if within 30 min.';

  @override
  String get waterBannerTitle => 'A glass of water';

  @override
  String waterBannerSub(int n, String time) {
    return '$n today · next $time';
  }

  @override
  String get waterDrank => 'Drank';

  @override
  String get waterLater30 => 'In 30 min';

  @override
  String get waterStopToday => 'Done for today';

  @override
  String get waterBgNote =>
      'Fires even when the app is closed (needs exact-alarm permission).';

  @override
  String get waterSettingsDesc => 'Remind to drink at intervals or set times';

  @override
  String get waterNotifBody => 'Time to drink water';
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
  String get navTimer => '計時器';

  @override
  String get navMulti => '多重';

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
  String get settingsTelemetryDesc => '傳送匿名診斷與 ANR 資訊（不含個人資料）';

  @override
  String get overlayLongPressHint => '長按時鐘，然後點按想要移動到的位置圓點';

  @override
  String get editCoachGrid => '點按方格即可移到該處';

  @override
  String get editCoachDpad => '方向鍵微調 · 長按可連續';

  @override
  String get editCoachControls => '⤢ 大小 · ⇄ 切換左右 · ✓ 完成';

  @override
  String get editCoachDismiss => '點按任意處開始';

  @override
  String get settingsTextSize => '文字大小';

  @override
  String get textSizeSmall => '小';

  @override
  String get textSizeNormal => '標準';

  @override
  String get textSizeLarge => '大';

  @override
  String get textSizeXLarge => '特大';

  @override
  String get textSizePreview => '計時器 25:00 預覽';

  @override
  String get a11yClose => '關閉';

  @override
  String get a11yEditSegment => '編輯區間';

  @override
  String get a11yDismissBanner => '關閉提示';

  @override
  String get settingsHaptics => '觸覺回饋';

  @override
  String get settingsHapticsDesc => '開始、暫停和完成時震動';

  @override
  String get settingsColorblind => '色盲模式';

  @override
  String get settingsColorblindDesc => '用虛線而非僅顏色區分碼錶';

  @override
  String get settingsHighContrast => '高對比度';

  @override
  String get settingsHighContrastDesc => '提亮次要文字以便閱讀';

  @override
  String get multiTimerTitle => '多個計時器';

  @override
  String get multiTimerAdd => '新增計時器';

  @override
  String get multiTimerNameHint => '計時器名稱';

  @override
  String get multiTimerEmpty => '還沒有計時器，點 + 新增。';

  @override
  String get multiTimerDone => '完成';

  @override
  String get multiTimerOverlayOn => '顯示浮動視窗';

  @override
  String get multiTimerOverlayOff => '隱藏浮動視窗';

  @override
  String get multiTimerOverlayPermission => '請允許「顯示在其他應用程式上層」以使用浮動視窗';

  @override
  String multiTimerOverlayLimit(int count) {
    return '最多可顯示 $count 個浮動視窗';
  }

  @override
  String multiTimerAllDone(int count) {
    return '$count 個計時器完成';
  }
}
