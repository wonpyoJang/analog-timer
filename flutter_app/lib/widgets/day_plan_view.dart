import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/daily_record_service.dart';
import '../services/persistence_service.dart';
import '../features/timer/models/preset.dart';
import '../features/timer/models/segment.dart';
import '../features/timer/bloc/timer_bloc.dart';
import '../features/timer/bloc/timer_event.dart';
import '../features/timer/widgets/color_picker_dialog.dart';
import '../features/timer/widgets/preset_manage_page.dart';

class DayPlanView extends StatefulWidget {
  final DateTime date;
  const DayPlanView({super.key, required this.date});

  @override
  State<DayPlanView> createState() => _DayPlanViewState();
}

class _DayPlanViewState extends State<DayPlanView> {
  List<Segment>? _segments;
  bool _loading = true;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(DayPlanView old) {
    super.didUpdateWidget(old);
    if (old.date.day != widget.date.day ||
        old.date.month != widget.date.month ||
        old.date.year != widget.date.year) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _dirty = false;
    });
    final plan = await DailyRecordService.loadPlan(widget.date);
    if (mounted) {
      setState(() {
        _segments = plan ?? [];
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final segs = _segments;
    if (segs == null) return;
    await DailyRecordService.savePlan(widget.date, segs);
    if (mounted) setState(() => _dirty = false);
  }

  Future<void> _loadIntoTimer() async {
    await _save();
    if (!mounted) return;
    final segs = _segments;
    if (segs == null || segs.isEmpty) return;
    context.read<TimerBloc>().add(TimerSegmentsReplaced(segs));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).planLoadIntoTimer),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _appendPreset(List<Segment> segs) {
    setState(() {
      _segments = [...(_segments ?? []), ...segs];
      _dirty = true;
    });
  }

  void _addSegment() {
    final segs = _segments ?? [];
    final newSeg = Segment(
      name: 'Task',
      minutes: 5,
      color: AppColors.segColors[segs.length % AppColors.segColors.length],
    );
    setState(() {
      _segments = [...segs, newSeg];
      _dirty = true;
    });
  }

  void _removeSegment(int index) {
    final segs = List<Segment>.from(_segments ?? []);
    segs.removeAt(index);
    setState(() {
      _segments = segs;
      _dirty = true;
    });
  }

  void _updateSegment(int index, Segment updated) {
    final segs = List<Segment>.from(_segments ?? []);
    segs[index] = updated;
    setState(() {
      _segments = segs;
      _dirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l.dayPlanTitle,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              if (_dirty)
                GestureDetector(
                  onTap: _save,
                  child: Text(
                    l.planSave,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 10,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (!_loading)
            _PlanPresetBar(
              currentSegments: _segments ?? [],
              onAppend: _appendPreset,
            ),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            if (_segments!.isEmpty)
              Text(
                l.dayPlanEmpty,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ..._segments!.asMap().entries.map(
                (e) => _PlanSegEditRow(
                  key: ValueKey(e.value.id),
                  index: e.key,
                  segment: e.value,
                  onUpdate: (seg) => _updateSegment(e.key, seg),
                  onRemove: () => _removeSegment(e.key),
                ),
              ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _addSegment,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  l.addSegment,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ),
            ),
            if (_segments!.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadIntoTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l.planLoadIntoTimer,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _PlanPresetBar extends StatefulWidget {
  final List<Segment> currentSegments;
  final ValueChanged<List<Segment>> onAppend;

  const _PlanPresetBar({required this.currentSegments, required this.onAppend});

  @override
  State<_PlanPresetBar> createState() => _PlanPresetBarState();
}

class _PlanPresetBarState extends State<_PlanPresetBar> {
  List<Preset> _userPresets = const [];
  Set<String> _hidden = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await PersistenceService.loadPresets();
    final list = raw == null
        ? <Preset>[]
        : raw
              .map(Preset.fromJson)
              .where((p) => !Preset.builtinEnNames.contains(p.name))
              .toList();
    final hidden = (await PersistenceService.loadHiddenDefaults()).toSet();
    if (!mounted) return;
    setState(() {
      _userPresets = list;
      _hidden = hidden;
      _loaded = true;
    });
  }

  Future<void> _persist() => PersistenceService.savePresets(
    _userPresets.map((p) => p.toJson()).toList(),
  );

  void _apply(Preset p) {
    widget.onAppend(p.freshSegments());
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).presetApplied(p.name)),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _saveCurrent() async {
    final l = AppLocalizations.of(context);
    final segs = widget.currentSegments;
    if (segs.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.noSegmentsToSave)));
      return;
    }
    final name = await _promptName();
    if (!mounted || name == null || name.trim().isEmpty) return;
    final preset = Preset(
      name: name.trim(),
      loop: false,
      segments: [
        for (final s in segs)
          Segment(name: s.name, minutes: s.minutes, color: s.color),
      ],
    );
    setState(() => _userPresets = [..._userPresets, preset]);
    await _persist();
  }

  Future<String?> _promptName() {
    final l = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          l.savePresetTitle,
          style: const TextStyle(color: AppColors.text, fontSize: 15),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.text, fontSize: 13),
          decoration: InputDecoration(
            hintText: l.presetNameHint,
            hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.timerOrange),
            ),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(
              l.cancel,
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: Text(
              l.save,
              style: const TextStyle(color: AppColors.timerOrange),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openManage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PresetManagePage()),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final defaults = Preset.defaultsFor(l);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final p in defaults)
            if (!_hidden.contains(p.builtinKey))
              _PlanPresetChip(
                preset: p,
                deletable: false,
                onApply: () => _apply(p),
              ),
          for (final e in _userPresets.asMap().entries)
            _PlanPresetChip(
              preset: e.value,
              deletable: true,
              onApply: () => _apply(e.value),
              onDelete: () async {
                setState(() {
                  final next = [..._userPresets]..removeAt(e.key);
                  _userPresets = next;
                });
                await _persist();
              },
            ),
          _PlanSaveChip(onTap: _saveCurrent),
          _PlanManageChip(onTap: _openManage),
        ],
      ),
    );
  }
}

