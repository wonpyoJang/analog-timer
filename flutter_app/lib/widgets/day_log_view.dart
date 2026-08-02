import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/daily_record_service.dart';

class DayLogView extends StatefulWidget {
  final DateTime date;
  const DayLogView({super.key, required this.date});

  @override
  State<DayLogView> createState() => _DayLogViewState();
}

class _DayLogViewState extends State<DayLogView> {
  List<Map<String, dynamic>>? _entries;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(DayLogView old) {
    super.didUpdateWidget(old);
    if (old.date.day != widget.date.day ||
        old.date.month != widget.date.month ||
        old.date.year != widget.date.year) {
      _load();
    }
  }

  Future<void> _load() async {
    final entries = await DailyRecordService.loadLog(widget.date);
    if (mounted) setState(() => _entries = entries);
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
          Text(
            l.dayLogTitle,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          if (_entries == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_entries!.isEmpty)
            Text(
              l.dayLogEmpty,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ..._entries!.map((e) => _LogEntryRow(entry: e)),
        ],
      ),
    );
  }
}

class _LogEntryRow extends StatelessWidget {
  final Map<String, dynamic> entry;
  const _LogEntryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final segName = entry['segName'] as String? ?? '';
    final type = entry['type'] as String? ?? '';
    final colorValue = entry['colorValue'] as int? ?? 0xFFE07A52;
    final timeMs = entry['timeMs'] as int? ?? 0;
    final t = DateTime.fromMillisecondsSinceEpoch(timeMs);
    final timeStr =
        '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}:'
        '${t.second.toString().padLeft(2, '0')}';

    final typeIcon = switch (type) {
      'done' => '✓',
      'allDone' => '✓✓',
      'start' => '▶',
      'pause' => '⏸',
      'skip' => '⏭',
      'reset' => '↺',
      'loop' => '↻',
      _ => '·',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 8, top: 1),
            decoration: BoxDecoration(
              color: Color(colorValue),
              shape: BoxShape.circle,
            ),
          ),
          Text(
            '$timeStr ',
            style: TextStyle(color: AppColors.muted, fontSize: 10),
          ),
          Text(
            '$typeIcon ',
            style: TextStyle(
              color: Color(colorValue),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              segName,
              style: const TextStyle(color: AppColors.text, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
