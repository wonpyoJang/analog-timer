# Analog Timer — Android Floating Overlay Widget
## Design Handoff Document

**대상:** Claude Design / UI 디자이너  
**작성일:** 2026-06-07  
**플랫폼:** Android (Floating Overlay, System Alert Window)  
**컴포넌트:** `TimerOverlayWidget` — 다른 앱 위에 항상 표시되는 미니 타이머 위젯

---

## 1. 개요

타이머/스톱워치 앱이 백그라운드에 있어도 상태 정보를 보여주는 플로팅 pill 위젯.  
상태에 따라 자동으로 콘텐츠가 전환되며, 사용자가 드래그로 위치를 자유롭게 이동할 수 있다.

---

## 2. 4가지 상태 (States)

| 상태 | 표시 콘텐츠 | 예시 |
|------|------------|------|
| **Idle** | 현재 시각 (HH:MM, 1초 갱신) | `21:43` |
| **Timer only** | 🟠 세그먼트명(선택) + 남은 시간 | `할 것 1 / 01:44` |
| **Stopwatch only** | 🟢 경과 시간 | `00:16` |
| **Timer + Stopwatch** | 🟠 타이머 + 🟢 스톱워치 나란히 | `01:44  •  00:16` |

### 상태 전환 로직
```
timerActive = (status == running || status == paused)
swActive    = (running == true || elapsedMs > 0)

if !timerActive && !swActive  →  Idle (시계)
if timerActive && !swActive   →  Timer only
if !timerActive && swActive   →  Stopwatch only
if timerActive && swActive    →  Both
```

---

## 3. 색상 팔레트

### 오버레이 전용 컬러
| 역할 | Token | HEX | Alpha | 비고 |
|------|-------|-----|-------|------|
| 배경 | `surface` | `#1A1A1C` | 93% (EE) | 뒤가 살짝 비침 |
| 테두리 | `border` | `#2E2E32` | 100% | 1px |
| 타이머 값 | `timerOrange` | `#E07A52` | 100% | 메인 숫자 |
| 타이머 레이블 | `timerOrangeDark` | `#C05A28` | 100% | 세그먼트명 |
| 타이머 인디케이터 dot | `timerOrange` | `#E07A52` | 100% | ● |
| 스톱워치 값 | `swGreen` | `#2EA84A` | 100% | 메인 숫자 |
| 스톱워치 인디케이터 dot | `swGreen` | `#2EA84A` | 100% | ● |
| 아이들 시계 | — | `#9E9A97` | 100% | muted보다 살짝 밝음 |
| 그림자 | black | `#000000` | 60% (99) | blur 12, offset (0, 4) |

### 앱 전체 팔레트 (참고)
| Token | HEX | 용도 |
|-------|-----|------|
| `bg` | `#0E0E0F` | 앱 배경 |
| `surface` | `#1A1A1C` | 카드/오버레이 배경 |
| `border` | `#2E2E32` | 구분선, 테두리 |
| `text` | `#E8E6E0` | 기본 텍스트 |
| `muted` | `#6B6968` | 보조 텍스트 |
| `accent` | `#F0C040` | 강조 (노란색, 앱 타이틀 등) |
| `timerOrange` | `#E07A52` | 타이머 |
| `timerOrangeDark` | `#C05A28` | 타이머 보조 |
| `swGreen` | `#2EA84A` | 스톱워치 |
| `danger` | `#E05252` | 경고/에러 |

---

## 4. 타이포그래피

**폰트:** Bebas Neue (Google Fonts) — 모든 텍스트 동일

| 요소 | Size | Color | Letter Spacing | 비고 |
|------|------|-------|----------------|------|
| 아이들 시계 | 17sp | `#9E9A97` | 1.0 | HH:MM |
| 타이머 값 | 17sp | `#E07A52` | 1.0 | MM:SS 또는 H:MM:SS |
| 타이머 레이블 | 9sp | `#C05A28` | 0.8 | 세그먼트명, 선택 표시 |
| 스톱워치 값 | 17sp | `#2EA84A` | 1.0 | MM:SS 또는 H:MM:SS |

