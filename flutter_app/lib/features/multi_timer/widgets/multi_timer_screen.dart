import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../services/persistence_service.dart';
import '../../../services/haptic_service.dart';
import '../../../services/tts_service.dart';
import '../../../services/desktop_notification_service.dart';
import '../bloc/multi_timer_bloc.dart';
import '../bloc/multi_timer_event.dart';
import '../bloc/multi_timer_state.dart';
import '../models/countdown_timer.dart';

String _fmt(int ms) {
  final total = (ms / 1000).ceil();
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  final mm = m.toString().padLeft(2, '0');
  final ss = s.toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
}

class MultiTimerScreen extends StatelessWidget {
  const MultiTimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 복원(async)은 _MultiTimerView.initState 에서 dispatch.
    return BlocProvider(
      create: (_) => MultiTimerBloc(),
      child: const _MultiTimerView(),
    );
  }
}

class _MultiTimerView extends StatefulWidget {
  const _MultiTimerView();
  @override
  State<_MultiTimerView> createState() => _MultiTimerViewState();
}

class _MultiTimerViewState extends State<_MultiTimerView> {
  Timer? _saveTrailing;
  DateTime _lastSave = DateTime.fromMillisecondsSinceEpoch(0);
  static const _saveInterval = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final data = await PersistenceService.loadMultiTimerState();
    if (data == null || !mounted) return;
    final rawList = (data['timers'] as List?) ?? const [];
    final savedAt = (data['savedAtMs'] as num?)?.toInt();
    final elapsed = savedAt == null
        ? 0
        : DateTime.now().millisecondsSinceEpoch - savedAt;
    final timers = rawList
        .map((e) => CountdownTimer.fromJson(e as Map<String, dynamic>))
        .map((t) {
          // 앱 꺼진 동안 running 이었으면 경과분 차감.
          if (t.running && elapsed > 0) {
            final r = t.remainMs - elapsed;
            if (r <= 0) {
              return t.copyWith(remainMs: 0, running: false, done: true);
            }
            return t.copyWith(remainMs: r);
          }
          return t;
        })
        .toList();
    if (mounted) context.read<MultiTimerBloc>().add(MtRestore(timers));
  }

  // 스로틀 저장 — 실행 중 매 틱 저장(16ms)은 막되, 최소 1.5s 간격으로 갱신하고
  // 마지막 상태를 트레일링 저장(디바운스는 틱마다 리셋돼 영영 저장 안 되는 버그가 있어 사용 안 함).
  void _save(MultiTimerState s) {
    _lastSave = DateTime.now();
    PersistenceService.saveMultiTimerState(
      s.timers.map((t) => t.toJson()).toList(),
    );
  }

  void _persist(MultiTimerState s) {
    final since = DateTime.now().difference(_lastSave);
    if (since >= _saveInterval) {
      _saveTrailing?.cancel();
      _save(s);
    } else {
      _saveTrailing?.cancel();
      _saveTrailing = Timer(_saveInterval - since, () => _save(s));
    }
  }

  void _onCompleted(BuildContext context, MultiTimerState s) {
    final ids = s.justCompleted;
    if (ids.isEmpty) return;
    HapticService.instance.impact(); // 여러 개 동시여도 1회
    final l = AppLocalizations.of(context);
    if (ids.length == 1) {
      final t = s.timers.firstWhere(
        (x) => x.id == ids.first,
        orElse: () => CountdownTimer(name: '', totalMs: 0),
      );
      DesktopNotificationService.notify(l.multiTimerTitle, t.name);
      if (t.name.isNotEmpty) {
        TtsService.instance.speak(
          t.name,
          localeTag: Localizations.localeOf(context).toLanguageTag(),
        );
      }
    } else {
      final msg = l.multiTimerAllDone(ids.length);
      DesktopNotificationService.notify(l.multiTimerTitle, msg);
      TtsService.instance.speak(
        msg,
        localeTag: Localizations.localeOf(context).toLanguageTag(),
      );
    }
  }

  @override
  void dispose() {
    _saveTrailing?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.text,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l.multiTimerTitle,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: BlocConsumer<MultiTimerBloc, MultiTimerState>(
        listener: (context, state) {
          _persist(state);
          _onCompleted(context, state);
        },
        builder: (context, state) {
          if (state.timers.isEmpty) {
            return Center(
              child: Text(
                l.multiTimerEmpty,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 14),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.timers.length,
            separatorBuilder: (_, _) => const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: AppColors.border,
            ),
            itemBuilder: (context, i) => _TimerRow(
              timer: state.timers[i],
              color: AppColors.segColors[i % AppColors.segColors.length],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddSheet(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final bloc = context.read<MultiTimerBloc>();
    final nameCtrl = TextEditingController();
    Duration picked = const Duration(minutes: 3);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: l.multiTimerNameHint,
                hintStyle: TextStyle(color: AppColors.muted),
              ),
            ),
            SizedBox(
              height: 180,
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hms,
                initialTimerDuration: picked,
                onTimerDurationChanged: (d) => picked = d,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  final ms = picked.inMilliseconds;
                  if (ms <= 0) return;
                  final name = nameCtrl.text.trim().isEmpty
                      ? l.multiTimerTitle
                      : nameCtrl.text.trim();
                  bloc.add(MtAdd(name, ms));
                  Navigator.pop(ctx);
                },
                child: Text(
                  l.multiTimerAdd,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _TimerRow extends StatelessWidget {
  final CountdownTimer timer;
  final Color color;
  const _TimerRow({required this.timer, required this.color});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bloc = context.read<MultiTimerBloc>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.text, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  timer.done ? l.multiTimerDone : _fmt(timer.remainMs),
                  style: TextStyle(
                    color: timer.done ? AppColors.accent : AppColors.muted,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              timer.running ? Icons.pause : Icons.play_arrow,
              color: AppColors.text,
            ),
            tooltip: timer.running ? l.btnPause : l.btnStart,
            onPressed: () => timer.running
                ? bloc.add(MtPause(timer.id))
                : bloc.add(MtStart(timer.id)),
          ),
          IconButton(
            icon: Icon(Icons.replay, color: AppColors.muted),
            tooltip: l.btnReset,
            onPressed: () => bloc.add(MtReset(timer.id)),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.muted),
            tooltip: l.delete,
            onPressed: () => bloc.add(MtRemove(timer.id)),
          ),
        ],
      ),
    );
  }
}
