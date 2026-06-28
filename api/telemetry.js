import { Redis } from '@upstash/redis';

const redis = Redis.fromEnv();

const KEY = 'telemetry:reports';
const MAX = 1000; // 최근 1000건 유지

// 단순 검증 — 과도한 페이로드 차단
const MAX_BODY = 64 * 1024;

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-Admin-Token');

  if (req.method === 'OPTIONS') return res.status(200).end();

  // ── 리포트 수신 (앱 → 서버) ──────────────────────────────
  if (req.method === 'POST') {
    const body = req.body ?? {};
    if (JSON.stringify(body).length > MAX_BODY) {
      return res.status(413).json({ error: 'payload too large' });
    }
    if (!body.deviceId) {
      return res.status(400).json({ error: 'deviceId required' });
    }

    const report = {
      id: Date.now().toString(36) + Math.random().toString(36).slice(2, 6),
      receivedAt: Date.now(),
      type: body.type ?? 'crash', // crash | env | heartbeat
      deviceId: String(body.deviceId).slice(0, 64),
      appVersion: body.appVersion ?? null,
      platform: body.platform ?? null, // windows/macos/...
      osVersion: body.osVersion ?? null,
      gpu: body.gpu ?? null,
      crashKind: body.crashKind ?? null, // dart | native(비정상종료)
      message: typeof body.message === 'string' ? body.message.slice(0, 4000) : null,
      stack: typeof body.stack === 'string' ? body.stack.slice(0, 8000) : null,
      lastState: body.lastState ?? null, // 위젯 on/off, 타이머 상태 등
      eventLog: typeof body.eventLog === 'string' ? body.eventLog.slice(0, 8000) : null,
      breadcrumbs: Array.isArray(body.breadcrumbs) ? body.breadcrumbs.slice(0, 40) : null,
      extra: body.extra ?? null,
    };

    await redis.lpush(KEY, JSON.stringify(report));
    await redis.ltrim(KEY, 0, MAX - 1);
    return res.status(200).json({ ok: true, id: report.id });
  }

  // ── 리포트 조회 (어드민, 비밀키) ──────────────────────────
  if (req.method === 'GET') {
    const token = req.headers['x-admin-token'] || req.query.token;
    if (!process.env.ADMIN_TOKEN || token !== process.env.ADMIN_TOKEN) {
      return res.status(401).json({ error: 'unauthorized' });
    }
    const limit = Math.min(parseInt(req.query.limit ?? '200', 10) || 200, MAX);
    const raw = await redis.lrange(KEY, 0, limit - 1);
    const reports = raw.map((r) => (typeof r === 'string' ? JSON.parse(r) : r));
    return res.status(200).json({ count: reports.length, reports });
  }

  // ── 전체 삭제 (어드민, 비밀키) — 테스트/누적 데이터 정리용 ──────
  if (req.method === 'DELETE') {
    const token = req.headers['x-admin-token'] || req.query.token;
    if (!process.env.ADMIN_TOKEN || token !== process.env.ADMIN_TOKEN) {
      return res.status(401).json({ error: 'unauthorized' });
    }
    await redis.del(KEY);
    return res.status(200).json({ ok: true, cleared: true });
  }

  res.status(405).json({ error: 'method not allowed' });
}
