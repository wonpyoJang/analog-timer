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
}
