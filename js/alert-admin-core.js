/**
 * ACNHS Alert Center - core  (js/alert-admin-core.js)
 * Shared helpers, permissions, status logic, data access and UI primitives.
 * Other modules attach to the same window.AC namespace.
 */
(function (global) {
  'use strict';

  var AC = global.AC = global.AC || {};

  /* ======================================================================
     Constants
     ====================================================================== */
  AC.TZ = 'Asia/Yerevan';                 // Armenia: UTC+4 all year (no daylight-saving time)
  AC.TZ_OFFSET = '+04:00';
  AC.MAIN_ADMINS = ['hrachfilm@gmail.com'];
  AC.TOKENS = [
    ['{student_name}', 'Student name'], ['{student_id}', 'Student ID'], ['{email}', 'Email'],
    ['{group}', 'Group'], ['{month}', 'Month'], ['{year}', 'Year'], ['{date}', 'Date']
  ];
  AC.PRIORITY = {
    normal:    { label: 'Normal',    rank: 1, color: '#c9a84c', severity: 'info' },
    important: { label: 'Important', rank: 2, color: '#f2b134', severity: 'warn' },
    urgent:    { label: 'Urgent',    rank: 3, color: '#f97316', severity: 'warn' },
    critical:  { label: 'Critical',  rank: 4, color: '#ef4444', severity: 'critical' }
  };
  AC.STATUS = {
    live: 'Live', scheduled: 'Scheduled', draft: 'Draft', paused: 'Paused', expired: 'Expired', archived: 'Archived'
  };
  AC.SURFACE = { homepage: 'Homepage pop-up', portal: 'Student portal', both: 'Homepage + portal' };
  AC.POP_FREQ = { every_visit: 'Every visit', once_per_session: 'Once per session', once_per_visitor: 'Once per visitor' };
  AC.PORTAL_FREQ = {
    once_ever: 'Once ever', times_limit: 'Limited times', daily: 'Once a day', daily_first_login: 'Daily (first login)',
    every_load: 'Every page load', weekly: 'Once a week', until_response: 'Until answered', cooldown: 'Cooldown'
  };

  AC.state = {
    db: null,
    rows: [],
    schema: { ready: false, rpc: false, checked: false },
    user: { email: '', name: '', isAdmin: false },
    perms: { main: false, manage: false, publish: false },
    ui: { tab: 'all', q: '', status: '', surface: '', priority: '', audience: '', sort: 'newest', stat: '' }
  };

  /* ======================================================================
     Small utilities
     ====================================================================== */
  AC.$ = function (sel, root) { return (root || document).querySelector(sel); };
  AC.$$ = function (sel, root) { return Array.prototype.slice.call((root || document).querySelectorAll(sel)); };
  AC.esc = function (s) {
    return String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  };
  AC.icon = function (name, size, cls) {
    size = size || 16;
    return '<svg class="ac-ic' + (cls ? ' ' + cls : '') + '" width="' + size + '" height="' + size + '" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><use href="#i-' + name + '"/></svg>';
  };
  AC.json = function (v, fallback) {
    if (v && typeof v === 'object') { return v; }
    if (typeof v === 'string' && v) { try { return JSON.parse(v); } catch (e) { /* ignore */ } }
    return fallback === undefined ? {} : fallback;
  };
  AC.arr = function (v) {
    if (Array.isArray(v)) { return v.map(String); }
    var j = AC.json(v, []);
    return Array.isArray(j) ? j.map(String) : [];
  };
  AC.plain = function (html) {
    try { return (new DOMParser().parseFromString('<body>' + String(html || ''), 'text/html').body.textContent || '').replace(/\s+/g, ' ').trim(); }
    catch (e) { return String(html || '').replace(/<[^>]*>/g, ' ').replace(/\s+/g, ' ').trim(); }
  };
  AC.debounce = function (fn, ms) {
    var t; return function () { var a = arguments, c = this; clearTimeout(t); t = setTimeout(function () { fn.apply(c, a); }, ms); };
  };
  AC.plural = function (n, one, many) { return n + ' ' + (n === 1 ? one : (many || one + 's')); };

  /* Dates: everything is stored as UTC (timestamptz) and shown in Armenia time */
  var DT = new Intl.DateTimeFormat('en-GB', { timeZone: AC.TZ, day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', hourCycle: 'h23' });
  var D_ONLY = new Intl.DateTimeFormat('en-GB', { timeZone: AC.TZ, day: 'numeric', month: 'short', year: 'numeric' });
  AC.fmt = function (v) { var d = v instanceof Date ? v : new Date(v); return isNaN(d) ? '' : DT.format(d).replace(',', ''); };
  AC.fmtDay = function (v) { var d = v instanceof Date ? v : new Date(v); return isNaN(d) ? '' : D_ONLY.format(d); };
  AC.relative = function (v, now) {
    var d = v instanceof Date ? v : new Date(v);
    if (isNaN(d)) { return ''; }
    var diff = d.getTime() - (now || new Date()).getTime(), abs = Math.abs(diff), s;
    if (abs < 60000) { s = 'moments'; }
    else if (abs < 3600000) { s = AC.plural(Math.round(abs / 60000), 'min'); }
    else if (abs < 86400000) { s = AC.plural(Math.round(abs / 3600000), 'hour'); }
    else { s = AC.plural(Math.round(abs / 86400000), 'day'); }
    if (s === 'moments') { return 'in a moment'; }
    return diff >= 0 ? 'in ' + s : s + ' ago';
  };
  AC.toInput = function (iso) {                    // UTC ISO -> "YYYY-MM-DDTHH:mm" in Armenia time
    if (!iso) { return ''; }
    var d = new Date(iso);
    return isNaN(d) ? '' : new Date(d.getTime() + 4 * 3600000).toISOString().slice(0, 16);
  };
  AC.fromInput = function (v) {                    // "YYYY-MM-DDTHH:mm" (Armenia time) -> UTC ISO
    if (!v) { return null; }
    var d = new Date(v + ':00' + AC.TZ_OFFSET);
    return isNaN(d) ? null : d.toISOString();
  };
  AC.dayStart = function (ymd) { var d = new Date(ymd + 'T00:00:00' + AC.TZ_OFFSET); return isNaN(d) ? null : d; };

  /* ======================================================================
     Access control and permissions
     ====================================================================== */
  AC.readUser = function () {
    function get(k) { return sessionStorage.getItem(k) || localStorage.getItem(k) || ''; }
    var email = get('userEmail').toLowerCase();
    var isAdmin = sessionStorage.getItem('isAdmin') === 'true' || localStorage.getItem('isAdmin') === 'true';
    var perms = AC.json(get('userPermissions'), {});
    AC.state.user = { email: email, name: get('userName') || email, isAdmin: isAdmin };
    var main = AC.MAIN_ADMINS.indexOf(email) !== -1;
    AC.state.perms = { main: main, manage: main || perms.manage_alerts === true || perms.publish_alerts === true, publish: main || perms.publish_alerts === true };
    return AC.state;
  };

  /* Can the signed-in admin perform this action? (UI-level; see HOMEPAGE-POPUP-ALERTS-SETUP.md) */
  AC.can = function (action, row) {
    var p = AC.state.perms;
    if (p.main) { return true; }
    if (!p.manage) { return false; }
    switch (action) {
      case 'publish': case 'resume': case 'delete': case 'reshow': return !!p.publish;
      case 'edit': {
        if (!row) { return true; }
        var st = AC.statusOf(row);
        return (st === 'live' || st === 'scheduled') ? !!p.publish : true;
      }
      default: return true;
    }
  };

  /* ======================================================================
     Alert semantics (status, audience, labels) - works with old and new rows
     ====================================================================== */
  AC.surfaceOf = function (r) { return r.display_surface || 'portal'; };
  AC.lifecycleOf = function (r) { return r.lifecycle_status || 'published'; };
  AC.priorityOf = function (r) {
    if (r.priority && AC.PRIORITY[r.priority]) { return r.priority; }
    return r.severity === 'critical' ? 'critical' : (r.severity === 'warn' ? 'important' : 'normal');
  };
  AC.audienceType = function (r) {
    var tr = AC.json(r.targeting_rules), trg = AC.json(r.trigger_rules);
    if (tr.mode === 'public' || trg.audience === 'public') { return 'public'; }     // old form stored "public" this way
    if (tr.mode === 'students') { return 'students'; }                              // written before the upgrade: stored as "all" + mode
    return r.target_type || 'all';
  };
  AC.audienceGroups = function (r) {
    var tr = AC.json(r.targeting_rules);
    if (Array.isArray(tr.groups) && tr.groups.length) { return tr.groups.map(String); }
    return r.target_group ? [String(r.target_group)] : [];
  };
  AC.audienceStudents = function (r) {
    var tr = AC.json(r.targeting_rules), a = AC.arr(r.target_student_ids);
    return a.length ? a : AC.arr(tr.include_students);
  };
  AC.audienceLabel = function (r) {
    var t = AC.audienceType(r);
    if (t === 'public') { return 'Visitors (not signed in)'; }
    if (t === 'students') { return 'Signed-in students'; }
    if (t === 'group') { var g = AC.audienceGroups(r); return g.length ? 'Groups: ' + g.join(', ') : 'Selected groups'; }
    if (t === 'individual') { return AC.plural(AC.audienceStudents(r).length, 'specific student'); }
    return 'Everyone';
  };

  /* Start / end of the live window. Prefers the exact fields; falls back to the old day-level date range. */
  AC.windowOf = function (r) {
    var start = r.publish_at ? new Date(r.publish_at) : null;
    var end = r.expires_at ? new Date(r.expires_at) : null;
    if (!start && !end) {
      var sched = AC.json(r.schedule_rules), rule = sched.recurrence_type || r.date_rule_type || 'always';
      if (rule === 'date_range' || rule === 'one_time') {
        var s = String(sched.start_datetime || r.start_date || '').slice(0, 10), e = String(r.end_date || sched.end_datetime || '').slice(0, 10);
        if (s) { start = AC.dayStart(s); }
        if (e) { var ed = AC.dayStart(e); if (ed) { end = new Date(ed.getTime() + 86400000); } }
      }
    }
    return { start: start && !isNaN(start) ? start : null, end: end && !isNaN(end) ? end : null };
  };

  AC.statusOf = function (r, now) {
    now = now || new Date();
    var life = AC.lifecycleOf(r);
    if (life === 'archived') { return 'archived'; }
    if (life === 'draft') { return 'draft'; }
    if (r.is_active === false) { return 'paused'; }
    var w = AC.windowOf(r);
    if (w.start && now < w.start) { return 'scheduled'; }
    if (w.end && now >= w.end) { return 'expired'; }
    return 'live';
  };

  AC.recurrenceOf = function (r) {
    var sched = AC.json(r.schedule_rules), t = sched.recurrence_type || r.date_rule_type || 'always';
    if (t === 'monthly' || t === 'monthly_range') {
      var dr = sched.monthly_pattern && sched.monthly_pattern.day_range;
      return { type: 'monthly', start: r.monthly_start_day || (dr && dr[0]) || 1, end: r.monthly_end_day || (dr && dr[1]) || 31 };
    }
    if (t === 'custom_dates') {
      var cd = AC.arr(sched.custom_dates && sched.custom_dates.length ? sched.custom_dates : r.custom_dates);
      return { type: 'custom', dates: cd };
    }
    return { type: 'none' };
  };

  AC.freqLabel = function (r) {
    var s = AC.surfaceOf(r), home = AC.POP_FREQ[r.popup_frequency || 'once_per_session'];
    var fr = AC.json(r.frequency_rules), cap = fr.cap_type || r.display_mode || 'once_ever';
    var portal = cap === 'times_limit' ? (fr.max_displays || r.max_displays || 1) + '× total' : (AC.PORTAL_FREQ[cap] || cap);
    if (s === 'homepage') { return home; }
    if (s === 'portal') { return portal; }
    return home + ' / ' + portal;
  };

  /* Plain-language description used in the editor and in publish confirmations.
     m = { surface, audience, groups[], students (count), priority, dismiss, popfreq, portalFreq, start(Date|null), end(Date|null), repeat, cta } */
  AC.describe = function (m, status) {
    var out = [], now = new Date();
    var where = m.surface === 'homepage' ? 'on the public homepage (www.acnhs.am)' : (m.surface === 'portal' ? 'inside the student portal' : 'on the public homepage and inside the student portal');
    var who = {
      all: 'every visitor, including signed-in students',
      public: 'visitors who are not signed in',
      students: 'signed-in students',
      group: m.groups && m.groups.length ? 'students in ' + m.groups.join(', ') : 'students in the selected groups (none chosen yet)',
      individual: m.students ? AC.plural(m.students, 'hand-picked student') : 'hand-picked students (none chosen yet)'
    }[m.audience] || 'everyone';
    out.push({ text: 'Appears ' + where + ' for ' + who + '.' });
    out.push({ text: (AC.PRIORITY[m.priority] || AC.PRIORITY.normal).label + ' priority' + (m.dismiss === 'acknowledge' ? '; visitors must acknowledge it before continuing.' : '; visitors can close it.') });
    var f = [];
    if (m.surface !== 'portal') { f.push('on the homepage: ' + (AC.POP_FREQ[m.popfreq] || '').toLowerCase()); }
    if (m.surface !== 'homepage') { f.push('in the portal: ' + (AC.PORTAL_FREQ[m.portalFreq] || m.portalFreq || '').toLowerCase()); }
    out.push({ text: 'Shown ' + f.join('; ') + '.' });
    if (m.start && m.start > now) { out.push({ text: 'Goes live ' + AC.fmt(m.start) + ' (' + AC.relative(m.start, now) + ').' }); }
    else { out.push({ text: status === 'draft' ? 'Goes live as soon as you publish.' : 'Live from ' + (m.start ? AC.fmt(m.start) : 'the moment it is published') + '.' }); }
    if (m.end) {
      var past = m.end <= now;
      out.push({ text: (past ? 'Expiry time is already in the past: ' : 'Expires automatically ') + AC.fmt(m.end) + (past ? ' - it would end immediately.' : ' (' + AC.relative(m.end, now) + ').'), warn: past });
    } else { out.push({ text: 'Stays live until you turn it off.' }); }
    if (m.repeat === 'monthly') { out.push({ text: 'Only on days ' + m.repeatDays + ' of each month.' }); }
    if (m.repeat === 'custom') { out.push({ text: 'Only on the listed dates.' }); }
    if (m.cta) { out.push({ text: 'Has an action button: "' + m.cta + '".' }); }
    return out;
  };

  /* ======================================================================
     Error handling
     ====================================================================== */
  AC.isMissingColumn = function (e) {
    var msg = e && (e.message || '') + ' ' + (e.details || '') + ' ' + (e.hint || '');
    return !!e && (e.code === '42703' || e.code === 'PGRST204' || /column .* does not exist|could not find the .* column|schema cache/i.test(msg));
  };
  AC.explain = function (e) {
    if (!e) { return 'Something went wrong.'; }
    if (AC.isMissingColumn(e)) { return 'The database needs the Alert Center upgrade. Run ADD-HOMEPAGE-POPUP-ALERTS.sql in the Supabase SQL Editor.'; }
    if (e.code === '22023' || e.code === 'P0001') { return e.message; }
    if (e.code === '23514') { return 'One of the values is not allowed by the database (' + (e.message || '').replace(/^.*constraint\s+/i, '') + ').'; }
    if (e.code === '42501') { return 'The database refused this action (permission denied).'; }
    if (/Failed to fetch|NetworkError|network/i.test(e.message || '')) { return 'Cannot reach the server. Check your connection and try again.'; }
    return e.message || 'Something went wrong.';
  };

  /* ======================================================================
     Data access
     ====================================================================== */
  var V2_COLUMNS = 'lifecycle_status,display_surface,priority,publish_at,expires_at,popup_frequency,dismiss_behavior,revision';

  AC.data = {
    db: function () { return AC.state.db; },

    /* Loads every alert and works out whether the V2 upgrade has been applied */
    fetchAll: async function () {
      var db = AC.state.db;
      var res = await db.from('portal_alerts').select('*').order('created_at', { ascending: false }).limit(1000);
      if (res.error) { throw res.error; }
      AC.state.rows = res.data || [];
      var ready;
      if (AC.state.rows.length) { ready = 'lifecycle_status' in AC.state.rows[0] && 'display_surface' in AC.state.rows[0]; }
      else { var probe = await db.from('portal_alerts').select(V2_COLUMNS).limit(1); ready = !probe.error; }
      AC.state.schema.ready = ready;
      AC.state.schema.checked = true;
      if (ready) {
        try { var r = await db.rpc('get_site_alerts', { p_surface: 'homepage' }); AC.state.schema.rpc = !r.error; }
        catch (e) { AC.state.schema.rpc = false; }
      } else { AC.state.schema.rpc = false; }
      return AC.state.rows;
    },

    insert: async function (payload) {
      var res = await AC.state.db.from('portal_alerts').insert([payload]).select().single();
      if (res.error) { throw res.error; }
      AC.data.cache(res.data);
      return res.data;
    },
    update: async function (id, patch) {
      var res = await AC.state.db.from('portal_alerts').update(patch).eq('id', id).select().single();
      if (res.error) { throw res.error; }
      AC.data.cache(res.data);
      return res.data;
    },
    remove: async function (id) {
      var res = await AC.state.db.from('portal_alerts').delete().eq('id', id);
      if (res.error) { throw res.error; }
      AC.state.rows = AC.state.rows.filter(function (r) { return r.id !== id; });
    },
    cache: function (row) {
      var i = AC.state.rows.findIndex(function (r) { return r.id === row.id; });
      if (i === -1) { AC.state.rows.unshift(row); } else { AC.state.rows[i] = row; }
    },
    byId: function (id) { return AC.state.rows.find(function (r) { return r.id === id; }) || null; },

    /* Columns that only exist after the upgrade: stripped when the upgrade is missing */
    V2_FIELDS: ['display_surface', 'lifecycle_status', 'priority', 'publish_at', 'expires_at', 'popup_frequency', 'dismiss_behavior',
                'acknowledge_label', 'link_new_tab', 'revision', 'published_at', 'published_by', 'updated_by', 'archived_at', 'archived_by'],
    stripV2: function (payload) {
      var out = {}; Object.keys(payload).forEach(function (k) { if (AC.data.V2_FIELDS.indexOf(k) === -1) { out[k] = payload[k]; } });
      return out;
    }
  };

  /* ======================================================================
     UI primitives: toast, dialogs, menu, focus trap
     ====================================================================== */
  AC.ui = {};

  AC.ui.toast = function (message, type, ms) {
    var host = AC.$('#ac-toasts');
    if (!host) { return; }
    var el = document.createElement('div');
    el.className = 'ac-toast ' + (type || 'ok');
    el.innerHTML = AC.icon(type === 'err' ? 'alert' : (type === 'info' ? 'info' : 'check'), 18) + '<span>' + AC.esc(message) + '</span>';
    host.appendChild(el);
    var life = ms || (type === 'err' ? 7000 : 3800);
    setTimeout(function () { el.classList.add('out'); setTimeout(function () { el.remove(); }, 260); }, life);
    return el;
  };

  var trapStack = [];            // only the top-most dialog reacts to Tab / Escape

  AC.ui.trapFocus = function (container, onEscape) {
    var prev = document.activeElement, entry = { container: container };
    trapStack.push(entry);
    function focusables() {
      return AC.$$('a[href],button:not([disabled]),input:not([disabled]):not([type=hidden]),select:not([disabled]),textarea:not([disabled]),[contenteditable="true"],[tabindex]:not([tabindex="-1"])', container)
        .filter(function (el) { return el.offsetParent !== null && !el.closest('[hidden]'); });
    }
    function onKey(e) {
      if (trapStack[trapStack.length - 1] !== entry) { return; }
      if (e.key === 'Escape' && onEscape) { e.stopPropagation(); e.preventDefault(); onEscape(); return; }
      if (e.key !== 'Tab') { return; }
      var f = focusables();
      if (!f.length) { e.preventDefault(); return; }
      var first = f[0], last = f[f.length - 1], cur = document.activeElement;
      if (e.shiftKey && (cur === first || !container.contains(cur))) { e.preventDefault(); last.focus(); }
      else if (!e.shiftKey && (cur === last || !container.contains(cur))) { e.preventDefault(); first.focus(); }
    }
    document.addEventListener('keydown', onKey, true);
    return function release() {
      document.removeEventListener('keydown', onKey, true);
      trapStack = trapStack.filter(function (x) { return x !== entry; });
      try { if (prev && prev.focus && document.contains(prev)) { prev.focus({ preventScroll: true }); } } catch (e) { /* ignore */ }
    };
  };

  /* Generic modal. Returns { el, close(result) } and a promise that resolves with the result. */
  AC.ui.modal = function (html, opts) {
    opts = opts || {};
    var back = document.createElement('div');
    back.className = 'ac-modal-back';
    back.innerHTML = '<div class="ac-modal' + (opts.wide ? ' wide' : '') + '" role="dialog" aria-modal="true" ' + (opts.label ? 'aria-label="' + AC.esc(opts.label) + '"' : '') + '>' + html + '</div>';
    document.body.appendChild(back);
    var dlg = back.firstChild, resolve, done = false;
    var promise = new Promise(function (r) { resolve = r; });
    var release = AC.ui.trapFocus(dlg, function () { if (opts.dismissible !== false) { close(opts.escapeValue); } });
    function close(v) {
      if (done) { return; }
      done = true; release(); back.remove(); resolve(v);
    }
    back.addEventListener('mousedown', function (e) { if (e.target === back && opts.dismissible !== false) { close(opts.escapeValue); } });
    var first = AC.$(opts.focus || '[data-autofocus]', dlg) || AC.$('button, input', dlg);
    if (first) { setTimeout(function () { first.focus({ preventScroll: true }); }, 30); }
    return { el: dlg, close: close, promise: promise };
  };

  AC.ui.confirm = function (o) {
    var body = o.html || ('<p>' + AC.esc(o.message || '') + '</p>');
    var m = AC.ui.modal(
      '<div class="ac-modal-head"><h3>' + AC.esc(o.title || 'Are you sure?') + '</h3></div>' +
      '<div class="ac-modal-body">' + body + '</div>' +
      '<div class="ac-modal-foot"><button type="button" class="ac-btn ac-btn-ghost" data-v="0">' + AC.esc(o.cancelText || 'Cancel') + '</button>' +
      '<button type="button" class="ac-btn ' + (o.danger ? 'ac-btn-solid-danger' : 'ac-btn-primary') + '" data-v="1" data-autofocus>' + AC.esc(o.confirmText || 'Confirm') + '</button></div>',
      { label: o.title, escapeValue: false }
    );
    AC.$$('[data-v]', m.el).forEach(function (b) { b.addEventListener('click', function () { m.close(b.getAttribute('data-v') === '1'); }); });
    return m.promise;
  };

  AC.ui.prompt = function (o) {
    var m = AC.ui.modal(
      '<form><div class="ac-modal-head"><h3>' + AC.esc(o.title) + '</h3></div>' +
      '<div class="ac-modal-body"><label class="ac-label" for="ac-prompt-in">' + AC.esc(o.label || '') + '</label>' +
      '<input class="ac-input" id="ac-prompt-in" data-autofocus maxlength="' + (o.maxlength || 200) + '" placeholder="' + AC.esc(o.placeholder || '') + '" value="' + AC.esc(o.value || '') + '" autocomplete="off">' +
      '<div class="ac-error" hidden></div></div>' +
      '<div class="ac-modal-foot"><button type="button" class="ac-btn ac-btn-ghost" data-cancel>Cancel</button><button type="submit" class="ac-btn ac-btn-primary">' + AC.esc(o.confirmText || 'Save') + '</button></div></form>',
      { label: o.title, escapeValue: null }
    );
    var form = AC.$('form', m.el), input = AC.$('input', m.el), err = AC.$('.ac-error', m.el);
    AC.$('[data-cancel]', m.el).addEventListener('click', function () { m.close(null); });
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var v = input.value.trim();
      var problem = o.validate ? o.validate(v) : (v ? '' : 'Please enter a value.');
      if (problem) { err.textContent = problem; err.hidden = false; input.setAttribute('aria-invalid', 'true'); input.focus(); return; }
      m.close(v);
    });
    return m.promise;
  };

  /* Small popover menu anchored to a button. items: [{label, icon, danger, disabled, hint, onClick}] | '-' */
  var openMenu = null;
  AC.ui.menu = function (anchor, items) {
    AC.ui.closeMenu();
    var el = document.createElement('div');
    el.className = 'ac-menu'; el.setAttribute('role', 'menu');
    el.innerHTML = items.map(function (it, i) {
      if (it === '-') { return '<hr>'; }
      return '<button type="button" role="menuitem" data-i="' + i + '"' + (it.disabled ? ' disabled' : '') + (it.hint ? ' title="' + AC.esc(it.hint) + '"' : '') + ' class="' + (it.danger ? 'danger' : '') + '">' + (it.icon ? AC.icon(it.icon, 16) : '') + '<span>' + AC.esc(it.label) + '</span></button>';
    }).join('');
    document.body.appendChild(el);
    var r = anchor.getBoundingClientRect(), mw = el.offsetWidth, mh = el.offsetHeight;
    var left = Math.min(Math.max(8, r.right - mw), window.innerWidth - mw - 8);
    var top = r.bottom + 6; if (top + mh > window.innerHeight - 8) { top = Math.max(8, r.top - mh - 6); }
    el.style.left = left + 'px'; el.style.top = top + 'px';
    el.addEventListener('click', function (e) {
      var b = e.target.closest('button[data-i]'); if (!b || b.disabled) { return; }
      var it = items[+b.getAttribute('data-i')]; AC.ui.closeMenu(); if (it && it.onClick) { it.onClick(); }
    });
    var first = AC.$('button:not([disabled])', el); if (first) { first.focus(); }
    function onDoc(e) { if (!el.contains(e.target) && e.target !== anchor && !anchor.contains(e.target)) { AC.ui.closeMenu(); } }
    function onKey(e) {
      if (e.key === 'Escape') { AC.ui.closeMenu(); try { anchor.focus(); } catch (x) { /* ignore */ } }
      else if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
        e.preventDefault();
        var bs = AC.$$('button:not([disabled])', el), i = bs.indexOf(document.activeElement);
        bs[(i + (e.key === 'ArrowDown' ? 1 : -1) + bs.length) % bs.length].focus();
      }
    }
    setTimeout(function () { document.addEventListener('mousedown', onDoc, true); document.addEventListener('keydown', onKey, true); }, 0);
    window.addEventListener('scroll', AC.ui.closeMenu, { once: true, capture: true });
    openMenu = { el: el, cleanup: function () { document.removeEventListener('mousedown', onDoc, true); document.removeEventListener('keydown', onKey, true); el.remove(); } };
  };
  AC.ui.closeMenu = function () { if (openMenu) { openMenu.cleanup(); openMenu = null; } };

  /* Banner (top of the page) */
  AC.ui.banner = function (id, o) {
    var host = AC.$('#ac-banners');
    if (!host) { return; }
    var old = AC.$('[data-banner="' + id + '"]', host);
    if (old) { old.remove(); }
    if (!o) { return; }
    var el = document.createElement('div');
    el.className = 'ac-banner ' + (o.kind || '');
    el.setAttribute('data-banner', id);
    el.setAttribute('role', o.kind === 'danger' ? 'alert' : 'status');
    el.innerHTML = AC.icon(o.kind === 'danger' ? 'alert' : 'info', 20) + '<div><h3>' + AC.esc(o.title) + '</h3>' + o.html + '</div>';
    host.appendChild(el);
    if (o.onMount) { o.onMount(el); }
  };

  /* ======================================================================
     Page boot
     ====================================================================== */
  AC.reload = async function (opts) {
    opts = opts || {};
    try {
      await AC.data.fetchAll();
    } catch (e) {
      console.error('Alert Center: load failed', e);
      AC.ui.banner('load', { kind: 'danger', title: 'Could not load alerts', html: '<p>' + AC.esc(AC.explain(e)) + '</p><div class="ac-banner-actions"><button type="button" class="ac-btn ac-btn-secondary ac-btn-sm" id="ac-retry">Try again</button></div>', onMount: function (el) { AC.$('#ac-retry', el).addEventListener('click', function () { AC.reload(); }); } });
      AC.list.renderAll(true);
      return false;
    }
    AC.ui.banner('load', null);
    AC.renderSchemaBanner();
    AC.list.renderAll();
    return true;
  };

  AC.renderSchemaBanner = function () {
    var s = AC.state.schema;
    if (s.ready && s.rpc) { AC.ui.banner('schema', null); return; }
    if (!s.ready) {
      AC.ui.banner('schema', {
        kind: '', title: 'One-time database upgrade needed for homepage pop-ups',
        html: '<p>Your existing alerts keep working. To unlock homepage pop-ups, priorities, exact scheduling and the draft / archive workflow, run <code>ADD-HOMEPAGE-POPUP-ALERTS.sql</code> once in the Supabase SQL Editor, then reload this page.</p>' +
              '<p>Until then you can still create and manage student-portal alerts.</p>' +
              '<div class="ac-banner-actions"><a class="ac-btn ac-btn-secondary ac-btn-sm" href="HOMEPAGE-POPUP-ALERTS-SETUP.md" target="_blank" rel="noopener">Open setup guide</a><button type="button" class="ac-btn ac-btn-ghost ac-btn-sm" id="ac-recheck">I ran it - check again</button></div>',
        onMount: function (el) { AC.$('#ac-recheck', el).addEventListener('click', function () { AC.reload(); }); }
      });
    } else {
      AC.ui.banner('schema', { kind: '', title: 'Homepage delivery function is missing', html: '<p>The upgrade was only partly applied: <code>get_site_alerts</code> was not found, so homepage pop-ups will not appear for visitors. Run <code>ADD-HOMEPAGE-POPUP-ALERTS.sql</code> again (it is safe to re-run).</p>' });
    }
  };

  AC.init = async function () {
    AC.readUser();
    var u = AC.state.user;
    if (!u.isAdmin || !u.email) { location.replace('login.html'); return; }
    if (!AC.state.perms.manage) {
      AC.$('#ac-denied').hidden = false;
      AC.$('#ac-denied-msg').textContent = 'Your account does not have permission to manage alerts. Ask the main administrator to enable "Manage Alerts" for you.';
      return;
    }
    AC.$('#ac-app').hidden = false;
    var role = AC.state.perms.main ? 'Main administrator' : (AC.state.perms.publish ? 'Alert publisher' : 'Alert editor');
    var roleEl = AC.$('#ac-role');
    roleEl.innerHTML = AC.icon('lock', 13) + ' ' + AC.esc(role);
    roleEl.title = AC.state.perms.publish ? 'You can create, publish, schedule and delete alerts.' : 'You can create and edit drafts, pause and archive. Publishing needs the "Publish Alerts" permission.';

    function tick() { var el = AC.$('#ac-clock'); if (el) { el.textContent = 'Armenia time ' + new Intl.DateTimeFormat('en-GB', { timeZone: AC.TZ, hour: '2-digit', minute: '2-digit', hourCycle: 'h23' }).format(new Date()); } }
    tick(); setInterval(tick, 20000);

    AC.state.db = (typeof initSupabase === 'function') ? initSupabase() : null;
    if (!AC.state.db) {
      AC.ui.banner('db', { kind: 'danger', title: 'Database connection unavailable', html: '<p>The Supabase library did not load. Refresh the page; if it keeps happening, check your internet connection.</p>' });
      return;
    }
    AC.list.bind(); AC.composer.bind(); AC.extras.bind();
    AC.list.restoreUi();
    await AC.reload();

    // keep statuses fresh (scheduled -> live -> expired) and pick up changes from other admins
    setInterval(function () {
      if (document.hidden || AC.composer.isOpen() || document.querySelector('.ac-modal-back, .ac-menu')) { return; }
      AC.reload();
    }, 60000);
  };

})(window);