class _PlanPresetChip extends StatelessWidget {
  final Preset preset;
  final VoidCallback onApply;
  final VoidCallback? onDelete;
  final bool deletable;

  const _PlanPresetChip({
    required this.preset,
    required this.onApply,
    this.onDelete,
    required this.deletable,
  });

  @override
  Widget build(BuildContext context) {
    final dot = preset.segments.isNotEmpty
        ? preset.segments.first.color
        : AppColors.muted;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111113),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.only(left: 10, right: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onApply,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: dot,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    preset.name,
                    style: const TextStyle(color: AppColors.text, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          if (deletable) ...[
            const SizedBox(width: 2),
            GestureDetector(
              onTap: onDelete,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 14, color: AppColors.muted),
              ),
            ),
          ] else
            const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _PlanSaveChip extends StatelessWidget {
  final VoidCallback onTap;
  const _PlanSaveChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.timerOrange.withAlpha(0x88)),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bookmark_add_outlined,
              size: 14,
              color: AppColors.timerOrange,
            ),
            const SizedBox(width: 5),
            Text(
              l.savePresetChip,
              style: const TextStyle(
                color: AppColors.timerOrange,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanManageChip extends StatelessWidget {
  final VoidCallback onTap;
  const _PlanManageChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune, size: 14, color: AppColors.muted),
            const SizedBox(width: 5),
            Text(
              l.manage,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanSegEditRow extends StatefulWidget {
  final int index;
  final Segment segment;
  final ValueChanged<Segment> onUpdate;
  final VoidCallback onRemove;

  const _PlanSegEditRow({
    super.key,
    required this.index,
    required this.segment,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<_PlanSegEditRow> createState() => _PlanSegEditRowState();
}

class _PlanSegEditRowState extends State<_PlanSegEditRow> {
  late TextEditingController _nameCtrl;
  late TextEditingController _minCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.segment.name);
    _minCtrl = TextEditingController(text: widget.segment.minutes.toString());
  }

  @override
  void didUpdateWidget(_PlanSegEditRow old) {
    super.didUpdateWidget(old);
    if (old.segment.name != widget.segment.name &&
        _nameCtrl.text != widget.segment.name) {
      _nameCtrl.text = widget.segment.name;
    }
    if (old.segment.minutes != widget.segment.minutes) {
      final t = widget.segment.minutes.toString();
      if (_minCtrl.text != t) _minCtrl.text = t;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  void _commit() {
    final mins = (int.tryParse(_minCtrl.text) ?? widget.segment.minutes).clamp(
      1,
      999,
    );
    widget.onUpdate(
      widget.segment.copyWith(name: _nameCtrl.text, minutes: mins),
    );
  }

  Future<void> _pickColor() async {
    final picked = await showSegColorPicker(context, widget.segment.color);
    if (picked != null) {
      widget.onUpdate(widget.segment.copyWith(color: picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF111113),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickColor,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: widget.segment.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.text.withAlpha(0x33),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppColors.text, fontSize: 12),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) => _commit(),
            ),
          ),
          SizedBox(
            width: 52,
            child: TextField(
              controller: _minCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.text, fontSize: 12),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
              ),
              onChanged: (_) => _commit(),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            l.minutesUnit,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: widget.onRemove,
            child: const Icon(Icons.close, size: 16, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
