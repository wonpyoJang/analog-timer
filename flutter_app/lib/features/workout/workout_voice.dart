import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../services/platform_info.dart';

/// 운동 구령 전용 TTS — 우선순위·보이스 톤·음악 덕킹(스펙 §06).
///
/// 우선순위(pri): 1=이전 발화를 끊고 즉시(세트 안내·3-2-1), 2=말 중이 아니면
/// 발화(콜아웃·예고), 3=구령(말 중이면 그 박자는 건너뜀 — 밀리면 안 되므로).
/// 덕킹: 발화 동안 오디오 포커스(TRANSIENT_MAY_DUCK)를 잡아 시스템이 음악
/// 볼륨을 낮추게 한다(네이티브 채널). 발화 종료 380ms 후 해제.
class WorkoutVoice {
  WorkoutVoice({this.localeTag = 'ko-KR'});

  static const _focusChannel = MethodChannel('dev.analogtimer/audio_focus');

  String localeTag;
  String tone = 'coach'; // coach: rate↑ pitch↓ / calm: 느리고 평탄
  bool duckEnabled = true;

  /// 실행 화면 캡션(🗣 "…") 스트림.
  final captions = StreamController<String>.broadcast();

  FlutterTts? _tts;
  bool _speaking = false;
  bool _configured = false;
  String? _appliedTone;
  Timer? _releaseTimer;

  static const _koNums = [
    '하나',
    '둘',
    '셋',
    '넷',
    '다섯',
    '여섯',
    '일곱',
    '여덟',
    '아홉',
    '열',
    '열하나',
    '열둘',
    '열셋',
    '열넷',
    '열다섯',
    '열여섯',
    '열일곱',
    '열여덟',
    '열아홉',
    '스물',
  ];

  /// 구령 숫자 — 한국어는 고유어 수사(하나·둘·셋), 그 외 로케일은 숫자.
  String countWord(int n) {
    if (localeTag.startsWith('ko') && n >= 1 && n <= 20) return _koNums[n - 1];
    return '$n';
  }

  Future<void> _ensure() async {
    _tts ??= FlutterTts();
    if (!_configured) {
      _configured = true;
      try {
        await _tts!.setLanguage(localeTag);
      } catch (_) {}
      _tts!.setCompletionHandler(_onDone);
      _tts!.setCancelHandler(_onDone);
      _tts!.setErrorHandler((_) => _onDone());
    }
    if (_appliedTone != tone) {
      _appliedTone = tone;
      try {
        await _tts!.setSpeechRate(tone == 'coach' ? 0.62 : 0.48);
        await _tts!.setPitch(tone == 'coach' ? 0.9 : 1.0);
      } catch (_) {}
    }
  }

  void _onDone() {
    _speaking = false;
    _releaseTimer?.cancel();
    _releaseTimer = Timer(const Duration(milliseconds: 380), () {
      if (!_speaking) _releaseFocus();
    });
  }

  Future<void> say(String text, {int pri = 3}) async {
    if (text.trim().isEmpty) return;
    try {
      await _ensure();
      if (pri >= 3 && _speaking) return; // 구령은 밀리지 않게 스킵
      if (pri <= 1 && _speaking) await _tts!.stop();
      if (pri == 2 && _speaking) return;
      _speaking = true;
      _requestFocus();
      captions.add(text);
      unawaited(_tts!.speak(text));
    } catch (_) {
      _speaking = false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {}
    _speaking = false;
    _releaseFocus();
  }

  void _requestFocus() {
    if (!duckEnabled || !isAndroid) return;
    _releaseTimer?.cancel();
    _focusChannel.invokeMethod('duck').ignore();
  }

  void _releaseFocus() {
    if (!isAndroid) return;
    _focusChannel.invokeMethod('release').ignore();
  }

  void dispose() {
    _releaseTimer?.cancel();
    stop();
    captions.close();
  }
}
