# Analog Timer — 프로젝트 규칙

## Git 흐름 (PR 기반 — 2026-08-02 전환)

**upstream(wonpyoJang) main에 직접 push 금지.** upstream에서 다른 작업(PR)이
상시로 일어나 직push가 계속 경합했다.

1. 작업은 `feature/*` 브랜치에서. 커밋 후 push는 **feature 브랜치까지만**:
   ```bash
   git push origin feature/windows-app
   git push upstream feature/windows-app:feature/windows-app
   ```
2. push 전 반드시 `git fetch upstream` 후 upstream/main이 앞서 있으면
   **BASE를 feature에 머지** (글로벌 규칙과 동일 방향).
3. main 반영은 **PR로**:
   ```bash
   gh pr create --repo wonpyoJang/analog-timer --base main --head feature/windows-app ...
   gh pr merge <num> --repo wonpyoJang/analog-timer --merge
   ```
   (repo 관례 = merge commit. gh 인증 계정: wonpyoJang)
4. PR 머지 후 정리:
   - `git fetch upstream && git merge upstream/main` (머지 커밋 역동기화)
   - `git push origin feature/windows-app:main` — origin(wpjang95) main FF 정렬
     (wpjang95 repo는 gh API 권한이 없어 PR 불가 — FF push만 가능)
5. 기능 단위가 끝났을 때 PR을 만든다. 커밋마다 PR을 만들 필요는 없음.

## Windows 빌드

- **nuget 필수**: `export PATH="/c/Users/jangw/tools:$PATH"` 후 빌드
  (permission_handler의 CppWinRT가 요구. 없으면 "Unable to generate build files")
- configure 실패 후엔 반드시 `flutter clean` (CMAKE_INSTALL_PREFIX 오염)
- **빌드 전 앱 종료**: `taskkill //F //IM analog_timer.exe` — 안 하면 LNK1104.
  강제 종료 전 `%TEMP%\analog_timer_clean.flag` 생성(크래시 오탐 방지)
- pub cache 로컬 패치 3건 — `pub upgrade` 시 소실 주의, 원본/재적용은 `patches/`:
  - desktop_multi_window: WM_FONTCHANGE null 가드
  - flutter_tts: CMakeLists C++17+/await (VS2019 16.5 C++20 코루틴 미지원)
  - hotkey_manager_windows: RegisterHotKey 실패를 Error 로 전파(선점 감지)
- 아이콘 재생성: `python tool/make_icons.py` (크기별 렌디션)

## 테스트/검증 관례

- 실행 검증은 샌드박스 권장: APPDATA/TEMP env 오버라이드 + clean.flag 선생성.
  단 **shared_preferences는 실제 Roaming을 읽는다**(env 무시) — 텔레메트리
  오염 주의 (기기B=이 PC 리포트는 분석에서 제외 표기)
- 이 PC에서 개발자가 앱을 실사용 중(장기 스톱워치) — 타이머 상태를 바꾸는
  자동화 테스트 금지(랩·치트시트 등 무해한 조작만)
