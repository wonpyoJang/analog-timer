// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Temporizador analógico';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get manage => 'Gestionar';

  @override
  String get timerSection => 'TEMPORIZADOR';

  @override
  String get btnStart => 'INICIAR';

  @override
  String get btnPause => 'PAUSAR';

  @override
  String get btnResume => 'REANUDAR';

  @override
  String get btnRunning => 'EN CURSO…';

  @override
  String get btnNext => 'SIGUIENTE';

  @override
  String get btnReset => 'REIN';

  @override
  String get stopwatchSection => 'CRONÓMETRO';

  @override
  String get btnLap => 'VUELTA';

  @override
  String lapToast(int num, String time) {
    return 'Vuelta $num    $time';
  }

  @override
  String get timerSegments => 'SEGMENTOS DEL TEMPORIZADOR';

  @override
  String get addSegment => '+ Añadir segmento';

  @override
  String get loopToggle => 'Bucle';

  @override
  String get minutesUnit => 'min';

  @override
  String get segmentColor => 'Color del segmento';

  @override
  String get segments => 'Segmentos';

  @override
  String get savePresetChip => 'Guardar actual';

  @override
  String presetApplied(String name) {
    return 'Preajuste añadido · $name';
  }

  @override
  String get noSegmentsToSave => 'No hay segmentos para guardar';

  @override
  String get savePresetTitle => 'Guardar preajuste';

  @override
  String get presetNameHint => 'p. ej. Estudio 50/10';

  @override
  String get presetName => 'Nombre del preajuste';

  @override
  String get presetManageTitle => 'Gestionar preajustes';

  @override
  String get newPreset => 'Nuevo preajuste';

  @override
  String get editPreset => 'Editar preajuste';

  @override
  String get deletePresetTitle => 'Eliminar preajuste';

  @override
  String deletePresetConfirm(String name) {
    return '¿Eliminar «$name»?';
  }

  @override
  String get noPresets =>
      'No hay preajustes guardados.\nAñade uno con «Nuevo preajuste» en la parte superior derecha.';

  @override
  String get enterName => 'Introduce un nombre';

  @override
  String get atLeastOneSegment => 'Añade al menos un segmento';

  @override
  String get legendTimer => 'Temporizador — espiral interior';

  @override
  String get legendStopwatch => 'Cronómetro — anillo exterior';

  @override
  String get statusDone => 'Listo';

  @override
  String get statusWaiting => 'Preparado';

  @override
  String get widget => 'Widget';

  @override
  String get widgetOn => 'Widget activado';

  @override
  String get notifyTimerDoneTitle => 'Temporizador completado';

  @override
  String get notifyTimerDoneBody => 'Todos los segmentos finalizados 🎉';

  @override
  String get notifySegmentDoneTitle => 'Segmento completado';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev terminado · Siguiente: $next';
  }

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get presetPomodoro => 'Pomodoro 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => 'Trabajo profundo 90/20';

  @override
  String get segFocus => 'Concentración';

  @override
  String get segBreak => 'Descanso';

  @override
  String get stopwatchLaps => 'Vueltas del cronómetro';

  @override
  String get noLaps => 'Aún no hay vueltas';

  @override
  String get timerLogTitle => 'Registro del temporizador';

  @override
  String get noEvents => 'Sin eventos';

  @override
  String lapLabel(int num) {
    return 'Vuelta $num';
  }

  @override
  String logStart(String name) {
    return 'Inicio: $name';
  }

  @override
  String get logPaused => 'En pausa';

  @override
  String get logReset => 'Reiniciado';

  @override
  String logSkipped(String name) {
    return 'Omitido: $name';
  }

  @override
  String logDone(String name) {
    return 'Completado: $name';
  }

  @override
  String get logAllDone => 'Todos los segmentos completados 🎉';

  @override
  String logLoop(String count) {
    return '🔁 Ciclo $count completado';
  }

  @override
  String get batteryLow => 'Batería baja — por favor cargue';

  @override
  String get batteryMon => 'Batería';

  @override
  String get batteryMonOn => 'Batería ON';

  @override
  String get settings => 'Ajustes';

  @override
  String get settingsBattery => 'Supervisión de batería';

  @override
  String get settingsBatteryDesc =>
      'Avisar cuando la batería baje al 20 % o menos';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get modeLabelLog => 'Registro';

  @override
  String get modeLabelToday => 'Hoy';

  @override
  String get modeLabelPlan => 'Plan';

  @override
  String get dayLogTitle => 'Registro del día';

  @override
  String get dayLogEmpty => 'Sin actividad registrada para este día';

  @override
  String get dayPlanTitle => 'Plan del día';

  @override
  String get dayPlanEmpty => 'Sin plan para este día';

  @override
  String get planSaveAsCurrent => 'Guardar como plan';

  @override
  String get planLoadIntoTimer => 'Cargar en el temporizador';

  @override
  String get planSave => 'Guardar';
}
