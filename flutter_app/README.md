# analog_timer

아날로그 시계 페이스 위에 세그먼트 타이머 + 스톱워치를 시각화하는 멀티플랫폼 Flutter 앱.

타겟: **iOS · Android · macOS · Windows**

## 플랫폼별 기능

| 기능 | Android | iOS | Windows | macOS |
|------|:------:|:---:|:------:|:-----:|
| 타이머 / 스톱워치 | ✅ | ✅ | ✅ | ✅ |
| 상태 영속화(복원) | ✅ | ✅ | ✅ | ✅ |
| 플로팅 오버레이 위젯 | ✅ | – | – | – |
| LiveActivity | – | ✅ | – | – |
| 창 크기 고정 / 최소 크기 | – | – | ✅ | (계획) |
| 시스템 트레이 + 닫기 시 상주 | – | – | ✅ | (계획) |
| 데스크톱 토스트 알림 | – | – | ✅ | (계획) |
| 멀티기기 동기화(룸코드) | – | – | ✅ | (계획) |

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

### 멀티기기 동기화

웹앱과 동일한 룸코드 방식. 데스크톱 상단 바에서 **새 방**을 만들거나 코드로 **참가**하면
`https://analog-timer-kappa.vercel.app/api/room/{roomId}` 를 1초 간격으로 폴링하며
타이머 동작(start/pause/reset/next)을 기기 간 공유한다. 백엔드는 Upstash Redis(24h TTL).

> ⚠️ 동기화는 위 Vercel 엔드포인트의 Upstash 환경변수가 설정돼 있어야 동작한다.

## 디렉토리

```
lib/
├── features/timer|stopwatch/   # BLoC + 위젯
├── overlay/                    # Android 플로팅 오버레이
├── live_activity/              # iOS LiveActivity
├── services/
│   ├── persistence_service.dart       # shared_preferences 영속화
│   ├── desktop_service.dart           # 창 + 트레이 (Windows/macOS/Linux)
│   ├── desktop_notification_service.dart
│   └── sync_service.dart              # 룸코드 멀티기기 동기화
└── widgets/clock_painter.dart  # 아날로그 시계 렌더링
```
