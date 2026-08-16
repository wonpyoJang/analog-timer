// 어드민 로그인/로그아웃 — 토큰 1회 검증 후 HttpOnly 세션 쿠키 발급.
//
// POST   {token}  → 일치 시 Set-Cookie(at_admin, 7일) — 이후 어드민 API 는
//                   쿠키만으로 인증되어 URL 에 토큰이 남지 않는다.
// DELETE          → 쿠키 말소(로그아웃).
import {
  checkToken,
  createSessionCookie,
  clearSessionCookie,
} from './_lib/auth.js';

export default async function handler(req, res) {
  if (req.method === 'POST') {
    let token = '';
    try {
      const body =
        typeof req.body === 'string' ? JSON.parse(req.body) : req.body;
      token = String(body?.token ?? '');
    } catch (_) {
      return res.status(400).json({ error: 'bad request' });
    }
    if (!checkToken(token)) {
      // 무차별 대입 완화 — 실패 응답을 일괄 지연.
      await new Promise((r) => setTimeout(r, 800));
      return res.status(401).json({ error: 'unauthorized' });
    }
    res.setHeader('Set-Cookie', createSessionCookie());
    return res.status(200).json({ ok: true });
  }

  if (req.method === 'DELETE') {
    res.setHeader('Set-Cookie', clearSessionCookie());
    return res.status(200).json({ ok: true });
  }

  res.status(405).json({ error: 'method not allowed' });
}
