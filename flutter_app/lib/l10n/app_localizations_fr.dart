// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Minuteur analogique';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get manage => 'Gérer';

  @override
  String get timerSection => 'MINUTEUR';

  @override
  String get btnStart => 'DÉMARRER';

  @override
  String get btnPause => 'PAUSE';

  @override
  String get btnResume => 'REPRENDRE';

  @override
  String get btnRunning => 'EN COURS…';

  @override
  String get btnNext => 'SUIVANT';

  @override
  String get btnReset => 'RÀZ';

  @override
  String get stopwatchSection => 'CHRONOMÈTRE';

  @override
  String get btnLap => 'TOUR';

  @override
  String lapToast(int num, String time) {
    return 'Tour $num    $time';
  }

  @override
  String get timerSegments => 'SEGMENTS DU MINUTEUR';

  @override
  String get addSegment => '+ Ajouter un segment';

  @override
  String get loopToggle => 'Boucle';

  @override
  String get minutesUnit => 'min';

  @override
  String get segmentColor => 'Couleur du segment';

  @override
  String get segments => 'Segments';

  @override
  String get savePresetChip => 'Enregistrer l\'actuel';

  @override
  String presetApplied(String name) {
    return 'Préréglage ajouté · $name';
  }

  @override
  String get noSegmentsToSave => 'Aucun segment à enregistrer';

  @override
  String get savePresetTitle => 'Enregistrer le préréglage';

  @override
  String get presetNameHint => 'ex. Étude 50/10';

  @override
  String get presetName => 'Nom du préréglage';

  @override
  String get presetManageTitle => 'Gérer les préréglages';

  @override
  String get newPreset => 'Nouveau préréglage';

  @override
  String get editPreset => 'Modifier le préréglage';

  @override
  String get deletePresetTitle => 'Supprimer le préréglage';

  @override
  String deletePresetConfirm(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get noPresets =>
      'Aucun préréglage enregistré.\nAjoutez-en un avec « Nouveau préréglage » en haut à droite.';

  @override
  String get enterName => 'Veuillez saisir un nom';

  @override
  String get atLeastOneSegment => 'Ajoutez au moins un segment';

  @override
  String get legendTimer => 'Minuteur — spirale intérieure';

  @override
  String get legendStopwatch => 'Chronomètre — anneau extérieur';

  @override
  String get statusDone => 'Terminé';

  @override
  String get statusWaiting => 'Prêt';

  @override
  String get widget => 'Widget';

  @override
  String get widgetOn => 'Widget activé';

  @override
  String get notifyTimerDoneTitle => 'Minuteur terminé';

  @override
  String get notifyTimerDoneBody => 'Tous les segments terminés 🎉';

  @override
  String get notifySegmentDoneTitle => 'Segment terminé';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev terminé · Suivant : $next';
  }

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Réglage du système';

  @override
  String get presetPomodoro => 'Pomodoro 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => 'Travail intense 90/20';

  @override
  String get segFocus => 'Concentration';

  @override
  String get segBreak => 'Pause';

  @override
  String get stopwatchLaps => 'Tours du chronomètre';

  @override
  String get noLaps => 'Aucun tour pour l\'instant';

  @override
  String get timerLogTitle => 'Journal du minuteur';

  @override
  String get noEvents => 'Aucun événement';

  @override
  String lapLabel(int num) {
    return 'Tour $num';
  }

  @override
  String logStart(String name) {
    return 'Début : $name';
  }

  @override
  String get logPaused => 'En pause';

  @override
  String get logReset => 'Réinitialisé';

  @override
  String logSkipped(String name) {
    return 'Ignoré : $name';
  }

  @override
  String logDone(String name) {
    return 'Terminé : $name';
  }

  @override
  String get logAllDone => 'Tous les segments terminés 🎉';

  @override
  String logLoop(String count) {
    return '🔁 Boucle $count terminée';
  }

  @override
  String get batteryLow => 'Batterie faible — veuillez charger';

  @override
  String get batteryMon => 'Batterie';

  @override
  String get batteryMonOn => 'Batterie ON';

  @override
  String get settings => 'Paramètres';

  @override
  String get navTimer => 'Minuteur';

  @override
  String get navMulti => 'Multi';

  @override
  String get settingsBattery => 'Surveillance batterie';

  @override
  String get settingsBatteryDesc =>
      'Avertir quand la batterie descend à 20 % ou moins';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get modeLabelLog => 'Journal';

  @override
  String get modeLabelToday => 'Aujourd\'hui';

  @override
  String get modeLabelPlan => 'Plan';

  @override
  String get dayLogTitle => 'Journal du jour';

  @override
  String get dayLogEmpty => 'Aucune activité enregistrée pour ce jour';

  @override
  String get dayPlanTitle => 'Plan du jour';

  @override
  String get dayPlanEmpty => 'Aucun plan pour ce jour';

  @override
  String get planSaveAsCurrent => 'Enregistrer comme plan';

  @override
  String get planLoadIntoTimer => 'Charger dans la minuterie';

  @override
  String get planSave => 'Sauvegarder';

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
      'Appuyez longuement sur l\'horloge, puis touchez un point pour la déplacer';

  @override
  String get editCoachGrid => 'Touchez une case pour vous y déplacer';

  @override
  String get editCoachDpad =>
      'Flèches pour un réglage fin · maintenez pour répéter';

  @override
  String get editCoachControls => '⤢ Taille · ⇄ Changer de côté · ✓ Terminé';

  @override
  String get editCoachDismiss => 'Touchez n\'importe où pour commencer';

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
  String get settingsTextSize => 'Taille du texte';

  @override
  String get textSizeSmall => 'Petit';

  @override
  String get textSizeNormal => 'Normal';

  @override
  String get textSizeLarge => 'Grand';

  @override
  String get textSizeXLarge => 'Très grand';

  @override
  String get textSizePreview => 'Aperçu 25:00';

  @override
  String get a11yClose => 'Fermer';

  @override
  String get a11yEditSegment => 'Modifier le segment';

  @override
  String get a11yDismissBanner => 'Ignorer';

  @override
  String get settingsHaptics => 'Retour haptique';

  @override
  String get settingsHapticsDesc => 'Vibrer au démarrage, en pause et à la fin';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsDesc =>
      'Toast when a segment changes or the timer completes';

  @override
  String get settingsColorblind => 'Mode daltonien';

  @override
  String get settingsColorblindDesc =>
      'Distinguer le chronomètre par des pointillés, pas seulement la couleur';

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
  String get settingsHighContrast => 'Contraste élevé';

  @override
  String get settingsHighContrastDesc =>
      'Éclaircir le texte secondaire pour une meilleure lisibilité';

  @override
  String get multiTimerTitle => 'Minuteurs multiples';

  @override
  String get multiTimerAdd => 'Ajouter un minuteur';

  @override
  String get multiTimerNameHint => 'Nom du minuteur';

  @override
  String get multiTimerEmpty => 'Aucun minuteur. Touchez + pour en ajouter.';

  @override
  String get multiTimerDone => 'Terminé';

  @override
  String get multiTimerOverlayOn => 'Afficher les superpositions';

  @override
  String get multiTimerOverlayOff => 'Masquer les superpositions';

  @override
  String get multiTimerOverlayPermission =>
      'Autorisez « Affichage par-dessus les autres applis » pour les superpositions';

  @override
  String multiTimerOverlayLimit(int count) {
    return 'Vous pouvez afficher jusqu\'à $count superpositions';
  }

  @override
  String multiTimerAllDone(int count) {
    return '$count minuteurs terminés';
  }
}
