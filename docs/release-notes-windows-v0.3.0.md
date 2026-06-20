# Analog Timer — Windows v0.3.0

분석 시계(Analog Timer)의 Windows 데스크톱 버전입니다.

## 새로운 기능

### 다국어 지원 (15개 언어)
- **English · 한국어 · 中文(简体) · 中文(繁體) · Español · العربية · Português · Français · 日本語 · Deutsch · Русский · हिन्दी · Bahasa Indonesia · Italiano · Türkçe**
- 앱 시작 시 **OS 언어 자동 감지**, 헤더의 🌐 버튼으로 **수동 선택**(선택은 저장됨)
- 아랍어 선택 시 **RTL 레이아웃** 자동 적용
- 화면 전체 현지화: 타이틀·날짜(요일)·버튼·세그먼트·프리셋·기본 프리셋·타이머 로그·패널
- 날짜 요일은 로케일별 표기 (예: `6/20 (토)` / `6/20 (土)` / `6/20 (Sat)`)
- 기본 프리셋은 현재 언어로 동적 생성 (언어를 바꾸면 이름·세그먼트도 따라감)

## 이전 버전(v0.2.0)에서 이어지는 기능
- 세그먼트 **프리셋** 저장·추가·편집/관리
- 글자 **외곽선(stroke+shadow)** 가독성
- **Pretendard** 폰트 + **등폭** 숫자
- 메인/위젯 **날짜·요일** 표시, 위젯 **전체 드래그** 이동

## 설치 방법

### 포터블 ZIP (설치 불필요)
1. `AnalogTimer-Windows-v0.3.0-portable.zip` 다운로드
2. 압축 해제 후 `AnalogTimer\analog_timer.exe` 실행

### MSIX 설치 패키지
- 자체 서명(CN=zero)으로, 동봉한 `AnalogTimer-publisher.cer` 인증서를 먼저 **로컬 컴퓨터 → 신뢰할 수 있는 사람/루트**에 설치한 뒤
- `AnalogTimer-Windows-v0.3.0.msix` 실행으로 설치.

## 무결성 확인
`SHA256SUMS.txt` 의 해시로 다운로드 파일을 검증할 수 있습니다.
