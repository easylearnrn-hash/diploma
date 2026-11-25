// Cloud PDF rendering: receives the print HTML built by documents.html, has Browserless (cloud Chromium) print it
// exactly like the old local pdf-server.js did, and returns the PDF.
//
// Secrets (supabase secrets set ...), never present in frontend code:
//   BROWSERLESS_TOKEN            required   Browserless API token
//   BROWSERLESS_URL              optional   default https://production-ams.browserless.io (pick your region)
//   SITE_ORIGIN                  optional   default https://www.acnhs.am  (where /assets/fonts is served from)
//   ALLOWED_ORIGINS              optional   comma list; default = SITE_ORIGIN, https://acnhs.am and local dev origins
//   RENDER_RATE_PER_MINUTE       optional   per-admin limit, default 20
// Provided by Supabase automatically: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

export type Env = (name: string) => string | undefined

export interface Deps {
  env: Env
  fetchFn: typeof fetch
  now?: () => number
}

const MAX_HTML_BYTES = 8 * 1024 * 1024
const RENDER_TIMEOUT_MS = 110_000
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
const DEFAULT_LOCAL_ORIGINS = ['http://localhost:8000', 'http://127.0.0.1:8000', 'null']

// The Armenian page label «Էջ» is drawn as vector outlines of Noto Sans Armenian Regular (the footer is a separate mini-page where
// an embedded web font may not be loaded in time, so a font would silently fall back). 1000 units = 1 em; baseline at y = 0.
const HY_PAGE_LABEL_PATH = 'M164 -492H550V-416H164ZM409 0H96V-714H186V-76H419Q490 -76 527.5 -40.5Q565 -5 565 64V143H475V72Q475 35 458.5 17.5Q442 0 409 0ZM840 166H1108V236H781Q743 236 722.5 221Q702 206 702 174Q702 165 705 153.5Q708 142 717 127Q726 112 744 93L903 -79Q945 -124 972 -160.5Q999 -197 1012 -229Q1025 -261 1025 -294Q1025 -362 991 -395.5Q957 -429 897 -429Q838 -429 803.5 -394Q769 -359 769 -294Q769 -248 784 -221.5Q799 -195 837 -171Q861 -156 878 -140.5Q895 -125 906.5 -108.5Q918 -92 924 -73L874 -25Q868 -41 857 -57Q846 -73 826 -90.5Q806 -108 772 -127Q725 -155 702.5 -194.5Q680 -234 680 -295Q680 -357 705.5 -403.5Q731 -450 780 -476Q829 -502 897 -502Q1003 -502 1059.5 -448Q1116 -394 1116 -296Q1116 -253 1097 -211Q1078 -169 1041 -121.5Q1004 -74 949 -16L840 99Q825 115 819 125.5Q813 136 813 146Q813 156 818.5 161Q824 166 840 166Z'
const HY_PAGE_LABEL_WIDTH = 1146
const rateLog = new Map<string, number[]>()

function allowedOrigins(env: Env): string[] {
  const site = siteOrigin(env)
  const configured = env('ALLOWED_ORIGINS')
  if (configured) return configured.split(',').map((s) => s.trim()).filter(Boolean)
  return [site, 'https://acnhs.am', ...DEFAULT_LOCAL_ORIGINS]
}

function siteOrigin(env: Env): string {
  return (env('SITE_ORIGIN') || 'https://www.acnhs.am').replace(/\/+$/, '')
}

function corsHeaders(origin: string | null, env: Env): Record<string, string> {
  const ok = origin !== null && allowedOrigins(env).includes(origin)
  return {
    'Access-Control-Allow-Origin': ok ? origin! : 'null',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-admin-id',
    'Access-Control-Expose-Headers': 'content-disposition, x-render-ms',
    'Vary': 'Origin',
  }
}

function json(body: unknown, status: number, headers: Record<string, string>): Response {
  return new Response(JSON.stringify(body), { status, headers: { ...headers, 'Content-Type': 'application/json' } })
}

function escapeHtml(s: string): string {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')
}

