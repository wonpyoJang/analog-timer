
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import 'l10n/app_localizations.dart';
import 'services/battery_service.dart';
import 'theme/app_theme.dart';
import 'widgets/language_picker.dart';
import 'widgets/feedback_page.dart';
import 'services/platform_info.dart';
import 'services/hotkey_service.dart';
import 'services/tts_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    // 현재 선택된 언어 이름 (시스템 기본이면 l.languageSystem)
    const langLabels = {
      'en': 'English',
      'ko': '한국어',
      'zh': '中文',
      'es': 'Español',
      'ar': 'العربية',
      'pt': 'Português',
      'fr': 'Français',
      'ja': '日本語',
      'de': 'Deutsch',
      'ru': 'Русский',
      'hi': 'हिन्दी',
      'id': 'Bahasa Indonesia',
      'it': 'Italiano',
      'tr': 'Türkçe',
    };
    final langLabel = langLabels[locale.languageCode] ?? l.languageSystem;

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
          l.settings,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── 언어 ──────────────────────────────────────────────
          _SettingsTile(
            icon: Icons.language,
            iconColor: AppColors.accent,
            title: l.settingsLanguage,
            trailing: Text(
              langLabel,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                fontFamily: 'Pretendard',
              ),
            ),
            onTap: () => showLanguagePicker(context),
          ),

          const _Divider(),

          // ── 제작자에게 피드백 (버그/기능요청, 사진·동영상 첨부) ──────
          _SettingsTile(
            icon: Icons.send_outlined,
            iconColor: AppColors.timerOrange,
            title: l.feedbackEntry,
            subtitle: l.feedbackEntryDesc,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FeedbackPage()),
            ),
          ),

          const _Divider(),

          // ── 전역 단축키 (데스크톱) — 다른 앱에서도 타이머 조작 ─────
          if (isDesktop) ...[
            ValueListenableBuilder<bool>(
              valueListenable: HotkeyService.instance.enabledListenable,
              builder: (ctx, hkOn, _) => Column(
                children: [
                  _SettingsTile(
                    icon: Icons.keyboard_outlined,
                    iconColor: AppColors.accent,
                    title: l.settingsHotkeys,
                    subtitle: l.settingsHotkeysDesc,
                    trailing: Switch(
                      value: hkOn,
                      onChanged: HotkeyService.instance.setEnabled,
                      activeThumbColor: AppColors.accent,
                      trackColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? AppColors.accent.withAlpha(0x55)
                            : AppColors.surface,
                      ),
                    ),
                    onTap: () => HotkeyService.instance.setEnabled(!hkOn),
                  ),
                  // 액션별 조합 — 탭하면 녹화 다이얼로그로 변경.
                  if (hkOn)
                    ValueListenableBuilder<int>(
                      valueListenable: HotkeyService.instance.bindingsRev,
                      builder: (ctx2, _, _) => Column(
                        children: [
                          _hotkeyRow(
                              context, l.shortcutTimerToggle, 'timer_toggle'),
                          _hotkeyRow(
                              context, l.shortcutTimerNext, 'timer_next'),
                          _hotkeyRow(context, l.shortcutSwLap, 'sw_lap'),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: TextButton(
                                onPressed:
                                    HotkeyService.instance.resetBindings,
                                child: Text(l.hotkeyReset,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.muted)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const _Divider(),
          ],

          // ── 음성 안내 (TTS) — 세그먼트 전환/완료를 소리로 ────────
          ValueListenableBuilder<bool>(
            valueListenable: TtsService.instance.enabledListenable,
            builder: (ctx, ttsOn, _) => _SettingsTile(
              icon: Icons.record_voice_over_outlined,
              iconColor: AppColors.accent,
              title: l.settingsTts,
              subtitle: l.settingsTtsDesc,
              trailing: Switch(
                value: ttsOn,
                onChanged: (v) => TtsService.instance.setEnabled(
                  v,
                  sample: l.settingsTtsSample,
                  localeTag: Localizations.localeOf(context).toLanguageTag(),
                ),
                activeThumbColor: AppColors.accent,
                trackColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColors.accent.withAlpha(0x55)
                      : AppColors.surface,
                ),
              ),
              onTap: () => TtsService.instance.setEnabled(
                !ttsOn,
                sample: l.settingsTtsSample,
                localeTag: Localizations.localeOf(context).toLanguageTag(),
              ),
            ),
          ),

          // ── 음성 스타일 (TTS 켜졌을 때만) — 선택 즉시 미리듣기 ────
          ValueListenableBuilder<bool>(
            valueListenable: TtsService.instance.enabledListenable,
            builder: (ctx, ttsOn, _) => !ttsOn
                ? const SizedBox.shrink()
                : ValueListenableBuilder<Map<String, String>?>(
                    valueListenable: TtsService.instance.voiceListenable,
                    builder: (ctx2, voice, _) => _SettingsTile(
                      icon: Icons.graphic_eq,
                      iconColor: AppColors.accent,
                      title: l.settingsTtsVoice,
                      subtitle: _voiceDisplayName(voice) ??
                          l.settingsTtsVoiceDefault,
                      onTap: () => _pickTtsVoice(context, l),
                    ),
                  ),
          ),

          const _Divider(),

          // ── 배터리 모니터링 (모바일 전용) ─────────────────────
          if (isAndroid || isIOS) ...[
            ValueListenableBuilder<bool>(
              valueListenable: BatteryService.instance.monitoringEnabled,
              builder: (ctx, enabled, _) => _SettingsTile(
                icon: Icons.battery_std,
                iconColor: const Color(0xFFB45309),
                title: l.settingsBattery,
                subtitle: l.settingsBatteryDesc,
                trailing: Switch(
                  value: enabled,
                  onChanged: BatteryService.instance.setEnabled,
                  activeThumbColor: const Color(0xFFB45309),
                  trackColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? const Color(0xFFB45309).withAlpha(0x55)
                        : AppColors.surface,
                  ),
                ),
                onTap: () => BatteryService.instance.setEnabled(!enabled),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 핫키 액션 한 줄 — 라벨 + 현재 조합 뱃지. 탭하면 녹화 다이얼로그.
Widget _hotkeyRow(BuildContext context, String label, String action) {
  final combo = HotkeyService.instance.describe(action);
  return InkWell(
    onTap: () => _recordHotkey(context, label, action),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(56, 6, 20, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.text)),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.bg,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(combo,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.text)),
          ),
        ],
      ),
    ),
  );
}

/// 조합 녹화 다이얼로그 — 원하는 키를 누르면 미리보기, 저장으로 확정.
///
/// 여는 동안 전역 핫키를 해제한다(등록된 조합은 OS 가 가로채 녹화가 안 됨).
Future<void> _recordHotkey(
    BuildContext context, String label, String action) async {
  final l = AppLocalizations.of(context);
  HotKey? recorded;
  await HotkeyService.instance.suspendForRecording();
  try {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setState) {
          // 검증: 수식키 없는 단일 키를 전역 등록하면 그 키가 시스템 전체에서
          // 삼켜진다. 중복 조합은 둘 중 하나가 조용히 등록 실패한다.
          final mods = recorded?.modifiers ?? const <HotKeyModifier>[];
          final noMod = recorded != null && mods.isEmpty;
          final dup = recorded == null
              ? null
              : HotkeyService.instance.conflictingAction(action, recorded!);
          final invalid = recorded == null || noMod || dup != null;
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(label,
                style: const TextStyle(fontSize: 15, color: AppColors.text)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.hotkeyRecordPrompt,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.muted)),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: HotKeyRecorder(
                    initalHotKey: HotkeyService.instance.binding(action),
                    onHotKeyRecorded: (hk) => setState(() => recorded = hk),
                  ),
                ),
                if (noMod || dup != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    noMod ? l.hotkeyNeedModifier : l.hotkeyDuplicate,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 11.5, color: AppColors.danger),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx2),
                child: Text(l.cancel,
                    style: const TextStyle(color: AppColors.muted)),
              ),
              TextButton(
                onPressed: invalid
                    ? null
                    : () {
                        HotkeyService.instance.setBinding(action, recorded!);
                        Navigator.pop(ctx2);
                      },
                child: Text(l.save,
                    style: TextStyle(
                        color: invalid ? AppColors.muted : AppColors.accent)),
              ),
            ],
          );
        },
      ),
    );
  } finally {
    await HotkeyService.instance.resumeAfterRecording();
  }
}

