/*
 * Return to where a profile was opened on the staff directory.
 * staff.html remembers which profile link was clicked and how far the page was scrolled. When the visitor comes back
 * through "Faculty & Staff" on that profile, the directory reopens at the same spot instead of at the top.
 * Every other way of reaching staff.html (address bar, bookmark, other links) is left alone.
 */
(function () {
  'use strict';

  var KEY = 'acnhs-staff-return';
  var GO_WINDOW_MS = 60 * 1000; // a "Faculty & Staff" click only counts for the page load that follows it

  function read() { try { return JSON.parse(sessionStorage.getItem(KEY)); } catch (e) { return null; } }
  function write(rec) { try { sessionStorage.setItem(KEY, JSON.stringify(rec)); } catch (e) { /* storage blocked: links behave normally */ } }
  function clear() { try { sessionStorage.removeItem(KEY); } catch (e) { /* ignore */ } }
  function slug(url) { return String(url).split('#')[0].split('?')[0].replace(/\/+$/, '').split('/').pop().replace(/\.html$/i, ''); }
  function pageTop(el) { var top = 0; for (; el; el = el.offsetParent) top += el.offsetTop; return top; }

  function initDirectory() {
    var box = document.querySelector('.staff-container');
    if (!box) return;
    var links = Array.prototype.slice.call(box.querySelectorAll('a[href]'));

    // Remember which link was clicked and where the page was scrolled at that moment.
    document.addEventListener('click', function (e) {
      var a = e.target.closest ? e.target.closest('a[href]') : null;
      var idx = a ? links.indexOf(a) : -1;
      if (idx < 0) return;
      var href = a.getAttribute('href');
      if (/^([a-z][a-z0-9+.-]*:|#)/i.test(href)) return;
      write({ page: slug(href), idx: idx, y: window.pageYOffset, top: pageTop(a) });
    });

    var rec = read();
    if (!rec || !rec.go || Date.now() - rec.go > GO_WINDOW_MS) return;
    clear();

    var link = links[rec.idx];
    var sameLink = !!link && slug(link.getAttribute('href')) === rec.page;

    function jump() {
      var y = sameLink ? rec.y + (pageTop(link) - rec.top) : rec.y; // follow the link if the layout above it has moved
      var root = document.documentElement, prev = root.style.scrollBehavior;
      root.style.scrollBehavior = 'auto'; // the page uses scroll-behavior:smooth; this jump must be instant
      window.scrollTo(0, Math.max(0, y));
      root.style.scrollBehavior = prev;
    }
    jump();

    // Fonts and images can still shift the layout; re-apply until the visitor scrolls on their own.
    var touched = false;
    ['wheel', 'touchstart', 'keydown', 'mousedown'].forEach(function (type) {
      window.addEventListener(type, function () { touched = true; }, { passive: true, once: true });
    });
    function again() { if (!touched) jump(); }
    if (document.readyState === 'complete') again(); else window.addEventListener('load', again);
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(again);
  }

  function initProfile() {
    var here = slug(location.pathname);
    document.addEventListener('click', function (e) {
      var a = e.target.closest ? e.target.closest('a[href="staff.html"]') : null;
      if (!a) return;
      var rec = read();
      if (rec && rec.page === here) { rec.go = Date.now(); write(rec); }
    });
  }

  if (slug(location.pathname) === 'staff') initDirectory(); else initProfile();
})();
