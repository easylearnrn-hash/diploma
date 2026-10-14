/**
 * ACNHS Alert Center - composer  (js/alert-admin-composer.js)
 * Create / edit drawer: message, placement, audience, priority, schedule, live preview.
 */
(function (global) {
  'use strict';

  var AC = global.AC = global.AC || {};
  var esc = AC.esc, icon = AC.icon, $ = AC.$, $$ = AC.$$;

  var PORTAL_PAGES = [
    ['Student portal', ['Student-page.html', 'hub.html', 'studies-portal.html', 'notes.html', 'notes-new-design.html', 'student-email.html', 'student-card.html', 'invoice.html', 'invoice-view.html', 'acceptance-letter.html']],
    ['Application flow', ['index.html', 'Qualifier.html', 'admission-form.html', 'application-status.html', 'final-form.html', 'login.html']],
    ['Public / info', ['about.html', 'academic-catalog.html', 'contact.html', 'verify-transcript.html', 'verify-document.html', 'verify.html', 'help-handbook.html', 'help-grading.html', 'help-appeals.html', 'help-clinical.html', 'help-support.html']],
    ['Nursing studies', ['fundamentals-nursing-nclex.html', 'informed-consent-nursing.html', 'delegation-nursing-nclex.html', 'sbar-communication-nursing.html', 'scope-of-practice-nursing.html', 'vital-signs-interpretation-nursing.html', 'head-to-toe-assessment-nursing.html', 'pain-assessment-nursing-nclex.html', 'EKG.html', 'anatomy.html', 'medical-terminology.html', 'oxygenation-basics-nursing-nclex.html', 'nutrition-feeding-nursing-nclex.html', 'nursing-calculations-nclex.html', 'nursing-diagnosis-nclex.html', 'physical-assessment-nursing.html', 'maslows-hierarchy-nursing.html', 'mental-health-notes.html', 'precautions-nursing.html', 'family-dynamics-nursing.html', 'amputation-nursing.html', 'blood-products-administration-nursing.html', 'bmi-calculation-nursing.html', 'client-positioning-nursing.html', 'complementary-alternative-medicine-nursing.html', 'documentation-informatics-nursing.html', 'elimination-intake-output-nursing.html', 'emergency-triage-tag-colors-nursing.html', 'hygiene-grooming-nursing-nclex.html', 'physical-exam-bowel-sounds-nursing.html', 'skin-integrity-pressure-injuries-nclex.html', 'sleep-sensory-needs-nclex.html', 'tube-care-nursing.html']]
  ];

  var C = {
    open: false, row: null, republish: false, dirty: false, release: null, saving: false,
    groups: null, students: null, selGroups: new Set(), selStudents: new Set(), pages: new Set(), triggers: [],
    preview: null, device: 'desktop', asStudent: false, savedRange: null, loaded: false
  };
  AC.composer = { isOpen: function () { return C.open; }, state: C };

  /* ======================================================================
     Helpers
     ====================================================================== */
  function radio(name) { var el = $('input[name="' + name + '"]:checked'); return el ? el.value : ''; }
  function setRadio(name, v) { var el = $('input[name="' + name + '"][value="' + v + '"]'); if (el) { el.checked = true; } }
  function val(id) { return $('#' + id).value; }
  function setVal(id, v) { $('#' + id).value = v == null ? '' : v; }
  function chk(id) { return $('#' + id).checked; }
  function setChk(id, v) { $('#' + id).checked = !!v; }
  function show(sel, on) { var el = typeof sel === 'string' ? $(sel) : sel; if (el) { el.hidden = !on; } }
  function ready() { return AC.state.schema.ready; }
  function mark() { C.dirty = true; }

  AC.safeUrl = function (u) {
    u = String(u || '').trim();
    if (!u) { return ''; }
    if (/^(https?:\/\/|mailto:|tel:)[^\s<>"'`]+$/i.test(u)) { return u; }
    if (/^[^:\s<>"'`]+$/.test(u)) { return u; }
    return '';
  };
  /* Wrap loose text at the top level in <p> so every line is a proper paragraph */
  function paragraphize(html) {
    var box = document.createElement('div'), out = document.createElement('div'), cur = null;
    box.innerHTML = html;
    Array.prototype.slice.call(box.childNodes).forEach(function (n) {
      if (n.nodeType === 1 && /^(P|UL|OL|H3|H4|BLOCKQUOTE|HR)$/.test(n.nodeName)) { cur = null; out.appendChild(n); }
      else {
        if (n.nodeType === 3 && !n.nodeValue.trim() && !cur) { return; }
        if (!cur) { cur = document.createElement('p'); out.appendChild(cur); }
        cur.appendChild(n);
      }
    });
    Array.prototype.slice.call(out.querySelectorAll('p')).forEach(function (p) { if (!p.textContent.trim() && !p.querySelector('br')) { p.remove(); } });
    return out.innerHTML;
  }
  function clean(html) {
    var s = global.ACNHSHomepageAlerts ? global.ACNHSHomepageAlerts.sanitize(html) : AC.esc(AC.plain(html));
    if (!(AC.plain(s) || /<(a|li)\b/i.test(s))) { return ''; }
    return paragraphize(s);
  }

  /* ======================================================================
     Open / close
     ====================================================================== */
  AC.composer.open = function (row, opts) {
    opts = opts || {};
    if (!row && !AC.can('create')) { return AC.ui.toast('You do not have permission to create alerts.', 'err'); }
    if (row && !AC.can('edit', row)) { return AC.ui.toast('Editing a live alert needs the "Publish Alerts" permission.', 'err'); }
    C.row = row || null; C.republish = !!opts.republish; C.dirty = false; C.saving = false;
    resetForm();
    if (row) { fillFromRow(row, { republish: C.republish }); }
    else if (opts.from) { fillFromRow(opts.from, { copy: true }); }
    else if (opts.template) { fillFromTemplate(opts.template); }
    applyLegacyMode();
    syncAll();
    updateCount();
    header();

    var drawer = $('#ac-drawer'), back = $('#ac-backdrop');
    drawer.hidden = false; back.hidden = false;
    document.body.classList.add('ac-locked');
    drawer.setAttribute('data-pane', 'edit'); setPane('edit');
    requestAnimationFrame(function () { drawer.classList.add('open'); back.classList.add('open'); });
    C.release = AC.ui.trapFocus(drawer, requestClose);
    C.open = true;
    setTimeout(function () { $('#f-title').focus({ preventScroll: true }); $('.ac-form').scrollTop = 0; }, 60);
    ensurePreview();
    C.dirty = false;
    // Lazy-load pickers when the loaded alert needs them
    if (AC.$('input[name="audience"]:checked').value === 'group') { loadGroups(); }
    if (AC.$('input[name="audience"]:checked').value === 'individual') { loadStudents(); }
  };

  function header() {
    var st = C.row ? AC.statusOf(C.row) : 'draft';
    $('#ac-drawer-title').textContent = C.row ? (C.republish ? 'Re-publish announcement' : 'Edit announcement') : 'New announcement';
    $('#ac-drawer-status').innerHTML = C.row ? '<span class="ac-badge s-' + st + '"><span class="d"></span>' + esc(AC.STATUS[st]) + '</span>' : '<span class="ac-badge s-draft"><span class="d"></span>Not saved yet</span>';
    $('#ac-drawer-sub').textContent = C.row ? 'Created ' + AC.fmt(C.row.created_at) + (C.row.created_by ? ' by ' + C.row.created_by : '') : 'Fill in the message, then publish or save a draft.';
    updateButtons();
  }

  function updateButtons() {
    var st = C.row ? AC.statusOf(C.row) : 'new';
    var draftBtn = $('#btn-draft'), pubBtn = $('#btn-publish'), label = $('span', pubBtn);
    var d = null; try { d = readForm(true); } catch (e) { /* ignore */ }
    var later = d && d.startMode === 'later' && AC.fromInput(d.startAt) && new Date(AC.fromInput(d.startAt)) > new Date();
    var isDraftFlow = !C.row || st === 'draft' || C.republish;
    if (isDraftFlow) {
      show(draftBtn, true);
      $('span', draftBtn).textContent = ready() ? 'Save draft' : 'Save (inactive)';
      label.textContent = later ? 'Schedule' : (C.republish ? 'Re-publish' : (ready() ? 'Publish now' : 'Publish'));
      pubBtn.setAttribute('data-mode', 'publish');
      var can = AC.can('publish');
      pubBtn.disabled = !can; pubBtn.title = can ? '' : 'Publishing needs the "Publish Alerts" permission. You can save a draft.';
    } else {
      show(draftBtn, false);
      label.textContent = 'Save changes';
      pubBtn.setAttribute('data-mode', 'save');
      pubBtn.disabled = false; pubBtn.title = '';
    }
  }

  function requestClose() {
    if (!C.open) { return; }
    if (!C.dirty) { return closeNow(); }
    AC.ui.confirm({ title: 'Discard your changes?', message: 'You have unsaved changes in this announcement.', confirmText: 'Discard changes', cancelText: 'Keep editing', danger: true }).then(function (ok) { if (ok) { closeNow(); } });
  }
  function closeNow() {
    var drawer = $('#ac-drawer'), back = $('#ac-backdrop');
    drawer.classList.remove('open'); back.classList.remove('open');
    if (C.release) { C.release(); C.release = null; }
    C.open = false;
    document.body.classList.remove('ac-locked');
    setTimeout(function () { if (!C.open) { drawer.hidden = true; back.hidden = true; } }, 300);
  }
  AC.composer.close = closeNow;

  function setPane(p) {
    $('#ac-drawer').setAttribute('data-pane', p);
    $$('#ac-panes [data-pane]').forEach(function (b) { b.setAttribute('aria-selected', String(b.getAttribute('data-pane') === p)); });
    if (p === 'preview') { renderPreview(); }
  }

  /* ======================================================================
     Reset / fill
     ====================================================================== */
  function resetForm() {
    setVal('f-title', ''); $('#f-editor').innerHTML = '';
    setVal('f-cta-label', ''); setVal('f-cta-url', ''); setChk('f-cta-newtab', true);
    setRadio('surface', ready() ? 'homepage' : 'portal'); setVal('f-position', 'modal');
    setRadio('audience', 'all'); C.selGroups = new Set(); C.selStudents = new Set();
    setRadio('priority', 'normal'); setChk('f-celebrate', false);
    setRadio('dismiss', 'dismissible'); setVal('f-ack-label', '');
    setRadio('popfreq', 'once_per_session'); setVal('f-portal-freq', 'once_ever'); setVal('f-max-displays', 3);
    setRadio('startmode', 'now'); setVal('f-start-at', ''); setRadio('endmode', 'never'); setVal('f-end-at', '');
    setVal('f-repeat', 'none'); setVal('f-month-start', 1); setVal('f-month-end', 5); setVal('f-custom-dates', '');
    setChk('f-requires-response', false); setVal('f-yes', 'Yes'); setVal('f-no', 'No'); setChk('f-session-repeat', false);
    C.pages = new Set(); C.triggers = [];
    $$('.ac-error', $('#ac-form')).forEach(function (e) { e.hidden = true; e.textContent = ''; });
    $$('[aria-invalid]', $('#ac-form')).forEach(function (e) { e.removeAttribute('aria-invalid'); });
    ['adv-pages', 'adv-trigger', 'adv-repeat'].forEach(function (id) { $('#' + id).open = false; });
  }

  function fillFromRow(r, o) {
    o = o || {};
    var now = new Date();
    setVal('f-title', (o.copy ? (r.title || '') + ' (copy)' : r.title));
    $('#f-editor').innerHTML = clean(r.message_html || '');
    setVal('f-cta-label', r.link_label && r.link_label !== 'Learn More' ? r.link_label : (r.link_url ? r.link_label || '' : ''));
    setVal('f-cta-url', r.link_url || ''); setChk('f-cta-newtab', r.link_new_tab !== false);

    setRadio('surface', ready() ? AC.surfaceOf(r) : 'portal');
    var trg = AC.json(r.trigger_rules);
    setVal('f-position', r.display_position || trg.display_position || 'modal');

    var aud = AC.audienceType(r);
    setRadio('audience', aud);
    C.selGroups = new Set(AC.audienceGroups(r)); C.selStudents = new Set(AC.audienceStudents(r));

    setRadio('priority', AC.priorityOf(r)); setChk('f-celebrate', r.severity === 'success');
    var inter = AC.json(r.interaction_rules);
    setRadio('dismiss', r.dismiss_behavior || (inter.dismissible === false ? 'acknowledge' : 'dismissible'));
    setVal('f-ack-label', r.acknowledge_label || '');
    setRadio('popfreq', r.popup_frequency || 'once_per_session');
    var fr = AC.json(r.frequency_rules), cap = fr.cap_type || r.display_mode || 'once_ever';
    if (!$('#f-portal-freq option[value="' + cap + '"]')) { cap = 'once_ever'; }
    setVal('f-portal-freq', cap); setVal('f-max-displays', fr.max_displays || r.max_displays || 3);

    var w = AC.windowOf(r);
    if (o.copy || o.republish) { setRadio('startmode', 'now'); setRadio('endmode', 'never'); }
    else {
      if (w.start) { setRadio('startmode', 'later'); setVal('f-start-at', AC.toInput(w.start.toISOString())); }
      if (w.end) { setRadio('endmode', 'on'); setVal('f-end-at', AC.toInput(w.end.toISOString())); }
    }
    var rec = AC.recurrenceOf(r);
    setVal('f-repeat', rec.type === 'monthly' ? 'monthly' : (rec.type === 'custom' ? 'custom' : 'none'));
    if (rec.type === 'monthly') { setVal('f-month-start', rec.start); setVal('f-month-end', rec.end); }
    if (rec.type === 'custom') { setVal('f-custom-dates', rec.dates.join(', ')); }
    if (rec.type !== 'none') { $('#adv-repeat').open = true; }

    var requires = r.requires_response != null ? r.requires_response : inter.required_response;
    setChk('f-requires-response', requires); setVal('f-yes', r.yes_label || 'Yes'); setVal('f-no', r.no_label || 'No');
    setChk('f-session-repeat', inter.allow_session_repeat != null ? inter.allow_session_repeat : r.allow_session_repeat);
    C.pages = new Set(Array.isArray(trg.pages_whitelist) ? trg.pages_whitelist : []);
    C.triggers = String(trg.on_click_selector || '').split(',').map(function (s) { return s.trim(); }).filter(Boolean);
    if (C.pages.size) { $('#adv-pages').open = true; }
    if (C.triggers.length) { $('#adv-trigger').open = true; }
    if (now) { /* keep linter quiet */ }
  }

  function fillFromTemplate(t) {
    setVal('f-title', t.title || ''); $('#f-editor').innerHTML = clean(t.message_html || '');
    var sev = t.severity || 'info';
    setRadio('priority', sev === 'critical' ? 'critical' : (sev === 'warn' ? 'important' : 'normal')); setChk('f-celebrate', sev === 'success');
    setChk('f-requires-response', !!t.requires_response); setVal('f-yes', t.yes_label || 'Yes'); setVal('f-no', t.no_label || 'No');
    if (t.requires_response) { setRadio('surface', 'portal'); }
  }

  /* When the database upgrade is missing, only student-portal alerts can be saved */
  function applyLegacyMode() {
    var on = !ready();
    $$('input[name="surface"]').forEach(function (i) { if (i.value !== 'portal') { i.disabled = on; i.closest('.ac-choice').title = on ? 'Needs the one-time database upgrade (see the banner at the top)' : ''; } });
    var ack = $('input[name="dismiss"][value="acknowledge"]'); ack.disabled = on; ack.closest('.ac-choice').title = on ? 'Needs the one-time database upgrade' : '';
    if (on) { setRadio('surface', 'portal'); setRadio('dismiss', 'dismissible'); }
  }

  /* ======================================================================
     Read the form
     ====================================================================== */
  function readForm(lenient) {
    var customRaw = val('f-custom-dates');
    return {
      title: val('f-title').trim(), messageHtml: clean($('#f-editor').innerHTML), messageText: AC.plain($('#f-editor').innerHTML),
      ctaLabel: val('f-cta-label').trim(), ctaUrl: val('f-cta-url').trim(), ctaNewTab: chk('f-cta-newtab'),
      surface: radio('surface') || 'portal', position: val('f-position'),
      audience: radio('audience') || 'all', groups: Array.from(C.selGroups), students: Array.from(C.selStudents),
      priority: radio('priority') || 'normal', celebrate: chk('f-celebrate'),
      dismiss: radio('dismiss') || 'dismissible', ackLabel: val('f-ack-label').trim(),
      popfreq: radio('popfreq') || 'once_per_session', portalFreq: val('f-portal-freq'), maxDisplays: parseInt(val('f-max-displays'), 10) || 3,
      startMode: radio('startmode'), startAt: val('f-start-at'), endMode: radio('endmode'), endAt: val('f-end-at'),
      repeat: val('f-repeat'), monthStart: parseInt(val('f-month-start'), 10), monthEnd: parseInt(val('f-month-end'), 10),
      customDates: customRaw.split(',').map(function (s) { return s.trim(); }).filter(Boolean),
      requiresResponse: chk('f-requires-response'), yes: val('f-yes').trim() || 'Yes', no: val('f-no').trim() || 'No',
      sessionRepeat: chk('f-session-repeat'), pages: Array.from(C.pages), triggers: C.triggers.slice(), lenient: !!lenient
    };
  }

  function modelFromForm(d) {
    var start = d.startMode === 'later' && d.startAt ? new Date(AC.fromInput(d.startAt) || NaN) : null;
    var end = d.endMode === 'on' && d.endAt ? new Date(AC.fromInput(d.endAt) || NaN) : null;
    return {
      surface: d.surface, audience: d.audience, groups: d.groups, students: d.students.length, priority: d.priority, dismiss: d.dismiss,
      popfreq: d.popfreq, portalFreq: d.portalFreq, start: start && !isNaN(start) ? start : null, end: end && !isNaN(end) ? end : null,
      repeat: d.repeat === 'monthly' ? 'monthly' : (d.repeat === 'custom' ? 'custom' : 'none'), repeatDays: d.monthStart + '–' + d.monthEnd,
      cta: d.ctaUrl ? (d.ctaLabel || 'Learn More') : ''
    };
  }

  /* ======================================================================
     Validation
     ====================================================================== */
  function fieldError(errId, inputSel, msg) {
    var e = $('#' + errId); if (e) { e.textContent = msg; e.hidden = false; }
    var i = typeof inputSel === 'string' ? $(inputSel) : inputSel; if (i) { i.setAttribute('aria-invalid', 'true'); }
  }
  function clearErrors() {
    $$('.ac-error', $('#ac-form')).forEach(function (e) { e.hidden = true; e.textContent = ''; });
    $$('[aria-invalid]', $('#ac-form')).forEach(function (e) { e.removeAttribute('aria-invalid'); });
  }

  function validate(d, mode) {
    clearErrors();
    var errs = [], now = new Date();
    function bad(id, sel, msg, section) { fieldError(id, sel, msg); errs.push({ section: section, msg: msg, el: sel }); }
    if (!d.title) { bad('err-title', '#f-title', 'Please give the announcement a title.', 'sec-message'); }
    if (d.title.length > 200) { bad('err-title', '#f-title', 'The title is too long (200 characters maximum).', 'sec-message'); }
    if (mode !== 'draft' && !d.messageText) { bad('err-message', '#f-editor', 'Please write the message.', 'sec-message'); }
    if (d.messageHtml.length > 20000) { bad('err-message', '#f-editor', 'The message is too long.', 'sec-message'); }
    if (d.ctaUrl && !AC.safeUrl(d.ctaUrl)) { bad('err-cta', '#f-cta-url', 'Use a link starting with https://, http://, mailto: or tel: - or a page such as hub.html.', 'sec-message'); }
    if (d.ctaLabel && !d.ctaUrl) { bad('err-cta', '#f-cta-url', 'Add the link for this button, or clear the button label.', 'sec-message'); }
    if (d.audience === 'group' && !d.groups.length && mode !== 'draft') { bad('err-groups', '#grp-search', 'Choose at least one group.', 'sec-audience'); }
    if (d.audience === 'individual' && !d.students.length && mode !== 'draft') { bad('err-students', '#stu-search', 'Choose at least one student.', 'sec-audience'); }
    var start = null, end = null;
    if (d.startMode === 'later') {
      var s = AC.fromInput(d.startAt);
      if (!s) { bad('err-start', '#f-start-at', 'Choose the start date and time.', 'sec-schedule'); } else { start = new Date(s); }
    }
    if (d.endMode === 'on') {
      var e = AC.fromInput(d.endAt);
      if (!e) { bad('err-end', '#f-end-at', 'Choose the expiry date and time.', 'sec-schedule'); }
      else {
        end = new Date(e);
        if (start && end <= start) { bad('err-end', '#f-end-at', 'The expiry must be later than the start.', 'sec-schedule'); }
        else if (!start && end <= now && mode === 'publish') { bad('err-end', '#f-end-at', 'That expiry time has already passed.', 'sec-schedule'); }
      }
    }
    if (d.repeat === 'monthly') {
      if (!(d.monthStart >= 1 && d.monthStart <= 31 && d.monthEnd >= 1 && d.monthEnd <= 31) || d.monthStart > d.monthEnd) { bad('err-repeat', '#f-month-start', 'Use days between 1 and 31, with the first day not after the last.', 'sec-schedule'); $('#adv-repeat').open = true; }
    }
    if (d.repeat === 'custom') {
      var ok = d.customDates.length && d.customDates.every(function (x) { return /^\d{4}-\d{2}-\d{2}$/.test(x) && !isNaN(new Date(x + 'T00:00:00Z')); });
      if (!ok) { bad('err-repeat', '#f-custom-dates', 'Enter dates like 2026-09-01, separated by commas.', 'sec-schedule'); $('#adv-repeat').open = true; }
    }
    if (d.dismiss === 'acknowledge' && d.ackLabel.length > 40) { errs.push({ section: 'sec-behaviour', msg: 'The acknowledge button text is too long.' }); }
    return errs;
  }

  /* ======================================================================
     Payload
     ====================================================================== */
  function buildPayload(d, mode) {
    var rdy = ready(), email = AC.state.user.email;
    var sev = d.celebrate && (d.priority === 'normal' || d.priority === 'important') ? 'success' : AC.PRIORITY[d.priority].severity;
    var aud = d.audience;
    var studentIds = aud === 'individual' ? d.students : [];
    var groups = aud === 'group' ? d.groups : [];
    var cap = d.portalFreq;
    var startIso = d.startMode === 'later' ? AC.fromInput(d.startAt) : null;
    var endIso = d.endMode === 'on' ? AC.fromInput(d.endAt) : null;
    var rec = d.repeat;

    var dateRule = rec === 'monthly' ? 'monthly_range' : (rec === 'custom' ? 'custom_dates' : 'always');
    var startDate = null, endDate = null;
    if (!rdy && dateRule === 'always' && (startIso || endIso)) {
      dateRule = 'date_range';
      startDate = startIso ? AC.toInput(startIso).slice(0, 10) : null; endDate = endIso ? AC.toInput(endIso).slice(0, 10) : null;
    }
    var payload = {
      title: d.title, message_html: d.messageHtml, severity: sev,
      display_position: d.surface === 'homepage' ? 'modal' : d.position,
      link_url: d.ctaUrl || null, link_label: d.ctaUrl ? (d.ctaLabel || 'Learn More') : null,
      target_type: rdy || (aud !== 'public' && aud !== 'students') ? aud : 'all',     // before the upgrade the database only accepts all / group / individual
      target_student_ids: studentIds, target_group: groups[0] || null,
      display_mode: cap, max_displays: cap === 'times_limit' ? d.maxDisplays : null,
      date_rule_type: dateRule, start_date: startDate, end_date: endDate,
      monthly_start_day: rec === 'monthly' ? d.monthStart : null, monthly_end_day: rec === 'monthly' ? d.monthEnd : null,
      custom_dates: rec === 'custom' ? d.customDates : [],
      requires_response: d.surface !== 'homepage' && d.requiresResponse, response_type: d.surface !== 'homepage' && d.requiresResponse ? 'yes_no' : 'none',
      yes_label: d.yes, no_label: d.no,
      targeting_rules: { mode: aud === 'individual' ? 'include' : (aud === 'group' ? 'complex' : aud), include_students: studentIds, exclude_students: [], groups: groups, statuses: [], tags: [], logic: 'AND' },
      frequency_rules: { cap_type: cap, max_displays: cap === 'times_limit' ? d.maxDisplays : null, cooldown_hours: null, per_period: /daily/.test(cap) ? 'day' : null, stop_after_response: d.requiresResponse, stop_after_days: null },
      schedule_rules: {
        recurrence_type: rec === 'monthly' ? 'monthly' : (rec === 'custom' ? 'custom_dates' : (!rdy && dateRule === 'date_range' ? 'one_time' : 'always')),
        start_datetime: startIso, end_datetime: endIso, timezone: AC.TZ, daily_pattern: null, weekly_pattern: null,
        monthly_pattern: rec === 'monthly' ? { day_range: [d.monthStart, d.monthEnd] } : null, custom_dates: rec === 'custom' ? d.customDates : [], exclude_dates: []
      },
      trigger_rules: { when: ['on_login'], pages_whitelist: d.surface === 'homepage' ? [] : d.pages, pages_blacklist: [], display_position: d.surface === 'homepage' ? 'modal' : d.position, time_window: null, audience: aud === 'public' ? 'public' : 'students', on_click_selector: d.surface === 'homepage' ? null : (d.triggers.join(', ') || null) },
      interaction_rules: { dismissible: d.dismiss !== 'acknowledge', required_response: d.surface !== 'homepage' && d.requiresResponse, remind_on_no: false, auto_dismiss_seconds: null, allow_session_repeat: d.sessionRepeat }
    };
    if (rdy) {
      payload.display_surface = d.surface; payload.priority = d.priority;
      payload.publish_at = startIso; payload.expires_at = endIso;
      payload.popup_frequency = d.popfreq; payload.dismiss_behavior = d.dismiss;
      payload.acknowledge_label = d.dismiss === 'acknowledge' ? (d.ackLabel || null) : null;
      payload.link_new_tab = d.ctaNewTab; payload.updated_by = email;
      if (mode === 'draft') { payload.lifecycle_status = 'draft'; payload.is_active = false; }
      if (mode === 'publish') { payload.lifecycle_status = 'published'; payload.is_active = true; payload.published_by = email; }
    } else {
      if (mode === 'draft') { payload.is_active = false; }
      if (mode === 'publish') { payload.is_active = true; }
    }
    if (!C.row) { payload.created_by = email; }
    return payload;
  }

  /* ======================================================================
     Save
     ====================================================================== */
  async function submit(mode, o) {
    o = o || {};
    if (C.saving) { return null; }
    var d = readForm();
    var errs = validate(d, mode);
    if (errs.length) {
      AC.ui.toast(errs[0].msg, 'err');
      var sec = errs[0].section && $('#' + errs[0].section); if (sec) { sec.scrollIntoView({ behavior: 'smooth', block: 'start' }); }
      var bad = $('[aria-invalid="true"]'); if (bad && bad.focus) { setTimeout(function () { bad.focus({ preventScroll: true }); }, 250); }
      if ($('#ac-drawer').getAttribute('data-pane') === 'preview') { setPane('edit'); }
      return null;
    }
    var model = modelFromForm(d);
    var st = C.row ? AC.statusOf(C.row) : 'draft';
    if (!o.skipConfirm) {
      if (mode === 'publish' && (d.surface !== 'portal')) {
        if (!(await AC.list.confirmPublic({ title: d.title, display_surface: d.surface }, model, model.start && model.start > new Date() ? 'Schedule' : 'Publish'))) { return null; }
      } else if (mode === 'save' && d.surface !== 'portal' && (st === 'live' || st === 'scheduled')) {
        if (!(await AC.ui.confirm({ title: 'Update a live public alert?', message: 'Changes go live immediately. Visitors who already dismissed it will see the new version again if you chose "once per visitor".', confirmText: 'Save changes' }))) { return null; }
      }
    }
    var payload = buildPayload(d, mode);
    if (!ready()) { payload = AC.data.stripV2(payload); }
    C.saving = true; setBusy(true);
    try {
      var saved = C.row ? await AC.data.update(C.row.id, payload) : await AC.data.insert(payload);
      C.row = saved; C.dirty = false;
      AC.list.renderAll();
      if (!o.silent) {
        var stNow = AC.statusOf(saved);
        AC.ui.toast(mode === 'draft' ? 'Draft saved' : (stNow === 'scheduled' ? 'Scheduled - it goes live ' + AC.fmt(AC.windowOf(saved).start) : (mode === 'publish' ? 'Published - it is live now' : 'Changes saved')), 'ok');
      }
      if (!o.keepOpen) { closeNow(); } else { header(); }
      return saved;
    } catch (e) {
      console.error('Alert Center: save failed', e);
      if (AC.isMissingColumn(e) && ready()) { AC.state.schema.ready = false; AC.renderSchemaBanner(); }
      AC.ui.toast(AC.explain(e), 'err');
      return null;
    } finally { C.saving = false; setBusy(false); }
  }
  function setBusy(on) { ['#btn-draft', '#btn-publish', '#btn-template', '#btn-testsite'].forEach(function (s) { var b = $(s); if (b) { b.classList.toggle('is-busy', on); if (on) { b.setAttribute('aria-busy', 'true'); b.disabled = true; } else { b.removeAttribute('aria-busy'); b.disabled = false; } } }); if (!on) { updateButtons(); } }

  async function saveTemplate() {
    var d = readForm();
    if (!d.title || !d.messageText) { return AC.ui.toast('Write a title and message first - then save it as a template.', 'err'); }
    var name = await AC.ui.prompt({ title: 'Save as template', label: 'Template name', placeholder: 'e.g. Admissions reminder', confirmText: 'Save template', maxlength: 80 });
    if (!name) { return; }
    var sev = d.celebrate && (d.priority === 'normal' || d.priority === 'important') ? 'success' : AC.PRIORITY[d.priority].severity;
    var res = await AC.state.db.from('portal_alert_templates').insert([{ template_name: name, title: d.title, message_html: d.messageHtml, severity: sev, requires_response: d.requiresResponse, response_type: d.requiresResponse ? 'yes_no' : 'none', yes_label: d.yes, no_label: d.no }]);
    if (res.error) { return AC.ui.toast(AC.explain(res.error), 'err'); }
    AC.ui.toast('Template saved', 'ok');
    if (AC.extras && AC.extras.templatesLoaded) { AC.extras.templatesLoaded = false; }
  }

  async function testOnSite() {
    var d = readForm(), mode = (!C.row || AC.lifecycleOf(C.row) === 'draft') ? 'draft' : 'save';
    if (!ready()) { return AC.ui.toast('Homepage pop-ups need the one-time database upgrade first.', 'err'); }
    if (d.surface === 'portal') { return AC.ui.toast('This alert is for the student portal only. Switch placement to Homepage to test it on www.acnhs.am.', 'info'); }
    if (!C.row || C.dirty) {
      var ok = await AC.ui.confirm({ title: 'Save first?', message: C.row ? 'Your latest changes need to be saved before the real homepage can show them.' : 'The real homepage can only show saved alerts. Save this as a draft now? Drafts are never visible to visitors.', confirmText: C.row ? 'Save and open' : 'Save draft and open' });
      if (!ok) { return; }
      var saved = await submit(mode, { keepOpen: true, silent: true, skipConfirm: true });
      if (!saved) { return; }
    }
    window.open('index.html?acnhs_alert_preview=' + encodeURIComponent(C.row.id), '_blank');
  }

  /* ======================================================================
     Rich-text editor
     ====================================================================== */
  function editor() { return $('#f-editor'); }
  function saveSel() { var s = window.getSelection(); if (s.rangeCount && editor().contains(s.anchorNode)) { C.savedRange = s.getRangeAt(0).cloneRange(); } }
  function restoreSel() { editor().focus(); if (C.savedRange) { var s = window.getSelection(); s.removeAllRanges(); s.addRange(C.savedRange); } }

  function setupEditor() {
    var ed = editor();
    try { document.execCommand('defaultParagraphSeparator', false, 'p'); } catch (e) { /* ignore */ }
    ed.addEventListener('input', function () { if (ed.innerHTML === '<br>') { ed.innerHTML = ''; } mark(); schedule(); });
    ed.addEventListener('keyup', saveSel); ed.addEventListener('mouseup', saveSel); ed.addEventListener('blur', saveSel);
    ed.addEventListener('paste', function (e) {
      e.preventDefault();
      var html = e.clipboardData.getData('text/html'), text = e.clipboardData.getData('text/plain');
      if (html && global.ACNHSHomepageAlerts) { document.execCommand('insertHTML', false, global.ACNHSHomepageAlerts.sanitize(html)); }
      else { document.execCommand('insertText', false, text); }
    });
    var bar = $('#f-toolbar');
    bar.addEventListener('mousedown', function (e) { if (e.target.closest('.ac-rte-btn')) { e.preventDefault(); } });
    bar.addEventListener('click', async function (e) {
      var b = e.target.closest('[data-cmd]'); if (!b) { return; }
      var cmd = b.getAttribute('data-cmd');
      if (cmd === 'createLink') {
        saveSel();
        var url = await AC.ui.prompt({ title: 'Insert link', label: 'Web address', placeholder: 'https://… or hub.html', confirmText: 'Insert link', maxlength: 500, validate: function (v) { return AC.safeUrl(v) ? '' : 'Use https://, http://, mailto:, tel: or a page such as hub.html.'; } });
        if (!url) { return; }
        restoreSel();
        var sel = window.getSelection();
        if (sel.isCollapsed) { document.execCommand('insertHTML', false, '<a href="' + esc(AC.safeUrl(url)) + '">' + esc(url) + '</a>'); }
        else { document.execCommand('createLink', false, AC.safeUrl(url)); }
      } else { editor().focus(); document.execCommand(cmd, false, null); }
      mark(); schedule();
    });
  }

  function tokenButtons() {
    function tokens(hostId, handler) {
      var host = $('#' + hostId);
      AC.TOKENS.forEach(function (t) {
        var b = document.createElement('button'); b.type = 'button'; b.className = 'ac-token'; b.textContent = t[0]; b.title = t[1];
        b.addEventListener('mousedown', function (e) { e.preventDefault(); });
        b.addEventListener('click', function () { handler(t[0]); });
        host.appendChild(b);
      });
    }
    tokens('title-tokens', function (tk) {
      var i = $('#f-title'), s = i.selectionStart == null ? i.value.length : i.selectionStart, e2 = i.selectionEnd == null ? s : i.selectionEnd;
      i.value = i.value.slice(0, s) + tk + i.value.slice(e2); i.focus(); i.selectionStart = i.selectionEnd = s + tk.length; mark(); updateCount(); schedule();
    });
    tokens('msg-tokens', function (tk) { restoreSel(); document.execCommand('insertText', false, tk); saveSel(); mark(); schedule(); });
  }
  function updateCount() {
    var n = val('f-title').length, el = $('#f-title-count'); el.textContent = n + ' / 200'; el.classList.toggle('warn', n > 170);
  }

  /* ======================================================================
     Pickers: groups, students, pages, triggers
     ====================================================================== */
  async function loadGroups() {
    if (C.groups) { return renderGroups(); }
    var set = new Set();
    try {
      var sg = await AC.state.db.from('student_groups').select('name');
      (sg.data || []).forEach(function (g) { if (g.name) { set.add(String(g.name).trim()); } });
    } catch (e) { /* optional table */ }
    try {
      var st = await AC.state.db.from('students').select('program,group,group_name').limit(5000);
      (st.data || []).forEach(function (s) { [s.group, s.group_name, s.program].forEach(function (g) { if (g && String(g).trim()) { set.add(String(g).trim()); } }); });
    } catch (e) { /* ignore */ }
    C.groups = Array.from(set).sort(function (a, b) { return a.localeCompare(b, 'en', { numeric: true }); });
    renderGroups();
  }
  function renderGroups() {
    var q = val('grp-search').trim().toLowerCase(), host = $('#grp-list');
    var all = (C.groups || []).slice();
    C.selGroups.forEach(function (g) { if (all.indexOf(g) === -1) { all.push(g); } });     // keep groups saved on the alert even if no student has them now
    var list = all.filter(function (g) { return !q || g.toLowerCase().indexOf(q) !== -1; });
    host.innerHTML = list.length ? list.map(function (g, i) {
      return '<label class="ac-pick"><input type="checkbox" data-g="' + esc(g) + '" ' + (C.selGroups.has(g) ? 'checked' : '') + '><span>' + esc(g) + '</span></label>';
    }).join('') : '<div class="ac-picker-empty">' + (all.length ? 'No groups match your search.' : 'No student groups found yet. Groups come from the Student Groups page and from each student\'s group.') + '</div>';
    $('#grp-count').textContent = C.selGroups.size + ' selected';
  }

  async function loadStudents() {
    if (C.students) { return renderStudents(); }
    try {
      var r = await AC.state.db.from('students').select('id,student_id,full_name,email,group,group_name,program').order('full_name').limit(3000);
      if (r.error) { throw r.error; }
      C.students = r.data || [];
    } catch (e) { C.students = []; AC.ui.toast('Could not load students: ' + AC.explain(e), 'err'); }
    renderStudents();
  }
  function renderStudents() {
    var q = val('stu-search').trim().toLowerCase(), host = $('#stu-list');
    var list = (C.students || []).filter(function (s) {
      return !q || [s.full_name, s.student_id, s.email, s.group, s.group_name].join(' ').toLowerCase().indexOf(q) !== -1 || C.selStudents.has(s.id) && !q;
    });
    var shown = list.slice(0, 150);
    host.innerHTML = shown.length ? shown.map(function (s) {
      return '<label class="ac-pick"><input type="checkbox" data-s="' + esc(s.id) + '" ' + (C.selStudents.has(s.id) ? 'checked' : '') + '><span>' + esc(s.full_name || 'Unnamed student') + '<small>' + esc([s.student_id, s.email].filter(Boolean).join(' · ')) + '</small></span></label>';
    }).join('') + (list.length > shown.length ? '<div class="ac-picker-empty">Showing 150 of ' + list.length + ' - type to narrow the list.</div>' : '') : '<div class="ac-picker-empty">' + ((C.students || []).length ? 'No students match your search.' : 'No students found.') + '</div>';
    $('#stu-count').textContent = C.selStudents.size + ' selected';
  }

  function renderPages() {
    var q = val('pg-search').trim().toLowerCase(), host = $('#pg-list'), known = {}, html = '';
    PORTAL_PAGES.forEach(function (g) {
      var items = g[1].filter(function (p) { known[p] = true; return !q || p.toLowerCase().indexOf(q) !== -1; });
      if (!items.length) { return; }
      html += '<div class="ac-pick-group">' + esc(g[0]) + '</div>' + items.map(function (p) { return '<label class="ac-pick"><input type="checkbox" data-p="' + esc(p) + '" ' + (C.pages.has(p) ? 'checked' : '') + '><span>' + esc(p) + '</span></label>'; }).join('');
    });
    var custom = Array.from(C.pages).filter(function (p) { return !known[p] && (!q || p.toLowerCase().indexOf(q) !== -1); });
    if (custom.length) { html += '<div class="ac-pick-group">Custom</div>' + custom.map(function (p) { return '<label class="ac-pick"><input type="checkbox" data-p="' + esc(p) + '" checked><span>' + esc(p) + '</span></label>'; }).join(''); }
    host.innerHTML = html || '<div class="ac-picker-empty">No pages match your search.</div>';
    var n = C.pages.size;
    $('#pg-count').textContent = n ? n + ' selected' : '0 selected (= all pages)';
    $('#pg-chip').textContent = n ? AC.plural(n, 'page') : 'All pages';
  }

  function renderTriggers() {
    var host = $('#trg-tags');
    host.innerHTML = C.triggers.map(function (t, i) { return '<span class="ac-tag"><code>' + esc(t) + '</code><button type="button" data-rm="' + i + '" aria-label="Remove ' + esc(t) + '">&times;</button></span>'; }).join('');
    $('#trg-chip').textContent = C.triggers.length ? AC.plural(C.triggers.length, 'button') : 'On page load';
  }
  function addTrigger(v) {
    String(v || '').split(',').map(function (s) { return s.trim(); }).filter(Boolean).forEach(function (s) { if (C.triggers.indexOf(s) === -1) { C.triggers.push(s); } });
    renderTriggers(); mark(); schedule();
  }

  async function scanPage(file) {
    var sel = $('#trg-buttons');
    sel.innerHTML = '<option value="">Scanning…</option>';
    if (!file) { sel.innerHTML = '<option value="">2. Choose a button…</option>'; return; }
    try {
      var resp = await fetch(file + '?nocache=' + Date.now());
      if (!resp.ok) { throw new Error('Fetch failed'); }
      var doc = new DOMParser().parseFromString(await resp.text(), 'text/html');
      doc.querySelectorAll('script, style, noscript').forEach(function (el) { el.remove(); });
      var els = Array.prototype.slice.call(doc.querySelectorAll('button, a[href], a[data-view], a[onclick], [onclick], input[type="submit"], input[type="button"], [data-tab], [data-section], [role="tab"], [role="button"]'));
      var seen = {}, opts = [];
      els.forEach(function (el) {
        el.querySelectorAll('svg').forEach(function (s) { s.remove(); });
        var label = el.textContent.replace(/\s+/g, ' ').trim();
        if (!label || label.length < 2) { label = el.getAttribute('aria-label') || el.getAttribute('title') || el.getAttribute('value') || el.getAttribute('data-tab') || el.getAttribute('data-view') || ''; }
        if (!label) { return; }
        if (label.length > 60) { label = label.slice(0, 60) + '…'; }
        var s = '';
        if (el.id) { s = '#' + el.id; }
        else if (el.getAttribute('data-tab')) { s = "[data-tab='" + el.getAttribute('data-tab') + "']"; }
        else if (el.getAttribute('data-view')) { s = "[data-view='" + el.getAttribute('data-view') + "']"; }
        else if (el.getAttribute('onclick')) { var fn = (el.getAttribute('onclick').match(/(\w+)\s*\(/) || [])[1]; if (fn) { s = "[onclick*='" + fn + "']"; } }
        else if (el.getAttribute('href') && el.getAttribute('href') !== '#') { var h = el.getAttribute('href').replace(/[?#].*/, '').split('/').pop(); if (h) { s = "[href*='" + h + "']"; } }
        else if (el.classList.length) { var best = Array.prototype.find.call(el.classList, function (c) { return c.length > 2 && ['active', 'show', 'hide', 'btn', 'open'].indexOf(c) === -1; }); if (best) { s = '.' + best; } }
        if (s && !seen[s]) { seen[s] = 1; opts.push([label, s]); }
      });
      sel.innerHTML = opts.length ? '<option value="">' + opts.length + ' buttons found - pick one…</option>' + opts.map(function (o) { return '<option value="' + esc(o[1]) + '">' + esc(o[0]) + '  ·  ' + esc(o[1]) + '</option>'; }).join('') : '<option value="">No identifiable buttons found</option>';
    } catch (e) { sel.innerHTML = '<option value="">Could not scan - open this page on the local server (localhost:8000)</option>'; }
  }

  /* ======================================================================
     Visibility, summary, preview
     ====================================================================== */
  function syncAll() {
    var d = readForm(true), portal = d.surface !== 'homepage', home = d.surface !== 'portal';
    show('#wrap-position', portal); show('#wrap-portalfreq', portal); show('#sec-portal', portal); show('#wrap-popfreq', home);
    show('#wrap-maxdisp', portal && d.portalFreq === 'times_limit');
    show('#aud-group-box', d.audience === 'group'); show('#aud-student-box', d.audience === 'individual');
    show('#wrap-celebrate', d.priority === 'normal' || d.priority === 'important');
    show('#wrap-ack-label', d.dismiss === 'acknowledge');
    show('#f-start-at', d.startMode === 'later'); show('#f-end-at', d.endMode === 'on');
    show('#wrap-monthly', d.repeat === 'monthly'); show('#wrap-custom', d.repeat === 'custom');
    show('#wrap-yesno', d.requiresResponse);
    $('#repeat-chip').textContent = d.repeat === 'monthly' ? 'Days ' + d.monthStart + '–' + d.monthEnd : (d.repeat === 'custom' ? AC.plural(d.customDates.length, 'date') : 'None');
    var help = '';
    if (d.audience === 'public') { help = 'Only people who are not signed in will see this - signed-in students never do.'; }
    else if (d.audience === 'students' || d.audience === 'group' || d.audience === 'individual') { help = home ? 'On the homepage, students are recognised when they are signed in to the student portal in the same browser.' : ''; }
    $('#aud-help').textContent = help;
    $('#btn-testsite').hidden = !home;
    $('#pv-title').textContent = home ? 'Live preview - homepage pop-up' : 'Preview - student portal alert';
    $('#pv-note').textContent = home ? 'This is exactly how the pop-up looks to ' + (C.asStudent ? 'a signed-in student' : 'visitors') + '.' : 'Student-portal alerts use the portal\'s own display style (' + (d.position.indexOf('banner') === 0 ? 'banner' : (d.position.indexOf('toast') === 0 ? 'corner notice' : 'pop-up')) + '); content and priority styling are shown here.';
    renderSummary(d);
    updateButtons();
  }

  function renderSummary(d) {
    var items = AC.describe(modelFromForm(d), C.row ? AC.statusOf(C.row) : 'draft');
    $('#ac-summary ul').innerHTML = items.map(function (i) { return '<li' + (i.warn ? ' class="warn"' : '') + '>' + esc(i.text) + '</li>'; }).join('');
  }

  var schedule = AC.debounce(function () { syncAll(); renderPreview(); }, 140);

  function ensurePreview() {
    if (!C.preview && global.ACNHSHomepageAlerts) { C.preview = global.ACNHSHomepageAlerts.mountPreview($('#ac-stage-host'), { title: '', message_html: '' }, {}); }
    renderPreview();
  }
  function renderPreview() {
    if (!C.preview) { return; }
    var d = readForm(true);
    var sev = d.celebrate && (d.priority === 'normal' || d.priority === 'important') ? 'success' : AC.PRIORITY[d.priority].severity;
    var data = {
      title: d.title || 'Your title appears here', message_html: d.messageHtml || '<p style="opacity:.6">Your message appears here as you type…</p>',
      priority: d.priority, severity: sev, link_url: AC.safeUrl(d.ctaUrl), link_label: d.ctaLabel, link_new_tab: d.ctaNewTab,
      dismiss_behavior: d.dismiss, acknowledge_label: d.ackLabel
    };
    $('#ac-stage').setAttribute('data-device', C.device);
    C.preview.update(data, { student: C.asStudent, compact: C.device === 'mobile' });
  }

  /* ======================================================================
     Events
     ====================================================================== */
  AC.composer.bind = function () {
    setupEditor(); tokenButtons(); renderPages(); renderTriggers();
    var form = $('#ac-form');
    form.addEventListener('submit', function (e) { e.preventDefault(); });
    form.addEventListener('input', function (e) {
      mark();
      if (e.target.id === 'f-title') { updateCount(); }
      if (e.target.id === 'grp-search') { renderGroups(); return; }
      if (e.target.id === 'stu-search') { renderStudents(); return; }
      if (e.target.id === 'pg-search') { renderPages(); return; }
      if (e.target.closest('.ac-picker')) { return; }
      schedule();
    });
    form.addEventListener('change', function (e) {
      var t = e.target;
      if (t.name === 'audience') { if (t.value === 'group') { loadGroups(); } if (t.value === 'individual') { loadStudents(); } }
      if (t.name === 'surface' && t.value === 'homepage') { $('#adv-pages').open = false; }
      if (t.hasAttribute('data-g')) { t.checked ? C.selGroups.add(t.getAttribute('data-g')) : C.selGroups.delete(t.getAttribute('data-g')); $('#grp-count').textContent = C.selGroups.size + ' selected'; }
      if (t.hasAttribute('data-s')) { t.checked ? C.selStudents.add(t.getAttribute('data-s')) : C.selStudents.delete(t.getAttribute('data-s')); $('#stu-count').textContent = C.selStudents.size + ' selected'; }
      if (t.hasAttribute('data-p')) { t.checked ? C.pages.add(t.getAttribute('data-p')) : C.pages.delete(t.getAttribute('data-p')); renderPages(); }
      if (t.name === 'startmode' && t.value === 'later' && !val('f-start-at')) { setVal('f-start-at', AC.toInput(new Date(Date.now() + 3600000).toISOString())); }
      if (t.name === 'endmode' && t.value === 'on' && !val('f-end-at')) { var base = val('f-start-at') ? new Date(AC.fromInput(val('f-start-at'))) : new Date(); setVal('f-end-at', AC.toInput(new Date(+base + 7 * 86400000).toISOString())); }
      mark(); syncAll(); renderPreview();
    });
    $('#pg-clear').addEventListener('click', function () { C.pages = new Set(); renderPages(); mark(); });
    function addPage() {
      var raw = val('pg-custom'); if (!raw.trim()) { return; }
      raw.split(',').map(function (s) { return s.trim().replace(/^\/+/, ''); }).filter(Boolean).forEach(function (p) { C.pages.add(p); });
      setVal('pg-custom', ''); renderPages(); mark();
    }
    $('#pg-add').addEventListener('click', addPage);
    $('#pg-custom').addEventListener('keydown', function (e) { if (e.key === 'Enter') { e.preventDefault(); addPage(); } });
    $('#trg-page').addEventListener('change', function (e) { scanPage(e.target.value); });
    $('#trg-buttons').addEventListener('change', function (e) { if (e.target.value) { addTrigger(e.target.value); e.target.selectedIndex = 0; } });
    $('#trg-add').addEventListener('click', function () { addTrigger(val('trg-manual')); setVal('trg-manual', ''); });
    $('#trg-manual').addEventListener('keydown', function (e) { if (e.key === 'Enter') { e.preventDefault(); addTrigger(val('trg-manual')); setVal('trg-manual', ''); } });
    $('#trg-clear').addEventListener('click', function () { C.triggers = []; renderTriggers(); mark(); });
    $('#trg-tags').addEventListener('click', function (e) { var b = e.target.closest('[data-rm]'); if (b) { C.triggers.splice(+b.getAttribute('data-rm'), 1); renderTriggers(); mark(); } });

    $('#ac-drawer-close').addEventListener('click', requestClose);
    $('#btn-cancel').addEventListener('click', requestClose);
    $('#ac-backdrop').addEventListener('mousedown', requestClose);
    $('#btn-draft').addEventListener('click', function () { submit('draft'); });
    $('#btn-publish').addEventListener('click', function () { submit($('#btn-publish').getAttribute('data-mode') || 'publish'); });
    $('#btn-template').addEventListener('click', saveTemplate);
    $('#btn-testsite').addEventListener('click', testOnSite);
    $('#ac-panes').addEventListener('click', function (e) { var b = e.target.closest('[data-pane]'); if (b) { setPane(b.getAttribute('data-pane')); } });
    function dev(d) { C.device = d; $('#pv-desktop').setAttribute('aria-pressed', String(d === 'desktop')); $('#pv-mobile').setAttribute('aria-pressed', String(d === 'mobile')); renderPreview(); }
    function who(s) { C.asStudent = s; $('#pv-visitor').setAttribute('aria-pressed', String(!s)); $('#pv-student').setAttribute('aria-pressed', String(s)); syncAll(); renderPreview(); }
    $('#pv-desktop').addEventListener('click', function () { dev('desktop'); });
    $('#pv-mobile').addEventListener('click', function () { dev('mobile'); });
    $('#pv-visitor').addEventListener('click', function () { who(false); });
    $('#pv-student').addEventListener('click', function () { who(true); });
    window.addEventListener('beforeunload', function (e) { if (C.open && C.dirty) { e.preventDefault(); e.returnValue = ''; } });
  };

})(window);