/// Windows 음성 이름 정리 — "Microsoft Zira - English (US)" → "Zira - English (US)".
String? _voiceDisplayName(Map<String, String>? v) {
  if (v == null) return null;
  return v['name']!.replaceFirst(RegExp(r'^Microsoft\s+'), '');
}

/// 음성 스타일 선택 바텀시트 — 항목 탭 = 선택 + 즉시 미리듣기.
/// 시트를 닫지 않아 여러 음성을 연달아 들어보고 고를 수 있다.
Future<void> _pickTtsVoice(BuildContext context, AppLocalizations l) async {
  final localeTag = Localizations.localeOf(context).toLanguageTag();
  final voices = await TtsService.instance.availableVoices(localeTag);
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
    ),
    builder: (ctx) => SafeArea(
      child: ValueListenableBuilder<Map<String, String>?>(
        valueListenable: TtsService.instance.voiceListenable,
        builder: (ctx2, current, _) {
          Widget row({
            required String label,
            required bool selected,
            required VoidCallback onTap,
            String? sub,
          }) =>
              ListTile(
                dense: true,
                title: Text(label,
                    style: TextStyle(
                        fontSize: 13.5,
                        color: selected ? AppColors.accent : AppColors.text)),
                subtitle: sub == null
                    ? null
                    : Text(sub,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.muted)),
                trailing: selected
                    ? const Icon(Icons.check, size: 16, color: AppColors.accent)
                    : null,
                onTap: onTap,
              );
          return ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(l.settingsTtsVoice,
                    style: const TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        color: AppColors.muted)),
              ),
              row(
                label: l.settingsTtsVoiceDefault,
                selected: current == null,
                onTap: () => TtsService.instance.setVoice(null,
                    sample: l.settingsTtsVoicePreview, localeTag: localeTag),
              ),
              for (final v in voices)
                row(
                  label: _voiceDisplayName(v)!,
                  sub: v['locale'],
                  selected: current != null && current['name'] == v['name'],
                  onTap: () => TtsService.instance.setVoice(v,
                      sample: l.settingsTtsVoicePreview, localeTag: localeTag),
                ),
              if (voices.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l.ttsVoiceMissingHint,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
                ),
            ],
          );
        },
      ),
    ),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.accent.withAlpha(0x22),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(0x22),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 68,
      endIndent: 0,
      color: AppColors.border,
    );
  }
}
