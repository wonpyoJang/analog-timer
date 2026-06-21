// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Timer Analog';

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String get manage => 'Kelola';

  @override
  String get timerSection => 'TIMER';

  @override
  String get btnStart => 'MULAI';

  @override
  String get btnPause => 'JEDA';

  @override
  String get btnResume => 'LANJUT';

  @override
  String get btnRunning => 'BERJALAN…';

  @override
  String get btnNext => 'BERIKUTNYA';

  @override
  String get btnReset => 'RESET';

  @override
  String get stopwatchSection => 'STOPWATCH';

  @override
  String get btnLap => 'LAP';

  @override
  String lapToast(int num, String time) {
    return 'Lap $num    $time';
  }

  @override
  String get timerSegments => 'SEGMEN TIMER';

  @override
  String get addSegment => '+ Tambah segmen';

  @override
  String get loopToggle => 'Ulang';

  @override
  String get minutesUnit => 'mnt';

  @override
  String get segmentColor => 'Warna segmen';

  @override
  String get segments => 'Segmen';

  @override
  String get savePresetChip => 'Simpan saat ini';

  @override
  String presetApplied(String name) {
    return 'Preset ditambahkan · $name';
  }

  @override
  String get noSegmentsToSave => 'Tidak ada segmen untuk disimpan';

  @override
  String get savePresetTitle => 'Simpan preset';

  @override
  String get presetNameHint => 'mis. Belajar 50/10';

  @override
  String get presetName => 'Nama preset';

  @override
  String get presetManageTitle => 'Kelola preset';

  @override
  String get newPreset => 'Preset baru';

  @override
  String get editPreset => 'Edit preset';

  @override
  String get deletePresetTitle => 'Hapus preset';

  @override
  String deletePresetConfirm(String name) {
    return 'Hapus \"$name\"?';
  }

  @override
  String get noPresets =>
      'Belum ada preset tersimpan.\nTambahkan satu dengan \"Preset baru\" di kanan atas.';

  @override
  String get enterName => 'Masukkan nama';

  @override
  String get atLeastOneSegment => 'Tambahkan setidaknya satu segmen';

  @override
  String get legendTimer => 'Timer — spiral dalam';

  @override
  String get legendStopwatch => 'Stopwatch — cincin luar';

  @override
  String get statusDone => 'Selesai';

  @override
  String get statusWaiting => 'Siap';

  @override
  String get widget => 'Widget';

  @override
  String get widgetOn => 'Widget AKTIF';

  @override
  String get notifyTimerDoneTitle => 'Timer selesai';

  @override
  String get notifyTimerDoneBody => 'Semua segmen selesai 🎉';

  @override
  String get notifySegmentDoneTitle => 'Segmen selesai';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev selesai · Berikutnya: $next';
  }

  @override
  String get language => 'Bahasa';

  @override
  String get languageSystem => 'Default sistem';

  @override
  String get presetPomodoro => 'Pomodoro 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => 'Kerja fokus 90/20';

  @override
  String get segFocus => 'Fokus';

  @override
  String get segBreak => 'Istirahat';

  @override
  String get stopwatchLaps => 'Lap stopwatch';

  @override
  String get noLaps => 'Belum ada lap';

  @override
  String get timerLogTitle => 'Log timer';

  @override
  String get noEvents => 'Tidak ada peristiwa';

  @override
  String lapLabel(int num) {
    return 'Lap $num';
  }

  @override
  String logStart(String name) {
    return 'Mulai: $name';
  }

  @override
  String get logPaused => 'Dijeda';

  @override
  String get logReset => 'Direset';

  @override
  String logSkipped(String name) {
    return 'Dilewati: $name';
  }

  @override
  String logDone(String name) {
    return 'Selesai: $name';
  }

  @override
  String get logAllDone => 'Semua segmen selesai 🎉';

  @override
  String logLoop(String count) {
    return '🔁 Putaran $count selesai';
  }
}
