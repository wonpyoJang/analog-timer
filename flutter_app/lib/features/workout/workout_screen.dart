import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../services/persistence_service.dart';
import 'workout_models.dart';
import 'workout_run_screen.dart';

/// 운동 이름 — libKey → 로케일 표시 이름.
String exerciseDisplayName(AppLocalizations l, String libKey) =>
    switch (libKey) {
      'squat' => l.exSquat,
      'pushup' => l.exPushup,
      'lunge' => l.exLunge,
      'burpee' => l.exBurpee,
      'crunch' => l.exCrunch,
      'plank' => l.exPlank,
      'wallsit' => l.exWallsit,
      'pullup' => l.exPullup,
      _ => libKey,
    };

/// 항목 표시 이름 — 커스텀 이름 우선.
String exerciseName(AppLocalizations l, WorkoutExercise it) =>
    it.customName ?? exerciseDisplayName(l, it.libKey);

String exerciseSummary(AppLocalizations l, WorkoutExercise it) =>
    switch (it.type) {
      WorkoutType.time => l.workoutSummaryTime(it.dur),
      WorkoutType.free => l.workoutSummaryFree('${it.pace}'),
      WorkoutType.reps => l.workoutSummaryReps(it.sets, it.reps, '${it.pace}'),
    };

/// 운동 TTS 모드 — 루틴 빌더(디자인 "운동 TTS 모드" 왼쪽 폰).
class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  List<WorkoutRoutine> _routines = [];
  String? _activeId;
  String? _openItemId;
  WorkoutConfig _cfg = WorkoutConfig();
  List<WorkoutLibEntry> _customLib = [];

  /// 커스텀 운동 작성 폼 상태 — null 이면 닫힘.
  String? _customName;
  WorkoutType _customType = WorkoutType.reps;
  bool _customOpen = false;
  bool _loaded = false;

  WorkoutRoutine? get _active =>
      _routines.where((r) => r.id == _activeId).firstOrNull ??
      _routines.firstOrNull;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await PersistenceService.loadWorkoutRoutines();
    final cfgRaw = await PersistenceService.loadWorkoutConfig();
    final customRaw = await PersistenceService.loadWorkoutCustomLib();
    if (!mounted) return;
    setState(() {
      _loaded = true;
      if (cfgRaw != null) _cfg = WorkoutConfig.fromJson(cfgRaw);
      if (raw != null) {
        _routines = raw.map(WorkoutRoutine.fromJson).toList();
      } else {
        // 첫 실행 시드 — 시안의 "아침 루틴"/"전신 서킷".
        _routines = [
          WorkoutRoutine(
            id: 'r1',
            name: '',
            items: [
              workoutLibrary[0].instantiate(),
              workoutLibrary[5].instantiate(),
            ],
          ),
        ];
      }
      _activeId = _routines.firstOrNull?.id;
      if (customRaw != null) {
        _customLib = customRaw.map(WorkoutLibEntry.fromJson).toList();
      }
    });
  }

  void _persist() {
    PersistenceService.saveWorkoutRoutines(
      _routines.map((r) => r.toJson()).toList(),
    );
    PersistenceService.saveWorkoutConfig(_cfg.toJson());
  }

  void _patchActive(WorkoutRoutine Function(WorkoutRoutine) f) {
    final a = _active;
    if (a == null) return;
    setState(() {
      _routines = _routines.map((r) => r.id == a.id ? f(r) : r).toList();
    });
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final active = _active;
    final items = active?.items ?? const <WorkoutExercise>[];
    final routineName = (active?.name.isNotEmpty ?? false)
        ? active!.name
        : l.workoutRoutineN(
            _routines.indexWhere((r) => r.id == active?.id) + 1,
          );

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          l.workoutMyRoutines,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: items.isEmpty || !_loaded
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.accent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkoutRunScreen(
                      routineName: routineName,
                      items: items,
                      config: _cfg,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow, color: Colors.black),
              label: Text(
                l.workoutStart,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
      body: !_loaded
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              children: [
                // 루틴 선택 칩
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final r in _routines)
                      _RoutineChip(
                        label:
                            '${r.name.isNotEmpty ? r.name : l.workoutRoutineN(_routines.indexOf(r) + 1)} ${r.items.length}',
                        selected: r.id == _activeId,
                        onTap: () => setState(() {
                          _activeId = r.id;
                          _openItemId = null;
                        }),
                      ),
                    _RoutineChip(
                      label: l.workoutNewRoutine,
                      dashed: true,
                      onTap: () {
                        final nr = WorkoutRoutine(
                          id: 'r${DateTime.now().microsecondsSinceEpoch}',
                          name: '',
                        );
                        setState(() {
                          _routines = [..._routines, nr];
                          _activeId = nr.id;
                        });
                        _persist();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 루틴 이름 + 삭제
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: ValueKey(_activeId),
                        initialValue: active?.name ?? '',
                        onChanged: (v) =>
                            _patchActive((r) => r.copyWith(name: v)),
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: routineName,
                          hintStyle: TextStyle(color: AppColors.faint),
                          filled: true,
                          fillColor: const Color(0xFF232326),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    if (_routines.length > 1)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: AppColors.danger,
                        ),
                        onPressed: () {
                          setState(() {
                            _routines = _routines
                                .where((r) => r.id != _activeId)
                                .toList();
                            _activeId = _routines.first.id;
                            _openItemId = null;
                          });
                          _persist();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // 루틴 항목들
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Text(
                      l.workoutEmptyRoutine,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.faint, fontSize: 13),
                    ),
                  ),
                for (var i = 0; i < items.length; i++)
                  _ExerciseCard(
                    index: i,
                    item: items[i],
                    total: items.length,
                    open: _openItemId == items[i].id,
                    onToggleOpen: () => setState(() {
                      _openItemId = _openItemId == items[i].id
                          ? null
                          : items[i].id;
                    }),
                    onMove: (d) {
                      final j = i + d;
                      if (j < 0 || j >= items.length) return;
                      _patchActive((r) {
                        final n = List.of(r.items);
                        final tmp = n[i];
                        n[i] = n[j];
                        n[j] = tmp;
                        return r.copyWith(items: n);
                      });
                    },
                    onRemove: () => _patchActive(
                      (r) => r.copyWith(
                        items: r.items
                            .where((x) => x.id != items[i].id)
                            .toList(),
                      ),
                    ),
                    onPatch: (p) => _patchActive(
                      (r) => r.copyWith(
                        items: r.items
                            .map((x) => x.id == items[i].id ? p : x)
                            .toList(),
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                // 라이브러리
                Text.rich(
                  TextSpan(
                    text: l.workoutLibrary,
                    style: TextStyle(
                      color: AppColors.faint,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: ' — ${l.workoutLibraryHint}',
                        style: const TextStyle(fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final e in [...workoutLibrary, ..._customLib])
                      _RoutineChip(
                        label:
                            '＋ ${e.customName ?? exerciseDisplayName(l, e.libKey)} ${e.type == WorkoutType.time
                                ? '${e.dur}s'
                                : e.type == WorkoutType.free
                                ? '∞'
                                : '${e.pace}s'}',
                        custom: e.isCustom,
                        onTap: () => _patchActive(
                          (r) =>
                              r.copyWith(items: [...r.items, e.instantiate()]),
                        ),
                      ),
                    _RoutineChip(
                      label: l.workoutCustomAdd,
                      dashed: true,
                      onTap: () => setState(() {
                        _customOpen = true;
                        _customName = '';
                        _customType = WorkoutType.reps;
                      }),
                    ),
                  ],
                ),
                if (_customOpen) ...[
                  const SizedBox(height: 10),
                  _CustomExerciseCard(
                    name: _customName ?? '',
                    type: _customType,
                    onName: (v) => setState(() => _customName = v),
                    onType: (t) => setState(() => _customType = t),
                    onCancel: () => setState(() => _customOpen = false),
                    onCreate: () {
                      final nm = (_customName ?? '').trim();
                      if (nm.isEmpty) return;
                      final entry = WorkoutLibEntry(
                        'custom',
                        _customType,
                        customName: nm,
                      );
                      setState(() {
                        _customLib = [..._customLib, entry];
                        _customOpen = false;
                      });
                      PersistenceService.saveWorkoutCustomLib(
                        _customLib.map((e) => e.toJson()).toList(),
                      );
                      _patchActive(
                        (r) => r.copyWith(
                          items: [...r.items, entry.instantiate()],
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 16),
                // 휴식·톤·말해줄 것·덕킹
                _Section(
                  children: [
                    _CfgRow(
                      label: l.workoutRest,
                      sub: l.workoutRestCommon,
                      child: _Stepper(
                        value: _cfg.restSec.toDouble(),
                        min: 5,
                        max: 90,
                        step: 5,
                        suffix: 's',
                        onChanged: (v) {
                          setState(() => _cfg.restSec = v.round());
                          _persist();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  l.workoutVoiceTone,
                  style: TextStyle(
                    color: AppColors.faint,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _SegButtons(
                  options: {
                    'coach': l.workoutToneCoach,
                    'calm': l.workoutToneCalm,
                  },
                  value: _cfg.tone,
                  onChanged: (v) {
                    setState(() => _cfg.tone = v);
                    _persist();
                  },
                ),
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    text: l.workoutSpeakSection,
                    style: TextStyle(
                      color: AppColors.faint,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: ' — ${l.workoutSpeakAllOff}',
                        style: const TextStyle(fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _Section(
                  children: [
                    _CfgRow(
                      label: l.workoutSayCount,
                      sub: l.workoutSayCountSub,
                      child: _Toggle(
                        on: _cfg.sayCount,
                        onChanged: (v) {
                          setState(() => _cfg.sayCount = v);
                          _persist();
                        },
                      ),
                    ),
                    _CfgRow(
                      label: l.workoutSaySetAnn,
                      child: _Toggle(
                        on: _cfg.saySetAnnounce,
                        onChanged: (v) {
                          setState(() => _cfg.saySetAnnounce = v);
                          _persist();
                        },
                      ),
                    ),
                    _CfgRow(
                      label: l.workoutSayCallout,
                      child: _Toggle(
                        on: _cfg.sayCallout,
                        onChanged: (v) {
                          setState(() => _cfg.sayCallout = v);
                          _persist();
                        },
                      ),
                    ),
                    _CfgRow(
                      label: l.workoutSayCountdown,
                      child: _Toggle(
                        on: _cfg.sayCountdown,
                        onChanged: (v) {
                          setState(() => _cfg.sayCountdown = v);
                          _persist();
                        },
                      ),
                    ),
                    _CfgRow(
                      label: l.workoutSayPreview,
                      child: _Toggle(
                        on: _cfg.sayPreview,
                        onChanged: (v) {
                          setState(() => _cfg.sayPreview = v);
                          _persist();
                        },
                      ),
                    ),
                    _CfgRow(
                      label: l.workoutSayCheer,
                      sub: l.workoutSayCheerSub,
                      child: _Toggle(
                        on: _cfg.sayCheer,
                        onChanged: (v) {
                          setState(() => _cfg.sayCheer = v);
                          _persist();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _Section(
                  children: [
                    _CfgRow(
                      label: l.workoutDucking,
                      sub: l.workoutDuckingSub,
                      child: _Toggle(
                        on: _cfg.duck,
                        onChanged: (v) {
                          setState(() => _cfg.duck = v);
                          _persist();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final int index;
  final int total;
  final WorkoutExercise item;
  final bool open;
  final VoidCallback onToggleOpen;
  final void Function(int) onMove;
  final VoidCallback onRemove;
  final void Function(WorkoutExercise) onPatch;
  const _ExerciseCard({
    required this.index,
    required this.total,
    required this.item,
    required this.open,
    required this.onToggleOpen,
    required this.onMove,
    required this.onRemove,
    required this.onPatch,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: open ? AppColors.accent : AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                children: [
                  _MoveBtn(
                    up: true,
                    enabled: index > 0,
                    onTap: () => onMove(-1),
                  ),
                  _MoveBtn(
                    up: false,
                    enabled: index < total - 1,
                    onTap: () => onMove(1),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: InkWell(
                  onTap: onToggleOpen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ${exerciseName(l, item)}',
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        exerciseSummary(l, item),
                        style: TextStyle(
                          color: AppColors.faint,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 18, color: AppColors.danger),
                onPressed: onRemove,
              ),
            ],
          ),
          if (open) ...[
            const Divider(height: 12, color: Color(0xFF1F1F22)),
            if (item.type == WorkoutType.reps) ...[
              _CfgRow(
                label: l.workoutSets,
                child: _Stepper(
                  value: item.sets.toDouble(),
                  min: 1,
                  max: 8,
                  step: 1,
                  onChanged: (v) => onPatch(item.copyWith(sets: v.round())),
                ),
              ),
              _CfgRow(
                label: l.workoutReps,
                child: _Stepper(
                  value: item.reps.toDouble(),
                  min: 3,
                  max: 30,
                  step: 1,
                  onChanged: (v) => onPatch(item.copyWith(reps: v.round())),
                ),
              ),
              _CfgRow(
                label: l.workoutPace,
                child: _Stepper(
                  value: item.pace,
                  min: 0.8,
                  max: 5,
                  step: 0.5,
                  suffix: 's',
                  onChanged: (v) => onPatch(item.copyWith(pace: v)),
                ),
              ),
            ],
            if (item.type == WorkoutType.time)
              _CfgRow(
                label: l.workoutHoldTime,
                child: _Stepper(
                  value: item.dur.toDouble(),
                  min: 10,
                  max: 180,
                  step: 5,
                  suffix: 's',
                  onChanged: (v) => onPatch(item.copyWith(dur: v.round())),
                ),
              ),
            if (item.type == WorkoutType.free)
              _CfgRow(
                label: l.workoutPace,
                sub: l.workoutPaceFreeSub,
                child: _Stepper(
                  value: item.pace,
                  min: 0.8,
                  max: 5,
                  step: 0.5,
                  suffix: 's',
                  onChanged: (v) => onPatch(item.copyWith(pace: v)),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _MoveBtn extends StatelessWidget {
  final bool up;
  final bool enabled;
  final VoidCallback onTap;
  const _MoveBtn({
    required this.up,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: enabled ? onTap : null,
    child: Icon(
      up ? Icons.arrow_drop_up : Icons.arrow_drop_down,
      size: 20,
      color: enabled ? AppColors.muted : const Color(0xFF3A3A3E),
    ),
  );
}

class _RoutineChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool dashed;

  /// 커스텀 운동 — 녹색 뉘앙스로 구분(시안).
  final bool custom;
  final VoidCallback onTap;
  const _RoutineChip({
    required this.label,
    required this.onTap,
    this.selected = false,
    this.dashed = false,
    this.custom = false,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: selected
        ? AppColors.accent.withAlpha(0x1A)
        : custom
        ? const Color(0xFF52E08E).withAlpha(0x12)
        : dashed
        ? Colors.transparent
        : const Color(0xFF232326),
    borderRadius: BorderRadius.circular(11),
    child: InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? AppColors.accent
                : dashed
                ? AppColors.faint
                : AppColors.text,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  final List<Widget> children;
  const _Section({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(children: children),
  );
}

class _CfgRow extends StatelessWidget {
  final String label;
  final String? sub;
  final Widget child;
  const _CfgRow({required this.label, this.sub, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFF1F1F22))),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (sub != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    sub!,
                    style: TextStyle(color: AppColors.faint, fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
        child,
      ],
    ),
  );
}

class _Toggle extends StatelessWidget {
  final bool on;
  final void Function(bool) onChanged;
  const _Toggle({required this.on, required this.onChanged});

  @override
  Widget build(BuildContext context) => Switch(
    value: on,
    onChanged: onChanged,
    activeThumbColor: AppColors.swGreen,
  );
}

class _Stepper extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final double step;
  final String suffix;
  final void Function(double) onChanged;
  const _Stepper({
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    this.suffix = '',
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isInt =
        step == step.roundToDouble() && value == value.roundToDouble();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn(
          '−',
          () => onChanged(((value - step).clamp(min, max) * 10).round() / 10),
        ),
        SizedBox(
          width: 52,
          child: Text(
            '${isInt ? value.round() : value}$suffix',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _btn(
          '＋',
          () => onChanged(((value + step).clamp(min, max) * 10).round() / 10),
        ),
      ],
    );
  }

  Widget _btn(String s, VoidCallback onTap) => Material(
    color: const Color(0xFF232326),
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: SizedBox(
        width: 30,
        height: 30,
        child: Center(
          child: Text(
            s,
            style: const TextStyle(color: AppColors.text, fontSize: 14),
          ),
        ),
      ),
    ),
  );
}

class _SegButtons extends StatelessWidget {
  final Map<String, String> options;
  final String value;
  final void Function(String) onChanged;
  const _SegButtons({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFF232326),
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        for (final e in options.entries)
          Expanded(
            child: Material(
              color: value == e.key ? AppColors.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              child: InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: () => onChanged(e.key),
                child: SizedBox(
                  height: 36,
                  child: Center(
                    child: Text(
                      e.value,
                      style: TextStyle(
                        color: value == e.key
                            ? const Color(0xFF111111)
                            : AppColors.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// 커스텀 운동 작성 카드(시안) — 이름 + 유형 세그 + 안내 + 취소/만들고 추가.
class _CustomExerciseCard extends StatelessWidget {
  final String name;
  final WorkoutType type;
  final ValueChanged<String> onName;
  final ValueChanged<WorkoutType> onType;
  final VoidCallback onCancel;
  final VoidCallback onCreate;
  const _CustomExerciseCard({
    required this.name,
    required this.type,
    required this.onName,
    required this.onType,
    required this.onCancel,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const green = Color(0xFF52E08E);
    final desc = switch (type) {
      WorkoutType.reps => l.workoutCustomRepsDesc,
      WorkoutType.time => l.workoutCustomTimeDesc,
      WorkoutType.free => l.workoutCustomFreeDesc,
    };
    final canCreate = name.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: green),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.workoutCustomTitle,
            style: const TextStyle(
              color: green,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            autofocus: true,
            initialValue: name,
            onChanged: onName,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: l.workoutCustomNameHint,
              hintStyle: TextStyle(color: AppColors.faint),
              filled: true,
              fillColor: const Color(0xFF232326),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _SegButtons(
            options: {
              'reps': l.workoutTypeReps,
              'time': l.workoutTypeTime,
              'free': l.workoutTypeFree,
            },
            value: type.name,
            onChanged: (v) => onType(
              WorkoutType.values.firstWhere((t) => t.name == v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              desc,
              style: TextStyle(color: AppColors.faint, fontSize: 11),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: onCancel,
                  child: Text(
                    l.workoutCustomCancel,
                    style: TextStyle(color: AppColors.muted, fontSize: 12.5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: canCreate ? green : const Color(0xFF3A3A3E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: canCreate ? onCreate : null,
                  child: Text(
                    l.workoutCustomCreate,
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
