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

  /* ── boot ── */
  function boot() {
    if (typeof initSupabase === 'function') { db = initSupabase(); }
    if (!db) { setTimeout(boot, 500); return; }
    // Wait for student profile to be saved to sessionStorage (fetchStudentProfile is async)
    waitForStudent(0);
  }

  function waitForStudent(attempts) {
    student = readStudent();
    if (student || attempts >= 20) {
      // Student found (or gave up after 10s) — run
      console.log('Alerts: ready. student=' + (student ? (student.full_name || student.id) : 'anon') +
                  (student ? ' group=' + (student.group || student.group_name || student.enrollment_group || student.program || 'none') : ''));
      run();
    } else {
      // Student not in storage yet — retry in 500ms (profile is still loading)
      setTimeout(function() { waitForStudent(attempts + 1); }, 500);
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
    var cap  = freq.cap_type || a.display_mode || 'once_ever';

    // 1. Session dismissing always trumps all other rules. If they clicked 'X', it stays closed until refresh.
    if (sessionStorage.getItem(DISMISS_KEY + a.id) === '1') return 'dismissed this session';

    if (cap === 'every_load') return null;

    var shown = getShownData(a.id);

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
    if (type === 'all' || type === 'public') return true;
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
        student.group,
        student.program
      ].filter(Boolean).map(function(g){ return String(g).trim().toLowerCase(); });

      // Check flat target_group column
      var flat = a.target_group || '';

      // Check targeting_rules.groups array (new rule engine)
      var tr   = safeJson(a.targeting_rules);
      var ruleGroups = Array.isArray(tr.groups) ? tr.groups : (flat ? [flat] : []);

      // No group restriction set → show to all
      if (!ruleGroups.length && !flat) return true;

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

  function markDismissed(id) { sessionStorage.setItem(DISMISS_KEY + id, '1'); }

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
        await db.from('portal_alert_impressions').insert({
          alert_id: a.id, student_id: student.id,
          shown_date_local: localDate(),
          page_path: window.location.pathname.split('/').pop()
        });
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
      console.log('Alerts: click listener attached for "' + a.title + '" on selector: ' + sel);
      document.addEventListener('click', function(e) {
          var target = e.target.closest(sel);
          if (!target) return;
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
    return html
      .replace(/&nbsp;/gi, ' ')                     // Normalize non-breaking spaces
      .replace(/\s*style="[^"]*"/gi, '')            // Strip chaotic inline CSS
      .replace(/<p>(\s)*<\/p>/gi, '')               // Remove completely empty paragraphs
      .replace(/<div>(\s)*<\/div>/gi, '')           // Remove completely empty divs
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
    var linkH = a.link_url
      ? '<div style="padding:0 32px 20px;text-align:center"><a href="'+esc(a.link_url)+'" target="_blank" rel="noopener" style="display:inline-block;padding:10px 28px;border:1.5px solid '+c+';border-radius:8px;color:'+c+';font-size:14px;font-weight:600;text-decoration:none;letter-spacing:0.03em">'+esc(a.link_label||'Learn More')+' ↗</a></div>'
      : '';
    var yesno = (a.requires_response && a.response_type === 'yes_no')
      ? '<div class="acnhs-actions"><button class="acnhs-btn-yes" style="background:'+c+';box-shadow:0 4px 12px '+c+'40;color:#04111f">'+esc(a.yes_label||'Yes')+'</button><button class="acnhs-btn-no">'+esc(a.no_label||'No')+'</button></div>'
      : '';
    var el = document.createElement('div');
    el.className = 'acnhs-overlay'; el.dataset.alertId = a.id;
    el.innerHTML = '<div class="acnhs-box" style="border-top:4px solid '+c+'">'
      + '<button class="acnhs-close" data-dismiss><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg></button>'
      + '<div class="acnhs-header"><span class="acnhs-icon" style="color:'+c+';background:'+c+'15;">'+ic+'</span><span class="acnhs-title" style="color:'+c+'">'+esc(personalise(a.title))+'</span></div>'
      + '<div class="acnhs-body">'+cleanHtml(personalise(a.message_html))+'</div>'
      + linkH + yesno + '</div>';
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
      '.acnhs-overlay{position:fixed;inset:0;z-index:99999;background:rgba(4,17,31,.88);display:flex;align-items:center;justify-content:center;opacity:0;transition:all .4s ease;padding:24px;box-sizing:border-box}'
      +'.acnhs-overlay.acnhs-show{opacity:1}'
      +'.acnhs-box{background:#0a1220;background:linear-gradient(145deg, #071b30, #04111f);color:#f0ece3;border:1px solid rgba(201,168,76,.15);border-top:none;border-radius:12px;max-width:560px;width:100%;box-shadow:0 30px 60px -12px rgba(0,0,0,.8), 0 0 0 1px rgba(255,255,255,.02);position:relative;overflow:hidden;transform:scale(0.96) translateY(12px);transition:all .45s cubic-bezier(0.16,1,0.3,1);font-family:"Inter",system-ui,-apple-system,sans-serif}'
      +'.acnhs-overlay.acnhs-show .acnhs-box{transform:scale(1) translateY(0)}'
      +'.acnhs-header{display:flex;align-items:center;gap:16px;padding:32px 36px 16px}'
      +'.acnhs-icon{width:46px;height:46px;display:flex;align-items:center;justify-content:center;border-radius:10px;flex-shrink:0}'
      +'.acnhs-title{font-family:"Playfair Display",Georgia,serif;font-size:22px;font-weight:600;line-height:1.3;letter-spacing:0.02em;margin:0}'
      +'.acnhs-body{padding:0 36px 36px;font-size:15px;line-height:1.7;color:#b8b0a0}'
      +'.acnhs-body *{line-height:1.7;margin:0}'
      +'.acnhs-body p{margin-bottom:16px}'
      +'.acnhs-body p:last-child{margin-bottom:0}'
      +'.acnhs-body ul,.acnhs-body ol{margin-bottom:16px;padding-left:24px}'
      +'.acnhs-body li{margin-bottom:8px}'
      +'.acnhs-body strong,.acnhs-body b{color:#f0ece3;font-weight:600}'
      +'.acnhs-body a{color:#c9a84c;text-decoration:none;font-weight:500;border-bottom:1px solid rgba(201,168,76,.4);transition:all .2s;padding-bottom:1px}'
      +'.acnhs-body a:hover{color:#d4b56a;border-bottom-color:#d4b56a}'
      +'.acnhs-close{position:absolute;top:20px;right:20px;background:rgba(255,255,255,.02);border:1px solid rgba(255,255,255,.05);width:32px;height:32px;border-radius:50%;color:#7a7267;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:all .2s;padding:0}'
      +'.acnhs-close:hover{background:rgba(201,168,76,.1);color:#c9a84c;border-color:rgba(201,168,76,.3)}'
      +'.acnhs-actions{display:flex;gap:12px;padding:0 36px 36px}'
      +'.acnhs-btn-yes,.acnhs-btn-no{flex:1;padding:12px 0;border-radius:8px;font-size:14px;font-weight:600;cursor:pointer;transition:all .2s;text-align:center;border:none;letter-spacing:0.03em;text-transform:uppercase}'
      +'.acnhs-btn-yes:hover{filter:brightness(1.1);transform:translateY(-1px)}'
      +'.acnhs-btn-no{background:rgba(255,255,255,.04);color:#b8b0a0;border:1px solid rgba(255,255,255,.08)}'
      +'.acnhs-btn-no:hover{background:rgba(255,255,255,.08);color:#f0ece3;border-color:rgba(255,255,255,.15)}'
      +'.acnhs-banner{position:fixed;left:0;right:0;z-index:99999;background:linear-gradient(90deg, #071b30, #0a1728);color:#f0ece3;border-top:1px solid rgba(201,168,76,.15);border-bottom:1px solid rgba(201,168,76,.15);display:flex;align-items:center;gap:16px;padding:16px 28px;font-size:14.5px;font-family:"Inter",system-ui,sans-serif;box-shadow:0 10px 30px rgba(0,0,0,.5);opacity:0;transition:opacity .4s,transform .4s}'
      +'.acnhs-banner-top{top:0;transform:translateY(-100%);border-top:none}'
      +'.acnhs-banner-bottom{bottom:0;transform:translateY(100%);border-bottom:none}'
      +'.acnhs-banner.acnhs-show{opacity:1;transform:translateY(0)}'
      +'.acnhs-banner-text{flex:1;font-weight:500}'
      +'.acnhs-toast{position:fixed;z-index:99999;background:linear-gradient(145deg, #071b30, #04111f);color:#f0ece3;border:1px solid rgba(201,168,76,.15);border-radius:12px;padding:18px 22px;max-width:360px;width:calc(100% - 40px);box-shadow:0 20px 40px rgba(0,0,0,.6);opacity:0;transform:translateX(20px);transition:all .4s cubic-bezier(0.16,1,0.3,1);font-family:"Inter",system-ui,sans-serif}'
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
