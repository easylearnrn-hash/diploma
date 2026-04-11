/**
 * ACNHS Portal Alert Engine
 * Reads portal_alerts from Supabase and shows modals/banners/toasts.
 *
 * Flat DB columns used:
 *   target_type ('all'|'group'|'individual')
 *   target_group, target_student_ids JSONB
 *   display_mode ('every_load'|'once_ever'|'times_limit'|'daily'|'daily_first_login')
 *   max_displays
 *   date_rule_type ('always'|'date_range'|'monthly_range'|'custom_dates')
 *   start_date, end_date, monthly_start_day, monthly_end_day, custom_dates
 *   display_position ('modal'|'banner_top'|'banner_bottom'|'toast_tr'|'toast_tl'|'toast_br'|'toast_bl')
 *   link_url, link_label, requires_response, response_type, yes_label, no_label
 *   trigger_rules JSONB -> { pages_whitelist: [] }
 *   frequency_rules JSONB -> { cap_type, max_displays }
 *   schedule_rules JSONB -> { recurrence_type, start_datetime, end_datetime }
 */
(function () {
  'use strict';

  var DISMISS_KEY = 'acnhs_dismissed_';
  var SHOWN_KEY   = 'acnhs_shown_';

  var db      = null;
  var student = null;
  var busy    = false;
  var bootFired = false;  // guard: loadStudentThenRun must only call run() once

  // Tracks every_load alerts dismissed in the current page view only.
  // Resets on each real page refresh (JS re-runs), so alert re-shows on next load.
  var dismissedThisLoad = {};

  /* ── boot ── */
  function boot() {
    if (typeof initSupabase === 'function') { db = initSupabase(); }
    if (!db) { setTimeout(boot, 500); return; }
    loadStudentThenRun(0);
  }

  /* Try sessionStorage first; if not there yet, query Supabase directly */
  function fireRun(label) {
    if (bootFired) return;
    bootFired = true;
    console.log('Alerts: ' + label);
    run();
  }

  async function loadStudentThenRun(attempts) {
    student = readStudent();
    if (student) {
      fireRun('student from storage — ' + (student.full_name || student.id) +
        ' | group=' + (student['group'] || student.group_name || student.enrollment_group || student.program || 'none'));
      return;
    }
    // Not in storage yet — try to load directly from Supabase using stored IDs
    var recordId = sessionStorage.getItem('studentRecordId') || localStorage.getItem('studentRecordId');
    if (recordId && db) {
      try {
        var res = await db.from('students').select('id,student_id,full_name,email,program,group,group_name,enrollment_group').eq('id', recordId).maybeSingle();
        if (res.data) {
          student = {
            id:               res.data.id,
            student_id:       res.data.student_id || null,
            full_name:        res.data.full_name   || null,
            email:            res.data.email       || null,
            enrollment_group: res.data.enrollment_group || null,
            group_name:       res.data.group_name  || null,
            group:            res.data['group']    || null,
            program:          res.data.program     || null
          };
          fireRun('student from DB — ' + (student.full_name || student.id) +
            ' | group=' + (student['group'] || student.group_name || student.program || 'none'));
          return;
        }
      } catch(e) { console.warn('Alerts: DB student lookup failed', e); }
    }
    if (attempts < 20) {
      // Still waiting for profile load — retry
      setTimeout(function() { loadStudentThenRun(attempts + 1); }, 500);
    } else {
      fireRun('no student found after 10s — running as anon');
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    setTimeout(boot, 0);
  }

  /* ── read student from session ── */
  function readStudent() {
    var keys = ['hubStudentData', 'studentData', 'currentStudent'];
    for (var i = 0; i < keys.length; i++) {
      try {
        var raw = sessionStorage.getItem(keys[i]) || localStorage.getItem(keys[i]);
        if (!raw) continue;
        var p = JSON.parse(raw);
        var id = p.id || p.student_id_pk;
        if (id) {
          return {
            id:               id,
            student_id:       p.student_id       || p.studentId       || null,
            full_name:        p.full_name         || p.fullName         || null,
            email:            p.email             || null,
            // Keep ALL group fields so matchesAudience can check any of them
            // Note: DB column is literally named "group" (reserved word) - stored as p.group
            enrollment_group: p.enrollment_group  || p.enrollmentGroup  || null,
            group_name:       p.group_name        || p.groupName        || null,
            group:            p['group']          || null,
            program:          p.program           || null
          };
        }
      } catch(e) {}
    }
    return null;
  }

  /* ── main run loop ── */
  async function run() {
    if (busy) return;
    var res = await db.from('portal_alerts').select('*').eq('is_active', true).order('created_at', { ascending: false });
    if (res.error) { console.error('Alerts fetch error:', res.error.message); return; }
    var alerts = res.data || [];
    console.log('Alerts: ' + alerts.length + ' active in DB');
    for (var i = 0; i < alerts.length; i++) {
      var a = alerts[i];
      var tr = safeJson(a.trigger_rules);

      if (tr.on_click_selector) {
        // For click-triggered alerts: only skip if page/audience/date don't match.
        // Frequency cap is checked at click-time inside setupClickListener, not here —
        // otherwise once_ever would prevent the listener from ever being registered.
        if (!matchesPage(a))     { console.log('skip (click) "' + a.title + '": page mismatch'); continue; }
        if (!matchesAudience(a)) { console.log('skip (click) "' + a.title + '": audience mismatch'); continue; }
        if (!inDateWindow(a))    { console.log('skip (click) "' + a.title + '": outside date window'); continue; }
        setupClickListener(a, tr.on_click_selector);
      } else {
        var reason = shouldBlock(a);
        if (reason) { console.log('skip "' + a.title + '": ' + reason); continue; }
        await show(a);
        return; // standard alerts only show one at a time to prevent modal stacking
      }
    }
  }

  /* ── should we block this alert? ── */
  function shouldBlock(a) {
    if (!matchesPage(a))     return 'page mismatch';
    if (!matchesAudience(a)) return 'audience mismatch';
    if (!inDateWindow(a))    return 'outside date window';

    var freq = safeJson(a.frequency_rules);
    // Default to every_load for click-triggered alerts, once_ever for page-load alerts
    var tr = safeJson(a.trigger_rules);
    var defaultCap = tr.on_click_selector ? 'every_load' : 'once_ever';
    var cap  = freq.cap_type || a.display_mode || defaultCap;

    // Session dismissing blocks re-show (except every_load — cleared at click time)
    if (cap !== 'every_load' && sessionStorage.getItem(DISMISS_KEY + a.id) === '1') return 'dismissed this session';

    // every_load: show once per page load, but not again after user closes it this view
    if (cap === 'every_load') return dismissedThisLoad[a.id] ? 'dismissed this page load' : null;

    var shown = getShownData(a.id);
    console.log('Alerts: cap=' + cap + ' shown=' + shown.count + ' today=' + shown.today + ' for "' + a.title + '"');

    if (cap === 'once_ever' && shown.count > 0)
      return 'already shown (once_ever)';
    if ((cap === 'daily' || cap === 'daily_first_login') && shown.today)
      return 'already shown today';
    if (cap === 'times_limit') {
      var max = (freq.max_displays != null) ? freq.max_displays : (a.max_displays || 1);
      if (shown.count >= max) return 'shown ' + shown.count + '/' + max;
    }
    return null;
  }

  function matchesPage(a) {
    var tr    = safeJson(a.trigger_rules);
    var pages = Array.isArray(tr.pages_whitelist) ? tr.pages_whitelist : [];
    if (!pages.length) return true;
    var file  = (window.location.pathname.split('/').pop() || 'index.html').toLowerCase().replace(/[?#].*/, '').replace(/\.html$/, '');
    for (var i = 0; i < pages.length; i++) {
      var p = pages[i].toLowerCase().replace(/\.html$/, '');
      if (p === file) return true;
    }
    console.log('Alerts: page mismatch — current="' + file + '" allowed=' + JSON.stringify(pages));
    return false;
  }

  function matchesAudience(a) {
    var type = a.target_type || 'all';
    if (type === 'all') return true;
    if (type === 'public') return !student; // public alerts only show to anonymous visitors (not logged-in students)
    if (!student) return false;

    if (type === 'individual') {
      var ids = a.target_student_ids || [];
      if (typeof ids === 'string') { try { ids = JSON.parse(ids); } catch(e) {} }
      return Array.isArray(ids) && ids.indexOf(student.id) !== -1;
    }

    if (type === 'group') {
      // Collect every group the student could belong to (DB has reserved col "group")
      var studentGroups = [
        student.enrollment_group,
        student.group_name,
        student['group'],
        student.program
      ].filter(Boolean).map(function(g){ return String(g).trim().toLowerCase(); });

      // Check flat target_group column
      var flat = a.target_group || '';

      // Check targeting_rules.groups array (new rule engine)
      var tr   = safeJson(a.targeting_rules);
      var ruleGroups = Array.isArray(tr.groups) ? tr.groups : (flat ? [flat] : []);

      // No group restriction set → show to everyone
      if (!ruleGroups.length && !flat) return true;

      // Student has no group data → show anyway (don't punish missing metadata)
      if (!studentGroups.length) {
        console.log('Alerts: student has no group data — showing alert anyway');
        return true;
      }

      var candidates = ruleGroups.length ? ruleGroups : [flat];
      for (var i = 0; i < candidates.length; i++) {
        var cand = String(candidates[i]).trim().toLowerCase();
        if (!cand) continue;
        if (studentGroups.indexOf(cand) !== -1) return true;
      }
      console.log('Alerts: audience mismatch — student groups=' + JSON.stringify(studentGroups) + ' required=' + JSON.stringify(candidates));
      return false;
    }
    return true;
  }

  function inDateWindow(a) {
    var sched = safeJson(a.schedule_rules);
    var rule  = sched.recurrence_type || a.date_rule_type || 'always';
    if (rule === 'always') return true;

    var today = localDate();

    if (rule === 'date_range' || rule === 'one_time') {
      var start = (sched.start_datetime || a.start_date || '').substring(0, 10);
      var end   = (sched.end_datetime   || a.end_date   || '').substring(0, 10);
      if (!start && !end) return true;
      if (start && today < start) return false;
      if (end   && today > end)   return false;
      return true;
    }
    if (rule === 'monthly_range' || rule === 'monthly') {
      var day = new Date().getDate();
      return day >= (a.monthly_start_day || 1) && day <= (a.monthly_end_day || 31);
    }
    if (rule === 'custom_dates') {
      var dates = a.custom_dates || [];
      if (typeof dates === 'string') { try { dates = JSON.parse(dates); } catch(e) {} }
      return Array.isArray(dates) && dates.indexOf(today) !== -1;
    }
    return true;
  }

  /* ── helpers ── */
  function localDate() { return new Date().toISOString().substring(0, 10); }

  function safeJson(v) {
    if (!v) return {};
    if (typeof v === 'object') return v;
    try { return JSON.parse(v); } catch(e) { return {}; }
  }

  function getShownData(id) {
    try { var r = sessionStorage.getItem(SHOWN_KEY + id); if (r) return JSON.parse(r); } catch(e) {}
    return { count: 0, today: false };
  }

  function recordShown(id) {
    var d = getShownData(id);
    d.count++; d.today = true;
    sessionStorage.setItem(SHOWN_KEY + id, JSON.stringify(d));
  }

  function markDismissed(id) {
    sessionStorage.setItem(DISMISS_KEY + id, '1');
    dismissedThisLoad[id] = true;
  }

  /* ── display ── */
  async function show(a) {
    busy = true;
    recordShown(a.id);
    var pos = a.display_position || 'modal';
    var el;
    if      (pos === 'modal')                              el = buildModal(a);
    else if (pos === 'banner_top' || pos === 'banner_bottom') el = buildBanner(a, pos);
    else                                                   el = buildToast(a, pos);
    document.body.appendChild(el);
    requestAnimationFrame(function() { el.classList.add('acnhs-show'); });

    if (student && student.id) {
      try {
        await db.from('portal_alert_impressions').upsert({
          alert_id: a.id, student_id: student.id,
          shown_date_local: localDate(),
          page_path: window.location.pathname.split('/').pop()
        }, { onConflict: 'alert_id,student_id,shown_date_local', ignoreDuplicates: true });
      } catch(e) {}
    }
  }

  function dismiss(a, el) {
    markDismissed(a.id);
    el.classList.remove('acnhs-show');
    setTimeout(function() {
      if (el.parentNode) el.parentNode.removeChild(el);
      busy = false; run();
    }, 300);
  }

  var _clickAlerts = {};
  function setupClickListener(a, sel) {
      if (_clickAlerts[a.id]) return;
      _clickAlerts[a.id] = true;
      // Normalise: trim each selector in the comma-separated list
      var normSel = sel.split(',').map(function(s){ return s.trim(); }).filter(Boolean).join(', ');
      console.log('Alerts: click listener attached for "' + a.title + '" on selector: ' + normSel);
      document.addEventListener('click', function(e) {
          var target = e.target.closest(normSel);
          if (!target) return;

          var freq = safeJson(a.frequency_rules);
          var cap  = freq.cap_type || a.display_mode || 'once_ever';

          // For every_load click alerts: clear dismiss so it always re-shows on click
          if (cap === 'every_load') {
            sessionStorage.removeItem(DISMISS_KEY + a.id);
            sessionStorage.removeItem(SHOWN_KEY + a.id);
          }

          // Full frequency/dismiss check at click-time
          var reason = shouldBlock(a);
          if (!reason) {
              show(a);
          } else {
              console.log('Alerts: click blocked for "' + a.title + '": ' + reason);
          }
      });
  }

  /* ── colours / icons ── */
  var COL = { info:'#c9a84c', success:'#2dd4bf', warn:'#d4b56a', critical:'#ef4444' };
  var ICO = {
    info: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>',
    success: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>',
    warn: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>',
    critical: '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>'
  };

  function personalise(t) {
    if (!t) return '';
    var now = new Date();
    var mo  = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return t
      .replace(/\{student_name\}/g, (student&&student.full_name)        || 'Student')
      .replace(/\{student_id\}/g,   (student&&student.student_id)       || 'N/A')
      .replace(/\{email\}/g,        (student&&student.email)            || '')
      .replace(/\{group\}/g,        (student&&student.enrollment_group) || 'N/A')
      .replace(/\{month\}/g, mo[now.getMonth()])
      .replace(/\{year\}/g,  String(now.getFullYear()))
      .replace(/\{date\}/g,  now.toLocaleDateString('en-US'));
  }

  function esc(s) {
    return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
  }

  /* Aggressive cleanup for rich-text artifacts to ensure perfect professional spacing */
  function cleanHtml(html) {
    if (!html) return '';
    // If content has no block-level HTML tags, treat as plain text and wrap paragraphs
    var hasBlockTags = /<(p|div|br|ul|ol|li|h[1-6])\b/i.test(html);
    if (!hasBlockTags) {
      // Plain text: split on newlines, wrap non-empty lines in <p>
      return html
        .replace(/&nbsp;/gi, ' ')
        .split(/\n+/)
        .map(function(s){ return s.trim(); })
        .filter(Boolean)
        .map(function(s){ return '<p>' + s + '</p>'; })
        .join('');
    }
    return html
      .replace(/&nbsp;/gi, ' ')                     // Normalize non-breaking spaces
      .replace(/\s*style="[^"]*"/gi, '')            // Strip chaotic inline CSS
      .replace(/<div>/gi, '<p>')                    // Convert divs to paragraphs
      .replace(/<\/div>/gi, '</p>')
      .replace(/<p>(\s)*<\/p>/gi, '')               // Remove completely empty paragraphs
      .replace(/<span>(\s)*<\/span>/gi, '')         // Remove completely empty spans
      .replace(/(<br\s*\/?>\s*){2,}/gi, '</p><p>')  // Transform double breaks into proper paragraphs
      .replace(/<p>\s*<br\s*\/?>/gi, '<p>')         // Trim breaks at start of paragraphs
      .replace(/<br\s*\/?>\s*<\/p>/gi, '</p>')      // Trim breaks at end of paragraphs
      .replace(/(<\/p>)\s*(<p>)/gi, '$1$2')         // Close gaps between paragraphs
      .trim();
  }

  function on(el, sel, evt, fn) {
    var nodes = el.querySelectorAll(sel);
    for (var i = 0; i < nodes.length; i++) nodes[i].addEventListener(evt, fn);
  }

  function wire(el, a) {
    on(el, '[data-dismiss]', 'click', function() { dismiss(a, el); });
    if (el.classList.contains('acnhs-overlay')) {
      el.addEventListener('click', function(ev) { if (ev.target === el) dismiss(a, el); });
    }
    var yes = el.querySelector('.acnhs-btn-yes');
    var no  = el.querySelector('.acnhs-btn-no');
    if (yes) yes.addEventListener('click', function() { recordResp(a,'yes'); dismiss(a,el); });
    if (no)  no.addEventListener( 'click', function() { recordResp(a,'no');  dismiss(a,el); });
  }

  async function recordResp(a, ans) {
    if (!student||!student.id) return;
    try {
      await db.from('portal_alert_responses').insert({
        alert_id: a.id, student_id: student.id, answer: ans,
        page_path: window.location.pathname.split('/').pop()
      });
    } catch(e) {}
  }
  /* ── builders ── */
  function buildModal(a) {
    var c = COL[a.severity]||COL.info, ic = ICO[a.severity]||ICO.info;
    var severityLabel = { info:'Notice', success:'Update', warn:'Notice', critical:'Alert' };
    var eyebrow = (severityLabel[a.severity] || 'Notice').toUpperCase();

    var linkH = a.link_url
      ? '<a href="'+esc(a.link_url)+'" target="_blank" rel="noopener" class="acnhs-link-btn" style="border-color:'+c+';color:'+c+'">'+esc(a.link_label||'Learn More')+' ↗</a>'
      : '';
    var yesno = (a.requires_response && a.response_type === 'yes_no')
      ? '<button class="acnhs-btn-yes" style="background:'+c+';box-shadow:0 4px 12px '+c+'40;color:#04111f">'+esc(a.yes_label||'Yes')+'</button><button class="acnhs-btn-no">'+esc(a.no_label||'No')+'</button>'
      : '<button class="acnhs-btn-dismiss" data-dismiss style="border-color:'+c+';color:'+c+'">I Understand</button>';

    var el = document.createElement('div');
    el.className = 'acnhs-overlay'; el.dataset.alertId = a.id;
    el.innerHTML =
      '<div class="acnhs-box">'
      + '<div class="acnhs-top-bar" style="background:'+c+'"></div>'
      + '<button class="acnhs-close" data-dismiss aria-label="Close"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg></button>'
      + '<div class="acnhs-header">'
        + '<div class="acnhs-icon-ring" style="border-color:'+c+'22;background:'+c+'12;"><span class="acnhs-icon" style="color:'+c+'">'+ic+'</span></div>'
        + '<div>'
          + '<div class="acnhs-eyebrow" style="color:'+c+'">◆&nbsp;&nbsp;'+eyebrow+'&nbsp;&nbsp;◆</div>'
          + '<div class="acnhs-title">'+esc(personalise(a.title))+'</div>'
        + '</div>'
      + '</div>'
      + '<div class="acnhs-divider"></div>'
      + '<div class="acnhs-body">'+cleanHtml(personalise(a.message_html))+'</div>'
      + '<div class="acnhs-footer">'+linkH+yesno+'</div>'
      + '</div>';
    wire(el, a); injectCSS(); return el;
  }

  function buildBanner(a, pos) {
    var c = COL[a.severity]||COL.info, ic = ICO[a.severity]||ICO.info;
    var linkH = a.link_url
      ? '<a href="'+esc(a.link_url)+'" target="_blank" rel="noopener" style="color:'+c+';font-weight:600;margin-left:12px;text-decoration:underline">'+esc(a.link_label||'Learn More')+' ↗</a>'
      : '';
    var el = document.createElement('div');
    el.className = 'acnhs-banner acnhs-banner-'+(pos==='banner_top'?'top':'bottom');
    el.style.borderLeftColor = c; el.dataset.alertId = a.id;
    el.innerHTML = '<span class="acnhs-banner-icon" style="color:'+c+';display:flex">'+ic+'</span>'
      + '<span class="acnhs-banner-text">'+esc(personalise(a.title))+'</span>'
      + linkH
      + '<button class="acnhs-close" data-dismiss><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>';
    wire(el, a); injectCSS(); return el;
  }

  function buildToast(a, pos) {
    var c = COL[a.severity]||COL.info, ic = ICO[a.severity]||ICO.info;
    var corners = { toast_tr:'top:80px;right:20px', toast_tl:'top:80px;left:20px', toast_br:'bottom:20px;right:20px', toast_bl:'bottom:20px;left:20px' };
    var linkH = a.link_url
      ? '<a href="'+esc(a.link_url)+'" target="_blank" rel="noopener" style="color:'+c+';font-size:13px;font-weight:600;text-decoration:none;display:inline-block;margin-top:8px">'+esc(a.link_label||'Learn More')+' ↗</a>'
      : '';
    var el = document.createElement('div');
    el.className = 'acnhs-toast'; el.dataset.alertId = a.id;
    el.style.cssText += ';' + (corners[pos]||corners.toast_tr) + ';border-left:4px solid '+c;
    el.innerHTML = '<div style="display:flex;align-items:flex-start;gap:12px">'
      + '<span style="color:'+c+';display:flex;margin-top:2px">'+ic+'</span>'
      + '<div style="flex:1"><div style="font-family:\'Playfair Display\',Georgia,serif;font-weight:600;font-size:16px;line-height:1.2;margin-bottom:6px;color:'+c+'">'+esc(personalise(a.title))+'</div><div style="font-size:13px;line-height:1.5;color:#b8b0a0">'+cleanHtml(personalise(a.message_html))+'</div>'+linkH+'</div>'
      + '<button data-dismiss class="acnhs-close" style="position:static;margin-left:8px"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>'
      + '</div>';
    wire(el, a); injectCSS(); return el;
  }
  /* ── css ── */
  var _css = false;
  function injectCSS() {
    if (_css) return; _css = true;
    var s = document.createElement('style'); s.id = 'acnhs-alert-css';
    s.textContent =
      /* ── Overlay backdrop ── */
      '.acnhs-overlay{position:fixed;inset:0;z-index:99999;background:rgba(4,17,31,.88);backdrop-filter:blur(8px);-webkit-backdrop-filter:blur(8px);display:flex;align-items:center;justify-content:center;opacity:0;transition:opacity .35s ease;padding:24px;box-sizing:border-box}'
      +'.acnhs-overlay.acnhs-show{opacity:1}'
      /* ── Modal box ── */
      +'.acnhs-box{background:linear-gradient(160deg,#071b30 0%,#04111f 100%);color:#f0ece3;border:1px solid rgba(201,168,76,.22);border-radius:18px;max-width:540px;width:100%;box-shadow:0 40px 80px -16px rgba(0,0,0,.85),0 0 0 1px rgba(255,255,255,.03);position:relative;overflow:hidden;transform:translateY(18px) scale(0.97);transition:transform .4s cubic-bezier(0.16,1,0.3,1),opacity .35s ease;font-family:"Inter",system-ui,sans-serif}'
      +'.acnhs-overlay.acnhs-show .acnhs-box{transform:translateY(0) scale(1)}'
      /* ── Gold top accent bar ── */
      +'.acnhs-top-bar{height:3px;background:#c9a84c;width:100%;position:absolute;top:0;left:0;right:0}'
      /* ── Close button ── */
      +'.acnhs-close{position:absolute;top:18px;right:18px;background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.07);width:30px;height:30px;border-radius:50%;color:#7a7267;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:background .2s,color .2s,border-color .2s;padding:0;z-index:1}'
      +'.acnhs-close:hover{background:rgba(201,168,76,.1);color:#c9a84c;border-color:rgba(201,168,76,.3)}'
      /* ── Header ── */
      +'.acnhs-header{display:flex;align-items:center;gap:18px;padding:36px 32px 24px}'
      +'.acnhs-icon-ring{width:54px;height:54px;border-radius:50%;border:1.5px solid;display:flex;align-items:center;justify-content:center;flex-shrink:0}'
      +'.acnhs-icon{display:flex;align-items:center;justify-content:center}'
      +'.acnhs-eyebrow{font-size:10px;font-weight:700;letter-spacing:2.5px;text-transform:uppercase;margin-bottom:6px;opacity:.9}'
      +'.acnhs-title{font-family:"Playfair Display",Georgia,serif;font-size:20px;font-weight:700;line-height:1.25;letter-spacing:-.01em;color:#f0ece3;margin:0}'
      /* ── Divider ── */
      +'.acnhs-divider{height:1px;background:rgba(255,255,255,.07);margin:0 32px}'
      /* ── Body ── */
      +'.acnhs-body{padding:22px 32px 24px;font-size:14.5px;line-height:1.75;color:#b8b0a0}'
      +'.acnhs-body p{margin:0 0 14px}'
      +'.acnhs-body p:last-child{margin-bottom:0}'
      +'.acnhs-body ul,.acnhs-body ol{margin:0 0 14px;padding-left:22px}'
      +'.acnhs-body li{margin-bottom:6px}'
      +'.acnhs-body strong,.acnhs-body b{color:#e8e3d8;font-weight:600}'
      +'.acnhs-body a{color:#c9a84c;text-decoration:none;font-weight:500;border-bottom:1px solid rgba(201,168,76,.35);transition:all .2s}'
      +'.acnhs-body a:hover{color:#d4b56a;border-bottom-color:#d4b56a}'
      /* ── Footer ── */
      +'.acnhs-footer{padding:0 32px 32px;display:flex;gap:12px;justify-content:center}'
      +'.acnhs-btn-dismiss{padding:13px 36px;border-radius:10px;font-size:13px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;cursor:pointer;border:1.5px solid;background:transparent;transition:background .2s,box-shadow .2s,transform .15s;font-family:"Inter",system-ui,sans-serif}'
      +'.acnhs-btn-dismiss:hover{background:rgba(201,168,76,.1);box-shadow:0 4px 18px rgba(201,168,76,.15);transform:translateY(-1px)}'
      +'.acnhs-btn-dismiss:active{transform:translateY(0)}'
      +'.acnhs-link-btn{display:inline-flex;align-items:center;gap:6px;padding:13px 28px;border-radius:10px;font-size:13px;font-weight:700;letter-spacing:.6px;text-transform:uppercase;text-decoration:none;border:1.5px solid;background:transparent;transition:background .2s,opacity .2s;font-family:"Inter",system-ui,sans-serif}'
      +'.acnhs-link-btn:hover{background:rgba(201,168,76,.08);opacity:.9}'
      +'.acnhs-btn-yes,.acnhs-btn-no{flex:1;padding:13px 0;border-radius:10px;font-size:13px;font-weight:700;cursor:pointer;transition:all .2s;text-align:center;border:none;letter-spacing:.6px;text-transform:uppercase;font-family:"Inter",system-ui,sans-serif}'
      +'.acnhs-btn-yes:hover{filter:brightness(1.08);transform:translateY(-1px)}'
      +'.acnhs-btn-no{background:rgba(255,255,255,.04);color:#b8b0a0;border:1px solid rgba(255,255,255,.08)}'
      +'.acnhs-btn-no:hover{background:rgba(255,255,255,.08);color:#f0ece3;border-color:rgba(255,255,255,.15)}'
      /* ── Banner ── */
      +'.acnhs-banner{position:fixed;left:0;right:0;z-index:99999;background:linear-gradient(90deg,#071b30,#0a1728);color:#f0ece3;border-top:1px solid rgba(201,168,76,.15);border-bottom:1px solid rgba(201,168,76,.15);display:flex;align-items:center;gap:16px;padding:16px 28px;font-size:14.5px;font-family:"Inter",system-ui,sans-serif;box-shadow:0 10px 30px rgba(0,0,0,.5);opacity:0;transition:opacity .4s,transform .4s}'
      +'.acnhs-banner-top{top:0;transform:translateY(-100%);border-top:none}'
      +'.acnhs-banner-bottom{bottom:0;transform:translateY(100%);border-bottom:none}'
      +'.acnhs-banner.acnhs-show{opacity:1;transform:translateY(0)}'
      +'.acnhs-banner-text{flex:1;font-weight:500}'
      /* ── Toast ── */
      +'.acnhs-toast{position:fixed;z-index:99999;background:linear-gradient(145deg,#071b30,#04111f);color:#f0ece3;border:1px solid rgba(201,168,76,.18);border-radius:14px;padding:20px 22px;max-width:360px;width:calc(100% - 40px);box-shadow:0 20px 40px rgba(0,0,0,.6);opacity:0;transform:translateX(20px);transition:all .4s cubic-bezier(0.16,1,0.3,1);font-family:"Inter",system-ui,sans-serif}'
      +'.acnhs-toast.acnhs-show{opacity:1;transform:translateX(0)}';
    document.head.appendChild(s);
  }

  /* ── public API ── */
  window.ACNHSAlerts = {
    reset: function() {
      var rem = [];
      for (var i = sessionStorage.length - 1; i >= 0; i--) {
        var k = sessionStorage.key(i);
        if (k && (k.indexOf(DISMISS_KEY)===0 || k.indexOf(SHOWN_KEY)===0)) {
          sessionStorage.removeItem(k); rem.push(k);
        }
      }
      busy = false;
      console.log('ACNHSAlerts.reset(): cleared ' + rem.length + ' key(s)');
      run();
    },
    debug: async function() {
      if (!db) { console.warn('Supabase not ready'); return; }
      var res = await db.from('portal_alerts').select('*').eq('is_active', true);
      var list = res.data || [];
      console.group('ACNHSAlerts.debug() — ' + list.length + ' active');
      console.log('page:', window.location.pathname.split('/').pop()||'index.html');
      console.log('student:', student ? student.id : 'anon');
      for (var i = 0; i < list.length; i++) {
        var a = list[i], b = shouldBlock(a);
        var tr = safeJson(a.trigger_rules);
        console.group((b?'🚫':'✅') + ' "' + a.title + '"');
        console.log('target_type:', a.target_type, ' display_mode:', a.display_mode, ' date_rule_type:', a.date_rule_type);
        console.log('pages_whitelist:', tr.pages_whitelist||'(all)');
        console.log('result:', b || 'WILL SHOW');
        console.groupEnd();
      }
      console.groupEnd();
    }
  };

})();
