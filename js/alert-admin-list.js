/**
 * ACNHS Alert Center - dashboard list  (js/alert-admin-list.js)
 * Summary tiles, category tabs, search / filter / sort, alert cards and row actions.
 */
(function (global) {
  'use strict';

  var AC = global.AC = global.AC || {};
  var esc = AC.esc, icon = AC.icon, $ = AC.$, $$ = AC.$$;
  var STORE_KEY = 'acnhs_alert_center_ui_v1';
  var PAGE = 40;
  var shown = PAGE;

  var TABS = [
    { id: 'all', label: 'All', test: function (r, st) { return st !== 'archived'; } },
    { id: 'homepage', label: 'Homepage pop-ups', test: function (r, st) { return st !== 'archived' && AC.surfaceOf(r) !== 'portal'; } },
    { id: 'portal', label: 'Student portal', test: function (r, st) { return st !== 'archived' && AC.surfaceOf(r) !== 'homepage'; } },
    { id: 'group', label: 'Group-specific', test: function (r, st) { return st !== 'archived' && AC.audienceType(r) === 'group'; } },
    { id: 'urgent', label: 'Urgent', test: function (r, st) { var p = AC.priorityOf(r); return (p === 'urgent' || p === 'critical') && st !== 'archived' && st !== 'expired'; } },
    { id: 'scheduled', label: 'Scheduled', test: function (r, st) { return st === 'scheduled'; } },
    { id: 'history', label: 'Expired & archived', test: function (r, st) { return st === 'expired' || st === 'archived'; } },
    'sep',
    { id: 'templates', label: 'Templates', view: 'templates' },
    { id: 'analytics', label: 'Analytics', view: 'analytics' }
  ];

  var STATS = [
    { id: 'live', label: 'Live now', color: 'var(--ac-live)', test: function (r, st) { return st === 'live'; } },
    { id: 'scheduled', label: 'Scheduled', color: 'var(--ac-scheduled)', test: function (r, st) { return st === 'scheduled'; } },
    { id: 'draft', label: 'Drafts', color: 'var(--ac-draft)', test: function (r, st) { return st === 'draft'; } },
    { id: 'paused', label: 'Paused', color: 'var(--ac-paused)', test: function (r, st) { return st === 'paused'; } },
    { id: 'ending', label: 'Ending soon', color: 'var(--ac-expired)', test: function (r, st) {
      if (st !== 'live') { return false; }
      var e = AC.windowOf(r).end; return !!e && e - new Date() < 48 * 3600000;
    } }
  ];

  var SORTS = {
    newest: function (a, b) { return time(b.created_at) - time(a.created_at); },
    oldest: function (a, b) { return time(a.created_at) - time(b.created_at); },
    priority: function (a, b) { return AC.PRIORITY[AC.priorityOf(b)].rank - AC.PRIORITY[AC.priorityOf(a)].rank || time(b.created_at) - time(a.created_at); },
    start: function (a, b) { return effStart(b) - effStart(a); },
    expiry: function (a, b) { var ea = AC.windowOf(a).end, eb = AC.windowOf(b).end; return (ea ? +ea : Infinity) - (eb ? +eb : Infinity); },
    title: function (a, b) { return String(a.title || '').localeCompare(String(b.title || ''), 'en', { sensitivity: 'base' }); }
  };
  function time(v) { return v ? (Date.parse(v) || 0) : 0; }
  function effStart(r) { var w = AC.windowOf(r); return w.start ? +w.start : (time(r.published_at) || time(r.created_at)); }

  AC.list = {};

  /* ======================================================================
     State persistence
     ====================================================================== */
  AC.list.restoreUi = function () {
    try {
      var s = JSON.parse(localStorage.getItem(STORE_KEY) || '{}');
      ['tab', 'sort', 'status', 'surface', 'priority', 'audience'].forEach(function (k) { if (typeof s[k] === 'string') { AC.state.ui[k] = s[k]; } });
    } catch (e) { /* ignore */ }
    if (!SORTS[AC.state.ui.sort]) { AC.state.ui.sort = 'newest'; }
    if (!TABS.some(function (t) { return t.id === AC.state.ui.tab; }) || (tabDef(AC.state.ui.tab) || {}).view) { AC.state.ui.tab = 'all'; }
    $('#ac-f-status').value = AC.state.ui.status; $('#ac-f-surface').value = AC.state.ui.surface;
    $('#ac-f-priority').value = AC.state.ui.priority; $('#ac-f-audience').value = AC.state.ui.audience;
    $('#ac-sort').value = AC.state.ui.sort;
  };
  function persist() {
    var u = AC.state.ui;
    try { localStorage.setItem(STORE_KEY, JSON.stringify({ tab: u.tab, sort: u.sort, status: u.status, surface: u.surface, priority: u.priority, audience: u.audience })); } catch (e) { /* ignore */ }
  }

  /* ======================================================================
     Filtering
     ====================================================================== */
  function tabDef(id) { return TABS.filter(function (t) { return t !== 'sep' && t.id === id; })[0]; }

  AC.list.visible = function () {
    var u = AC.state.ui, now = new Date(), q = u.q.trim().toLowerCase();
    var tab = tabDef(u.tab), stat = STATS.filter(function (s) { return s.id === u.stat; })[0];
    var rows = AC.state.rows.filter(function (r) {
      var st = AC.statusOf(r, now);
      if (tab && tab.test && !tab.test(r, st)) { return false; }
      if (stat && !stat.test(r, st)) { return false; }
      if (u.status && st !== u.status) { return false; }
      if (u.surface && AC.surfaceOf(r) !== u.surface) { return false; }
      if (u.priority && AC.priorityOf(r) !== u.priority) { return false; }
      if (u.audience && AC.audienceType(r) !== u.audience) { return false; }
      if (q) {
        var hay = [r.title, AC.plain(r.message_html), AC.audienceLabel(r), AC.SURFACE[AC.surfaceOf(r)], AC.STATUS[st], AC.PRIORITY[AC.priorityOf(r)].label, r.created_by].join(' ').toLowerCase();
        if (hay.indexOf(q) === -1) { return false; }
      }
      return true;
    });
    return rows.sort(SORTS[u.sort] || SORTS.newest);
  };

  /* ======================================================================
     Rendering
     ====================================================================== */
  AC.list.renderAll = function (failed) {
    renderStats(); renderTabs();
    if (isAlertsView()) { renderList(failed); }
  };
  function isAlertsView() { var t = tabDef(AC.state.ui.tab); return !t || !t.view; }

  function renderStats() {
    var now = new Date(), rows = AC.state.rows, host = $('#ac-stats'), u = AC.state.ui;
    host.hidden = !isAlertsView();
    var liveHome = 0, livePortal = 0, nextStart = null, nextEnd = null;
    var counts = {};
    STATS.forEach(function (s) { counts[s.id] = 0; });
    rows.forEach(function (r) {
      var st = AC.statusOf(r, now), w = AC.windowOf(r), surf = AC.surfaceOf(r);
      STATS.forEach(function (s) { if (s.test(r, st)) { counts[s.id]++; } });
      if (st === 'live') { if (surf !== 'portal') { liveHome++; } if (surf !== 'homepage') { livePortal++; } if (w.end && (!nextEnd || w.end < nextEnd)) { nextEnd = w.end; } }
      if (st === 'scheduled' && w.start && (!nextStart || w.start < nextStart)) { nextStart = w.start; }
    });
    var subs = {
      live: counts.live ? liveHome + ' homepage · ' + livePortal + ' portal' : 'Nothing is live',
      scheduled: nextStart ? 'Next ' + AC.relative(nextStart, now) : 'None waiting',
      draft: counts.draft ? 'Ready to finish' : 'No drafts',
      paused: counts.paused ? 'Switched off' : 'None paused',
      ending: nextEnd && counts.ending ? 'Next ' + AC.relative(nextEnd, now) : 'Nothing expiring'
    };
    host.innerHTML = STATS.map(function (s) {
      return '<button type="button" class="ac-stat" style="--ac-stat-c:' + s.color + '" data-stat="' + s.id + '" aria-pressed="' + (u.stat === s.id) + '">' +
        '<div class="ac-stat-num">' + counts[s.id] + '</div><div class="ac-stat-label">' + esc(s.label) + '</div><div class="ac-stat-sub">' + esc(subs[s.id]) + '</div></button>';
    }).join('');
  }

  function renderTabs() {
    var now = new Date(), u = AC.state.ui, host = $('#ac-tabs');
    var counts = {};
    TABS.forEach(function (t) { if (t !== 'sep' && t.test) { counts[t.id] = 0; } });
    AC.state.rows.forEach(function (r) { var st = AC.statusOf(r, now); TABS.forEach(function (t) { if (t !== 'sep' && t.test && t.test(r, st)) { counts[t.id]++; } }); });
    host.innerHTML = TABS.map(function (t) {
      if (t === 'sep') { return '<span class="ac-tab-sep" aria-hidden="true"></span>'; }
      return '<button type="button" class="ac-tab" role="tab" data-tab="' + t.id + '" aria-selected="' + (u.tab === t.id) + '">' + esc(t.label) + (t.test ? '<span class="n">' + counts[t.id] + '</span>' : '') + '</button>';
    }).join('');
  }

  function chip(text, cls, ic) { return '<span class="ac-chip ' + (cls || '') + '" title="' + esc(text) + '">' + (ic ? icon(ic, 12) : '') + '<span>' + esc(text) + '</span></span>'; }

  function cardHtml(r, now, i) {
    var st = AC.statusOf(r, now), pr = AC.priorityOf(r), surf = AC.surfaceOf(r), w = AC.windowOf(r), p = AC.PRIORITY[pr];
    var life = AC.lifecycleOf(r);
    var ack = r.dismiss_behavior === 'acknowledge';
    var surfChip = surf === 'homepage' ? chip('Homepage pop-up', 'home', 'globe') : (surf === 'portal' ? chip('Student portal', '', 'cap') : chip('Homepage + portal', 'home', 'layers'));
    var audType = AC.audienceType(r);
    var audChip = chip(AC.audienceLabel(r), 'ellipsis', audType === 'group' || audType === 'individual' ? 'users' : (audType === 'all' ? 'globe' : 'user'));
    var recur = AC.recurrenceOf(r);
    var badges = '<span class="ac-badge s-' + st + '"><span class="d"></span>' + esc(AC.STATUS[st]) + '</span>' +
      '<span class="ac-badge p-' + pr + '">' + esc(p.label) + '</span>' + surfChip + audChip +
      chip(AC.freqLabel(r), '', 'refresh') + (ack ? chip('Must acknowledge', '', 'check') : '') +
      (recur.type !== 'none' ? chip(recur.type === 'monthly' ? 'Days ' + recur.start + '–' + recur.end + ' monthly' : AC.plural(recur.dates.length, 'set date'), '', 'calendar') : '');
    var published = life === 'draft' ? 'Not published' : (r.published_at ? AC.fmt(r.published_at) : (w.start && w.start <= now ? AC.fmt(w.start) : AC.fmt(r.created_at)));
    var starts = w.start ? AC.fmt(w.start) + ' <em>(' + esc(AC.relative(w.start, now)) + ')</em>' : (life === 'draft' ? 'When published' : 'Immediately');
    var ends = w.end ? AC.fmt(w.end) + ' <em>(' + esc(AC.relative(w.end, now)) + ')</em>' : 'No expiry';
    var excerpt = AC.plain(r.message_html);

    var published_ = (life !== 'draft' && life !== 'archived');
    var control = '';
    if (published_ && (st === 'live' || st === 'scheduled' || st === 'paused')) {
      var on = r.is_active !== false;
      var canToggle = on ? AC.can('pause', r) : AC.can('resume', r);
      control = '<label class="ac-switch" title="' + (canToggle ? 'Switch on or off instantly' : 'Needs the Publish Alerts permission') + '"><input type="checkbox" data-act="toggle" ' + (on ? 'checked' : '') + (canToggle ? '' : ' disabled') + ' aria-label="' + (on ? 'Pause' : 'Resume') + ' alert"><span class="track"></span><span>' + (on ? 'On' : 'Off') + '</span></label>';
    }
    var primary = '';
    if (st === 'draft') { primary = '<button type="button" class="ac-btn ac-btn-primary ac-btn-sm" data-act="publish"' + (AC.can('publish') ? '' : ' disabled title="Needs the Publish Alerts permission"') + '>' + icon('send', 14) + 'Publish</button>'; }
    else if (st === 'scheduled') { primary = '<button type="button" class="ac-btn ac-btn-secondary ac-btn-sm" data-act="publish"' + (AC.can('publish') ? '' : ' disabled') + '>Publish now</button>'; }
    else if (st === 'expired') { primary = '<button type="button" class="ac-btn ac-btn-secondary ac-btn-sm" data-act="republish"' + (AC.can('publish') ? '' : ' disabled') + '>' + icon('restore', 14) + 'Re-publish</button>'; }
    else if (st === 'archived') { primary = '<button type="button" class="ac-btn ac-btn-secondary ac-btn-sm" data-act="restore">' + icon('restore', 14) + 'Restore</button>'; }

    var editable = AC.can('edit', r);
    return '<article class="ac-card" data-id="' + esc(r.id) + '" data-status="' + st + '" style="--ac-pc:' + p.color + ';animation-delay:' + Math.min(i * 30, 240) + 'ms">' +
      '<div class="ac-card-bar"></div>' +
      '<div class="ac-card-main"><div class="ac-card-badges">' + badges + '</div>' +
      '<h3 class="ac-card-title">' + esc(r.title || '(untitled)') + (r.link_url ? '<span class="lnk" title="Has an action button">' + icon('link', 13) + '</span>' : '') + '</h3>' +
      '<p class="ac-card-excerpt">' + esc(excerpt || 'No message text') + '</p>' +
      '<dl class="ac-card-meta">' +
        '<div><dt>Created</dt><dd>' + esc(AC.fmt(r.created_at)) + '</dd></div>' +
        '<div><dt>Published</dt><dd>' + esc(published) + '</dd></div>' +
        '<div><dt>Starts</dt><dd>' + starts + '</dd></div>' +
        '<div><dt>Expires</dt><dd>' + ends + '</dd></div>' +
      '</dl></div>' +
      '<div class="ac-card-actions">' + control + primary +
        '<div class="ac-card-btns">' +
          '<button type="button" class="ac-btn ac-btn-ghost ac-btn-sm" data-act="preview" title="Preview exactly as visitors see it">' + icon('eye', 14) + 'Preview</button>' +
          '<button type="button" class="ac-btn ac-btn-ghost ac-btn-sm" data-act="edit"' + (editable ? '' : ' disabled title="Live alerts can only be edited with the Publish Alerts permission"') + '>' + icon('edit', 14) + 'Edit</button>' +
          '<button type="button" class="ac-btn ac-btn-ghost ac-btn-sm ac-btn-icon" data-act="more" aria-label="More actions" aria-haspopup="menu">' + icon('more', 16) + '</button>' +
        '</div></div></article>';
  }

  function renderList(failed) {
    var host = $('#ac-list'), rows = AC.list.visible(), now = new Date(), u = AC.state.ui;
    var total = AC.state.rows.length;
    $('#ac-count').textContent = failed ? 'Could not load alerts' : (rows.length === total ? AC.plural(total, 'alert') : 'Showing ' + rows.length + ' of ' + AC.plural(total, 'alert'));
    var liveHome = AC.state.rows.filter(function (r) { return AC.statusOf(r, now) === 'live' && AC.surfaceOf(r) !== 'portal'; }).length;
    $('#ac-hint').textContent = liveHome > 3 ? liveHome + ' homepage pop-ups are live - visitors see at most 3 per visit (highest priority first).' : '';
    if (failed) { host.innerHTML = ''; return; }
    if (!rows.length) {
      var filtered = u.q || u.status || u.surface || u.priority || u.audience || u.stat || u.tab !== 'all';
      host.innerHTML = '<div class="ac-empty">' + icon('inbox', 44) +
        '<h3>' + (total && filtered ? 'Nothing matches these filters' : 'No announcements yet') + '</h3>' +
        '<p>' + (total && filtered ? 'Try a different category, or clear the search and filters.' : 'Create your first announcement - for example a homepage pop-up about admissions, or a notice for one student group.') + '</p>' +
        (total && filtered ? '<button type="button" class="ac-btn ac-btn-secondary" data-act="reset">Clear filters</button>' : '<button type="button" class="ac-btn ac-btn-primary" data-act="new">' + icon('plus', 16) + 'New announcement</button>') + '</div>';
      return;
    }
    var slice = rows.slice(0, shown);
    host.innerHTML = slice.map(function (r, i) { return cardHtml(r, now, i); }).join('') +
      (rows.length > shown ? '<div style="text-align:center;padding:10px"><button type="button" class="ac-btn ac-btn-secondary" data-act="more-rows">Show ' + Math.min(PAGE, rows.length - shown) + ' more (' + (rows.length - shown) + ' hidden)</button></div>' : '');
  }

  /* ======================================================================
     Tabs, filters and events
     ====================================================================== */
  AC.list.setTab = function (id) {
    var t = tabDef(id); if (!t) { return; }
    AC.state.ui.tab = id; shown = PAGE; persist();
    var view = t.view || 'alerts';
    $('#ac-view-alerts').hidden = view !== 'alerts';
    $('#ac-view-templates').hidden = view !== 'templates';
    $('#ac-view-analytics').hidden = view !== 'analytics';
    AC.list.renderAll();
    if (view === 'templates') { AC.extras.renderTemplates(); }
    if (view === 'analytics') { AC.extras.renderAnalytics(); }
  };

  function syncFilters() {
    var u = AC.state.ui;
    u.status = $('#ac-f-status').value; u.surface = $('#ac-f-surface').value; u.priority = $('#ac-f-priority').value;
    u.audience = $('#ac-f-audience').value; u.sort = $('#ac-sort').value; shown = PAGE; persist();
    AC.list.renderAll();
  }
  AC.list.resetFilters = function () {
    var u = AC.state.ui; u.q = ''; u.status = u.surface = u.priority = u.audience = u.stat = ''; u.tab = 'all'; u.sort = 'newest';
    $('#ac-q').value = ''; ['#ac-f-status', '#ac-f-surface', '#ac-f-priority', '#ac-f-audience'].forEach(function (s) { $(s).value = ''; }); $('#ac-sort').value = 'newest';
    AC.list.setTab('all');
  };

  AC.list.bind = function () {
    $('#ac-tabs').addEventListener('click', function (e) { var b = e.target.closest('[data-tab]'); if (b) { AC.state.ui.stat = ''; AC.list.setTab(b.getAttribute('data-tab')); } });
    $('#ac-stats').addEventListener('click', function (e) {
      var b = e.target.closest('[data-stat]'); if (!b) { return; }
      var u = AC.state.ui, id = b.getAttribute('data-stat');
      u.stat = u.stat === id ? '' : id; u.tab = 'all'; u.status = ''; $('#ac-f-status').value = '';
      AC.list.setTab('all');
    });
    $('#ac-q').addEventListener('input', AC.debounce(function () { AC.state.ui.q = $('#ac-q').value; shown = PAGE; AC.list.renderAll(); }, 160));
    ['#ac-f-status', '#ac-f-surface', '#ac-f-priority', '#ac-f-audience', '#ac-sort'].forEach(function (s) { $(s).addEventListener('change', function () { AC.state.ui.stat = ''; syncFilters(); }); });
    $('#ac-reset').addEventListener('click', AC.list.resetFilters);
    $('#ac-refresh').addEventListener('click', function () { AC.reload().then(function (ok) { if (ok) { AC.ui.toast('Alerts refreshed', 'info', 1800); } }); });
    $('#ac-new-btn').addEventListener('click', function () { AC.composer.open(null); });
    $('#ac-guide-btn').addEventListener('click', AC.list.showGuide);
    $('#ac-list').addEventListener('click', onListClick);
    $('#ac-list').addEventListener('change', onListChange);
    document.addEventListener('keydown', function (e) {
      if (e.key === '/' && !/^(INPUT|TEXTAREA|SELECT)$/.test((document.activeElement || {}).tagName) && !(document.activeElement || {}).isContentEditable && !document.querySelector('.ac-drawer.open, .ac-modal-back')) {
        e.preventDefault(); $('#ac-q').focus();
      }
    });
  };

  function rowFrom(el) { var c = el.closest('.ac-card'); return c ? AC.data.byId(c.getAttribute('data-id')) : null; }

  function onListClick(e) {
    var b = e.target.closest('[data-act]'); if (!b || b.tagName === 'INPUT') { return; }
    var act = b.getAttribute('data-act');
    if (act === 'reset') { return AC.list.resetFilters(); }
    if (act === 'new') { return AC.composer.open(null); }
    if (act === 'more-rows') { shown += PAGE; return renderList(); }
    var row = rowFrom(b); if (!row) { return; }
    if (act === 'preview') { return AC.list.previewRow(row); }
    if (act === 'edit') { return AC.composer.open(row); }
    if (act === 'publish') { return publishNow(row); }
    if (act === 'republish') { return AC.composer.open(row, { republish: true }); }
    if (act === 'restore') { return restoreRow(row); }
    if (act === 'more') { return openMore(b, row); }
  }
  function onListChange(e) {
    var t = e.target; if (t.getAttribute('data-act') !== 'toggle') { return; }
    var row = rowFrom(t); if (row) { setActive(row, t.checked, t); }
  }

  function openMore(anchor, row) {
    var st = AC.statusOf(row), surf = AC.surfaceOf(row), life = AC.lifecycleOf(row);
    var published = life === 'published';
    AC.ui.menu(anchor, [
      { label: 'Duplicate as new draft', icon: 'copy', onClick: function () { AC.composer.open(null, { from: row }); } },
      { label: 'View analytics', icon: 'chart', onClick: function () { AC.extras.showAnalytics(row.id); } },
      surf !== 'portal' ? { label: 'Test on the real homepage', icon: 'external', onClick: function () { window.open('index.html?acnhs_alert_preview=' + encodeURIComponent(row.id), '_blank'); } } : null,
      published && (st === 'live' || st === 'scheduled') ? { label: 'Re-show to everyone', icon: 'refresh', disabled: !AC.can('reshow'), hint: 'Visitors and students who already closed it will see it again', onClick: function () { reshowRow(row); } } : null,
      '-',
      life === 'archived'
        ? { label: 'Restore as draft', icon: 'restore', onClick: function () { restoreRow(row); } }
        : { label: 'Archive', icon: 'archive', onClick: function () { archiveRow(row); } },
      { label: 'Delete permanently…', icon: 'trash', danger: true, disabled: !AC.can('delete'), hint: AC.can('delete') ? '' : 'Needs the Publish Alerts permission', onClick: function () { deleteRow(row); } }
    ].filter(Boolean));
  }

  /* ======================================================================
     Row actions
     ====================================================================== */
  function me() { return AC.state.user.email; }

  async function patchRow(row, patch, okMsg) {
    try {
      if (!AC.state.schema.ready) { patch = AC.data.stripV2(patch); }
      var updated = await AC.data.update(row.id, patch);
      AC.list.renderAll();
      if (okMsg) { AC.ui.toast(okMsg, 'ok'); }
      return updated;
    } catch (e) {
      console.error('Alert Center: update failed', e);
      AC.ui.toast(AC.explain(e), 'err');
      AC.list.renderAll();
      return null;
    }
  }

  async function setActive(row, on, input) {
    var patch = AC.state.schema.ready ? { is_active: on, updated_by: me() } : { is_active: on };
    var updated = await patchRow(row, patch);
    if (updated) { AC.ui.toast(on ? 'Alert resumed' : 'Alert paused - it is no longer shown', on ? 'ok' : 'info'); }
    else if (input) { input.checked = !on; }
  }

  function modelOf(r) {
    var w = AC.windowOf(r), rec = AC.recurrenceOf(r);
    return {
      surface: AC.surfaceOf(r), audience: AC.audienceType(r), groups: AC.audienceGroups(r), students: AC.audienceStudents(r).length,
      priority: AC.priorityOf(r), dismiss: r.dismiss_behavior || 'dismissible', popfreq: r.popup_frequency || 'once_per_session',
      portalFreq: (AC.json(r.frequency_rules).cap_type || r.display_mode || 'once_ever'), start: w.start, end: w.end,
      repeat: rec.type === 'monthly' ? 'monthly' : (rec.type === 'custom' ? 'custom' : 'none'), repeatDays: rec.start + '–' + rec.end,
      cta: r.link_url ? (r.link_label || 'Learn More') : ''
    };
  }
  AC.list.modelOf = modelOf;

  AC.list.confirmPublic = function (row, model, verb) {
    var items = AC.describe(model || modelOf(row), 'draft').map(function (d) { return '<li' + (d.warn ? ' style="color:#fcd34d"' : '') + '>' + esc(d.text) + '</li>'; }).join('');
    return AC.ui.confirm({
      title: verb + ' this announcement?',
      html: '<p><b>' + esc(row.title || '') + '</b></p><ul>' + items + '</ul>' + (AC.surfaceOf(row) !== 'portal' ? '<p style="color:var(--ac-gold-2)">This will be visible on the public website, so please check the wording and links.</p>' : ''),
      confirmText: verb, cancelText: 'Not yet'
    });
  };

  async function publishNow(row) {
    if (!AC.can('publish')) { return AC.ui.toast('Publishing needs the "Publish Alerts" permission.', 'err'); }
    var w = AC.windowOf(row);
    if (w.end && w.end <= new Date()) {
      var go = await AC.ui.confirm({ title: 'This alert has already expired', message: 'Its expiry time (' + AC.fmt(w.end) + ') has passed, so publishing now would end it immediately. Open the editor to choose a new expiry?', confirmText: 'Open editor' });
      if (go) { AC.composer.open(row, { republish: true }); }
      return;
    }
    var st = AC.statusOf(row);
    var m = modelOf(row); m.start = null;
    if (AC.surfaceOf(row) !== 'portal') {
      if (!(await AC.list.confirmPublic(row, m, st === 'scheduled' ? 'Publish now' : 'Publish'))) { return; }
    }
    var patch = { lifecycle_status: 'published', is_active: true, publish_at: st === 'scheduled' ? null : row.publish_at, published_by: me(), updated_by: me() };
    var u = await patchRow(row, patch, 'Published - it is live now');
    return u;
  }

  async function archiveRow(row) {
    var ok = await AC.ui.confirm({ title: 'Archive this alert?', message: 'It stops being shown immediately and moves to "Expired & archived". You can restore it later as a draft.', confirmText: 'Archive' });
    if (!ok) { return; }
    await patchRow(row, { lifecycle_status: 'archived', is_active: false, archived_by: me(), updated_by: me() }, 'Archived');
  }
  async function restoreRow(row) {
    await patchRow(row, { lifecycle_status: 'draft', is_active: false, updated_by: me() }, 'Restored as a draft - review it, then publish');
  }

  async function deleteRow(row) {
    var st = AC.statusOf(row);
    var ok = await AC.ui.confirm({
      title: 'Delete permanently?', danger: true, confirmText: 'Delete forever',
      html: '<p><b>' + esc(row.title || '') + '</b></p><p>This removes the alert' + (st === 'live' ? ' <b>(it is live right now and disappears immediately)</b>' : '') + ' together with its student views and answers. This cannot be undone.</p><p style="color:var(--ac-muted)">Tip: use <b>Archive</b> if you may need it again.</p>'
    });
    if (!ok) { return; }
    try { await AC.data.remove(row.id); AC.list.renderAll(); AC.ui.toast('Alert deleted', 'ok'); }
    catch (e) { AC.ui.toast(AC.explain(e), 'err'); }
  }

  async function reshowRow(row) {
    var ok = await AC.ui.confirm({ title: 'Show this alert again?', message: 'Everyone who already closed or acknowledged it will see it again: homepage visitors on their next visit and students the next time they open the portal.', confirmText: 'Show again' });
    if (!ok) { return; }
    try {
      if (AC.state.schema.ready) { await AC.data.update(row.id, { revision: (row.revision || 1) + 1, updated_by: me() }); }
      if (AC.surfaceOf(row) !== 'homepage') {
        var del = await AC.state.db.from('portal_alert_impressions').delete().eq('alert_id', row.id);
        if (del.error) { throw del.error; }
      }
      AC.list.renderAll(); AC.ui.toast('Done - the alert will be shown again', 'ok');
    } catch (e) { AC.ui.toast(AC.explain(e), 'err'); }
  }

  /* ======================================================================
     Guide: lifecycle, workflow and permissions (so the rules are visible in the product)
     ====================================================================== */
  AC.list.showGuide = function () {
    var p = AC.state.perms, role = p.main ? 'main' : (p.publish ? 'publisher' : 'editor');
    var statusRows = [
      ['draft', 'Being written. Never visible to anyone.'],
      ['scheduled', 'Published with a future start. Goes live automatically.'],
      ['live', 'Published, switched on and inside its dates. People see it.'],
      ['paused', 'Switched off with the toggle. Resume any time.'],
      ['expired', 'The expiry time has passed. Re-publish with a new expiry.'],
      ['archived', 'Retired and kept for the record. Restore as a draft.']
    ].map(function (r) { return '<li><span class="ac-badge s-' + r[0] + '"><span class="d"></span>' + esc(AC.STATUS[r[0]]) + '</span><span>' + esc(r[1]) + '</span></li>'; }).join('');
    var yes = '<span style="color:var(--ac-live)">✓</span>', no = '<span style="color:var(--ac-dim)">–</span>';
    var matrix = [
      ['Open the Alert Center, view alerts, analytics, templates', 1, 1, 1],
      ['Create and edit drafts, duplicate, preview, save templates', 1, 1, 1],
      ['Pause (switch off), archive, restore', 1, 1, 1],
      ['Publish, schedule, switch on, publish drafts', 1, 1, 0],
      ['Edit live or scheduled alerts', 1, 1, 0],
      ['Re-show to everyone', 1, 1, 0],
      ['Delete permanently', 1, 1, 0]
    ].map(function (r) {
      return '<tr><td>' + esc(r[0]) + '</td>' + [1, 2, 3].map(function (i, k) { return '<td style="text-align:center' + (['main', 'publisher', 'editor'][k] === role ? ';background:var(--ac-gold-soft)' : '') + '">' + (r[i] ? yes : no) + '</td>'; }).join('') + '</tr>';
    }).join('');
    var m = AC.ui.modal(
      '<div class="ac-modal-head"><h3>How alerts work</h3></div>' +
      '<div class="ac-modal-body ac-guide">' +
      '<h4>Statuses</h4><ul class="ac-guide-list">' + statusRows + '</ul>' +
      '<h4>Publishing workflow</h4><ol><li><b>Write</b> the title and message, choose where it appears and who sees it.</li><li><b>Preview</b> the exact pop-up (desktop or phone, visitor or student), or test it on the real homepage.</li><li><b>Save a draft</b>, or <b>Publish</b> now / schedule it for later. Public homepage alerts ask for a final confirmation.</li><li><b>Operate</b> from the dashboard: switch off instantly, edit, re-show, archive or delete.</li></ol>' +
      '<h4>Who can do what</h4><div class="ac-table-wrap"><table class="ac-table"><thead><tr><th>Action</th><th>Main administrator</th><th>Publisher</th><th>Editor</th></tr></thead><tbody>' + matrix + '</tbody></table></div>' +
      '<p class="ac-help">Your role: <b>' + esc({ main: 'Main administrator', publisher: 'Alert publisher', editor: 'Alert editor' }[role]) + '</b>. Permissions are granted in Admin Users → <i>Announcements &amp; Alerts</i> (Manage Alerts = editor, Publish Alerts = publisher).</p></div>' +
      '<div class="ac-modal-foot"><a class="ac-btn ac-btn-ghost" href="HOMEPAGE-POPUP-ALERTS-SETUP.md" target="_blank" rel="noopener">Full guide</a><button type="button" class="ac-btn ac-btn-primary" data-close data-autofocus>Got it</button></div>',
      { wide: true, label: 'How alerts work' }
    );
    $('[data-close]', m.el).addEventListener('click', function () { m.close(); });
  };

  /* ======================================================================
     Preview dialog (uses the real homepage renderer)
     ====================================================================== */
  AC.list.previewRow = function (row) {
    var m = AC.ui.modal(
      '<div class="ac-modal-head"><h3>Preview</h3></div>' +
      '<div class="ac-modal-body"><div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:12px">' +
      '<span class="ac-mini-seg"><button type="button" data-dev="desktop" aria-pressed="true">Desktop</button><button type="button" data-dev="mobile" aria-pressed="false">Phone</button></span>' +
      '<span class="ac-mini-seg"><button type="button" data-who="visitor" aria-pressed="true">Visitor</button><button type="button" data-who="student" aria-pressed="false">Student</button></span></div>' +
      '<div class="ac-stage-wrap" style="border-radius:12px"><div class="ac-stage" data-device="desktop"><div class="ac-stage-page" aria-hidden="true"><i class="nav"></i><i class="hero"></i><i class="w80"></i><i class="w60"></i></div><div class="ac-stage-host"></div></div></div>' +
      (AC.surfaceOf(row) === 'portal' ? '<p class="ac-help">Student-portal alerts use the portal display style "' + esc(row.display_position || 'modal') + '". The content and priority styling are shown here.</p>' : '') + '</div>' +
      '<div class="ac-modal-foot"><button type="button" class="ac-btn ac-btn-ghost" data-close>Close</button></div>',
      { wide: true, label: 'Alert preview', focus: '[data-close]' }
    );
    var stage = $('.ac-stage', m.el), host = $('.ac-stage-host', m.el), state = { dev: 'desktop', student: false }, handle;
    function paint() {
      stage.setAttribute('data-device', state.dev);
      var data = { title: row.title, message_html: row.message_html, priority: AC.priorityOf(row), severity: row.severity, link_url: row.link_url, link_label: row.link_label, link_new_tab: row.link_new_tab, dismiss_behavior: row.dismiss_behavior, acknowledge_label: row.acknowledge_label };
      var opts = { student: state.student, compact: state.dev === 'mobile' };
      if (handle) { handle.update(data, opts); } else if (global.ACNHSHomepageAlerts) { handle = global.ACNHSHomepageAlerts.mountPreview(host, data, opts); }
    }
    $$('[data-dev]', m.el).forEach(function (b) { b.addEventListener('click', function () { state.dev = b.getAttribute('data-dev'); $$('[data-dev]', m.el).forEach(function (x) { x.setAttribute('aria-pressed', String(x === b)); }); paint(); }); });
    $$('[data-who]', m.el).forEach(function (b) { b.addEventListener('click', function () { state.student = b.getAttribute('data-who') === 'student'; $$('[data-who]', m.el).forEach(function (x) { x.setAttribute('aria-pressed', String(x === b)); }); paint(); }); });
    $('[data-close]', m.el).addEventListener('click', function () { m.close(); });
    paint();
  };

})(window);
