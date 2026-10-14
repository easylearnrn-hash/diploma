/**
 * ACNHS Alert Center - templates and analytics  (js/alert-admin-extras.js)
 */
(function (global) {
  'use strict';

  var AC = global.AC = global.AC || {};
  var esc = AC.esc, icon = AC.icon, $ = AC.$, $$ = AC.$$;

  var X = AC.extras = { templatesLoaded: false, templates: [], analyticsId: null };

  X.bind = function () { /* views are rendered on demand */ };

  /* ======================================================================
     Templates
     ====================================================================== */
  X.renderTemplates = async function () {
    var host = $('#ac-view-templates');
    host.innerHTML = '<div class="ac-panel"><h2>Templates</h2><p class="sub">Reusable messages. Open the editor, write an announcement, then choose <b>Save as template</b>.</p><div class="ac-tpl-grid" id="ac-tpl-grid"><div class="ac-skeleton"></div><div class="ac-skeleton"></div></div></div>';
    if (!X.templatesLoaded) {
      var res = await AC.state.db.from('portal_alert_templates').select('*').order('created_at', { ascending: false });
      if (res.error) { $('#ac-tpl-grid').innerHTML = '<div class="ac-empty" style="grid-column:1/-1"><h3>Could not load templates</h3><p>' + esc(AC.explain(res.error)) + '</p></div>'; return; }
      X.templates = res.data || []; X.templatesLoaded = true;
    }
    var grid = $('#ac-tpl-grid');
    if (!X.templates.length) { grid.innerHTML = '<div class="ac-empty" style="grid-column:1/-1">' + icon('file', 40) + '<h3>No templates yet</h3><p>Save an announcement as a template to reuse it.</p></div>'; return; }
    grid.innerHTML = X.templates.map(function (t) {
      var pr = t.severity === 'critical' ? 'critical' : (t.severity === 'warn' ? 'important' : 'normal');
      return '<article class="ac-tpl" data-id="' + esc(t.id) + '"><div style="display:flex;justify-content:space-between;gap:8px;align-items:flex-start"><h4>' + esc(t.template_name) + '</h4>' +
        '<span class="ac-badge p-' + pr + '">' + esc(AC.PRIORITY[pr].label) + '</span></div>' +
        '<div class="t">' + esc(t.title) + '</div><div class="excerpt">' + esc(AC.plain(t.message_html)) + '</div>' +
        '<div class="row"><button type="button" class="ac-btn ac-btn-primary ac-btn-sm" data-use>' + icon('plus', 14) + 'Use template</button>' +
        '<button type="button" class="ac-btn ac-btn-ghost ac-btn-sm" data-del aria-label="Delete template ' + esc(t.template_name) + '">' + icon('trash', 14) + '</button></div></article>';
    }).join('');
    grid.onclick = async function (e) {
      var card = e.target.closest('.ac-tpl'); if (!card) { return; }
      var t = X.templates.find(function (x) { return String(x.id) === card.getAttribute('data-id'); }); if (!t) { return; }
      if (e.target.closest('[data-use]')) { AC.composer.open(null, { template: t }); }
      if (e.target.closest('[data-del]')) {
        var ok = await AC.ui.confirm({ title: 'Delete template?', message: 'Template "' + t.template_name + '" will be removed. Alerts created from it are not affected.', confirmText: 'Delete', danger: true });
        if (!ok) { return; }
        var r = await AC.state.db.from('portal_alert_templates').delete().eq('id', t.id);
        if (r.error) { return AC.ui.toast(AC.explain(r.error), 'err'); }
        X.templates = X.templates.filter(function (x) { return x.id !== t.id; });
        AC.ui.toast('Template deleted', 'ok'); X.renderTemplates();
      }
    };
  };

  /* ======================================================================
     Analytics
     ====================================================================== */
  X.showAnalytics = function (id) { X.analyticsId = id; AC.state.ui.stat = ''; AC.list.setTab('analytics'); };

  X.renderAnalytics = function () {
    var host = $('#ac-view-analytics');
    var rows = AC.state.rows.slice().sort(function (a, b) { return (Date.parse(b.created_at) || 0) - (Date.parse(a.created_at) || 0); });
    host.innerHTML = '<div class="ac-panel"><h2>Analytics</h2><p class="sub">See which signed-in students viewed an alert and how they answered. Anonymous homepage visitors are not tracked.</p>' +
      '<label class="ac-label" for="ac-an-select">Alert</label>' +
      '<select class="ac-select" id="ac-an-select" style="max-width:560px"><option value="">Choose an alert…</option>' +
      rows.map(function (r) { return '<option value="' + esc(r.id) + '">' + esc((r.title || '(untitled)') + ' — ' + AC.STATUS[AC.statusOf(r)]) + '</option>'; }).join('') + '</select></div>' +
      '<div id="ac-an-body"></div>';
    var sel = $('#ac-an-select');
    sel.addEventListener('change', function () { X.analyticsId = sel.value || null; loadAnalytics(); });
    if (X.analyticsId && rows.some(function (r) { return r.id === X.analyticsId; })) { sel.value = X.analyticsId; loadAnalytics(); }
    else { $('#ac-an-body').innerHTML = '<div class="ac-empty" style="margin-top:16px">' + icon('chart', 40) + '<h3>Pick an alert</h3><p>Choose an alert above, or use "View analytics" from the ⋯ menu on any alert card.</p></div>'; }
  };

  async function loadAnalytics() {
    var body = $('#ac-an-body'), id = X.analyticsId;
    if (!id) { body.innerHTML = ''; return; }
    var row = AC.data.byId(id); if (!row) { return; }
    body.innerHTML = '<div class="ac-panel"><div class="ac-skeleton"></div></div>';
    try {
      var db = AC.state.db;
      var counts = await db.from('portal_alert_impressions').select('*', { count: 'exact', head: true }).eq('alert_id', id);
      var resp = await db.from('portal_alert_responses').select('*, students(full_name, student_id, email)').eq('alert_id', id);
      if (resp.error) { throw resp.error; }
      var imps = await db.from('portal_alert_impressions').select('*, students(full_name, student_id, email)').eq('alert_id', id).order('shown_at', { ascending: false }).limit(1000);
      var responses = resp.data || [], impressions = imps.data || [];
      var yes = responses.filter(function (r) { return r.answer === 'yes'; }), no = responses.filter(function (r) { return r.answer === 'no'; });
      var viewCount = counts.count != null ? counts.count : impressions.length;
      var st = AC.statusOf(row);
      body.innerHTML = '<div class="ac-panel"><div style="display:flex;justify-content:space-between;gap:12px;flex-wrap:wrap;align-items:flex-start"><div><h3>' + esc(row.title) + '</h3>' +
        '<div style="display:flex;gap:6px;flex-wrap:wrap;margin-top:6px"><span class="ac-badge s-' + st + '"><span class="d"></span>' + esc(AC.STATUS[st]) + '</span><span class="ac-chip">' + esc(AC.SURFACE[AC.surfaceOf(row)]) + '</span><span class="ac-chip">' + esc(AC.audienceLabel(row)) + '</span></div></div></div>' +
        '<div class="ac-kpis"><button type="button" class="ac-kpi" data-k="views"><b>' + viewCount + '</b><span>Student views</span></button>' +
        '<button type="button" class="ac-kpi" data-k="yes"><b>' + yes.length + '</b><span>Yes answers</span></button>' +
        '<button type="button" class="ac-kpi" data-k="no"><b>' + no.length + '</b><span>No answers</span></button>' +
        '<button type="button" class="ac-kpi" data-k="all"><b>' + responses.length + '</b><span>All answers</span></button></div>' +
        (AC.surfaceOf(row) !== 'portal' ? '<p class="ac-help">Homepage pop-ups are recorded here only when the visitor is a signed-in student. Anonymous visitors are not tracked.</p>' : '') +
        (responses.length ? '<h3 style="margin-top:18px">Answers</h3>' + studentTable(responses, 'answered_at', true) : '') + '</div>';
      $$('.ac-kpi', body).forEach(function (b) {
        b.addEventListener('click', function () {
          var k = b.getAttribute('data-k');
          if (k === 'views') { listModal('Students who viewed', impressions, 'shown_at'); }
          else if (k === 'yes') { listModal('Answered yes', yes, 'answered_at'); }
          else if (k === 'no') { listModal('Answered no', no, 'answered_at'); }
          else { listModal('All answers', responses, 'answered_at'); }
        });
      });
    } catch (e) {
      console.error('Alert Center: analytics failed', e);
      body.innerHTML = '<div class="ac-empty" style="margin-top:16px"><h3>Could not load analytics</h3><p>' + esc(AC.explain(e)) + '</p></div>';
    }
  }

  function studentTable(list, dateField, withAnswer) {
    return '<div class="ac-table-wrap" style="margin-top:8px"><table class="ac-table"><thead><tr><th>#</th><th>Student</th><th>ID</th><th>Email</th>' + (withAnswer ? '<th>Answer</th>' : '') + '<th>When</th></tr></thead><tbody>' +
      list.map(function (r, i) {
        var s = r.students || {};
        return '<tr><td>' + (i + 1) + '</td><td>' + esc(s.full_name || 'N/A') + '</td><td>' + esc(s.student_id || 'N/A') + '</td><td>' + esc(s.email || 'N/A') + '</td>' +
          (withAnswer ? '<td><span class="ac-badge ' + (r.answer === 'yes' ? 's-live' : 's-paused') + '">' + esc(r.answer || '') + '</span></td>' : '') +
          '<td>' + esc(r[dateField] ? AC.fmt(r[dateField]) : '') + '</td></tr>';
      }).join('') + '</tbody></table></div>';
  }

  function listModal(title, list, dateField) {
    var m = AC.ui.modal('<div class="ac-modal-head"><h3>' + esc(title) + '</h3><p style="margin:4px 0 0;color:var(--ac-muted)">' + AC.plural(list.length, 'student') + '</p></div>' +
      '<div class="ac-modal-body">' + (list.length ? studentTable(list, dateField, dateField === 'answered_at') : '<div class="ac-empty" style="padding:30px">' + icon('inbox', 36) + '<p>No students to show yet.</p></div>') + '</div>' +
      '<div class="ac-modal-foot"><button type="button" class="ac-btn ac-btn-ghost" data-close data-autofocus>Close</button></div>', { wide: true, label: title });
    AC.$('[data-close]', m.el).addEventListener('click', function () { m.close(); });
  }

})(window);
