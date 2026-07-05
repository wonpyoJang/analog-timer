// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ANALOG TIMER';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get manage => 'Manage';

  @override
  String get timerSection => 'TIMER';

  @override
  String get btnStart => 'START';

  @override
  String get btnPause => 'PAUSE';

  @override
  String get btnResume => 'RESUME';

  @override
  String get btnRunning => 'RUNNING…';

  @override
  String get btnNext => 'NEXT';

  @override
  String get btnReset => 'RST';

  @override
  String get stopwatchSection => 'STOPWATCH';

  @override
  String get btnLap => 'LAP';

  @override
  String lapToast(int num, String time) {
    return 'Lap $num    $time';
  }

  @override
  String get timerSegments => 'TIMER SEGMENTS';

  @override
  String get addSegment => '+ Add segment';

  @override
  String get loopToggle => 'Loop';

  @override
  String get minutesUnit => 'min';

  @override
  String get segmentColor => 'Segment color';

  @override
  String get segments => 'Segments';

  @override
  String get savePresetChip => 'Save current';

  @override
  String presetApplied(String name) {
    return 'Preset added · $name';
  }

  @override
  String get noSegmentsToSave => 'No segments to save';

  @override
  String get savePresetTitle => 'Save preset';

  @override
  String get presetNameHint => 'e.g. Study 50/10';

  @override
  String get presetName => 'Preset name';

  @override
  String get presetManageTitle => 'Manage presets';

  @override
  String get newPreset => 'New preset';

  @override
  String get editPreset => 'Edit preset';

  @override
  String get deletePresetTitle => 'Delete preset';

  @override
  String deletePresetConfirm(String name) {
    return 'Delete \'$name\'?';
  }

  @override
  String get noPresets =>
      'No saved presets.\nAdd one with \"New preset\" at the top right.';

  @override
  String get enterName => 'Please enter a name';

  @override
  String get atLeastOneSegment => 'Add at least one segment';

  @override
  String get legendTimer => 'Timer — inner spiral';

  @override
  String get legendStopwatch => 'Stopwatch — outer ring';

  @override
  String get statusDone => 'Done';

  @override
  String get statusWaiting => 'Ready';

  @override
  String get widget => 'Widget';

  @override
  String get widgetOn => 'Widget ON';

  @override
  String get notifyTimerDoneTitle => 'Timer complete';

  @override
  String get notifyTimerDoneBody => 'All segments finished 🎉';

  @override
  String get notifySegmentDoneTitle => 'Segment complete';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev done · Next: $next';
  }

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get presetPomodoro => 'Pomodoro 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => 'Deep work 90/20';

  @override
  String get segFocus => 'Focus';

  @override
  String get segBreak => 'Break';

  @override
  String get stopwatchLaps => 'Stopwatch laps';

  @override
  String get noLaps => 'No laps yet';

  @override
  String get timerLogTitle => 'Timer log';

  @override
  String get noEvents => 'No events';

  @override
  String lapLabel(int num) {
    return 'Lap $num';
  }

  @override
  String logStart(String name) {
    return 'Start: $name';
  }

  @override
  String get logPaused => 'Paused';

  @override
  String get logReset => 'Reset';

  @override
  String logSkipped(String name) {
    return 'Skipped: $name';
  }

  @override
  String logDone(String name) {
    return 'Done: $name';
  }

  @override
  String get logAllDone => 'All segments done 🎉';

  @override
  String logLoop(String count) {
    return '🔁 Loop $count done';
  }

  @override
  String get batteryLow => 'Battery low — please charge';

  @override
  String get batteryMon => 'Battery';

  @override
  String get batteryMonOn => 'Battery ON';

  @override
  String get settings => 'Settings';

  @override
  String get settingsBattery => 'Battery monitoring';

  @override
  String get settingsBatteryDesc => 'Warn when battery drops to 20% or below';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get modeLabelLog => 'Log';

  @override
  String get modeLabelToday => 'Today';

  @override
  String get modeLabelPlan => 'Plan';

  @override
  String get dayLogTitle => 'Activity Log';

  @override
  String get dayLogEmpty => 'No activity recorded for this day';

  @override
  String get dayPlanTitle => 'Day Plan';

  @override
  String get dayPlanEmpty => 'No plan set for this day';

  @override
  String get planSaveAsCurrent => 'Save as plan';

  @override
  String get planLoadIntoTimer => 'Load into timer';

  @override
  String get planSave => 'Save';

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
