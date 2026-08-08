import 'dart:async';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'workout_models.dart';
import 'workout_screen.dart' show exerciseDisplayName, exerciseSummary;
import 'workout_session.dart';
import 'workout_voice.dart';

/// 운동 실행 화면(디자인 "운동 TTS 모드" 가운데 폰) — 4상태 + 캡션 + 컨트롤.
class WorkoutRunScreen extends StatefulWidget {
  final String routineName;
  final List<WorkoutExercise> items;
  final WorkoutConfig config;
  const WorkoutRunScreen({
    super.key,
    required this.routineName,
    required this.items,
    required this.config,
  });

  @override
  State<WorkoutRunScreen> createState() => _WorkoutRunScreenState();
}

class _WorkoutRunScreenState extends State<WorkoutRunScreen> {
  late final WorkoutVoice _voice;
  WorkoutSession? _session;
  String _caption = '';
  Timer? _captionClear;
  StreamSubscription<String>? _capSub;

  @override
  void initState() {
    super.initState();
    _voice = WorkoutVoice();
    _capSub = _voice.captions.stream.listen((t) {
      setState(() => _caption = t);
      _captionClear?.cancel();
      _captionClear = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _caption = '');
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_session == null) {
      final l = AppLocalizations.of(context);
      _voice.localeTag = Localizations.localeOf(context).toLanguageTag();
      _voice.tone = widget.config.tone;
      _voice.duckEnabled = widget.config.duck;
      _session =
          WorkoutSession(
            voice: _voice,
            config: widget.config,
            exerciseName: (k) => exerciseDisplayName(l, k),
            script: WorkoutScript(
              setStart: (n, s, r) => l.wsSetStart(n, s, r),
              setStartAgain: (s) => l.wsSetStartAgain(s),
              timeStart: (n, d) => l.wsTimeStart(n, d),
              freeStart: (n) => l.wsFreeStart(n),
              lastSetCheer: l.wsLastSet,
              halfway: l.wsHalfway,
              tenLeft: l.wsTenLeft,
              setDoneRest: (s, r) => l.wsSetDoneRest(s, r),
              exerciseDoneRest: (n, r) => l.wsExDoneRest(n, r),
              nextExercise: (n, a) => l.wsNextEx(n, a),
              nextSet: (s) => l.wsNextSet(s),
              allDone: l.wsAllDone,
              amountTime: (d) => l.wsAmountTime(d),
              amountReps: (r) => l.wsAmountReps(r),
              amountFree: l.wsAmountFree,
            ),
          )..addListener(() {
            if (mounted) setState(() {});
          });
    }
  }

  @override
  void dispose() {
    _captionClear?.cancel();
    _capSub?.cancel();
    _session?.stop();
    _session?.dispose();
    _voice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = _session!;
    final ex = s.current;

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
        title: Text(
          s.phase == WorkoutPhase.idle
              ? widget.routineName
              : s.phase == WorkoutPhase.done
              ? l.workoutDoneTitle
              : '${s.exIdx + 1}/${widget.items.length} · ${ex == null ? '' : exerciseDisplayName(l, ex.libKey)}',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Center(child: _phaseView(l, s, ex))),
            SizedBox(
              height: 52,
              child: Center(
                child: _caption.isEmpty
                    ? null
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha(0x1A),
                          border: Border.all(
                            color: AppColors.accent.withAlpha(0x40),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '🗣 “$_caption”',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                children: [
                  if (s.running) ...[
                    Expanded(
                      child: _BigBtn(
                        label: '■ ${l.workoutStop}',
                        color: AppColors.danger,
                        onTap: () {
                          s.stop();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _BigBtn(
                        label: '${l.workoutSkip} ▶',
                        color: AppColors.text,
                        onTap: s.skip,
                      ),
                    ),
                  ],
                  if (s.phase == WorkoutPhase.done)
                    Expanded(
                      child: _BigBtn(
                        label: l.workoutBackToStart,
                        color: const Color(0xFF111111),
                        filled: true,
                        onTap: s.stop,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _phaseView(AppLocalizations l, WorkoutSession s, WorkoutExercise? ex) {
    switch (s.phase) {
      case WorkoutPhase.idle:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.items.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${i + 1}. ${exerciseDisplayName(l, widget.items[i].libKey)} — ${exerciseSummary(l, widget.items[i])}',
                  style: TextStyle(color: AppColors.muted, fontSize: 13.5),
                ),
              ),
            const SizedBox(height: 24),
            Material(
              color: AppColors.accent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => s.start(widget.items),
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Center(
                    child: Text(
                      '${l.workoutStart} ▶',
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l.workoutTtsNote,
              style: TextStyle(color: AppColors.faint, fontSize: 11),
            ),
          ],
        );
      case WorkoutPhase.work:
        if (ex == null) return const SizedBox.shrink();
        switch (ex.type) {
          case WorkoutType.reps:
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.workoutSetProgress(s.set, ex.sets),
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  s.rep > 0 ? '${s.rep}' : '–',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 120,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  l.workoutRepOf(ex.reps),
                  style: TextStyle(color: AppColors.faint, fontSize: 13),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 240,
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    alignment: WrapAlignment.center,
                    children: [
                      for (var i = 0; i < ex.reps; i++)
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < s.rep
                                ? const Color(0xFF52E08E)
                                : const Color(0xFF333333),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          case WorkoutType.free:
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.workoutFreeCount,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  s.rep > 0 ? '${s.rep}' : '–',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 120,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  l.workoutFreeHint,
                  style: TextStyle(color: AppColors.faint, fontSize: 12),
                ),
              ],
            );
          case WorkoutType.time:
            return _gauge(
              label: l.workoutHold,
              color: const Color(0xFF52E08E),
              t: s.t,
              total: s.total,
            );
        }
      case WorkoutPhase.rest:
        final nx = ex != null && ex.type == WorkoutType.reps && s.set < ex.sets
            ? '${exerciseDisplayName(l, ex.libKey)} ${s.set + 1}'
            : (s.exIdx + 1 < widget.items.length
                  ? exerciseDisplayName(l, widget.items[s.exIdx + 1].libKey)
                  : l.workoutDoneTitle);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _gauge(
              label: l.workoutRestLabel,
              color: const Color(0xFF52B0E0),
              t: s.t,
              total: s.total,
            ),
            const SizedBox(height: 8),
            Text(
              l.workoutNextLabel(nx),
              style: TextStyle(color: AppColors.faint, fontSize: 12.5),
            ),
          ],
        );
      case WorkoutPhase.done:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '✓',
              style: TextStyle(
                color: AppColors.swGreen,
                fontSize: 64,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.workoutDoneTitle,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              l.workoutDoneCount(widget.items.length),
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        );
    }
  }

  Widget _gauge({
    required String label,
    required Color color,
    required int t,
    required int total,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: CircularProgressIndicator(
                value: total > 0 ? t / total : 0,
                strokeWidth: 9,
                backgroundColor: const Color(0xFF2A2A2E),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            Text(
              '$t',
              style: TextStyle(
                color: label == 'Rest' || label == '휴식'
                    ? const Color(0xFF52B0E0)
                    : AppColors.text,
                fontSize: 56,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _BigBtn extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  const _BigBtn({
    required this.label,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: filled ? AppColors.accent : const Color(0xFF232326),
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: filled ? null : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ),
  );
}
