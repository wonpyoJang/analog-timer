import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../bloc/timer_bloc.dart';
import '../bloc/timer_event.dart';
import '../../../services/hotkey_service.dart';
import '../../../services/shortcut_hint_service.dart';
import '../bloc/timer_state.dart';

class TimerControls extends StatelessWidget {
  const TimerControls({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        final l = AppLocalizations.of(context);
        final isRunning = state.status == TimerStatus.running;
        final isIdle =
            state.status == TimerStatus.idle ||
            state.status == TimerStatus.done;

        return Column(
          children: [
            Text(
              '⏱ ${l.timerSection}',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            // 1행: START/RESUME/RUNNING + PAUSE
            Row(
              children: [
                Expanded(
                  child: _Btn(
                    label: isRunning
                        ? l.btnRunning
                        : (state.status == TimerStatus.paused
                              ? l.btnResume
                              : l.btnStart),
                    enabled: !isRunning,
                    primary: true,
                    color: AppColors.timerOrange,
                    tooltip: 'Space · ${HotkeyService.instance.describe('timer_toggle')}',
                    onTap: isRunning
                        ? null
                        : () {
                            context.read<TimerBloc>().add(const TimerStart());
                            ShortcutHintService.instance
                                .buttonPressed('timer_toggle');
                          },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Btn(
                    label: l.btnPause,
                    enabled: isRunning,
                    tooltip: 'Space · ${HotkeyService.instance.describe('timer_toggle')}',
                    onTap: isRunning
                        ? () {
                            context.read<TimerBloc>().add(const TimerPause());
                            ShortcutHintService.instance
                                .buttonPressed('timer_toggle');
                          }
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 2행: NEXT (즉시 다음) + RST
            Row(
              children: [
                Expanded(
                  child: _Btn(
                    label: '▶ ${l.btnNext}',
                    enabled: !isIdle,
                    color: AppColors.accent,
                    accentOutline: true,
                    tooltip: 'N · ${HotkeyService.instance.describe('timer_next')}',
                    onTap: !isIdle
                        ? () {
                            context.read<TimerBloc>().add(const TimerNext());
                            ShortcutHintService.instance
                                .buttonPressed('timer_next');
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Btn(
                    label: l.btnReset,
                    danger: true,
                    onTap: () =>
                        context.read<TimerBloc>().add(const TimerReset()),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool primary;
  final bool danger;

  /// 강조 윤곽선(다음 버튼) — 배경은 어둡게, 글자/테두리는 accent.
  final bool accentOutline;
  final Color? color;
  final VoidCallback? onTap;

  /// 호버 시 단축키 표기(예: 'Space · Ctrl+Alt+Space') — 학습 장치 1층.
  final String? tooltip;

  const _Btn({
    required this.label,
    this.enabled = true,
    this.primary = false,
    this.danger = false,
    this.accentOutline = false,
    this.color,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.surface;
    Color fg = AppColors.text;
    Color border = AppColors.border;
    if (primary && color != null) {
      bg = color!;
      fg = Colors.white;
      border = color!;
    } else if (accentOutline && color != null) {
      bg = const Color(0xFF2E2E38);
      fg = color!;
      border = color!;
    } else if (danger) {
      fg = AppColors.danger;
      border = const Color(0xFF554040);
    }
    if (!enabled) {
      bg = bg.withAlpha(0x88);
      fg = fg.withAlpha(0x88);
    }

    final btn = GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(color: fg, fontSize: 11, letterSpacing: 0.8),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
    if (tooltip == null) return btn;
    return Tooltip(message: tooltip!, child: btn);
  }
}