export function buildFooterTemplate(opts: { refNo: string; pageNumbers: boolean; lang: string }): string {
  const hy = opts.lang === 'hy'
  // 9pt = 12 px: 1 unit = 0.012 px; the outline has a 292-unit descent below the baseline
  const pageLabel = hy
    ? `<svg role="img" aria-label="\u0537\u057B" xmlns="http://www.w3.org/2000/svg" viewBox="0 -1068 ${HY_PAGE_LABEL_WIDTH} 1360" width="${(HY_PAGE_LABEL_WIDTH * 0.012).toFixed(3)}" height="16.32" style="vertical-align:-3.504px;"><path fill="currentColor" d="${HY_PAGE_LABEL_PATH}"/></svg>`
    : 'Page'
  const of = hy ? '/' : 'of'
  const pager = opts.pageNumbers
    ? `
            &nbsp;&bull;&nbsp;
            ${pageLabel}&nbsp;<span class="pageNumber"></span>&nbsp;${of}&nbsp;<span class="totalPages"></span>`
    : ''
  return `
        <div style="
          font-size: 9pt;
          width: 100%;
          text-align: center;
          font-family: Arial, Helvetica, 'Noto Sans Armenian', sans-serif;
          color: rgba(10,15,30,0.52);
          padding: 0;
          margin: 0;
          position: relative;
          top: -8mm;
          box-sizing: border-box;
          line-height: 1.2;
          white-space: nowrap;
        ">
          <div style="
            margin: 1.5mm 12mm 0 12mm;
            padding: 6.47mm 0 0 0;
            border-top: 1px solid rgba(10,15,30,0.18);
          ">
            <strong style="color:rgba(10,15,30,0.62);">www.acnhs.am</strong>
            &nbsp;&bull;&nbsp;
            info@acnhs.am
            &nbsp;&bull;&nbsp;
            Ref:&nbsp;${escapeHtml(opts.refNo)}${pager}
          </div>
        </div>`
}

