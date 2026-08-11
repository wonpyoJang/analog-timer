import 'dart:async';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../services/water_reminder_service.dart';
import '../../services/notification_service.dart';
import '../../services/sound_service.dart';
import '../../services/haptic_service.dart';

const _c2 = Color(0xFF52B0E0); // 물 색(디자인 --c2)

String _fmtHm(int minOfDay) {
  final h = minOfDay ~/ 60, m = minOfDay % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

/// 물 마시기 알림 설정(디자인 §1).
class WaterSettingsPage extends StatefulWidget {
  const WaterSettingsPage({super.key});
  @override
  State<WaterSettingsPage> createState() => _WaterSettingsPageState();
}

class _WaterSettingsPageState extends State<WaterSettingsPage> {
  final _s = WaterReminderService.instance;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: Text(l.waterTitle),
        actions: [
          // 마스터 on/off
          ValueListenableBuilder<bool>(
            valueListenable: _s.enabled,
            builder: (_, on, _) => Switch(
              value: on,
              activeColor: _c2,
              onChanged: (v) => _s.setEnabled(v),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _progress(l),
          _group(l.waterWhenGroup, [
            _intervalRow(l),
            _fixedRow(l),
            _activeRow(l),
            _switchRow(
              l.waterWithTimer,
              l.waterWithTimerSub,
              _s.withTimerEnd,
              _s.setWithTimerEnd,
            ),
          ]),
          _group(l.waterHowGroup, [_intensityRow(l), _goalRow(l)]),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
            child: Text(
              l.waterNote,
              style: TextStyle(
                color: AppColors.faint,
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              l.waterBgNote,
              style: TextStyle(
                color: AppColors.faint,
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ),
          // 개발 검증용(release 숨김) — 알림 권한 요청 + 즉시 알림으로 플러그인 확인.
          if (!kReleaseMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: OutlinedButton(
                onPressed: () async {
                  await NotificationService.instance.requestPermission();
                  // +8초 예약 — 실제 물 예약(zonedSchedule)과 동일 경로 검증용.
                  await NotificationService.instance.scheduleAt(
                    900001,
                    l.waterBannerTitle,
                    l.waterNotifBody,
                    DateTime.now().add(const Duration(seconds: 8)),
                  );
                },
                child: const Text('테스트 예약 +8초 (debug)'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _progress(AppLocalizations l) => ValueListenableBuilder<int>(
    valueListenable: _s.todayCount,
    builder: (_, count, _) => ValueListenableBuilder<int>(
      valueListenable: _s.dailyGoal,
      builder: (_, goal, _) => Container(
        margin: const EdgeInsets.fromLTRB(20, 18, 20, 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _c2.withValues(alpha: 0.08),
          border: Border.all(color: _c2.withValues(alpha: 0.28)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l.waterToday,
                  style: const TextStyle(
                    color: _c2,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  l.waterCups(count, goal),
                  style: const TextStyle(
                    color: _c2,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (var i = 0; i < goal; i++)
                  Container(
                    width: 22,
                    height: 28,
                    decoration: BoxDecoration(
                      color: i < count
                          ? _c2.withValues(alpha: 0.35)
                          : const Color(0xFF26262A),
                      border: Border.all(
                        color: i < count ? _c2 : const Color(0xFF35353A),
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(3),
                        bottom: Radius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _group(String head, List<Widget> rows) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Text(
          head,
          style: TextStyle(
            color: AppColors.faint,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: Color(0xFF1F1F22)),
              rows[i],
            ],
          ],
        ),
      ),
    ],
  );

  Widget _rowShell(String title, String? sub, Widget trailing) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (sub != null) ...[
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(
                    color: AppColors.faint,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        trailing,
      ],
    ),
  );

  Widget _seg(
    List<({String label, bool on, VoidCallback onTap})> items,
  ) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF141416),
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final it in items)
          GestureDetector(
            onTap: it.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: it.on ? _c2.withValues(alpha: 0.16) : Colors.transparent,
              child: Text(
                it.label,
                style: TextStyle(
                  color: it.on ? _c2 : AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _intervalRow(AppLocalizations l) => ValueListenableBuilder<int>(
    valueListenable: _s.intervalMin,
    builder: (_, iv, _) => _rowShell(
      l.waterInterval,
      null,
      _seg([
        (label: '45m', on: iv == 45, onTap: () => _s.setInterval(45)),
        (label: '1h', on: iv == 60, onTap: () => _s.setInterval(60)),
        (label: '2h', on: iv == 120, onTap: () => _s.setInterval(120)),
      ]),
    ),
  );

  Widget _fixedRow(AppLocalizations l) => ValueListenableBuilder<bool>(
    valueListenable: _s.fixedEnabled,
    builder: (_, on, _) => ValueListenableBuilder<List<int>>(
      valueListenable: _s.fixedTimes,
      builder: (_, times, _) => _rowShell(
        l.waterFixed,
        times.map(_fmtHm).join(' · '),
        _switch(on, _s.setFixedEnabled),
      ),
    ),
  );

  Widget _activeRow(AppLocalizations l) => ValueListenableBuilder<int>(
    valueListenable: _s.activeStartMin,
    builder: (_, st, _) => ValueListenableBuilder<int>(
      valueListenable: _s.activeEndMin,
      builder: (_, en, _) => InkWell(
        onTap: () => _pickActiveHours(st, en),
        child: _rowShell(
          l.waterActiveHours,
          null,
          Text(
            '${_fmtHm(st)} – ${_fmtHm(en)} ›',
            style: TextStyle(
              color: AppColors.faint,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _intensityRow(AppLocalizations l) => ValueListenableBuilder<bool>(
    valueListenable: _s.sound,
    builder: (_, snd, _) => _rowShell(
      l.waterIntensity,
      l.waterIntensitySub,
      _seg([
        (label: l.waterBannerMode, on: !snd, onTap: () => _s.setSound(false)),
        (label: l.waterOneSound, on: snd, onTap: () => _s.setSound(true)),
      ]),
    ),
  );

  Widget _goalRow(AppLocalizations l) => ValueListenableBuilder<int>(
    valueListenable: _s.dailyGoal,
    builder: (_, g, _) => InkWell(
      onTap: () => _pickGoal(g),
      child: _rowShell(
        l.waterGoal,
        null,
        Text(
          '${l.waterGoalCups(g)} ›',
          style: TextStyle(
            color: AppColors.faint,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );

  Widget _switchRow(
    String title,
    String? sub,
    ValueNotifier<bool> vn,
    ValueChanged<bool> onCh,
  ) => ValueListenableBuilder<bool>(
    valueListenable: vn,
    builder: (_, on, _) => _rowShell(title, sub, _switch(on, onCh)),
  );

  Widget _switch(bool on, ValueChanged<bool> onCh) =>
      Switch(value: on, activeColor: _c2, onChanged: onCh);

  Future<void> _pickActiveHours(int st, int en) async {
    final start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: st ~/ 60, minute: st % 60),
      helpText: AppLocalizations.of(context).waterActiveHours,
    );
    if (start == null || !mounted) return;
    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: en ~/ 60, minute: en % 60),
      helpText: AppLocalizations.of(context).waterActiveHours,
    );
    if (end == null) return;
    await _s.setActiveHours(
      start.hour * 60 + start.minute,
      end.hour * 60 + end.minute,
    );
  }

  Future<void> _pickGoal(int cur) async {
    final l = AppLocalizations.of(context);
    final g = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final n in [4, 6, 8, 10, 12])
              ListTile(
                title: Text(
                  l.waterGoalCups(n),
                  style: const TextStyle(color: AppColors.text),
                ),
                trailing: n == cur ? const Icon(Icons.check, color: _c2) : null,
                onTap: () => Navigator.pop(ctx, n),
              ),
          ],
        ),
      ),
    );
    if (g != null) await _s.setGoal(g);
  }
}

// ── 물 알림 배너(디자인 §2) ──────────────────────────────────────────────
// 가장 가벼운 알람: 탭=한 잔 기록+사라짐, 20초 자동소멸, 재알림 없음, 무시해도
// 카운트 불변. 인앱 트리거(앱 실행 중)로만 표시.
bool _bannerShowing = false;

Future<void> showWaterBanner(BuildContext context) async {
  if (_bannerShowing) return;
  final s = WaterReminderService.instance;
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final next = await s.nextReminderMs();
  final nextStr = next == null
      ? '—'
      : _fmtHm(
          DateTime.fromMillisecondsSinceEpoch(next).hour * 60 +
              DateTime.fromMillisecondsSinceEpoch(next).minute,
        );
  if (!context.mounted) return;

  if (s.sound.value) SoundService.instance.play('done');
  HapticService.instance.light();

  _bannerShowing = true;
  Timer? auto;
  void close() {
    auto?.cancel();
    messenger.hideCurrentMaterialBanner();
    _bannerShowing = false;
  }

  messenger.showMaterialBanner(
    MaterialBanner(
      backgroundColor: AppColors.surface,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _c2.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.local_drink_outlined, color: _c2, size: 20),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.waterBannerTitle,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l.waterBannerSub(s.todayCount.value, nextStr),
            style: TextStyle(color: AppColors.faint, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            close();
            await s.recordCup();
          },
          child: Text(
            l.waterDrank,
            style: const TextStyle(color: _c2, fontWeight: FontWeight.w700),
          ),
        ),
        TextButton(
          onPressed: () async {
            close();
            await s.snooze30(); // 30분 뒤 다시
          },
          child: Text(l.waterLater30, style: TextStyle(color: AppColors.muted)),
        ),
        TextButton(
          onPressed: () async {
            close();
            await s.muteToday();
          },
          child: Text(
            l.waterStopToday,
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      ],
    ),
  );
  // 알림이 울렸으니 이번 슬롯 소비 — 즉시 재알림 방지("재알림 없음").
  await s.markReminded();
  // 20초 방치 시 자동 소멸(카운트 불변).
  auto = Timer(const Duration(seconds: 20), close);
}
