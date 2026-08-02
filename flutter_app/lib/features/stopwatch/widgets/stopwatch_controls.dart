import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../bloc/stopwatch_bloc.dart';
import '../bloc/stopwatch_event.dart';
import '../../../services/shortcut_hint_service.dart';
import '../bloc/stopwatch_state.dart';

String _fmt(int ms) {
  final total = (ms.clamp(0, ms) / 1000).truncate();
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  if (h > 0) {
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

class StopwatchControls extends StatelessWidget {
  const StopwatchControls({super.key});

  void _lap(BuildContext context, StopwatchState state) {
    final l = AppLocalizations.of(context);
    final lapMs = state.elapsedMs - state.lapStartMs;
    final lapNum = state.laps.length + 1;
    context.read<StopwatchBloc>().add(const StopwatchLap());
    // 기록이 하단 패널에만 들어가 잘 안 보이므로, 눌렸음을 즉시 알리는 스낵바.
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '🏁  ${l.lapToast(lapNum, _fmt(lapMs))}',
            style: const TextStyle(color: AppColors.text, fontSize: 12),
          ),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1300),
          width: 240,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.swGreen),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StopwatchBloc, StopwatchState>(
      builder: (context, state) {
        final l = AppLocalizations.of(context);
        final active = state.running || state.elapsedMs > 0;
        return Column(
          children: [
            Text(
              '⏲ ${l.stopwatchSection}',
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Btn(
                    label: state.running ? l.btnPause : l.btnStart,
                    primary: true,
                    color: AppColors.swGreen,
                    tooltip: 'S',
                    onTap: () {
                      context.read<StopwatchBloc>().add(
                        const StopwatchToggle(),
                      );
                      ShortcutHintService.instance.buttonPressed('sw_toggle');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Btn(
                    label: l.btnLap,
                    // 스톱워치가 시작되지 않았으면 비활성(회색) — 무반응 혼란 방지.
                    enabled: active,
                    tooltip: 'L · Ctrl+Alt+L',
                    onTap: active
                        ? () {
                            _lap(context, state);
                            ShortcutHintService.instance
                                .buttonPressed('sw_lap');
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Btn(
                    label: l.btnReset,
                    danger: true,
                    onTap: () => context.read<StopwatchBloc>().add(
                      const StopwatchReset(),
                    ),
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
  final Color? color;
  final VoidCallback? onTap;

  /// 호버 시 단축키 표기 — 학습 장치 1층.
  final String? tooltip;

  const _Btn({
    required this.label,
    this.enabled = true,
    this.primary = false,
    this.danger = false,
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
    } else if (danger) {
      fg = AppColors.danger;
      border = const Color(0xFF554040);
    }
    if (!enabled) {
      bg = bg.withAlpha(0x55);
      fg = fg.withAlpha(0x55);
      border = border.withAlpha(0x55);
    }

    final btn = Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        splashColor: fg.withAlpha(0x44),
        highlightColor: fg.withAlpha(0x22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(color: fg, fontSize: 11, letterSpacing: 0.8),
          ),
        ),
      ),
    );
    if (tooltip == null) return btn;
    return Tooltip(message: tooltip!, child: btn);
  }
}
