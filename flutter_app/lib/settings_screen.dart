import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import 'l10n/app_localizations.dart';
import 'services/battery_service.dart';
import 'theme/app_theme.dart';
import 'widgets/hotkey_record_field.dart';
import 'widgets/key_caps.dart';
import 'widgets/language_picker.dart';
import 'widgets/feedback_page.dart';
import 'services/platform_info.dart';
import 'services/hotkey_service.dart';
import 'services/tts_service.dart';
import 'services/text_scale_service.dart';
import 'services/haptic_service.dart';
import 'services/colorblind_service.dart';

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

          // ── 글씨 크기 (접근성) ─────────────────────────────────
          _TextSizeTile(),

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
                            context,
                            l.shortcutTimerToggle,
                            'timer_toggle',
                          ),
                          _hotkeyRow(
                            context,
                            l.shortcutTimerNext,
                            'timer_next',
                          ),
                          _hotkeyRow(context, l.shortcutSwLap, 'sw_lap'),
                          _hotkeyRow(
                            context,
                            l.shortcutWidgetFocus,
                            'widget_focus',
                          ),
                          // 시안 결정 4: 기본값과 달라졌을 때만 노출 —
                          // 평소엔 시각 소음 0.
                          if (HotkeyService.instance.isModified)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: TextButton(
                                  onPressed:
                                      HotkeyService.instance.resetBindings,
                                  child: Text(
                                    l.hotkeyReset,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.faint,
                                    ),
                                  ),
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
                      subtitle:
                          _voiceDisplayName(voice) ?? l.settingsTtsVoiceDefault,
                      onTap: () => _pickTtsVoice(context, l),
                    ),
                  ),
          ),

          const _Divider(),

          // ── 진동 피드백 (접근성) ──────────────────────────────
          ValueListenableBuilder<bool>(
            valueListenable: HapticService.instance.enabledListenable,
            builder: (ctx, hOn, _) => _SettingsTile(
              icon: Icons.vibration,
              iconColor: AppColors.accent,
              title: l.settingsHaptics,
              subtitle: l.settingsHapticsDesc,
              trailing: Switch(
                value: hOn,
                onChanged: HapticService.instance.setEnabled,
                activeThumbColor: AppColors.accent,
                trackColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColors.accent.withAlpha(0x55)
                      : AppColors.surface,
                ),
              ),
              onTap: () => HapticService.instance.setEnabled(!hOn),
            ),
          ),

          const _Divider(),

          // ── 색맹 모드 (접근성) ────────────────────────────────
          ValueListenableBuilder<bool>(
            valueListenable: ColorblindService.instance.enabledListenable,
            builder: (ctx, cbOn, _) => _SettingsTile(
              icon: Icons.palette_outlined,
              iconColor: AppColors.accent,
              title: l.settingsColorblind,
              subtitle: l.settingsColorblindDesc,
              trailing: Switch(
                value: cbOn,
                onChanged: ColorblindService.instance.setEnabled,
                activeThumbColor: AppColors.accent,
                trackColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColors.accent.withAlpha(0x55)
                      : AppColors.surface,
                ),
              ),
              onTap: () => ColorblindService.instance.setEnabled(!cbOn),
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

/// 핫키 액션 한 줄 — 라벨 + 키캡 분리형 조합. 탭하면 녹화 다이얼로그.
///
/// 시안 결정 2: 선점(⚠) 상태는 **라벨 밑 왼쪽 힌트 줄**로, 키캡은 45%
/// 디밍만 — 위험이 아니라 "미등록"이므로 빨간 테두리·행 배경 변화 없음.
/// 문구 길이 가변(15개 언어)에도 레이아웃이 안전하다.
Widget _hotkeyRow(BuildContext context, String label, String action) {
  final combo = HotkeyService.instance.describe(action);
  final l = AppLocalizations.of(context);
  return ValueListenableBuilder<Set<String>>(
    valueListenable: HotkeyService.instance.failedActions,
    builder: (ctx, failed, _) {
      final taken = failed.contains(action);
      return InkWell(
        onTap: () => _recordHotkey(context, label, action),
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(56, 9, 20, 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.text,
                      ),
                    ),
                    if (taken)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Row(
                          children: [
                            const Text(
                              '⚠',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: AppColors.danger,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                l.hotkeyTakenWarning,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFC98080),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              KeyCaps(combo: combo, dim: taken),
            ],
          ),
        ),
      );
    },
  );
}

/// 초심자 힌트 본문 — 번역문 속 {example} 자리에 실제 키캡([Ctrl][L])을
/// 인라인으로 끼워 넣는다(개체 치환 문자로 분할 후 WidgetSpan 삽입).
Widget _guideText(AppLocalizations l) {
  const marker = '￼';
  final line1 = l.hotkeyRecordGuide1(marker).split(marker);
  const style = TextStyle(
    fontSize: 11.5,
    height: 1.8,
    color: Color(0xFFA8A5A0),
  );
  return Text.rich(
    TextSpan(
      children: [
        for (var i = 0; i < line1.length; i++) ...[
          if (i > 0)
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: KeyCaps(combo: 'Ctrl+L', fontSize: 10),
            ),
          TextSpan(text: line1[i]),
        ],
        const TextSpan(text: '\n'),
        TextSpan(text: l.hotkeyRecordGuide2),
      ],
    ),
    style: style,
  );
}

/// 액션 id → 표시 라벨 (중복 오류 문구에 "어느 액션과 겹치는지" 명시용).
String _actionLabel(AppLocalizations l, String action) => switch (action) {
  'timer_toggle' => l.shortcutTimerToggle,
  'timer_next' => l.shortcutTimerNext,
  'sw_lap' => l.shortcutSwLap,
  'widget_focus' => l.shortcutWidgetFocus,
  _ => action,
};

