# AI 시간해석 폴백 — 실제 온디바이스 모델 연동 플랜

작성: 2026-08-10 · 상태: **계획(미구현)** · 선행: 스캐폴드 PR #98 완료

## 0. 한 줄 요약
규칙 기반 시간 파서가 `unparsed`로 남긴 조각에 한해, **온디바이스 Gemini Nano(AICore)**로
재해석을 시도하는 **옵션형 폴백**을 실구현한다. 기본 OFF·실패 시 규칙 결과 보존 — 앱의
철칙("AI는 실행 경로 밖 / 규칙으로 되는 건 규칙으로 / AI 없이도 도달 가능")을 유지한다.

## 1. 배경·원칙 (변경 금지)
- 시간 파서(`lib/features/multi_timer/time_parser.dart`)는 순수 Dart·오프라인·결정론.
  숫자+단위·한글수사·구분자 분리·프리셋 대조까지 규칙으로 처리하고, 못 하면 `ParsedKind.unparsed`
  (회색 카드)로 보존한다.
- AI는 **1순위가 아니다.** 규칙이 먼저, AI는 규칙 실패분에만, 그것도 사용자가 켰을 때만.
- 관련 메모리: `project_voice_ondevice.md`("AI는 실행 경로에 없다").

## 2. 현재 상태 (스캐폴드, PR #98)
- `ai/timer_ai_provider.dart`
  - `TimerAiProvider` 인터페이스: `Future<bool> isAvailable()`, `Future<List<ParsedTimer>> resolve(unresolved, {presets})`
  - `NoopAiProvider`(기본): `isAvailable→false`, `resolve→입력 그대로`
  - `GeminiNanoAiProvider`(**스텁**): `isAvailable→false`(TODO), `resolve→입력 그대로`(TODO)
- `ai/timer_ai_service.dart`
  - 영속 플래그 `ai_fallback_enabled`(기본 **false**), `provider`(기본 Noop)
  - `enhance(parsed, {presets})`: OFF·미지원·unparsed 없음이면 입력 그대로; 아니면 unparsed만
    `provider.resolve`로 치환(규칙 해석분 parsed/preset 은 절대 미변경, 실패 시 규칙 결과 유지)
- `text_timer_screen._parse`가 `parseTimers` 뒤 `enhance()` 호출(플래그 OFF면 무동작)
- `main`에서 `TimerAiService.load()`
- 유닛테스트 6건(OFF 불변·미가용 불변·unparsed없음 스킵·치환·영속화)

즉 **배선은 끝났고, `GeminiNanoAiProvider`의 실구현과 설정 토글만 남음.**

## 3. 하드웨어 제약 (검증 게이트 — 필독)
- Gemini Nano는 **AICore 지원 기기에서만** 동작(Pixel 8/9, 일부 갤럭시 S24+ 등). 모델은 시스템
  AICore가 관리·다운로드.
- **현재 개발/테스트 기기(Galaxy S10 · Android 11, 에뮬레이터)에서는 실행 불가** → 구현해도
  이 기기들에선 `isAvailable→false`로 떨어져 **e2e 검증 불가.**
- 결론: **실구현은 AICore 기기 확보가 선행 조건.** 확보 전까지는 아래 Phase A~C를 "코드 작성 +
  유닛테스트"까지만 하고, 실기기 e2e(Phase E)는 기기 확보 후로 게이팅.

## 4. 통합 지점 (이미 존재)
```
parseTimers(text) → List<ParsedTimer>  (규칙, unparsed 포함)
        │
        └─ TimerAiService.enhance(parsed)   ← 여기서만 AI 개입
              if !enabled || provider 미가용 || unparsed 없음 → 그대로 반환
              else: unparsed 조각 → provider.resolve → 그 자리만 치환
```
- 호출부: `text_timer_screen._parse`(현재). **OCR 경로(`multi_timer_screen`의 `parseTimers`
  직접 호출, line ~301)에는 아직 enhance 미연결** → Phase D에서 선택적으로 연결 검토.
- ⚠ 주의: "말하거나 적기"(text_timer_screen 진입)는 현재 **release 빌드에서 숨김**(#105,
  미완성). AI 폴백을 실제로 노출하려면 이 진입의 완성 여부와 함께 재검토 필요.

## 5. 구현 Phase

### Phase A — 네이티브 AICore 가용성·생성 채널 (Kotlin)
- 신규 `android/.../AiCoreChannel.kt`, MethodChannel `dev.analogtimer/ai_core`.
  - `isAvailable()` → AICore/GenerativeModel 가용성 조회(기기·모델 다운로드 상태). 미지원 API/기기 → false.
  - `generate(prompt, {maxTokens, temperature})` → 텍스트 반환(취소·타임아웃 지원).
