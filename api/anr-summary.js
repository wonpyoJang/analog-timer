import { isAuthed } from './_lib/auth.js';
import { Redis } from '@upstash/redis';

const redis = Redis.fromEnv();
const KEY = 'telemetry:reports';
const MAX = 1000;

// ANR-free 비율 집계(어드민, 비밀키). telemetry.js 가 저장한 리포트에서
// type='vitals_rollup'(세션/ANR 카운트)과 type='anr'(개별 ANR)을 읽어 요약한다.
//
// 주의: 6σ(3.4/1e6) 유의 추정에는 수백만 세션이 필요 → 이 요약은 방향성 KPI·조기신호용.
// 권위 지표는 Play Console Android Vitals(전체 설치 기반). GET /api/anr-summary?version=&token=
export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-Admin-Token');
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'GET') return res.status(405).json({ error: 'method not allowed' });

  if (!isAuthed(req)) {
    return res.status(401).json({ error: 'unauthorized' });
  }

  const raw = await redis.lrange(KEY, 0, MAX - 1);
  const reports = raw.map((r) => (typeof r === 'string' ? JSON.parse(r) : r));

  const versionFilter = req.query.version || null;
  const num = (v) => (typeof v === 'number' ? v : 0);

  // 디바이스별 최신 rollup 만 채택(rollup 은 누적 카운트라 최신이 전체를 대표).
  const latestByDevice = new Map();
  let anrEvents = 0;
  let userPerceivedAnr = 0;

  for (const r of reports) {
    if (versionFilter && r.appVersion !== versionFilter) continue;
    if (r.platform && r.platform !== 'android') continue;
    if (r.type === 'vitals_rollup') {
      const ex = r.extra || {};
      if (ex.anrMeasurable === false) continue; // 측정 불능(API<30)은 분모 제외
      const prev = latestByDevice.get(r.deviceId);
      const at = num(ex.atMs);
      if (!prev || at > prev.atMs) {
        latestByDevice.set(r.deviceId, {
          atMs: at,
          sessions: num(ex.sessions),
          anrSessions: num(ex.anrSessions),
        });
      }
    } else if (r.type === 'anr') {
      anrEvents++;
      if (r.extra && r.extra.userPerceived) userPerceivedAnr++;
    }
  }

  let sessions = 0;
  let anrSessions = 0;
  for (const v of latestByDevice.values()) {
    sessions += v.sessions;
    anrSessions += v.anrSessions;
  }
  const anrFreeRatio = sessions > 0 ? 1 - anrSessions / sessions : null;

  return res.status(200).json({
    version: versionFilter,
    devices: latestByDevice.size,
    sessions,
    anrSessions,
    anrFreeRatio, // null = 표본 없음
    anrEvents,
    userPerceivedAnr,
    // 참고 임계: Play Vitals bad-behavior = 0.47% ANR율(= anrFreeRatio 0.9953).
    badBehaviorThreshold: 0.9953,
    sixSigmaTarget: 0.9999966,
    note: '방향성 KPI. 6σ 판정은 Play Console Android Vitals(전체 기반)가 1차 소스.',
  });
}
