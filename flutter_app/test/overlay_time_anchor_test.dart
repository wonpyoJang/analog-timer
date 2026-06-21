// overlay_widget.dart의 _segRemainMs / _swElapsedMs 게터 로직을
// 결정론적으로 검증하기 위한 독립 테스트.
// 프로덕션 게터는 DateTime.now()를 직접 호출하지만, 여기서는
// now를 파라미터로 받아 시간을 고정시킨다.
//
// 현재 구현 (overlay_widget.dart):
//   int get _segRemainMs {
//     if (_ipcTimerReceivedAt == null) return _ipcSegRemainMs;
//     if (!_timerRunning) return _ipcSegRemainMs;
//     final elapsed = DateTime.now().difference(_ipcTimerReceivedAt!).inMilliseconds;
//     return max(0, _ipcSegRemainMs - elapsed);
//   }
//   int get _swElapsedMs {
//     if (_ipcSwReceivedAt == null) return _ipcSwElapsedMs;
//     if (!_swRunning) return _ipcSwElapsedMs;
//     final elapsed = DateTime.now().difference(_ipcSwReceivedAt!).inMilliseconds;
//     return _ipcSwElapsedMs + elapsed;
//   }

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

// ─── 테스트용 게터 함수 (overlay_widget.dart 로직과 1:1 대응) ───────────────

int computeSegRemainMs({
  required bool timerRunning,
  required int ipcSegRemainMs,
  required DateTime? ipcTimerReceivedAt,
  required DateTime now,
}) {
  if (ipcTimerReceivedAt == null) return ipcSegRemainMs;
  if (!timerRunning) return ipcSegRemainMs;
  final elapsed = now.difference(ipcTimerReceivedAt).inMilliseconds;
  return max(0, ipcSegRemainMs - elapsed);
}

int computeSwElapsedMs({
  required bool swRunning,
  required int ipcSwElapsedMs,
  required DateTime? ipcSwReceivedAt,
  required DateTime now,
}) {
  if (ipcSwReceivedAt == null) return ipcSwElapsedMs;
  if (!swRunning) return ipcSwElapsedMs;
  final elapsed = now.difference(ipcSwReceivedAt).inMilliseconds;
  return ipcSwElapsedMs + elapsed;
}

// ─── 헬퍼 ────────────────────────────────────────────────────────────────────

DateTime _fromSeconds(int secondsFromEpoch) =>
    DateTime.fromMillisecondsSinceEpoch(secondsFromEpoch * 1000, isUtc: true);

final DateTime _anchor = DateTime.utc(2024, 1, 1, 12, 0, 0);

DateTime _plus(int ms) => _anchor.add(Duration(milliseconds: ms));

// ─── 1. 분기 커버리지 (Branch Coverage) — 100% ───────────────────────────────

