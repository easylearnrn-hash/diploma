// Signed admin session tokens, shared by the admin-auth and render-pdf Edge Functions.
// Format: base64url(JSON claims) + "." + base64url(HMAC-SHA256(secret, first part)).
// The secret (ADMIN_TOKEN_SECRET) only exists as a Supabase secret; the browser can store a token but never forge one.

export interface AdminClaims {
  sub: string   // admin_users.id
  email: string
  role: string
  iat: number   // seconds
  exp: number   // seconds
}

const enc = new TextEncoder()

function toB64u(bytes: Uint8Array): string {
  let bin = ''
  for (let i = 0; i < bytes.length; i += 0x8000) bin += String.fromCharCode(...bytes.subarray(i, i + 0x8000))
  return btoa(bin).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')
}

function fromB64u(s: string): Uint8Array<ArrayBuffer> {
  const pad = '='.repeat((4 - (s.length % 4)) % 4)
  const bin = atob(s.replace(/-/g, '+').replace(/_/g, '/') + pad)
  const out = new Uint8Array(bin.length)
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i)
  return out
}

function hmacKey(secret: string, usage: KeyUsage[]): Promise<CryptoKey> {
  return crypto.subtle.importKey('raw', enc.encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, usage)
}

export async function signAdminToken(
  secret: string,
  admin: { id: string; email: string; role: string },
  ttlSeconds = 12 * 60 * 60,
  nowMs = Date.now(),
): Promise<string> {
  const iat = Math.floor(nowMs / 1000)
  const claims: AdminClaims = { sub: admin.id, email: admin.email, role: admin.role, iat, exp: iat + ttlSeconds }
  const body = toB64u(enc.encode(JSON.stringify(claims)))
  const sig = new Uint8Array(await crypto.subtle.sign('HMAC', await hmacKey(secret, ['sign']), enc.encode(body)))
  return `${body}.${toB64u(sig)}`
}

// Returns the claims of a genuine, unexpired token, otherwise null (never throws)
export async function verifyAdminToken(secret: string, token: string | null | undefined, nowMs = Date.now()): Promise<AdminClaims | null> {
  try {
    if (!secret || !token || token.length > 4096) return null
    const [body, sig, extra] = token.split('.')
    if (!body || !sig || extra !== undefined) return null
    const ok = await crypto.subtle.verify('HMAC', await hmacKey(secret, ['verify']), fromB64u(sig), enc.encode(body))
    if (!ok) return null
    const claims = JSON.parse(new TextDecoder().decode(fromB64u(body))) as AdminClaims
    if (!claims || typeof claims.sub !== 'string' || typeof claims.exp !== 'number') return null
    if (claims.exp * 1000 <= nowMs) return null
    return claims
  } catch (_e) {
    return null
  }
}
