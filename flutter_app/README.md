# analog_timer

아날로그 시계 페이스 위에 세그먼트 타이머 + 스톱워치를 시각화하는 멀티플랫폼 Flutter 앱.

타겟: **iOS · Android · macOS · Windows**

## 플랫폼별 기능

| 기능 | Android | iOS | Windows | macOS |
|------|:------:|:---:|:------:|:-----:|
| 타이머 / 스톱워치 | ✅ | ✅ | ✅ | ✅ |
| 상태 영속화(복원) | ✅ | ✅ | ✅ | ✅ |
| 플로팅 오버레이 위젯(항상 위) | ✅ | – | ✅ | (계획) |
| LiveActivity | – | ✅ | – | – |
| 창 크기 고정 / 최소 크기 | – | – | ✅ | (계획) |
| 시스템 트레이 + 닫기 시 상주 | – | – | ✅ | (계획) |
| 데스크톱 토스트 알림 | – | – | ✅ | (계획) |

## Windows 빌드 / 실행

요구사항: Flutter(stable), Visual Studio + "C++를 사용한 데스크톱 개발" 워크로드.

```powershell
flutter pub get
flutter run -d windows          # 개발 실행
flutter build windows --release # 릴리스 빌드
```

### MSIX 인스톨러

```powershell
dart run msix:create            # build/windows/x64/runner/Release 아래 .msix 생성
```

서명 설정은 `pubspec.yaml` 의 `msix_config` 참고.

### 플로팅 오버레이 위젯 (항상 위)

타이틀의 **위젯** 버튼을 누르면 모바일 오버레이처럼 **다른 모든 창 위에 항상 떠 있는**
작은 아날로그 타이머 창이 뜬다. `desktop_multi_window` 로 띄운 별도 네이티브 서브윈도우이며
(frameless · always-on-top · 작업표시줄 숨김), 메인 창과 per-window 채널로 통신한다.

- 메인 → 오버레이: 타이머/스톱워치 상태를 ~48ms 주기로 push
- 오버레이 → 메인: 재생/일시정지·다음·정지 버튼 액션 전달
- 시계 영역 드래그로 창 이동, ✕ 로 닫기

## 디렉토리

```
lib/
├── features/timer|stopwatch/   # BLoC + 위젯
├── overlay/
│   ├── overlay_widget.dart            # Android 플로팅 오버레이
│   ├── desktop_overlay.dart           # 데스크톱 always-on-top 서브윈도우
│   └── overlay_clock_painter.dart     # 오버레이 공용 아날로그 클록 페인터
├── live_activity/              # iOS LiveActivity
├── services/
│   ├── persistence_service.dart       # shared_preferences 영속화
│   ├── desktop_service.dart           # 창 + 트레이 (Windows/macOS/Linux)
│   ├── desktop_notification_service.dart
│   └── desktop_overlay_service.dart   # 오버레이 서브윈도우 제어 + IPC
└── widgets/clock_painter.dart  # 아날로그 시계 렌더링
```
