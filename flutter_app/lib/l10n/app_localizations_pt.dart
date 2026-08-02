// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Temporizador analógico';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get manage => 'Gerenciar';

  @override
  String get timerSection => 'TEMPORIZADOR';

  @override
  String get btnStart => 'INICIAR';

  @override
  String get btnPause => 'PAUSAR';

  @override
  String get btnResume => 'RETOMAR';

  @override
  String get btnRunning => 'EM ANDAMENTO…';

  @override
  String get btnNext => 'PRÓXIMO';

  @override
  String get btnReset => 'ZERAR';

  @override
  String get stopwatchSection => 'CRONÔMETRO';

  @override
  String get btnLap => 'VOLTA';

  @override
  String lapToast(int num, String time) {
    return 'Volta $num    $time';
  }

  @override
  String get timerSegments => 'SEGMENTOS DO TEMPORIZADOR';

  @override
  String get addSegment => '+ Adicionar segmento';

  @override
  String get loopToggle => 'Repetir';

  @override
  String get minutesUnit => 'min';

  @override
  String get segmentColor => 'Cor do segmento';

  @override
  String get segments => 'Segmentos';

  @override
  String get savePresetChip => 'Salvar atual';

  @override
  String presetApplied(String name) {
    return 'Predefinição adicionada · $name';
  }

  @override
  String get noSegmentsToSave => 'Nenhum segmento para salvar';

  @override
  String get savePresetTitle => 'Salvar predefinição';

  @override
  String get presetNameHint => 'ex.: Estudo 50/10';

  @override
  String get presetName => 'Nome da predefinição';

  @override
  String get presetManageTitle => 'Gerenciar predefinições';

  @override
  String get newPreset => 'Nova predefinição';

  @override
  String get editPreset => 'Editar predefinição';

  @override
  String get deletePresetTitle => 'Excluir predefinição';

  @override
  String deletePresetConfirm(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get noPresets =>
      'Nenhuma predefinição salva.\nAdicione uma com \"Nova predefinição\" no canto superior direito.';

  @override
  String get enterName => 'Digite um nome';

  @override
  String get atLeastOneSegment => 'Adicione pelo menos um segmento';

  @override
  String get legendTimer => 'Temporizador — espiral interna';

  @override
  String get legendStopwatch => 'Cronômetro — anel externo';

  @override
  String get statusDone => 'Concluído';

  @override
  String get statusWaiting => 'Pronto';

  @override
  String get widget => 'Widget';

  @override
  String get widgetOn => 'Widget ativado';

  @override
  String get notifyTimerDoneTitle => 'Temporizador concluído';

  @override
  String get notifyTimerDoneBody => 'Todos os segmentos finalizados 🎉';

  @override
  String get notifySegmentDoneTitle => 'Segmento concluído';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev concluído · Próximo: $next';
  }

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Padrão do sistema';

  @override
  String get presetPomodoro => 'Pomodoro 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => 'Trabalho focado 90/20';

  @override
  String get segFocus => 'Foco';

  @override
  String get segBreak => 'Pausa';

  @override
  String get stopwatchLaps => 'Voltas do cronômetro';

  @override
  String get noLaps => 'Nenhuma volta ainda';

  @override
  String get timerLogTitle => 'Registro do temporizador';

  @override
  String get noEvents => 'Nenhum evento';

  @override
  String lapLabel(int num) {
    return 'Volta $num';
  }

  @override
  String logStart(String name) {
    return 'Início: $name';
  }

  @override
  String get logPaused => 'Pausado';

  @override
  String get logReset => 'Reiniciado';

  @override
  String logSkipped(String name) {
    return 'Pulado: $name';
  }

  @override
  String logDone(String name) {
    return 'Concluído: $name';
  }

  @override
  String get logAllDone => 'Todos os segmentos concluídos 🎉';

  @override
  String logLoop(String count) {
    return '🔁 Ciclo $count concluído';
  }

  @override
  String get batteryLow => 'Bateria fraca — por favor carregue';

  @override
  String get batteryMon => 'Bateria';

  @override
  String get batteryMonOn => 'Bateria ON';

  @override
  String get settings => 'Configurações';

  @override
  String get settingsBattery => 'Monitoramento de bateria';

  @override
  String get settingsBatteryDesc =>
      'Avisar quando a bateria cair para 20% ou menos';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get modeLabelLog => 'Registo';

  @override
  String get modeLabelToday => 'Hoje';

  @override
  String get modeLabelPlan => 'Plano';

  @override
  String get dayLogTitle => 'Registo diário';

  @override
  String get dayLogEmpty => 'Nenhuma atividade registada para este dia';

  @override
  String get dayPlanTitle => 'Plano do dia';

  @override
  String get dayPlanEmpty => 'Nenhum plano para este dia';

  @override
  String get planSaveAsCurrent => 'Guardar como plano';

  @override
  String get planLoadIntoTimer => 'Carregar no temporizador';

  @override
  String get planSave => 'Salvar';

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
      'Toque e segure o relógio e depois toque em um ponto para movê-lo';
}