void main() {
  group('[Branch] _segRemainMs: 4가지 실행 경로', () {
    // Branch 1: anchor == null → 원시 IPC 값 반환
    test('anchor null → IPC 값 그대로 반환', () {
      expect(
        computeSegRemainMs(
          timerRunning: true,
          ipcSegRemainMs: 30000,
          ipcTimerReceivedAt: null,
          now: _anchor,
        ),
        30000,
      );
    });

    // Branch 2: timerRunning == false → 원시 IPC 값 반환 (정지 = 고정)
    test('timerRunning=false → elapsed 무시하고 IPC 값 반환', () {
      expect(
        computeSegRemainMs(
          timerRunning: false,
          ipcSegRemainMs: 60000,
          ipcTimerReceivedAt: _anchor,
          now: _plus(10000), // 10초 경과해도
        ),
        60000, // 정지된 값 그대로
      );
    });

    // Branch 3: running + elapsed < remain → 차감
    test('running + elapsed 정상 범위 → ipcSegRemainMs - elapsed', () {
      expect(
        computeSegRemainMs(
          timerRunning: true,
          ipcSegRemainMs: 60000,
          ipcTimerReceivedAt: _anchor,
          now: _plus(5000),
        ),
        55000,
      );
    });

    // Branch 4: running + elapsed >= remain → 0 클램프
    test('running + elapsed > remain → 0 클램프', () {
      expect(
        computeSegRemainMs(
          timerRunning: true,
          ipcSegRemainMs: 3000,
          ipcTimerReceivedAt: _anchor,
          now: _plus(10000),
        ),
        0,
      );
    });
  });

  group('[Branch] _swElapsedMs: 3가지 실행 경로', () {
    // Branch 1: anchor == null
    test('anchor null → IPC 값 그대로', () {
      expect(
        computeSwElapsedMs(
          swRunning: true,
          ipcSwElapsedMs: 12000,
          ipcSwReceivedAt: null,
          now: _anchor,
        ),
        12000,
      );
    });

    // Branch 2: swRunning == false
    test('swRunning=false → elapsed 무시하고 IPC 값 반환', () {
      expect(
        computeSwElapsedMs(
          swRunning: false,
          ipcSwElapsedMs: 5000,
          ipcSwReceivedAt: _anchor,
          now: _plus(15000), // 15초 경과해도
        ),
        5000, // 정지 값 고정
      );
    });

    // Branch 3: running → 누적
    test('swRunning=true → ipcSwElapsedMs + elapsed', () {
      expect(
        computeSwElapsedMs(
          swRunning: true,
          ipcSwElapsedMs: 5000,
          ipcSwReceivedAt: _anchor,
          now: _plus(3000),
        ),
        8000,
      );
    });
  });

  // ─── 2. 경계값 분석 (Boundary Value Analysis) ─────────────────────────────

  group('[BVA] 타이머 remain 경계값', () {
    test('remain = 0: 이미 만료된 세그먼트, elapsed=0 → 0 반환', () {
      expect(
        computeSegRemainMs(
          timerRunning: true,
          ipcSegRemainMs: 0,
          ipcTimerReceivedAt: _anchor,
          now: _anchor,
        ),
        0,
      );
    });

    test('remain = 1ms: 만료 직전, elapsed=0 → 1 반환', () {
      expect(
        computeSegRemainMs(
          timerRunning: true,
          ipcSegRemainMs: 1,
          ipcTimerReceivedAt: _anchor,
          now: _anchor,
        ),
        1,
      );
    });

    test('remain = 1ms, elapsed = 1ms: 정확히 만료 → 0', () {
      expect(
        computeSegRemainMs(
          timerRunning: true,
          ipcSegRemainMs: 1,
          ipcTimerReceivedAt: _anchor,
          now: _plus(1),
        ),
        0,
      );
    });

    test('elapsed = 0: IPC 즉시 수신, 차감 없음', () {
      expect(
        computeSegRemainMs(
          timerRunning: true,
          ipcSegRemainMs: 60000,
          ipcTimerReceivedAt: _anchor,
          now: _anchor, // elapsed = 0
        ),
        60000,
      );
    });

    test('elapsed = remain - 1: 만료 직전 1ms', () {
      expect(
        computeSegRemainMs(
          timerRunning: true,
          ipcSegRemainMs: 10000,
          ipcTimerReceivedAt: _anchor,
          now: _plus(9999),
        ),
        1,
      );
    });

    test('elapsed = remain: 정확히 만료 → 0', () {
      expect(
        computeSegRemainMs(
          timerRunning: true,
          ipcSegRemainMs: 10000,
          ipcTimerReceivedAt: _anchor,
          now: _plus(10000),
        ),
        0,
      );
    });

    test('elapsed = remain + 1ms: 만료 후 1ms → 0 (음수 불가)', () {
      expect(
        computeSegRemainMs(
          timerRunning: true,
          ipcSegRemainMs: 10000,
          ipcTimerReceivedAt: _anchor,
          now: _plus(10001),
        ),
        0,
      );
    });

    test('remain 음수 입력 방어: max(0, negative - elapsed) → 0', () {
      // IPC 데이터 손상 시나리오
      expect(
        computeSegRemainMs(
          timerRunning: true,
          ipcSegRemainMs: -1,
          ipcTimerReceivedAt: _anchor,
          now: _anchor,
        ),
        0, // max(0, -1 - 0) = 0
      );
    });
  });

  group('[BVA] 스톱워치 elapsed 경계값', () {
    test('elapsed = 0: 즉시 쿼리 → IPC 값 그대로', () {
      expect(
        computeSwElapsedMs(
          swRunning: true,
          ipcSwElapsedMs: 5000,
          ipcSwReceivedAt: _anchor,
          now: _anchor,
        ),
        5000,
      );
    });

    test('elapsed = 1ms: 최소 증가', () {
      expect(
        computeSwElapsedMs(
          swRunning: true,
          ipcSwElapsedMs: 5000,
          ipcSwReceivedAt: _anchor,
          now: _plus(1),
        ),
        5001,
      );
    });

    test('ipcSwElapsedMs = 0: 스톱워치 리셋 직후', () {
      expect(
        computeSwElapsedMs(
          swRunning: true,
          ipcSwElapsedMs: 0,
          ipcSwReceivedAt: _anchor,
          now: _plus(500),
        ),
        500,
      );
    });
  });

  // ─── 3. 정밀도 검증 (Precision) ───────────────────────────────────────────

  group('[Precision] 시간 앵커 정확도', () {
    test('500ms 경과: 초 단위 표시에서 0.5s 오차 허용', () {
      final result = computeSegRemainMs(
        timerRunning: true,
        ipcSegRemainMs: 60000,
        ipcTimerReceivedAt: _anchor,
        now: _plus(500),
      );
      expect(result, 59500);
      // 표시 단위: 초 → 59초로 표시 (오차 < 1s)
      expect(result ~/ 1000, 59);
    });

    test('999ms 경과: 여전히 59초 표시 (올림 없음)', () {
      final result = computeSegRemainMs(
        timerRunning: true,
        ipcSegRemainMs: 60000,
        ipcTimerReceivedAt: _anchor,
        now: _plus(999),
      );
      expect(result, 59001);
      expect(result ~/ 1000, 59);
    });

    test('1000ms 경과: 정확히 1초 차감 → 59초', () {
      final result = computeSegRemainMs(
        timerRunning: true,
        ipcSegRemainMs: 60000,
        ipcTimerReceivedAt: _anchor,
        now: _plus(1000),
      );
      expect(result, 59000);
      expect(result ~/ 1000, 59);
    });

    test('IPC 수신 후 1s 내 표시값: 주앱과 최대 1s 차이', () {
      // fire-and-forget 1s heartbeat 기준: 최악 1s 지연
      const ipcRemain = 120000; // 2:00
      final received = _anchor;
      final displayTime = _plus(999); // IPC 수신 999ms 후 표시

      final overlay = computeSegRemainMs(
        timerRunning: true,
        ipcSegRemainMs: ipcRemain,
        ipcTimerReceivedAt: received,
        now: displayTime,
      );
      // 주앱은 이미 999ms 진행
      final mainApp = ipcRemain - 999;
      expect((overlay - mainApp).abs(), lessThan(1000));
    });
  });

  // ─── 4. 대규모 값 (Scale) ─────────────────────────────────────────────────

  group('[Scale] 대규모 시간 값', () {
    test('1시간 세그먼트 (3600s): 30분 경과 → 30분 남음', () {
      expect(
        computeSegRemainMs(
          timerRunning: true,
          ipcSegRemainMs: 3600000, // 1 hour
          ipcTimerReceivedAt: _anchor,
          now: _plus(1800000), // 30 minutes later
        ),
        1800000,
      );
    });

    test('24시간 스톱워치 (86400s) + 1초', () {
      expect(
        computeSwElapsedMs(
          swRunning: true,
          ipcSwElapsedMs: 86400000,
          ipcSwReceivedAt: _anchor,
          now: _plus(1000),
        ),
        86401000,
      );
    });

    test('최대 정수 근처 remain (안전한 int 범위): 0 클램프 동작', () {
      const bigRemain = 100000000; // ~27시간
      expect(
        computeSegRemainMs(
          timerRunning: true,
          ipcSegRemainMs: bigRemain,
          ipcTimerReceivedAt: _anchor,
          now: _plus(bigRemain + 1),
        ),
        0, // 만료 후 클램프
      );
    });
  });

  // ─── 5. 상태 전이 시나리오 ────────────────────────────────────────────────

  group('[Transition] 상태 전이', () {
    test('일시정지 → 재개: 재개 시 앵커 갱신으로 드리프트 없음', () {
      // 3s 동안 정지
      final pausedRemain = computeSegRemainMs(
        timerRunning: false,
        ipcSegRemainMs: 60000,
        ipcTimerReceivedAt: _anchor,
        now: _plus(3000), // 3s 경과 (정지 → 변화 없음)
      );
      expect(pausedRemain, 60000);

      // 재개 직후 새 IPC 수신: 앵커가 갱신됨
      final resumeAnchor = _plus(3000); // 재개 시각
      final resumedRemain = computeSegRemainMs(
        timerRunning: true,
        ipcSegRemainMs: 60000, // 정지 중 아무것도 안 빠짐
        ipcTimerReceivedAt: resumeAnchor,
        now: _plus(4000), // 재개 후 1s
      );
      expect(resumedRemain, 59000);
    });

    test('세그먼트 전환: 새 remain으로 앵커 갱신', () {
      // 세그먼트 A: 5s 남음
      const remainA = 5000;
      final anchorA = _anchor;

      // 세그먼트 B: 전환 후 새 앵커 (남은 시간 300s)
      final anchorB = _plus(5000); // A 만료 시각
      const remainB = 300000;

      final resultB = computeSegRemainMs(
        timerRunning: true,
        ipcSegRemainMs: remainB,
        ipcTimerReceivedAt: anchorB,
        now: _plus(8000), // B 시작 후 3s
      );
      // 사용하지 않지만 컴파일 확인용
      expect(remainA, 5000);
      expect(anchorA, _anchor);
      expect(resultB, 297000); // 300s - 3s
    });

    test('play 탭 직후: elapsed=0, 값 변화 없음', () {
      const elapsedAtTap = 100000; // SW 이미 100s 경과
      final tapTime = _anchor;
      expect(
        computeSwElapsedMs(
          swRunning: true,
          ipcSwElapsedMs: elapsedAtTap,
          ipcSwReceivedAt: tapTime,
          now: tapTime, // elapsed = 0
        ),
        elapsedAtTap,
      );
    });
  });

  // ─── 6. 복합 상태 (Mixed States) ─────────────────────────────────────────

  group('[Mixed] 타이머·스톱워치 독립 동작', () {
    test('타이머 running + SW paused: 각자 독립', () {
      final timer = computeSegRemainMs(
        timerRunning: true,
        ipcSegRemainMs: 60000,
        ipcTimerReceivedAt: _anchor,
        now: _plus(5000),
      );
      final sw = computeSwElapsedMs(
        swRunning: false,
        ipcSwElapsedMs: 30000,
        ipcSwReceivedAt: _anchor,
        now: _plus(5000),
      );
      expect(timer, 55000); // 타이머 진행
      expect(sw, 30000); // SW 정지
    });

    test('타이머 paused + SW running: 각자 독립', () {
      final timer = computeSegRemainMs(
        timerRunning: false,
        ipcSegRemainMs: 60000,
        ipcTimerReceivedAt: _anchor,
        now: _plus(5000),
      );
      final sw = computeSwElapsedMs(
        swRunning: true,
        ipcSwElapsedMs: 30000,
        ipcSwReceivedAt: _anchor,
        now: _plus(5000),
      );
      expect(timer, 60000); // 타이머 정지
      expect(sw, 35000); // SW 진행
    });

    test('둘 다 running: 동기화 확인', () {
      final elapsed = 7000;
      final timer = computeSegRemainMs(
        timerRunning: true,
        ipcSegRemainMs: 120000,
        ipcTimerReceivedAt: _anchor,
        now: _plus(elapsed),
      );
      final sw = computeSwElapsedMs(
        swRunning: true,
        ipcSwElapsedMs: 45000,
        ipcSwReceivedAt: _anchor,
        now: _plus(elapsed),
      );
      expect(timer, 113000);
      expect(sw, 52000);
    });

    test('둘 다 paused: 둘 다 고정', () {
      final timer = computeSegRemainMs(
        timerRunning: false,
        ipcSegRemainMs: 90000,
        ipcTimerReceivedAt: _anchor,
        now: _plus(10000),
      );
      final sw = computeSwElapsedMs(
        swRunning: false,
        ipcSwElapsedMs: 20000,
        ipcSwReceivedAt: _anchor,
        now: _plus(10000),
      );
      expect(timer, 90000);
      expect(sw, 20000);
    });
  });

  // ─── 7. 회귀 방지 (Regression Prevention) ────────────────────────────────

  group('[Regression] 수정 전 버그 재현 방지', () {
    test('R-01: IPC 5초 후 표시 — 시간앵커로 정확한 값 계산', () {
      // 버그: 오버레이가 IPC 값을 raw로 표시 (5s 오차)
      // 수정 후: 앵커 계산으로 0s 오차
      const ipcRemain = 150000; // 2:30
      final result = computeSegRemainMs(
        timerRunning: true,
        ipcSegRemainMs: ipcRemain,
        ipcTimerReceivedAt: _anchor,
        now: _plus(5000),
      );
      // 주앱 기준: 2:30 - 5s = 2:25 = 145000ms
      expect(result, 145000);
      // 시간앵커 없이는 150000 표시 → 5s 오차
    });

    test('R-02: 19초 IPC 없어도 계속 진행 (시간앵커 long-gap)', () {
      expect(
        computeSegRemainMs(
          timerRunning: true,
          ipcSegRemainMs: 60000,
          ipcTimerReceivedAt: _anchor,
          now: _plus(19000),
        ),
        41000,
      );
    });

    test('R-03: SW 37초 갭 — 시간앵커로 누적', () {
      expect(
        computeSwElapsedMs(
          swRunning: true,
          ipcSwElapsedMs: 2383000, // 39:43
          ipcSwReceivedAt: _anchor,
          now: _plus(37000),
        ),
        2420000, // 39:43 + 37s = 40:20
      );
    });

    test('R-04: 복합 동결 시나리오 — timerRunning=true, swRunning=true 전제', () {
      // 이전 버그: timerRunning=false IPC 수신 후 IPC 끊김 → 표시 고정
      // 현재 구현: timerRunning=false이면 IPC 값 고정 (정지 신뢰)
      // 새 구현에서는 1s heartbeat로 IPC가 끊기지 않음
      final anchor = _fromSeconds(1000);
      final now = _fromSeconds(1037); // 37초 경과

      // timerRunning=true인 경우: 시간앵커 작동
      final timerResult = computeSegRemainMs(
        timerRunning: true,
        ipcSegRemainMs: 435000,
        ipcTimerReceivedAt: anchor,
        now: now,
      );
      final swResult = computeSwElapsedMs(
        swRunning: true,
        ipcSwElapsedMs: 2383000,
        ipcSwReceivedAt: anchor,
        now: now,
      );
      expect(timerResult, 398000); // 07:15 - 37s = 06:38
      expect(swResult, 2420000); // 39:43 + 37s = 40:20
    });
  });

  // ─── 8. 동시성 안정성 (Concurrency Safety) ───────────────────────────────

  group('[Concurrency] IPC 연속 수신 시나리오', () {
    test('연속 IPC 수신: 가장 최근 값이 올바름', () {
      // fire-and-forget 후 다중 IPC가 빠르게 도착하는 시나리오
      final anchor1 = _anchor;
      final anchor2 = _plus(1000);
      final anchor3 = _plus(2000);

      // 각각 수신 즉시 표시 (elapsed=0)
      expect(
        computeSegRemainMs(
          timerRunning: true,
          ipcSegRemainMs: 60000,
          ipcTimerReceivedAt: anchor1,
          now: anchor1,
        ),
        60000,
      );
      expect(
        computeSegRemainMs(
          timerRunning: true,
          ipcSegRemainMs: 59000,
          ipcTimerReceivedAt: anchor2,
          now: anchor2,
        ),
        59000,
      );
      expect(
        computeSegRemainMs(
          timerRunning: true,
          ipcSegRemainMs: 58000,
          ipcTimerReceivedAt: anchor3,
          now: anchor3,
        ),
        58000,
      );
    });

    test('가장 최근 IPC anchor 기준 표시: 이전 IPC의 오염 없음', () {
      // 최신 IPC: anchor3, remain=58000, 500ms 후 표시
      final anchor3 = _plus(2000);
      final displayTime = _plus(2500);

      expect(
        computeSegRemainMs(
          timerRunning: true,
          ipcSegRemainMs: 58000,
          ipcTimerReceivedAt: anchor3,
          now: displayTime,
        ),
        57500, // 58000 - 500ms
      );
    });
  });

  // ─── 9. 요구사항 준수 검증 ────────────────────────────────────────────────

  group('[Requirement] ≤2초 오차 요구사항', () {
    // 요구사항: 오버레이 값과 주앱 값의 차이가 2초 미만
    // 현재 구현: fire-and-forget + 1s heartbeat → IPC ≤1s 지연
    // 시간앵커: IPC 수신 시각 기준으로 elapsed 계산 → drift=0

    test('IPC 수신 직후 (0ms): 주앱과 정확히 일치', () {
      const trueRemain = 120000; // 주앱의 실제 값
      const ipcRemain = trueRemain; // IPC는 현재 값

      final overlay = computeSegRemainMs(
        timerRunning: true,
        ipcSegRemainMs: ipcRemain,
        ipcTimerReceivedAt: _anchor,
        now: _anchor, // elapsed = 0
      );
      expect((overlay - trueRemain).abs(), 0);
    });

    test('IPC 수신 1초 후: 오차 = 0ms (시간앵커가 보정)', () {
      // IPC 수신 1초 후 표시: 1초 경과를 앵커로 보정
      const ipcRemain = 120000;
      const elapsed = 1000;

      final overlay = computeSegRemainMs(
        timerRunning: true,
        ipcSegRemainMs: ipcRemain,
        ipcTimerReceivedAt: _anchor,
        now: _plus(elapsed),
      );
      final trueRemain = ipcRemain - elapsed; // 주앱의 실제 값
      expect((overlay - trueRemain).abs(), 0); // 완벽 일치
    });

    test('최악 시나리오 (1s heartbeat 직전): 오차 < 2000ms', () {
      // IPC 1초 후 (다음 IPC 직전) 표시
      const ipcRemain = 120000;
      const elapsedWorstCase = 999; // 1s heartbeat 직전

      final overlay = computeSegRemainMs(
        timerRunning: true,
        ipcSegRemainMs: ipcRemain,
        ipcTimerReceivedAt: _anchor,
        now: _plus(elapsedWorstCase),
      );
      final trueRemain = ipcRemain - elapsedWorstCase;
      expect((overlay - trueRemain).abs(), lessThan(2000)); // ≤2s 요구사항
    });
  });
}
