// Server-side password checks for students/applicants and teachers.
//
// Replaces browser code that downloaded password hashes (and plain-text passwords) with the public key and compared them
// in the page. The pages now send the password (students: the same SHA-256 hash as before) here; the comparison happens with
// the service role and no secret is ever returned.
//
// Actions (no token; throttled per IP and per account):
//   student-verify          { applicationId, passwordHash }                      -> { ok, match, hasCredentials }
//   student-change-password { applicationId, currentPasswordHash, newPassword }  -> { ok } | { ok:false, code:'bad_password' }
//   teacher-verify          { teacherId, password }                              -> { ok, match }
//
// Secrets: PORTAL_AUTH_ORIGINS (optional, comma list; default = the site + local dev origins)
// Provided by Supabase: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

import { pbkdf2Hash, sameText, sha256Hex, verifyStoredPassword } from '../_shared/password.ts'

export type Env = (name: string) => string | undefined

export interface Deps {
  env: Env
  fetchFn: typeof fetch
  now?: () => number
  sleep?: (ms: number) => Promise<void>
}

type Row = Record<string, unknown>

const MAX_BODY_BYTES = 64 * 1024
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
const HASH_RE = /^[0-9a-f]{64}$/i
const DEFAULT_ORIGINS = ['https://www.acnhs.am', 'https://acnhs.am', 'http://localhost:8000', 'http://127.0.0.1:8000', 'null']
const failures = new Map<string, number[]>()

function allowedOrigins(env: Env): string[] {
  const configured = env('PORTAL_AUTH_ORIGINS')
  return configured ? configured.split(',').map((s) => s.trim()).filter(Boolean) : DEFAULT_ORIGINS
}

function corsHeaders(origin: string | null, env: Env): Record<string, string> {
  const ok = origin !== null && allowedOrigins(env).includes(origin)
  return {
    'Access-Control-Allow-Origin': ok ? origin! : 'null',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Vary': 'Origin',
  }
}

function reply(body: unknown, status: number, cors: Record<string, string>, extra: Record<string, string> = {}): Response {
  return new Response(JSON.stringify(body), { status, headers: { ...cors, 'Content-Type': 'application/json', 'Cache-Control': 'no-store', ...extra } })
}

function clientIp(req: Request): string {
  return (req.headers.get('x-forwarded-for') || req.headers.get('cf-connecting-ip') || 'unknown').split(',')[0].trim()
}

function throttled(key: string, limit: number, now: number): boolean {
  const recent = (failures.get(key) || []).filter((t) => now - t < 10 * 60_000)
  failures.set(key, recent)
  return recent.length >= limit
}

function noteFailure(key: string, now: number): void {
  failures.set(key, [...(failures.get(key) || []), now])
}

async function rest(deps: Deps, path: string, init: RequestInit = {}): Promise<{ ok: boolean; status: number; data: unknown }> {
  const url = deps.env('SUPABASE_URL')
  const key = deps.env('SUPABASE_SERVICE_ROLE_KEY')
  if (!url || !key) return { ok: false, status: 503, data: { message: 'Database access is not configured' } }
  const res = await deps.fetchFn(`${url}/rest/v1/${path}`, {
    ...init,
    headers: { apikey: key, Authorization: `Bearer ${key}`, 'Content-Type': 'application/json', Prefer: 'return=representation', ...(init.headers || {}) },
    signal: AbortSignal.timeout(15_000),
  })
  let data: unknown = null
  try { data = await res.json() } catch (_e) { /* empty body */ }
  return { ok: res.ok, status: res.status, data }
}

const str = (v: unknown): string => (typeof v === 'string' ? v : '')
const obj = (v: unknown): Row => (v && typeof v === 'object' && !Array.isArray(v) ? (v as Row) : {})

// The hash a student password is compared against: private table first, then (only until the columns are emptied) the
// same places login.html used to look in applications
async function storedStudentHash(deps: Deps, applicationId: string): Promise<{ hash: string; lookupFailed: boolean }> {
  const sec = await rest(deps, `application_secrets?select=password_hash&application_id=eq.${applicationId}&limit=1`)
  if (sec.ok && Array.isArray(sec.data) && sec.data.length && str(obj(sec.data[0]).password_hash)) {
    return { hash: str(obj(sec.data[0]).password_hash).toLowerCase(), lookupFailed: false }
  }
  const app = await rest(deps, `applications?select=password_hash,payload&id=eq.${applicationId}&limit=1`)
  if (!app.ok) return { hash: '', lookupFailed: true }
  const row = obj(Array.isArray(app.data) && app.data.length ? app.data[0] : {})
  const p = obj(row.payload)
  const portal = obj(p.studentPortal)
  const found =
    str(row.password_hash) || str(p.passwordHash) || str(p.password_hash) || str(portal.passwordHash) ||
    str(obj(portal.credentials).passwordHash) || str(obj(p.studentCredentials).passwordHash) ||
    str(obj(p.portalCredentials).passwordHash) || str(obj(p.credentials).passwordHash) || str(obj(p.applicationCredentials).passwordHash) ||
    str(obj(p.credentials).password_hash)
  return { hash: found.toLowerCase(), lookupFailed: false }
}

