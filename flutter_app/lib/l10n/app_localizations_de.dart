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
}
