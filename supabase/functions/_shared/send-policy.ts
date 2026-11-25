// Who may send e-mail through the send-email function, and as whom.
//
// Before this, send-email accepted any request from anyone on the internet and sent it from any @acnhs.am address. Now the caller must be:
//   admin    signed admin token (x-admin-token)              any sender and recipient, as before
//   teacher  signed portal token, role teacher               sender hub@acnhs.am only (class notices)
//   student  signed portal token, role student               sender must be the student's own campus address
//   viewer   signed portal token, role viewer (test admin)   sender must be an @acnhs.am address
//   public   nothing                                         only the website's own forms: fixed sender addresses, a fixed
//                                                            inbox, or the applicant who has just applied; small and rate-limited
// Portal tokens are signed with a key derived from ADMIN_TOKEN_SECRET, so a student token can never pass as an admin token.

import { signAdminToken, verifyAdminToken } from './admin-token.ts'

export type Env = (name: string) => string | undefined

export interface PolicyDeps {
  env: Env
  fetchFn: typeof fetch
  now?: () => number
}

export interface SendRequest {
  to: string
  from?: string
  subject: string
  html: string
  attachments?: unknown[]
  headers?: Record<string, string>
}

export type PolicyResult =
  | { ok: true; role: 'admin' | 'teacher' | 'student' | 'viewer' | 'public'; headers?: Record<string, string> }
  | { ok: false; status: number; error: string }

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
const SAFE_ADDRESS_RE = /^[A-Za-z0-9._+'-]{1,64}@[A-Za-z0-9.-]{1,190}\.[A-Za-z]{2,}$/
const PUBLIC_SENDERS = new Set(['admissions@acnhs.am', 'student-services@acnhs.am', 'documents@acnhs.am', 'do-not-reply@acnhs.am'])
const PUBLIC_INBOXES = new Set(['student-services@acnhs.am', 'acnhs.2026@gmail.com'])
const TEACHER_SENDER = 'hub@acnhs.am'
const HOUR = 60 * 60_000
const sends = new Map<string, number[]>()

export const portalSecret = (secret: string): string => `${secret}|portal-v1`

export function signPortalToken(secret: string, claims: { id: string; role: 'student' | 'teacher' | 'viewer'; email?: string }, ttlSeconds?: number, nowMs?: number): Promise<string> {
  return signAdminToken(portalSecret(secret), { id: claims.id, email: claims.email || '', role: claims.role }, ttlSeconds, nowMs)
}

export async function verifyPortalToken(secret: string, token: string | null, nowMs?: number): Promise<{ sub: string; role: string } | null> {
  const c = await verifyAdminToken(portalSecret(secret), token, nowMs)
  return c ? { sub: c.sub, role: c.role } : null
}

function overLimit(key: string, limit: number, now: number): boolean {
  const recent = (sends.get(key) || []).filter((t) => now - t < HOUR)
  if (recent.length >= limit) { sends.set(key, recent); return true }
  recent.push(now)
  sends.set(key, recent)
  return false
}

async function rest(deps: PolicyDeps, path: string): Promise<unknown[] | null> {
  const url = deps.env('SUPABASE_URL')
  const key = deps.env('SUPABASE_SERVICE_ROLE_KEY')
  if (!url || !key) return null
  const res = await deps.fetchFn(`${url}/rest/v1/${path}`, { headers: { apikey: key, Authorization: `Bearer ${key}` } })
  if (!res.ok) return null
  const data = await res.json()
  return Array.isArray(data) ? data : null
}

const lower = (v: unknown): string => (typeof v === 'string' ? v.trim().toLowerCase() : '')

// The addresses a student may send from: every campus/personal address recorded for their application and student record
export async function studentAddresses(deps: PolicyDeps, applicationId: string): Promise<Set<string> | null> {
  const [apps, studs] = await Promise.all([
    rest(deps, `applications?select=email,institutional_email,username,payload&id=eq.${applicationId}&limit=1`),
    rest(deps, `students?select=email,metadata&application_id=eq.${applicationId}&limit=5`),
  ])
  if (apps === null || studs === null) return null
  const out = new Set<string>()
  const add = (v: unknown) => { const a = lower(v); if (a.includes('@')) out.add(a) }
  const obj = (v: unknown): Record<string, unknown> => (v && typeof v === 'object' ? (v as Record<string, unknown>) : {})
  for (const a of apps as Record<string, unknown>[]) {
    add(a.email); add(a.institutional_email)
    const p = obj(a.payload)
    add(p.institutionalEmail); add(obj(p.studentPortal).institutionalEmail)
    const u = lower(a.username)
    if (u && !u.includes('@')) out.add(`${u}@acnhs.am`); else add(u)
  }
  for (const s of studs as Record<string, unknown>[]) {
    add(s.email)
    const m = obj(s.metadata)
    add(m.institutional_email); add(obj(m.portal).institutional_email)
  }
  return out
}

function cleanHeaders(h: unknown): Record<string, string> | undefined {
  if (!h || typeof h !== 'object') return undefined
  const out: Record<string, string> = {}
  for (const [k, v] of Object.entries(h as Record<string, unknown>)) {
    if (/^X-[A-Za-z0-9-]{1,40}$/i.test(k) && typeof v === 'string' && v.length <= 200 && !/[\r\n]/.test(v)) out[k] = v
  }
  return Object.keys(out).length ? out : undefined
}

export async function authorizeSend(
  input: { adminToken: string | null; portalToken: string | null; ip: string; body: SendRequest },
  deps: PolicyDeps,
): Promise<PolicyResult> {
  const now = (deps.now || Date.now)()
  const secret = deps.env('ADMIN_TOKEN_SECRET')
  if (!secret || secret.length < 32) return { ok: false, status: 503, error: 'E-mail authentication is not configured' }
  const { body, ip } = input
  const to = lower(body.to)
  const from = lower(body.from || 'admissions@acnhs.am')

  // 1) admin
  if (input.adminToken) {
    const c = await verifyAdminToken(secret, input.adminToken, now)
    if (c && UUID_RE.test(c.sub)) {
      const rows = await rest(deps, `admin_users?select=id&id=eq.${c.sub}&status=eq.active&limit=1`)
      if (rows === null) return { ok: false, status: 503, error: 'Could not verify the admin session' }
      if (rows.length === 1) {
        if (overLimit(`admin:${c.sub}`, 600, now)) return { ok: false, status: 429, error: 'Too many e-mails in the last hour' }
        return { ok: true, role: 'admin' }
      }
    }
    // a bad admin token is not a reason to refuse: fall through (the caller may still be a student/teacher/public form)
  }

  const tooBig = typeof body.html === 'string' && body.html.length > 450_000
  const hasAttachments = Array.isArray(body.attachments) && body.attachments.length > 0

  // 2) signed portal token
  if (input.portalToken) {
    const p = await verifyPortalToken(secret, input.portalToken, now)
    if (p && UUID_RE.test(p.sub)) {
      if (tooBig || hasAttachments) return { ok: false, status: 413, error: 'Message too large or attachments are not allowed for this account' }
      // A sender outside the person's own rights is not an error here: the request is then judged as a public form
      // (an applicant who is signed in and uses the "contact admissions" form is still a public-form request)
      if (p.role === 'teacher' && from === TEACHER_SENDER) {
        if (overLimit(`teacher:${p.sub}`, 400, now)) return { ok: false, status: 429, error: 'Too many e-mails in the last hour' }
        return { ok: true, role: 'teacher', headers: cleanHeaders(body.headers) }
      }
      if (p.role === 'student') {
        const mine = await studentAddresses(deps, p.sub)
        if (mine === null) return { ok: false, status: 503, error: 'Could not verify the sender' }
        if (mine.has(from)) {
          if (overLimit(`student:${p.sub}`, 30, now)) return { ok: false, status: 429, error: 'Too many e-mails in the last hour' }
          return { ok: true, role: 'student', headers: cleanHeaders(body.headers) }
        }
      }
      if (p.role === 'viewer' && from.endsWith('@acnhs.am')) {
        if (overLimit(`viewer:${p.sub}`, 30, now)) return { ok: false, status: 429, error: 'Too many e-mails in the last hour' }
        return { ok: true, role: 'viewer', headers: cleanHeaders(body.headers) }
      }
    }
  }

  // 3) the website's own public forms
  if (tooBig || hasAttachments) return { ok: false, status: 401, error: 'Sign in to send this message' }
  if (!PUBLIC_SENDERS.has(from)) return { ok: false, status: 401, error: 'Sign in to send e-mail from this address' }
  if (typeof body.subject !== 'string' || body.subject.length > 300) return { ok: false, status: 400, error: 'Invalid subject' }
  if (overLimit(`public-ip:${ip}`, 10, now) || overLimit('public-all', 300, now)) return { ok: false, status: 429, error: 'Too many requests. Please try again later.' }

  if (PUBLIC_INBOXES.has(to)) return { ok: true, role: 'public', headers: cleanHeaders(body.headers) }

  // the applicant who has just submitted an application (welcome e-mail)
  if (SAFE_ADDRESS_RE.test(to)) {
    const since = new Date(now - 3 * HOUR).toISOString()
    const rows = await rest(deps, `applications?select=id&email=eq.${encodeURIComponent(to)}&submission_date=gte.${encodeURIComponent(since)}&limit=1`)
    const exact = rows && rows.length ? rows : await rest(deps, `applications?select=id&email=ilike.${encodeURIComponent(to)}&submission_date=gte.${encodeURIComponent(since)}&limit=1`)
    if (exact === null) return { ok: false, status: 503, error: 'Could not verify the recipient' }
    if (exact.length && !overLimit(`public-to:${to}`, 3, now)) return { ok: true, role: 'public', headers: cleanHeaders(body.headers) }
    if (exact.length) return { ok: false, status: 429, error: 'Too many e-mails to this address' }
  }
  return { ok: false, status: 401, error: 'Sign in to send e-mail to this address' }
}
