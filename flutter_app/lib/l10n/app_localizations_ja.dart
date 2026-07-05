// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'アナログタイマー';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get manage => '管理';

  @override
  String get timerSection => 'タイマー';

  @override
  String get btnStart => '開始';

  @override
  String get btnPause => '一時停止';

  @override
  String get btnResume => '再開';

  @override
  String get btnRunning => '実行中…';

  @override
  String get btnNext => '次へ';

  @override
  String get btnReset => 'リセット';

  @override
  String get stopwatchSection => 'ストップウォッチ';

  @override
  String get btnLap => 'ラップ';

  @override
  String lapToast(int num, String time) {
    return 'ラップ $num    $time';
  }

  @override
  String get timerSegments => 'タイマーセグメント';

  @override
  String get addSegment => '+ セグメントを追加';

  @override
  String get loopToggle => 'ループ';

  @override
  String get minutesUnit => '分';

  @override
  String get segmentColor => 'セグメントの色';

  @override
  String get segments => 'セグメント';

  @override
  String get savePresetChip => '現在の設定を保存';

  @override
  String presetApplied(String name) {
    return 'プリセットを追加しました · $name';
  }

  @override
  String get noSegmentsToSave => '保存するセグメントがありません';

  @override
  String get savePresetTitle => 'プリセットを保存';

  @override
  String get presetNameHint => '例: 勉強 50/10';

  @override
  String get presetName => 'プリセット名';

  @override
  String get presetManageTitle => 'プリセットを管理';

  @override
  String get newPreset => '新しいプリセット';

  @override
  String get editPreset => 'プリセットを編集';

  @override
  String get deletePresetTitle => 'プリセットを削除';

  @override
  String deletePresetConfirm(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get noPresets => '保存されたプリセットはありません。\n右上の「新しいプリセット」から追加してください。';

  @override
  String get enterName => '名前を入力してください';

  @override
  String get atLeastOneSegment => 'セグメントを1つ以上追加してください';

  @override
  String get legendTimer => 'タイマー — 内側のスパイラル';

  @override
  String get legendStopwatch => 'ストップウォッチ — 外側のリング';

  @override
  String get statusDone => '完了';

  @override
  String get statusWaiting => '準備完了';

  @override
  String get widget => 'ウィジェット';

  @override
  String get widgetOn => 'ウィジェット オン';

  @override
  String get notifyTimerDoneTitle => 'タイマー完了';

  @override
  String get notifyTimerDoneBody => 'すべてのセグメントが完了しました 🎉';

  @override
  String get notifySegmentDoneTitle => 'セグメント完了';

  @override
  String notifySegmentDoneBody(String prev, String next) {
    return '$prev 完了 · 次: $next';
  }

  @override
  String get language => '言語';

  @override
  String get languageSystem => 'システムの既定';

  @override
  String get presetPomodoro => 'ポモドーロ 25/5';

  @override
  String get preset5217 => '52/17';

  @override
  String get presetDeepwork => 'ディープワーク 90/20';

  @override
  String get segFocus => '集中';

  @override
  String get segBreak => '休憩';

  @override
  String get stopwatchLaps => 'ラップ記録';

  @override
  String get noLaps => 'ラップはまだありません';

  @override
  String get timerLogTitle => 'タイマーログ';

  @override
  String get noEvents => 'イベントはありません';

  @override
  String lapLabel(int num) {
    return 'ラップ $num';
  }

  @override
  String logStart(String name) {
    return '開始: $name';
  }

  @override
  String get logPaused => '一時停止';

  @override
  String get logReset => 'リセット';

  @override
  String logSkipped(String name) {
    return 'スキップ: $name';
  }

  @override
  String logDone(String name) {
    return '完了: $name';
  }

  @override
  String get logAllDone => 'すべてのセグメントが完了しました 🎉';

  @override
  String logLoop(String count) {
    return '🔁 ループ $count 回目完了';
  }

  @override
  String get batteryLow => 'バッテリー残量低下 — 充電してください';

  @override
  String get batteryMon => 'バッテリー';

  @override
  String get batteryMonOn => 'バッテリー ON';

  @override
  String get settings => '設定';

  @override
  String get settingsBattery => 'バッテリー監視';

  @override
  String get settingsBatteryDesc => 'バッテリーが20%以下になったら警告';

  @override
  String get settingsLanguage => '言語';

  @override
  String get modeLabelLog => 'ログ';

  @override
  String get modeLabelToday => '今日';

  @override
  String get modeLabelPlan => '予定';

  @override
  String get dayLogTitle => '当日の記録';

  @override
  String get dayLogEmpty => 'この日の記録はありません';

  @override
  String get dayPlanTitle => '当日の予定';

  @override
  String get dayPlanEmpty => 'この日の予定はありません';

  @override
  String get planSaveAsCurrent => '計画として保存';

  @override
  String get planLoadIntoTimer => 'タイマーに読み込む';

  @override
  String get planSave => '保存';

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
  String get feedbackSend => 'Send';

  @override
  String get feedbackSent => 'Thanks! Your feedback has been sent.';

  @override
  String get feedbackFailed =>
      'Failed to send — check your network and try again';

  @override
  String get feedbackMessageRequired => 'Please write a message first';

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
}
