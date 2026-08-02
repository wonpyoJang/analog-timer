// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مؤقت تناظري';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get manage => 'إدارة';

  @override
  String get timerSection => 'المؤقّت';

  @override
  String get btnStart => 'ابدأ';

  @override
  String get btnPause => 'إيقاف مؤقت';

  @override
  String get btnResume => 'استئناف';

  @override
  String get btnRunning => 'قيد التشغيل…';

  @override
  String get btnNext => 'التالي';

  @override
  String get btnReset => 'تصفير';

  @override
  String get stopwatchSection => 'ساعة الإيقاف';

  @override
  String get btnLap => 'لفة';

  @override
  String lapToast(int num, String time) {
    return 'اللفة $num    $time';
  }

  @override
  String get timerSegments => 'مقاطع المؤقّت';

  @override
  String get addSegment => '+ إضافة مقطع';

  @override
  String get loopToggle => 'تكرار';

  @override
  String get minutesUnit => 'دقيقة';

  @override
  String get segmentColor => 'لون المقطع';

  @override
  String get segments => 'المقاطع';

  @override
  String get savePresetChip => 'حفظ الحالي';

  @override
  String presetApplied(String name) {
    return 'تمت إضافة الإعداد · $name';
  }

  @override
  String get noSegmentsToSave => 'لا توجد مقاطع للحفظ';

  @override
  String get savePresetTitle => 'حفظ الإعداد';

  @override
  String get presetNameHint => 'مثال: دراسة 50/10';

  @override
  String get presetName => 'اسم الإعداد';

  @override
  String get presetManageTitle => 'إدارة الإعدادات';

  @override
  String get newPreset => 'إعداد جديد';

  @override
  String get editPreset => 'تعديل الإعداد';

  @override
  String get deletePresetTitle => 'حذف الإعداد';

  @override
  String deletePresetConfirm(String name) {
    return 'حذف «$name»؟';
  }

  @override
  String get noPresets =>
      'لا توجد إعدادات محفوظة.\nأضف واحدًا عبر «إعداد جديد» في أعلى اليمين.';

  @override
  String get enterName => 'يرجى إدخال اسم';

  @override
  String get atLeastOneSegment => 'أضف مقطعًا واحدًا على الأقل';

  @override
  String get legendTimer => 'المؤقّت — الحلزون الداخلي';

  @override
  String get legendStopwatch => 'ساعة الإيقاف — الحلقة الخارجية';

  @override
  String get statusDone => 'تم';

  @override
  String get statusWaiting => 'جاهز';

  @override
  String get widget => 'الأداة';

  @override
  String get widgetOn => 'الأداة مفعّلة';

  @override
  String get notifyTimerDoneTitle => 'اكتمل المؤقّت';

  @override
  String get notifyTimerDoneBody => 'اكتملت جميع المقاطع 🎉';

  @override
  String get notifySegmentDoneTitle => 'اكتمل المقطع';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return 'اكتمل $prev · التالي: $next';
  }

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'إعداد النظام الافتراضي';

  @override
  String get presetPomodoro => 'بومودورو 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => 'العمل العميق 90/20';

  @override
  String get segFocus => 'تركيز';

  @override
  String get segBreak => 'استراحة';

  @override
  String get stopwatchLaps => 'لفّات ساعة الإيقاف';

  @override
  String get noLaps => 'لا توجد لفّات بعد';

  @override
  String get timerLogTitle => 'سجل المؤقّت';

  @override
  String get noEvents => 'لا توجد أحداث';

  @override
  String lapLabel(int num) {
    return 'اللفة $num';
  }

  @override
  String logStart(String name) {
    return 'بدء: $name';
  }

  @override
  String get logPaused => 'متوقف مؤقتًا';

  @override
  String get logReset => 'إعادة تعيين';

  @override
  String logSkipped(String name) {
    return 'تم التخطي: $name';
  }

  @override
  String logDone(String name) {
    return 'اكتمل: $name';
  }

  @override
  String get logAllDone => 'اكتملت جميع المقاطع 🎉';

  @override
  String logLoop(String count) {
    return '🔁 اكتملت الدورة $count';
  }

  @override
  String get batteryLow => 'البطارية منخفضة — يرجى الشحن';

  @override
  String get batteryMon => 'بطارية';

  @override
  String get batteryMonOn => 'بطارية ON';

  @override
  String get settings => 'الإعدادات';

  @override
  String get settingsBattery => 'مراقبة البطارية';

  @override
  String get settingsBatteryDesc => 'تحذير عند انخفاض البطارية إلى 20٪ أو أقل';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get modeLabelLog => 'سجل';

  @override
  String get modeLabelToday => 'اليوم';

  @override
  String get modeLabelPlan => 'خطة';

  @override
  String get dayLogTitle => 'سجل اليوم';

  @override
  String get dayLogEmpty => 'لا توجد أنشطة مسجلة لهذا اليوم';

  @override
  String get dayPlanTitle => 'خطة اليوم';

  @override
  String get dayPlanEmpty => 'لا توجد خطة لهذا اليوم';

  @override
  String get planSaveAsCurrent => 'حفظ كخطة';

  @override
  String get planLoadIntoTimer => 'تحميل في المؤقت';

  @override
  String get planSave => 'حفظ';

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
  String get overlayLongPressHint =>
      'اضغط مطولًا على الساعة ثم انقر على نقطة لنقلها إلى هناك';
}
