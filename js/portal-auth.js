/* ACNHS portal authentication client (students, applicants, teachers)
 *
 * The password comparison happens on the server (Edge Function "portal-auth"); the pages never receive a stored hash or password.
 * Every call resolves to a plain object and never throws.
 *   PortalAuth.verifyStudent(applicationId, passwordHash) -> { ok, match, hasCredentials, mustChange, reason? }
 *   PortalAuth.promptNewPassword({ applicationId, currentPassword }) -> Promise<{ ok }>  (shows the "create your new password" window)
 *   PortalAuth.changeStudentPassword(applicationId, currentPasswordHash, newPassword) -> { ok, reason? }  reason: bad_password | ...
 *   PortalAuth.verifyTeacher(teacherId, password) -> { ok, match, reason? }
 */
(function () {
  'use strict';

  async function call(body) {
    const cfg = (typeof SUPABASE_CONFIG !== 'undefined') ? SUPABASE_CONFIG : null;
    if (!cfg || !cfg.url) return { ok: false, reason: 'not_configured', message: 'Supabase is not configured' };
    let res;
    try {
      res = await fetch(cfg.url + '/functions/v1/portal-auth', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', apikey: cfg.anonKey, Authorization: 'Bearer ' + cfg.anonKey },
        body: JSON.stringify(body),
      });
    } catch (_) {
      return { ok: false, reason: 'unreachable', message: 'Could not reach the authentication service. Check your connection and try again.' };
    }
    let json = null;
    try { json = await res.json(); } catch (_) { /* not JSON */ }
    if (res.status === 404) return { ok: false, reason: 'not_configured', message: 'The authentication service is not available.' };
    if (!json) return { ok: false, reason: 'error', message: 'Authentication service error (' + res.status + ')' };
    if (json.ok) return json;
    return Object.assign({}, json, { ok: false, reason: json.code || 'error', message: json.error || 'Request failed' });
  }

  // A successful check returns a signed session token; it is kept so the site can prove who the student/teacher is to the server
  // (for instance when sending e-mail). js/supabase-config.js attaches it to those requests.
  async function remember(promise) {
    const res = await promise;
    try {
      if (res && res.ok && res.token) { sessionStorage.setItem('portalToken', res.token); localStorage.setItem('portalToken', res.token); }
    } catch (_) { /* storage blocked */ }
    return res;
  }

  async function sha256(text) {
    const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text));
    return Array.from(new Uint8Array(buf)).map((b) => b.toString(16).padStart(2, '0')).join('');
  }

  const DEFAULT_PASSWORD_RE = /^welcome\d{4}!$/i;

  // A student whose password is a temporary one (the yearly default, or one an admin set) must create their own before entering.
  // Resolves { ok: true } once the server has saved it, { ok: false } if the student cancels.
  function promptNewPassword(opts) {
    return new Promise((resolve) => {
      const wrap = document.createElement('div');
      wrap.setAttribute('role', 'dialog');
      wrap.setAttribute('aria-modal', 'true');
      wrap.style.cssText = 'position:fixed;inset:0;z-index:2147483000;background:rgba(4,17,31,0.92);display:flex;align-items:center;justify-content:center;padding:20px;font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif';
      wrap.innerHTML =
        '<form style="width:100%;max-width:420px;background:#0b2239;border:1px solid rgba(201,168,76,0.45);border-radius:16px;padding:28px;color:#f1f5f9;box-shadow:0 20px 60px rgba(0,0,0,0.6)" autocomplete="off">' +
        '<h2 style="margin:0 0 8px;font-size:20px;color:#e2cc92">Create your new password</h2>' +
        '<p style="margin:0 0 18px;font-size:13px;line-height:1.5;color:#cbd5e1">You signed in with a temporary password. For your security, choose a password of your own before continuing.</p>' +
        '<label style="display:block;font-size:12px;margin-bottom:4px;color:#cbd5e1">New password (at least 8 characters)</label>' +
        '<input data-f="p1" type="password" autocomplete="new-password" style="width:100%;box-sizing:border-box;padding:11px;border-radius:9px;border:1px solid rgba(201,168,76,0.4);background:rgba(4,17,31,0.7);color:#f1f5f9;font-size:14px;margin-bottom:12px">' +
        '<label style="display:block;font-size:12px;margin-bottom:4px;color:#cbd5e1">Repeat new password</label>' +
        '<input data-f="p2" type="password" autocomplete="new-password" style="width:100%;box-sizing:border-box;padding:11px;border-radius:9px;border:1px solid rgba(201,168,76,0.4);background:rgba(4,17,31,0.7);color:#f1f5f9;font-size:14px">' +
        '<div data-f="msg" style="min-height:20px;margin:10px 0 4px;font-size:12.5px;color:#fca5a5"></div>' +
        '<div style="display:flex;gap:10px;margin-top:8px"><button type="button" data-f="cancel" style="flex:1;padding:12px;border-radius:10px;border:1px solid rgba(148,163,184,0.4);background:transparent;color:#cbd5e1;font-size:14px;cursor:pointer">Cancel</button>' +
        '<button type="submit" data-f="ok" style="flex:2;padding:12px;border-radius:10px;border:none;background:linear-gradient(135deg,#c9a84c,#a8872f);color:#0b2239;font-weight:700;font-size:14px;cursor:pointer">Save and continue</button></div></form>';
      document.body.appendChild(wrap);
      const q = (k) => wrap.querySelector('[data-f="' + k + '"]');
      const msg = q('msg');
      const finish = (ok) => { wrap.remove(); resolve({ ok }); };
      setTimeout(() => q('p1').focus(), 50);
      q('cancel').addEventListener('click', () => finish(false));
      wrap.querySelector('form').addEventListener('submit', async (e) => {
        e.preventDefault();
        const p1 = q('p1').value;
        const p2 = q('p2').value;
        if (p1.length < 8) { msg.textContent = 'The password must be at least 8 characters.'; return; }
        if (p1 !== p2) { msg.textContent = 'The two passwords do not match.'; return; }
        if (DEFAULT_PASSWORD_RE.test(p1)) { msg.textContent = 'Please choose a password of your own, not the default one.'; return; }
        if (p1 === opts.currentPassword) { msg.textContent = 'The new password must be different from the temporary one.'; return; }
        const btn = q('ok');
        btn.disabled = true; btn.textContent = 'Saving…'; msg.textContent = '';
        const res = await window.PortalAuth.changeStudentPassword(opts.applicationId, await sha256(opts.currentPassword), p1);
        if (res && res.ok) { finish(true); return; }
        btn.disabled = false; btn.textContent = 'Save and continue';
        msg.textContent = (res && res.message) || 'Could not save the password. Please try again.';
      });
    });
  }

  window.PortalAuth = {
    promptNewPassword,
    verifyStudent: (applicationId, passwordHash) => remember(call({ action: 'student-verify', applicationId, passwordHash })),
    changeStudentPassword: (applicationId, currentPasswordHash, newPassword) => remember(call({ action: 'student-change-password', applicationId, currentPasswordHash, newPassword })),
    verifyTeacher: (teacherId, password) => remember(call({ action: 'teacher-verify', teacherId, password })),
    clear: () => { try { sessionStorage.removeItem('portalToken'); localStorage.removeItem('portalToken'); } catch (_) { /* ignore */ } },
  };
})();
