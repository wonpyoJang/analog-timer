# 기능 분석 — analog-timer-5.html

> 원본: `original/analog-timer-5.html` / 배포: https://analog-timer-kappa.vercel.app

## 1. 핵심 컨셉

아날로그 시계 페이스 위에 세 레이어를 겹쳐 그린다.

| 레이어 | 시각 표현 | 의미 |
|--------|-----------|------|
| **시계 바탕** | 시/분/초침 실시간 | 현재 시각 |
| **타이머** | 분침 위치부터 시작하는 쐐기 + 안쪽 나선 | 세그먼트 잔여 시간 |
| **스톱워치** | 바깥 테두리부터 안으로 채워지는 링 | 경과 시간 |

**핵심 UX**: 타이머 쐐기가 **현재 분침에서 시작**하므로, 쐐기 끝 각도를 시계판에서 읽으면 종료 시각을 즉시 알 수 있다.

---

## 2. 타이머

### 세그먼트 시스템
- 복수 구간(이름 + 분 + 색상)을 순서대로 자동 실행
- 기본값: 작업/휴식 교대 8구간 (포모도로 변형 패턴)
- 구간별 색상 → Canvas 쐐기 색상 + 진행률 바 색상 연동

### 컨트롤
| 버튼 | 동작 |
|------|------|
| START | 첫 세그먼트 시작 (이후 RUNNING… 비활성) |
| PAUSE | 일시정지 → 버튼이 RESUME으로 변환 |
| NEXT | 2초 카운트다운 후 다음 세그먼트 강제 진행 (탭으로 취소) |
| RST | 전체 초기화 |

### NEXT 버튼 UX
- 2초 홀드 + 진행 애니메이션 (실수 방지)
- 카운트다운 중 재탭 → 취소
- paused 상태에서 NEXT → 자동으로 running 재개

### 연속 반복 (Loop)
- 전체 세그먼트 완료 후 처음부터 반복, 루프 횟수 로그 기록

### 진행률 바
- 전체 세그먼트 합산 시간 기준 선형 진행
- 현재 세그먼트 색상 반영

---

## 3. Canvas 시각화 상세

### 타이머 쐐기 (`drawTimerSpiral`)
```
남은 시간 < 60분:  분침 위치에서 시계 방향으로 쐐기 (안쪽 r=14 ~ 초침 끝 r=R*0.79)
남은 시간 ≥ 60분:  완전한 60분 바퀴는 안쪽 링(반투명)으로 쌓고, 현재 바퀴만 쐐기
```

### 스톱워치 링 (`drawStopwatchRings`)
```
시작 시 분침 각도 고정 → 해당 각도에서 시계 방향으로 채움
1바퀴 = 60분, 바깥 링부터 안쪽으로 쌓임
```

### 렌더 루프
- `requestAnimationFrame` 기반, 60fps
- `performance.now()` 타이밍 → setInterval보다 정밀

---

## 4. 스톱워치

- START/PAUSE 토글
- LAP: 구간 시간 + 누적 시간 기록
- 랩 목록: 스크롤 가능한 패널
- Canvas 링과 실시간 동기화

---

## 5. 세그먼트 편집 UI

- 이름 인라인 편집
- 분 수: 0.1~60, 0.5 단위 스텝
- 색상: 6색 팔레트 순환 자동 할당 (`#e05252 #52b0e0 #52e08e #e07a52 #a052e0 #e0c052`)
- 세그먼트 추가/삭제 (최소 1개 유지)

---

## 6. 이벤트 로그

타임스탬프 + 컬러 도트로 세그먼트 시작/완료/건너뜀/루프/리셋 기록.

---

## 7. 기술 스택 (v0)

- 단일 HTML 파일, 외부 의존 없음 (Google Fonts CSS만)
- Canvas 2D API
- DPR(devicePixelRatio) 대응 → 레티나 선명도
- CSS 커스텀 프로퍼티로 테마 관리 (다크 베이스, 노란 액센트)
- 폰트: DM Mono (숫자/UI) + Bebas Neue (타이틀/레이블)

---

## 8. 확장 포인트 (v1 웹 / v2 Flutter)

| 항목 | 현재 (v0) | v1 웹 | v2 Flutter |
|------|-----------|-------|------------|
| 세그먼트 저장 | 없음 | localStorage / URL 공유 | SharedPreferences / Hive |
| 알림 | 없음 | Web Notification API + 소리 | 로컬 알림 (flutter_local_notifications) |
| 다중 타이머 | 단일 | 탭 UI | 하단 탭 또는 PiP |
| 세그먼트 정렬 | 없음 | 드래그 앤 드롭 | ReorderableListView |
| 프리셋 | 없음 | 포모도로/커스텀 템플릿 | 내장 + 사용자 저장 |
| 플랫폼 | 웹 | 웹 (PWA) | iOS / Android / macOS / Windows |
| 공유 | Vercel URL | URL 파라미터 인코딩 | 딥링크 |

---

## 9. Flutter 포팅 시 주요 고려사항

- Canvas → `CustomPainter` (`drawTimerSpiral` / `drawStopwatchRings` 1:1 변환 가능)
- `requestAnimationFrame` → `AnimationController` + `Ticker`
- `performance.now()` → `DateTime.now().microsecondsSinceEpoch`
- 세그먼트 상태 → `Bloc` 또는 `Riverpod` StateNotifier
- 실시간 시계 → `Stream.periodic(Duration(milliseconds: 16))`
- 폰트: DM Mono (`google_fonts`), Bebas Neue (`google_fonts`)
