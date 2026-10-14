/**
 * ACNHS Homepage Pop-Up Alerts  (js/homepage-alerts.js)
 * ---------------------------------------------------------------------------
 * Shows administrator-published announcements to visitors of www.acnhs.am,
 * including people who are not signed in. Managed from alert.html.
 *
 * - One tiny request (RPC get_site_alerts) after the page has finished loading
 *   and the browser is idle. No Supabase library, no layout shift, no blocking.
 * - The database applies lifecycle (published / enabled) and start / expiry
 *   rules with its own clock. This script applies audience, frequency and
 *   acknowledgement rules for the current visitor.
 * - Several alerts are shown as one organised queue ("1 of 3"), highest priority
 *   first, never more than CFG.maxPerVisit per visit.
 * - Message HTML is passed through a strict allow-list sanitizer before display.
 * - Every failure is swallowed: a broken network or database never affects the page.
 *
 * Public API:  window.ACNHSHomepageAlerts
 *   start()            run the engine (automatic unless window.ACNHS_HP_ALERTS_MANUAL)
 *   reset()            forget "already seen" flags and run again (testing)
 *   debug()            explain, per alert, why it is / is not shown
 *   mountPreview(el,a) render an alert exactly as visitors see it (admin preview)
 *   sanitize(html)     the allow-list sanitizer
 */
