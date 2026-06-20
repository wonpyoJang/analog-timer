import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/preset.dart';
import '../models/segment.dart';
import 'color_picker_dialog.dart';

/// 단일 프리셋 풀스크린 편집 화면. [initial] 이 null 이면 새 프리셋 작성.
/// 저장 시 Navigator.pop 으로 [Preset] 을 반환(취소 시 null).
class PresetEditPage extends StatefulWidget {
  final Preset? initial;
  const PresetEditPage({super.key, this.initial});

  @override
  State<PresetEditPage> createState() => _PresetEditPageState();
}

class _PresetEditPageState extends State<PresetEditPage> {
  late final TextEditingController _nameCtrl;
  late List<Segment> _segs;
  late bool _loop;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _nameCtrl = TextEditingController(text: init?.name ?? '');
    _segs = init == null
        ? [Segment(name: '집중', minutes: 25, color: AppColors.segColors[3])]
        : [
            for (final s in init.segments)
              Segment(name: s.name, minutes: s.minutes, color: s.color),
          ];
    _loop = init?.loop ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _addSeg() {
    setState(() {
      final color =
          AppColors.segColors[_segs.length % AppColors.segColors.length];
      _segs = [
        ..._segs,
        Segment(name: '세그먼트 ${_segs.length + 1}', minutes: 5, color: color),
      ];
    });
  }

  void _updateSeg(int i, Segment s) {
    final n = [..._segs];
    n[i] = s;
    setState(() => _segs = n);
  }

  void _removeSeg(int i) {
    final n = [..._segs]..removeAt(i);
    setState(() => _segs = n);
  }

  void _reorder(int oldI, int newI) {
    setState(() {
      final n = [..._segs];
      final moved = n.removeAt(oldI);
      // 표준 onReorder: newIndex 는 '제거 전' 기준이라 뒤로 미는 경우 보정.
      n.insert(newI > oldI ? newI - 1 : newI, moved);
      _segs = n;
    });
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    if (name.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('이름을 입력하세요')));
      return;
    }
    if (_segs.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('세그먼트를 1개 이상 추가하세요')),
      );
      return;
    }
    Navigator.pop(context, Preset(name: name, loop: _loop, segments: _segs));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: Text(
          widget.initial == null ? '새 프리셋' : '프리셋 편집',
          style: const TextStyle(fontSize: 15, letterSpacing: 0.5),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              '저장',
              style: TextStyle(
                color: AppColors.timerOrange,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            '프리셋 이름',
            style: TextStyle(color: AppColors.muted, fontSize: 11, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: AppColors.text, fontSize: 14),
            decoration: InputDecoration(
              hintText: '예: 공부 50/10',
              hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.timerOrange),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            '세그먼트',
            style: TextStyle(color: AppColors.muted, fontSize: 11, letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorder: _reorder,
            children: [
              for (final e in _segs.asMap().entries)
                _EditSegRow(
                  key: ValueKey(e.value.id),
                  index: e.key,
                  segment: e.value,
                  onChanged: (s) => _updateSeg(e.key, s),
                  onRemove: () => _removeSeg(e.key),
                ),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _addSeg,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '+ 세그먼트 추가',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Switch(
                value: _loop,
                onChanged: (v) => setState(() => _loop = v),
                activeThumbColor: AppColors.timerOrange,
                activeTrackColor: AppColors.timerOrange.withAlpha(0x88),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 8),
              const Text(
                '연속 반복',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditSegRow extends StatefulWidget {
  final int index;
  final Segment segment;
  final ValueChanged<Segment> onChanged;
  final VoidCallback onRemove;
  const _EditSegRow({
    super.key,
    required this.index,
    required this.segment,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_EditSegRow> createState() => _EditSegRowState();
}

class _EditSegRowState extends State<_EditSegRow> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _minCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.segment.name);
    _minCtrl = TextEditingController(text: widget.segment.minutes.toString());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    final mins = int.tryParse(_minCtrl.text) ?? widget.segment.minutes;
    widget.onChanged(
      widget.segment.copyWith(name: _nameCtrl.text, minutes: mins),
    );
  }

  Future<void> _pickColor() async {
    final picked = await showSegColorPicker(context, widget.segment.color);
    if (picked != null) {
      final mins = int.tryParse(_minCtrl.text) ?? widget.segment.minutes;
      widget.onChanged(
        widget.segment.copyWith(name: _nameCtrl.text, minutes: mins, color: picked),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF111113),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: widget.index,
            child: const MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.drag_indicator, size: 18, color: AppColors.muted),
              ),
            ),
          ),
          GestureDetector(
            onTap: _pickColor,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: widget.segment.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.text.withAlpha(0x33), width: 1),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppColors.text, fontSize: 13),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) => _emit(),
            ),
          ),
          SizedBox(
            width: 56,
            child: TextField(
              controller: _minCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.text, fontSize: 13),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
              ),
              onChanged: (_) => _emit(),
            ),
          ),
          const SizedBox(width: 5),
          const Text('분', style: TextStyle(color: AppColors.muted, fontSize: 12)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: widget.onRemove,
            child: const MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Icon(Icons.close, size: 17, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