---

## 5. 레이아웃 & 스펙

```
┌─────────────────────────────────────────┐
│  pill container (border-radius: 24)     │
│  padding: H=12, V=4                     │
│                                         │
│  [•] [label]  [space:12]  [•] [sw time] │
│      [time]                             │
└─────────────────────────────────────────┘
```

| 요소 | 값 |
|------|-----|
| 컨테이너 패딩 | `horizontal: 12dp, vertical: 4dp` |
| 테두리 반경 | `24dp` (완전 pill) |
| 테두리 두께 | `1dp` |
| 인디케이터 dot 크기 | `6×6dp`, circle |
| dot ↔ 텍스트 간격 | `5dp` |
| 타이머 ↔ 스톱워치 간격 | `12dp` |
| 그림자 blur | `12dp` |
| 그림자 offset | `(0, 4dp)` |

---

## 6. 오버레이 윈도우 설정 (Android)

| 속성 | 값 | 비고 |
|------|-----|------|
| 높이 | `150px` (raw, ≈50dp@3x) | 플러그인 버그: dp 변환 없이 raw px 처리 |
| 너비 | `WRAP_CONTENT (-2)` | Android LayoutParams 직접 지정 |
| 초기 위치 | `y = 53dp` from top | 상태바(~53dp) 바로 아래 |
| 드래그 | 활성화 | 드래그 후 위치 유지 |
| 정렬 | `topCenter` | 초기 x 위치 |

**주의:** `moveOverlay(x, y)`는 dp 단위, `showOverlay(height:)`는 raw pixel 단위 (플러그인 불일치).

---

## 7. 인터랙션

| 동작 | 결과 |
|------|------|
| Tap | 없음 (앱으로 포커스 이동 없음) |
| Drag | 자유 이동, 위치 유지 |
| 앱 전면 진입 시 | 오버레이 위에 앱이 렌더됨 (위젯 숨지 않음) |

---

## 8. 상태별 ASCII 목업

### Idle
```
╭─────────────╮
│  21:43      │
╰─────────────╯
```

### Timer only (레이블 있음)
```
╭─────────────────╮
│ ● 할 것 1       │
│   01:44         │
╰─────────────────╯
```

### Timer only (레이블 없음)
```
╭─────────────╮
│ ● 01:44     │
╰─────────────╯
```

### Stopwatch only
```
╭──────────────╮
│ ● 00:16      │
╰──────────────╯
```

### Both
```
╭──────────────────────────╮
│ ● 01:44   ●  00:16       │
╰──────────────────────────╯
```
(타이머 레이블 있을 경우 타이머 섹션이 2줄)

---

## 9. 기술 스택 (구현 참고)

| 항목 | 내용 |
|------|------|
| 플랫폼 | Android only (`Platform.isAndroid` guard) |
| 플러그인 | `flutter_overlay_window ^0.5.0` |
| 권한 | `SYSTEM_ALERT_WINDOW`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_SPECIAL_USE` |
| IPC | `FlutterOverlayWindow.shareData(jsonEncode(...))` → `overlayListener` |
| 폰트 로딩 | Google Fonts (Bebas Neue), 오버레이 isolate에서 직접 로드 |
| 시계 갱신 | 오버레이 내부 `Timer.periodic(1s)` |
| 데이터 갱신 | 메인 앱 16ms tick → `OverlayService.updateState()` |

---

## 10. 디자인 개선 제안 (옵션)

- [ ] 세그먼트 색상이 6가지 (`segColors`)이므로, 타이머 dot/텍스트를 세그먼트 색상으로 동적 변경 가능
- [ ] 타이머 종료 임박 시 (예: 10초 이하) 빨간색(`#E05252`)으로 점멸 애니메이션
- [ ] long-press로 앱 복귀 인터랙션 추가 가능
- [ ] iOS Live Activity(Dynamic Island)와 동일한 디자인 언어 적용 예정