export async function handlePortalAuth(req: Request, deps: Deps): Promise<Response> {
  const { env } = deps
  const now = (deps.now || Date.now)()
  const sleep = deps.sleep || ((ms: number) => new Promise<void>((r) => setTimeout(r, ms)))
  const origin = req.headers.get('Origin')
  const cors = corsHeaders(origin, env)

  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })
  if (req.method !== 'POST') return reply({ ok: false, error: 'Method not allowed' }, 405, cors)
  if (origin !== null && !allowedOrigins(env).includes(origin)) return reply({ ok: false, code: 'forbidden_origin', error: 'Origin not allowed' }, 403, cors)
  if (Number(req.headers.get('content-length') || 0) > MAX_BODY_BYTES) return reply({ ok: false, code: 'too_large', error: 'Request too large' }, 413, cors)

  let body: Record<string, unknown>
  try { body = await req.json() } catch (_e) { return reply({ ok: false, code: 'bad_request', error: 'Invalid JSON body' }, 400, cors) }
  if (!body || typeof body !== 'object' || typeof body.action !== 'string') return reply({ ok: false, code: 'bad_request', error: 'action is required' }, 400, cors)

  const ip = clientIp(req)
  const keyIp = `ip:${ip}`
  const tooMany = () => reply({ ok: false, code: 'too_many_attempts', error: 'Too many sign-in attempts. Please wait a few minutes.' }, 429, cors, { 'Retry-After': '300' })

  switch (body.action) {
    case 'student-verify':
    case 'student-change-password': {
      const applicationId = str(body.applicationId)
      const given = str(body.action === 'student-verify' ? body.passwordHash : body.currentPasswordHash).trim().toLowerCase()
      if (!UUID_RE.test(applicationId) || !HASH_RE.test(given)) return reply({ ok: false, code: 'bad_request', error: 'applicationId and password hash are required' }, 400, cors)
      const keyId = `app:${applicationId}|${ip}`
      if (throttled(keyId, 8, now) || throttled(keyIp, 60, now)) return tooMany()

      const { hash, lookupFailed } = await storedStudentHash(deps, applicationId)
      if (lookupFailed) return reply({ ok: false, code: 'auth_unavailable', error: 'Authentication service unavailable. Please try again.' }, 503, cors)
      const match = HASH_RE.test(hash) && sameText(hash, given)
      if (!match && hash) { noteFailure(keyId, now); noteFailure(keyIp, now); await sleep(300) }

      if (body.action === 'student-verify') return reply({ ok: true, match, hasCredentials: !!hash }, 200, cors)

      if (!hash) return reply({ ok: false, code: 'no_credentials', error: 'This account has no password yet' }, 400, cors)
      if (!match) return reply({ ok: false, code: 'bad_password', error: 'Current password is incorrect' }, 401, cors)
      const newPassword = str(body.newPassword)
      if (newPassword.length < 8 || newPassword.length > 200) return reply({ ok: false, code: 'bad_request', error: 'New password must be 8-200 characters' }, 400, cors)
      const newHash = await sha256Hex(newPassword)

      const saved = await rest(deps, 'application_secrets?on_conflict=application_id', {
        method: 'POST',
        headers: { Prefer: 'resolution=merge-duplicates,return=minimal' },
        body: JSON.stringify([{ application_id: applicationId, password_hash: newHash, plain_password: newPassword, source: 'server', updated_at: new Date(now).toISOString() }]),
      })
      if (!saved.ok) return reply({ ok: false, code: 'db_error', error: 'Could not save the new password' }, 502, cors)

      // Keep the flags the portal shows (payload.credentials.*) without touching anything else in the payload
      const cur = await rest(deps, `applications?select=payload&id=eq.${applicationId}&limit=1`)
      if (cur.ok && Array.isArray(cur.data) && cur.data.length) {
        const payload = obj(obj(cur.data[0]).payload)
        const credentials = { ...obj(payload.credentials), default_password: false, must_change_password: false, password_last_changed: new Date(now).toISOString() }
        await rest(deps, `applications?id=eq.${applicationId}`, { method: 'PATCH', headers: { Prefer: 'return=minimal' }, body: JSON.stringify({ payload: { ...payload, credentials } }) })
      }
      return reply({ ok: true }, 200, cors)
    }

    case 'teacher-verify': {
      const teacherId = str(body.teacherId)
      const password = str(body.password)
      if (!UUID_RE.test(teacherId) || !password || password.length > 500) return reply({ ok: false, code: 'bad_request', error: 'teacherId and password are required' }, 400, cors)
      const keyId = `teacher:${teacherId}|${ip}`
      if (throttled(keyId, 8, now) || throttled(keyIp, 60, now)) return tooMany()
      const r = await rest(deps, `teachers?select=password_hash&id=eq.${teacherId}&active=eq.true&limit=1`)
      if (!r.ok) return reply({ ok: false, code: 'auth_unavailable', error: 'Authentication service unavailable. Please try again.' }, 503, cors)
      const stored = Array.isArray(r.data) && r.data.length ? str(obj(r.data[0]).password_hash) : ''
      const match = await verifyStoredPassword(password, stored)
      if (!match) { noteFailure(keyId, now); noteFailure(keyIp, now); await sleep(300) }
      // A password that was still stored as plain text is re-saved as a PBKDF2 hash the first time it is used
      if (match && !stored.startsWith('pbkdf2:')) {
        await rest(deps, `teachers?id=eq.${teacherId}`, { method: 'PATCH', headers: { Prefer: 'return=minimal' }, body: JSON.stringify({ password_hash: await pbkdf2Hash(password) }) })
      }
      return reply({ ok: true, match }, 200, cors)
    }

    default:
      return reply({ ok: false, code: 'bad_request', error: 'Unknown action' }, 400, cors)
  }
}
