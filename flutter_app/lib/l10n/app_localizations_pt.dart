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
}
