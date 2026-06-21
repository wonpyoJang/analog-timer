import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/daily_record_service.dart';
import '../features/timer/models/segment.dart';
import '../features/timer/bloc/timer_bloc.dart';
import '../features/timer/bloc/timer_event.dart';

class DayPlanView extends StatefulWidget {
  final DateTime date;
  const DayPlanView({super.key, required this.date});

  @override
  State<DayPlanView> createState() => _DayPlanViewState();
}

class _DayPlanViewState extends State<DayPlanView> {
  List<Segment>? _segments;
  bool _loading = true;

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
    setState(() => _loading = true);
    final plan = await DailyRecordService.loadPlan(widget.date);
    if (mounted) {
      setState(() {
        _segments = plan;
        _loading = false;
      });
    }
  }

  Future<void> _saveCurrentAsplan() async {
    final segs = List<Segment>.from(context.read<TimerBloc>().state.segments);
    await DailyRecordService.savePlan(widget.date, segs);
    if (mounted) setState(() => _segments = segs);
  }

  void _loadIntoTimer() {
    if (_segments == null || _segments!.isEmpty) return;
    context.read<TimerBloc>().add(TimerSegmentsReplaced(_segments!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).planLoadIntoTimer),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
              GestureDetector(
                onTap: _saveCurrentAsplan,
                child: Text(
                  l.planSaveAsCurrent,
                  style: const TextStyle(
                    color: AppColors.muted,
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
          else if (_segments == null || _segments!.isEmpty)
            Text(
              l.dayPlanEmpty,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            )
          else ...[
            ..._segments!.map((s) => _PlanSegRow(segment: s)),
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
      ),
    );
  }
}

class _PlanSegRow extends StatelessWidget {
  final Segment segment;
  const _PlanSegRow({required this.segment});

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0 && s > 0) return '${m}m ${s}s';
    if (m > 0) return '${m}m';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: segment.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              segment.name,
              style: const TextStyle(color: AppColors.text, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _fmt(segment.duration),
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
