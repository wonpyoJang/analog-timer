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
  String get navTimer => 'مؤقت';

  @override
  String get navMulti => 'متعدد';

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
  String get settingsTelemetryDesc =>
      'إرسال تشخيصات مجهولة ومعلومات ANR (بدون بيانات شخصية)';

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
      'اضغط مطولًا على الساعة ثم انقر على نقطة لنقلها إلى هناك';

  @override
  String get editCoachGrid => 'انقر على خلية للانتقال إليها';

  @override
  String get editCoachDpad => 'الأسهم للضبط الدقيق · اضغط مطولًا للتكرار';

  @override
  String get editCoachControls => '⤢ الحجم · ⇄ تبديل الجانب · ✓ تم';

  @override
  String get editCoachDismiss => 'انقر في أي مكان للبدء';

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
  String get settingsTextSize => 'حجم الخط';

  @override
  String get textSizeSmall => 'صغير';

  @override
  String get textSizeNormal => 'عادي';

  @override
  String get textSizeLarge => 'كبير';

  @override
  String get textSizeXLarge => 'كبير جدًا';

  @override
  String get textSizePreview => 'معاينة 25:00';

  @override
  String get a11yClose => 'إغلاق';

  @override
  String get a11yEditSegment => 'تعديل المقطع';

  @override
  String get a11yDismissBanner => 'تجاهل';

  @override
  String get settingsHaptics => 'ردود فعل لمسية';

  @override
  String get settingsHapticsDesc => 'اهتزاز عند البدء والإيقاف المؤقت والإكمال';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsDesc =>
      'Toast when a segment changes or the timer completes';

  @override
  String get settingsColorblind => 'وضع عمى الألوان';

  @override
  String get settingsColorblindDesc =>
      'تمييز ساعة الإيقاف بنمط متقطع وليس باللون فقط';

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
  String get settingsHighContrast => 'تباين عالٍ';

  @override
  String get settingsHighContrastDesc => 'تفتيح النص الثانوي لتسهيل القراءة';

  @override
  String get multiTimerTitle => 'مؤقتات متعددة';

  @override
  String get multiTimerAdd => 'إضافة مؤقت';

  @override
  String get multiTimerNameHint => 'اسم المؤقت';

  @override
  String get multiTimerEmpty => 'لا مؤقتات بعد. اضغط + للإضافة.';

  @override
  String get multiTimerDone => 'تم';

  @override
  String get multiTimerOverlayOn => 'إظهار النوافذ العائمة';

  @override
  String get multiTimerOverlayOff => 'إخفاء النوافذ العائمة';

  @override
  String get multiTimerOverlayPermission =>
      'اسمح بـ \"العرض فوق التطبيقات الأخرى\" لاستخدام النوافذ العائمة';

  @override
  String multiTimerOverlayLimit(int count) {
    return 'يمكنك عرض حتى $count نافذة عائمة';
  }

  @override
  String multiTimerAllDone(int count) {
    return 'انتهى $count مؤقتات';
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
}
