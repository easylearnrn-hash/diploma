// Server-side admin authentication and admin-account management.
//
// Replaces browser code that downloaded admin_users (including password_hash) with the public key. Passwords are still
// the same SHA-256 hashes the pages already send, so every existing admin keeps their password; the comparison now
// happens here, with the service role, and password_hash is never returned to a browser.
//
// Secrets (supabase secrets set ...):
//   ADMIN_TOKEN_SECRET     required   random string used to sign admin session tokens
//   ADMIN_AUTH_ORIGINS     optional   comma list of allowed origins (default: the site + local dev origins)
// Provided by Supabase: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

import { signAdminToken, verifyAdminToken } from '../_shared/admin-token.ts'
import { checkPrehashed, hashSecret, sha256Hex } from '../_shared/password.ts'
import { signPortalToken } from '../_shared/send-policy.ts'

export type Env = (name: string) => string | undefined

export interface Deps {
  env: Env
  fetchFn: typeof fetch
  now?: () => number
  sleep?: (ms: number) => Promise<void>
}

const MAX_BODY_BYTES = 2 * 1024 * 1024
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
const HASH_RE = /^[0-9a-f]{64}$/i
const DEFAULT_ORIGINS = ['https://www.acnhs.am', 'https://acnhs.am', 'http://localhost:8000', 'http://127.0.0.1:8000', 'null']

// Exactly what the login pages used to read (without password_hash)
const PROFILE_COLS = 'id,name,email,username,role,permissions,email_permissions,signature,title,phone_ext,status'
// Everything admin-users.html used to read with select('*'), minus password_hash
const LIST_COLS = 'id,name,email,username,role,title,phone_ext,signature,status,permissions,email_permissions,forward_enabled,forward_to_email,created_at,updated_at,last_login'
const WRITABLE = ['name', 'username', 'role', 'title', 'phone_ext', 'email', 'signature', 'status', 'permissions', 'email_permissions', 'password_hash', 'forward_enabled', 'forward_to_email']

const failures = new Map<string, number[]>()   // login brute-force throttle, per instance

function allowedOrigins(env: Env): string[] {
  const configured = env('ADMIN_AUTH_ORIGINS')
  return configured ? configured.split(',').map((s) => s.trim()).filter(Boolean) : DEFAULT_ORIGINS
}

