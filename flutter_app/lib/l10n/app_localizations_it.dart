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
}
