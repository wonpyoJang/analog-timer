import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/haptic_service.dart';
import '../../services/persistence_service.dart';
import '../../theme/app_theme.dart';
import 'prep_models.dart';

/// 준비물 체크리스트(디자인 "준비물 체크리스트") — ADHD 사용자용 반복 준비물 확인.
/// daily 목록은 날짜가 바뀌면 자동으로 체크가 풀린다(아침 리셋).
class PrepScreen extends StatefulWidget {
  const PrepScreen({super.key});

  @override
  State<PrepScreen> createState() => _PrepScreenState();
}

class _PrepScreenState extends State<PrepScreen> {
  List<PrepList> _lists = [];
  String? _viewId; // null = 홈
  bool _editing = false;
  bool _loaded = false;
  final _newListCtrl = TextEditingController();
  final _newItemCtrl = TextEditingController();

  PrepList? get _cur => _lists.where((l) => l.id == _viewId).firstOrNull;

  static String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final data = await PersistenceService.loadPrepData();
    if (!mounted) return;
    final ko = Localizations.localeOf(context).languageCode.startsWith('ko');
    setState(() {
      _loaded = true;
      if (data != null) {
        _lists = ((data['lists'] as List?) ?? const [])
            .map((e) => PrepList.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        // 매일 아침 리셋 — 저장 날짜가 오늘이 아니면 daily 목록 체크 해제.
        final saved = data['date'] as String?;
        if (saved != null && saved != _today()) {
          for (final l in _lists) {
            if (l.daily) {
              for (final it in l.items) {
                it.done = false;
              }
            }
          }
          _persist();
        }
      } else {
        _lists = prepSeed(ko);
        _persist();
      }
    });
  }

  void _persist() {
    PersistenceService.savePrepData({
      'date': _today(),
      'lists': _lists.map((l) => l.toJson()).toList(),
    });
  }

  void _addList(AppLocalizations l) {
    final name = _newListCtrl.text.trim();
    if (name.isEmpty) return;
    final nl = PrepList(
      id: 'l${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      icon: prepIcons[_lists.length % prepIcons.length],
    );
    setState(() {
      _lists = [..._lists, nl];
      _newListCtrl.clear();
      _viewId = nl.id;
      _editing = true;
    });
    _persist();
  }

  void _addItem() {
    final cur = _cur;
    final text = _newItemCtrl.text.trim();
    if (cur == null || text.isEmpty) return;
    setState(() {
      cur.items.add(
        PrepItem(id: 'i${DateTime.now().microsecondsSinceEpoch}', text: text),
      );
      _newItemCtrl.clear();
    });
    _persist();
  }

