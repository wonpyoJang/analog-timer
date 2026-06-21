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
}
