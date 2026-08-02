// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Analog-Timer';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get manage => 'Verwalten';

  @override
  String get timerSection => 'TIMER';

  @override
  String get btnStart => 'START';

  @override
  String get btnPause => 'PAUSE';

  @override
  String get btnResume => 'FORTSETZEN';

  @override
  String get btnRunning => 'LÄUFT…';

  @override
  String get btnNext => 'WEITER';

  @override
  String get btnReset => 'RST';

  @override
  String get stopwatchSection => 'STOPPUHR';

  @override
  String get btnLap => 'RUNDE';

  @override
  String lapToast(int num, String time) {
    return 'Runde $num    $time';
  }

  @override
  String get timerSegments => 'TIMER-ABSCHNITTE';

  @override
  String get addSegment => '+ Abschnitt hinzufügen';

  @override
  String get loopToggle => 'Schleife';

  @override
  String get minutesUnit => 'Min.';

  @override
  String get segmentColor => 'Abschnittsfarbe';

  @override
  String get segments => 'Abschnitte';

  @override
  String get savePresetChip => 'Aktuelles speichern';

  @override
  String presetApplied(String name) {
    return 'Voreinstellung hinzugefügt · $name';
  }

  @override
  String get noSegmentsToSave => 'Keine Abschnitte zum Speichern';

  @override
  String get savePresetTitle => 'Voreinstellung speichern';

  @override
  String get presetNameHint => 'z. B. Lernen 50/10';

  @override
  String get presetName => 'Name der Voreinstellung';

  @override
  String get presetManageTitle => 'Voreinstellungen verwalten';

  @override
  String get newPreset => 'Neue Voreinstellung';

  @override
  String get editPreset => 'Voreinstellung bearbeiten';

  @override
  String get deletePresetTitle => 'Voreinstellung löschen';

  @override
  String deletePresetConfirm(String name) {
    return '„$name“ löschen?';
  }

  @override
  String get noPresets =>
      'Keine gespeicherten Voreinstellungen.\nFüge oben rechts mit „Neue Voreinstellung“ eine hinzu.';

  @override
  String get enterName => 'Bitte einen Namen eingeben';

  @override
  String get atLeastOneSegment => 'Füge mindestens einen Abschnitt hinzu';

  @override
  String get legendTimer => 'Timer — innere Spirale';

  @override
  String get legendStopwatch => 'Stoppuhr — äußerer Ring';

  @override
  String get statusDone => 'Fertig';

  @override
  String get statusWaiting => 'Bereit';

  @override
  String get widget => 'Widget';

  @override
  String get widgetOn => 'Widget AN';

  @override
  String get notifyTimerDoneTitle => 'Timer abgeschlossen';

  @override
  String get notifyTimerDoneBody => 'Alle Abschnitte beendet 🎉';

  @override
  String get notifySegmentDoneTitle => 'Abschnitt abgeschlossen';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev fertig · Nächster: $next';
  }

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'Systemstandard';

  @override
  String get presetPomodoro => 'Pomodoro 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => 'Deep Work 90/20';

  @override
  String get segFocus => 'Fokus';

  @override
  String get segBreak => 'Pause';

  @override
  String get stopwatchLaps => 'Stoppuhr-Runden';

  @override
  String get noLaps => 'Noch keine Runden';

  @override
  String get timerLogTitle => 'Timer-Protokoll';

  @override
  String get noEvents => 'Keine Ereignisse';

  @override
  String lapLabel(int num) {
    return 'Runde $num';
  }

  @override
  String logStart(String name) {
    return 'Start: $name';
  }

  @override
  String get logPaused => 'Pausiert';

  @override
  String get logReset => 'Zurückgesetzt';

  @override
  String logSkipped(String name) {
    return 'Übersprungen: $name';
  }

  @override
  String logDone(String name) {
    return 'Fertig: $name';
  }

  @override
  String get logAllDone => 'Alle Abschnitte fertig 🎉';

  @override
  String logLoop(String count) {
    return '🔁 Schleife $count fertig';
  }

  @override
  String get batteryLow => 'Akku schwach — bitte laden';

  @override
  String get batteryMon => 'Akku';

  @override
  String get batteryMonOn => 'Akku AN';

  @override
  String get settings => 'Einstellungen';

  @override
  String get settingsBattery => 'Akku-Überwachung';

  @override
  String get settingsBatteryDesc =>
      'Warnen wenn Akku auf 20 % oder darunter fällt';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get modeLabelLog => 'Log';

  @override
  String get modeLabelToday => 'Heute';

  @override
  String get modeLabelPlan => 'Plan';

  @override
  String get dayLogTitle => 'Tagesprotokoll';

  @override
  String get dayLogEmpty => 'Keine Aktivitäten für diesen Tag';

  @override
  String get dayPlanTitle => 'Tagesplan';

  @override
  String get dayPlanEmpty => 'Kein Plan für diesen Tag';

  @override
  String get planSaveAsCurrent => 'Als Plan speichern';

  @override
  String get planLoadIntoTimer => 'In Timer laden';

  @override
  String get planSave => 'Speichern';

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
      'Uhr gedrückt halten und dann auf einen Punkt tippen, um sie dorthin zu verschieben';
}
