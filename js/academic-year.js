/*
 * ACNHS academic-year display.
 * The academic year runs September 1 - August 31 and is always evaluated in Armenia time
 * (Asia/Yerevan), so every visitor sees the same year whatever their own time zone is.
 * Fills any element with id="acnhs-academic-year" or a data-acnhs-academic-year attribute and keeps it
 * current, including when the page stays open across the September 1 rollover.
 */
(function () {
  'use strict';

  var TIME_ZONE = 'Asia/Yerevan';
  var FALLBACK_OFFSET_MS = 4 * 60 * 60 * 1000; // Armenia is UTC+4 all year; used only if Intl has no time-zone support
  var MAX_WAIT_MS = 60 * 60 * 1000;            // wake at least hourly so sleep or clock changes can't leave it stale
  var SELECTOR = '#acnhs-academic-year, [data-acnhs-academic-year]';

  var formatter = null;
  try {
    formatter = new Intl.DateTimeFormat('en-US', {
      timeZone: TIME_ZONE, hour12: false,
      year: 'numeric', month: 'numeric', day: 'numeric',
      hour: 'numeric', minute: 'numeric', second: 'numeric'
    });
    formatter.formatToParts(0);
  } catch (e) {
    formatter = null;
  }

  // Calendar and clock fields of an instant (ms since epoch) as seen in Armenia.
  function armeniaTime(ms) {
    var t = { year: 0, month: 0, day: 0, hour: 0, minute: 0, second: 0 };
    if (formatter) {
      var parts = formatter.formatToParts(ms);
      for (var i = 0; i < parts.length; i++) {
        if (t.hasOwnProperty(parts[i].type)) t[parts[i].type] = parseInt(parts[i].value, 10);
      }
      t.hour = t.hour % 24; // some engines print midnight as 24
      return t;
    }
    var d = new Date(ms + FALLBACK_OFFSET_MS);
    t.year = d.getUTCFullYear(); t.month = d.getUTCMonth() + 1; t.day = d.getUTCDate();
    t.hour = d.getUTCHours(); t.minute = d.getUTCMinutes(); t.second = d.getUTCSeconds();
    return t;
  }

  // September-December belong to the year that just started; January-August to the one that began last September.
  function startYear(ms) {
    var t = armeniaTime(ms === undefined ? Date.now() : ms);
    return t.month >= 9 ? t.year : t.year - 1;
  }

  function label(ms) {
    var y = startYear(ms);
    return 'Academic Year ' + y + '\u2013' + (y + 1) + '.';
  }

  var timer = null;

  function update() {
    clearTimeout(timer);
    var now = Date.now();
    var text = label(now);
    var els = document.querySelectorAll(SELECTOR);
    for (var i = 0; i < els.length; i++) {
      if (els[i].textContent !== text) els[i].textContent = text;
    }

    // Sleep until the next September 1, 00:00 Armenia time (or an hour, whichever is sooner), then re-evaluate.
    var t = armeniaTime(now);
    var rolloverYear = t.month >= 9 ? t.year + 1 : t.year;
    var wallNow = Date.UTC(t.year, t.month - 1, t.day, t.hour, t.minute, t.second) + (now % 1000);
    var wait = Date.UTC(rolloverYear, 8, 1) - wallNow;
    timer = setTimeout(update, Math.max(50, Math.min(wait + 50, MAX_WAIT_MS)));
  }

  function start() {
    update();
    document.addEventListener('visibilitychange', function () { if (!document.hidden) update(); });
    window.addEventListener('pageshow', function (e) { if (e.persisted) update(); });
  }

  window.ACNHSAcademicYear = { startYear: startYear, label: label, refresh: update };

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start);
  else start();
})();
