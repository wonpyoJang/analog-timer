import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../services/haptic_service.dart';
import '../ai/timer_ai_service.dart';
import '../bloc/multi_timer_bloc.dart';
import '../bloc/multi_timer_event.dart';
import '../models/countdown_timer.dart';
import '../time_parser.dart';

/// 말·글로 타이머 만들기(디자인 "온디바이스 기능 화면" §E·§F).
///
/// 한 문장을 규칙 파서(time_parser)로 여러 후보로 쪼개 확인 카드로 보여주고
/// 일괄 시작한다. 음성 인식은 후속(speech_to_text) — 지금은 텍스트 입력이 입구.
class TextTimerScreen extends StatefulWidget {
  final List<PresetRef> presets;
  final MultiTimerBloc bloc;

  /// OCR 등에서 이미 파싱된 후보로 바로 확인 단계 진입(§C). 제목도 전환.
  final List<ParsedTimer>? initial;
  final String? title;
  const TextTimerScreen({
    super.key,
    required this.presets,
    required this.bloc,
    this.initial,
    this.title,
  });

  @override
  State<TextTimerScreen> createState() => _TextTimerScreenState();
}

/// 시작 방식(§C·동시완료) — 병렬 / 순차 / 동시 완료(끝 맞추기).
enum _StartMode { parallel, sequential, finishTogether }

class _TextTimerScreenState extends State<TextTimerScreen> {
  final _ctrl = TextEditingController();
  List<ParsedTimer>? _parsed; // null = 입력 단계
  final _selected = <int>{};
  _StartMode _mode = _StartMode.parallel;
  bool? _ackGateOverride; // null = 맥락 자동 추천, 값 있으면 사용자 토글(순차 전용)

  static const _examples = ['라면이랑 세탁', '십오분 집중', '계란 육분 반숙', '파스타 팔분, 소스 오분'];

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    if (init != null && init.isNotEmpty) {
      _parsed = init;
      _selected.addAll([
        for (var i = 0; i < init.length; i++)
          if (init[i].kind != ParsedKind.unparsed) i,
      ]);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _parse() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    // 규칙 파서가 1순위. AI 폴백은 플래그 OFF·미지원이면 결과를 그대로 돌려줌.
    var result = parseTimers(text, presets: widget.presets);
    result = await TimerAiService.instance.enhance(
      result,
      presets: widget.presets,
    );
    if (!mounted) return;
    setState(() {
      _parsed = result;
      _selected
        ..clear()
        ..addAll([
          for (var i = 0; i < result.length; i++)
            if (result[i].kind != ParsedKind.unparsed) i,
        ]);
    });
  }

