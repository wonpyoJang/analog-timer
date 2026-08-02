import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 상태 전환 음성 안내(TTS) — 접근성/눈 안 대고 쓰기용.
///
/// - 기본 OFF, 설정 토글로 켠다(프리퍼런스 저장).
/// - 문구는 기존 알림 l10n(notifySegmentDoneBody 등)을 그대로 읽어
///   15개 언어를 추가 번역 없이 따라간다. 음성 언어도 앱 로케일에 맞춘다.
/// - 발화 겹침 방지: 새 안내가 오면 이전 발화를 끊는다(전환 안내는 최신이 정답).
/// - 엔진 초기화/미지원 음성 등 모든 실패는 조용히 무시 — 안내는 부가 기능이라
///   타이머 본체에 영향을 줘선 안 된다.
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  static const String _kEnabled = 'tts_enabled';
  static const String _kOnboardShown = 'tts_onboarding_shown';
  static const String _kTransitionCount = 'tts_transition_count';
  static const String _kVoiceName = 'tts_voice_name';
  static const String _kVoiceLocale = 'tts_voice_locale';

  /// 설정 화면 토글 바인딩용(BatteryService.monitoringEnabled 와 동일 패턴).
  final ValueNotifier<bool> enabledListenable = ValueNotifier<bool>(false);
  bool get enabled => enabledListenable.value;

  FlutterTts? _tts;
  String? _appliedLanguage;

  /// 선택된 음성 스타일 — null 이면 시스템 기본(로케일 기반 setLanguage 만).
  /// 설정 화면 표시용으로도 노출한다({'name','locale'} 형태).
  final ValueNotifier<Map<String, String>?> voiceListenable =
      ValueNotifier<Map<String, String>?>(null);
  bool _voiceApplied = false;

  Future<void> init() async {
    try {
      final p = await SharedPreferences.getInstance();
      enabledListenable.value = p.getBool(_kEnabled) ?? false;
      final vn = p.getString(_kVoiceName);
      final vl = p.getString(_kVoiceLocale);
      if (vn != null && vl != null) {
        voiceListenable.value = {'name': vn, 'locale': vl};
      }
    } catch (_) {}
  }

  /// 시스템에 설치된 음성 목록 — [localeTag] 언어를 앞으로 정렬해 반환.
  /// (Windows: WinRT 설치 음성. 항목 = {'name': ..., 'locale': ...})
  Future<List<Map<String, String>>> availableVoices(String localeTag) async {
    try {
      _tts ??= FlutterTts();
      final raw = await _tts!.getVoices;
      if (raw is! List) return [];
      final voices = <Map<String, String>>[];
      for (final v in raw) {
        if (v is Map) {
          final name = v['name']?.toString();
          final loc = v['locale']?.toString();
          if (name != null && loc != null) {
            voices.add({'name': name, 'locale': loc});
          }
        }
      }
      final lc = localeTag.split('-').first.toLowerCase();
      voices.sort((a, b) {
        final am = a['locale']!.toLowerCase().startsWith(lc) ? 0 : 1;
        final bm = b['locale']!.toLowerCase().startsWith(lc) ? 0 : 1;
        return am != bm ? am - bm : a['name']!.compareTo(b['name']!);
      });
      return voices;
    } catch (_) {
      return [];
    }
  }

  /// 음성 스타일 선택 — null 이면 시스템 기본으로 복귀.
  /// [sample] 이 있으면 곧바로 그 음성으로 미리듣기를 재생한다.
  Future<void> setVoice(Map<String, String>? voice,
      {String? sample, String? localeTag}) async {
    voiceListenable.value = voice;
    _voiceApplied = false; // 다음 speak 에서 재적용
    _appliedLanguage = null;
    try {
      final p = await SharedPreferences.getInstance();
      if (voice == null) {
        await p.remove(_kVoiceName);
        await p.remove(_kVoiceLocale);
      } else {
        await p.setString(_kVoiceName, voice['name']!);
        await p.setString(_kVoiceLocale, voice['locale']!);
      }
    } catch (_) {}
    if (sample != null && enabled) {
      await speak(sample, localeTag: localeTag);
    }
  }

  /// [sample] 이 있으면 켜는 즉시 읽어줘 사용자가 바로 확인할 수 있게 한다.
  Future<void> setEnabled(bool v,
      {String? sample, String? localeTag}) async {
    enabledListenable.value = v;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kEnabled, v);
    } catch (_) {}
    if (v && sample != null) {
      await speak(sample, localeTag: localeTag);
    }
    if (!v) {
      try {
        await _tts?.stop();
      } catch (_) {}
    }
  }

  /// 온보딩 판정 — 세그먼트 전환 1회 경험을 집계하고, "3번째 전환 직후 1회"
  /// 타이밍이면 true. TTS 가 이미 켜져 있거나 이전에 노출했으면 false.
  /// (맥락 트리거형: 사용자가 전환의 가치를 막 체감한 순간에만 제안한다)
  Future<bool> shouldShowOnboarding() async {
    if (enabled) return false;
    try {
      final p = await SharedPreferences.getInstance();
      if (p.getBool(_kOnboardShown) ?? false) return false;
      final n = (p.getInt(_kTransitionCount) ?? 0) + 1;
      await p.setInt(_kTransitionCount, n);
      return n >= 3;
    } catch (_) {
      return false;
    }
  }

  /// 온보딩 노출 마킹 — 수락/무시와 무관하게 다시 뜨지 않는다.
  Future<void> markOnboardingShown() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kOnboardShown, true);
    } catch (_) {}
  }

  /// 시스템에 [tag] 언어 음성이 설치돼 있는지 — 미설치면 기본(외국어) 음성으로
  /// 읽혀 어색하므로, 온보딩에서 음성 추가 안내를 덧붙이는 데 쓴다.
  /// 판별 실패 시 true(경고 억제 — 보수적).
  Future<bool> isLanguageAvailable(String tag) async {
    try {
      _tts ??= FlutterTts();
      final langs = await _tts!.getLanguages;
      if (langs is List && langs.isNotEmpty) {
        final lc = tag.split('-').first.toLowerCase();
        return langs.any((e) => e.toString().toLowerCase().startsWith(lc));
      }
    } catch (_) {}
    return true;
  }

  /// [localeTag] 예: 'ko-KR', 'en-US' — 앱 로케일에서 만들어 넘긴다.
  /// 시스템에 해당 음성이 없으면 setLanguage 실패를 무시하고 기본 음성으로 발화.
  Future<void> speak(String text, {String? localeTag}) async {
    if (!enabled || text.trim().isEmpty) return;
    try {
      _tts ??= FlutterTts();
      final voice = voiceListenable.value;
      if (voice != null) {
        // 사용자가 고른 음성 스타일 — setLanguage 보다 우선한다.
        if (!_voiceApplied) {
          try {
            await _tts!.setVoice(voice);
            _voiceApplied = true;
          } catch (_) {
            // 미지원/음성 소멸(시스템에서 제거) — 로케일 폴백
            if (localeTag != null) {
              try {
                await _tts!.setLanguage(localeTag);
              } catch (_) {}
            }
          }
        }
      } else if (localeTag != null && localeTag != _appliedLanguage) {
        try {
          await _tts!.setLanguage(localeTag);
          _appliedLanguage = localeTag;
        } catch (_) {}
      }
      await _tts!.stop(); // 겹침 방지 — 최신 안내가 우선
      unawaited(_tts!.speak(text));
    } catch (_) {}
  }
}
