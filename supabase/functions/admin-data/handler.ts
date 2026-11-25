// Admin data gateway: lets the admin pages keep using the normal Supabase client for tables that the public key can no
// longer touch.
//
// js/supabase-config.js sends the page's REST requests for the tables below to
//     <project>/functions/v1/admin-data/<table>?<same query as before>
// together with the signed admin token (x-admin-token, issued by admin-auth). This function checks the token (and that the
// admin still exists and is active), then replays the identical request against PostgREST with the service role.
// Only the tables in ADMIN_TABLES can be reached this way; admin_users, application_secrets and the like never can.
//
// Secrets: ADMIN_TOKEN_SECRET (shared with admin-auth), ADMIN_AUTH_ORIGINS (allowed origins; same as admin-auth).
// Provided by Supabase: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

import { verifyAdminToken } from '../_shared/admin-token.ts'
import { studentAddresses, verifyPortalToken } from '../_shared/send-policy.ts'

export type Env = (name: string) => string | undefined

export interface Deps {
  env: Env
  fetchFn: typeof fetch
  now?: () => number
}

// Keep in sync with PROXIED_TABLES in js/supabase-config.js
export const ADMIN_TABLES = new Set([
  'documents',
  'email_configuration',
  'email_folder_rules',
  'email_folders',
  'email_forwarding_rules',
  'email_spam_blocked',
  'invoice_drafts',
  'invoice_templates',
  'export_sessions',
  'export_session_notes',
  'monthly_expenses',
  'portal_alert_templates',
  'user_tasks',
])

// Tables that signed-in students (and the test viewer) may also use, under the rules in portalAllows()
export const PORTAL_TABLES = new Set(['email_history'])
// Tables whose reads (GET/HEAD) go through the gateway for admins only; the browser still inserts into them directly
export const ADMIN_READ_TABLES = new Set(['user_activity_log'])

const MAX_BODY_BYTES = 25 * 1024 * 1024
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
const DEFAULT_ORIGINS = ['https://www.acnhs.am', 'https://acnhs.am', 'http://localhost:8000', 'http://127.0.0.1:8000', 'null']
const METHODS = new Set(['GET', 'HEAD', 'POST', 'PATCH', 'PUT', 'DELETE'])
// Request headers PostgREST understands that the browser may set (everything else, including auth, is dropped)
const FORWARD_REQUEST_HEADERS = ['accept', 'content-type', 'prefer', 'range', 'range-unit', 'accept-profile', 'content-profile']
const FORWARD_RESPONSE_HEADERS = ['content-type', 'content-range', 'content-location', 'preference-applied', 'range-unit']
const activeCache = new Map<string, number>()   // admin id -> time it was last confirmed active
const ACTIVE_CACHE_MS = 30_000

function allowedOrigins(env: Env): string[] {
  const configured = env('ADMIN_AUTH_ORIGINS')
  return configured ? configured.split(',').map((s) => s.trim()).filter(Boolean) : DEFAULT_ORIGINS
}

function corsHeaders(origin: string | null, env: Env): Record<string, string> {
  const ok = origin !== null && allowedOrigins(env).includes(origin)
  return {
    'Access-Control-Allow-Origin': ok ? origin! : 'null',
    'Access-Control-Allow-Methods': 'GET, HEAD, POST, PATCH, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-admin-token, x-portal-token, prefer, range, range-unit, accept, accept-profile, content-profile, x-owner-id, x-owner-role',
    'Access-Control-Expose-Headers': 'content-range, content-location, preference-applied, range-unit',
    'Vary': 'Origin',
  }
}

function fail(status: number, code: string, message: string, cors: Record<string, string>): Response {
  return new Response(JSON.stringify({ code, message, details: null, hint: null }), { status, headers: { ...cors, 'Content-Type': 'application/json', 'Cache-Control': 'no-store' } })
}

async function isActiveAdmin(adminId: string, deps: Deps, now: number): Promise<boolean | null> {
  const seen = activeCache.get(adminId)
  if (seen !== undefined && now - seen < ACTIVE_CACHE_MS) return true
  const url = deps.env('SUPABASE_URL')
  const key = deps.env('SUPABASE_SERVICE_ROLE_KEY')
  if (!url || !key) return null
  const res = await deps.fetchFn(`${url}/rest/v1/admin_users?select=id&id=eq.${encodeURIComponent(adminId)}&status=eq.active&limit=1`, { headers: { apikey: key, Authorization: `Bearer ${key}` } })
  if (!res.ok) return null
  const rows = await res.json()
  const ok = Array.isArray(rows) && rows.length === 1
  if (ok) activeCache.set(adminId, now)
  else activeCache.delete(adminId)
  return ok
}

