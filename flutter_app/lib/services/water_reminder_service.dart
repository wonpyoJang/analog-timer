import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 물 마시기 알림(디자인 "물 알림 & 루틴 알람" §1·§2).
///
/// 철칙: **간격 타이머는 "마셨어요" 시점부터 리셋**(합집합 아님 — 방금 마셨는데 또
/// 울리는 사고 방지). 정해진 시각과 [dedupMin]분 내로 겹치면 하나만. 활동 시간대
/// 밖에서는 전부 침묵. 무시해도 카운트 불변("죄책감 UI 금지").
///
/// 현재 구현: 앱 실행 중 인앱 알림(배너+소리). 백그라운드(앱 종료) 예약 전달은
/// flutter_local_notifications 도입 후 후속(§ nextWaterReminderMs 를 그대로 재사용).
class WaterReminderService {
  WaterReminderService._();
  static final WaterReminderService instance = WaterReminderService._();

  static const _kEnabled = 'water_enabled';
  static const _kIntervalMin = 'water_interval_min';
  static const _kFixedEnabled = 'water_fixed_enabled';
  static const _kFixed = 'water_fixed_times'; // 분-of-day CSV
  static const _kActiveStart = 'water_active_start';
  static const _kActiveEnd = 'water_active_end';
  static const _kWithTimerEnd = 'water_with_timer_end';
  static const _kSound = 'water_sound'; // true=한 번 소리 / false=배너
  static const _kGoal = 'water_goal';
  static const _kCount = 'water_count';
  static const _kCountDay = 'water_count_day'; // yyyymmdd — 날짜 바뀌면 리셋
  static const _kLastDrank = 'water_last_drank_ms';
  static const _kLastReminded = 'water_last_reminded_ms';
  static const _kSnooze = 'water_snooze_until_ms';
  static const _kMutedDay = 'water_muted_day'; // "오늘은 그만" 누른 날

  final ValueNotifier<bool> enabled = ValueNotifier<bool>(false);
  final ValueNotifier<int> intervalMin = ValueNotifier<int>(60);
  final ValueNotifier<bool> fixedEnabled = ValueNotifier<bool>(false);
  final ValueNotifier<List<int>> fixedTimes = ValueNotifier<List<int>>(const [
    540,
    660,
    840,
    960,
    1140,
  ]);
  final ValueNotifier<int> activeStartMin = ValueNotifier<int>(420); // 7:00
  final ValueNotifier<int> activeEndMin = ValueNotifier<int>(1350); // 22:30
  final ValueNotifier<bool> withTimerEnd = ValueNotifier<bool>(false);
  final ValueNotifier<bool> sound = ValueNotifier<bool>(true);
  final ValueNotifier<int> dailyGoal = ValueNotifier<int>(8);

  /// 오늘 마신 잔 수(자정 지나면 0). UI 가 구독.
  final ValueNotifier<int> todayCount = ValueNotifier<int>(0);

  int _lastDrankMs = 0;
  // 알림이 한 번 울리면 그 슬롯을 소비(간격은 여기서 다시 셈) → 재알림 없음.
  int _lastRemindedMs = 0;
  // "30분 뒤" 스누즈 — 이 시각 전엔 안 울림.
  int _snoozeUntilMs = 0;