/// 조합 녹화 다이얼로그 — 시안 스펙(핫키 설정 UI):
/// 제목 옆 "now: 현재조합" 컨텍스트, 미리보기 박스(대기 커서→진행형→확정),
/// 오류/안내가 같은 슬롯을 공유해 높이가 흔들리지 않는다. 안내문은
/// **조합 확정 후에만**(사실 서술 톤). 여는 동안 전역 핫키 해제(등록된
/// 조합은 OS 가 가로채 녹화 불가).
Future<void> _recordHotkey(
  BuildContext context,
  String label,
  String action,
) async {
  final l = AppLocalizations.of(context);
  HotKey? recorded;
  var touched = false; // 키 입력 시작 → 초심자 힌트 숨김(시안)
  await HotkeyService.instance.suspendForRecording();
  try {
    if (!context.mounted) return;
    final current = HotkeyService.instance.describe(action);
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setState) {
          final noMod =
              recorded != null && !HotkeyService.isSaneBinding(recorded!);
          final dup = recorded == null
              ? null
              : HotkeyService.instance.conflictingAction(action, recorded!);
          final canSave = recorded != null && !noMod && dup == null;
          return Dialog(
            backgroundColor: const Color(0xFF1E1E21),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Container(
              width: 316,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      Text(
                        l.hotkeyNow(current),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.faint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l.hotkeyRecordPrompt,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  HotkeyRecordField(
                    initial: null, // 대기 상태(커서)에서 시작 — 시안
                    error: noMod || dup != null,
                    onRecorded: (hk) => setState(() => recorded = hk),
                    onActivity: () {
                      if (!touched) setState(() => touched = true);
                    },
                  ),
                  // 초심자 힌트 — 대기 상태에만. 키를 누르기 시작하면 사라져
                  // 경험자에겐 방해가 없다(시안). 둘째 줄: 앱이 감지 못하는
                  // 타앱 로컬 단축키 충돌을 사전에 줄이는 선택 가이드.
                  if (!touched && recorded == null)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.14),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ℹ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.accent,
                              height: 1.8,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: _guideText(l)),
                        ],
                      ),
                    ),
                  // 오류/안내 공유 슬롯 — 높이 고정으로 다이얼로그 안 흔들림.
                  Container(
                    constraints: const BoxConstraints(minHeight: 30),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(4, 7, 4, 0),
                    child: noMod
                        // 누른 키를 인정하며 방법을 가르치는 톤(시안) —
                        // {key}엔 수식키를 뗀 키 이름만 넣는다.
                        ? Text(
                            l.hotkeyNeedModifier(
                              HotkeyService.describeHotKey(
                                HotKey(
                                  key: recorded!.key,
                                  scope: HotKeyScope.system,
                                ),
                              ),
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11.5,
                              height: 1.5,
                              color: AppColors.danger,
                            ),
                          )
                        : dup != null
                        ? Text(
                            l.hotkeyDuplicate(_actionLabel(l, dup)),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11.5,
                              height: 1.5,
                              color: AppColors.danger,
                            ),
                          )
                        : canSave
                        ? Text(
                            l.hotkeyRecordCaution,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11.5,
                              height: 1.5,
                              color: AppColors.faint,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx2),
                        child: Text(
                          l.cancel,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      TextButton(
                        onPressed: canSave
                            ? () {
                                HotkeyService.instance.setBinding(
                                  action,
                                  recorded!,
                                );
                                Navigator.pop(ctx2);
                              }
                            : null,
                        child: Text(
                          l.save,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: canSave ? AppColors.accent : AppColors.faint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
          }) => ListTile(
            dense: true,
            title: Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                color: selected ? AppColors.accent : AppColors.text,
              ),
            ),
            subtitle: sub == null
                ? null
                : Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
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
                child: Text(
                  l.settingsTtsVoice,
                  style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    color: AppColors.muted,
                  ),
                ),
              ),
              row(
                label: l.settingsTtsVoiceDefault,
                selected: current == null,
                onTap: () => TtsService.instance.setVoice(
                  null,
                  sample: l.settingsTtsVoicePreview,
                  localeTag: localeTag,
                ),
              ),
              for (final v in voices)
                row(
                  label: _voiceDisplayName(v)!,
                  sub: v['locale'],
                  selected: current != null && current['name'] == v['name'],
                  onTap: () => TtsService.instance.setVoice(
                    v,
                    sample: l.settingsTtsVoicePreview,
                    localeTag: localeTag,
                  ),
                ),
              if (voices.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l.ttsVoiceMissingHint,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
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

/// 글씨 크기 프리셋 4단계 — 저시력 접근성. 탭 즉시 앱 전역에 반영(라이브 미리보기).
class _TextSizeTile extends StatelessWidget {
  static const _presets = [0.85, 1.0, 1.2, 1.4];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = [
      l.textSizeSmall,
      l.textSizeNormal,
      l.textSizeLarge,
      l.textSizeXLarge,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(0x22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.format_size,
                  size: 18,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                l.settingsTextSize,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  color: AppColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<double>(
            valueListenable: TextScaleService.instance.scaleListenable,
            builder: (context, scale, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < _presets.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: _sizeButton(
                            label: labels[i],
                            selected: (scale - _presets[i]).abs() < 0.01,
                            onTap: () =>
                                TextScaleService.instance.setScale(_presets[i]),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 미리보기 — 화면 전체가 이미 배율을 타므로 현재 크기 그대로 보임
                  Text(
                    l.textSizePreview,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _sizeButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent.withAlpha(0x22)
                : AppColors.surface,
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12.5,
              color: selected ? AppColors.accent : AppColors.muted,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
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