const ownCache = new Map<string, { at: number; set: Set<string> }>()
const OWN_CACHE_MS = 60_000

async function ownAddresses(deps: Deps, applicationId: string, now: number): Promise<Set<string> | null> {
  const hit = ownCache.get(applicationId)
  if (hit && now - hit.at < OWN_CACHE_MS) return hit.set
  const set = await studentAddresses(deps, applicationId)
  if (set) ownCache.set(applicationId, { at: now, set })
  return set
}

async function db(deps: Deps, path: string): Promise<Record<string, unknown>[] | null> {
  const url = deps.env('SUPABASE_URL')
  const key = deps.env('SUPABASE_SERVICE_ROLE_KEY')
  if (!url || !key) return null
  const res = await deps.fetchFn(`${url}/rest/v1/${path}`, { headers: { apikey: key, Authorization: `Bearer ${key}` } })
  if (!res.ok) return null
  const data = await res.json()
  return Array.isArray(data) ? data : null
}

// A campus address of an enrolled student (what the test viewer may look at)
async function isStudentAddress(deps: Deps, address: string): Promise<boolean | null> {
  if (!/^[A-Za-z0-9._+'-]{1,64}@acnhs\.am$/i.test(address)) return false
  const local = address.slice(0, address.indexOf('@')).toLowerCase()
  const rows = await db(deps, `applications?select=id&or=(institutional_email.ilike.${encodeURIComponent(address)},username.ilike.${encodeURIComponent(local)},username.ilike.${encodeURIComponent(address)})&limit=1`)
  return rows === null ? null : rows.length > 0
}

const lc = (v: string): string => v.trim().toLowerCase()

// Rules for what a student (own mail only) or the test viewer (read-only, a student's mail) may do with PORTAL_TABLES.
// Returns true to allow, a message to refuse, or null when the database could not be asked.
async function portalAllows(table: string, role: 'student' | 'viewer', subject: string, method: string, params: URLSearchParams, deps: Deps, now: number): Promise<true | string | null> {
  if (table !== 'email_history') return 'Not allowed'
  const read = method === 'GET' || method === 'HEAD'
  if (!read && !(method === 'DELETE' && role === 'student')) return 'Not allowed'

  const own = role === 'student' ? await ownAddresses(deps, subject, now) : null
  if (role === 'student' && own === null) return null
  // may this address be looked at?
  const addrOk = async (a: string): Promise<boolean | null> => (role === 'student' ? own!.has(lc(a)) : await isStudentAddress(deps, lc(a)))

  // 1) the request itself pins the rows to an allowed address: sender=eq.A, recipient=eq.A or or=(sender.eq.A,recipient.eq.A)
  let pinned = false
  for (const col of ['sender', 'recipient']) {
    for (const v of params.getAll(col)) {
      if (v.startsWith('eq.')) { const r = await addrOk(v.slice(3)); if (r === null) return null; if (r) pinned = true }
    }
  }
  for (const v of params.getAll('or')) {
    const conds = v.replace(/^\(|\)$/g, '').split(',')
    let all = conds.length > 0
    for (const c of conds) {
      const m = /^(sender|recipient)\.eq\.(.+)$/.exec(c)
      if (!m) { all = false; break }
      const r = await addrOk(m[2]); if (r === null) return null
      if (!r) { all = false; break }
    }
    if (all) pinned = true
  }
  if (pinned) return true

  // 2) rows picked by id (open one message / delete messages): each must belong to an allowed address
  const ids: string[] = []
  for (const v of params.getAll('id')) {
    if (v.startsWith('eq.')) ids.push(v.slice(3))
    else if (v.startsWith('in.(') && v.endsWith(')')) ids.push(...v.slice(4, -1).split(',').map((x) => x.replace(/"/g, '').trim()))
    else return 'Not allowed'
  }
  if (!ids.length || ids.length > 200 || !ids.every((i) => UUID_RE.test(i))) return 'Not allowed'
  const rows = await db(deps, `email_history?select=id,sender,recipient&id=in.(${ids.join(',')})`)
  if (rows === null) return null
  for (const row of rows) {
    const a = await addrOk(String(row.sender || ''))
    const b = await addrOk(String(row.recipient || ''))
    if (a === null || b === null) return null
    if (!a && !b) return 'Not allowed'
  }
  return true
}

export async function handleAdminData(req: Request, deps: Deps): Promise<Response> {
  const { env } = deps
  const now = (deps.now || Date.now)()
  const origin = req.headers.get('Origin')
  const cors = corsHeaders(origin, env)

  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })
  if (!METHODS.has(req.method)) return fail(405, 'method_not_allowed', 'Method not allowed', cors)
  if (origin !== null && !allowedOrigins(env).includes(origin)) return fail(403, 'forbidden_origin', 'Origin not allowed', cors)

  // Path after the function name: /admin-data/<table>  (Supabase may or may not include the /functions/v1 prefix)
  const u = new URL(req.url)
  const marker = '/admin-data/'
  const at = u.pathname.indexOf(marker)
  const tail = at >= 0 ? u.pathname.slice(at + marker.length) : ''
  const table = decodeURIComponent(tail.split('/')[0] || '')
  const readOnly = req.method === 'GET' || req.method === 'HEAD'
  const known = ADMIN_TABLES.has(table) || PORTAL_TABLES.has(table) || (ADMIN_READ_TABLES.has(table) && readOnly)
  if (!known || tail.split('/').filter(Boolean).length !== 1) return fail(403, 'table_not_available', 'This table is not available through the admin gateway', cors)

  const secret = env('ADMIN_TOKEN_SECRET')
  if (!secret || secret.length < 32) return fail(503, 'not_configured', 'Admin authentication is not configured', cors)

  // Who is asking: an active admin, or (for PORTAL_TABLES only) a signed-in student / the test viewer
  let role: 'admin' | 'student' | 'viewer' | null = null
  let subject = ''
  const adminToken = req.headers.get('x-admin-token')
  if (adminToken) {
    const claims = await verifyAdminToken(secret, adminToken, now)
    if (claims && UUID_RE.test(claims.sub)) {
      const active = await isActiveAdmin(claims.sub, deps, now)
      if (active === null) return fail(503, 'auth_unavailable', 'Could not verify the admin session', cors)
      if (active) { role = 'admin'; subject = claims.sub }
    }
  }
  if (!role && PORTAL_TABLES.has(table)) {
    const p = await verifyPortalToken(secret, req.headers.get('x-portal-token'), now)
    if (p && UUID_RE.test(p.sub) && (p.role === 'student' || p.role === 'viewer')) { role = p.role; subject = p.sub }
  }
  if (!role) return fail(401, 'unauthorized', 'Session required', cors)
  if (role !== 'admin') {
    const verdict = await portalAllows(table, role, subject, req.method, u.searchParams, deps, now)
    if (verdict === null) return fail(503, 'auth_unavailable', 'Could not verify access', cors)
    if (verdict !== true) return fail(403, 'forbidden', verdict, cors)
  }

  const declared = Number(req.headers.get('content-length') || 0)
  if (declared > MAX_BODY_BYTES) return fail(413, 'too_large', 'Request too large', cors)
  const body = req.method === 'GET' || req.method === 'HEAD' ? undefined : await req.arrayBuffer()
  if (body && body.byteLength > MAX_BODY_BYTES) return fail(413, 'too_large', 'Request too large', cors)

  const url = env('SUPABASE_URL')
  const key = env('SUPABASE_SERVICE_ROLE_KEY')
  if (!url || !key) return fail(503, 'not_configured', 'Database access is not configured', cors)

  const headers: Record<string, string> = { apikey: key, Authorization: `Bearer ${key}` }
  for (const h of FORWARD_REQUEST_HEADERS) {
    const v = req.headers.get(h)
    if (v) headers[h] = v
  }

  let upstream: Response
  try {
    upstream = await deps.fetchFn(`${url}/rest/v1/${encodeURIComponent(table)}${u.search}`, { method: req.method, headers, body: body && body.byteLength ? body : undefined })
  } catch (_e) {
    return fail(502, 'upstream_unreachable', 'Could not reach the database', cors)
  }

  const out: Record<string, string> = { ...cors, 'Cache-Control': 'no-store' }
  for (const h of FORWARD_RESPONSE_HEADERS) {
    const v = upstream.headers.get(h)
    if (v) out[h] = v
  }
  return new Response(req.method === 'HEAD' ? null : upstream.body, { status: upstream.status, headers: out })
}