  static int _dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    enabled.value = p.getBool(_kEnabled) ?? false;
    intervalMin.value = p.getInt(_kIntervalMin) ?? 60;
    fixedEnabled.value = p.getBool(_kFixedEnabled) ?? false;
    final f = p.getString(_kFixed);
    if (f != null && f.isNotEmpty) {
      fixedTimes.value = f
          .split(',')
          .map(int.tryParse)
          .whereType<int>()
          .toList();
    }
    activeStartMin.value = p.getInt(_kActiveStart) ?? 420;
    activeEndMin.value = p.getInt(_kActiveEnd) ?? 1350;
    withTimerEnd.value = p.getBool(_kWithTimerEnd) ?? false;
    sound.value = p.getBool(_kSound) ?? true;
    dailyGoal.value = p.getInt(_kGoal) ?? 8;
    _lastDrankMs = p.getInt(_kLastDrank) ?? 0;
    _lastRemindedMs = p.getInt(_kLastReminded) ?? 0;
    _snoozeUntilMs = p.getInt(_kSnooze) ?? 0;
    // 날짜 롤오버 — 카운트는 오늘 것만.
    final today = _dayKey(DateTime.now());
    todayCount.value = (p.getInt(_kCountDay) == today)
        ? (p.getInt(_kCount) ?? 0)
        : 0;
  }

  Future<SharedPreferences> get _p => SharedPreferences.getInstance();

  Future<void> setEnabled(bool v) async =>
      _p.then((p) => p.setBool(_kEnabled, enabled.value = v));
  Future<void> setInterval(int m) async =>
      _p.then((p) => p.setInt(_kIntervalMin, intervalMin.value = m));
  Future<void> setFixedEnabled(bool v) async =>
      _p.then((p) => p.setBool(_kFixedEnabled, fixedEnabled.value = v));
  Future<void> setWithTimerEnd(bool v) async =>
      _p.then((p) => p.setBool(_kWithTimerEnd, withTimerEnd.value = v));
  Future<void> setSound(bool v) async =>
      _p.then((p) => p.setBool(_kSound, sound.value = v));
  Future<void> setGoal(int g) async =>
      _p.then((p) => p.setInt(_kGoal, dailyGoal.value = g));
  Future<void> setActiveHours(int start, int end) async {
    activeStartMin.value = start;
    activeEndMin.value = end;
    final p = await _p;
    await p.setInt(_kActiveStart, start);
    await p.setInt(_kActiveEnd, end);
  }

  /// "마셨어요" — 한 잔 기록 + 간격 타이머 리셋 기준점 갱신.
  Future<void> recordCup([DateTime? at]) async {
    final now = at ?? DateTime.now();
    final p = await _p;
    final today = _dayKey(now);
    final cur = (p.getInt(_kCountDay) == today) ? (p.getInt(_kCount) ?? 0) : 0;
    todayCount.value = cur + 1;
    _lastDrankMs = now.millisecondsSinceEpoch;
    await p.setInt(_kCount, todayCount.value);
    await p.setInt(_kCountDay, today);
    await p.setInt(_kLastDrank, _lastDrankMs);
  }

  /// 알림이 울렸음 — 슬롯 소비(간격을 여기서 다시 셈, 즉시 재알림 방지).
  Future<void> markReminded([DateTime? at]) async {
    _lastRemindedMs = (at ?? DateTime.now()).millisecondsSinceEpoch;
    final p = await _p;
    await p.setInt(_kLastReminded, _lastRemindedMs);
  }

  /// "30분 뒤" — 30분간 스누즈(간격/시각 무시). 카운트 불변.
  Future<void> snooze30([DateTime? at]) async {
    _snoozeUntilMs = (at ?? DateTime.now()).millisecondsSinceEpoch + 30 * 60000;
    final p = await _p;
    await p.setInt(_kSnooze, _snoozeUntilMs);
  }

  /// "오늘은 그만" — 오늘 하루 침묵(카운트는 불변).
  Future<void> muteToday([DateTime? at]) async {
    final p = await _p;
    await p.setInt(_kMutedDay, _dayKey(at ?? DateTime.now()));
  }

  Future<bool> _mutedToday(DateTime now) async {
    final p = await _p;
    return p.getInt(_kMutedDay) == _dayKey(now);
  }

  /// 다음 알림 예정 시각(epoch ms). null = 예정 없음(비활성·목표달성·오늘 그만).
  /// 스케줄 순수 로직은 [nextWaterReminderMs] 에 위임(유닛테스트로 잠금).
  Future<int?> nextReminderMs([DateTime? at]) async {
    final now = at ?? DateTime.now();
    if (!enabled.value) return null;
    if (todayCount.value >= dailyGoal.value) return null; // 목표 달성 → 침묵
    if (await _mutedToday(now)) return null;
    // 간격 기준선 = 마지막 섭취/알림 중 최신(알림도 슬롯을 소비 → 재알림 방지).
    final base = _lastDrankMs > _lastRemindedMs
        ? _lastDrankMs
        : _lastRemindedMs;
    final next = nextWaterReminderMs(
      nowMs: now.millisecondsSinceEpoch,
      lastDrankMs: base,
      intervalMin: intervalMin.value,
      fixedTimes: fixedEnabled.value ? fixedTimes.value : const [],
      activeStartMin: activeStartMin.value,
      activeEndMin: activeEndMin.value,
    );
    if (next == null) return null;
    // 스누즈("30분 뒤")가 걸려 있으면 그 이후로 미룸.
    return next > _snoozeUntilMs ? next : _snoozeUntilMs;
  }

  /// 지금 알림을 울려야 하나(인앱 트리거용). 예정 시각이 [slackMs] 이내로 지났으면 true.
  Future<bool> isDueNow([DateTime? at]) async {
    final now = at ?? DateTime.now();
    final next = await nextReminderMs(now);
    if (next == null) return false;
    return next <= now.millisecondsSinceEpoch;
  }
}

