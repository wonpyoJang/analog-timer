import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'activity_stats_service.dart';

/// 활동 통계 화면(디자인 "활동 통계") — 기간 탭 + 총 집중 시간 + 세션/연속/최고
/// + 최근 7일 스택 막대 + 활동별 분석 + 인사이트. 데이터는 완료 로그 자동 집계.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _period = 'week';
  String? _sel; // 하이라이트 활동 이름
  List<ActivityLog> _logs = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final logs = await ActivityStatsService.instance.load();
    if (!mounted) return;
    setState(() {
      _logs = logs;
      _loaded = true;
    });
  }

  DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

  /// 현재 기간에 포함되는 로그.
  List<ActivityLog> get _periodLogs {
    final now = DateTime.now();
    final today0 = _dayStart(now).millisecondsSinceEpoch;
    return switch (_period) {
      'today' => _logs.where((e) => e.atMs >= today0).toList(),
      'month' =>
        _logs
            .where(
              (e) =>
                  e.atMs >=
                  _dayStart(
                    now.subtract(const Duration(days: 29)),
                  ).millisecondsSinceEpoch,
            )
            .toList(),
      _ =>
        _logs
            .where(
              (e) =>
                  e.atMs >=
                  _dayStart(
                    now.subtract(const Duration(days: 6)),
                  ).millisecondsSinceEpoch,
            )
            .toList(),
    };
  }

  /// 연속일(오늘 또는 어제부터 역산) — 완료가 있는 날의 연속 수.
  int get _streak {
    final days = _logs
        .map((e) => _dayStart(DateTime.fromMillisecondsSinceEpoch(e.atMs)))
        .toSet();
    if (days.isEmpty) return 0;
    var cur = _dayStart(DateTime.now());
    if (!days.contains(cur)) {
      cur = cur.subtract(const Duration(days: 1));
      if (!days.contains(cur)) return 0;
    }
    var n = 0;
    while (days.contains(cur)) {
      n++;
      cur = cur.subtract(const Duration(days: 1));
    }
    return n;
  }

  /// 역대 최고 연속.
  int get _bestStreak {
    final days =
        _logs
            .map((e) => _dayStart(DateTime.fromMillisecondsSinceEpoch(e.atMs)))
            .toSet()
            .toList()
          ..sort();
    if (days.isEmpty) return 0;
    var best = 1, run = 1;
    for (var i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays == 1) {
        run++;
        best = run > best ? run : best;
      } else {
        run = 1;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pl = _periodLogs;
    // 활동별 합계·세션.
    final byName = <String, int>{};
    final sessByName = <String, int>{};
    for (final e in pl) {
      byName[e.name] = (byName[e.name] ?? 0) + e.durationMs;
      sessByName[e.name] = (sessByName[e.name] ?? 0) + 1;
    }
    final activities = byName.keys.toList()
      ..sort((a, b) => byName[b]!.compareTo(byName[a]!));
    final totalMs = byName.values.fold<int>(0, (a, b) => a + b);
    final totalSessions = pl.length;

    // 최근 7일 스택 데이터(항상 주간 창).
    final now = DateTime.now();
    final week = List.generate(7, (i) {
      final day = _dayStart(now.subtract(Duration(days: 6 - i)));
      final dayMs = day.millisecondsSinceEpoch;
      final nextMs = day.add(const Duration(days: 1)).millisecondsSinceEpoch;
      final segs = <String, int>{};
      for (final e in _logs) {
        if (e.atMs >= dayMs && e.atMs < nextMs) {
          segs[e.name] = (segs[e.name] ?? 0) + e.durationMs;
        }
      }
      return (
        day: day,
        segs: segs,
        total: segs.values.fold<int>(0, (a, b) => a + b),
      );
    });
    final maxDay = week.fold<int>(1, (m, d) => d.total > m ? d.total : m);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: AppColors.text,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text('📊 ', style: TextStyle(fontSize: 20)),
            Text(
              l.statsTitle,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
      body: !_loaded
          ? const SizedBox.shrink()
          : _logs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l.statsEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 14),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 30),
              children: [
                // 기간 탭
                Row(
                  children: [
                    for (final t in [
                      ('today', l.statsToday),
                      ('week', l.statsWeek),
                      ('month', l.statsMonth),
                    ])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _PeriodTab(
                            label: t.$2,
                            selected: _period == t.$1,
                            onTap: () => setState(() => _period = t.$1),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                // 총 집중 시간
                Center(
                  child: Column(
                    children: [
                      Text(
                        l.statsFocusedTime(switch (_period) {
                          'today' => l.statsToday,
                          'month' => l.statsMonth,
                          _ => l.statsWeek,
                        }),
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      _BigDuration(ms: totalMs),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _summaryStat(l.statsSessions, '$totalSessions'),
                          const SizedBox(width: 20),
                          _summaryStat(
                            l.statsStreak,
                            '$_streak🔥',
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 20),
                          _summaryStat(l.statsBest, '$_bestStreak'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                // 최근 7일 스택 막대
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.statsLast7,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 130,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (var di = 0; di < 7; di++)
                              Expanded(
                                child: _DayBar(
                                  day: week[di].day,
                                  segs: week[di].segs,
                                  total: week[di].total,
                                  maxDay: maxDay,
                                  isToday: di == 6,
                                  sel: _sel,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 14,
                        runSpacing: 6,
                        children: [
                          for (final a in activities)
                            _LegendChip(
                              name: a,
                              on: _sel == null || _sel == a,
                              onTap: () =>
                                  setState(() => _sel = _sel == a ? null : a),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 활동별
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.statsByActivity,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final a in activities)
                        _ActivityRow(
                          name: a,
                          ms: byName[a]!,
                          sessions: sessByName[a]!,
                          pct: totalMs > 0 ? byName[a]! / totalMs * 100 : 0,
                          on: _sel == null || _sel == a,
                          onTap: () =>
                              setState(() => _sel = _sel == a ? null : a),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 인사이트
                _insight(l, week),
                const SizedBox(height: 14),
                Text(
                  l.statsPrivacy,
                  style: TextStyle(color: AppColors.faint, fontSize: 11.5),
                ),
              ],
            ),
    );
  }

  Widget _summaryStat(String label, String value, {Color? color}) => Row(
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      Text('$label ', style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
      Text(
        value,
        style: TextStyle(
          color: color ?? AppColors.text,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );

  Widget _insight(AppLocalizations l, List<dynamic> week) {
    // 최다 집중 요일.
    var bestIdx = 0;
    for (var i = 1; i < week.length; i++) {
      if (week[i].total > week[bestIdx].total) bestIdx = i;
    }
    if (week[bestIdx].total == 0) return const SizedBox.shrink();
    final dayName = _weekdayName(week[bestIdx].day.weekday, l);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(0x12),
        border: Border.all(color: AppColors.accent.withAlpha(0x40)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡 ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              l.statsInsightTop(dayName, _streak),
              style: const TextStyle(
                color: Color(0xFFD8CFB6),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _weekdayName(int weekday, AppLocalizations l) {
    // DateTime.weekday: 1=Mon..7=Sun. l10n 요일 약어 재사용이 없으므로 로케일 판단.
    final ko = Localizations.localeOf(context).languageCode.startsWith('ko');
    const koN = ['월', '화', '수', '목', '금', '토', '일'];
    const enN = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return (ko ? koN : enN)[weekday - 1];
  }
}

class _PeriodTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PeriodTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.accent.withAlpha(0x21) : Colors.transparent,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.accent : AppColors.muted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ),
  );
}

class _BigDuration extends StatelessWidget {
  final int ms;
  const _BigDuration({required this.ms});

  @override
  Widget build(BuildContext context) {
    final totalMin = ms ~/ 60000;
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (h > 0) ...[_num('$h'), _unit('H ')],
        _num('$m'),
        _unit('M'),
      ],
    );
  }

  Widget _num(String s) => Text(
    s,
    style: const TextStyle(
      color: AppColors.text,
      fontSize: 56,
      height: 1,
      fontWeight: FontWeight.w800,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  );
  Widget _unit(String s) => Text(
    s,
    style: TextStyle(
      color: AppColors.muted,
      fontSize: 26,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _DayBar extends StatelessWidget {
  final DateTime day;
  final Map<String, int> segs;
  final int total;
  final int maxDay;
  final bool isToday;
  final String? sel;
  const _DayBar({
    required this.day,
    required this.segs,
    required this.total,
    required this.maxDay,
    required this.isToday,
    required this.sel,
  });

  @override
  Widget build(BuildContext context) {
    final ko = Localizations.localeOf(context).languageCode.startsWith('ko');
    const koN = ['월', '화', '수', '목', '금', '토', '일'];
    const enN = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final label = (ko ? koN : enN)[day.weekday - 1];
    final names = segs.keys.toList();
    // 막대·세그먼트 높이를 모두 고정 픽셀로 계산 — Expanded/FractionallySizedBox 가
    // loose 제약에서 0으로 무너지는 문제를 피한다. 차트 영역 130 − 라벨/gap ≈ 100.
    const maxBar = 100.0;
    final barH = total > 0 ? (total / maxDay * maxBar).clamp(4.0, maxBar) : 0.0;
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final n in names)
                Container(
                  width: 24,
                  height: (segs[n]! / total * barH).clamp(1.0, barH),
                  color: ActivityStatsService.colorFor(
                    n,
                  ).withAlpha(sel == null || sel == n ? 0xFF : 0x2E),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isToday ? AppColors.accent : AppColors.faint,
            fontSize: 11.5,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String name;
  final bool on;
  final VoidCallback onTap;
  const _LegendChip({
    required this.name,
    required this.on,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: on ? 1 : 0.3,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: ActivityStatsService.colorFor(name),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          name,
          style: TextStyle(
            color: on ? AppColors.muted : AppColors.faint,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

class _ActivityRow extends StatelessWidget {
  final String name;
  final int ms;
  final int sessions;
  final double pct;
  final bool on;
  final VoidCallback onTap;
  const _ActivityRow({
    required this.name,
    required this.ms,
    required this.sessions,
    required this.pct,
    required this.on,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final color = ActivityStatsService.colorFor(name);
    final totalMin = ms ~/ 60000;
    final dur = totalMin >= 60
        ? l.statsHoursMin(totalMin ~/ 60, totalMin % 60)
        : l.statsMinOnly(totalMin);
    return Opacity(
      opacity: on ? 1 : 0.45,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFF161618),
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(11),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    l.statsSessionsN(sessions),
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    dur,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        minHeight: 6,
                        backgroundColor: AppColors.bg,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 34,
                    child: Text(
                      '${pct.round()}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: AppColors.faint, fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
