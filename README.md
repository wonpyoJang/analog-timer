# Analog Timer

아날로그 시계 페이스 위에 세그먼트 타이머 + 스톱워치를 동시에 시각화하는 타이머 앱.

## 로드맵

| 단계 | 타겟 | 상태 |
|------|------|------|
| v0 | 웹 (단일 HTML) | 완료 → [배포](https://analog-timer-kappa.vercel.app) |
| v1 | 웹 확장 (기능 추가) | 계획 |
| v2 | Flutter (모바일 + 데스크톱) | 계획 |

## 디렉토리 구조

```
analog-timer/
├── original/          # 원본 HTML (v0 레퍼런스)
│   └── analog-timer-5.html
├── docs/
│   └── feature-analysis.md   # 기능 분석 및 설계 노트
└── README.md
```

## 핵심 컨셉

시계판의 **현재 분침 위치**를 기준점으로 삼아 타이머 잔여 시간을 쐐기로 시각화.
"몇 분 후에 끝나는지"를 시계판에서 직접 읽을 수 있는 것이 차별점.

상세 분석 → [`docs/feature-analysis.md`](docs/feature-analysis.md)
