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
import 'services/telemetry_service.dart';
import 'services/desktop_notification_service.dart';
import 'services/hotkey_service.dart';
import 'services/tts_service.dart';
import 'services/text_scale_service.dart';
import 'services/haptic_service.dart';
import 'services/sound_service.dart';
import 'services/care_service.dart';
import 'services/colorblind_service.dart';
import 'services/high_contrast_service.dart';
import 'features/stats/stats_screen.dart';
import 'features/onboarding/alarm_diagnostics_screen.dart';
import 'services/alarm_readiness_service.dart';
import 'services/list_display_service.dart';
import 'services/overlay_settings_service.dart';
import 'overlay/overlay_coordinator.dart';

class SettingsScreen extends StatelessWidget {
  /// 하단 탭으로 임베드될 때 true — 뒤로가기 화살표를 숨긴다.
  final bool embedded;
  const SettingsScreen({super.key, this.embedded = false});

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
        automaticallyImplyLeading: false,
        leading: embedded
            ? null
            : IconButton(
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
          // ── 알람 점검 카드(디자인 §3) — 배터리 예외/알림이 깨졌을 때만 노출.
          if (isAndroid) const _AlarmCheckCard(),

          // ══ 그룹 1: 알림 방식 ═════════════════════════════════
          _GroupHeader(l.settingsGroupNotify),

          // ── 상세 페이지 진입(디자인 §A·§B·§C) — 붐비던 알림 방식 그룹을
          //    3개 상세 페이지로 분리해 메인을 간결하게.
          if (!isDesktop) ...[
            _SettingsTile(
              icon: Icons.notifications_active_outlined,
              iconColor: AppColors.accent,
              title: l.settingsAlarmSection,
              subtitle: l.settingsAlarmSectionDesc,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _AlarmSettingsPage()),
              ),
            ),
            const _Divider(),
            _SettingsTile(
              icon: Icons.music_note_outlined,
              iconColor: AppColors.accent,
              title: l.settingsSoundSection,
              subtitle: l.settingsSoundSectionDesc,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _SoundSettingsPage()),
              ),
            ),
            const _Divider(),
          ],
          _SettingsTile(
            icon: Icons.record_voice_over_outlined,
            iconColor: AppColors.accent,
            title: l.settingsVoiceSection,
            subtitle: l.settingsVoiceSectionDesc,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const _VoiceSettingsPage()),
            ),
          ),
          if (isDesktop) const _Divider(),

          // ── 알림 (데스크톱 — 구간 전환·완료 토스트) ───────────
          if (isDesktop) ...[
            ValueListenableBuilder<bool>(
              valueListenable: DesktopNotificationService.enabledListenable,
              builder: (ctx, nOn, _) => _SettingsTile(
                icon: Icons.notifications_outlined,
                iconColor: AppColors.accent,
                title: l.settingsNotifications,
                subtitle: l.settingsNotificationsDesc,
                trailing: Switch(
                  value: nOn,
                  onChanged: DesktopNotificationService.setEnabled,
                  activeThumbColor: AppColors.accent,
                  trackColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? AppColors.accent.withAlpha(0x55)
                        : AppColors.surface,
                  ),
                ),
                onTap: () => DesktopNotificationService.setEnabled(!nOn),
              ),
            ),
            const _Divider(),
          ],

          // ══ 그룹 2: 화면 표시 ═════════════════════════════════
          _GroupHeader(l.settingsGroupDisplay),

          // ── 글씨 크기 (접근성) ─────────────────────────────────
          _TextSizeTile(),

          const _Divider(),

          // ── 언어 ──────────────────────────────────────────────
          _SettingsTile(
            icon: Icons.language,
            iconColor: AppColors.accent,
            title: l.settingsLanguage,
            trailing: Text(
              langLabel,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                fontFamily: 'Pretendard',
              ),
            ),
            onTap: () => showLanguagePicker(context),
          ),

          const _Divider(),

          // ── 고대비 (접근성) ───────────────────────────────────
          ValueListenableBuilder<bool>(
            valueListenable: HighContrastService.instance.enabledListenable,
            builder: (ctx, hcOn, _) => _SettingsTile(
              icon: Icons.contrast,
              iconColor: AppColors.accent,
              title: l.settingsHighContrast,
              subtitle: l.settingsHighContrastDesc,
              trailing: Switch(
                value: hcOn,
                onChanged: HighContrastService.instance.setEnabled,
                activeThumbColor: AppColors.accent,
                trackColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColors.accent.withAlpha(0x55)
                      : AppColors.surface,
                ),
              ),
              onTap: () => HighContrastService.instance.setEnabled(!hcOn),
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

          // ── 리스트 표시 상세 페이지(디자인 §E) — 멀티 타이머 리스트 표시.
          _SettingsTile(
            icon: Icons.view_agenda_outlined,
            iconColor: AppColors.accent,
            title: l.settingsListSection,
            subtitle: l.settingsListSectionDesc,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const _ListSettingsPage()),
            ),
          ),

          // ══ 그룹 3: 내 데이터 ═════════════════════════════════
          _GroupHeader(l.settingsGroupData),

          // ── 활동 통계 (완료 로그 자동 집계) ────────────────────
          _SettingsTile(
            icon: Icons.bar_chart,
            iconColor: AppColors.accent,
            title: l.settingsStats,
            subtitle: l.settingsStatsDesc,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            ),
          ),

          // ── 배터리 모니터링 (모바일 전용) ─────────────────────
          if (isAndroid || isIOS) ...[
            const _Divider(),
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

          // ── 진단 데이터 전송 (Android — ANR-free 지표 동의) ────
          if (isAndroid) ...[const _Divider(), const _TelemetryConsentTile()],

          // ══ 그룹 4: 조작 ═════════════════════════════════════
          if (isDesktop || isAndroid) _GroupHeader(l.settingsGroupControl),

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
                                    style: TextStyle(
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

          // ── 오버레이 pill 상세 페이지(디자인 §D, Android 전용) ─────
          if (isAndroid) ...[
            _SettingsTile(
              icon: Icons.picture_in_picture_alt_outlined,
              iconColor: AppColors.accent,
              title: l.settingsOverlaySection,
              subtitle: l.settingsOverlaySectionDesc,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _OverlaySettingsPage()),
              ),
            ),
            const _Divider(),
          ],

          // ── 오버레이 상호 배타 (Android 전용) ──────────────────
          if (isAndroid) ...[
            ValueListenableBuilder<bool>(
              valueListenable: OverlayCoordinator.instance.enabledListenable,
              builder: (ctx, mxOn, _) => _SettingsTile(
                icon: Icons.layers_clear_outlined,
                iconColor: AppColors.accent,
                title: l.settingsOverlayMutex,
                subtitle: l.settingsOverlayMutexDesc,
                trailing: Switch(
                  value: mxOn,
                  onChanged: OverlayCoordinator.instance.setEnabled,
                  activeThumbColor: AppColors.accent,
                  trackColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? AppColors.accent.withAlpha(0x55)
                        : AppColors.surface,
                  ),
                ),
                onTap: () => OverlayCoordinator.instance.setEnabled(!mxOn),
              ),
            ),
            const _Divider(),
          ],

          // ══ 그룹 5: 도움 ═════════════════════════════════════
          _GroupHeader(l.settingsGroupHelp),

          // ── 알람 점검 (자가 진단 — 알림·배터리·오버레이 체크) ──────
          if (isAndroid)
            _SettingsTile(
              icon: Icons.health_and_safety_outlined,
              iconColor: AppColors.accent,
              title: l.settingsDiag,
              subtitle: l.settingsDiagDesc,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AlarmDiagnosticsScreen(),
                ),
              ),
            ),
          if (isAndroid) const _Divider(),

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
        ],
      ),
    );
  }
}

