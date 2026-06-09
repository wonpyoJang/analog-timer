import { Redis } from '@upstash/redis';

const redis = Redis.fromEnv();

const ROOM_ID_RE = /^[A-Z0-9]{4,8}$/;

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();

  const { roomId } = req.query;
  if (!ROOM_ID_RE.test(roomId)) {
    return res.status(400).json({ error: 'roomId must be 4–8 uppercase alphanumeric characters' });
  }

  const key = `room:${roomId}`;

  if (req.method === 'GET') {
    const data = await redis.get(key);
    return res.status(200).json(data ?? null);
  }

  if (req.method === 'POST') {
    const { action, timestamp, remaining_ms, seg_idx, segments, loop, deviceId } = req.body ?? {};
    if (!action || !timestamp || !deviceId) {
      return res.status(400).json({ error: 'Missing required fields: action, timestamp, deviceId' });
    }

    const event = {
      action,
      timestamp,
      remaining_ms: remaining_ms ?? 0,
      seg_idx: seg_idx ?? 0,
      segments: segments ?? [],
      loop: loop ?? false,
      deviceId,
      eventId: Date.now().toString(36) + Math.random().toString(36).slice(2, 6),
    };

    // TTL 24시간 — 방치된 룸 자동 정리
    await redis.set(key, event, { ex: 86400 });
    return res.status(200).json({ ok: true, eventId: event.eventId });
  }

  res.status(405).json({ error: 'Method not allowed' });
}
