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
  if (!PROXIED_TABLES.has(table)) return fetch(input, init);

  const token = acnhsAdminToken();
  if (!token) {
    // A session opened before the security update has no token: sign in again
    if (typeof window !== 'undefined' && window.AdminAuth && typeof window.AdminAuth.sessionExpired === 'function') {
      window.AdminAuth.sessionExpired('Please sign in again to continue (security update).');
    }
    return new Response(JSON.stringify({ code: 'unauthorized', message: 'Admin session required', details: null, hint: null }), { status: 401, headers: { 'Content-Type': 'application/json' } });
  }

  const target = SUPABASE_CONFIG.url + '/functions/v1/admin-data/' + rest;
  const headers = new Headers((init && init.headers) || (typeof input !== 'string' && input && input.headers) || undefined);
  headers.set('x-admin-token', token);
  const method = (init && init.method) || (typeof input !== 'string' && input && input.method) || 'GET';
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
