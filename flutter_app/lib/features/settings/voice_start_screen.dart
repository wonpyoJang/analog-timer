import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../services/deep_link_service.dart';

/// "음성으로 시작"(디자인 "음성 연동 UX 디자인" §A·§F).
///
/// 어시스턴트 단축어(ShortcutManager)·인식은 실기기 검증이 필요해 후속. 이 화면은
/// 지금 바로 되는 것 — 발화 문구 안내 + 갤럭시 루틴 레시피(딥링크 복사)에 집중한다.
/// 루틴은 "개발 없이 되는" 가장 강력한 연동 수단(§5).
class VoiceStartScreen extends StatefulWidget {
  const VoiceStartScreen({super.key});

  @override
  State<VoiceStartScreen> createState() => _VoiceStartScreenState();
}

class _Recipe {
  final IconData icon;
  final String title;
  final String when;
  final String link;
  const _Recipe(this.icon, this.title, this.when, this.link);
}

class _VoiceStartScreenState extends State<VoiceStartScreen> {
  String? _copied; // 마지막으로 복사한 레시피 링크(스텝 노출용)

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final recipes = [
      _Recipe(
        Icons.desk_outlined,
        l.recipeDesk,
        l.recipeDeskWhen,
        'anytime://loop/focus25?silent=1',
      ),
      _Recipe(
        Icons.bolt_outlined,
        l.recipeCharge,
        l.recipeChargeWhen,
        'anytime://loop/focus25?silent=1',
      ),
      _Recipe(
        Icons.fitness_center_outlined,
        l.recipeWorkout,
        l.recipeWorkoutWhen,
        'anytime://workout',
      ),
      _Recipe(
        Icons.bedtime_outlined,
        l.recipeSleep,
        l.recipeSleepWhen,
        'anytime://stop?all=1',
      ),
    ];
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
          l.settingsVoiceStart,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 28),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Text(
              l.voiceStartSub,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 히어로: 뭐라고 말하면 되는지(설정이 아니라 대사가 위 — §A).
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF141416),
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withAlpha(0x1F),
                    border: Border.all(color: AppColors.accent.withAlpha(0x59)),
                  ),
                  child: const Icon(
                    Icons.mic_none,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l.voiceHeroQuote,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.voiceHeroHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.faint, fontSize: 12.5),
                ),
              ],
            ),
          ),
          _groupHead(l.voiceRoutineHead),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              l.voiceRoutineSub,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12.5,
                height: 1.6,
              ),
            ),
          ),
          _groupHead(l.voiceRecipeHead),
          Container(
            color: AppColors.surface,
            child: Column(
              children: [
                for (var i = 0; i < recipes.length; i++)
                  _recipeRow(l, recipes[i], first: i == 0),
              ],
            ),
          ),
          if (_copied != null) _steps(l),
        ],
      ),
    );
  }

  Future<void> _pick(AppLocalizations l, _Recipe r) async {
    await Clipboard.setData(ClipboardData(text: r.link));
    setState(() => _copied = r.link);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.routineCopied(r.title))));
  }

  Widget _recipeRow(AppLocalizations l, _Recipe r, {required bool first}) {
    return InkWell(
      onTap: () => _pick(l, r),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
        decoration: BoxDecoration(
          border: Border(
            top: first
                ? BorderSide.none
                : const BorderSide(color: Color(0xFF232326)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF2B2B2F),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(r.icon, size: 17, color: const Color(0xFFC9C7C2)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    r.when,
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              _copied == r.link ? Icons.check : Icons.copy_outlined,
              color: _copied == r.link ? AppColors.swGreen : AppColors.faint,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _steps(AppLocalizations l) {
    Widget step(String n, String title, String desc) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF232326),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                n,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _groupHead(l.routineStepsHead),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              step('1', l.routineStep1, l.routineStep1Desc),
              step('2', l.routineStep2, l.routineStep2Desc),
              step('3', l.routineStep3, l.routineStep3Desc),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _copied ?? '',
              style: const TextStyle(
                color: AppColors.swGreen,
                fontFamily: 'monospace',
                fontSize: 12.5,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final ok = await DeepLinkService.instance.openRoutinesApp();
                if (!ok && mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l.routineCantOpen)));
                }
              },
              child: Text(
                l.routineOpenApp,
                style: const TextStyle(
                  color: Color(0xFF141416),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _groupHead(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 20, 24, 9),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        color: AppColors.faint,
        fontSize: 12,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
