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
              ...state.segments.asMap().entries.map(
                (e) => _SegmentRow(index: e.key, segment: e.value),
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
  const _SegmentRow({required this.index, required this.segment});

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
    final mins = double.tryParse(_minCtrl.text) ?? widget.segment.minutes;
    context.read<TimerBloc>().add(
      TimerSegmentUpdated(
        widget.index,
        widget.segment.copyWith(name: _nameCtrl.text, minutes: mins),
      ),
    );
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
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: widget.segment.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
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
