// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Analog Zamanlayıcı';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'İptal';

  @override
  String get delete => 'Sil';

  @override
  String get manage => 'Yönet';

  @override
  String get timerSection => 'ZAMANLAYICI';

  @override
  String get btnStart => 'BAŞLAT';

  @override
  String get btnPause => 'DURAKLAT';

  @override
  String get btnResume => 'DEVAM';

  @override
  String get btnRunning => 'ÇALIŞIYOR…';

  @override
  String get btnNext => 'SONRAKİ';

  @override
  String get btnReset => 'SIFIRLA';

  @override
  String get stopwatchSection => 'KRONOMETRE';

  @override
  String get btnLap => 'TUR';

  @override
  String lapToast(int num, String time) {
    return 'Tur $num    $time';
  }

  @override
  String get timerSegments => 'ZAMANLAYICI BÖLÜMLERİ';

  @override
  String get addSegment => '+ Bölüm ekle';

  @override
  String get loopToggle => 'Döngü';

  @override
  String get minutesUnit => 'dk';

  @override
  String get segmentColor => 'Bölüm rengi';

  @override
  String get segments => 'Bölümler';

  @override
  String get savePresetChip => 'Mevcudu kaydet';

  @override
  String presetApplied(String name) {
    return 'Hazır ayar eklendi · $name';
  }

  @override
  String get noSegmentsToSave => 'Kaydedilecek bölüm yok';

  @override
  String get savePresetTitle => 'Hazır ayarı kaydet';

  @override
  String get presetNameHint => 'örn. Çalışma 50/10';

  @override
  String get presetName => 'Hazır ayar adı';

  @override
  String get presetManageTitle => 'Hazır ayarları yönet';

  @override
  String get newPreset => 'Yeni hazır ayar';

  @override
  String get editPreset => 'Hazır ayarı düzenle';

  @override
  String get deletePresetTitle => 'Hazır ayarı sil';

  @override
  String deletePresetConfirm(String name) {
    return '\"$name\" silinsin mi?';
  }

  @override
  String get noPresets =>
      'Kayıtlı hazır ayar yok.\nSağ üstteki \"Yeni hazır ayar\" ile bir tane ekleyin.';

  @override
  String get enterName => 'Lütfen bir ad girin';

  @override
  String get atLeastOneSegment => 'En az bir bölüm ekleyin';

  @override
  String get legendTimer => 'Zamanlayıcı — iç spiral';

  @override
  String get legendStopwatch => 'Kronometre — dış halka';

  @override
  String get statusDone => 'Bitti';

  @override
  String get statusWaiting => 'Hazır';

  @override
  String get widget => 'Widget';

  @override
  String get widgetOn => 'Widget AÇIK';

  @override
  String get notifyTimerDoneTitle => 'Zamanlayıcı tamamlandı';

  @override
  String get notifyTimerDoneBody => 'Tüm bölümler tamamlandı 🎉';

  @override
  String get notifySegmentDoneTitle => 'Bölüm tamamlandı';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev bitti · Sonraki: $next';
  }

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Sistem varsayılanı';

  @override
  String get presetPomodoro => 'Pomodoro 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => 'Derin çalışma 90/20';

  @override
  String get segFocus => 'Odak';

  @override
  String get segBreak => 'Mola';

  @override
  String get stopwatchLaps => 'Kronometre turları';

  @override
  String get noLaps => 'Henüz tur yok';

  @override
  String get timerLogTitle => 'Zamanlayıcı günlüğü';

  @override
  String get noEvents => 'Etkinlik yok';

  @override
  String lapLabel(int num) {
    return 'Tur $num';
  }

  @override
  String logStart(String name) {
    return 'Başlangıç: $name';
  }

  @override
  String get logPaused => 'Duraklatıldı';

  @override
  String get logReset => 'Sıfırlandı';

  @override
  String logSkipped(String name) {
    return 'Atlandı: $name';
  }

  @override
  String logDone(String name) {
    return 'Tamamlandı: $name';
  }

  @override
  String get logAllDone => 'Tüm bölümler tamamlandı 🎉';

  @override
  String logLoop(String count) {
    return '🔁 Döngü $count tamamlandı';
  }

  @override
  String get batteryLow => 'Pil az — lütfen şarj edin';

  @override
  String get batteryMon => 'Pil';

  @override
  String get batteryMonOn => 'Pil ON';

  @override
  String get settings => 'Ayarlar';

  @override
  String get navTimer => 'Zamanlayıcı';

  @override
  String get navMulti => 'Çoklu';

  @override
  String get settingsBattery => 'Pil izleme';

  @override
  String get settingsBatteryDesc => 'Pil %20 veya altına düştüğünde uyar';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get modeLabelLog => 'Günlük';

  @override
  String get modeLabelToday => 'Bugün';

  @override
  String get modeLabelPlan => 'Plan';

  @override
  String get dayLogTitle => 'Günlük Kaydı';

  @override
  String get dayLogEmpty => 'Bu gün için kayıt yok';

  @override
  String get dayPlanTitle => 'Günlük Plan';

  @override
  String get dayPlanEmpty => 'Bu gün için plan yok';

  @override
  String get planSaveAsCurrent => 'Plan olarak kaydet';

  @override
  String get planLoadIntoTimer => 'Zamanlayıcıya yükle';

  @override
  String get planSave => 'Kaydet';

  @override
  String get telemetryConsentTitle => 'Help improve Analog Timer';

  @override
  String get settingsTelemetryDesc =>
      'Anonim tanılama ve ANR bilgisi gönder (kişisel veri yok)';

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
      'Saate uzun basın, ardından taşımak istediğiniz noktaya dokunun';

  @override
  String get editCoachGrid => 'Oraya taşımak için bir hücreye dokunun';

  @override
  String get editCoachDpad => 'İnce ayar için oklar · tekrar için basılı tutun';

  @override
  String get editCoachControls => '⤢ Boyut · ⇄ Taraf değiştir · ✓ Bitti';

  @override
  String get editCoachDismiss => 'Başlamak için herhangi bir yere dokunun';

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
  String get settingsTextSize => 'Yazı boyutu';

  @override
  String get textSizeSmall => 'Küçük';

  @override
  String get textSizeNormal => 'Normal';

  @override
  String get textSizeLarge => 'Büyük';

  @override
  String get textSizeXLarge => 'Çok büyük';

  @override
  String get textSizePreview => 'Önizleme 25:00';

  @override
  String get a11yClose => 'Kapat';

  @override
  String get a11yEditSegment => 'Bölümü düzenle';

  @override
  String get a11yDismissBanner => 'Kapat';

  @override
  String get settingsHaptics => 'Dokunsal geri bildirim';

  @override
  String get settingsHapticsDesc =>
      'Başlatma, duraklatma ve tamamlamada titret';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsDesc =>
      'Toast when a segment changes or the timer completes';

  @override
  String get settingsColorblind => 'Renk körlüğü modu';

  @override
  String get settingsColorblindDesc =>
      'Kronometreyi yalnızca renkle değil kesik çizgiyle ayırt et';

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
  String get settingsHighContrast => 'Yüksek kontrast';

  @override
  String get settingsHighContrastDesc =>
      'İkincil metni okumayı kolaylaştırmak için aydınlat';

  @override
  String get multiTimerTitle => 'Birden fazla zamanlayıcı';

  @override
  String get multiTimerAdd => 'Zamanlayıcı ekle';

  @override
  String get multiTimerNameHint => 'Zamanlayıcı adı';

  @override
  String get multiTimerEmpty =>
      'Henüz zamanlayıcı yok. Eklemek için +\'ya dokunun.';

  @override
  String get multiTimerDone => 'Bitti';

  @override
  String get multiTimerOverlayOn => 'Yer paylaşımlarını göster';

  @override
  String get multiTimerOverlayOff => 'Yer paylaşımlarını gizle';

  @override
  String get multiTimerOverlayPermission =>
      'Yer paylaşımı için \"Diğer uygulamaların üzerinde göster\" iznini verin';

  @override
  String multiTimerOverlayLimit(int count) {
    return 'En fazla $count yer paylaşımı gösterebilirsin';
  }

  @override
  String multiTimerAllDone(int count) {
    return '$count zamanlayıcı bitti';
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
}
