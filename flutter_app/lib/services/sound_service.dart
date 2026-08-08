import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'care_service.dart';
import 'haptic_service.dart';

/// 멀티 타이머 UI 효과음 — 디자인 "모션 & 사운드 스펙" 구현.
///
/// 4개 사운드 세트(soft pop/wood/glass/retro) × 8개 이벤트를 합성 에셋
/// (assets/sounds/{set}_{event}.wav, tool/gen_sounds.py 로 생성)으로 재생.
/// ADHD 사용자 과자극 방지를 위해 설정에서 전체 OFF 가능(기본 ON).
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  static const String _kEnabled = 'ui_sounds_enabled';
  static const String _kSet = 'ui_sound_set';
  static const List<String> sets = ['pop', 'wood', 'glass', 'retro'];

  final ValueNotifier<bool> enabledListenable = ValueNotifier<bool>(true);
  final ValueNotifier<String> setListenable = ValueNotifier<String>('pop');
  bool get enabled => enabledListenable.value;
  String get soundSet => setListenable.value;

  // 짧은 효과음 연타(칩 여러 번 탭 등)를 위해 플레이어 풀 순환.
  final List<AudioPlayer> _pool = [];
  int _next = 0;

  Future<void> init() async {
    try {
      final p = await SharedPreferences.getInstance();
      enabledListenable.value = p.getBool(_kEnabled) ?? true;
      final s = p.getString(_kSet);
      if (s != null && sets.contains(s)) setListenable.value = s;
    } catch (_) {}
  }

  Future<void> setEnabled(bool v) async {
    enabledListenable.value = v;
    if (v) play('tap'); // 켤 때 즉시 미리듣기(햅틱 토글과 동일 패턴)
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kEnabled, v);
    } catch (_) {}
  }

  Future<void> setSoundSet(String v) async {
    if (!sets.contains(v)) return;
    setListenable.value = v;
    play('done'); // 세트 미리듣기
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kSet, v);
    } catch (_) {}
  }

  /// 이벤트: tap/add/start/pause/warn/done/snap/del
  void play(String event) {
    if (!enabled) return;
    // 조용한 시간(22–07시) — 소리 대신 진동(페르소나 §3).
    if (CareService.instance.inQuietWindow) {
      HapticService.instance.light();
      return;
    }
    try {
      if (_pool.length < 3) {
        // 짧은 효과음이 음악 재생을 끊지 않도록 오디오 포커스를 잡지 않는다.
        final p = AudioPlayer()
          ..setPlayerMode(PlayerMode.lowLatency)
          ..setAudioContext(
            AudioContext(
              android: const AudioContextAndroid(
                audioFocus: AndroidAudioFocus.none,
                usageType: AndroidUsageType.assistanceSonification,
                contentType: AndroidContentType.sonification,
              ),
            ),
          );
        _pool.add(p);
      }
      final player = _pool[_next % _pool.length];
      _next++;
      player.play(
        AssetSource('sounds/${soundSet}_$event.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {} // 효과음 실패는 무해 — 조용히 무시
  }
}
