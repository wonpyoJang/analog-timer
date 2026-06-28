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
    return res.status(200).json(out);
  }

  // ── push — kind 별 last-write-wins(ts 비교) ──────────────────────
  if (req.method === 'POST') {
    const body = req.body ?? {};
    if (JSON.stringify(body).length > MAX_BODY) {
      return res.status(413).json({ error: 'payload too large' });
    }
    const { deviceId, kind, data, ts } = body;
    if (!KINDS.includes(kind)) {
      return res.status(400).json({ error: 'invalid kind' });
    }
    if (!deviceId || typeof ts !== 'number') {
      return res.status(400).json({ error: 'deviceId and numeric ts required' });
    }

    const key = `sync:${roomId}:${kind}`;
    const cur = await redis.get(key);
    // 이미 더 최신(또는 동일) 스냅샷이 있으면 덮어쓰지 않는다.
    if (cur && typeof cur.ts === 'number' && cur.ts >= ts) {
      return res.status(200).json({ ok: true, skipped: true, currentTs: cur.ts });
    }
    await redis.set(key, { data, ts, deviceId }, { ex: TTL });
    return res.status(200).json({ ok: true });
  }

  return res.status(405).json({ error: 'method not allowed' });
}
