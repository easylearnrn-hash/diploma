// Supabase Configuration for ACNHS Transcript System
// This file contains the public configuration for client-side Supabase access

const SUPABASE_CONFIG = {
  // Your Supabase project URL
  url: 'https://eyhksbiceueoiamwnqpr.supabase.co',
  
  // Your Supabase anonymous (public) key - safe for client-side use
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV5aGtzYmljZXVlb2lhbXducXByIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4NTIwOTAsImV4cCI6MjA4NDQyODA5MH0.1G3RZLKLJvIR8U9Cvmner3kUIxDtUfFYkHpzUUbnbq8',
  
  // Optional: Additional configuration
  options: {
    auth: {
      persistSession: true,
      autoRefreshToken: true,
      detectSessionInUrl: false,
      storage: typeof window !== 'undefined' ? window.localStorage : undefined,
      storageKey: 'acnhs-admin-auth',
      // Prevent Navigator LockManager timeout when multiple admin tabs are open.
      // Instead of blocking for 10s waiting to acquire an exclusive lock, we
      // use a non-exclusive relaxed lock that resolves immediately.
      lock: typeof navigator !== 'undefined' && navigator.locks
        ? async (name, acquireTimeout, fn) => {
            return navigator.locks.request(
              name,
              { mode: 'exclusive', ifAvailable: true },
              async (lock) => {
                // If lock isn't available (another tab holds it), run anyway
                return fn(lock);
              }
            );
          }
        : undefined
    }
  }
};

// Tables the public key can no longer read or write. Admin pages reach them through the admin-data Edge Function, which checks
// the signed admin session (adminToken) and replays the same request with the service role. Keep in sync with ADMIN_TABLES in
// supabase/functions/admin-data/handler.ts. The page code does not change: it still calls supabase.from('<table>')...
const PROXIED_TABLES = new Set([
  'documents',
  'email_history',
  'export_session_notes',
  'export_sessions',
  'email_configuration',
  'email_folder_rules',
  'email_folders',
  'email_forwarding_rules',
  'email_spam_blocked',
  'invoice_drafts',
  'invoice_templates',
  'monthly_expenses',
  'portal_alert_templates',
  'user_tasks'
]);

// Tables whose reads go through the gateway (admin session) while inserts still go straight to the database (activity logs)
const PROXIED_READ_ONLY = new Set(['user_activity_log']);

function acnhsPortalToken() {
  try { return sessionStorage.getItem('portalToken') || localStorage.getItem('portalToken') || ''; } catch (_) { return ''; }
}

// Used when the page has no AdminAuth library (student pages): drop the stale session and go to the login page
function acnhsSessionExpired(message) {
  try {
    ['isLoggedIn', 'isAdmin', 'primaryAdmin', 'userEmail', 'userName', 'userId', 'userRole', 'isStudentViewer', 'viewerAccountEmail',
      'studentRecordId', 'studentApplicationId', 'studentInstitutionalEmail', 'studentPersonalEmail', 'isApplicationLogin',
      'adminToken', 'portalToken'].forEach(function (k) { sessionStorage.removeItem(k); localStorage.removeItem(k); });
  } catch (_) { /* ignore */ }
  if (message) { try { alert(message); } catch (_) { /* ignore */ } }
  location.href = 'login.html';
}

function acnhsAdminToken() {
  try { return sessionStorage.getItem('adminToken') || localStorage.getItem('adminToken') || ''; } catch (_) { return ''; }
}

