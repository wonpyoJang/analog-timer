// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Timer Analog';

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String get manage => 'Kelola';

  @override
  String get timerSection => 'TIMER';

  @override
  String get btnStart => 'MULAI';

  @override
  String get btnPause => 'JEDA';

  @override
  String get btnResume => 'LANJUT';

  @override
  String get btnRunning => 'BERJALAN…';

  @override
  String get btnNext => 'BERIKUTNYA';

  @override
  String get btnReset => 'RESET';

  @override
  String get stopwatchSection => 'STOPWATCH';

  @override
  String get btnLap => 'LAP';

  @override
  String lapToast(int num, String time) {
    return 'Lap $num    $time';
  }

  @override
  String get timerSegments => 'SEGMEN TIMER';

  @override
  String get addSegment => '+ Tambah segmen';

  @override
  String get loopToggle => 'Ulang';

  @override
  String get minutesUnit => 'mnt';

  @override
  String get segmentColor => 'Warna segmen';

  @override
  String get segments => 'Segmen';

  @override
  String get savePresetChip => 'Simpan saat ini';

  @override
  String presetApplied(String name) {
    return 'Preset ditambahkan · $name';
  }

  @override
  String get noSegmentsToSave => 'Tidak ada segmen untuk disimpan';

  @override
  String get savePresetTitle => 'Simpan preset';

  @override
  String get presetNameHint => 'mis. Belajar 50/10';

  @override
  String get presetName => 'Nama preset';

  @override
  String get presetManageTitle => 'Kelola preset';

  @override
  String get newPreset => 'Preset baru';

  @override
  String get editPreset => 'Edit preset';

  @override
  String get deletePresetTitle => 'Hapus preset';

  @override
  String deletePresetConfirm(String name) {
    return 'Hapus \"$name\"?';
  }

  @override
  String get noPresets =>
      'Belum ada preset tersimpan.\nTambahkan satu dengan \"Preset baru\" di kanan atas.';

  @override
  String get enterName => 'Masukkan nama';

  @override
  String get atLeastOneSegment => 'Tambahkan setidaknya satu segmen';

  @override
  String get legendTimer => 'Timer — spiral dalam';

  @override
  String get legendStopwatch => 'Stopwatch — cincin luar';

  @override
  String get statusDone => 'Selesai';

  @override
  String get statusWaiting => 'Siap';

  @override
  String get widget => 'Widget';

  @override
  String get widgetOn => 'Widget AKTIF';

  @override
  String get notifyTimerDoneTitle => 'Timer selesai';

  @override
  String get notifyTimerDoneBody => 'Semua segmen selesai 🎉';

  @override
  String get notifySegmentDoneTitle => 'Segmen selesai';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev selesai · Berikutnya: $next';
  }

  @override
  String get language => 'Bahasa';

  @override
  String get languageSystem => 'Default sistem';

  @override
  String get presetPomodoro => 'Pomodoro 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => 'Kerja fokus 90/20';

  @override
  String get segFocus => 'Fokus';

  @override
  String get segBreak => 'Istirahat';

  @override
  String get stopwatchLaps => 'Lap stopwatch';

  @override
  String get noLaps => 'Belum ada lap';

  @override
  String get timerLogTitle => 'Log timer';

  @override
  String get noEvents => 'Tidak ada peristiwa';

  @override
  String lapLabel(int num) {
    return 'Lap $num';
  }

  @override
  String logStart(String name) {
    return 'Mulai: $name';
  }

  @override
  String get logPaused => 'Dijeda';

  @override
  String get logReset => 'Direset';

  @override
  String logSkipped(String name) {
    return 'Dilewati: $name';
  }

  @override
  String logDone(String name) {
    return 'Selesai: $name';
  }

  @override
  String get logAllDone => 'Semua segmen selesai 🎉';

  @override
  String logLoop(String count) {
    return '🔁 Putaran $count selesai';
  }

  @override
  String get batteryLow => 'Baterai lemah — silakan isi daya';

  @override
  String get batteryMon => 'Baterai';

  @override
  String get batteryMonOn => 'Baterai ON';

  @override
  String get settings => 'Pengaturan';

  @override
  String get settingsBattery => 'Pemantauan baterai';

  @override
  String get settingsBatteryDesc =>
      'Peringatkan jika baterai turun ke 20% atau lebih rendah';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get modeLabelLog => 'Log';

  @override
  String get modeLabelToday => 'Hari Ini';

  @override
  String get modeLabelPlan => 'Rencana';

  @override
  String get dayLogTitle => 'Log Aktivitas';

  @override
  String get dayLogEmpty => 'Tidak ada aktivitas yang dicatat untuk hari ini';

  @override
  String get dayPlanTitle => 'Rencana Hari';

  @override
  String get dayPlanEmpty => 'Tidak ada rencana untuk hari ini';

  @override
  String get planSaveAsCurrent => 'Simpan sebagai rencana';

  @override
  String get planLoadIntoTimer => 'Muat ke timer';

  @override
  String get planSave => 'Simpan';

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
      'Tekan lama jam, lalu ketuk titik untuk memindahkannya ke sana';

  @override
  String get editCoachGrid => 'Ketuk sel untuk pindah ke sana';

  @override
  String get editCoachDpad =>
      'Panah untuk penyetelan halus · tahan untuk mengulang';

  @override
  String get editCoachControls => '⤢ Ukuran · ⇄ Ganti sisi · ✓ Selesai';

  @override
  String get editCoachDismiss => 'Ketuk di mana saja untuk mulai';

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
  String get settingsTextSize => 'Ukuran teks';

  @override
  String get textSizeSmall => 'Kecil';

  @override
  String get textSizeNormal => 'Normal';

  @override
  String get textSizeLarge => 'Besar';

  @override
  String get textSizeXLarge => 'Sangat besar';

  @override
  String get textSizePreview => 'Pratinjau 25:00';

  @override
  String get a11yClose => 'Tutup';

  @override
  String get a11yEditSegment => 'Edit segmen';

  @override
  String get a11yDismissBanner => 'Tutup';

  @override
  String get settingsHaptics => 'Umpan balik haptik';

  @override
  String get settingsHapticsDesc => 'Getar saat mulai, jeda, dan selesai';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsDesc =>
      'Toast when a segment changes or the timer completes';

  @override
  String get settingsColorblind => 'Mode buta warna';

  @override
  String get settingsColorblindDesc =>
      'Bedakan stopwatch dengan pola putus-putus, bukan hanya warna';

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
  String get settingsHighContrast => 'Kontras tinggi';

  @override
  String get settingsHighContrastDesc =>
      'Cerahkan teks sekunder agar mudah dibaca';

  @override
  String get multiTimerTitle => 'Beberapa timer';

  @override
  String get multiTimerAdd => 'Tambah timer';

  @override
  String get multiTimerNameHint => 'Nama timer';

  @override
  String get multiTimerEmpty => 'Belum ada timer. Ketuk + untuk menambah.';

  @override
  String get multiTimerDone => 'Selesai';

  @override
  String multiTimerAllDone(int count) {
    return '$count timer selesai';
  }
}
