// 어드민 인증 공유 헬퍼 — 세션 쿠키(HMAC 서명) + 레거시 토큰 하위호환.
//
// 세션 쿠키 형식: `<expMs>.<hmacSha256hex>` — 서버 상태 없이(스테이트리스)
// ADMIN_TOKEN 을 키로 서명만 검증한다. 토큰을 회전하면 기존 세션이 전부
// 무효화된다(의도된 동작). Vercel 은 api/ 하위 `_` 프리픽스 경로를 함수로
// 노출하지 않으므로 이 파일은 엔드포인트가 아니다.
import crypto from 'crypto';

export const SESSION_COOKIE = 'at_admin';
const SESSION_TTL_MS = 7 * 24 * 60 * 60 * 1000; // 7일

/// 세션 서명 키 — 비밀번호 해시가 있으면 그것을 우선 사용해, 비밀번호를
/// 바꾸면 기존 세션이 전부 무효화되게 한다. 없으면 레거시 ADMIN_TOKEN.
function sessionSecret() {
  return String(
    process.env.ADMIN_PASSWORD_SCRYPT || process.env.ADMIN_TOKEN || '',
  );
}

function hmac(payload) {
  return crypto.createHmac('sha256', sessionSecret()).update(payload).digest('hex');
}

/// 상수시간 문자열 비교 — 길이가 달라도 조기 반환하지 않는다.
export function safeEqual(a, b) {
  const ab = Buffer.from(String(a));
  const bb = Buffer.from(String(b));
  if (ab.length !== bb.length) {
    // 길이 불일치도 동일 비용의 비교를 수행해 타이밍 힌트를 줄인다.
    crypto.timingSafeEqual(ab, ab);
    return false;
  }
  return crypto.timingSafeEqual(ab, bb);
}

/// 제출된 토큰이 ADMIN_TOKEN 과 일치하는가 (미설정이면 항상 거부).
export function checkToken(token) {
  if (!process.env.ADMIN_TOKEN || !token) return false;
  return safeEqual(token, process.env.ADMIN_TOKEN);
}

/// scrypt 해시 문자열 생성 — `scrypt$N$r$p$salthex$hashhex`.
/// 운영자가 env(ADMIN_PASSWORD_SCRYPT) 값을 만들 때 쓴다.
export function hashPassword(password, N = 16384, r = 8, p = 1) {
  const salt = crypto.randomBytes(16);
  const hash = crypto.scryptSync(String(password), salt, 32, { N, r, p });
  return `scrypt$${N}$${r}$${p}$${salt.toString('hex')}$${hash.toString('hex')}`;
}

/// id/비밀번호 검증 — ADMIN_ID + ADMIN_PASSWORD_SCRYPT(해시만 저장, 평문 금지).
export function checkCredentials(id, password) {
  const envId = process.env.ADMIN_ID;
  const stored = process.env.ADMIN_PASSWORD_SCRYPT;
  if (!envId || !stored || !id || !password) return false;
  const parts = String(stored).split('$');
  if (parts.length !== 6 || parts[0] !== 'scrypt') return false;
  const [, nStr, rStr, pStr, saltHex, hashHex] = parts;
  let derived;
  try {
    derived = crypto.scryptSync(String(password), Buffer.from(saltHex, 'hex'), 32, {
      N: parseInt(nStr, 10),
      r: parseInt(rStr, 10),
      p: parseInt(pStr, 10),
    });
  } catch (_) {
    return false;
  }
  // id 비교도 상수시간 — 두 검증을 모두 수행한 뒤 합산한다.
  const idOk = safeEqual(id, envId);
  const pwOk = safeEqual(derived.toString('hex'), hashHex);
  return idOk && pwOk;
}

/// 로그인 성공 시 Set-Cookie 값 생성.
export function createSessionCookie() {
  const exp = Date.now() + SESSION_TTL_MS;
  const value = `${exp}.${hmac(String(exp))}`;
  return (
    `${SESSION_COOKIE}=${value}; HttpOnly; Secure; SameSite=Strict; ` +
    `Path=/api; Max-Age=${Math.floor(SESSION_TTL_MS / 1000)}`
  );
}

/// 로그아웃용 즉시 만료 쿠키.
export function clearSessionCookie() {
  return `${SESSION_COOKIE}=; HttpOnly; Secure; SameSite=Strict; Path=/api; Max-Age=0`;
}

function parseCookies(req) {
  const out = {};
  const raw = req.headers?.cookie;
  if (!raw) return out;
  for (const part of String(raw).split(';')) {
    const i = part.indexOf('=');
    if (i > 0) out[part.slice(0, i).trim()] = part.slice(i + 1).trim();
  }
  return out;
}

/// 세션 쿠키가 유효한가 (서명 일치 + 미만료).
export function verifySession(req) {
  if (!sessionSecret()) return false;
  const value = parseCookies(req)[SESSION_COOKIE];
  if (!value) return false;
  const dot = value.indexOf('.');
  if (dot <= 0) return false;
  const exp = value.slice(0, dot);
  const sig = value.slice(dot + 1);
  const expMs = parseInt(exp, 10);
  if (!Number.isFinite(expMs) || expMs < Date.now()) return false;
  return safeEqual(sig, hmac(exp));
}

/// 어드민 API 인증 — 세션 쿠키 또는 레거시 토큰(x-admin-token / ?token=).
/// 레거시 경로는 스크립트·문서(anr-summary 등) 하위호환용으로 유지한다.
export function isAuthed(req) {
  if (verifySession(req)) return true;
  const token = req.headers?.['x-admin-token'] || req.query?.token;
  return checkToken(token);
}
