// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Timer analogico';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get manage => 'Gestisci';

  @override
  String get timerSection => 'TIMER';

  @override
  String get btnStart => 'AVVIA';

  @override
  String get btnPause => 'PAUSA';

  @override
  String get btnResume => 'RIPRENDI';

  @override
  String get btnRunning => 'IN CORSO…';

  @override
  String get btnNext => 'AVANTI';

  @override
  String get btnReset => 'AZZ';

  @override
  String get stopwatchSection => 'CRONOMETRO';

  @override
  String get btnLap => 'GIRO';

  @override
  String lapToast(int num, String time) {
    return 'Giro $num    $time';
  }

  @override
  String get timerSegments => 'SEGMENTI DEL TIMER';

  @override
  String get addSegment => '+ Aggiungi segmento';

  @override
  String get loopToggle => 'Ciclo';

  @override
  String get minutesUnit => 'min';

  @override
  String get segmentColor => 'Colore del segmento';

  @override
  String get segments => 'Segmenti';

  @override
  String get savePresetChip => 'Salva attuale';

  @override
  String presetApplied(String name) {
    return 'Preset aggiunto · $name';
  }

  @override
  String get noSegmentsToSave => 'Nessun segmento da salvare';

  @override
  String get savePresetTitle => 'Salva preset';

  @override
  String get presetNameHint => 'es. Studio 50/10';

  @override
  String get presetName => 'Nome del preset';

  @override
  String get presetManageTitle => 'Gestisci preset';

  @override
  String get newPreset => 'Nuovo preset';

  @override
  String get editPreset => 'Modifica preset';

  @override
  String get deletePresetTitle => 'Elimina preset';

  @override
  String deletePresetConfirm(String name) {
    return 'Eliminare «$name»?';
  }

  @override
  String get noPresets =>
      'Nessun preset salvato.\nAggiungine uno con «Nuovo preset» in alto a destra.';

  @override
  String get enterName => 'Inserisci un nome';

  @override
  String get atLeastOneSegment => 'Aggiungi almeno un segmento';

  @override
  String get legendTimer => 'Timer — spirale interna';

  @override
  String get legendStopwatch => 'Cronometro — anello esterno';

  @override
  String get statusDone => 'Fatto';

  @override
  String get statusWaiting => 'Pronto';

  @override
  String get widget => 'Widget';

  @override
  String get widgetOn => 'Widget attivo';

  @override
  String get notifyTimerDoneTitle => 'Timer completato';

  @override
  String get notifyTimerDoneBody => 'Tutti i segmenti completati 🎉';

  @override
  String get notifySegmentDoneTitle => 'Segmento completato';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev completato · Successivo: $next';
  }

  @override
  String get language => 'Lingua';

  @override
  String get languageSystem => 'Predefinito di sistema';

  @override
  String get presetPomodoro => 'Pomodoro 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => 'Lavoro profondo 90/20';

  @override
  String get segFocus => 'Concentrazione';

  @override
  String get segBreak => 'Pausa';

  @override
  String get stopwatchLaps => 'Giri del cronometro';

  @override
  String get noLaps => 'Ancora nessun giro';

  @override
  String get timerLogTitle => 'Registro del timer';

  @override
  String get noEvents => 'Nessun evento';

  @override
  String lapLabel(int num) {
    return 'Giro $num';
  }

  @override
  String logStart(String name) {
    return 'Inizio: $name';
  }

  @override
  String get logPaused => 'In pausa';

  @override
  String get logReset => 'Azzerato';

  @override
  String logSkipped(String name) {
    return 'Saltato: $name';
  }

  @override
  String logDone(String name) {
    return 'Completato: $name';
  }

  @override
  String get logAllDone => 'Tutti i segmenti completati 🎉';

  @override
  String logLoop(String count) {
    return '🔁 Ciclo $count completato';
  }

  @override
  String get batteryLow => 'Batteria scarica — ricarica';

  @override
  String get batteryMon => 'Batteria';

  @override
  String get batteryMonOn => 'Batteria ON';

  @override
  String get settings => 'Impostazioni';

  @override
  String get settingsBattery => 'Monitoraggio batteria';

  @override
  String get settingsBatteryDesc =>
      'Avvisa quando la batteria scende al 20% o meno';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get modeLabelLog => 'Registro';

  @override
  String get modeLabelToday => 'Oggi';

  @override
  String get modeLabelPlan => 'Piano';

  @override
  String get dayLogTitle => 'Registro giornaliero';

  @override
  String get dayLogEmpty => 'Nessuna attività registrata per questo giorno';

  @override
  String get dayPlanTitle => 'Piano del giorno';

  @override
  String get dayPlanEmpty => 'Nessun piano per questo giorno';

  @override
  String get planSaveAsCurrent => 'Salva come piano';

  @override
  String get planLoadIntoTimer => 'Carica nel timer';

  @override
  String get planSave => 'Salva';

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
      'Tieni premuto l\'orologio, poi tocca un punto per spostarlo lì';

  @override
  String get editCoachGrid => 'Tocca una cella per spostarti lì';

  @override
  String get editCoachDpad =>
      'Frecce per la regolazione fine · tieni premuto per ripetere';

  @override
  String get editCoachControls => '⤢ Dimensione · ⇄ Cambia lato · ✓ Fatto';

  @override
  String get editCoachDismiss => 'Tocca ovunque per iniziare';

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
  String get settingsTextSize => 'Dimensione testo';

  @override
  String get textSizeSmall => 'Piccolo';

  @override
  String get textSizeNormal => 'Normale';

  @override
  String get textSizeLarge => 'Grande';

  @override
  String get textSizeXLarge => 'Molto grande';

  @override
  String get textSizePreview => 'Anteprima 25:00';

  @override
  String get a11yClose => 'Chiudi';

  @override
  String get a11yEditSegment => 'Modifica segmento';

  @override
  String get a11yDismissBanner => 'Ignora';

  @override
  String get settingsHaptics => 'Feedback aptico';

  @override
  String get settingsHapticsDesc =>
      'Vibra all\'avvio, in pausa e al completamento';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsDesc =>
      'Toast when a segment changes or the timer completes';

  @override
  String get settingsColorblind => 'Modalità daltonici';

  @override
  String get settingsColorblindDesc =>
      'Distingui il cronometro con tratteggio, non solo col colore';

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
  String get settingsHighContrast => 'Contrasto elevato';

  @override
  String get settingsHighContrastDesc =>
      'Schiarisci il testo secondario per leggerlo meglio';
}