function corsHeaders(origin: string | null, env: Env): Record<string, string> {
  const ok = origin !== null && allowedOrigins(env).includes(origin)
  return {
    'Access-Control-Allow-Origin': ok ? origin! : 'null',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-admin-token',
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

function sameHash(a: string, b: string): boolean {
  if (a.length !== b.length) return false
  let diff = 0
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i)
  return diff === 0
}

type Row = Record<string, unknown>

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

function dbError(data: unknown, status: number, cors: Record<string, string>): Response {
  const d = (data || {}) as { message?: string; code?: string }
  return reply({ ok: false, code: 'db_error', error: d.message || 'Database error', dbCode: d.code || null }, d.code === '23505' ? 409 : status >= 500 ? 502 : 400, cors)
}

// Case-insensitive match on email or username, as the pages did (the identifier is never trusted inside a filter)
async function findAdminByIdentifier(deps: Deps, identifier: string): Promise<Row | null> {
  if (/[*%,()"\\]/.test(identifier)) return null
  const v = encodeURIComponent(identifier)
  const cols = `${PROFILE_COLS},password_hash`
  const [byEmail, byUser] = await Promise.all([
    rest(deps, `admin_users?select=${cols}&status=eq.active&email=ilike.${v}&limit=1`),
    rest(deps, `admin_users?select=${cols}&status=eq.active&username=ilike.${v}&limit=1`),
  ])
  if (!byEmail.ok && !byUser.ok) throw new Error('lookup failed')   // a database outage must not look like "account not found"
  for (const r of [byEmail, byUser]) {
    if (r.ok && Array.isArray(r.data) && r.data.length) return r.data[0] as Row
  }
  return null
}

function publicProfile(row: Row): Row {
  const { password_hash: _drop, ...rest } = row
  return rest
}

export async function handleAdminAuth(req: Request, deps: Deps): Promise<Response> {
  const { env } = deps
  const now = (deps.now || Date.now)()
  const sleep = deps.sleep || ((ms: number) => new Promise<void>((r) => setTimeout(r, ms)))
  const origin = req.headers.get('Origin')
  const cors = corsHeaders(origin, env)

  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })
  if (req.method !== 'POST') return reply({ ok: false, error: 'Method not allowed' }, 405, cors)
  if (origin !== null && !allowedOrigins(env).includes(origin)) return reply({ ok: false, code: 'forbidden_origin', error: 'Origin not allowed' }, 403, cors)

  const secret = env('ADMIN_TOKEN_SECRET')
  if (!secret || secret.length < 32) return reply({ ok: false, code: 'not_configured', error: 'Admin authentication is not configured' }, 503, cors)

  if (Number(req.headers.get('content-length') || 0) > MAX_BODY_BYTES) return reply({ ok: false, code: 'too_large', error: 'Request too large' }, 413, cors)
  let body: Record<string, unknown>
  try { body = await req.json() } catch (_e) { return reply({ ok: false, code: 'bad_request', error: 'Invalid JSON body' }, 400, cors) }
  if (!body || typeof body !== 'object' || typeof body.action !== 'string') return reply({ ok: false, code: 'bad_request', error: 'action is required' }, 400, cors)

  /* ───────────── student-viewer test account (no token): the credentials only exist as Supabase secrets ───────────── */
  if (body.action === 'viewer-login') {
    const email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : ''
    const passwordHash = typeof body.passwordHash === 'string' ? body.passwordHash.trim().toLowerCase() : ''
    if (!email || email.length > 254 || !HASH_RE.test(passwordHash)) return reply({ ok: false, code: 'bad_request', error: 'email and passwordHash are required' }, 400, cors)
    const ip = clientIp(req)
    if (throttled(`viewer:${ip}`, 8, now) || throttled(`ip:${ip}`, 40, now)) {
      return reply({ ok: false, code: 'too_many_attempts', error: 'Too many sign-in attempts. Please wait a few minutes.' }, 429, cors, { 'Retry-After': '300' })
    }
    const viewerEmail = (env('STUDENT_VIEWER_EMAIL') || '').trim().toLowerCase()
    const viewerHash = (env('STUDENT_VIEWER_PASSWORD_HASH') || '').trim().toLowerCase()
    const match = !!viewerEmail && HASH_RE.test(viewerHash) && email === viewerEmail && sameHash(viewerHash, passwordHash)
    if (!match) { noteFailure(`viewer:${ip}`, now); noteFailure(`ip:${ip}`, now); await sleep(400) }
    const viewerToken = match ? await signPortalToken(secret, { id: '00000000-0000-4000-8000-000000000001', role: 'viewer', email: viewerEmail }) : undefined
    return reply({ ok: true, match, ...(viewerToken ? { token: viewerToken } : {}) }, 200, cors)
  }

  /* ───────────── login (no token yet) ───────────── */
  if (body.action === 'login') {
    const identifier = typeof body.identifier === 'string' ? body.identifier.trim() : ''
    const passwordHash = typeof body.passwordHash === 'string' ? body.passwordHash.trim().toLowerCase() : ''
    if (!identifier || identifier.length > 254 || !HASH_RE.test(passwordHash)) return reply({ ok: false, code: 'bad_request', error: 'identifier and passwordHash are required' }, 400, cors)

    const ip = clientIp(req)
    const keyId = `id:${ip}|${identifier.toLowerCase()}`
    const keyIp = `ip:${ip}`
    if (throttled(keyId, 8, now) || throttled(keyIp, 40, now)) {
      return reply({ ok: false, code: 'too_many_attempts', error: 'Too many sign-in attempts. Please wait a few minutes.' }, 429, cors, { 'Retry-After': '300' })
    }

    let admin: Row | null
    try { admin = await findAdminByIdentifier(deps, identifier) } catch (_e) {
      return reply({ ok: false, code: 'auth_unavailable', error: 'Authentication service unavailable. Please try again.' }, 503, cors)
    }
    if (!admin) {
      noteFailure(keyId, now); noteFailure(keyIp, now)
      await sleep(400)
      return reply({ ok: false, code: 'not_found', error: 'Account not found or inactive' }, 401, cors)
    }
    const check = await checkPrehashed(passwordHash, String(admin.password_hash || ''))
    if (!check.match) {
      noteFailure(keyId, now); noteFailure(keyIp, now)
      await sleep(400)
      return reply({ ok: false, code: 'bad_password', error: 'Incorrect password' }, 401, cors)
    }
    // An old bare SHA-256 is replaced by a salted, slow hash now that the password is known to be right (a failure here must not block the login)
    if (check.legacy) {
      try { await rest(deps, `admin_users?id=eq.${encodeURIComponent(String(admin.id))}`, { method: 'PATCH', headers: { Prefer: 'return=minimal' }, body: JSON.stringify({ password_hash: await hashSecret(passwordHash) }) }) } catch (_e) { /* converted next time */ }
    }
    const token = await signAdminToken(secret, { id: String(admin.id), email: String(admin.email || ''), role: String(admin.role || '') }, undefined, now)
    return reply({ ok: true, user: publicProfile(admin), token }, 200, cors)
  }

  /* ───────────── everything else needs a valid token of an active admin ───────────── */
  const claims = await verifyAdminToken(secret, req.headers.get('x-admin-token'), now)
  if (!claims || !UUID_RE.test(claims.sub)) return reply({ ok: false, code: 'unauthorized', error: 'Please sign in again' }, 401, cors)
  const meRes = await rest(deps, `admin_users?select=${PROFILE_COLS}&id=eq.${encodeURIComponent(claims.sub)}&status=eq.active&limit=1`)
  if (!meRes.ok) return reply({ ok: false, code: 'auth_unavailable', error: 'Could not verify the admin session' }, 503, cors)
  if (!Array.isArray(meRes.data) || !meRes.data.length) return reply({ ok: false, code: 'unauthorized', error: 'Please sign in again' }, 401, cors)
  const me = meRes.data[0] as Row

  switch (body.action) {
    case 'me':
      return reply({ ok: true, user: me }, 200, cors)

    case 'directory': {
      const r = await rest(deps, 'admin_users?select=email,name,role&order=name.asc.nullslast')
      return r.ok ? reply({ ok: true, users: r.data }, 200, cors) : dbError(r.data, r.status, cors)
    }

    case 'set-email-permissions': {
      const emails = body.emails
      if (!Array.isArray(emails) || emails.length > 500 || !emails.every((e) => typeof e === 'string' && e.length > 0 && e.length <= 254)) {
        return reply({ ok: false, code: 'bad_request', error: 'emails must be a list of addresses' }, 400, cors)
      }
      const r = await rest(deps, `admin_users?id=eq.${encodeURIComponent(String(me.id))}`, { method: 'PATCH', body: JSON.stringify({ email_permissions: emails }) })
      return r.ok ? reply({ ok: true }, 200, cors) : dbError(r.data, r.status, cors)
    }

    case 'users-list': {
      const r = await rest(deps, `admin_users?select=${LIST_COLS}&order=created_at.desc`)
      return r.ok ? reply({ ok: true, users: r.data }, 200, cors) : dbError(r.data, r.status, cors)
    }

    case 'users-get': {
      const id = String(body.id || '')
      if (!UUID_RE.test(id)) return reply({ ok: false, code: 'bad_request', error: 'Invalid id' }, 400, cors)
      const r = await rest(deps, `admin_users?select=${LIST_COLS}&id=eq.${encodeURIComponent(id)}&limit=1`)
      if (!r.ok) return dbError(r.data, r.status, cors)
      return Array.isArray(r.data) && r.data.length ? reply({ ok: true, user: r.data[0] }, 200, cors) : reply({ ok: false, code: 'not_found', error: 'User not found' }, 404, cors)
    }

    case 'users-create':
    case 'users-update': {
      const src = (body.user && typeof body.user === 'object' ? body.user : {}) as Row
      const data: Row = {}
      for (const k of WRITABLE) if (k in src) data[k] = src[k]
      if ('password_hash' in data && !(typeof data.password_hash === 'string' && HASH_RE.test(data.password_hash))) {
        return reply({ ok: false, code: 'bad_request', error: 'password_hash must be a SHA-256 hex digest' }, 400, cors)
      }
      // stored salted and slow, never as the bare SHA-256 the page sent
      if (typeof data.password_hash === 'string') data.password_hash = await hashSecret(data.password_hash.toLowerCase())
      if (body.action === 'users-create') {
        const r = await rest(deps, 'admin_users', { method: 'POST', body: JSON.stringify([data]) })
        return r.ok ? reply({ ok: true, user: Array.isArray(r.data) ? publicProfile((r.data as Row[])[0] || {}) : null }, 200, cors) : dbError(r.data, r.status, cors)
      }
      const id = String(body.id || '')
      if (!UUID_RE.test(id)) return reply({ ok: false, code: 'bad_request', error: 'Invalid id' }, 400, cors)
      if (!Object.keys(data).length) return reply({ ok: false, code: 'bad_request', error: 'Nothing to update' }, 400, cors)
      const r = await rest(deps, `admin_users?id=eq.${encodeURIComponent(id)}`, { method: 'PATCH', body: JSON.stringify(data) })
      if (!r.ok) return dbError(r.data, r.status, cors)
      return Array.isArray(r.data) && r.data.length ? reply({ ok: true, user: publicProfile(r.data[0] as Row) }, 200, cors) : reply({ ok: false, code: 'not_found', error: 'User not found' }, 404, cors)
    }

    case 'users-delete': {
      const id = String(body.id || '')
      if (!UUID_RE.test(id)) return reply({ ok: false, code: 'bad_request', error: 'Invalid id' }, 400, cors)
      const r = await rest(deps, `admin_users?id=eq.${encodeURIComponent(id)}`, { method: 'DELETE' })
      if (!r.ok) return dbError(r.data, r.status, cors)
      return Array.isArray(r.data) && r.data.length ? reply({ ok: true }, 200, cors) : reply({ ok: false, code: 'not_found', error: 'User not found' }, 404, cors)
    }

    /* ───────────── student credentials (private table application_secrets; never readable with the public key) ───────────── */
    case 'student-credentials-get': {
      const id = String(body.applicationId || '')
      if (!UUID_RE.test(id)) return reply({ ok: false, code: 'bad_request', error: 'Invalid applicationId' }, 400, cors)
      const r = await rest(deps, `application_secrets?select=plain_password,latest_password,password_hash&application_id=eq.${encodeURIComponent(id)}&limit=1`)
      if (!r.ok) return dbError(r.data, r.status, cors)
      const row = (Array.isArray(r.data) && r.data.length ? r.data[0] : {}) as Row
      return reply({ ok: true, password: row.plain_password || null, latestPassword: row.latest_password || null, hasPassword: !!row.password_hash }, 200, cors)
    }

    case 'student-credentials-set': {
      const id = String(body.applicationId || '')
      const password = typeof body.password === 'string' ? body.password : ''
      if (!UUID_RE.test(id) || password.length < 1 || password.length > 200) return reply({ ok: false, code: 'bad_request', error: 'applicationId and password are required' }, 400, cors)
      const exists = await rest(deps, `applications?select=id&id=eq.${encodeURIComponent(id)}&limit=1`)
      if (!exists.ok) return dbError(exists.data, exists.status, cors)
      if (!Array.isArray(exists.data) || !exists.data.length) return reply({ ok: false, code: 'not_found', error: 'Application not found' }, 404, cors)
      // mustChange: the student has to create their own password at the next sign-in (default or admin-set passwords)
      const record: Row = { application_id: id, password_hash: await hashSecret(await sha256Hex(password)), plain_password: password, must_change: body.mustChange === true, source: 'server', updated_at: new Date(now).toISOString() }
      if (body.latest === true) record.latest_password = password
      const r = await rest(deps, 'application_secrets?on_conflict=application_id', { method: 'POST', headers: { Prefer: 'resolution=merge-duplicates,return=minimal' }, body: JSON.stringify([record]) })
      return r.ok ? reply({ ok: true }, 200, cors) : dbError(r.data, r.status, cors)
    }

    // One-off/idempotent clean-up: passwords the server can verify against the plain text it keeps (students with a saved plain password,
    // teachers still stored as plain text) are converted to salted, slow hashes. Does `limit` accounts per call (default 8), call again until remaining is 0.
    case 'rehash-passwords': {
      const limit = Math.min(Math.max(Number(body.limit) || 8, 1), 15)
      let done = 0
      let remaining = 0
      const students = await rest(deps, 'application_secrets?select=application_id,password_hash,plain_password&plain_password=not.is.null&limit=500')
      if (!students.ok) return dbError(students.data, students.status, cors)
      for (const row of students.data as Row[]) {
        const stored = String(row.password_hash || '')
        const plain = String(row.plain_password || '')
        if (!/^[0-9a-f]{64}$/i.test(stored) || stored.toLowerCase() !== (await sha256Hex(plain))) continue
        if (done >= limit) { remaining++; continue }
        const w = await rest(deps, `application_secrets?application_id=eq.${encodeURIComponent(String(row.application_id))}`, { method: 'PATCH', headers: { Prefer: 'return=minimal' }, body: JSON.stringify({ password_hash: await hashSecret(stored.toLowerCase()) }) })
        if (w.ok) done++
      }
      const teachers = await rest(deps, 'teachers?select=id,password_hash&limit=200')
      if (!teachers.ok) return dbError(teachers.data, teachers.status, cors)
      for (const t of teachers.data as Row[]) {
        const stored = String(t.password_hash || '')
        if (!stored || stored.startsWith('p2:') || stored.startsWith('pbkdf2:')) continue
        if (done >= limit) { remaining++; continue }
        const w = await rest(deps, `teachers?id=eq.${encodeURIComponent(String(t.id))}`, { method: 'PATCH', headers: { Prefer: 'return=minimal' }, body: JSON.stringify({ password_hash: await hashSecret(stored) }) })
        if (w.ok) done++
      }
      return reply({ ok: true, converted: done, remaining }, 200, cors)
    }

    case 'teacher-set-password': {
      const id = String(body.teacherId || '')
      const password = typeof body.password === 'string' ? body.password : ''
      if (!UUID_RE.test(id) || password.length < 1 || password.length > 200) return reply({ ok: false, code: 'bad_request', error: 'teacherId and password are required' }, 400, cors)
      const r = await rest(deps, `teachers?id=eq.${encodeURIComponent(id)}`, { method: 'PATCH', body: JSON.stringify({ password_hash: await hashSecret(password) }) })
      if (!r.ok) return dbError(r.data, r.status, cors)
      return Array.isArray(r.data) && r.data.length ? reply({ ok: true }, 200, cors) : reply({ ok: false, code: 'not_found', error: 'Teacher not found' }, 404, cors)
    }

    default:
      return reply({ ok: false, code: 'bad_request', error: 'Unknown action' }, 400, cors)
  }
}
