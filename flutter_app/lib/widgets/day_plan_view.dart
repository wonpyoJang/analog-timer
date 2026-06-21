import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/daily_record_service.dart';
import '../features/timer/models/segment.dart';
import '../features/timer/bloc/timer_bloc.dart';
import '../features/timer/bloc/timer_event.dart';
import '../features/timer/widgets/color_picker_dialog.dart';

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
