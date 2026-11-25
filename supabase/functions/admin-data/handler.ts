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
  'monthly_expenses',
  'portal_alert_templates',
  'user_tasks',
])

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
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-admin-token, prefer, range, range-unit, accept, accept-profile, content-profile, x-owner-id, x-owner-role',
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
  if (!ADMIN_TABLES.has(table) || tail.split('/').filter(Boolean).length !== 1) return fail(403, 'table_not_available', 'This table is not available through the admin gateway', cors)

  const secret = env('ADMIN_TOKEN_SECRET')
  if (!secret || secret.length < 32) return fail(503, 'not_configured', 'Admin authentication is not configured', cors)
  const claims = await verifyAdminToken(secret, req.headers.get('x-admin-token'), now)
  if (!claims || !UUID_RE.test(claims.sub)) return fail(401, 'unauthorized', 'Admin session required', cors)
  const active = await isActiveAdmin(claims.sub, deps, now)
  if (active === null) return fail(503, 'auth_unavailable', 'Could not verify the admin session', cors)
  if (!active) return fail(401, 'unauthorized', 'Admin session required', cors)

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
