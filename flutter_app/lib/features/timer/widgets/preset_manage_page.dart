import 'package:flutter/material.dart';
import '../../../services/persistence_service.dart';
import '../../../theme/app_theme.dart';
import '../models/preset.dart';
import 'preset_edit_page.dart';

/// 프리셋 목록 관리 풀스크린 화면 — 새로 만들기 / 편집 / 삭제 / 순서.
class PresetManagePage extends StatefulWidget {
  const PresetManagePage({super.key});

  @override
  State<PresetManagePage> createState() => _PresetManagePageState();
}

class _PresetManagePageState extends State<PresetManagePage> {
  List<Preset> _presets = const [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await PersistenceService.loadPresets();
    final list = raw == null ? Preset.defaults : raw.map(Preset.fromJson).toList();
    if (raw == null) {
      await PersistenceService.savePresets(list.map((p) => p.toJson()).toList());
    }
    if (!mounted) return;
    setState(() {
      _presets = list;
      _loaded = true;
    });
  }

  Future<void> _persist() => PersistenceService.savePresets(
    _presets.map((p) => p.toJson()).toList(),
  );

  Future<void> _new() async {
    final created = await Navigator.push<Preset>(
      context,
      MaterialPageRoute(builder: (_) => const PresetEditPage()),
    );
    if (created == null) return;
    setState(() => _presets = [..._presets, created]);
    await _persist();
  }

  Future<void> _edit(int i) async {
    final edited = await Navigator.push<Preset>(
      context,
      MaterialPageRoute(builder: (_) => PresetEditPage(initial: _presets[i])),
    );
    if (edited == null) return;
    final n = [..._presets];
    n[i] = edited;
    setState(() => _presets = n);
    await _persist();
  }

  Future<void> _delete(int i) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          '프리셋 삭제',
          style: TextStyle(color: AppColors.text, fontSize: 15),
        ),
        content: Text(
          "'${_presets[i].name}' 을(를) 삭제할까요?",
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final n = [..._presets]..removeAt(i);
    setState(() => _presets = n);
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: const Text(
          '프리셋 관리',
          style: TextStyle(fontSize: 15, letterSpacing: 0.5),
        ),
        actions: [
          TextButton.icon(
            onPressed: _new,
            icon: const Icon(Icons.add, size: 18, color: AppColors.timerOrange),
            label: const Text(
              '새 프리셋',
              style: TextStyle(color: AppColors.timerOrange, fontSize: 14),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: !_loaded
          ? const SizedBox.shrink()
          : _presets.isEmpty
          ? const Center(
              child: Text(
                '저장된 프리셋이 없습니다.\n우측 상단 "새 프리셋" 으로 추가하세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _presets.length,
              itemBuilder: (_, i) => _PresetCard(
                preset: _presets[i],
                onEdit: () => _edit(i),
                onDelete: () => _delete(i),
              ),
            ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  final Preset preset;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _PresetCard({
    required this.preset,
    required this.onEdit,
    required this.onDelete,
  });

  String get _summary => preset.segments
      .map((s) => '${s.name} ${s.minutes}분')
      .join(' · ');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 색 점들 — 세그먼트 미리보기
          Wrap(
            spacing: 3,
            children: [
              for (final s in preset.segments.take(6))
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        preset.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.text, fontSize: 14),
                      ),
                    ),
                    if (preset.loop) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.repeat, size: 13, color: AppColors.timerOrange),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _IconBtn(icon: Icons.edit_outlined, color: AppColors.text, onTap: onEdit),
          const SizedBox(width: 4),
          _IconBtn(icon: Icons.delete_outline, color: AppColors.danger, onTap: onDelete),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
