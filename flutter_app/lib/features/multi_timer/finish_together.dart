import 'models/countdown_timer.dart';

/// 동시 완료(끝 맞추기) 계산·어긋남 로직(디자인 "동시 완료 화면").
///
/// 가장 긴 항목을 지금 시작하고, 짧은 항목은 (max − 자기길이)만큼 지연 시작해
/// 모두 같은 시각(now+max)에 끝나게 한다. 순수 함수 — 유닛테스트로 잠근다.

class FinishPlan {
  /// 각 항목의 시작 절대시각(epoch ms). now 보다 크면 waiting(지연 시작).
  final List<int> startAtMs;

  /// 모두가 끝나야 하는 목표 완료시각(epoch ms).
  final int targetFinishMs;
  const FinishPlan(this.startAtMs, this.targetFinishMs);
}

/// 지속시간 목록 → 동시 완료 계획. 가장 긴 항목 startAt=now, 나머지는 지연.
FinishPlan computeFinishTogether(List<int> durationsMs, int nowMs) {
  var maxMs = 0;
  for (final d in durationsMs) {
    if (d > maxMs) maxMs = d;
  }
  final target = nowMs + maxMs;
  return FinishPlan([for (final d in durationsMs) target - d], target);
}

/// 어긋남(늦게 시작해 정렬이 깨짐) 정보 — 배너·복구 제안용(§5).
class FinishDrift {
  /// 가장 늦게 끝나는(문제) 타이머 id 와 그 완료시각.
  final String lateId;
  final int lateFinishMs;

  /// 늘려서 맞출 수 있는 기준(anchor) 타이머 id — 지금 실행 중이고 더 일찍 끝나는 것.
  final String anchorId;
  final int anchorFinishMs;

  /// 벌어진 시간(ms) — anchor 를 이만큼 늘리면 다시 맞는다.
  int get gapMs => lateFinishMs - anchorFinishMs;
  const FinishDrift({
    required this.lateId,
    required this.lateFinishMs,
    required this.anchorId,
    required this.anchorFinishMs,
  });
}

/// 같은 groupId 묶음의 완료시각 격차가 [thresholdMs] 를 넘으면 FinishDrift 반환.
/// running 은 now+remainMs, waiting 은 startAtMs+totalMs 로 완료시각을 추정한다.
/// 줄일 수 없는 항목(늦게 끝나는 쪽)은 건드리지 않고, 늘릴 수 있는 anchor 만 제안.
FinishDrift? finishTogetherDrift(
  List<CountdownTimer> timers,
  int nowMs, {
  int thresholdMs = 60000,
}) {
  final groups = <String, List<CountdownTimer>>{};
  for (final t in timers) {
    if (t.groupId == null || t.done) continue;
    (groups[t.groupId!] ??= []).add(t);
  }
  int finishOf(CountdownTimer t) =>
      t.running ? nowMs + t.remainMs : t.startAtMs + t.totalMs;

  for (final members in groups.values) {
    if (members.length < 2) continue;
    CountdownTimer? late;
    var lateFin = -1;
    // anchor = 지금 실행 중이면서 가장 일찍 끝나는 항목(늘릴 수 있는 대상).
    CountdownTimer? anchor;
    var anchorFin = 1 << 62;
    for (final t in members) {
      final f = finishOf(t);
      if (f > lateFin) {
        lateFin = f;
        late = t;
      }
      if (t.running && f < anchorFin) {
        anchorFin = f;
        anchor = t;
      }
    }
    if (late == null || anchor == null || late.id == anchor.id) continue;
    if (lateFin - anchorFin > thresholdMs) {
      return FinishDrift(
        lateId: late.id,
        lateFinishMs: lateFin,
        anchorId: anchor.id,
        anchorFinishMs: anchorFin,
      );
    }
  }
  return null;
}
