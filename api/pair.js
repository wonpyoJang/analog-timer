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
    // 코드 충돌 시 재시도(nx). 페어링은 일회성·단명(5분).
    for (let i = 0; i < 5; i++) {
      const code = genCode();
      const ok = await redis.set(`pair:${code}`, roomId, { ex: 300, nx: true });
      if (ok) return res.status(200).json({ code, roomId, expiresIn: 300 });
    }
    // 5회 연속 충돌(사실상 불가) — 저장 안 된 코드를 내보내지 않는다.
    return res.status(503).json({ error: 'code space exhausted, retry' });
  }

  // ── 페어링 코드 교환 — 새 기기가 코드로 roomId 획득(일회성) ─────────
  if (action === 'redeem') {
    // 브루트포스 방어 — 6자리 코드는 공간이 작으므로 IP 당 분당 20회 제한.
    const ip = String(
      req.headers['x-forwarded-for'] ?? req.socket?.remoteAddress ?? 'unknown',
    ).split(',')[0].trim();
    const attempts = await redis.incr(`pairrl:${ip}`);
    if (attempts === 1) await redis.expire(`pairrl:${ip}`, 60);
    if (attempts > 20) {
      return res.status(429).json({ error: 'too many attempts, slow down' });
    }

    const code = String(body.code ?? '').trim();
    if (!/^\d{6}$/.test(code)) {
      return res.status(400).json({ error: 'code must be 6 digits' });
    }
    // GET+DEL 원자화(Lua) — 동시 redeem 시 정확히 한 기기만 성공(일회성 보장).
    const roomId = await redis.eval(
      `local v = redis.call('GET', KEYS[1])
       if v then redis.call('DEL', KEYS[1]) end
       return v`,
      [`pair:${code}`],
      [],
    );
    if (!roomId) {
      return res.status(404).json({ error: 'invalid or expired code' });
    }
    return res.status(200).json({ roomId });
  }

  return res.status(400).json({ error: 'unknown action' });
}
