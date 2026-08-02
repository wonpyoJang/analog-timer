// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'एनालॉग टाइमर';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get manage => 'प्रबंधित करें';

  @override
  String get timerSection => 'टाइमर';

  @override
  String get btnStart => 'शुरू';

  @override
  String get btnPause => 'रोकें';

  @override
  String get btnResume => 'जारी रखें';

  @override
  String get btnRunning => 'चल रहा है…';

  @override
  String get btnNext => 'अगला';

  @override
  String get btnReset => 'रीसेट';

  @override
  String get stopwatchSection => 'स्टॉपवॉच';

  @override
  String get btnLap => 'लैप';

  @override
  String lapToast(int num, String time) {
    return 'लैप $num    $time';
  }

  @override
  String get timerSegments => 'टाइमर सेगमेंट';

  @override
  String get addSegment => '+ सेगमेंट जोड़ें';

  @override
  String get loopToggle => 'लूप';

  @override
  String get minutesUnit => 'मिनट';

  @override
  String get segmentColor => 'सेगमेंट का रंग';

  @override
  String get segments => 'सेगमेंट';

  @override
  String get savePresetChip => 'वर्तमान सहेजें';

  @override
  String presetApplied(String name) {
    return 'प्रीसेट जोड़ा गया · $name';
  }

  @override
  String get noSegmentsToSave => 'सहेजने के लिए कोई सेगमेंट नहीं';

  @override
  String get savePresetTitle => 'प्रीसेट सहेजें';

  @override
  String get presetNameHint => 'जैसे अध्ययन 50/10';

  @override
  String get presetName => 'प्रीसेट का नाम';

  @override
  String get presetManageTitle => 'प्रीसेट प्रबंधित करें';

  @override
  String get newPreset => 'नया प्रीसेट';

  @override
  String get editPreset => 'प्रीसेट संपादित करें';

  @override
  String get deletePresetTitle => 'प्रीसेट हटाएँ';

  @override
  String deletePresetConfirm(String name) {
    return '\'$name\' हटाएँ?';
  }

  @override
  String get noPresets =>
      'कोई सहेजा गया प्रीसेट नहीं।\nऊपर दाईं ओर \"नया प्रीसेट\" से एक जोड़ें।';

  @override
  String get enterName => 'कृपया एक नाम दर्ज करें';

  @override
  String get atLeastOneSegment => 'कम से कम एक सेगमेंट जोड़ें';

  @override
  String get legendTimer => 'टाइमर — भीतरी सर्पिल';

  @override
  String get legendStopwatch => 'स्टॉपवॉच — बाहरी वलय';

  @override
  String get statusDone => 'पूर्ण';

  @override
  String get statusWaiting => 'तैयार';

  @override
  String get widget => 'विजेट';

  @override
  String get widgetOn => 'विजेट चालू';

  @override
  String get notifyTimerDoneTitle => 'टाइमर पूर्ण';

  @override
  String get notifyTimerDoneBody => 'सभी सेगमेंट समाप्त 🎉';

  @override
  String get notifySegmentDoneTitle => 'सेगमेंट पूर्ण';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev पूर्ण · अगला: $next';
  }

  @override
  String get language => 'भाषा';

  @override
  String get languageSystem => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get presetPomodoro => 'पोमोडोरो 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => 'गहन कार्य 90/20';

  @override
  String get segFocus => 'फोकस';

  @override
  String get segBreak => 'विराम';

  @override
  String get stopwatchLaps => 'स्टॉपवॉच लैप';

  @override
  String get noLaps => 'अभी कोई लैप नहीं';

  @override
  String get timerLogTitle => 'टाइमर लॉग';

  @override
  String get noEvents => 'कोई इवेंट नहीं';

  @override
  String lapLabel(int num) {
    return 'लैप $num';
  }

  @override
  String logStart(String name) {
    return 'शुरू: $name';
  }

  @override
  String get logPaused => 'रोका गया';

  @override
  String get logReset => 'रीसेट';

  @override
  String logSkipped(String name) {
    return 'छोड़ा गया: $name';
  }

  @override
  String logDone(String name) {
    return 'पूर्ण: $name';
  }

  @override
  String get logAllDone => 'सभी सेगमेंट पूर्ण 🎉';

  @override
  String logLoop(String count) {
    return '🔁 लूप $count पूर्ण';
  }

  @override
  String get batteryLow => 'बैटरी कम — कृपया चार्ज करें';

  @override
  String get batteryMon => 'बैटरी';

  @override
  String get batteryMonOn => 'बैटरी ON';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get settingsBattery => 'बैटरी निगरानी';

  @override
  String get settingsBatteryDesc => 'जब बैटरी 20% या कम हो तो चेतावनी दें';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get modeLabelLog => 'लॉग';

  @override
  String get modeLabelToday => 'आज';

  @override
  String get modeLabelPlan => 'योजना';

  @override
  String get dayLogTitle => 'दिनचर्या लॉग';

  @override
  String get dayLogEmpty => 'इस दिन के लिए कोई गतिविधि दर्ज नहीं';

  @override
  String get dayPlanTitle => 'दिन की योजना';

  @override
  String get dayPlanEmpty => 'इस दिन के लिए कोई योजना नहीं';

  @override
  String get planSaveAsCurrent => 'योजना के रूप में सहेजें';

  @override
  String get planLoadIntoTimer => 'टाइमर में लोड करें';

  @override
  String get planSave => 'सहेजें';

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
      'Include at least one modifier (Ctrl, Shift, Alt)';

  @override
  String get hotkeyDuplicate => 'Already used by another action';

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
      'घड़ी को देर तक दबाएँ, फिर उसे वहाँ ले जाने के लिए किसी बिंदु पर टैप करें';
}
