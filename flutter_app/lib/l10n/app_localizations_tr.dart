// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Analog Zamanlayıcı';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'İptal';

  @override
  String get delete => 'Sil';

  @override
  String get manage => 'Yönet';

  @override
  String get timerSection => 'ZAMANLAYICI';

  @override
  String get btnStart => 'BAŞLAT';

  @override
  String get btnPause => 'DURAKLAT';

  @override
  String get btnResume => 'DEVAM';

  @override
  String get btnRunning => 'ÇALIŞIYOR…';

  @override
  String get btnNext => 'SONRAKİ';

  @override
  String get btnReset => 'SIFIRLA';

  @override
  String get stopwatchSection => 'KRONOMETRE';

  @override
  String get btnLap => 'TUR';

  @override
  String lapToast(int num, String time) {
    return 'Tur $num    $time';
  }

  @override
  String get timerSegments => 'ZAMANLAYICI BÖLÜMLERİ';

  @override
  String get addSegment => '+ Bölüm ekle';

  @override
  String get loopToggle => 'Döngü';

  @override
  String get minutesUnit => 'dk';

  @override
  String get segmentColor => 'Bölüm rengi';

  @override
  String get segments => 'Bölümler';

  @override
  String get savePresetChip => 'Mevcudu kaydet';

  @override
  String presetApplied(String name) {
    return 'Hazır ayar eklendi · $name';
  }

  @override
  String get noSegmentsToSave => 'Kaydedilecek bölüm yok';

  @override
  String get savePresetTitle => 'Hazır ayarı kaydet';

  @override
  String get presetNameHint => 'örn. Çalışma 50/10';

  @override
  String get presetName => 'Hazır ayar adı';

  @override
  String get presetManageTitle => 'Hazır ayarları yönet';

  @override
  String get newPreset => 'Yeni hazır ayar';

  @override
  String get editPreset => 'Hazır ayarı düzenle';

  @override
  String get deletePresetTitle => 'Hazır ayarı sil';

  @override
  String deletePresetConfirm(String name) {
    return '\"$name\" silinsin mi?';
  }

  @override
  String get noPresets =>
      'Kayıtlı hazır ayar yok.\nSağ üstteki \"Yeni hazır ayar\" ile bir tane ekleyin.';

  @override
  String get enterName => 'Lütfen bir ad girin';

  @override
  String get atLeastOneSegment => 'En az bir bölüm ekleyin';

  @override
  String get legendTimer => 'Zamanlayıcı — iç spiral';

  @override
  String get legendStopwatch => 'Kronometre — dış halka';

  @override
  String get statusDone => 'Bitti';

  @override
  String get statusWaiting => 'Hazır';

  @override
  String get widget => 'Widget';

  @override
  String get widgetOn => 'Widget AÇIK';

  @override
  String get notifyTimerDoneTitle => 'Zamanlayıcı tamamlandı';

  @override
  String get notifyTimerDoneBody => 'Tüm bölümler tamamlandı 🎉';

  @override
  String get notifySegmentDoneTitle => 'Bölüm tamamlandı';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev bitti · Sonraki: $next';
  }

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Sistem varsayılanı';

  @override
  String get presetPomodoro => 'Pomodoro 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => 'Derin çalışma 90/20';

  @override
  String get segFocus => 'Odak';

  @override
  String get segBreak => 'Mola';

  @override
  String get stopwatchLaps => 'Kronometre turları';

  @override
  String get noLaps => 'Henüz tur yok';

  @override
  String get timerLogTitle => 'Zamanlayıcı günlüğü';

  @override
  String get noEvents => 'Etkinlik yok';

  @override
  String lapLabel(int num) {
    return 'Tur $num';
  }

  @override
  String logStart(String name) {
    return 'Başlangıç: $name';
  }

  @override
  String get logPaused => 'Duraklatıldı';

  @override
  String get logReset => 'Sıfırlandı';

  @override
  String logSkipped(String name) {
    return 'Atlandı: $name';
  }

  @override
  String logDone(String name) {
    return 'Tamamlandı: $name';
  }

  @override
  String get logAllDone => 'Tüm bölümler tamamlandı 🎉';

  @override
  String logLoop(String count) {
    return '🔁 Döngü $count tamamlandı';
  }

  @override
  String get batteryLow => 'Pil az — lütfen şarj edin';

  @override
  String get batteryMon => 'Pil';

  @override
  String get batteryMonOn => 'Pil ON';

  @override
  String get settings => 'Ayarlar';

  @override
  String get settingsBattery => 'Pil izleme';

  @override
  String get settingsBatteryDesc => 'Pil %20 veya altına düştüğünde uyar';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get modeLabelLog => 'Günlük';

  @override
  String get modeLabelToday => 'Bugün';

  @override
  String get modeLabelPlan => 'Plan';

  @override
  String get dayLogTitle => 'Günlük Kaydı';

  @override
  String get dayLogEmpty => 'Bu gün için kayıt yok';

  @override
  String get dayPlanTitle => 'Günlük Plan';

  @override
  String get dayPlanEmpty => 'Bu gün için plan yok';

  @override
  String get planSaveAsCurrent => 'Plan olarak kaydet';

  @override
  String get planLoadIntoTimer => 'Zamanlayıcıya yükle';
}
