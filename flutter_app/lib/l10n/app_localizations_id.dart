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
  String get menuRefreshWidget => 'Refresh widget';

  @override
  String get menuRestartApp => 'Restart app';

  @override
  String get menuErrorReports => 'Error reports';

  @override
  String get overlayLongPressHint =>
      'Tekan lama jam untuk menyesuaikan ukuran dan posisi';
}
