// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مؤقت تناظري';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get manage => 'إدارة';

  @override
  String get timerSection => 'المؤقّت';

  @override
  String get btnStart => 'ابدأ';

  @override
  String get btnPause => 'إيقاف مؤقت';

  @override
  String get btnResume => 'استئناف';

  @override
  String get btnRunning => 'قيد التشغيل…';

  @override
  String get btnNext => 'التالي';

  @override
  String get btnReset => 'تصفير';

  @override
  String get stopwatchSection => 'ساعة الإيقاف';

  @override
  String get btnLap => 'لفة';

  @override
  String lapToast(int num, String time) {
    return 'اللفة $num    $time';
  }

  @override
  String get timerSegments => 'مقاطع المؤقّت';

  @override
  String get addSegment => '+ إضافة مقطع';

  @override
  String get loopToggle => 'تكرار';

  @override
  String get minutesUnit => 'دقيقة';

  @override
  String get segmentColor => 'لون المقطع';

  @override
  String get segments => 'المقاطع';

  @override
  String get savePresetChip => 'حفظ الحالي';

  @override
  String presetApplied(String name) {
    return 'تمت إضافة الإعداد · $name';
  }

  @override
  String get noSegmentsToSave => 'لا توجد مقاطع للحفظ';

  @override
  String get savePresetTitle => 'حفظ الإعداد';

  @override
  String get presetNameHint => 'مثال: دراسة 50/10';

  @override
  String get presetName => 'اسم الإعداد';

  @override
  String get presetManageTitle => 'إدارة الإعدادات';

  @override
  String get newPreset => 'إعداد جديد';

  @override
  String get editPreset => 'تعديل الإعداد';

  @override
  String get deletePresetTitle => 'حذف الإعداد';

  @override
  String deletePresetConfirm(String name) {
    return 'حذف «$name»؟';
  }

  @override
  String get noPresets =>
      'لا توجد إعدادات محفوظة.\nأضف واحدًا عبر «إعداد جديد» في أعلى اليمين.';

  @override
  String get enterName => 'يرجى إدخال اسم';

  @override
  String get atLeastOneSegment => 'أضف مقطعًا واحدًا على الأقل';

  @override
  String get legendTimer => 'المؤقّت — الحلزون الداخلي';

  @override
  String get legendStopwatch => 'ساعة الإيقاف — الحلقة الخارجية';

  @override
  String get statusDone => 'تم';

  @override
  String get statusWaiting => 'جاهز';

  @override
  String get widget => 'الأداة';

  @override
  String get widgetOn => 'الأداة مفعّلة';

  @override
  String get notifyTimerDoneTitle => 'اكتمل المؤقّت';

  @override
  String get notifyTimerDoneBody => 'اكتملت جميع المقاطع 🎉';

  @override
  String get notifySegmentDoneTitle => 'اكتمل المقطع';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return 'اكتمل $prev · التالي: $next';
  }

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'إعداد النظام الافتراضي';

  @override
  String get presetPomodoro => 'بومودورو 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => 'العمل العميق 90/20';

  @override
  String get segFocus => 'تركيز';

  @override
  String get segBreak => 'استراحة';

  @override
  String get stopwatchLaps => 'لفّات ساعة الإيقاف';

  @override
  String get noLaps => 'لا توجد لفّات بعد';

  @override
  String get timerLogTitle => 'سجل المؤقّت';

  @override
  String get noEvents => 'لا توجد أحداث';

  @override
  String lapLabel(int num) {
    return 'اللفة $num';
  }

  @override
  String logStart(String name) {
    return 'بدء: $name';
  }

  @override
  String get logPaused => 'متوقف مؤقتًا';

  @override
  String get logReset => 'إعادة تعيين';

  @override
  String logSkipped(String name) {
    return 'تم التخطي: $name';
  }

  @override
  String logDone(String name) {
    return 'اكتمل: $name';
  }

  @override
  String get logAllDone => 'اكتملت جميع المقاطع 🎉';

  @override
  String logLoop(String count) {
    return '🔁 اكتملت الدورة $count';
  }

  @override
  String get batteryLow => 'البطارية منخفضة — يرجى الشحن';

  @override
  String get batteryMon => 'بطارية';

  @override
  String get batteryMonOn => 'بطارية ON';

  @override
  String get settings => 'الإعدادات';

  @override
  String get settingsBattery => 'مراقبة البطارية';

  @override
  String get settingsBatteryDesc => 'تحذير عند انخفاض البطارية إلى 20٪ أو أقل';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get modeLabelLog => 'سجل';

  @override
  String get modeLabelToday => 'اليوم';

  @override
  String get modeLabelPlan => 'خطة';

  @override
  String get dayLogTitle => 'سجل اليوم';

  @override
  String get dayLogEmpty => 'لا توجد أنشطة مسجلة لهذا اليوم';

  @override
  String get dayPlanTitle => 'خطة اليوم';

  @override
  String get dayPlanEmpty => 'لا توجد خطة لهذا اليوم';

  @override
  String get planSaveAsCurrent => 'حفظ كخطة';

  @override
  String get planLoadIntoTimer => 'تحميل في المؤقت';

  @override
  String get planSave => 'حفظ';
}
