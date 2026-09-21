/* Popup docs media: lazy-load recordings, play only what is visible, honor reduced motion. Plain JS, no libraries. */
(function () {
  'use strict';
  var mq = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : null;
  function reduced() { return !!(mq && mq.matches); }

  function setToggle(fig, playing) {
    var btn = fig.querySelector('.clip-toggle');
    if (!btn) return;
    var name = fig.getAttribute('data-title') || 'clip';
    btn.textContent = playing ? 'Pause' : 'Play';
    btn.setAttribute('aria-label', (playing ? 'Pause: ' : 'Play: ') + name);
    fig.classList.toggle('is-paused', !playing);
  }

  function prepare(v) {
    if (v.getAttribute('data-ready')) return;
    v.setAttribute('data-ready', '1');
    var p = v.getAttribute('data-poster');
    if (p && !v.getAttribute('poster')) v.setAttribute('poster', p);
  }

  function attach(v) {
    if (v.getAttribute('data-attached')) return;
    v.setAttribute('data-attached', '1');
    var s = v.querySelector('source');
    if (s && !s.getAttribute('src')) { s.setAttribute('src', s.getAttribute('data-src')); v.load(); }
  }

  function play(v, fig) {
    attach(v);
    var r = v.play();
    if (r && r.catch) r.catch(function () { setToggle(fig, false); });
    setToggle(fig, true);
  }
  function pause(v, fig) { v.pause(); setToggle(fig, false); }

  var figs = Array.prototype.slice.call(document.querySelectorAll('figure.clip'));
  figs.forEach(function (fig) {
    var v = fig.querySelector('video');
    var btn = fig.querySelector('.clip-toggle');
    if (!v) return;
    if (reduced()) { v.removeAttribute('loop'); }
    setToggle(fig, false);
    if (btn) btn.addEventListener('click', function () {
      if (v.paused) { v.removeAttribute('data-user-paused'); play(v, fig); }
      else { v.setAttribute('data-user-paused', '1'); pause(v, fig); }
    });
    v.addEventListener('ended', function () { setToggle(fig, false); });
  });

  if ('IntersectionObserver' in window) {
    var near = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (e.isIntersecting) { var v = e.target.querySelector('video'); if (v) prepare(v); near.unobserve(e.target); }
      });
    }, { rootMargin: '500px 0px' });
    var vis = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        var v = e.target.querySelector('video');
        if (!v) return;
        if (e.isIntersecting) {
          prepare(v);
          if (!reduced() && !v.getAttribute('data-user-paused')) play(v, e.target);
        } else if (!v.paused) {
          pause(v, e.target);
        }
      });
    }, { threshold: 0.45 });
    figs.forEach(function (f) { near.observe(f); vis.observe(f); });
  } else {
    figs.forEach(function (f) { var v = f.querySelector('video'); if (v) prepare(v); });
  }

  document.addEventListener('visibilitychange', function () {
    if (!document.hidden) return;
    figs.forEach(function (f) { var v = f.querySelector('video'); if (v && !v.paused) pause(v, f); });
  });

  /* Montage tiles: hover (mouse) or tap/Enter plays that clip; one at a time. */
  var tiles = Array.prototype.slice.call(document.querySelectorAll('.mt'));
  var active = null;
  function stopTile(t) {
    var v = t.querySelector('video');
    if (v) { v.pause(); v.removeAttribute('src'); v.load(); v.parentNode.removeChild(v); }
    t.classList.remove('is-playing');
    t.__pinned = false;
    t.setAttribute('aria-pressed', 'false');
    if (active === t) active = null;
  }
  function startTile(t) {
    if (active && active !== t) stopTile(active);
    if (t.classList.contains('is-playing')) return;
    var v = document.createElement('video');
    v.muted = true; v.loop = true; v.playsInline = true; v.setAttribute('playsinline', ''); v.preload = 'none';
    v.setAttribute('aria-hidden', 'true');
    v.src = t.getAttribute('data-src');
    t.querySelector('.mt-media').appendChild(v);
    var r = v.play(); if (r && r.catch) r.catch(function () {});
    t.classList.add('is-playing');
    t.setAttribute('aria-pressed', 'true');
    active = t;
  }
  tiles.forEach(function (t) {
    t.setAttribute('aria-pressed', 'false');
    t.addEventListener('pointerenter', function (e) { if (e.pointerType === 'mouse' && !reduced()) startTile(t); });
    t.addEventListener('pointerleave', function (e) { if (e.pointerType === 'mouse' && t.classList.contains('is-playing') && !t.__pinned) stopTile(t); });
    t.addEventListener('click', function () {
      if (t.classList.contains('is-playing') && t.__pinned) { t.__pinned = false; stopTile(t); return; }
      if (t.classList.contains('is-playing')) { t.__pinned = true; return; }
      t.__pinned = true; startTile(t);
    });
    t.addEventListener('blur', function () { if (t.classList.contains('is-playing')) { t.__pinned = false; stopTile(t); } });
  });
})();