  void _start(AppLocalizations l) {
    final picks = _currentPicks();
    if (picks.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.textTimerEmpty)));
      return;
    }
    String nameOf(ParsedTimer t) => t.name.isEmpty ? l.multiTimerTitle : t.name;
    final multi = picks.length > 1;
    if (multi && _mode == _StartMode.finishTogether) {
      // 동시 완료 = 가장 긴 것 지금, 짧은 것 지연해 모두 같은 시각에 끝냄.
      widget.bloc.add(
        MtAddFinishTogether([
          for (final t in picks) (name: nameOf(t), totalMs: t.totalMs),
        ]),
      );
    } else if (multi && _mode == _StartMode.sequential) {
      if (_effectiveAckGate(picks)) {
        // ack 게이트 = 한 단계 알람을 확인해야 다음이 시작(단계 사이 손 쓰는 조리법).
        final chainId = 'chain${DateTime.now().microsecondsSinceEpoch}';
        for (var i = 0; i < picks.length; i++) {
          widget.bloc.add(
            MtAdd(
              nameOf(picks[i]),
              picks[i].totalMs,
              autoStart: i == 0, // 첫 단계만 실행, 나머지는 확인 시 시작
              chainId: chainId,
              chainIndex: i,
            ),
          );
        }
      } else {
        // 자동 진행 = 한 단계가 끝나면 곧바로 다음(연속 과정: 뜸·식히기 등).
        final steps = [for (final t in picks) LoopStep(nameOf(t), t.totalMs)];
        widget.bloc.add(
          MtAddLoop(nameOf(picks.first), steps, 1, autoStart: true),
        );
      }
    } else {
      for (final t in picks) {
        widget.bloc.add(MtAdd(nameOf(t), t.totalMs, autoStart: true));
      }
    }
    HapticService.instance.selection();
    Navigator.pop(context);
  }

  /// 현재 유효 ack 게이트 여부 — 사용자가 토글로 덮어썼으면 그 값, 아니면 자동 추천.
  bool _effectiveAckGate(List<ParsedTimer> picks) =>
      _ackGateOverride ?? recommendAckGate([for (final t in picks) t.name]);

  /// 선택된 유효 후보(시간 있음)만 순서 유지.
  List<ParsedTimer> _currentPicks() {
    final list = _parsed;
    if (list == null) return const [];
    return [
      for (var i = 0; i < list.length; i++)
        if (_selected.contains(i) &&
            list[i].kind != ParsedKind.unparsed &&
            list[i].totalMs > 0)
          list[i],
    ];
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
            size: 18,
            color: AppColors.text,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title ?? l.textTimerTitle,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _parsed == null ? _input(l) : _confirm(l),
    );
  }

  // ── 입력 단계(§E) ─────────────────────────────────────────
  Widget _input(AppLocalizations l) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      children: [
        Text(
          l.textTimerHelper,
          style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.6),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _ctrl,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          style: const TextStyle(color: AppColors.text, fontSize: 16),
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: l.textTimerInputHint,
            hintStyle: TextStyle(color: AppColors.faint, fontSize: 15),
            filled: true,
            fillColor: const Color(0xFF141416),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
          onSubmitted: (_) => _parse(),
        ),
        const SizedBox(height: 22),
        Text(
          l.textTimerExamplesHead.toUpperCase(),
          style: TextStyle(
            color: AppColors.faint,
            fontSize: 12,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final ex in _examples)
              ActionChip(
                label: Text(ex),
                onPressed: () {
                  _ctrl.text = ex;
                  _ctrl.selection = TextSelection.collapsed(offset: ex.length);
                },
                backgroundColor: AppColors.accent.withAlpha(0x1F),
                labelStyle: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 13,
                ),
                side: BorderSide(color: AppColors.accent.withAlpha(0x55)),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          l.textTimerOffline,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.faint, fontSize: 12, height: 1.6),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _parse,
            child: Text(
              l.textTimerParse,
              style: const TextStyle(
                color: Color(0xFF141416),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 확인 단계(§F) ─────────────────────────────────────────
  Widget _confirm(AppLocalizations l) {
    final list = _parsed!;
    final startable = _selected
        .where((i) => list[i].kind != ParsedKind.unparsed)
        .length;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            children: [
              Text(
                l.textTimerConfirmTitle,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l.textTimerConfirmSub,
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              if (list.every((t) => t.kind == ParsedKind.unparsed))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l.textTimerNoTime,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: 14),
                  ),
                ),
              for (var i = 0; i < list.length; i++) _card(l, list[i], i),
              // 시작 방식(§C·§F) — 후보 2개 이상일 때만. 조리법=이어서.
              if (startable > 1) _startModeSeg(l),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF232326),
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => setState(() => _parsed = null),
                    child: Text(
                      l.textTimerRetype,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: startable == 0 ? null : () => _start(l),
                    child: Text(
                      l.textTimerStartN(startable),
                      style: const TextStyle(
                        color: Color(0xFF141416),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 시작 방식 세그먼트(§C·동시완료) — 동시에 / 이어서 / 동시 완료.
  Widget _startModeSeg(AppLocalizations l) {
    Widget seg(String label, _StartMode m) {
      final on = _mode == m;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _mode = m),
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
            decoration: BoxDecoration(
              color: on ? const Color(0xFF232326) : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: on ? AppColors.text : AppColors.faint,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF141416),
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                seg(l.seqParallel, _StartMode.parallel),
                seg(l.seqSequential, _StartMode.sequential),
                seg(l.seqFinishTogether, _StartMode.finishTogether),
              ],
            ),
          ),
          if (_mode == _StartMode.sequential) _ackGateRow(l),
          if (_mode == _StartMode.finishTogether) _finishPreview(l),
        ],
      ),
    );
  }

  /// 동시 완료 미리보기(§1·§2) — 계산된 공통 완료시각.
  Widget _finishPreview(AppLocalizations l) {
    final picks = _currentPicks();
    var maxMs = 0;
    for (final t in picks) {
      if (t.totalMs > maxMs) maxMs = t.totalMs;
    }
    final finish = DateTime.now().add(Duration(milliseconds: maxMs));
    final hh = finish.hour.toString().padLeft(2, '0');
    final mm = finish.minute.toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.seqFinishAt('$hh:$mm'),
            style: const TextStyle(
              color: Color(0xFF52B0E0),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.seqFinishNote,
            style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  /// ack 게이트 서브 토글(§C) — 맥락으로 자동 선택, 사용자가 덮어쓸 수 있음.
  Widget _ackGateRow(AppLocalizations l) {
    final picks = _currentPicks();
    final ack = _effectiveAckGate(picks);
    final isAuto = _ackGateOverride == null;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        l.seqAckTitle,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isAuto) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha(0x24),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          l.seqAckAuto,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Switch(
                value: ack,
                onChanged: (v) => setState(() => _ackGateOverride = v),
                activeThumbColor: AppColors.accent,
                trackColor: WidgetStateProperty.resolveWith(
                  (s) => s.contains(WidgetState.selected)
                      ? AppColors.accent.withAlpha(0x55)
                      : AppColors.surface,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 2),
            child: Text(
              ack ? l.seqAckOnNote : l.seqAckOffNote,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(AppLocalizations l, ParsedTimer t, int i) {
    final unparsed = t.kind == ParsedKind.unparsed;
    final sel = _selected.contains(i);
    final color = AppColors.segColors[i % AppColors.segColors.length];
    final reason = unparsed
        ? l.textTimerUnparsed
        : t.kind == ParsedKind.preset
        ? l.textTimerFromPreset
        : t.rangePickedShort
        ? l.textTimerRangeShort
        : (t.timeExpr != null && t.timeExpr!.isNotEmpty
              ? '${t.timeExpr} → ${_fmt(t.totalMs)}'
              : _fmt(t.totalMs));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: unparsed
            ? Colors.transparent
            : sel
            ? const Color(0xFF1D1C18)
            : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: unparsed
                ? AppColors.border
                : sel
                ? AppColors.accent.withAlpha(0x80)
                : AppColors.border,
            style: unparsed ? BorderStyle.none : BorderStyle.solid,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: unparsed
              ? null
              : () => setState(() {
                  if (sel) {
                    _selected.remove(i);
                  } else {
                    _selected.add(i);
                  }
                }),
          child: Container(
            decoration: unparsed
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF3A3A3E)),
                  )
                : null,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: unparsed ? const Color(0xFF4A4A50) : color,
                  ),
                ),
                const SizedBox(width: 13),
                Text(
                  unparsed ? '—:—' : _fmt(t.totalMs),
                  style: TextStyle(
                    color: unparsed ? AppColors.faint : AppColors.text,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.name.isEmpty ? l.multiTimerTitle : t.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: unparsed ? AppColors.muted : AppColors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        reason,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (!unparsed)
                  Icon(
                    sel ? Icons.check_circle : Icons.circle_outlined,
                    color: sel ? AppColors.accent : AppColors.faint,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(int ms) {
    final s = ms ~/ 1000;
    final m = s ~/ 60;
    final sec = s % 60;
    if (m >= 60) {
      final h = m ~/ 60;
      return '$h:${(m % 60).toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
    }
    return '$m:${sec.toString().padLeft(2, '0')}';
  }
}