- 의존성: ML Kit GenAI / AICore SDK(`com.google.ai.edge.aicore` 등) 추가. **min SDK·기기 게이트**로
  미지원 기기에서 클래스 로드 자체가 안 터지게(리플렉션/try-catch 가드) — OCR R8 교훈 반영.
- **R8 keep 규칙 필수**(OCR 사례처럼 릴리스에서 조용히 실패 위험) → `proguard-rules.pro`에
  AICore 패키지 keep 추가 + 릴리스에서 실제 호출 경로 검증.
- Dart 브리지: `GeminiNanoAiProvider.isAvailable()`가 이 채널 호출.

### Phase B — `GeminiNanoAiProvider.resolve()` 실구현 (Dart + 프롬프트)
- 입력: `unresolved`(모두 unparsed) + `presets`.
- 프롬프트 설계(§6) → `generate()` 호출 → **JSON** 파싱 → `ParsedTimer`로 매핑.
- 매핑 규칙:
  - 해석 성공: `kind: parsed`, `totalMs` 설정, `name` 보정(있으면), `source` 보존, `timeExpr`에 근거.
  - 프리셋 이름과 일치: `kind: preset`, 색 승계(`presetColor`).
  - 실패/불확실: **원본 unparsed 그대로 반환**(추측 금지 — 신뢰 규칙).
- 순서·길이 보존(입력 N개 → 출력 N개), 1:1 매칭.

### Phase C — 견고성 (grace-degrade)
- **타임아웃**(예 1.5s)·취소: 초과 시 규칙 결과 유지. UI는 규칙 결과를 먼저 보여주고 AI는
  비동기 보강(스피너 최소화, 절대 블로킹 금지).
- 모든 예외 `catch → 입력 그대로`(사일런트 폴백 아님 — 원본 보존이 정의된 동작).
- 오프라인·모델 미다운로드·저메모리: `isAvailable→false`로 조기 종료.
- 로깅: `kDebugMode`에서만. 민감정보(사용자 입력 문구) 외부 전송 금지(온디바이스 원칙).

### Phase D — 설정 토글 UI + 노출 정책
- 설정에 "실험적 · AI로 못 알아들은 표현 해석"(가칭) 토글. **provider.isAvailable()가 true일 때만
  노출/활성**(미지원 기기엔 아예 안 보이거나 비활성 + 사유 안내). 미동작 토글 노출 금지(말하거나
  적기 교훈).
- (선택) OCR 경로에도 enhance 연결 검토 — 봉지 문구가 규칙으로 안 잡힐 때 보강.

### Phase E — 검증 (AICore 기기 필요)
- 유닛(기기 불필요): resolve 매핑(JSON→ParsedTimer), 타임아웃 시 규칙 유지, 예외 시 입력 보존,
  프리셋 매칭 색 승계 — 가짜 provider로.
- 정적가드: 릴리스 R8 keep 존재 확인(anr_static_guard 스타일).
- **e2e(AICore 기기)**: 규칙 실패 문구("면 대충 삼분 반쯤", 오타·구어체) → AI 폴백이 타이머화;
  플래그 OFF면 규칙 그대로; 오프라인·저사양에서 크래시 없이 규칙 폴백. **릴리스 빌드로** 확인
  (tofu/R8 회귀 방지).

## 6. 프롬프트 설계 (Phase B 상세)
- 시스템 지침: "다음 한국어 조각들에서 조리/집중 시간을 추출해 JSON 배열로만 답하라. 시간이 없으면
  null. 추측 금지." few-shot 2~3개(구어체·범위·복합).
- 출력 스키마(예):
  ```json
  [{"i":0,"name":"소스","totalSec":210,"conf":0.9},{"i":1,"name":null,"totalSec":null,"conf":0}]
  ```
- 파싱 방어: 코드펜스 제거·부분 JSON 복구·conf 임계(<0.6 → unparsed 유지)·범위는 짧은 쪽(규칙과 일관).
- 언어: 한국어 우선, 입력 언어 따라감.

## 7. 리스크·완화
| 리스크 | 완화 |
|---|---|
| AICore 미지원 기기 다수(구형·비Pixel) | 기본 OFF·가용성 게이트·규칙이 항상 1순위라 영향 0 |
| 릴리스 R8가 AICore 리플렉션 파괴(OCR 사례) | proguard keep + 릴리스 e2e 필수 |
| 모델 환각(엉뚱한 시간) | conf 임계·범위 규칙·실패 시 unparsed 유지·사용자 확인 화면 유지 |
| 지연/배터리 | 타임아웃·비동기 보강·규칙 결과 선표시 |
| 온디바이스 원칙 위반(클라우드 유혹) | 클라우드 provider 금지. 온디바이스만. |

