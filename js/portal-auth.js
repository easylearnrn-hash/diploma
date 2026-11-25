/* ACNHS portal authentication client (students, applicants, teachers)
 *
 * The password comparison happens on the server (Edge Function "portal-auth"); the pages never receive a stored hash or password.
 * Every call resolves to a plain object and never throws.
 *   PortalAuth.verifyStudent(applicationId, passwordHash) -> { ok, match, hasCredentials, reason? }
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
      if (res && res.ok && res.match && res.token) { sessionStorage.setItem('portalToken', res.token); localStorage.setItem('portalToken', res.token); }
    } catch (_) { /* storage blocked */ }
    return res;
  }

  window.PortalAuth = {
    verifyStudent: (applicationId, passwordHash) => remember(call({ action: 'student-verify', applicationId, passwordHash })),
    changeStudentPassword: (applicationId, currentPasswordHash, newPassword) => call({ action: 'student-change-password', applicationId, currentPasswordHash, newPassword }),
    verifyTeacher: (teacherId, password) => remember(call({ action: 'teacher-verify', teacherId, password })),
    clear: () => { try { sessionStorage.removeItem('portalToken'); localStorage.removeItem('portalToken'); } catch (_) { /* ignore */ } },
  };
})();
