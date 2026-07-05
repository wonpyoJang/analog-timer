import { Redis } from '@upstash/redis';

const redis = Redis.fromEnv();

// 동기화 항목 — 타이머 상태 / 프리셋 목록 / 설정.
const KINDS = ['timer', 'presets', 'settings'];
const ROOM_RE = /^[A-Z2-9]{8}$/;
const TTL = 60 * 60 * 24 * 30; // 30일 — push 마다 갱신되어 활성 room 은 유지.
const MAX_BODY = 256 * 1024;

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(200).end();

  const roomId = req.query.roomId;
  if (!ROOM_RE.test(roomId)) {
    return res.status(400).json({ error: 'invalid roomId' });
  }

  // ── pull — 전체 상태(각 kind 의 최신 스냅샷) ──────────────────────
  // 반환: { timer:{data,ts,deviceId}|null, presets:..., settings:... }
  if (req.method === 'GET') {
    const out = {};
    for (const kind of KINDS) {
      out[kind] = await redis.get(`sync:${roomId}:${kind}`);
    }
    // now: 클라가 "push 후 경과시간"을 서버 시계만으로 계산하는 기준 —
    // 기기 벽시계 스큐가 러닝 타이머 보정에 섞이는 것을 차단.
    out.now = Date.now();
    return res.status(200).json(out);
  }

  // ── push — 도착순 last-write-wins, ts 는 **서버가** 찍는다 ─────────
  // 클라이언트 시계는 신뢰하지 않는다: 시계가 미래로 틀어진 기기가 클라 ts 로
  // LWW 를 잠가버리면 다른 모든 기기의 push 가 조용히 무시되는 최악의 장애가
  // 된다. 서버 시각 + 모노토닉 가드(동시 도착 시 +1)로 항상 전진만 한다.
  if (req.method === 'POST') {
    const body = req.body ?? {};
    if (JSON.stringify(body).length > MAX_BODY) {
      return res.status(413).json({ error: 'payload too large' });
    }
    const { deviceId, kind, data } = body;
    if (!KINDS.includes(kind)) {
      return res.status(400).json({ error: 'invalid kind' });
    }
    if (!deviceId) {
      return res.status(400).json({ error: 'deviceId required' });
    }

    const key = `sync:${roomId}:${kind}`;
    const cur = await redis.get(key);
    let ts = Date.now();
    if (cur && typeof cur.ts === 'number' && cur.ts >= ts) {
      ts = cur.ts + 1; // 같은 ms 내 연속 push 도 항상 전진
    }
    await redis.set(key, { data, ts, deviceId }, { ex: TTL });
    // 클라는 반환된 ts 를 저장해 자기 push 를 pull 에서 재적용하지 않는다.
    return res.status(200).json({ ok: true, ts });
  }

  return res.status(405).json({ error: 'method not allowed' });
}