## 8. 산출물 체크리스트 (실행 시)
- [ ] `AiCoreChannel.kt` + MethodChannel + 의존성 + min-SDK/기기 가드
- [ ] `proguard-rules.pro` AICore keep
- [ ] `GeminiNanoAiProvider.isAvailable/resolve` 실구현 + 프롬프트
- [ ] 타임아웃·예외·오프라인 grace-degrade
- [ ] 설정 토글(가용 시에만) + (선택) OCR enhance 연결
- [ ] 유닛테스트(매핑·타임아웃·예외·프리셋) + R8 정적가드
- [ ] AICore 기기 e2e(릴리스 빌드) — 규칙 실패 문구 해석·OFF 불변·오프라인 폴백

## 9. 미결 결정 (착수 전 확인)
1. 대상 SDK: ML Kit GenAI vs AICore(GenerativeModel) 중 무엇? (기기 지원 범위·API 안정성 비교)
2. "말하거나 적기" 진입을 완성해 AI와 함께 다시 노출할지, 별도 진입(예: 회색 카드에 "AI로 해석"
   버튼)으로 붙일지.
3. OCR 경로에도 AI 폴백을 넣을지(봉지 문구 커버리지).

---

## 10. 대안·병행 경로 — 어시스턴트 연동 (App Actions / Bixby)
**Gemini Nano(§3~8, AICore 필요)와 다른 트랙.** 여기선 AI가 앱 안에서 돌지 않는다 — 어시스턴트
(Google Gemini/Assistant, 또는 빅스비)가 **음성인식·의도해석을 하고, 앱은 기존 `anytime://`
딥링크로 구조화된 인텐트만 받는다.** 즉 §1 철칙("AI는 실행 경로 밖")에 그대로 맞고, **AICore
같은 특수 하드웨어가 필요 없어 지금 있는 S10에서도 검증 가능**하다. 그래서 AICore 실연동보다
**착수 우선순위가 높을 수 있다.**

### 10.1 옵션 비교
| 경로 | 방식 | 장점 | 단점/상태 | 검증 |
|---|---|---|---|---|
| **Android App Actions** (추천) | `shortcuts.xml` capability(BII 또는 커스텀) → `anytime://` 딥링크 매핑 | 현대적·Google Assistant/Gemini와 동작·기존 딥링크 재사용·특수 HW 불필요 | 커스텀 인텐트 승인/스키마 학습 | S10+Assistant 실기기 |
| **App Functions** (안드 15/16+) | 온디바이스 AI가 앱 기능 직접 호출 | 온디바이스·미래 표준 | 지원 버전 협소, 초기 API | 신형 기기 필요 |
| **Bixby Capsule** | Bixby Developer Studio(.bxb) → 딥링크 | S10에 빅스비 존재 | **빅스비 사양세(삼성이 Gemini로 대체)** → 신규 투자 비추천 | S10 실기기 |
| **Galaxy Routines** | 루틴이 `anytime://` 실행 | **이미 구현됨**(voice_ondevice) | 자동화 트리거 한정(음성 자유발화 아님) | 완료 |

결론: **App Actions 를 1순위**로. 빅스비는 사양세라 보류, App Functions 는 신형 기기 확보 후.

### 10.2 App Actions 구현 스케치 (착수 시)
- `android/app/src/main/res/xml/shortcuts.xml` 에 `<capability>` 선언, `anytime://start?...`·
  `preset/{id}`·`stop` 등 기존 딥링크에 매핑(파라미터: min/sec/label).
- 매니페스트에 shortcuts 메타데이터 연결. 가능하면 **Built-in Intents(BII)** 우선(예 타이머 관련
  `actions.intent.*`), 없으면 커스텀 capability.
- 딥링크 수신은 **기존 `deep_link_service.dart`/`DeepLinkRouter` 그대로 재사용**(신규 승격 불필요).
- 파라미터 파싱은 기존 `parseDeepLink` 재사용. 자유발화 시간표현("삼분 반")은 어시스턴트가
  이미 숫자로 정규화해 넘기므로 규칙 파서로 충분(AI 파서 폴백과 독립).
- 검증(실기기 S10): "Hey Google, [앱]에서 파스타 8분 타이머" → 앱이 딥링크로 8분 타이머 생성.
  릴리스 빌드로 확인(딥링크/인텐트 필터 R8 회귀 없는지).

### 10.3 리스크·주의
- App Actions 커스텀 인텐트는 문서/승인 절차가 바뀔 수 있음 → 착수 전 최신 확인(지식 컷 2026-01).
- 어시스턴트가 앱을 못 찾거나 딥링크 파라미터 스키마 불일치 → 조용한 실패. 로그·폴백(앱 열기만) 필요.
- 빅스비는 별도 캡슐 심사·계정 필요 + 플랫폼 사양세 → 당장은 문서화만.

### 10.4 미결 결정 (§9 에 추가)
4. App Actions 를 AICore 실연동보다 먼저 착수할지(HW 불필요·검증 가능 → 권장).
5. BII(빌트인 인텐트)로 커버되는 범위 vs 커스텀 capability 필요 범위.
