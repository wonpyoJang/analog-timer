// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Аналоговый таймер';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get manage => 'Управление';

  @override
  String get timerSection => 'ТАЙМЕР';

  @override
  String get btnStart => 'СТАРТ';

  @override
  String get btnPause => 'ПАУЗА';

  @override
  String get btnResume => 'ПРОДОЛЖИТЬ';

  @override
  String get btnRunning => 'ИДЁТ…';

  @override
  String get btnNext => 'ДАЛЕЕ';

  @override
  String get btnReset => 'СБРОС';

  @override
  String get stopwatchSection => 'СЕКУНДОМЕР';

  @override
  String get btnLap => 'КРУГ';

  @override
  String lapToast(int num, String time) {
    return 'Круг $num    $time';
  }

  @override
  String get timerSegments => 'СЕГМЕНТЫ ТАЙМЕРА';

  @override
  String get addSegment => '+ Добавить сегмент';

  @override
  String get loopToggle => 'Повтор';

  @override
  String get minutesUnit => 'мин';

  @override
  String get segmentColor => 'Цвет сегмента';

  @override
  String get segments => 'Сегменты';

  @override
  String get savePresetChip => 'Сохранить текущее';

  @override
  String presetApplied(String name) {
    return 'Пресет добавлен · $name';
  }

  @override
  String get noSegmentsToSave => 'Нет сегментов для сохранения';

  @override
  String get savePresetTitle => 'Сохранить пресет';

  @override
  String get presetNameHint => 'напр. Учёба 50/10';

  @override
  String get presetName => 'Название пресета';

  @override
  String get presetManageTitle => 'Управление пресетами';

  @override
  String get newPreset => 'Новый пресет';

  @override
  String get editPreset => 'Изменить пресет';

  @override
  String get deletePresetTitle => 'Удалить пресет';

  @override
  String deletePresetConfirm(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get noPresets =>
      'Нет сохранённых пресетов.\nДобавьте его с помощью «Новый пресет» в правом верхнем углу.';

  @override
  String get enterName => 'Введите название';

  @override
  String get atLeastOneSegment => 'Добавьте хотя бы один сегмент';

  @override
  String get legendTimer => 'Таймер — внутренняя спираль';

  @override
  String get legendStopwatch => 'Секундомер — внешнее кольцо';

  @override
  String get statusDone => 'Готово';

  @override
  String get statusWaiting => 'Готов';

  @override
  String get widget => 'Виджет';

  @override
  String get widgetOn => 'Виджет включён';

  @override
  String get notifyTimerDoneTitle => 'Таймер завершён';

  @override
  String get notifyTimerDoneBody => 'Все сегменты завершены 🎉';

  @override
  String get notifySegmentDoneTitle => 'Сегмент завершён';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev завершён · Далее: $next';
  }

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Системный по умолчанию';

  @override
  String get presetPomodoro => 'Помодоро 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => 'Глубокая работа 90/20';

  @override
  String get segFocus => 'Фокус';

  @override
  String get segBreak => 'Перерыв';

  @override
  String get stopwatchLaps => 'Круги секундомера';

  @override
  String get noLaps => 'Кругов пока нет';

  @override
  String get timerLogTitle => 'Журнал таймера';

  @override
  String get noEvents => 'Нет событий';

  @override
  String lapLabel(int num) {
    return 'Круг $num';
  }

  @override
  String logStart(String name) {
    return 'Старт: $name';
  }

  @override
  String get logPaused => 'Пауза';

  @override
  String get logReset => 'Сброс';

  @override
  String logSkipped(String name) {
    return 'Пропущено: $name';
  }

  @override
  String logDone(String name) {
    return 'Завершено: $name';
  }

  @override
  String get logAllDone => 'Все сегменты завершены 🎉';

  @override
  String logLoop(String count) {
    return '🔁 Цикл $count завершён';
  }
}
