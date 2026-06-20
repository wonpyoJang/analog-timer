# Analog Timer — Windows v0.2.0

분석 시계(Analog Timer)의 Windows 데스크톱 버전입니다.

## 새로운 기능

### 세그먼트 프리셋 (템플릿)
- **기본 프리셋 3종 제공**: 뽀모도로 25/5, 52/17, 딥워크 90/20 (집중·휴식 색 구분, 반복 설정 포함)
- **칩 바**: 타이머 세그먼트 영역 상단에서 프리셋을 한 번에 적용 — 현재 세그먼트 목록 **끝에 추가(append)**되어 여러 프리셋을 이어붙여 조합 가능
- **현재 구성 저장**: 지금 편집한 세그먼트들을 이름 붙여 새 프리셋으로 저장
- **프리셋 관리 페이지**(풀스크린): 새로 만들기 / 편집 / 삭제
  - 편집 화면에서 세그먼트 추가·삭제, 이름·분 수정, 색상 변경, 드래그로 순서 변경, 연속 반복 토글

### 가독성 개선
- 시계 중앙의 세그먼트 타이틀·숫자에 **윤곽선(stroke) + 그림자** 적용 — 흰 다이얼, 색 부채꼴, 시침/분침 위 어디서나 글자가 또렷하게 읽힘 (한글 깨짐 해결)

## 설치 방법

### 포터블 ZIP (설치 불필요)
1. `AnalogTimer-Windows-v0.2.0-portable.zip` 다운로드
2. 압축 해제 후 `AnalogTimer\analog_timer.exe` 실행

### MSIX 설치 패키지
- 자체 서명(CN=zero)으로, 설치하려면 동봉한 `AnalogTimer-publisher.cer` 인증서를 먼저 **로컬 컴퓨터 → 신뢰할 수 있는 사람/루트**에 설치해야 합니다.
- 이후 `AnalogTimer-Windows-v0.2.0.msix` 실행으로 설치.

## 무결성 확인
`SHA256SUMS.txt` 의 해시로 다운로드 파일을 검증할 수 있습니다.

```powershell
Get-FileHash .\AnalogTimer-Windows-v0.2.0-portable.zip -Algorithm SHA256
```
