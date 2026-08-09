import '../time_parser.dart';

/// 온디바이스 AI 시간 해석 provider — **옵션형 폴백** 계약(디자인 철칙: AI는 실행
/// 경로 밖, 규칙으로 되는 건 규칙으로). 규칙 파서가 [ParsedKind.unparsed] 로 남긴
/// 조각만 넘겨 재해석을 시도한다. 항상 grace-degrade: 미지원·실패 시 입력을 그대로 반환.
///
/// 실제 모델(Gemini Nano/AICore)은 AICore 지원 기기(Pixel 8+ 등)에서만 동작 →
/// S10·에뮬레이터에서 검증 불가. 그래서 v1 은 인터페이스+Noop 만 출하하고,
/// 실제 연동은 기기 확보 후 [GeminiNanoAiProvider] 구현체에서 채운다.
abstract class TimerAiProvider {
  /// 이 기기에서 온디바이스 모델을 쓸 수 있는가(AICore 존재·다운로드 완료 등).
  Future<bool> isAvailable();

  /// [unresolved] (모두 unparsed 조각)을 재해석. 해석된 것은 parsed/preset 로,
  /// 못 한 것은 unparsed 그대로 둔 리스트를 반환한다(길이·순서 보존).
  Future<List<ParsedTimer>> resolve(
    List<ParsedTimer> unresolved, {
    List<PresetRef> presets = const [],
  });
}

/// 기본 provider — 아무것도 하지 않는다. 항상 미지원, 입력을 그대로 돌려준다.
/// 플래그 OFF·미지원 기기의 기본값으로, 규칙 경로를 100% 그대로 유지한다.
class NoopAiProvider implements TimerAiProvider {
  const NoopAiProvider();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<List<ParsedTimer>> resolve(
    List<ParsedTimer> unresolved, {
    List<PresetRef> presets = const [],
  }) async => unresolved;
}

/// Gemini Nano(AICore) 스텁 — 인터페이스만. 실제 모델 호출은 기기 확보 후 구현.
/// 지금은 항상 미지원으로 보고하고 입력을 그대로 반환해 규칙 경로를 해치지 않는다.
class GeminiNanoAiProvider implements TimerAiProvider {
  const GeminiNanoAiProvider();

  @override
  Future<bool> isAvailable() async {
    // TODO(ai): AICore MethodChannel 로 모델 가용성 조회. 미확보 → false.
    return false;
  }

  @override
  Future<List<ParsedTimer>> resolve(
    List<ParsedTimer> unresolved, {
    List<PresetRef> presets = const [],
  }) async {
    // TODO(ai): 프롬프트로 구조화 추출 → ParsedTimer 로 매핑. 실패 시 입력 유지.
    return unresolved;
  }
}