  @override
  void dispose() {
    _newListCtrl.dispose();
    _newItemCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cur = _cur;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: !_loaded
            ? const SizedBox.shrink()
            : cur == null
            ? _homeView(l)
            : _listView(l, cur),
      ),
    );
  }

  // ── 홈: 목록 카드들 ──────────────────────────────────────
  Widget _homeView(AppLocalizations l) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              l.prepTitle,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                l.prepAutoReset,
                style: TextStyle(color: AppColors.faint, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l.prepAutoResetHint,
          style: TextStyle(color: AppColors.faint, fontSize: 12),
        ),
        const SizedBox(height: 14),
        for (final list in _lists)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ListCard(
              list: list,
              l: l,
              onTap: () => setState(() {
                _viewId = list.id;
                _editing = false;
              }),
            ),
          ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newListCtrl,
                onSubmitted: (_) => _addList(l),
                style: const TextStyle(color: AppColors.text, fontSize: 13),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: l.prepNewListHint,
                  hintStyle: TextStyle(color: AppColors.faint),
                  filled: true,
                  fillColor: const Color(0xFF232326),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 44,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _addList(l),
                child: const Text(
                  '＋',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── 목록 화면 ───────────────────────────────────────────
  Widget _listView(AppLocalizations l, PrepList cur) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        Row(
          children: [
            _SquareBtn(
              label: '‹',
              onTap: () => setState(() {
                _viewId = null;
                _editing = false;
              }),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cur.icon} ${cur.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    cur.allDone
                        ? l.prepAllPackedGo
                        : l.prepPackedCount(cur.doneCount, cur.items.length),
                    style: TextStyle(
                      color: cur.allDone ? AppColors.swGreen : AppColors.faint,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: _editing
                    ? AppColors.accent.withAlpha(0x1A)
                    : const Color(0xFF232326),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                  side: BorderSide(
                    color: _editing ? AppColors.accent : AppColors.border,
                  ),
                ),
              ),
              onPressed: () => setState(() => _editing = !_editing),
              child: Text(
                _editing ? l.prepEditDone : l.prepEdit,
                style: TextStyle(
                  color: _editing ? AppColors.accent : AppColors.muted,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (cur.allDone && !_editing)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.swGreen.withAlpha(0x1A),
              border: Border.all(color: AppColors.swGreen.withAlpha(0x59)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                l.prepCongrats,
                style: const TextStyle(
                  color: AppColors.swGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        for (final it in cur.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: _ItemTile(
                    item: it,
                    editing: _editing,
                    onTap: () {
                      if (_editing) return;
                      HapticService.instance.light();
                      setState(() => it.done = !it.done);
                      _persist();
                    },
                  ),
                ),
                if (_editing) ...[
                  const SizedBox(width: 8),
                  _SquareBtn(
                    label: '✕',
                    color: AppColors.danger,
                    onTap: () {
                      setState(() => cur.items.remove(it));
                      _persist();
                    },
                  ),
                ],
              ],
            ),
          ),
        if (cur.items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              _editing ? l.prepEmptyItemsEdit : l.prepEmptyItems,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.faint, fontSize: 13),
            ),
          ),
        if (_editing) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newItemCtrl,
                  autofocus: true,
                  onSubmitted: (_) => _addItem(),
                  style: const TextStyle(color: AppColors.text, fontSize: 13),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: l.prepAddItemHint,
                    hintStyle: TextStyle(color: AppColors.faint),
                    filled: true,
                    fillColor: const Color(0xFF232326),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _addItem,
                  child: const Text(
                    '＋',
                    style: TextStyle(
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.prepDailyReset,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        l.prepDailyResetHint,
                        style: TextStyle(color: AppColors.faint, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: cur.daily,
                  activeThumbColor: AppColors.swGreen,
                  onChanged: (v) {
                    setState(() => cur.daily = v);
                    _persist();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              setState(() {
                _lists.removeWhere((x) => x.id == cur.id);
                _viewId = null;
                _editing = false;
              });
              _persist();
            },
            child: Text(
              l.prepDeleteList,
              style: TextStyle(
                color: AppColors.danger,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        if (!_editing && cur.items.isNotEmpty) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              setState(() {
                for (final it in cur.items) {
                  it.done = false;
                }
              });
              _persist();
            },
            child: Text(
              l.prepUncheckAll,
              style: TextStyle(color: AppColors.faint, fontSize: 13),
            ),
          ),
        ],
      ],
    );
  }
}

class _ListCard extends StatelessWidget {
  final PrepList list;
  final AppLocalizations l;
  final VoidCallback onTap;
  const _ListCard({required this.list, required this.l, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final done = list.allDone;
    return Material(
      color: done ? AppColors.swGreen.withAlpha(0x14) : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: done
                  ? AppColors.swGreen.withAlpha(0x66)
                  : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text(list.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            list.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!list.daily) ...[
                          const SizedBox(width: 6),
                          const Text('🌙', style: TextStyle(fontSize: 11)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      done
                          ? l.prepAllPacked
                          : l.prepPackedCount(
                              list.doneCount,
                              list.items.length,
                            ),
                      style: TextStyle(
                        color: done ? AppColors.swGreen : AppColors.faint,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 44,
                height: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: list.items.isEmpty
                        ? 0
                        : list.doneCount / list.items.length,
                    backgroundColor: const Color(0xFF232326),
                    valueColor: AlwaysStoppedAnimation(
                      done ? AppColors.swGreen : AppColors.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final PrepItem item;
  final bool editing;
  final VoidCallback onTap;
  const _ItemTile({
    required this.item,
    required this.editing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final checked = item.done && !editing;
    return Material(
      color: checked ? AppColors.swGreen.withAlpha(0x14) : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(
              color: checked
                  ? AppColors.swGreen.withAlpha(0x66)
                  : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              if (!editing) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.done ? AppColors.swGreen : Colors.transparent,
                    border: Border.all(
                      color: item.done
                          ? AppColors.swGreen
                          : const Color(0xFF3F3F44),
                      width: 2,
                    ),
                  ),
                  child: item.done
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Color(0xFF111111),
                        )
                      : null,
                ),
                const SizedBox(width: 11),
              ],
              Expanded(
                child: Opacity(
                  opacity: checked ? 0.6 : 1.0,
                  child: Text(
                    item.text,
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: checked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: AppColors.muted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SquareBtn extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _SquareBtn({required this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFF232326),
    borderRadius: BorderRadius.circular(11),
    child: InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color ?? AppColors.muted,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ),
  );
}
