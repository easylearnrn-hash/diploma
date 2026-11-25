/* ACNHS admin authentication client
 *
 * Talks to the Supabase Edge Function `admin-auth`. The password is hashed in the browser exactly as before (SHA-256), but it is
 * compared on the server, and the server never sends a password hash back. A successful login returns a signed token that the
 * pages keep in sessionStorage/localStorage ('adminToken') and send with every admin-only request.
 */
(function () {
  'use strict';

  const TOKEN_KEY = 'adminToken';

  class AdminAuthError extends Error {
    constructor(message, code, status, dbCode) { super(message); this.name = 'AdminAuthError'; this.code = code || 'error'; this.status = status || 0; this.dbCode = dbCode || null; }
  }

  const store = {
    get() { try { return sessionStorage.getItem(TOKEN_KEY) || localStorage.getItem(TOKEN_KEY) || ''; } catch (_) { return ''; } },
    set(t) { try { sessionStorage.setItem(TOKEN_KEY, t); localStorage.setItem(TOKEN_KEY, t); } catch (_) { /* storage blocked */ } },
    clear() { try { sessionStorage.removeItem(TOKEN_KEY); localStorage.removeItem(TOKEN_KEY); } catch (_) { /* ignore */ } },
  };

  async function sha256(text) {
    const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text));
    return Array.from(new Uint8Array(buf)).map(b => b.toString(16).padStart(2, '0')).join('');
  }

  async function post(body, withToken) {
    const cfg = (typeof SUPABASE_CONFIG !== 'undefined') ? SUPABASE_CONFIG : null;
    if (!cfg || !cfg.url) throw new AdminAuthError('Supabase is not configured', 'not_configured');
    const headers = { 'Content-Type': 'application/json', apikey: cfg.anonKey, Authorization: 'Bearer ' + cfg.anonKey };
    if (withToken) {
      const t = store.get();
      if (!t) throw new AdminAuthError('Please sign in again', 'unauthorized', 401);
      headers['x-admin-token'] = t;
    }
    let res;
    try {
      res = await fetch(cfg.url + '/functions/v1/admin-auth', { method: 'POST', headers, body: JSON.stringify(body) });
    } catch (_) {
      throw new AdminAuthError('Could not reach the authentication service. Check your connection and try again.', 'unreachable');
    }
    let json = null;
    try { json = await res.json(); } catch (_) { /* not JSON */ }
    if (res.status === 404) throw new AdminAuthError('The authentication service is not available.', 'not_configured', 404);
    if (!json) throw new AdminAuthError('Authentication service error (' + res.status + ')', 'error', res.status);
    return { res, json };
  }

  // Signs in. Resolves { ok: true, user } or { ok: false, reason, message }; reason is one of
  // not_found | bad_password | too_many_attempts | auth_unavailable | unreachable | not_configured | error.
  async function login(identifier, password) {
    try {
      const passwordHash = await sha256(password);
      const { json } = await post({ action: 'login', identifier: String(identifier || '').trim(), passwordHash }, false);
      if (json.ok && json.token) { store.set(json.token); return { ok: true, user: json.user }; }
      return { ok: false, reason: json.code || 'error', message: json.error || 'Sign-in failed' };
    } catch (e) {
      return { ok: false, reason: e.code || 'error', message: e.message };
    }
  }

  // Authenticated call; throws AdminAuthError (code 'unauthorized' means: the session has no valid token any more)
  async function call(action, payload) {
    const { res, json } = await post(Object.assign({ action }, payload || {}), true);
    if (!json.ok) {
      if (res.status === 401) store.clear();
      throw new AdminAuthError(json.error || 'Request failed', json.code || 'error', res.status, json.dbCode);
    }
    return json;
  }

  const ADMIN_SESSION_KEYS = ['isLoggedIn', 'isAdmin', 'primaryAdmin', 'userEmail', 'userName', 'userId', 'userRole', 'userSignature', 'userTitle', 'userPhoneExt', 'userPermissions', 'userEmailPermissions', 'adminToken'];

  // The session has no valid token (for instance it was opened before this security update): sign in again
  function sessionExpired(message) {
    try { ADMIN_SESSION_KEYS.forEach(k => { sessionStorage.removeItem(k); localStorage.removeItem(k); }); } catch (_) { /* ignore */ }
    if (message) { try { alert(message); } catch (_) { /* ignore */ } }
    location.href = 'login.html';
  }

  window.AdminAuth = {
    login,
    hasToken: () => !!store.get(),
    clear: store.clear,
    sessionExpired,
    // Student-viewer test account: true only when the server confirms it (credentials live in Supabase secrets, not in the page)
    viewerLogin: async (email, password) => {
      try {
        const passwordHash = await sha256(password);
        const { json } = await post({ action: 'viewer-login', email: String(email || '').trim(), passwordHash }, false);
        return !!(json && json.ok && json.match);
      } catch (_) { return false; }
    },
    me: async () => (await call('me')).user,
    directory: async () => (await call('directory')).users,
    setEmailPermissions: async (emails) => { await call('set-email-permissions', { emails }); },
    users: {
      list: async () => (await call('users-list')).users,
      get: async (id) => (await call('users-get', { id })).user,
      create: async (user) => (await call('users-create', { user })).user,
      update: async (id, user) => (await call('users-update', { id, user })).user,
      remove: async (id) => { await call('users-delete', { id }); },
    },
    AdminAuthError,
  };
})();
