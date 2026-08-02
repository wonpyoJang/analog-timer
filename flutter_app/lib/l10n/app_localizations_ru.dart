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

  @override
  String get batteryLow => 'Заряд батареи мал — зарядите';

  @override
  String get batteryMon => 'Батарея';

  @override
  String get batteryMonOn => 'Батарея ON';

  @override
  String get settings => 'Настройки';

  @override
  String get settingsBattery => 'Мониторинг батареи';

  @override
  String get settingsBatteryDesc =>
      'Предупреждать при уровне заряда 20 % и ниже';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get modeLabelLog => 'Журнал';

  @override
  String get modeLabelToday => 'Сегодня';

  @override
  String get modeLabelPlan => 'План';

  @override
  String get dayLogTitle => 'Журнал дня';

  @override
  String get dayLogEmpty => 'Нет записей за этот день';

  @override
  String get dayPlanTitle => 'План дня';

  @override
  String get dayPlanEmpty => 'Нет плана на этот день';

  @override
  String get planSaveAsCurrent => 'Сохранить как план';

  @override
  String get planLoadIntoTimer => 'Загрузить в таймер';

  @override
  String get planSave => 'Сохранить';

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
      'Удерживайте часы, затем коснитесь точки, чтобы переместить их туда';

  @override
  String get editCoachGrid => 'Коснитесь ячейки, чтобы переместить';

  @override
  String get editCoachDpad =>
      'Стрелки для точной настройки · удерживайте для повтора';

  @override
  String get editCoachControls => '⤢ Размер · ⇄ Сменить сторону · ✓ Готово';

  @override
  String get editCoachDismiss => 'Коснитесь в любом месте, чтобы начать';
}