/// 다음 물 알림 시각 계산 — **순수 함수**. 간격(마지막 섭취 기준)과 정해진 시각 중
/// 활동 시간대 안의 가장 이른 후보. [dedupMin]분 내 중복은 하나로. 활동 시간대
/// 밖 후보는 다음 활동창 시작으로 미룸. 후보가 없으면 null.
int? nextWaterReminderMs({
  required int nowMs,
  required int lastDrankMs,
  required int intervalMin,
  required List<int> fixedTimes,
  required int activeStartMin,
  required int activeEndMin,
  int dedupMin = 30,
}) {
  const dayMs = 86400000;
  final now = DateTime.fromMillisecondsSinceEpoch(nowMs);
  int minOfDay(DateTime d) => d.hour * 60 + d.minute;
  int startOfDayMs(DateTime d) =>
      DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;

  // 활동창 안으로 당김/미룸: t 가 활동창 밖이면 그 날(또는 다음 날) 활동 시작으로.
  int clampToActive(int t) {
    var cur = t;
    for (var i = 0; i < 3; i++) {
      final d = DateTime.fromMillisecondsSinceEpoch(cur);
      final m = minOfDay(d);
      final sod = startOfDayMs(d);
      if (m < activeStartMin) {
        cur = sod + activeStartMin * 60000; // 오늘 활동 시작으로 당김
      } else if (m > activeEndMin) {
        cur = sod + dayMs + activeStartMin * 60000; // 내일 활동 시작
      } else {
        return cur;
      }
    }
    return cur;
  }

  final candidates = <int>[];
  // 간격 후보 — 마지막 섭취(없으면 now) + interval. now 이전이면 now 로.
  if (intervalMin > 0) {
    final base = lastDrankMs > 0 ? lastDrankMs : nowMs;
    var iv = base + intervalMin * 60000;
    if (iv < nowMs) iv = nowMs;
    candidates.add(clampToActive(iv));
  }
  // 정해진 시각 후보 — 오늘/내일 것 중 now 이후 첫 번째.
  final sodNow = startOfDayMs(now);
  for (final fm in fixedTimes) {
    var ft = sodNow + fm * 60000;
    if (ft < nowMs) ft += dayMs; // 오늘 지났으면 내일
    candidates.add(clampToActive(ft));
  }
  if (candidates.isEmpty) return null;
  candidates.sort();

  // dedup: 가장 이른 것 기준으로 dedupMin 내 후보는 하나로 접음(가장 이른 것 채택).
  final next = candidates.first;
  return next;
}