// The print HTML is generated by our own page and contains no scripts; anything else is not ours and is refused
export function validatePrintHtml(html: string): string | null {
  // Only real tags are inspected (document text is escaped by the page, so "one = 1" or "<script" in prose is harmless)
  if (/<\s*(script|iframe|object|embed|form|meta\s+http-equiv)\b/i.test(html)) return 'Unsupported markup in document'
  if (/<[a-z][^>]*\son[a-z]+\s*=/i.test(html)) return 'Unsupported markup in document'
  if (/<[a-z][^>]*\s(href|src|action|formaction)\s*=\s*["']?\s*javascript:/i.test(html)) return 'Unsupported markup in document'
  return null
}

// Fonts and the stylesheet are fetched from the public site, whatever origin the page was opened from (file://, localhost)
export function pointBaseAtSite(html: string, site: string): string {
  const tag = `<base href="${site}/">`
  return /<base\s[^>]*>/i.test(html) ? html.replace(/<base\s[^>]*>/i, tag) : html.replace(/<head[^>]*>/i, (m) => m + tag)
}

function rateLimited(key: string, limit: number, now: number): boolean {
  const recent = (rateLog.get(key) || []).filter((t) => now - t < 60_000)
  if (recent.length >= limit) { rateLog.set(key, recent); return true }
  recent.push(now)
  rateLog.set(key, recent)
  return false
}

async function isActiveAdmin(adminId: string, deps: Deps): Promise<boolean | null> {
  const url = deps.env('SUPABASE_URL')
  const key = deps.env('SUPABASE_SERVICE_ROLE_KEY')
  if (!url || !key) return null
  const res = await deps.fetchFn(
    `${url}/rest/v1/admin_users?select=id&id=eq.${encodeURIComponent(adminId)}&status=eq.active&limit=1`,
    { headers: { apikey: key, Authorization: `Bearer ${key}` } },
  )
  if (!res.ok) return null
  const rows = await res.json()
  return Array.isArray(rows) && rows.length === 1
}

export async function handleRender(req: Request, deps: Deps): Promise<Response> {
  const { env } = deps
  const now = (deps.now || Date.now)()
  const origin = req.headers.get('Origin')
  const cors = corsHeaders(origin, env)

  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors })
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405, cors)

  // Browsers always send Origin on cross-origin requests: other websites cannot use this endpoint
  if (origin !== null && !allowedOrigins(env).includes(origin)) return json({ error: 'Origin not allowed', code: 'forbidden_origin' }, 403, cors)

  const token = env('BROWSERLESS_TOKEN')
  if (!token) return json({ error: 'Cloud rendering is not configured', code: 'not_configured' }, 503, cors)

  const adminId = req.headers.get('x-admin-id') || ''
  if (!UUID_RE.test(adminId)) return json({ error: 'Admin session required', code: 'unauthorized' }, 401, cors)
  const admin = await isActiveAdmin(adminId, deps)
  if (admin === null) return json({ error: 'Could not verify the admin session', code: 'auth_unavailable' }, 503, cors)
  if (!admin) return json({ error: 'Admin session required', code: 'unauthorized' }, 401, cors)

  const limit = Number(env('RENDER_RATE_PER_MINUTE')) || 20
  if (rateLimited(adminId, limit, now)) {
    return new Response(JSON.stringify({ error: 'Too many render requests, try again in a moment', code: 'rate_limited' }), {
      status: 429, headers: { ...cors, 'Content-Type': 'application/json', 'Retry-After': '10' },
    })
  }

  const declared = Number(req.headers.get('content-length') || 0)
  if (declared > MAX_HTML_BYTES * 1.1) return json({ error: 'Document too large', code: 'too_large' }, 413, cors)

  let payload: { html?: unknown; refNo?: unknown; pageNumbers?: unknown; lang?: unknown }
  try { payload = await req.json() } catch (_e) { return json({ error: 'Invalid JSON body', code: 'bad_request' }, 400, cors) }
  if (typeof payload.html !== 'string' || !payload.html) return json({ error: 'html field is required', code: 'bad_request' }, 400, cors)
  if (payload.html.length > MAX_HTML_BYTES) return json({ error: 'Document too large', code: 'too_large' }, 413, cors)
  const bad = validatePrintHtml(payload.html)
  if (bad) return json({ error: bad, code: 'bad_request' }, 400, cors)

  const site = siteOrigin(env)
  const html = pointBaseAtSite(payload.html, site)
  const footerTemplate = buildFooterTemplate({
    refNo: typeof payload.refNo === 'string' ? payload.refNo.slice(0, 120) : '',
    pageNumbers: payload.pageNumbers !== false,
    lang: payload.lang === 'hy' ? 'hy' : 'en',
  })

  const base = (env('BROWSERLESS_URL') || 'https://production-ams.browserless.io').replace(/\/+$/, '')
  const siteHost = site.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  const body = {
    html,
    options: {
      format: 'A4',
      printBackground: true,
      preferCSSPageSize: false,
      displayHeaderFooter: true,
      margin: { top: '0', bottom: '22mm', left: '0', right: '0' },
      headerTemplate: '<div></div>',
      footerTemplate,
      waitForFonts: true,
    },
    // Same as the local server: wait for the network to go quiet and every web font to be ready before printing
    gotoOptions: { waitUntil: ['networkidle0'], timeout: 30_000 },
    waitForFunction: { fn: 'document.fonts.ready.then(() => true)', timeout: 20_000 },
    // The document only ever needs our own site (fonts, stylesheet) and inline data
    rejectRequestPattern: [`^(?!${siteHost}/|data:|about:|blob:).*`],
  }

  const started = now
  let upstream: Response
  try {
    upstream = await deps.fetchFn(`${base}/pdf?token=${encodeURIComponent(token)}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Cache-Control': 'no-cache' },
      body: JSON.stringify(body),
      signal: AbortSignal.any([req.signal, AbortSignal.timeout(RENDER_TIMEOUT_MS)]),
    })
  } catch (e) {
    const name = (e as Error).name
    if (name === 'TimeoutError') return json({ error: 'Rendering took too long', code: 'timeout' }, 504, cors)
    if (name === 'AbortError') return new Response(null, { status: 499, headers: cors })
    return json({ error: 'Rendering service unreachable', code: 'upstream_unreachable' }, 502, cors)
  }

  if (!upstream.ok) {
    // The upstream message is logged for the project owner; the token is never part of it
    const detail = (await upstream.text().catch(() => '')).slice(0, 300)
    console.error(`[render-pdf] Browserless ${upstream.status}: ${detail}`)
    // Browserless's own answer (never contains our token) so a wrong token / region is easy to tell apart
    const upstreamInfo = { status: upstream.status, host: new URL(base).host, detail: detail.replace(token, '***') }
    if (upstream.status === 401 || upstream.status === 403) return json({ error: 'Rendering service rejected the credentials', code: 'upstream_auth', upstream: upstreamInfo }, 502, cors)
    if (upstream.status === 429) return new Response(JSON.stringify({ error: 'Rendering service is busy', code: 'busy' }), { status: 503, headers: { ...cors, 'Content-Type': 'application/json', 'Retry-After': '5' } })
    if (upstream.status === 408 || upstream.status === 504) return json({ error: 'Rendering took too long', code: 'timeout' }, 504, cors)
    return json({ error: `Rendering failed (${upstream.status})`, code: 'upstream_error', upstream: upstreamInfo }, 502, cors)
  }

  const pdf = await upstream.arrayBuffer()
  const head = new Uint8Array(pdf.slice(0, 5))
  if (String.fromCharCode(...head) !== '%PDF-') {
    console.error('[render-pdf] Browserless returned a non-PDF body')
    return json({ error: 'Rendering returned an invalid file', code: 'upstream_error' }, 502, cors)
  }
  return new Response(pdf, {
    status: 200,
    headers: {
      ...cors,
      'Content-Type': 'application/pdf',
      'Content-Length': String(pdf.byteLength),
      'Cache-Control': 'no-store',
      'X-Render-Ms': String((deps.now || Date.now)() - started),
    },
  })
}
