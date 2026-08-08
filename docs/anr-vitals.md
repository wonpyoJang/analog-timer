# ANR-free 비율 추적 (6σ 지향)

멀티 오버레이 ANR 수정(PR #60~#63) 이후, ANR-free 비율을 **장기 KPI(6σ 지향)**로
추적한다. 6σ = 99.99966%(3.4 ANR/1e6 세션)는 매우 엄격한 목표선이며, 자체 표본으로
유의하게 판정하기 어렵다(아래 §통계). 따라서 **역할을 분담**한다.

## 역할 분담
| 소스 | 역할 | 근거 |
|---|---|---|
| **Play Console → Android Vitals (1차·권위)** | 6σ 판정·추세 | 전체 설치 기반, "사용자-인지 ANR율" 표준 정의, 손실 없음 |
| 자체 텔레메트리 (2차·보강) | 조기 신호·버전 회귀 확인·breadcrumb 맥락 | 배포 즉시, ANR 직전 상태 동봉 |

**임계**: Play Vitals bad-behavior ANR율 = **0.47%**(= ANR-free 0.9953). 초과 시 검색/추천
불이익. 6σ(0.9999966)는 그 위의 지향점.

## 자체 텔레메트리 파이프라인 (Android)
- **수집**(네이티브): `AnrVitalsCollector.kt` — `ActivityManager.getHistoricalProcessExitReasons()`
  의 `REASON_ANR`(API30+). API30 미만은 `measurable=false`(분모 제외). 채널
  `dev.analogtimer/anr_vitals` `collect(sinceMs)`.
- **집계**(Dart): `AnrVitalsService` — 콜드스타트마다 세션 카운터(분모) +1, 커서(`anr_exit_cursor_ms`)
  이후 종료만 수집(중복 방지), ANR 분자 카운트, `type:'anr'`/`type:'vitals_rollup'` 이벤트 적재.
- **전송**: 기존 `telemetry_consent` 동의가 true 일 때만 `POST /api/telemetry`(deviceId·consent
  재사용). 미동의면 로컬 카운트만(프라이버시). ANR 전용 수치는 서버 화이트리스트 밖이라 `extra` 에 담음.
- **집계 조회**: `GET /api/anr-summary?version=&token=<ADMIN_TOKEN>` → `{sessions, anrSessions,
  anrFreeRatio, anrEvents, userPerceivedAnr, badBehaviorThreshold, sixSigmaTarget}`.
  디바이스별 최신 rollup(누적)만 합산, `measurable=false` 제외.

### 서버 payload 계약 (client → /api/telemetry)
- `type:'vitals_rollup'`, `extra:{sessions, anrSessions, anrMeasurable, sdkInt, atMs}`
- `type:'anr'`, `crashKind:'anr'`, `message`, `extra:{atMs, userPerceived, importance, processName, pssKb, rssKb}`
- 공통: `deviceId`, `appVersion`(네이티브 versionName+versionCode), `platform:'android'`, `osVersion`

## 통계적 현실 (왜 6σ 판정은 Vitals 로)
- 3.4/1e6 에서 기대 ANR 1건 관측 ≈ 294,000 세션. 유의 추정(포아송, event≥~10)엔 ≈ 3,000,000 세션.
- 소규모 배포의 자체 표본으로는 도달 불가 → 6σ는 **방향성 KPI**, 판정은 Vitals 전체 기반.

## 운영 루틴
1. **주 1회**: Play Console → Android vitals → ANR rate(사용자-인지) → 버전/기기별 확인 →
   임계(0.47%) 대비 여유를 추적 시트에 기록. 릴리스마다 배포 후 7일 스냅샷.
2. **자체 조기경보**: 집계 잡이 `anrFreeRatio < 0.9953` 감지 시 `notify.sh --level urgent` 경보.
   6σ 미달은 표본 부족 오탐이 많아 **정보성 로그만**(경보 억제).

## 후속(TODO)
- **Android 동의 UI**: 현재 텔레메트리 동의 다이얼로그는 데스크톱 전용 → Android 미노출이라
  자체 전송은 동의 전까지 로컬 집계에 머문다. Android 동의 화면 연동 시 전송 활성화.
- Play Developer Reporting API 로 Vitals 자동 수집(수동 스냅샷 대체).
