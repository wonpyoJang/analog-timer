import { Redis } from '@upstash/redis';

const redis = Redis.fromEnv();

// 0/O/1/I 등 헷갈리는 문자 제외한 roomId 문자셋.
const ROOM_CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const ROOM_RE = /^[A-Z2-9]{8}$/;

function genRoom() {
  let s = '';
  for (let i = 0; i < 8; i++) {
    s += ROOM_CHARS[Math.floor(Math.random() * ROOM_CHARS.length)];
  }
  return s;
}
function genCode() {
  return Math.floor(100000 + Math.random() * 900000).toString(); // 6자리
}

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'method not allowed' });
  }

  const body = req.body ?? {};
  const action = body.action;

  // ── 페어링 코드 발급 — 데스크탑/기존 기기가 새 기기를 초대 ──────────
  // 이미 room 이 있으면(기기 추가) 그 roomId 를, 없으면 새 room 을 만든다.
  if (action === 'create') {
    const roomId =
      typeof body.roomId === 'string' && ROOM_RE.test(body.roomId)
        ? body.roomId
        : genRoom();
    let code = genCode();
    // 코드 충돌 시 재시도(nx). 페어링은 일회성·단명(5분).
    for (let i = 0; i < 5; i++) {
      const ok = await redis.set(`pair:${code}`, roomId, { ex: 300, nx: true });
      if (ok) break;
      code = genCode();
    }
    return res.status(200).json({ code, roomId, expiresIn: 300 });
  }

  // ── 페어링 코드 교환 — 새 기기가 코드로 roomId 획득(일회성) ─────────
  if (action === 'redeem') {
    const code = String(body.code ?? '').trim();
    if (!/^\d{6}$/.test(code)) {
      return res.status(400).json({ error: 'code must be 6 digits' });
    }
    const roomId = await redis.get(`pair:${code}`);
    if (!roomId) {
      return res.status(404).json({ error: 'invalid or expired code' });
    }
    await redis.del(`pair:${code}`); // 일회성 — 교환 즉시 폐기
    return res.status(200).json({ roomId });
  }

  return res.status(400).json({ error: 'unknown action' });
}