/// Android 진단 동의 토글 — telemetry_consent(pref)를 읽고 쓴다. 켜면 ANR-free 지표가
/// 다음 실행부터 전송된다(AnrVitalsService 가 같은 pref 로 게이팅).
// ══ 상세 설정 페이지(디자인 "설정 상세 페이지" §A·§B·§C) ═══════════════
// 붐비던 알림 방식 그룹을 알람·재알림 / 사운드 / 음성 안내 3개로 분리.

/// 상세 페이지 공통 껍데기 — 제목 + 한 줄 안내 + 설정 그룹들.
class _DetailScaffold extends StatelessWidget {
  final String title;
  final String sub;
  final List<Widget> children;
  const _DetailScaffold({
    required this.title,
    required this.sub,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
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
          title,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
            child: Text(
              sub,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// 상세 페이지 공통 스위치 스타일.
Switch _detailSwitch(bool on, ValueChanged<bool> onChanged) => Switch(
  value: on,
  onChanged: onChanged,
  activeThumbColor: AppColors.accent,
  trackColor: WidgetStateProperty.resolveWith(
    (states) => states.contains(WidgetState.selected)
        ? AppColors.accent.withAlpha(0x55)
        : AppColors.surface,
  ),
);

/// 선택 칩 행 — 현재값 강조(디자인 §G: 숫자 값은 행에 노출).
Widget _detailChips<T>(
  List<T> options,
  T current,
  ValueChanged<T> onSelect,
  String Function(T) label,
) => Padding(
  padding: const EdgeInsets.fromLTRB(56, 0, 16, 12),
  child: Align(
    alignment: Alignment.centerLeft,
    child: Wrap(
      spacing: 8,
      children: [
        for (final v in options)
          ChoiceChip(
            label: Text(label(v)),
            selected: current == v,
            onSelected: (_) => onSelect(v),
            selectedColor: AppColors.accent.withAlpha(0x33),
            backgroundColor: AppColors.surface,
            labelStyle: TextStyle(
              color: current == v ? AppColors.accent : AppColors.muted,
              fontSize: 13,
            ),
            side: BorderSide(
              color: current == v ? AppColors.accent : AppColors.border,
            ),
          ),
      ],
    ),
  ),
);

/// A · 알람 · 재알림 (디자인 §A) — 확인 전까지 반복 + 카테고리별 간격.
class _AlarmSettingsPage extends StatelessWidget {
  const _AlarmSettingsPage();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final care = CareService.instance;
    return _DetailScaffold(
      title: l.settingsAlarmSection,
      sub: l.alarmPageSub,
      children: [
        _GroupHeader(l.grpAlarmBasic),
        ValueListenableBuilder<bool>(
          valueListenable: care.realarm,
          builder: (ctx, rOn, _) => _SettingsTile(
            icon: Icons.notification_important_outlined,
            iconColor: AppColors.accent,
            title: l.careRealarm,
            subtitle: l.careRealarmDesc,
            trailing: _detailSwitch(rOn, care.setRealarm),
            onTap: () => care.setRealarm(!rOn),
          ),
        ),
        ValueListenableBuilder<int>(
          valueListenable: care.preAlarmMin,
          builder: (ctx, pre, _) => Column(
            children: [
              _SettingsTile(
                icon: Icons.notifications_paused_outlined,
                iconColor: AppColors.accent,
                title: l.carePreAlarm,
                subtitle: l.carePreAlarmDesc,
              ),
              _detailChips<int>(
                const [0, 1, 2, 5],
                pre,
                care.setPreAlarmMin,
                (v) => v == 0 ? l.carePreAlarmOff : l.carePreAlarmMin(v),
              ),
            ],
          ),
        ),
        _GroupHeader(l.grpAlarmInterval),
        for (final iv in const ['cooking', 'chore', 'other'])
          ValueListenableBuilder<int>(
            valueListenable: switch (iv) {
              'cooking' => care.intervalCookingMin,
              'chore' => care.intervalChoreMin,
              _ => care.intervalOtherMin,
            },
            builder: (ctx, cur, _) => Column(
              children: [
                _SettingsTile(
                  icon: Icons.timer_outlined,
                  iconColor: AppColors.accent,
                  title: switch (iv) {
                    'cooking' => l.careIntervalCooking,
                    'chore' => l.careIntervalChore,
                    _ => l.careIntervalOther,
                  },
                ),
                _detailChips<int>(
                  const [1, 2, 5],
                  cur,
                  (v) => care.setInterval(iv, v),
                  (v) => l.carePreAlarmMin(v),
                ),
              ],
            ),
          ),
        _GroupHeader(l.grpAlarmDone),
        ValueListenableBuilder<String>(
          valueListenable: care.messageTone,
          builder: (ctx, tone, _) => Column(
            children: [
              _SettingsTile(
                icon: Icons.chat_bubble_outline,
                iconColor: AppColors.accent,
                title: l.careTone,
                subtitle: l.careToneDesc,
              ),
              _detailChips<String>(
                const ['warm', 'neutral', 'brief'],
                tone,
                care.setMessageTone,
                (v) => switch (v) {
                  'warm' => l.careToneWarm,
                  'brief' => l.careToneBrief,
                  _ => l.careToneNeutral,
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(56, 0, 24, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(switch (tone) {
                    'warm' => l.doneMsgWarm(l.multiTimerTitle),
                    'brief' => l.doneMsgBrief(l.multiTimerTitle),
                    _ => l.doneMsgNeutral(l.multiTimerTitle),
                  }, style: TextStyle(color: AppColors.faint, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// B · 사운드 (디자인 §B) — 세트 선택 + 진동/방해 금지.
class _SoundSettingsPage extends StatelessWidget {
  const _SoundSettingsPage();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _DetailScaffold(
      title: l.settingsSoundSection,
      sub: l.soundPageSub,
      children: [
        _GroupHeader(l.grpSoundSet),
        ValueListenableBuilder<bool>(
          valueListenable: SoundService.instance.enabledListenable,
          builder: (ctx, sOn, _) => Column(
            children: [
              _SettingsTile(
                icon: Icons.music_note_outlined,
                iconColor: AppColors.accent,
                title: l.settingsSounds,
                subtitle: l.settingsSoundsDesc,
                trailing: _detailSwitch(sOn, SoundService.instance.setEnabled),
                onTap: () => SoundService.instance.setEnabled(!sOn),
              ),
              if (sOn)
                ValueListenableBuilder<String>(
                  valueListenable: SoundService.instance.setListenable,
                  builder: (ctx2, cur, _) => _detailChips<String>(
                    const ['pop', 'wood', 'glass', 'retro'],
                    cur,
                    SoundService.instance.setSoundSet,
                    (v) => switch (v) {
                      'pop' => l.soundSetPop,
                      'wood' => l.soundSetWood,
                      'glass' => l.soundSetGlass,
                      _ => l.soundSetRetro,
                    },
                  ),
                ),
            ],
          ),
        ),
        _GroupHeader(l.grpSoundFeedback),
        ValueListenableBuilder<bool>(
          valueListenable: HapticService.instance.enabledListenable,
          builder: (ctx, hOn, _) => _SettingsTile(
            icon: Icons.vibration,
            iconColor: AppColors.accent,
            title: l.settingsHaptics,
            subtitle: l.settingsHapticsDesc,
            trailing: _detailSwitch(hOn, HapticService.instance.setEnabled),
            onTap: () => HapticService.instance.setEnabled(!hOn),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: CareService.instance.quietHours,
          builder: (ctx, qOn, _) => _SettingsTile(
            icon: Icons.bedtime_outlined,
            iconColor: AppColors.accent,
            title: l.careQuietHours,
            subtitle: l.careQuietHoursDesc,
            trailing: _detailSwitch(qOn, CareService.instance.setQuietHours),
            onTap: () => CareService.instance.setQuietHours(!qOn),
          ),
        ),
      ],
    );
  }
}

/// C · 음성 안내 (디자인 §C) — TTS 켜기 + 목소리·속도·이름·시보.
class _VoiceSettingsPage extends StatelessWidget {
  const _VoiceSettingsPage();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tts = TtsService.instance;
    String localeTag() => Localizations.localeOf(context).toLanguageTag();
    return _DetailScaffold(
      title: l.settingsVoiceSection,
      sub: l.voicePageSub,
      children: [
        _GroupHeader(l.grpVoiceUse),
        ValueListenableBuilder<bool>(
          valueListenable: tts.enabledListenable,
          builder: (ctx, ttsOn, _) => _SettingsTile(
            icon: Icons.record_voice_over_outlined,
            iconColor: AppColors.accent,
            title: l.settingsTts,
            subtitle: l.settingsTtsDesc,
            trailing: _detailSwitch(
              ttsOn,
              (v) => tts.setEnabled(
                v,
                sample: l.settingsTtsSample,
                localeTag: localeTag(),
              ),
            ),
            onTap: () => tts.setEnabled(
              !ttsOn,
              sample: l.settingsTtsSample,
              localeTag: localeTag(),
            ),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: tts.enabledListenable,
          builder: (ctx, ttsOn, _) => !ttsOn
              ? const SizedBox.shrink()
              : Column(
                  children: [
                    _GroupHeader(l.grpVoiceVoice),
                    ValueListenableBuilder<Map<String, String>?>(
                      valueListenable: tts.voiceListenable,
                      builder: (ctx2, voice, _) => _SettingsTile(
                        icon: Icons.graphic_eq,
                        iconColor: AppColors.accent,
                        title: l.settingsTtsVoice,
                        subtitle:
                            _voiceDisplayName(voice) ??
                            l.settingsTtsVoiceDefault,
                        onTap: () => _pickTtsVoice(context, l),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.speed,
                      iconColor: AppColors.accent,
                      title: l.settingsSpeechRate,
                    ),
                    ValueListenableBuilder<double>(
                      valueListenable: tts.speechRateListenable,
                      builder: (ctx2, rate, _) => _detailChips<double>(
                        const [0.35, 0.5, 0.65],
                        rate,
                        (v) => tts.setSpeechRate(
                          v,
                          sample: l.settingsTtsSample,
                          localeTag: localeTag(),
                        ),
                        (v) => v <= 0.35
                            ? l.speechRateSlow
                            : (v >= 0.65
                                  ? l.speechRateFast
                                  : l.speechRateNormal),
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: CareService.instance.ttsName,
                      builder: (ctx2, tOn, _) => _SettingsTile(
                        icon: Icons.badge_outlined,
                        iconColor: AppColors.accent,
                        title: l.careTtsName,
                        subtitle: l.careTtsNameDesc,
                        trailing: _detailSwitch(
                          tOn,
                          CareService.instance.setTtsName,
                        ),
                        onTap: () => CareService.instance.setTtsName(!tOn),
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: tts.hourlyChimeListenable,
                      builder: (ctx2, chimeOn, _) => _SettingsTile(
                        icon: Icons.schedule,
                        iconColor: AppColors.accent,
                        title: l.settingsHourlyChime,
                        subtitle: l.settingsHourlyChimeDesc,
                        trailing: _detailSwitch(
                          chimeOn,
                          (v) => tts.setHourlyChime(
                            v,
                            sample: l.settingsTtsSample,
                            localeTag: localeTag(),
                          ),
                        ),
                        onTap: () => tts.setHourlyChime(
                          !chimeOn,
                          sample: l.settingsTtsSample,
                          localeTag: localeTag(),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// E · 리스트 표시 (디자인 §E) — 멀티 타이머 리스트 표시 방식(view-only).
class _ListSettingsPage extends StatelessWidget {
  const _ListSettingsPage();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lds = ListDisplayService.instance;
    return _DetailScaffold(
      title: l.settingsListSection,
      sub: l.listPageSub,
      children: [
        _GroupHeader(l.grpListRing),
        ValueListenableBuilder<bool>(
          valueListenable: lds.showRing,
          builder: (ctx, on, _) => _SettingsTile(
            icon: Icons.donut_large,
            iconColor: AppColors.accent,
            title: l.listShowRing,
            subtitle: l.listShowRingDesc,
            trailing: _detailSwitch(on, lds.setShowRing),
            onTap: () => lds.setShowRing(!on),
          ),
        ),
        _GroupHeader(l.grpListSize),
        ValueListenableBuilder<int>(
          valueListenable: lds.density,
          builder: (ctx, d, _) => _detailChips<int>(
            const [0, 1, 2],
            d,
            lds.setDensity,
            (v) => switch (v) {
              0 => l.listDensityCompact,
              2 => l.listDensityLarge,
              _ => l.listDensityNormal,
            },
          ),
        ),
        _GroupHeader(l.grpListSort),
        ValueListenableBuilder<String>(
          valueListenable: lds.sortMode,
          builder: (ctx, s, _) => _detailChips<String>(
            const ['remain', 'created'],
            s,
            lds.setSortMode,
            (v) => v == 'remain' ? l.listSortRemain : l.listSortCreated,
          ),
        ),
        _GroupHeader(l.grpListDone),
        ValueListenableBuilder<int>(
          valueListenable: lds.keepDoneMin,
          builder: (ctx, m, _) => Column(
            children: [
              _SettingsTile(
                icon: Icons.history_outlined,
                iconColor: AppColors.accent,
                title: l.listKeepDone,
                subtitle: l.careKeepDoneDesc,
              ),
              _detailChips<int>(
                const [0, 10, 30, 60],
                m,
                lds.setKeepDoneMin,
                (v) => v == 0 ? l.listKeepOff : l.carePreAlarmMin(v),
              ),
            ],
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: lds.dimDone,
          builder: (ctx, on, _) => _SettingsTile(
            icon: Icons.opacity,
            iconColor: AppColors.accent,
            title: l.listDimDone,
            subtitle: l.listDimDoneDesc,
            trailing: _detailSwitch(on, lds.setDimDone),
            onTap: () => lds.setDimDone(!on),
          ),
        ),
      ],
    );
  }
}

/// D · 오버레이 pill (디자인 §D) — 미리보기가 설정보다 위. 크기·위치·표시 내용.
class _OverlaySettingsPage extends StatefulWidget {
  const _OverlaySettingsPage();

  @override
  State<_OverlaySettingsPage> createState() => _OverlaySettingsPageState();
}

class _OverlaySettingsPageState extends State<_OverlaySettingsPage>
    with WidgetsBindingObserver {
  final _ready = AlarmReadinessService.instance;
  final _ov = OverlaySettingsService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ready.refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _ready.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
            size: 18,
            color: AppColors.text,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l.settingsOverlaySection,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
            child: Text(
              l.overlayPageSub,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: Listenable.merge([_ov.sizeDp, _ov.showName]),
            builder: (ctx, _) => _preview(l),
          ),
          _GroupHeader(l.grpOverlayUse),
          ValueListenableBuilder<bool>(
            valueListenable: _ready.overlayOk,
            builder: (ctx, ok, _) => _SettingsTile(
              icon: Icons.open_in_new,
              iconColor: AppColors.accent,
              title: l.overlayShowOver,
              subtitle: l.overlayShowOverDesc,
              trailing: ok
                  ? const Icon(
                      Icons.check_circle,
                      color: AppColors.swGreen,
                      size: 22,
                    )
                  : TextButton(
                      onPressed: () => _ready.requestOverlay(),
                      child: Text(
                        l.overlayGrantCta,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
              onTap: ok ? null : () => _ready.requestOverlay(),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _ov.showOnLock,
            builder: (ctx, on, _) => _SettingsTile(
              icon: Icons.lock_outline,
              iconColor: AppColors.accent,
              title: l.overlayShowLock,
              subtitle: l.overlayShowLockDesc,
              trailing: _detailSwitch(on, _ov.setShowOnLock),
              onTap: () => _ov.setShowOnLock(!on),
            ),
          ),
          _GroupHeader(l.grpOverlaySize),
          ValueListenableBuilder<int>(
            valueListenable: _ov.sizeDp,
            builder: (ctx, s, _) => _detailChips<int>(
              const [88, 108, 132],
              s,
              _ov.setSizeDp,
              (v) => v == 88
                  ? l.overlaySizeSmall
                  : (v == 132 ? l.overlaySizeLarge : l.overlaySizeNormal),
            ),
          ),
          _GroupHeader(l.grpOverlaySide),
          ValueListenableBuilder<bool>(
            valueListenable: _ov.sideRight,
            builder: (ctx, right, _) => _detailChips<bool>(
              const [false, true],
              right,
              _ov.setSideRight,
              (v) => v ? l.overlaySideRight : l.overlaySideLeft,
            ),
          ),
          _GroupHeader(l.grpOverlayContent),
          ValueListenableBuilder<bool>(
            valueListenable: _ov.showName,
            builder: (ctx, on, _) => _SettingsTile(
              icon: Icons.label_outline,
              iconColor: AppColors.accent,
              title: l.overlayShowName,
              subtitle: l.overlayShowNameDesc,
              trailing: _detailSwitch(on, _ov.setShowName),
              onTap: () => _ov.setShowName(!on),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _ov.autoHideDone,
            builder: (ctx, on, _) => _SettingsTile(
              icon: Icons.visibility_off_outlined,
              iconColor: AppColors.accent,
              title: l.overlayAutoHide,
              subtitle: l.overlayAutoHideDesc,
              trailing: _detailSwitch(on, _ov.setAutoHideDone),
              onTap: () => _ov.setAutoHideDone(!on),
            ),
          ),
        ],
      ),
    );
  }

  /// pill 미리보기 — 크기·이름 표시를 실시간 반영(디자인 §D).
  Widget _preview(AppLocalizations l) {
    final dia = _ov.sizeDp.value.toDouble();
    final scale = dia / 108.0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        border: Border.all(color: const Color(0xFF3A3A3E)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            l.overlayPreviewLabel,
            style: TextStyle(color: AppColors.faint, fontSize: 11),
          ),
          const SizedBox(height: 14),
          Container(
            width: dia,
            height: dia,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1D1D20),
              border: Border.all(color: AppColors.accent, width: 3 * scale),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_ov.showName.value)
                    Text(
                      'Boil pasta',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 11 * scale,
                      ),
                    ),
                  Text(
                    '12:04',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 19 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l.overlayPreviewHint,
            style: TextStyle(color: AppColors.faint, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _TelemetryConsentTile extends StatelessWidget {
  const _TelemetryConsentTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // consentEnabled notifier 를 구독 — 첫 실행 다이얼로그의 변경도 즉시 반영.
    return ValueListenableBuilder<bool>(
      valueListenable: TelemetryService.instance.consentEnabled,
      builder: (ctx, on, _) => _SettingsTile(
        icon: Icons.insights_outlined,
        iconColor: AppColors.accent,
        title: l.telemetryConsentTitle,
        subtitle: l.settingsTelemetryDesc,
        trailing: Switch(
          value: on,
          onChanged: (v) => TelemetryService.instance.setConsent(v),
          activeThumbColor: AppColors.accent,
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.accent.withAlpha(0x55)
                : AppColors.surface,
          ),
        ),
        onTap: () => TelemetryService.instance.setConsent(!on),
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
                        style: TextStyle(fontSize: 11, color: AppColors.faint),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l.hotkeyRecordPrompt,
                    style: TextStyle(fontSize: 12.5, color: AppColors.muted),
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
                            style: TextStyle(
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
                          style: TextStyle(
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
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
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
                  style: TextStyle(
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
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
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
                      style: TextStyle(
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
                    style: TextStyle(
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

/// 설정 그룹 헤더(디자인 "설정 구조 & 초기 설정" §3) — 5개 그룹 라벨.
class _GroupHeader extends StatelessWidget {
  final String text;
  const _GroupHeader(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        color: AppColors.faint,
        fontSize: 12,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

/// 알람 점검 카드(디자인 "설정 구조 & 초기 설정" §3) — 배터리 예외/알림 권한이
/// 깨졌을 때만 설정 상단에 등장. 탭하면 시스템 권한을 요청해 바로 고친다.
class _AlarmCheckCard extends StatefulWidget {
  const _AlarmCheckCard();

  @override
  State<_AlarmCheckCard> createState() => _AlarmCheckCardState();
}

class _AlarmCheckCardState extends State<_AlarmCheckCard>
    with WidgetsBindingObserver {
  final _svc = AlarmReadinessService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _svc.refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _svc.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: _svc.notificationsOk,
      builder: (_, notifOk, _) => ValueListenableBuilder<bool>(
        valueListenable: _svc.batteryExemptOk,
        builder: (_, batOk, _) {
          if (notifOk && batOk) return const SizedBox.shrink();
          // 배터리 예외가 더 치명적(조용한 실패) — 우선 노출.
          final battery = !batOk;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Material(
              color: AppColors.accent.withAlpha(0x14),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () async {
                  if (battery) {
                    await _svc.requestBatteryExempt();
                  } else {
                    await _svc.requestNotifications();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.accent.withAlpha(0x4C)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Text('⚠️ ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.checkAlarmTitle,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              battery
                                  ? l.checkAlarmDesc
                                  : l.checkAlarmNotifDesc,
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12.5,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${l.checkFix} ›',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
