// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '模拟计时器';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get manage => '管理';

  @override
  String get timerSection => '计时器';

  @override
  String get btnStart => '开始';

  @override
  String get btnPause => '暂停';

  @override
  String get btnResume => '继续';

  @override
  String get btnRunning => '进行中…';

  @override
  String get btnNext => '下一个';

  @override
  String get btnReset => '重置';

  @override
  String get stopwatchSection => '秒表';

  @override
  String get btnLap => '计圈';

  @override
  String lapToast(int num, String time) {
    return '第 $num 圈    $time';
  }

  @override
  String get timerSegments => '计时区段';

  @override
  String get addSegment => '+ 添加区段';

  @override
  String get loopToggle => '循环';

  @override
  String get minutesUnit => '分钟';

  @override
  String get segmentColor => '区段颜色';

  @override
  String get segments => '区段';

  @override
  String get savePresetChip => '保存当前';

  @override
  String presetApplied(String name) {
    return '已添加预设 · $name';
  }

  @override
  String get noSegmentsToSave => '没有可保存的区段';

  @override
  String get savePresetTitle => '保存预设';

  @override
  String get presetNameHint => '例如 学习 50/10';

  @override
  String get presetName => '预设名称';

  @override
  String get presetManageTitle => '管理预设';

  @override
  String get newPreset => '新建预设';

  @override
  String get editPreset => '编辑预设';

  @override
  String get deletePresetTitle => '删除预设';

  @override
  String deletePresetConfirm(String name) {
    return '删除“$name”？';
  }

  @override
  String get noPresets => '没有已保存的预设。\n点击右上角的“新建预设”添加一个。';

  @override
  String get enterName => '请输入名称';

  @override
  String get atLeastOneSegment => '请至少添加一个区段';

  @override
  String get legendTimer => '计时器 — 内圈螺旋';

  @override
  String get legendStopwatch => '秒表 — 外圈';

  @override
  String get statusDone => '完成';

  @override
  String get statusWaiting => '就绪';

  @override
  String get widget => '小组件';

  @override
  String get widgetOn => '小组件已开启';

  @override
  String get notifyTimerDoneTitle => '计时完成';

  @override
  String get notifyTimerDoneBody => '所有区段已完成 🎉';

  @override
  String get notifySegmentDoneTitle => '区段完成';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev 已完成 · 下一个：$next';
  }

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get presetPomodoro => '番茄钟 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => '深度工作 90/20';

  @override
  String get segFocus => '专注';

  @override
  String get segBreak => '休息';

  @override
  String get stopwatchLaps => '计圈记录';

  @override
  String get noLaps => '暂无计圈';

  @override
  String get timerLogTitle => '计时日志';

  @override
  String get noEvents => '暂无事件';

  @override
  String lapLabel(int num) {
    return '第 $num 圈';
  }

  @override
  String logStart(String name) {
    return '开始：$name';
  }

  @override
  String get logPaused => '已暂停';

  @override
  String get logReset => '已重置';

  @override
  String logSkipped(String name) {
    return '已跳过：$name';
  }

  @override
  String logDone(String name) {
    return '已完成：$name';
  }

  @override
  String get logAllDone => '所有区段已完成 🎉';

  @override
  String logLoop(String count) {
    return '🔁 第 $count 轮完成';
  }

  @override
  String get batteryLow => '电量不足 — 请充电';

  @override
  String get batteryMon => '电量';

  @override
  String get batteryMonOn => '电量 ON';

  @override
  String get settings => '设置';

  @override
  String get settingsBattery => '电量监控';

  @override
  String get settingsBatteryDesc => '电量低于20%时发出警告';

  @override
  String get settingsLanguage => '语言';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => '類比計時器';

  @override
  String get save => '儲存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '刪除';

  @override
  String get manage => '管理';

  @override
  String get timerSection => '計時器';

  @override
  String get btnStart => '開始';

  @override
  String get btnPause => '暫停';

  @override
  String get btnResume => '繼續';

  @override
  String get btnRunning => '進行中…';

  @override
  String get btnNext => '下一個';

  @override
  String get btnReset => '重設';

  @override
  String get stopwatchSection => '碼錶';

  @override
  String get btnLap => '計圈';

  @override
  String lapToast(int num, String time) {
    return '第 $num 圈    $time';
  }

  @override
  String get timerSegments => '計時區段';

  @override
  String get addSegment => '+ 新增區段';

  @override
  String get loopToggle => '循環';

  @override
  String get minutesUnit => '分鐘';

  @override
  String get segmentColor => '區段顏色';

  @override
  String get segments => '區段';

  @override
  String get savePresetChip => '儲存目前';

  @override
  String presetApplied(String name) {
    return '已新增預設 · $name';
  }

  @override
  String get noSegmentsToSave => '沒有可儲存的區段';

  @override
  String get savePresetTitle => '儲存預設';

  @override
  String get presetNameHint => '例如 讀書 50/10';

  @override
  String get presetName => '預設名稱';

  @override
  String get presetManageTitle => '管理預設';

  @override
  String get newPreset => '新增預設';

  @override
  String get editPreset => '編輯預設';

  @override
  String get deletePresetTitle => '刪除預設';

  @override
  String deletePresetConfirm(String name) {
    return '刪除「$name」？';
  }

  @override
  String get noPresets => '沒有已儲存的預設。\n點選右上角的「新增預設」加入一個。';

  @override
  String get enterName => '請輸入名稱';

  @override
  String get atLeastOneSegment => '請至少新增一個區段';

  @override
  String get legendTimer => '計時器 — 內圈螺旋';

  @override
  String get legendStopwatch => '碼錶 — 外圈';

  @override
  String get statusDone => '完成';

  @override
  String get statusWaiting => '就緒';

  @override
  String get widget => '小工具';

  @override
  String get widgetOn => '小工具已開啟';

  @override
  String get notifyTimerDoneTitle => '計時完成';

  @override
  String get notifyTimerDoneBody => '所有區段已完成 🎉';

  @override
  String get notifySegmentDoneTitle => '區段完成';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev 已完成 · 下一個：$next';
  }

  @override
  String get language => '語言';

  @override
  String get languageSystem => '跟隨系統';

  @override
  String get presetPomodoro => '番茄鐘 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => '深度工作 90/20';

  @override
  String get segFocus => '專注';

  @override
  String get segBreak => '休息';

  @override
  String get stopwatchLaps => '計圈記錄';

  @override
  String get noLaps => '尚無計圈';

  @override
  String get timerLogTitle => '計時記錄';

  @override
  String get noEvents => '尚無事件';

  @override
  String lapLabel(int num) {
    return '第 $num 圈';
  }

  @override
  String logStart(String name) {
    return '開始：$name';
  }

  @override
  String get logPaused => '已暫停';

  @override
  String get logReset => '已重設';

  @override
  String logSkipped(String name) {
    return '已跳過：$name';
  }

  @override
  String logDone(String name) {
    return '已完成：$name';
  }

  @override
  String get logAllDone => '所有區段已完成 🎉';

  @override
  String logLoop(String count) {
    return '🔁 第 $count 輪完成';
  }

  @override
  String get batteryLow => '電量不足 — 請充電';

  @override
  String get batteryMon => '電量';

  @override
  String get batteryMonOn => '電量 ON';

  @override
  String get settings => '設定';

  @override
  String get settingsBattery => '電量監控';

  @override
  String get settingsBatteryDesc => '電量低於20%時發出警告';

  @override
  String get settingsLanguage => '語言';
}
