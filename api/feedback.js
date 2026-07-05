import { Redis } from '@upstash/redis';

const redis = Redis.fromEnv();

const KEY = 'feedback:items';
const MAX = 500;
const CATEGORIES = ['bug', 'feature', 'other'];
// 첨부 제한 — 사진/동영상만, 동영상 여유있게 200MB.
const MAX_FILE = 200 * 1024 * 1024;
const ALLOWED_TYPES = [
  'image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/heic',
  'video/mp4', 'video/quicktime', 'video/webm', 'video/x-matroska',
];

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, X-Admin-Token');
  if (req.method === 'OPTIONS') return res.status(200).end();

  // ── 첨부 업로드 토큰 발급 — 앱이 Blob 스토리지에 직접 PUT(서버 4.5MB 제한 우회) ──
  if (req.method === 'POST' && req.body?.action === 'upload-token') {
    const { filename, contentType, size } = req.body;
    if (!process.env.BLOB_READ_WRITE_TOKEN) {
      return res.status(503).json({ error: 'blob storage not configured' });
    }
    if (!ALLOWED_TYPES.includes(contentType)) {
      return res.status(400).json({ error: 'only image/video attachments allowed' });
    }
    if (typeof size !== 'number' || size <= 0 || size > MAX_FILE) {
      return res.status(400).json({ error: `size must be 1..${MAX_FILE} bytes` });
    }
    const safe = String(filename ?? 'file')
      .replace(/[^a-zA-Z0-9._-]/g, '_')
      .slice(-80);
    const pathname = `feedback/${Date.now().toString(36)}-${Math.random()
      .toString(36)
      .slice(2, 8)}-${safe}`;
    // dynamic import — 모듈 로드 실패가 함수 전체를 죽이지 않게 + 실제 에러 노출
    let generateClientTokenFromReadWriteToken;
    try {
      ({ generateClientTokenFromReadWriteToken } = await import(
        '@vercel/blob/client'
      ));
    } catch (e) {
      return res.status(500).json({ error: `blob module: ${e.message}` });
    }
    const clientToken = await generateClientTokenFromReadWriteToken({
      token: process.env.BLOB_READ_WRITE_TOKEN,
      pathname,
      allowedContentTypes: [contentType],
      maximumSizeInBytes: MAX_FILE,
      validUntil: Date.now() + 10 * 60 * 1000, // 10분
      addRandomSuffix: false,
    });
    return res.status(200).json({
      clientToken,
      pathname,
      uploadUrl: `https://blob.vercel-storage.com/${pathname}`,
    });
  }

  // ── 피드백 접수 ─────────────────────────────────────────────
  if (req.method === 'POST') {
    const b = req.body ?? {};
    if (!b.deviceId || typeof b.message !== 'string' || !b.message.trim()) {
      return res.status(400).json({ error: 'deviceId and message required' });
    }
    const item = {
      id: Date.now().toString(36) + Math.random().toString(36).slice(2, 6),
      receivedAt: Date.now(),
      category: CATEGORIES.includes(b.category) ? b.category : 'other',
      message: String(b.message).slice(0, 8000),
      contact: b.contact ? String(b.contact).slice(0, 200) : null,
      deviceId: String(b.deviceId).slice(0, 64),
      appVersion: b.appVersion ?? null,
      platform: b.platform ?? null,
      // [{url, name, size, contentType}] — Blob 업로드 완료 후의 공개 URL 목록
      attachments: Array.isArray(b.attachments)
        ? b.attachments.slice(0, 10).map((a) => ({
            url: String(a.url ?? '').slice(0, 500),
            name: String(a.name ?? '').slice(0, 120),
            size: typeof a.size === 'number' ? a.size : null,
            contentType: String(a.contentType ?? '').slice(0, 60),
          }))
        : [],
    };
    await redis.lpush(KEY, JSON.stringify(item));
    await redis.ltrim(KEY, 0, MAX - 1);
    return res.status(200).json({ ok: true, id: item.id });
  }

  // ── 어드민 조회/삭제 ─────────────────────────────────────────
  const token = req.headers['x-admin-token'] || req.query.token;
  const authed = process.env.ADMIN_TOKEN && token === process.env.ADMIN_TOKEN;
  if (req.method === 'GET') {
    if (!authed) return res.status(401).json({ error: 'unauthorized' });
    const limit = Math.min(parseInt(req.query.limit ?? '100', 10) || 100, MAX);
    const raw = await redis.lrange(KEY, 0, limit - 1);
    const items = raw.map((r) => (typeof r === 'string' ? JSON.parse(r) : r));
    return res.status(200).json({ count: items.length, items });
  }
  if (req.method === 'DELETE') {
    if (!authed) return res.status(401).json({ error: 'unauthorized' });
    await redis.del(KEY);
    return res.status(200).json({ ok: true, cleared: true });
  }

  return res.status(405).json({ error: 'method not allowed' });
}
