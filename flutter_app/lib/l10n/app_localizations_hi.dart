// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'एनालॉग टाइमर';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get manage => 'प्रबंधित करें';

  @override
  String get timerSection => 'टाइमर';

  @override
  String get btnStart => 'शुरू';

  @override
  String get btnPause => 'रोकें';

  @override
  String get btnResume => 'जारी रखें';

  @override
  String get btnRunning => 'चल रहा है…';

  @override
  String get btnNext => 'अगला';

  @override
  String get btnReset => 'रीसेट';

  @override
  String get stopwatchSection => 'स्टॉपवॉच';

  @override
  String get btnLap => 'लैप';

  @override
  String lapToast(int num, String time) {
    return 'लैप $num    $time';
  }

  @override
  String get timerSegments => 'टाइमर सेगमेंट';

  @override
  String get addSegment => '+ सेगमेंट जोड़ें';

  @override
  String get loopToggle => 'लूप';

  @override
  String get minutesUnit => 'मिनट';

  @override
  String get segmentColor => 'सेगमेंट का रंग';

  @override
  String get segments => 'सेगमेंट';

  @override
  String get savePresetChip => 'वर्तमान सहेजें';

  @override
  String presetApplied(String name) {
    return 'प्रीसेट जोड़ा गया · $name';
  }

  @override
  String get noSegmentsToSave => 'सहेजने के लिए कोई सेगमेंट नहीं';

  @override
  String get savePresetTitle => 'प्रीसेट सहेजें';

  @override
  String get presetNameHint => 'जैसे अध्ययन 50/10';

  @override
  String get presetName => 'प्रीसेट का नाम';

  @override
  String get presetManageTitle => 'प्रीसेट प्रबंधित करें';

  @override
  String get newPreset => 'नया प्रीसेट';

  @override
  String get editPreset => 'प्रीसेट संपादित करें';

  @override
  String get deletePresetTitle => 'प्रीसेट हटाएँ';

  @override
  String deletePresetConfirm(String name) {
    return '\'$name\' हटाएँ?';
  }

  @override
  String get noPresets =>
      'कोई सहेजा गया प्रीसेट नहीं।\nऊपर दाईं ओर \"नया प्रीसेट\" से एक जोड़ें।';

  @override
  String get enterName => 'कृपया एक नाम दर्ज करें';

  @override
  String get atLeastOneSegment => 'कम से कम एक सेगमेंट जोड़ें';

  @override
  String get legendTimer => 'टाइमर — भीतरी सर्पिल';

  @override
  String get legendStopwatch => 'स्टॉपवॉच — बाहरी वलय';

  @override
  String get statusDone => 'पूर्ण';

  @override
  String get statusWaiting => 'तैयार';

  @override
  String get widget => 'विजेट';

  @override
  String get widgetOn => 'विजेट चालू';

  @override
  String get notifyTimerDoneTitle => 'टाइमर पूर्ण';

  @override
  String get notifyTimerDoneBody => 'सभी सेगमेंट समाप्त 🎉';

  @override
  String get notifySegmentDoneTitle => 'सेगमेंट पूर्ण';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev पूर्ण · अगला: $next';
  }

  @override
  String get language => 'भाषा';

  @override
  String get languageSystem => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get presetPomodoro => 'पोमोडोरो 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => 'गहन कार्य 90/20';

  @override
  String get segFocus => 'फोकस';

  @override
  String get segBreak => 'विराम';

  @override
  String get stopwatchLaps => 'स्टॉपवॉच लैप';

  @override
  String get noLaps => 'अभी कोई लैप नहीं';

  @override
  String get timerLogTitle => 'टाइमर लॉग';

  @override
  String get noEvents => 'कोई इवेंट नहीं';

  @override
  String lapLabel(int num) {
    return 'लैप $num';
  }

  @override
  String logStart(String name) {
    return 'शुरू: $name';
  }

  @override
  String get logPaused => 'रोका गया';

  @override
  String get logReset => 'रीसेट';

  @override
  String logSkipped(String name) {
    return 'छोड़ा गया: $name';
  }

  @override
  String logDone(String name) {
    return 'पूर्ण: $name';
  }

  @override
  String get logAllDone => 'सभी सेगमेंट पूर्ण 🎉';

  @override
  String logLoop(String count) {
    return '🔁 लूप $count पूर्ण';
  }

  @override
  String get batteryLow => 'बैटरी कम — कृपया चार्ज करें';

  @override
  String get batteryMon => 'बैटरी';

  @override
  String get batteryMonOn => 'बैटरी ON';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get settingsBattery => 'बैटरी निगरानी';

  @override
  String get settingsBatteryDesc => 'जब बैटरी 20% या कम हो तो चेतावनी दें';

  @override
  String get settingsLanguage => 'भाषा';
}
