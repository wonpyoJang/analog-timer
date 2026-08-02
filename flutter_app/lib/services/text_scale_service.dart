import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 인앱 글씨 크기 배율 — 저시력 접근성용.
///
/// - 일반 `Text`는 이미 OS 글꼴 배율을 따르므로, 여기서 정한 사용자 배율을
///   시스템 배율에 곱해 `MediaQuery.textScaler`로 앱 전역에 적용한다(main.dart).
/// - 기본 1.0, 프리셋 4단계(0.85/1.0/1.2/1.4). 저장/로드는 SharedPreferences.
/// - 모든 실패는 조용히 무시 — 배율은 부가 기능이라 앱 본체에 영향을 줘선 안 된다.
class TextScaleService {
  TextScaleService._();
  static final TextScaleService instance = TextScaleService._();

  static const String _kScale = 'text_scale';

  /// 사용자 지정 배율 하한/상한 (프리셋 범위와 일치).
  static const double minScale = 0.85;
  static const double maxScale = 1.4;

  /// 설정 화면·MaterialApp builder 구독용 (TtsService.enabledListenable 패턴).
  final ValueNotifier<double> scaleListenable = ValueNotifier<double>(1.0);
  double get scale => scaleListenable.value;

  Future<void> init() async {
    try {
      final p = await SharedPreferences.getInstance();
      final v = p.getDouble(_kScale);
      if (v != null) {
        scaleListenable.value = v.clamp(minScale, maxScale);
      }
    } catch (_) {}
  }

  Future<void> setScale(double v) async {
    final clamped = v.clamp(minScale, maxScale);
    scaleListenable.value = clamped;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setDouble(_kScale, clamped);
    } catch (_) {}
  }
}