async function acnhsRestFetch(input, init) {
  let url = '';
  try { url = typeof input === 'string' ? input : (input && input.url) || String(input); } catch (_) { url = ''; }
  const prefix = SUPABASE_CONFIG.url + '/rest/v1/';
  if (!url.startsWith(prefix)) return fetch(input, init);

  const rest = url.slice(prefix.length);
  const table = rest.split('?')[0].split('/')[0];
  const method = String((init && init.method) || (typeof input !== 'string' && input && input.method) || 'GET').toUpperCase();
  const viaGateway = PROXIED_TABLES.has(table) || (PROXIED_READ_ONLY.has(table) && (method === 'GET' || method === 'HEAD'));
  if (!viaGateway) return fetch(input, init);

  const token = acnhsAdminToken();
  const portalToken = acnhsPortalToken();
  if (!token && !portalToken) {
    // A session opened before the security update has no token: sign in again
    const expiredMessage = 'Please sign in again to continue (security update).';
    if (typeof window !== 'undefined' && window.AdminAuth && typeof window.AdminAuth.sessionExpired === 'function') window.AdminAuth.sessionExpired(expiredMessage);
    else acnhsSessionExpired(expiredMessage);
    return new Response(JSON.stringify({ code: 'unauthorized', message: 'Session required', details: null, hint: null }), { status: 401, headers: { 'Content-Type': 'application/json' } });
  }

  const target = SUPABASE_CONFIG.url + '/functions/v1/admin-data/' + rest;
  const headers = new Headers((init && init.headers) || (typeof input !== 'string' && input && input.headers) || undefined);
  if (token) headers.set('x-admin-token', token);
  if (portalToken) headers.set('x-portal-token', portalToken);
  const body = init && 'body' in init ? init.body : undefined;
  const res = await fetch(target, { method, headers, body, signal: init && init.signal });
  if (res.status === 401 && window.AdminAuth && typeof window.AdminAuth.sessionExpired === 'function') {
    try {
      const j = await res.clone().json();
      if (j && j.code === 'unauthorized') window.AdminAuth.sessionExpired('Your session has expired. Please sign in again.');
    } catch (_) { /* not JSON */ }
  }
  return res;
}

SUPABASE_CONFIG.options.global = Object.assign({}, SUPABASE_CONFIG.options.global, { fetch: acnhsRestFetch });

// The send-email function only sends for signed-in people. Attach the session tokens (admin, or student/teacher) to those requests,
// whichever way the page calls it (supabase.functions.invoke or a plain fetch).
(function () {
  if (typeof window === 'undefined' || typeof window.fetch !== 'function' || window.__acnhsFetchPatched) return;
  window.__acnhsFetchPatched = true;
  const nativeFetch = window.fetch.bind(window);
  const stored = (key) => { try { return sessionStorage.getItem(key) || localStorage.getItem(key) || ''; } catch (_) { return ''; } };
  window.fetch = function (input, init) {
    try {
      const url = typeof input === 'string' ? input : (input && input.url) || '';
      if (url.indexOf('/functions/v1/send-email') !== -1) {
        const headers = new Headers((init && init.headers) || (typeof input !== 'string' && input && input.headers) || undefined);
        const adminToken = stored('adminToken');
        const portalToken = stored('portalToken');
        if (adminToken && !headers.has('x-admin-token')) headers.set('x-admin-token', adminToken);
        if (portalToken && !headers.has('x-portal-token')) headers.set('x-portal-token', portalToken);
        init = Object.assign({}, init, { headers });
      }
    } catch (_) { /* never block a request because of this */ }
    return nativeFetch(input, init);
  };
})();

// Initialize Supabase client
let supabaseClient = null;

function setSupabaseOwnerHeader(ownerId, ownerRole) {
  if (!ownerId) return;
  SUPABASE_CONFIG.options.global = SUPABASE_CONFIG.options.global || {};
  SUPABASE_CONFIG.options.global.headers = SUPABASE_CONFIG.options.global.headers || {};

  const role = (ownerRole || 'student').toLowerCase().trim();

  // Prevent rebuilding the client if both headers are already correctly set
  if (
    SUPABASE_CONFIG.options.global.headers['x-owner-id']   === ownerId &&
    SUPABASE_CONFIG.options.global.headers['x-owner-role'] === role
  ) {
    return;
  }

  SUPABASE_CONFIG.options.global.headers['x-owner-id']   = ownerId;
  SUPABASE_CONFIG.options.global.headers['x-owner-role'] = role;

  // If a client already exists, rebuild so new headers apply immediately.
  if (supabaseClient && typeof window !== 'undefined' && window.supabase) {
    supabaseClient = window.supabase.createClient(
      SUPABASE_CONFIG.url,
      SUPABASE_CONFIG.anonKey,
      SUPABASE_CONFIG.options
    );
  }
}

function initSupabase() {
  if (typeof window.supabase === 'undefined' || !window.supabase) {
    console.error('Supabase library not loaded. Please include the Supabase CDN script.');
    return null;
  }
  
  if (!supabaseClient) {
    supabaseClient = window.supabase.createClient(
      SUPABASE_CONFIG.url,
      SUPABASE_CONFIG.anonKey,
      SUPABASE_CONFIG.options
    );
  }
  
  return supabaseClient;
}

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { SUPABASE_CONFIG, initSupabase, setSupabaseOwnerHeader };
}
