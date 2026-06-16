import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_theme.dart';
import '../bloc/timer_bloc.dart';
import '../bloc/timer_event.dart';
import '../bloc/timer_state.dart';
import '../models/segment.dart';

class SegmentEditor extends StatelessWidget {
  const SegmentEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TIMER SEGMENTS',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                onReorderItem: (oldIndex, newIndex) => context
                    .read<TimerBloc>()
                    .add(TimerSegmentReordered(oldIndex, newIndex)),
                children: [
                  for (final e in state.segments.asMap().entries)
                    _SegmentRow(
                      key: ValueKey(e.value.id),
                      index: e.key,
                      segment: e.value,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              _AddButton(),
              const SizedBox(height: 8),
              _LoopToggle(loop: state.loop),
            ],
          ),
        );
      },
    );
  }
}

class _SegmentRow extends StatefulWidget {
  final int index;
  final Segment segment;
  const _SegmentRow({super.key, required this.index, required this.segment});

  @override
  State<_SegmentRow> createState() => _SegmentRowState();
}

class _SegmentRowState extends State<_SegmentRow> {
  late TextEditingController _nameCtrl;
  late TextEditingController _minCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.segment.name);
    _minCtrl = TextEditingController(text: widget.segment.minutes.toString());
  }

  @override
  void didUpdateWidget(_SegmentRow old) {
    super.didUpdateWidget(old);
    if (old.segment.name != widget.segment.name &&
        _nameCtrl.text != widget.segment.name) {
      _nameCtrl.text = widget.segment.name;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  void _update(BuildContext context) {
    final mins = int.tryParse(_minCtrl.text) ?? widget.segment.minutes;
    context.read<TimerBloc>().add(
      TimerSegmentUpdated(
        widget.index,
        widget.segment.copyWith(name: _nameCtrl.text, minutes: mins),
      ),
    );
  }

  Future<void> _pickColor(BuildContext context) async {
    final bloc = context.read<TimerBloc>();
    final current = widget.segment.color.toARGB32();
    final picked = await showDialog<Color>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '세그먼트 색상',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final c in AppColors.segColors)
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx, c),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: c.toARGB32() == current
                                  ? AppColors.text
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: c.toARGB32() == current
                              ? const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                )
                              : null,
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
    if (picked != null) {
      final mins = int.tryParse(_minCtrl.text) ?? widget.segment.minutes;
      bloc.add(
        TimerSegmentUpdated(
          widget.index,
          widget.segment.copyWith(
            name: _nameCtrl.text,
            minutes: mins,
            color: picked,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          // 드래그 핸들 — 순서 변경
          ReorderableDragStartListener(
            index: widget.index,
            child: const MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.drag_indicator,
                  size: 16,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
          // 색상 점 = 탭하면 팔레트에서 색 변경
          GestureDetector(
            onTap: () => _pickColor(context),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
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
              onChanged: (_) => _update(context),
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
                  borderSide: const BorderSide(color: AppColors.timerOrange),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
              ),
              onChanged: (_) => _update(context),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            '분',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => context.read<TimerBloc>().add(
              TimerSegmentRemoved(widget.index),
            ),
            child: const Icon(Icons.close, size: 16, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<TimerBloc>().add(const TimerSegmentAdded()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          '+ 세그먼트 추가',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 11),
        ),
      ),
    );
  }
}

class _LoopToggle extends StatelessWidget {
  final bool loop;
  const _LoopToggle({required this.loop});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Switch(
          value: loop,
          onChanged: (v) => context.read<TimerBloc>().add(TimerLoopToggled(v)),
          activeThumbColor: AppColors.timerOrange,
          activeTrackColor: AppColors.timerOrange.withAlpha(0x88),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: 8),
        const Text(
          '연속 반복',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}