(function (global, doc) {
  'use strict';

  if (global.ACNHSHomepageAlerts) { return; }

  /* ======================================================================
     Configuration
     ====================================================================== */
  var CFG = {
    surface: 'homepage',
    maxPerVisit: 3,            // never overwhelm a visitor
    cacheMs: 20000,            // re-use the fetched list for 20 s inside one session
    negativeCacheMs: 300000,   // if the feature is not installed yet, do not retry for 5 min
    fetchTimeoutMs: 7000,
    startDelayMs: 900,         // let the hero render first
    criticalDelayMs: 250,
    cookieWaitMs: 8000,        // wait for the cookie banner to be answered (not for urgent / critical)
    tz: 'Asia/Yerevan',
    z: 100000,
    url: (typeof SUPABASE_CONFIG !== 'undefined' && SUPABASE_CONFIG && SUPABASE_CONFIG.url) || 'https://eyhksbiceueoiamwnqpr.supabase.co',
    key: (typeof SUPABASE_CONFIG !== 'undefined' && SUPABASE_CONFIG && SUPABASE_CONFIG.anonKey) || ''
  };

  var DEBUG = /[?&]acnhs_alert_debug=1/.test(global.location.search);
  function log() { if (DEBUG && global.console) { try { global.console.log.apply(global.console, ['[ACNHS alerts]'].concat([].slice.call(arguments))); } catch (e) {} } }

  /* Priority styling. Colour is never the only cue: every level has its own label and icon. */
  var PRIORITY = {
    normal:    { rank: 1, label: 'Announcement',     accent: '#c9a84c', text: '#d9bf73', b1: '#c9a84c', b2: '#e2cc92', on: '#04111f', icon: 'info' },
    important: { rank: 2, label: 'Important Notice', accent: '#f2b134', text: '#f6c764', b1: '#f2b134', b2: '#f8d27a', on: '#04111f', icon: 'bell' },
    urgent:    { rank: 3, label: 'Urgent Notice',    accent: '#f97316', text: '#fb9a52', b1: '#f97316', b2: '#fdba74', on: '#04111f', icon: 'warn' },
    critical:  { rank: 4, label: 'Critical Alert',   accent: '#ef4444', text: '#f87171', b1: '#dc2626', b2: '#ef4444', on: '#ffffff', icon: 'stop' }
  };
  var TONE_SUCCESS = { rank: 1, label: 'Good News', accent: '#2dd4bf', text: '#5eead4', b1: '#14b8a6', b2: '#5eead4', on: '#04111f', icon: 'check' };

  var ICONS = {
    info:  '<circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/>',
    bell:  '<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/>',
    warn:  '<path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/>',
    stop:  '<polygon points="7.86 2 16.14 2 22 7.86 22 16.14 16.14 22 7.86 22 2 16.14 2 7.86 7.86 2"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>',
    check: '<path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>',
    close: '<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>',
    arrow: '<line x1="7" y1="17" x2="17" y2="7"/><polyline points="7 7 17 7 17 17"/>'
  };
  function svg(name, size, sw) {
    return '<svg width="' + size + '" height="' + size + '" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="' + (sw || 2) +
      '" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">' + ICONS[name] + '</svg>';
  }

  /* ======================================================================
     Utilities
     ====================================================================== */
  function safe(fn, fallback) { try { return fn(); } catch (e) { return fallback; } }

  function pickStorage(kind) {
    return safe(function () {
      var s = global[kind], k = '__acnhs_probe__';
      s.setItem(k, '1'); s.removeItem(k);
      return s;
    }, null);
  }
  var LS = pickStorage('localStorage');
  var SS = pickStorage('sessionStorage');
  var mem = {};   // fallback when storage is blocked (private mode): lasts for this page view only

  function sget(store, k) { return safe(function () { return store ? store.getItem(k) : (mem[k] || null); }, null); }
  function sset(store, k, v) { safe(function () { if (store) { store.setItem(k, v); } else { mem[k] = v; } }); }
  function sdel(store, k) { safe(function () { if (store) { store.removeItem(k); } else { delete mem[k]; } }); }
  function either(k) { return sget(SS, k) || sget(LS, k); }

  function esc(s) {
    return String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }
  function parseJson(v) {
    if (!v) { return {}; }
    if (typeof v === 'object') { return v; }
    return safe(function () { return JSON.parse(v); }, {});
  }
  function toArr(v) {
    if (Array.isArray(v)) { return v.map(String); }
    if (typeof v === 'string' && v) { return safe(function () { var p = JSON.parse(v); return Array.isArray(p) ? p.map(String) : []; }, []); }
    return [];
  }
  function norm(s) { return String(s == null ? '' : s).trim().toLowerCase(); }

  /* Calendar date (YYYY-MM-DD) in Armenia time */
  function ymd(d) {
    return safe(function () {
      var o = {};
      new Intl.DateTimeFormat('en-CA', { timeZone: CFG.tz, year: 'numeric', month: '2-digit', day: '2-digit' })
        .formatToParts(d || new Date()).forEach(function (p) { o[p.type] = p.value; });
      return o.year + '-' + o.month + '-' + o.day;
    }, (d || new Date()).toISOString().slice(0, 10));
  }

  function priorityOf(a) {
    if (a && PRIORITY[a.priority]) { return a.priority; }
    if (a && a.severity === 'critical') { return 'critical'; }
    if (a && a.severity === 'warn') { return 'important'; }
    return 'normal';
  }
  function toneOf(a) {
    var p = priorityOf(a);
    if (a && a.severity === 'success' && (p === 'normal' || p === 'important')) { return TONE_SUCCESS; }
    return PRIORITY[p];
  }
  function hexToRgba(hex, alpha) {
    var h = String(hex).replace('#', '');
    var n = parseInt(h.length === 3 ? h.replace(/(.)/g, '$1$1') : h, 16);
    return 'rgba(' + ((n >> 16) & 255) + ',' + ((n >> 8) & 255) + ',' + (n & 255) + ',' + alpha + ')';
  }

  /* ======================================================================
     Safe links and the HTML sanitizer
     ====================================================================== */
  function safeHref(url) {
    var u = String(url == null ? '' : url).trim();
    if (!u) { return ''; }
    if (/^(https?:\/\/|mailto:|tel:)[^\s<>"'`]+$/i.test(u)) { return u; }
    if (/^[^:\s<>"'`]+$/.test(u)) { return u; }       // relative page such as hub.html or /apply
    return '';
  }

  var DROP = { SCRIPT: 1, STYLE: 1, IFRAME: 1, OBJECT: 1, EMBED: 1, LINK: 1, META: 1, TEMPLATE: 1, NOSCRIPT: 1, SVG: 1, MATH: 1,
               FORM: 1, INPUT: 1, BUTTON: 1, TEXTAREA: 1, SELECT: 1, CANVAS: 1, AUDIO: 1, VIDEO: 1, IMG: 1, BASE: 1, FRAME: 1, FRAMESET: 1 };
  var KEEP = { P: 1, BR: 1, STRONG: 1, B: 1, EM: 1, I: 1, U: 1, UL: 1, OL: 1, LI: 1, A: 1, SPAN: 1, H3: 1, H4: 1, BLOCKQUOTE: 1, HR: 1 };

  /* Returns safe HTML. textFn (optional) transforms TEXT nodes only (used for {tokens}). */
  function sanitizeHtml(html, textFn) {
    var parsed;
    try { parsed = new DOMParser().parseFromString('<!doctype html><body>' + String(html == null ? '' : html), 'text/html'); }
    catch (e) { return esc(String(html || '').replace(/<[^>]*>/g, ' ')); }
    var out = doc.createElement('div');

    function walk(src, dst) {
      for (var n = src.firstChild; n; n = n.nextSibling) {
        if (n.nodeType === 3) {
          var t = n.nodeValue;
          dst.appendChild(doc.createTextNode(textFn ? textFn(t) : t));
        } else if (n.nodeType === 1) {
          var tag = n.nodeName.toUpperCase();
          if (DROP[tag]) { continue; }
          if (tag === 'DIV') {                       // browsers wrap lines in <div>: treat as paragraphs
            var p = doc.createElement('p'); walk(n, p);
            if (p.textContent.trim() || p.querySelector('br')) { dst.appendChild(p); }
          } else if (KEEP[tag]) {
            var el = doc.createElement(tag.toLowerCase());
            if (tag === 'A') {
              var href = safeHref(n.getAttribute('href'));
              if (!href) { walk(n, dst); continue; }          // no safe link: keep the text only
              el.setAttribute('href', href);
              if (/^https?:/i.test(href)) { el.setAttribute('target', '_blank'); }
              el.setAttribute('rel', 'noopener noreferrer');
            }
            walk(n, el);
            dst.appendChild(el);
          } else {
            walk(n, dst);                            // unknown element: keep its text, drop the tag
          }
        }
      }
    }
    walk(parsed.body, out);
    // tidy: remove empty paragraphs, collapse leading/trailing <br>
    var empties = out.querySelectorAll('p,span,li');
    for (var i = empties.length - 1; i >= 0; i--) {
      if (!empties[i].textContent.trim() && !empties[i].querySelector('br')) { empties[i].parentNode.removeChild(empties[i]); }
    }
    return out.innerHTML;
  }

  /* ======================================================================
     Visitor / student context
     ====================================================================== */
  function isAdminSession() { return either('isAdmin') === 'true'; }

  /* A signed-in student: logged in, not an admin, not an applicant, with a student record. */
  function signedInStudent() {
    var logged = sget(SS, 'isLoggedIn') === 'true' || sget(LS, 'isLoggedIn') === 'true';
    if (!logged) { return null; }
    if (isAdminSession()) { return null; }
    if (either('isApplicationLogin') === 'true') { return null; }
    var id = either('studentRecordId');
    return id ? { recordId: String(id) } : null;
  }

  function readStoredStudent(recordId) {
    var keys = ['hubStudentData', 'studentData', 'currentStudent', 'acnhs_hp_student'];
    for (var i = 0; i < keys.length; i++) {
      var raw = either(keys[i]);
      if (!raw) { continue; }
      var p = parseJson(raw);
      var id = p.id || p.student_id_pk;
      if (id && String(id) === String(recordId)) {
        return {
          id: String(id),
          student_id: p.student_id || p.studentId || null,
          full_name: p.full_name || p.fullName || null,
          email: p.email || null,
          enrollment_group: p.enrollment_group || p.enrollmentGroup || null,
          group_name: p.group_name || p.groupName || null,
          group: p['group'] || null,
          program: p.program || null
        };
      }
    }
    return null;
  }
  function hasGroupInfo(s) { return !!(s && (s.group || s.group_name || s.enrollment_group || s.program)); }

  function studentGroups(s) {
    return [s && s.enrollment_group, s && s.group_name, s && s['group'], s && s.program].filter(Boolean).map(norm);
  }

  var TOKEN_RE = /\{(student_name|student_id|email|group|month|year|date)\}/g;
  function usesTokens(a) { TOKEN_RE.lastIndex = 0; return TOKEN_RE.test((a.title || '') + ' ' + (a.message_html || '')); }

  var MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  function personalizer(ctx) {
    var s = ctx && ctx.student, now = new Date();
    var vals = {
      student_name: (s && s.full_name) || (ctx && ctx.signedIn ? 'Student' : 'Visitor'),
      student_id: (s && s.student_id) || 'N/A',
      email: (s && s.email) || '',
      group: (s && (s['group'] || s.group_name || s.enrollment_group || s.program)) || 'N/A',
      month: MONTHS[now.getMonth()],
      year: String(now.getFullYear()),
      date: now.toLocaleDateString('en-US')
    };
    return function (text) { return String(text == null ? '' : text).replace(TOKEN_RE, function (m, k) { return vals[k]; }); };
  }

  /* ======================================================================
     Network
     ====================================================================== */
  function rest(path, init) {
    init = init || {};
    var ctl = (typeof AbortController !== 'undefined') ? new AbortController() : null;
    var timer = ctl ? setTimeout(function () { ctl.abort(); }, CFG.fetchTimeoutMs) : null;
    var headers = { apikey: CFG.key, Authorization: 'Bearer ' + CFG.key, Accept: 'application/json' };
    Object.keys(init.headers || {}).forEach(function (k) { headers[k] = init.headers[k]; });
    var opts = { method: init.method || 'GET', headers: headers, cache: 'no-store', credentials: 'omit' };
    if (init.body) { opts.body = init.body; }
    if (ctl) { opts.signal = ctl.signal; }
    return fetch(CFG.url + path, opts).then(
      function (r) { if (timer) { clearTimeout(timer); } return r; },
      function (e) { if (timer) { clearTimeout(timer); } throw e; }
    );
  }

  var CACHE_KEY = 'acnhs_hp_payload_v1';
  function fetchAlerts() {
    var cached = parseJson(sget(SS, CACHE_KEY));
    if (cached && cached.t && (Date.now() - cached.t) < (cached.empty ? CFG.negativeCacheMs : CFG.cacheMs)) {
      log('using cached alert list');
      return Promise.resolve(cached.data || { alerts: [] });
    }
    return rest('/rest/v1/rpc/get_site_alerts?p_surface=' + CFG.surface).then(function (r) {
      if (!r.ok) {
        sset(SS, CACHE_KEY, JSON.stringify({ t: Date.now(), empty: true, data: { alerts: [] } }));
        log('alert function unavailable (' + r.status + ') - feature not installed yet?');
        return { alerts: [] };
      }
      return r.json().then(function (data) {
        var clean = (data && Array.isArray(data.alerts)) ? data : { alerts: [] };
        sset(SS, CACHE_KEY, JSON.stringify({ t: Date.now(), data: clean }));
        return clean;
      });
    });
  }

  function fetchStudent(recordId) {
    return rest('/rest/v1/students?id=eq.' + encodeURIComponent(recordId) + '&select=id,student_id,full_name,email,program,group,group_name&limit=1')
      .then(function (r) { return r.ok ? r.json() : []; })
      .then(function (rows) {
        var d = rows && rows[0];
        if (!d) { return null; }
        var s = { id: d.id, student_id: d.student_id || null, full_name: d.full_name || null, email: d.email || null,
                  enrollment_group: null, group_name: d.group_name || null, group: d['group'] || null, program: d.program || null };
        sset(SS, 'acnhs_hp_student', JSON.stringify(s));
        return s;
      })
      .catch(function () { return null; });
  }

  function recordImpression(a, ctx) {
    if (!ctx || !ctx.recordId || !a || !a.id) { return; }
    rest('/rest/v1/portal_alert_impressions?on_conflict=alert_id,student_id,shown_date_local', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Prefer: 'resolution=ignore-duplicates,return=minimal' },
      body: JSON.stringify({ alert_id: a.id, student_id: ctx.recordId, shown_date_local: ymd(), page_path: 'index.html' })
    }).catch(function () {});
  }

  /* ======================================================================
     Eligibility
     ====================================================================== */
  function inRecurrence(a) {
    var sched = parseJson(a.schedule_rules);
    var rule = sched.recurrence_type || a.date_rule_type || 'always';
    var today = ymd();
    if (rule === 'monthly_range' || rule === 'monthly') {
      var day = parseInt(today.slice(8, 10), 10);
      var dr = sched.monthly_pattern && sched.monthly_pattern.day_range;
      var s = (a.monthly_start_day != null ? a.monthly_start_day : (dr && dr[0])) || 1;
      var e = (a.monthly_end_day != null ? a.monthly_end_day : (dr && dr[1])) || 31;
      return day >= s && day <= e;
    }
    if (rule === 'custom_dates') {
      var dates = toArr(sched.custom_dates && sched.custom_dates.length ? sched.custom_dates : a.custom_dates);
      return dates.indexOf(today) !== -1;
    }
    if ((rule === 'date_range' || rule === 'one_time') && !a.publish_at && !a.expires_at) {
      var start = String(sched.start_datetime || a.start_date || '').slice(0, 10);
      var end = String(sched.end_datetime || a.end_date || '').slice(0, 10);
      if (start && today < start) { return false; }
      if (end && today > end) { return false; }
    }
    return true;
  }

  function audienceReason(a, ctx) {
    var t = a.target_type || 'all';
    if (t === 'all') { return null; }
    if (t === 'public') { return ctx.signedIn ? 'visitors-only alert' : null; }
    if (!ctx.signedIn) { return 'needs a signed-in student'; }
    if (t === 'students') { return null; }
    if (t === 'individual') {
      var rules = parseJson(a.targeting_rules);
      var ids = toArr(a.target_student_ids).concat(toArr(rules.include_students));
      var me = [ctx.recordId, ctx.student && ctx.student.student_id].filter(Boolean).map(String);
      return me.some(function (x) { return ids.indexOf(x) !== -1; }) ? null : 'not an intended student';
    }
    if (t === 'group') {
      var tr = parseJson(a.targeting_rules);
      var wanted = (Array.isArray(tr.groups) && tr.groups.length ? tr.groups : (a.target_group ? [a.target_group] : [])).map(norm).filter(Boolean);
      if (!wanted.length) { return 'group alert without a group'; }
      var mine = studentGroups(ctx.student);
      return wanted.some(function (g) { return mine.indexOf(g) !== -1; }) ? null : 'not in the target group';
    }
    return 'unknown audience';
  }

  function seenKey(a) { return 'acnhs_hp_seen:' + a.id + ':' + (a.revision || 1); }
  var shownThisView = {};

  function frequencyReason(a) {
    if (shownThisView[a.id]) { return 'already shown in this page view'; }
    var f = a.popup_frequency || 'once_per_session';
    if (f === 'every_visit') { return null; }
    if (f === 'once_per_visitor') { return sget(LS, seenKey(a)) ? 'already seen by this visitor (until updated)' : null; }
    return sget(SS, seenKey(a)) ? 'already seen this session' : null;
  }

  function evaluate(a, ctx) {
    if (a.display_surface && a.display_surface !== 'homepage' && a.display_surface !== 'both') { return 'not a homepage alert'; }
    if (a.lifecycle_status && a.lifecycle_status !== 'published') { return 'not published'; }
    if (a.is_active === false) { return 'switched off'; }
    if (!inRecurrence(a)) { return 'outside its recurring schedule'; }
    return audienceReason(a, ctx) || frequencyReason(a);
  }

  function byImportance(x, y) {
    var rx = PRIORITY[priorityOf(x)].rank, ry = PRIORITY[priorityOf(y)].rank;
    if (rx !== ry) { return ry - rx; }
    var tx = Date.parse(x.publish_at || x.published_at || x.created_at || 0) || 0;
    var ty = Date.parse(y.publish_at || y.published_at || y.created_at || 0) || 0;
    return ty - tx;
  }

  function markShown(a) {
    shownThisView[a.id] = true;
    if (a.dismiss_behavior === 'acknowledge') { return; }   // acknowledgement alerts count only once acknowledged
    persistSeen(a);
  }
  function persistSeen(a) {
    var f = a.popup_frequency || 'once_per_session';
    if (f === 'once_per_visitor') {
      safe(function () {        // drop flags from older revisions of this alert
        var prefix = 'acnhs_hp_seen:' + a.id + ':', keep = seenKey(a);
        for (var i = LS.length - 1; i >= 0; i--) { var k = LS.key(i); if (k && k.indexOf(prefix) === 0 && k !== keep) { LS.removeItem(k); } }
      });
      sset(LS, seenKey(a), String(Date.now()));
    } else if (f === 'once_per_session') {
      sset(SS, seenKey(a), '1');
    }
  }
  function pruneOldFlags() {
    safe(function () {
      if (!LS) { return; }
      var limit = Date.now() - 400 * 86400000;
      for (var i = LS.length - 1; i >= 0; i--) {
        var k = LS.key(i);
        if (k && k.indexOf('acnhs_hp_seen:') === 0 && (parseInt(LS.getItem(k), 10) || 0) < limit) { LS.removeItem(k); }
      }
    });
  }

  /* ======================================================================
     Styles
     ====================================================================== */
  var STYLE_ID = 'acnhs-hp-css';
  function ensureStyles() {
    if (doc.getElementById(STYLE_ID)) { return; }
    var s = doc.createElement('style');
    s.id = STYLE_ID;
    s.textContent = [
      '.acnhs-hp-overlay,.acnhs-hp-overlay *{box-sizing:border-box}',
      '.acnhs-hp-overlay [hidden]{display:none!important}',
      '.acnhs-hp-overlay{position:fixed;inset:0;z-index:' + CFG.z + ';display:flex;align-items:center;justify-content:center;padding:20px;background:rgba(4,17,31,.86);opacity:0;transition:opacity .28s ease;font-family:"Inter","Noto Sans Armenian",system-ui,-apple-system,"Segoe UI",sans-serif;-webkit-tap-highlight-color:transparent;overscroll-behavior:contain}',
      '.acnhs-hp-overlay.is-open{opacity:1}',
      '.acnhs-hp-embedded{position:absolute;z-index:2;padding:14px}',
      '.acnhs-hp-dialog{--hp-accent:#c9a84c;--hp-text:#d9bf73;--hp-b1:#c9a84c;--hp-b2:#e2cc92;--hp-on:#04111f;--hp-soft:rgba(201,168,76,.14);--hp-ring:rgba(201,168,76,.38);position:relative;display:flex;flex-direction:column;width:100%;max-width:560px;max-height:88vh;max-height:min(88vh,760px);max-height:min(88dvh,760px);border-radius:20px;color:#f0ece3;background:radial-gradient(120% 70% at 0% 0%,var(--hp-soft) 0%,transparent 60%),linear-gradient(160deg,#0b2543 0%,#071b30 46%,#04111f 100%);border:1px solid var(--hp-ring);box-shadow:0 34px 80px -14px rgba(0,0,0,.78),0 0 0 1px rgba(255,255,255,.03) inset;overflow:hidden;outline:none;transform:translateY(16px) scale(.98);transition:transform .4s cubic-bezier(.16,1,.3,1)}',
      '.acnhs-hp-overlay.is-open .acnhs-hp-dialog{transform:none}',
      '.acnhs-hp-overlay.is-nudge .acnhs-hp-dialog{animation:acnhs-hp-nudge .38s ease}',
      '@keyframes acnhs-hp-nudge{0%,100%{transform:translateX(0)}20%{transform:translateX(-7px)}40%{transform:translateX(6px)}60%{transform:translateX(-4px)}80%{transform:translateX(3px)}}',
      '@keyframes acnhs-hp-swap{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:none}}',
      '.acnhs-hp-swap .acnhs-hp-head,.acnhs-hp-swap .acnhs-hp-body,.acnhs-hp-swap .acnhs-hp-foot{animation:acnhs-hp-swap .3s ease both}',
      '.acnhs-hp-bar{height:3px;flex:none;background:linear-gradient(90deg,var(--hp-accent),var(--hp-b2) 55%,transparent)}',
      '.acnhs-hp-flag{flex:none;padding:7px 18px;font-size:11px;font-weight:600;letter-spacing:.04em;line-height:1.4;color:#04111f;background:#e2cc92;text-align:center}',
      '.acnhs-hp-x{position:absolute;top:14px;right:14px;z-index:3;width:40px;height:40px;display:flex;align-items:center;justify-content:center;padding:0;border-radius:50%;border:1px solid rgba(255,255,255,.14);background:rgba(255,255,255,.05);color:#d9d3c6;cursor:pointer;transition:background .2s,color .2s,border-color .2s;touch-action:manipulation}',
      '.acnhs-hp-x:hover{background:rgba(255,255,255,.12);color:#fff;border-color:rgba(255,255,255,.28)}',
      '.acnhs-hp-x:focus-visible,.acnhs-hp-btn:focus-visible,.acnhs-hp-body a:focus-visible{outline:2px solid var(--hp-accent);outline-offset:3px}',
      '.acnhs-hp-head{display:flex;align-items:center;gap:16px;padding:26px 66px 14px 26px}',
      '.acnhs-hp-ring{flex:none;width:50px;height:50px;border-radius:50%;display:flex;align-items:center;justify-content:center;color:var(--hp-accent);background:var(--hp-soft);border:1.5px solid var(--hp-ring)}',
      '.acnhs-hp-headtext{min-width:0}',
      '.acnhs-hp-eyebrow{font-size:10.5px;font-weight:700;letter-spacing:.2em;text-transform:uppercase;color:var(--hp-text);margin:0 0 5px}',
      '.acnhs-hp-title{font-family:"Playfair Display","Noto Serif Armenian",Georgia,serif;font-size:22px;font-weight:700;line-height:1.25;letter-spacing:0;color:#f6f2e8;margin:0;overflow-wrap:anywhere}',
      '.acnhs-hp-body{flex:1 1 auto;min-height:0;overflow-y:auto;-webkit-overflow-scrolling:touch;overscroll-behavior:contain;padding:6px 26px 20px;font-size:15px;line-height:1.72;color:#cdc7b8}',
      '.acnhs-hp-body p{margin:0 0 13px}',
      '.acnhs-hp-body p:last-child,.acnhs-hp-body ul:last-child,.acnhs-hp-body ol:last-child{margin-bottom:0}',
      '.acnhs-hp-body ul,.acnhs-hp-body ol{margin:0 0 13px;padding-left:22px}',
      '.acnhs-hp-body li{margin:0 0 6px}',
      '.acnhs-hp-body strong,.acnhs-hp-body b{color:#f6f2e8;font-weight:600}',
      '.acnhs-hp-body h3,.acnhs-hp-body h4{font-family:"Playfair Display",Georgia,serif;color:#f6f2e8;margin:0 0 8px;font-size:17px}',
      '.acnhs-hp-body blockquote{margin:0 0 13px;padding:2px 0 2px 14px;border-left:3px solid var(--hp-ring);color:#d9d3c6}',
      '.acnhs-hp-body hr{border:0;border-top:1px solid rgba(255,255,255,.1);margin:14px 0}',
      '.acnhs-hp-body a{color:var(--hp-text);font-weight:500;text-decoration:none;border-bottom:1px solid var(--hp-ring)}',
      '.acnhs-hp-body a:hover{color:#fff;border-bottom-color:var(--hp-accent)}',
      '.acnhs-hp-foot{flex:none;display:flex;align-items:center;justify-content:space-between;gap:14px;padding:16px 26px 22px;border-top:1px solid rgba(255,255,255,.08);background:linear-gradient(0deg,rgba(4,17,31,.65),transparent)}',
      '.acnhs-hp-count{display:flex;align-items:center;gap:10px;font-size:12px;font-weight:600;letter-spacing:.04em;color:#9aa6b8;white-space:nowrap}',
      '.acnhs-hp-dots{display:flex;gap:5px}',
      '.acnhs-hp-dots i{width:7px;height:7px;border-radius:50%;background:rgba(255,255,255,.22)}',
      '.acnhs-hp-dots i.on{background:var(--hp-accent)}',
      '.acnhs-hp-actions{display:flex;flex-wrap:wrap;gap:10px;justify-content:flex-end;margin-left:auto}',
      '.acnhs-hp-btn{display:inline-flex;align-items:center;justify-content:center;gap:8px;min-height:46px;padding:12px 22px;border-radius:12px;font-family:"Inter","Noto Sans Armenian",system-ui,sans-serif;font-size:14px;font-weight:700;line-height:1.2;text-decoration:none;cursor:pointer;border:1px solid transparent;transition:transform .15s,box-shadow .2s,background .2s,border-color .2s,color .2s;touch-action:manipulation}',
      '.acnhs-hp-btn-primary{color:var(--hp-on);background:linear-gradient(135deg,var(--hp-b1),var(--hp-b2));box-shadow:0 6px 20px -4px var(--hp-ring)}',
      '.acnhs-hp-btn-primary:hover{transform:translateY(-1px);box-shadow:0 10px 26px -4px var(--hp-ring)}',
      '.acnhs-hp-btn-outline{color:var(--hp-text);background:transparent;border-color:var(--hp-ring)}',
      '.acnhs-hp-btn-outline:hover{background:var(--hp-soft);border-color:var(--hp-accent)}',
      '.acnhs-hp-btn-ghost{color:#d9d3c6;background:transparent;border-color:rgba(255,255,255,.16)}',
      '.acnhs-hp-btn-ghost:hover{background:rgba(255,255,255,.07);color:#fff;border-color:rgba(255,255,255,.3)}',
      '@media (max-width:560px){' + smallScreenRules('') + '}',
      smallScreenRules('.acnhs-hp-compact'),
      '.acnhs-hp-embedded .acnhs-hp-dialog{max-height:100%}',
      '@media (prefers-reduced-motion:reduce){.acnhs-hp-overlay,.acnhs-hp-dialog,.acnhs-hp-btn{transition:none}.acnhs-hp-swap .acnhs-hp-head,.acnhs-hp-swap .acnhs-hp-body,.acnhs-hp-swap .acnhs-hp-foot,.acnhs-hp-overlay.is-nudge .acnhs-hp-dialog{animation:none}}'
    ].join('\n');
    doc.head.appendChild(s);
  }

  /* Phone layout. Applied by the media query on real phones, and by the .acnhs-hp-compact
     class when the admin preview simulates a phone inside a desktop window. */
  function smallScreenRules(scope) {
    var o = scope ? '.acnhs-hp-overlay' + scope : '.acnhs-hp-overlay';
    var d = scope ? scope + ' ' : '';
    return [
      o + '{padding:12px}',
      d + '.acnhs-hp-dialog{border-radius:18px;max-height:calc(100vh - 24px);max-height:calc(100dvh - 24px)}',
      d + '.acnhs-hp-head{padding:22px 58px 12px 20px;gap:13px}',
      d + '.acnhs-hp-ring{width:44px;height:44px}',
      d + '.acnhs-hp-title{font-size:19px}',
      d + '.acnhs-hp-body{padding:4px 20px 18px;font-size:14.5px}',
      d + '.acnhs-hp-foot{flex-direction:column-reverse;align-items:stretch;padding:14px 20px 20px}',
      d + '.acnhs-hp-count{justify-content:center}',
      d + '.acnhs-hp-actions{flex-direction:column;margin-left:0}',
      d + '.acnhs-hp-btn{width:100%}'
    ].join('');
  }

  /* ======================================================================
     Rendering (shared by the live site and the admin preview)
     ====================================================================== */
  function shellHtml() {
    return '<div class="acnhs-hp-dialog" role="dialog" aria-modal="true" aria-labelledby="acnhs-hp-title" aria-describedby="acnhs-hp-body" tabindex="-1">' +
      '<div class="acnhs-hp-bar"></div>' +
      '<div class="acnhs-hp-flag" data-hp="flag" hidden></div>' +
      '<button type="button" class="acnhs-hp-x" data-hp-act="dismiss" aria-label="Close announcement">' + svg('close', 16, 2.4) + '</button>' +
      '<div class="acnhs-hp-head"><div class="acnhs-hp-ring" data-hp="icon"></div>' +
      '<div class="acnhs-hp-headtext"><div class="acnhs-hp-eyebrow" data-hp="eyebrow"></div>' +
      '<div class="acnhs-hp-title" id="acnhs-hp-title" role="heading" aria-level="2" data-hp="title"></div></div></div>' +
      '<div class="acnhs-hp-body" id="acnhs-hp-body" data-hp="body"></div>' +
      '<div class="acnhs-hp-foot"><div class="acnhs-hp-count" data-hp="count"></div><div class="acnhs-hp-actions" data-hp="actions"></div></div>' +
      '</div>';
  }

  function q(root, name) { return root.querySelector('[data-hp="' + name + '"]'); }

  /* Paints one alert into an overlay element. Returns the info the controller needs. */
  function paint(overlay, a, index, total, ctx, opts) {
    opts = opts || {};
    var tone = toneOf(a);
    var dialog = overlay.querySelector('.acnhs-hp-dialog');
    var pers = personalizer(ctx);
    var ack = a.dismiss_behavior === 'acknowledge';
    var href = safeHref(a.link_url);
    var newTab = a.link_new_tab !== false;

    dialog.style.setProperty('--hp-accent', tone.accent);
    dialog.style.setProperty('--hp-text', tone.text);
    dialog.style.setProperty('--hp-b1', tone.b1);
    dialog.style.setProperty('--hp-b2', tone.b2);
    dialog.style.setProperty('--hp-on', tone.on);
    dialog.style.setProperty('--hp-soft', hexToRgba(tone.accent, 0.14));
    dialog.style.setProperty('--hp-ring', hexToRgba(tone.accent, 0.4));

    q(overlay, 'icon').innerHTML = svg(tone.icon, 24, 2);
    q(overlay, 'eyebrow').textContent = tone.label;
    q(overlay, 'title').textContent = pers(a.title || '');
    q(overlay, 'body').innerHTML = sanitizeHtml(a.message_html || '', pers);
    q(overlay, 'body').scrollTop = 0;

    var flag = q(overlay, 'flag');
    if (opts.flagText) { flag.textContent = opts.flagText; flag.hidden = false; } else { flag.hidden = true; }

    var x = overlay.querySelector('.acnhs-hp-x');
    x.hidden = ack;                               // acknowledgement alerts cannot be closed with the X

    var ackLabel = (a.acknowledge_label || '').trim() || 'I Understand';
    var cta = '';
    if (href) {
      cta = '<a class="acnhs-hp-btn ' + (ack ? 'acnhs-hp-btn-outline' : 'acnhs-hp-btn-primary') + '" data-hp-act="cta" href="' + esc(href) + '"' +
        (newTab ? ' target="_blank"' : '') + ' rel="noopener noreferrer">' + esc((a.link_label || '').trim() || 'Learn More') + (newTab ? ' ' + svg('arrow', 15, 2.4) : '') + '</a>';
    }
    var main = ack
      ? '<button type="button" class="acnhs-hp-btn acnhs-hp-btn-primary" data-hp-act="ack">' + esc(ackLabel) + '</button>'
      : '<button type="button" class="acnhs-hp-btn ' + (href ? 'acnhs-hp-btn-ghost' : 'acnhs-hp-btn-primary') + '" data-hp-act="dismiss">' +
        (index < total - 1 ? 'Next' : (href ? 'Close' : 'Got it')) + '</button>';
    q(overlay, 'actions').innerHTML = cta + main;

    var count = q(overlay, 'count');
    if (total > 1) {
      var dots = '';
      for (var i = 0; i < total; i++) { dots += '<i class="' + (i === index ? 'on' : '') + '"></i>'; }
      count.innerHTML = '<span>' + (index + 1) + ' of ' + total + '</span><span class="acnhs-hp-dots" aria-hidden="true">' + dots + '</span>';
      count.hidden = false;
    } else {
      count.innerHTML = '';
      count.hidden = true;
    }
    return { ack: ack, href: href, newTab: newTab };
  }

  /* ======================================================================
     Live presentation (modal queue)
     ====================================================================== */
  var active = null;          // current presentation
  var lockState = null;

  function lockScroll() {
    if (lockState) { return; }
    var de = doc.documentElement, b = doc.body;
    var iOS = /iP(hone|ad|od)/.test(global.navigator.userAgent) || (global.navigator.platform === 'MacIntel' && global.navigator.maxTouchPoints > 1);
    lockState = { y: global.pageYOffset || de.scrollTop || 0, ios: iOS, bodyStyle: b.getAttribute('style'), htmlStyle: de.getAttribute('style') };
    var gap = global.innerWidth - de.clientWidth;
    if (iOS) {
      b.style.position = 'fixed'; b.style.top = '-' + lockState.y + 'px'; b.style.width = '100%'; b.style.overflow = 'hidden';
    } else {
      de.style.overflow = 'hidden';
      if (gap > 0) { b.style.paddingRight = gap + 'px'; }
    }
  }
  function unlockScroll() {
    if (!lockState) { return; }
    var de = doc.documentElement, b = doc.body, st = lockState;
    lockState = null;
    if (st.bodyStyle == null) { b.removeAttribute('style'); } else { b.setAttribute('style', st.bodyStyle); }
    if (st.htmlStyle == null) { de.removeAttribute('style'); } else { de.setAttribute('style', st.htmlStyle); }
    if (st.ios) {
      try { global.scrollTo({ top: st.y, left: 0, behavior: 'instant' }); } catch (e) { global.scrollTo(0, st.y); }
    }
  }

  function focusables(root) {
    return [].slice.call(root.querySelectorAll('a[href],button:not([disabled]):not([hidden]),[tabindex]:not([tabindex="-1"])'))
      .filter(function (el) { return !el.hidden && el.offsetParent !== null; });
  }

  function present(queue, ctx, opts) {
    opts = opts || {};
    if (active || !queue.length) { return; }
    ensureStyles();

    var overlay = doc.createElement('div');
    overlay.className = 'acnhs-hp-overlay';
    overlay.id = 'acnhs-hp-overlay';
    overlay.setAttribute('data-acnhs-hp', '1');
    overlay.innerHTML = shellHtml();
    var dialog = overlay.querySelector('.acnhs-hp-dialog');

    var state = { overlay: overlay, queue: queue, i: 0, ctx: ctx, returnFocus: doc.activeElement, info: null, closing: false };
    active = state;

    function show(i, swap) {
      state.i = i;
      var a = queue[i];
      state.info = paint(overlay, a, i, queue.length, ctx, opts);
      if (!opts.preview) { markShown(a); recordImpression(a, ctx); }
      safe(function () { overlay.dispatchEvent(new CustomEvent('acnhs-alert-shown', { bubbles: true, detail: { id: a.id, priority: priorityOf(a) } })); });
      if (swap) {
        dialog.classList.remove('acnhs-hp-swap'); void dialog.offsetWidth; dialog.classList.add('acnhs-hp-swap');
      }
      safe(function () { dialog.focus({ preventScroll: true }); });
    }

    function advance(acknowledged) {
      var a = queue[state.i];
      if (acknowledged && !opts.preview) { persistSeen(a); }
      safe(function () { overlay.dispatchEvent(new CustomEvent('acnhs-alert-closed', { bubbles: true, detail: { id: a.id, acknowledged: !!acknowledged } })); });
      if (state.i < queue.length - 1) { show(state.i + 1, true); } else { close(); }
    }

    function close() {
      if (state.closing) { return; }
      state.closing = true;
      overlay.classList.remove('is-open');
      doc.removeEventListener('keydown', onKey, true);
      setTimeout(function () {
        if (overlay.parentNode) { overlay.parentNode.removeChild(overlay); }
        unlockScroll();
        active = null;
        safe(function () { if (state.returnFocus && state.returnFocus.focus) { state.returnFocus.focus({ preventScroll: true }); } });
      }, 300);
    }

    function nudge() {
      overlay.classList.remove('is-nudge'); void overlay.offsetWidth; overlay.classList.add('is-nudge');
      setTimeout(function () { overlay.classList.remove('is-nudge'); }, 420);
    }

    overlay.addEventListener('click', function (e) {
      var t = e.target;
      var actEl = t.closest ? t.closest('[data-hp-act]') : null;
      if (actEl && overlay.contains(actEl)) {
        var act = actEl.getAttribute('data-hp-act');
        if (act === 'dismiss') { e.preventDefault(); advance(false); return; }
        if (act === 'ack') { e.preventDefault(); advance(true); return; }
        if (act === 'cta') {
          var inf = state.info || {};
          if (!inf.newTab) { persistSeen(queue[state.i]); return; }       // same-tab link: the visitor is acting on it
          if (!inf.ack) { setTimeout(function () { advance(false); }, 120); }
          return;
        }
      }
      if (t === overlay) { if (state.info && state.info.ack) { nudge(); } else { advance(false); } }
    });

    function onKey(e) {
      if (e.key === 'Escape' || e.key === 'Esc') {
        if (state.info && state.info.ack) { nudge(); } else { advance(false); }
        e.stopPropagation(); return;
      }
      if (e.key === 'Tab') {
        var f = focusables(dialog);
        if (!f.length) { e.preventDefault(); dialog.focus(); return; }
        var first = f[0], last = f[f.length - 1], cur = doc.activeElement;
        if (e.shiftKey && (cur === first || cur === dialog)) { e.preventDefault(); last.focus(); }
        else if (!e.shiftKey && cur === last) { e.preventDefault(); first.focus(); }
        else if (!dialog.contains(cur)) { e.preventDefault(); first.focus(); }
      }
    }
    doc.addEventListener('keydown', onKey, true);

    lockScroll();
    doc.body.appendChild(overlay);
    show(0, false);
    global.requestAnimationFrame(function () { overlay.classList.add('is-open'); });
  }

  /* ======================================================================
     Orchestration
     ====================================================================== */
  function delay(ms) { return new Promise(function (r) { setTimeout(r, ms); }); }
  function whenLoaded() {
    return new Promise(function (r) { if (doc.readyState === 'complete') { r(); } else { global.addEventListener('load', function () { r(); }, { once: true }); } });
  }
  function whenIdle() {
    return new Promise(function (r) { if (global.requestIdleCallback) { global.requestIdleCallback(function () { r(); }, { timeout: 1500 }); } else { setTimeout(r, 200); } });
  }
  function whenVisible() {
    return new Promise(function (r) {
      if (doc.visibilityState !== 'hidden') { r(); return; }
      var h = function () { if (doc.visibilityState !== 'hidden') { doc.removeEventListener('visibilitychange', h); r(); } };
      doc.addEventListener('visibilitychange', h);
    });
  }
  function whenCookieSettled() {
    return new Promise(function (resolve) {
      var banner = doc.getElementById('cookie-consent-banner');
      var pending = sget(LS, 'acnhs_cookie_consent') === null;
      if (!banner || !pending) { resolve(); return; }
      var done = false;
      function finish() { if (done) { return; } done = true; global.removeEventListener('cookieConsentUpdated', finish); setTimeout(resolve, 500); }
      global.addEventListener('cookieConsentUpdated', finish);
      setTimeout(finish, CFG.cookieWaitMs);
    });
  }

  function buildContext(list) {
    var me = signedInStudent();
    var ctx = { signedIn: !!me, recordId: me ? me.recordId : null, student: null };
    if (!me) { return Promise.resolve(ctx); }
    ctx.student = readStoredStudent(me.recordId);
    var needGroups = list.some(function (a) { return a.target_type === 'group'; });
    var needName = list.some(usesTokens);
    if (((needGroups && !hasGroupInfo(ctx.student)) || (needName && !ctx.student))) {
      return fetchStudent(me.recordId).then(function (s) { if (s) { ctx.student = s; } return ctx; });
    }
    return Promise.resolve(ctx);
  }

  var started = false;
  /* Search-engine crawlers and speed-test robots never see announcements (keeps the indexed page clean) */
  var BOT_RE = /Googlebot|AdsBot|bingbot|Slurp|DuckDuckBot|Baiduspider|YandexBot|Lighthouse|PageSpeed|GTmetrix/i;
  function start() {
    if (started) { return Promise.resolve(); }
    started = true;
    if (!CFG.key) { return Promise.resolve(); }
    var previewId = safe(function () { return new URLSearchParams(global.location.search).get('acnhs_alert_preview'); }, null);
    if (!previewId && BOT_RE.test(global.navigator.userAgent || '')) { return Promise.resolve(); }
    return (previewId ? runAdminPreview(previewId) : run()).catch(function (e) { log('stopped', e); });
  }

  function run() {
    pruneOldFlags();
    return whenLoaded().then(whenIdle).then(function () { return fetchAlerts(); }).then(function (payload) {
      var list = (payload.alerts || []).filter(function (a) { return a && a.id; });
      if (!list.length) { log('no live homepage alerts'); return null; }
      return buildContext(list).then(function (ctx) {
        var queue = [];
        list.forEach(function (a) { var why = evaluate(a, ctx); if (why) { log('skip "' + a.title + '": ' + why); } else { queue.push(a); } });
        queue.sort(byImportance);
        queue = queue.slice(0, CFG.maxPerVisit);
        if (!queue.length) { return null; }
        var urgent = PRIORITY[priorityOf(queue[0])].rank >= 3;
        return whenVisible()
          .then(function () { return delay(urgent ? CFG.criticalDelayMs : CFG.startDelayMs); })
          .then(function () { return urgent ? null : whenCookieSettled(); })
          .then(function () { present(queue, ctx); });
      });
    });
  }

  function runAdminPreview(id) {
    if (!isAdminSession()) { return Promise.resolve(); }
    return whenLoaded().then(function () {
      return rest('/rest/v1/portal_alerts?id=eq.' + encodeURIComponent(id) + '&select=*&limit=1');
    }).then(function (r) { return r.ok ? r.json() : []; }).then(function (rows) {
      var a = rows && rows[0];
      if (!a) { return; }
      var ctx = { signedIn: false, recordId: null, student: null };
      var status = a.lifecycle_status === 'draft' ? 'a draft' : (a.is_active === false ? 'switched off' : 'saved');
      return delay(400).then(function () {
        present([a], ctx, { preview: true, flagText: 'Administrator preview - this alert is ' + status + '. Nothing is recorded and visitors are not affected.' });
      });
    });
  }

  function reset() {
    safe(function () {
      [SS, LS].forEach(function (store) {
        if (!store) { return; }
        for (var i = store.length - 1; i >= 0; i--) { var k = store.key(i); if (k && (k.indexOf('acnhs_hp_seen:') === 0 || k === CACHE_KEY)) { store.removeItem(k); } }
      });
    });
    shownThisView = {};
    started = false;
    return start();
  }

  function debug() {
    return fetchAlerts().then(function (payload) {
      var list = payload.alerts || [];
      return buildContext(list).then(function (ctx) {
        var rows = list.map(function (a) { return { title: a.title, priority: priorityOf(a), frequency: a.popup_frequency, audience: a.target_type, result: evaluate(a, ctx) || 'WILL SHOW' }; });
        if (global.console && global.console.table) { global.console.table(rows); }
        return { ctx: ctx, rows: rows };
      });
    });
  }

  /* Admin preview: renders exactly what visitors see, inside any container. No storage, no network. */
  function mountPreview(container, a, opts) {
    opts = opts || {};
    ensureStyles();
    container.textContent = '';
    var overlay = doc.createElement('div');
    overlay.className = 'acnhs-hp-overlay acnhs-hp-embedded is-open';
    overlay.innerHTML = shellHtml();
    // ids must not clash with a real pop-up on the same page
    [].slice.call(overlay.querySelectorAll('[id]')).forEach(function (el) { el.removeAttribute('id'); });
    overlay.querySelector('.acnhs-hp-dialog').removeAttribute('aria-labelledby');
    overlay.querySelector('.acnhs-hp-dialog').removeAttribute('aria-describedby');
    overlay.addEventListener('click', function (e) { var t = e.target.closest ? e.target.closest('a,button') : null; if (t) { e.preventDefault(); } });
    container.appendChild(overlay);
    var handle = {
      update: function (next, o) {
        o = o || {};
        overlay.classList.toggle('acnhs-hp-compact', !!o.compact);     // phone layout inside a desktop window
        var ctx = o.student ? { signedIn: true, recordId: 'preview', student: { id: 'preview', student_id: 'ACNHS-0001', full_name: 'Anna Hovhannisyan', email: 'anna@student.acnhs.am', group: 'BSN 101', group_name: 'BSN 101', program: 'B.S.N.' } }
                            : { signedIn: false, recordId: null, student: null };
        paint(overlay, next, o.index || 0, o.total || 1, ctx, { flagText: o.flagText });
      },
      destroy: function () { container.textContent = ''; }
    };
    handle.update(a, opts);
    return handle;
  }

  /* ======================================================================
     Public API + automatic start
     ====================================================================== */
  global.ACNHSHomepageAlerts = {
    version: '1.0.0',
    start: start,
    reset: reset,
    debug: debug,
    mountPreview: mountPreview,
    sanitize: sanitizeHtml,
    safeHref: safeHref,
    priorities: PRIORITY
  };

  if (!global.ACNHS_HP_ALERTS_MANUAL) {
    if (doc.readyState === 'loading') { doc.addEventListener('DOMContentLoaded', function () { start(); }); }
    else { start(); }
  }
})(window, document);
