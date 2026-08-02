// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ANALOG TIMER';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get manage => 'Manage';

  @override
  String get timerSection => 'TIMER';

  @override
  String get btnStart => 'START';

  @override
  String get btnPause => 'PAUSE';

  @override
  String get btnResume => 'RESUME';

  @override
  String get btnRunning => 'RUNNING…';

  @override
  String get btnNext => 'NEXT';

  @override
  String get btnReset => 'RST';

  @override
  String get stopwatchSection => 'STOPWATCH';

  @override
  String get btnLap => 'LAP';

  @override
  String lapToast(int num, String time) {
    return 'Lap $num    $time';
  }

  @override
  String get timerSegments => 'TIMER SEGMENTS';

  @override
  String get addSegment => '+ Add segment';

  @override
  String get loopToggle => 'Loop';

  @override
  String get minutesUnit => 'min';

  @override
  String get segmentColor => 'Segment color';

  @override
  String get segments => 'Segments';

  @override
  String get savePresetChip => 'Save current';

  @override
  String presetApplied(String name) {
    return 'Preset added · $name';
  }

  @override
  String get noSegmentsToSave => 'No segments to save';

  @override
  String get savePresetTitle => 'Save preset';

  @override
  String get presetNameHint => 'e.g. Study 50/10';

  @override
  String get presetName => 'Preset name';

  @override
  String get presetManageTitle => 'Manage presets';

  @override
  String get newPreset => 'New preset';

  @override
  String get editPreset => 'Edit preset';

  @override
  String get deletePresetTitle => 'Delete preset';

  @override
  String deletePresetConfirm(String name) {
    return 'Delete \'$name\'?';
  }

  @override
  String get noPresets =>
      'No saved presets.\nAdd one with \"New preset\" at the top right.';

  @override
  String get enterName => 'Please enter a name';

  @override
  String get atLeastOneSegment => 'Add at least one segment';

  @override
  String get legendTimer => 'Timer — inner spiral';

  @override
  String get legendStopwatch => 'Stopwatch — outer ring';

  @override
  String get statusDone => 'Done';

  @override
  String get statusWaiting => 'Ready';

  @override
  String get widget => 'Widget';

  @override
  String get widgetOn => 'Widget ON';

  @override
  String get notifyTimerDoneTitle => 'Timer complete';

  @override
  String get notifyTimerDoneBody => 'All segments finished 🎉';

  @override
  String get notifySegmentDoneTitle => 'Segment complete';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev done · Next: $next';
  }

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get presetPomodoro => 'Pomodoro 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => 'Deep work 90/20';

  @override
  String get segFocus => 'Focus';

  @override
  String get segBreak => 'Break';

  @override
  String get stopwatchLaps => 'Stopwatch laps';

  @override
  String get noLaps => 'No laps yet';

  @override
  String get timerLogTitle => 'Timer log';

  @override
  String get noEvents => 'No events';

  @override
  String lapLabel(int num) {
    return 'Lap $num';
  }

  @override
  String logStart(String name) {
    return 'Start: $name';
  }

  @override
  String get logPaused => 'Paused';

  @override
  String get logReset => 'Reset';

  @override
  String logSkipped(String name) {
    return 'Skipped: $name';
  }

  @override
  String logDone(String name) {
    return 'Done: $name';
  }

  @override
  String get logAllDone => 'All segments done 🎉';

  @override
  String logLoop(String count) {
    return '🔁 Loop $count done';
  }

  @override
  String get batteryLow => 'Battery low — please charge';

  @override
  String get batteryMon => 'Battery';

  @override
  String get batteryMonOn => 'Battery ON';

  @override
  String get settings => 'Settings';

  @override
  String get settingsBattery => 'Battery monitoring';

  @override
  String get settingsBatteryDesc => 'Warn when battery drops to 20% or below';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get modeLabelLog => 'Log';

  @override
  String get modeLabelToday => 'Today';

  @override
  String get modeLabelPlan => 'Plan';

  @override
  String get dayLogTitle => 'Activity Log';

  @override
  String get dayLogEmpty => 'No activity recorded for this day';

  @override
  String get dayPlanTitle => 'Day Plan';

  @override
  String get dayPlanEmpty => 'No plan set for this day';

  @override
  String get planSaveAsCurrent => 'Save as plan';

  @override
  String get planLoadIntoTimer => 'Load into timer';

  @override
  String get planSave => 'Save';

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
  String get overlayLongPressHint =>
      'Long-press the clock, then tap a dot to move it there';

  @override
  String get editCoachGrid => 'Tap a cell to jump there';

  @override
  String get editCoachDpad => 'Arrows for fine-tuning · hold to repeat';

  @override
  String get editCoachControls => '⤢ Size · ⇄ Switch side · ✓ Done';

  @override
  String get editCoachDismiss => 'Tap anywhere to start';

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
  String get settingsTextSize => 'Text size';

  @override
  String get textSizeSmall => 'Small';

  @override
  String get textSizeNormal => 'Normal';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get textSizeXLarge => 'Extra large';

  @override
  String get textSizePreview => 'Timer 25:00 preview';

  @override
  String get a11yClose => 'Close';

  @override
  String get a11yEditSegment => 'Edit segment';

  @override
  String get a11yDismissBanner => 'Dismiss';

  @override
  String get settingsHaptics => 'Haptic feedback';

  @override
  String get settingsHapticsDesc => 'Vibrate on start, pause and completion';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsDesc =>
      'Toast when a segment changes or the timer completes';

  @override
  String get settingsColorblind => 'Colorblind mode';

  @override
  String get settingsColorblindDesc =>
      'Distinguish stopwatch by dashed pattern, not just color';
}
