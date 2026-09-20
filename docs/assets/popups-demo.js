/* DesignFoundation — popup / toast motion demos (shared by docs/index.html and docs/pro/index.html).
 *
 * Illustrative HTML/CSS/JS reproductions of the SwiftUI behaviour, driven by the real source:
 *   - theme animation tokens: easeInOut 0.15s (fast) / 0.25s (default) / 0.4s (slow)
 *   - DFPopupHost: transitions, exit edges, 60pt drag-dismiss, 0.35 backdrop, safe-area bleed
 *   - DFPopupMotion: spring(response:dampingFraction:) presets
 * They are NOT screen recordings. Self-contained: no network, no libraries.
 *
 * Markup:  <div class="pd-demo" data-demo="centered" data-label="..."></div>
 * Each demo loops while on screen, pauses off screen, honours prefers-reduced-motion
 * (renders one static frame; the Play button starts it on request) and has a Pause/Play button.
 */
(function () {
  'use strict';

  var CANCEL = { cancel: true }, STOP = { stop: true };
  var EASE = 'cubic-bezier(.42,0,.58,1)';      // SwiftUI .easeInOut
  var DEFAULT_MS = 250, FAST_MS = 150;         // theme.animation.default / .fast
  var BACKDROP = 0.35;                          // theme.components.popup.backdropOpacity default
  var DRAG_DISMISS_PT = 60;                     // DFPopupDrag.dismissDistance
  var SCROLL_DISMISS_PT = 80;                   // DFScrollPopupDrag.dismissDistance

  var mqReduce = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : { matches: false };
  function mk(tag, cls, html) { var e = document.createElement(tag); if (cls) e.className = cls; if (html != null) e.innerHTML = html; return e; }
  function eio(t) { return t < .5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2; }
  function lin(t) { return t; }

  /* ───────────────────────── Icons + content templates ───────────────────────── */
  var SVG = function (d) { return '<svg class="pd-ico" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' + d + '</svg>'; };
  var ICON = {
    info: SVG('<circle cx="10" cy="10" r="8"/><path d="M10 9v5M10 6.2v.1"/>'),
    success: SVG('<circle cx="10" cy="10" r="8"/><path d="M6.5 10.3l2.4 2.4 4.6-4.9"/>'),
    warning: SVG('<path d="M10 2.5l8 14H2z"/><path d="M10 8v4M10 14.3v.1"/>'),
    error: SVG('<circle cx="10" cy="10" r="8"/><path d="M7 7l6 6M13 7l-6 6"/>')
  };
  var T = {
    card: function (title, msg, btns) {
      return '<div class="pd-h">' + title + '</div><div class="pd-p">' + msg + '</div><div class="pd-btns">' +
        btns.map(function (b, i) { return '<span class="pd-btn ' + (i === 0 ? 'ghost' : (b === 'Delete' ? 'danger' : '')) + '">' + b + '</span>'; }).join('') + '</div>';
    },
    toast: function (sev, text) { return '<div class="pd-line pd-' + sev + '">' + ICON[sev] + '<span>' + text + '</span></div>'; },
    capsule: function (sev, text) { return '<div class="pd-capsule pd-' + sev + '">' + ICON[sev] + '<span>' + text + '</span></div>'; },
    undo: function (text) { return '<div class="pd-line">' + ICON.success + '<span>' + text + '</span><span class="pd-btn ghost">Undo</span></div>'; },
    text: function (t) { return '<div class="pd-line">' + t + '</div>'; }
  };
  var SKEL_ROWS = function (n) { var s = ''; for (var i = 0; i < n; i++) s += '<div class="pd-row"><span class="pd-av"></span><span class="pd-lines"><i></i><i></i></span></div>'; return s; };
  var ITEM_ROWS = function () {
    return [['Order #1042', 'Shipped'], ['Order #1043', 'Packing'], ['Order #1044', 'Delivered']].map(function (r) {
      return '<div class="pd-row" data-item><span class="pd-av"></span><span><b>' + r[0] + '</b><small>' + r[1] + '</small></span><span class="pd-chev">›</span></div>';
    }).join('') + SKEL_ROWS(3);
  };

  var EDGE_OF = { topLeading: 'top', top: 'top', topTrailing: 'top', leading: 'left', trailing: 'right', center: 'bottom', bottomLeading: 'bottom', bottom: 'bottom', bottomTrailing: 'bottom' };
  var EDGE_NAME = { top: '.top', bottom: '.bottom', left: '.leading', right: '.trailing' };

  /* ───────────────────────── Spring (DFPopupMotion) ───────────────────────── */
  var SPRING = { snappy: [0.3, 0.85], bouncy: [0.45, 0.62], gentle: [0.6, 0.95] };
  function springFn(resp, z) {
    var w = 2 * Math.PI / resp, wd = w * Math.sqrt(1 - z * z);
    return function (t) { return 1 - Math.exp(-z * w * t) * (Math.cos(wd * t) + (z * w / wd) * Math.sin(wd * t)); };
  }
  function springSamples(sp) {
    var f = springFn(sp[0], sp[1]), end = .2, dt = 1 / 60, i;
    for (i = 0; i < 240; i++) if (Math.abs(f(i * dt) - 1) > .002) end = (i + 1) * dt;
    var out = [], n = Math.ceil(end / dt);
    for (i = 0; i <= n; i++) out.push(f(Math.min(end, i * dt)));
    out[out.length - 1] = 1;
    return { p: out, ms: end * 1000 };
  }

  /* ───────────────────────── Syntax highlighting for the Swift snippets ───────────────────────── */
  var KW = 'import|struct|class|enum|var|let|func|some|case|if|else|in|return|private|static|extension|guard|true|false|nil|self|any';
  var RE = new RegExp('(\\/\\/[^\\n]*)|("(?:[^"\\\\\\n]|\\\\.)*")|(@\\w+)|\\b(' + KW + ')\\b|\\b([A-Z][A-Za-z0-9]*)\\b|(\\.[a-z]\\w*)(?=\\()|\\b(\\d+(?:\\.\\d+)?)\\b', 'g');
  function highlight() {
    var nodes = document.querySelectorAll('pre.pd-code code, .pd-code > code');
    Array.prototype.forEach.call(nodes, function (code) {
      if (code.dataset.hl) return; code.dataset.hl = '1';
      var s = code.textContent.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
      code.innerHTML = s.replace(RE, function (m, cm, str, attr, kw, type, fn, num) {
        if (cm) return '<span class="cm">' + cm + '</span>';
        if (str) return '<span class="str">' + str + '</span>';
        if (attr || kw) return '<span class="kw">' + m + '</span>';
        if (type) return '<span class="type">' + m + '</span>';
        if (fn) return '<span class="fn">' + m + '</span>';
        if (num) return '<span class="num">' + m + '</span>';
        return m;
      });
    });
  }

  /* ───────────────────────── Shared ticker ───────────────────────── */
  var active = new Set(), ticking = false, lastT = 0;
  function frame(t) {
    var dt = Math.min(64, t - lastT); lastT = t;
    active.forEach(function (d) { d.tick(dt); if (!d.running && !d.jobs.length) active.delete(d); });
    if (active.size) requestAnimationFrame(frame); else ticking = false;
  }
  function wake() { if (!ticking) { ticking = true; lastT = performance.now(); requestAnimationFrame(frame); } }

  /* ───────────────────────── Popup instance ───────────────────────── */
  function Pop(demo, o) {
    this.d = demo; this.o = o; this.off = { x: 0, y: 0 }; this.gone = null; this.alive = false; this.autoJob = null;
    this.slot = mk('div', 'pd-slot k-' + o.kind + ' pos-' + o.pos);
    this.el = mk('div', 'pd-pop', '');
    this.slot.appendChild(this.el);
    this.back = o.dims ? mk('div', 'pd-back') : null;
    this.configure(o);
  }
  Pop.prototype.configure = function (o) {
    this.o = o;
    var bleed = '';
    if (o.kind === 'toast') { if (/^top/.test(o.pos)) bleed = ' bleed-t'; else if (/^bottom/.test(o.pos)) bleed = ' bleed-b'; }
    this.slot.className = 'pd-slot k-' + o.kind + ' pos-' + o.pos;
    this.el.className = 'pd-pop k-' + o.kind + (o.bare ? ' bare' : '') + bleed;
    this.el.innerHTML = o.html;
    var tr = o.tr || 'automatic';
    if (tr === 'automatic') tr = o.pos === 'center' ? 'scale' : 'slide';
    var nat = EDGE_OF[o.pos];
    this.inEdge = (tr && tr.ins) || nat; this.outEdge = (tr && tr.rem) || nat;
    this.tr = (tr && tr.ins) ? 'slide' : tr;
    this.edge = nat;
  };
  Pop.prototype.rest = function () {
    var r = this.el.getBoundingClientRect();
    return { left: r.left - this.off.x, right: r.right - this.off.x, top: r.top - this.off.y, bottom: r.bottom - this.off.y };
  };
  Pop.prototype.hidden = function (edge) {
    var r = this.rest(), s = this.d.screen.getBoundingClientRect(), pad = 14;
    if (this.tr === 'scale') return { x: 0, y: 0, s: .9, o: 0 };
    if (this.tr === 'fade') return { x: 0, y: 0, s: 1, o: 0 };
    if (edge === 'top') return { x: 0, y: -(r.bottom - s.top) - pad, s: 1, o: 0 };
    if (edge === 'left') return { x: -(r.right - s.left) - pad, y: 0, s: 1, o: 0 };
    if (edge === 'right') return { x: s.right - r.left + pad, y: 0, s: 1, o: 0 };
    return { x: 0, y: s.bottom - r.top + pad, s: 1, o: 0 };
  };
  Pop.prototype.enter = function () {
    var d = this.d, self = this, layer = this.o.win ? d.winLayer : (this.o.layer || d.ovLayer);
    if (this.back) layer.appendChild(this.back);
    layer.appendChild(this.slot);
    this.alive = true;
    if (this.o.haptic) d.haptic();
    var jobs = [];
    if (this.back) jobs.push(d.anim(this.back, [{ opacity: 0 }, { opacity: BACKDROP }], { duration: DEFAULT_MS, easing: EASE }));
    if (this.tr !== 'none') {
      var from = this.hidden(this.inEdge);
      jobs.push(d.animState(this.el, from, { x: 0, y: 0, s: 1, o: 1 }, this.o.spring));
    }
    this.entered = Promise.all(jobs).then(function () { self.el.style.transform = ''; });
    this.gone = new Promise(function (res) { self._goneRes = res; });
    return this.entered;
  };
  Pop.prototype.exit = function () {
    var d = this.d, self = this;
    if (!this.alive) return Promise.resolve();
    this.alive = false;
    if (this.autoJob) this.autoJob.cancel();
    var jobs = [], off = this.off, cur = { x: off.x, y: off.y, s: 1, o: 1 };
    // freeze at the current drag offset before the removal animation starts
    if (this.back) jobs.push(d.anim(this.back, [{ opacity: BACKDROP }, { opacity: 0 }], { duration: DEFAULT_MS, easing: EASE, keep: true }));
    if (this.tr !== 'none') {
      var to = this.hidden(this.outEdge);
      if (this.tr === 'slide' && this.o.dragOut) to = this.hidden(this.edge);
      jobs.push(d.animState(this.el, cur, to, this.o.spring, true));
    }
    var fin = Promise.all(jobs).then(function () { self.remove(); });
    if (this.tr === 'none') { this.remove(); fin = Promise.resolve(); }
    return fin;
  };
  Pop.prototype.remove = function () {
    if (this.slot.parentNode) this.slot.remove();
    if (this.back && this.back.parentNode) this.back.remove();
    if (this._goneRes) { this._goneRes(); this._goneRes = null; }
  };
  Pop.prototype.auto = function (ms, label) {
    var self = this;
    if (this.autoJob) this.autoJob.cancel();
    this.autoJob = this.d.after(ms, function () { self.exit(); }, label || 'auto-dismiss in');
    return this.autoJob;
  };
  Pop.prototype.setOffset = function (x, y) { this.off = { x: x, y: y }; this.el.style.transform = 'translate(' + x + 'px,' + y + 'px)'; };
  Pop.prototype.retarget = function (o) {  // content swap while staying presented (DFPopupCenter / toast queue)
    o = Object.assign({ kind: 'floater', pos: 'center', tr: 'automatic', dims: false }, o);
    this.configure(o);
  };

  /* ───────────────────────── Demo (one phone) ───────────────────────── */
  function Demo(root, name) {
    this.root = root; this.name = name; this.def = DEFS[name];
    if (!this.def) return;
    this.tk = 0; this.jobs = []; this.anims = new Set(); this.paused = false; this.opts = {};
    this.static = mqReduce.matches; this.visible = false; this.running = false;
    this.build();
    this.reset();
  }
  Demo.prototype.build = function () {
    var self = this, def = this.def, root = this.root;
    root.innerHTML = '';
    var wrap = mk('div', 'pd-demo-wrap');
    var phone = mk('div', 'pd-phone'); phone.setAttribute('role', 'img');
    phone.setAttribute('aria-label', (root.dataset.label || 'Animated demo') + ' — illustrative reproduction');
    var screen = mk('div', 'pd-screen');
    this.app = mk('div', 'pd-app');
    this.ovLayer = mk('div', 'pd-layer pd-l-ov'); this.sheetLayer = mk('div', 'pd-layer pd-l-sheet'); this.winLayer = mk('div', 'pd-layer pd-l-win');
    this.finger = mk('div', 'pd-finger');
    screen.appendChild(this.app); screen.appendChild(this.ovLayer); screen.appendChild(this.sheetLayer); screen.appendChild(this.winLayer);
    screen.appendChild(mk('div', 'pd-sbar', '<span>9:41</span><i class="pd-island"></i><span>100%</span>'));
    screen.appendChild(mk('div', 'pd-home')); screen.appendChild(this.finger);
    phone.appendChild(screen); wrap.appendChild(phone);
    this.phone = phone; this.screen = screen;
    if (def.setup) def.setup(this, wrap);
    var meta = mk('div', 'pd-meta');
    this.sayEl = mk('div', 'pd-say'); this.sayEl.setAttribute('aria-hidden', 'true');
    this.chipEl = mk('div', 'pd-chip'); this.chipEl.setAttribute('aria-hidden', 'true');
    var foot = mk('div', 'pd-foot');
    this.ctl = mk('button', 'pd-ctl', 'Pause'); this.ctl.type = 'button';
    this.ctl.addEventListener('click', function () { self.toggle(); });
    foot.appendChild(mk('span', 'pd-note', 'Illustrative reproduction'));
    foot.appendChild(this.ctl);
    meta.appendChild(this.sayEl); meta.appendChild(this.chipEl); meta.appendChild(foot);
    wrap.appendChild(meta);
    root.appendChild(wrap);
    this.syncCtl();
  };
  Demo.prototype.pt = function () { return this.screen.clientWidth / 390; };
  Demo.prototype.syncCtl = function () {
    this.ctl.textContent = (this.static || this.paused) ? 'Play' : 'Pause';
    this.ctl.setAttribute('aria-label', (this.static || this.paused) ? 'Play animation' : 'Pause animation');
  };
  Demo.prototype.toggle = function () {
    if (this.static) { this.static = false; this.paused = false; this.syncCtl(); this.restart(); return; }
    this.setPaused(!this.paused);
  };
  Demo.prototype.setPaused = function (v) {
    this.paused = v;
    this.anims.forEach(function (a) { try { v ? a.pause() : a.play(); } catch (e) { /* finished */ } });
    this.syncCtl();
  };
  Demo.prototype.reset = function () {
    this.jobs.forEach(function (j) { if (j.rej) j.rej(CANCEL); });
    this.jobs = [];
    this.anims.forEach(function (a) { try { a.cancel(); } catch (e) {} });
    this.anims.clear();
    [this.ovLayer, this.sheetLayer, this.winLayer].forEach(function (l) { l.innerHTML = ''; });
    this.finger.classList.remove('vis', 'down'); this.fx = null;
    this.app.innerHTML = this.def.app === 'items' ? '<div class="pd-nav">Orders</div>' + ITEM_ROWS()
      : this.def.app === 'nav' ? '<div class="pd-navbar"><span>Cancel</span><span>Profile</span><span>Done</span></div><div class="pd-nav">Settings</div>' + SKEL_ROWS(5)
      : '<div class="pd-nav">Inbox</div>' + SKEL_ROWS(6);
    this.say(''); this.chip('');
    if (this.def.onReset) this.def.onReset(this);
  };
  Demo.prototype.restart = function () { this.stop(true); this.start(); };
  Demo.prototype.start = function () {
    if (!this.def || this.running) return;
    this.running = true; active.add(this); wake();
    var self = this, tk = ++this.tk;
    (async function () {
      while (tk === self.tk) {
        try { await self.def.run(self); }
        catch (e) { if (e === STOP) { self.running = false; return; } if (e === CANCEL) return; console.error(e); return; }
        if (tk !== self.tk) return;
        try { await self.sleep(self.def.gap == null ? 900 : self.def.gap); } catch (e) { return; }
        if (tk !== self.tk) return;
        self.reset();
      }
    })();
  };
  Demo.prototype.stop = function (keepStatic) {
    this.tk++; this.running = false;
    this.reset();
    if (!this.jobs.length) active.delete(this);
  };
  Demo.prototype.chk = function (tk) { if (tk !== this.tk) throw CANCEL; };
  Demo.prototype.tick = function (dt) {
    if (this.paused) return;
    var list = this.jobs.slice(), label = '';
    for (var i = 0; i < list.length; i++) {
      var j = list[i]; if (j.dead) continue;
      j.el += dt;
      if (j.tick) j.tick(Math.min(1, j.el / j.dur));
      if (j.label && !label) label = j.label + ' ' + Math.max(0, (j.dur - j.el) / 1000).toFixed(1) + 's';
      if (j.el >= j.dur) { j.dead = true; this.jobs.splice(this.jobs.indexOf(j), 1); if (j.cb) j.cb(); if (j.res) j.res(); }
    }
    if (label) { this.chip(label); this._labelled = true; } else if (this._labelled) { this.chip(''); this._labelled = false; }
  };
  Demo.prototype.job = function (ms, o) {
    var self = this, j = { dur: Math.max(1, ms), el: 0, tick: o.tick, cb: o.cb, label: o.label, dead: false };
    j.cancel = function () { j.dead = true; var i = self.jobs.indexOf(j); if (i >= 0) self.jobs.splice(i, 1); };
    if (o.promise) {
      var tk = this.tk;
      j.promise = new Promise(function (res, rej) { j.res = res; j.rej = rej; });
      this.jobs.push(j); return j.promise;
    }
    this.jobs.push(j); return j;
  };
  Demo.prototype.sleep = function (ms) { if (this.static) return Promise.resolve(); return this.job(ms, { promise: true }); };
  Demo.prototype.after = function (ms, fn, label) { if (this.static) return { cancel: function () {} }; return this.job(ms, { cb: fn, label: label }); };
  Demo.prototype.tween = function (ms, fn, ease) {
    ease = ease || eio;
    if (this.static) { fn(1); return Promise.resolve(); }
    return this.job(ms, { promise: true, tick: function (t) { fn(ease(t)); } });
  };
  Demo.prototype.poster = function () { if (this.static) throw STOP; };
  Demo.prototype.say = function (t) { if (this.sayEl) this.sayEl.textContent = t; };
  Demo.prototype.chip = function (t) { if (this.chipEl && this.chipEl.textContent !== t) this.chipEl.textContent = t; };
  Demo.prototype.haptic = function () {
    var p = this.phone; if (mqReduce.matches) return;
    p.classList.remove('pd-haptic'); void p.offsetWidth; p.classList.add('pd-haptic');
  };

  /* WAAPI wrapper: pause-aware, cancels itself after finishing unless keep */
  Demo.prototype.anim = function (el, kf, o) {
    if (this.static) return Promise.resolve();
    var self = this, a = el.animate(kf, { duration: o.duration, easing: o.easing || 'linear', fill: 'both' });
    this.anims.add(a); if (this.paused) a.pause();
    return a.finished.then(function () {
      self.anims.delete(a);
      if (!o.keep) a.cancel();
    }, function () { self.anims.delete(a); });
  };
  Demo.prototype.animState = function (el, from, to, spring, keep) {
    function tf(v) { return 'translate(' + v.x + 'px,' + v.y + 'px) scale(' + v.s + ')'; }
    if (!spring) return this.anim(el, [{ transform: tf(from), opacity: from.o }, { transform: tf(to), opacity: to.o }], { duration: DEFAULT_MS, easing: EASE, keep: keep });
    var sp = springSamples(SPRING[spring] || spring), kf = [], n = sp.p.length;
    for (var i = 0; i < n; i++) {
      var p = sp.p[i], v = { x: from.x + (to.x - from.x) * p, y: from.y + (to.y - from.y) * p, s: from.s + (to.s - from.s) * p };
      kf.push({ transform: tf(v), opacity: Math.min(1, Math.max(0, from.o + (to.o - from.o) * p)), offset: i / (n - 1) });
    }
    return this.anim(el, kf, { duration: sp.ms, easing: 'linear', keep: keep });
  };

  /* Presenting */
  Demo.prototype.present = function (o) {
    o = Object.assign({ kind: 'floater', pos: 'center', tr: 'automatic', dims: false }, o);
    var p = new Pop(this, o); p.enter(); return p;
  };
  Demo.prototype.center = function (el) {
    var r = el.getBoundingClientRect(), s = this.screen.getBoundingClientRect();
    return { x: r.left - s.left + r.width / 2, y: r.top - s.top + r.height / 2 };
  };
  /* Finger */
  Demo.prototype.fingerAt = function (x, y) { this.fx = x; this.fy = y; this.finger.style.transform = 'translate(' + x + 'px,' + y + 'px)'; };
  Demo.prototype.fingerTo = async function (pt, ms) {
    var tk = this.tk, self = this; pt = pt.nodeType ? this.center(pt) : pt;
    if (this.static) { this.fingerAt(pt.x, pt.y); return; }
    if (this.fx == null) { this.fingerAt(pt.x + 24, pt.y + 60); }
    this.finger.classList.add('vis');
    var a = { x: this.fx, y: this.fy };
    await this.tween(ms || 480, function (t) { self.fingerAt(a.x + (pt.x - a.x) * t, a.y + (pt.y - a.y) * t); });
    this.chk(tk);
  };
  Demo.prototype.press = async function () {
    var tk = this.tk; this.finger.classList.add('down'); await this.sleep(150); this.chk(tk);
  };
  Demo.prototype.release = function () { this.finger.classList.remove('down'); };
  Demo.prototype.tap = async function (target, ms) {
    var tk = this.tk;
    await this.fingerTo(target, ms); this.chk(tk);
    await this.press(); this.release(); await this.sleep(120); this.chk(tk);
  };
  Demo.prototype.tapAt = function (fx, fy) { return this.tap({ x: this.screen.clientWidth * fx, y: this.screen.clientHeight * fy }); };
  Demo.prototype.fingerOff = function () { this.finger.classList.remove('vis', 'down'); };
  Demo.prototype.rowTap = async function (row) {
    var tk = this.tk; await this.fingerTo(row); this.chk(tk);
    row.classList.add('hl'); await this.press(); this.release(); await this.sleep(200); this.chk(tk); row.classList.remove('hl');
  };
  /* Drag a popup along the axis of its exit edge (DFPopupDrag.constrained) */
  function constrain(edge, x, y) {
    if (edge === 'top') return { x: 0, y: Math.min(0, y) };
    if (edge === 'bottom') return { x: 0, y: Math.max(0, y) };
    if (edge === 'left') return { x: Math.min(0, x), y: 0 };
    return { x: Math.max(0, x), y: 0 };
  }
  Demo.prototype.dragPop = async function (p, dx, dy, ms) {
    var tk = this.tk, self = this, c = this.center(p.el), pt = this.pt(), last = 0;
    dx *= pt; dy *= pt;
    await this.fingerTo(c); this.chk(tk);
    this.finger.classList.add('down');
    await this.tween(ms || 800, function (t) {
      self.fingerAt(c.x + dx * t, c.y + dy * t);
      var k = constrain(p.edge, dx * t, dy * t); p.setOffset(k.x, k.y);
      last = Math.abs(k.x || k.y) / pt;
      self.chip('drag travel ' + Math.round(last) + 'pt / ' + DRAG_DISMISS_PT + 'pt');
    }, lin);
    this.chk(tk);
    return last;
  };
  Demo.prototype.dropPop = async function (p, travelPt) {
    var tk = this.tk, self = this, o = p.off;
    this.release();
    if (travelPt >= DRAG_DISMISS_PT) {
      this.chip('travel ≥ 60pt → dismiss');
      await p.exit();
    } else {
      this.chip('travel < 60pt → snap back (easeInOut 0.15s)');
      await this.tween(FAST_MS, function (t) { p.setOffset(o.x * (1 - t), o.y * (1 - t)); });
    }
    this.chk(tk);
  };

  /* ───────────────────────── Demo definitions ───────────────────────── */
  var POS = ['topLeading', 'top', 'topTrailing', 'leading', 'center', 'trailing', 'bottomLeading', 'bottom', 'bottomTrailing'];
  var DEFS = {};

  DEFS.centered = { run: async function (c) {
    c.say('isPresented = true → default .centered configuration');
    var p = c.present({ kind: 'center', pos: 'center', dims: true, html: T.card('Delete this item?', 'This can’t be undone.', ['Cancel', 'Delete']) });
    await p.entered;
    c.say('Scale 0.9 → 1 + fade in, backdrop dims to 35%. easeInOut 0.25s.');
    c.poster(); await c.sleep(1900);
    c.say('Tap outside (dismissOnOutsideTap defaults to true)');
    await c.tapAt(.5, .9); await p.exit();
    c.fingerOff(); c.say('Removal reverses the transition.'); await c.sleep(900);
  } };

  DEFS.toast = { run: async function (c) {
    c.say('.toast(position: .top) — full width, flush with the edge');
    var p = c.present({ kind: 'toast', pos: 'top', html: T.toast('success', 'Changes saved') });
    p.auto(3000);
    await p.entered;
    c.say('Slides from .top, background bleeds under the status bar. autoDismissAfter defaults to 3s.');
    c.poster(); await p.gone;
    c.say('Auto-dismissed after 3s (slide out + fade).'); await c.sleep(700);
  } };

  DEFS.floater = { run: async function (c) {
    c.say('.floater(position: .bottom) — inset, rounded, no backdrop');
    var p = c.present({ kind: 'floater', pos: 'bottom', html: T.undo('Photo archived') });
    await p.entered;
    c.say('Touches pass through to the host: tapping a row still works.');
    c.poster(); await c.sleep(600);
    await c.rowTap(c.app.querySelectorAll('.pd-row')[1]);
    c.say('Stays until dismissed (autoDismissAfter is nil). Drag it toward its edge to dismiss.');
    var t = await c.dragPop(p, 0, 150, 700); await c.dropPop(p, t);
    c.fingerOff(); await c.sleep(800);
  } };

  DEFS.positions = {
    gap: 300,
    setup: function (c, wrap) {
      c.opts.kind = 'floater'; c.opts.from = 0;
      var box = mk('div'), grid = mk('div', 'pd-cells'), seg = mk('div', 'pd-seg'); seg.style.marginTop = '10px';
      grid.setAttribute('role', 'group'); grid.setAttribute('aria-label', 'Choose a popup position');
      c.cells = POS.map(function (pos, i) {
        var b = mk('button', 'pd-cellbtn'); b.type = 'button'; b.setAttribute('aria-label', '.' + pos); b.title = '.' + pos; b.setAttribute('aria-pressed', 'false');
        b.addEventListener('click', function () { c.opts.from = i; if (c.static) { c.static = false; c.syncCtl(); } c.restart(); });
        grid.appendChild(b); return b;
      });
      ['floater', 'toast'].forEach(function (k) {
        var b = mk('button', '', '.' + k); b.type = 'button'; b.setAttribute('aria-pressed', String(k === 'floater'));
        b.addEventListener('click', function () {
          c.opts.kind = k; Array.prototype.forEach.call(seg.children, function (x) { x.setAttribute('aria-pressed', String(x === b)); });
          if (c.static) { c.static = false; c.syncCtl(); } c.restart();
        });
        seg.appendChild(b);
      });
      box.appendChild(grid); box.appendChild(seg); box.style.cssText = 'display:flex;flex-direction:column;align-items:center;';
      wrap.appendChild(box);
    },
    onReset: function (c) { if (c.cells) c.cells.forEach(function (b) { b.setAttribute('aria-pressed', 'false'); }); },
    run: async function (c) {
      var kind = c.opts.kind, start = c.opts.from || 0;
      for (var i = start; i < POS.length; i++) {
        var pos = POS[i];
        c.cells.forEach(function (b, k) { b.setAttribute('aria-pressed', String(k === i)); });
        c.say('.' + kind + '(position: .' + pos + ')  →  enters from and exits toward ' + EDGE_NAME[EDGE_OF[pos]] + (pos === 'center' ? ' (automatic transition scales at .center)' : ''));
        var html = kind === 'toast' ? T.toast('info', '.' + pos) : T.text('.' + pos);
        var p = c.present({ kind: kind, pos: pos, html: html });
        await p.entered;
        if (i === start) c.poster();
        await c.sleep(1000); await p.exit(); await c.sleep(150);
      }
      c.opts.from = 0;
    }
  };

  function trDemo(tr, label, desc) {
    return { gap: 500, run: async function (c) {
      c.say(desc);
      var p = c.present({ kind: 'floater', pos: 'bottom', tr: tr, html: T.text('Hello, popup') });
      await p.entered; c.poster(); await c.sleep(1200); await p.exit(); await c.sleep(600);
    } };
  }
  DEFS['tr-slide'] = trDemo('slide', 'slide', 'Slides from the exit edge (.bottom) + fades. Default for every position except .center.');
  DEFS['tr-scale'] = trDemo('scale', 'scale', 'Scales 0.9 → 1 + fades. Default at .center.');
  DEFS['tr-fade'] = trDemo('fade', 'fade', 'Cross-fades in place.');
  DEFS['tr-none'] = trDemo('none', 'none', 'No animation — appears and disappears instantly.');
  DEFS['tr-asym'] = trDemo({ ins: 'left', rem: 'right' }, 'asym', 'Enters from .leading, leaves toward .trailing.');

  DEFS.auto = { run: async function (c) {
    c.say('autoDismissAfter: 2.5 — the popup schedules its own dismissal.');
    var p = c.present({ kind: 'floater', pos: 'bottom', html: T.text('Link copied') });
    p.auto(2500); await p.entered; c.poster();
    await p.gone; c.chip(''); c.say('Timer fired → isPresented = false → slide out.'); await c.sleep(900);
  } };

  DEFS.drag = { run: async function (c) {
    var pt = c.pt(), t;
    var p = c.present({ kind: 'floater', pos: 'bottom', html: T.text('Draft saved — drag me down') });
    await p.entered; c.poster();
    c.say('1 — Drag the wrong way (up): ignored. Only travel toward the exit edge counts.');
    await c.sleep(300); t = await c.dragPop(p, 0, -90, 700); c.release(); c.chip('wrong direction → constrained to 0'); await c.sleep(500);
    c.say('2 — Short drag (< 60pt) then release: snaps back with the theme’s fast animation.');
    t = await c.dragPop(p, 0, 42, 550); await c.dropPop(p, t); await c.sleep(600);
    c.say('3 — Drag ≥ 60pt (or a fast flick) and release: dismissed.');
    t = await c.dragPop(p, 0, 120, 800); await c.dropPop(p, t);
    c.fingerOff(); await c.sleep(900);
  } };

  DEFS.taps = { run: async function (c) {
    c.say('Centered popup: dimsBackground + dismissOnOutsideTap (defaults)');
    var p = c.present({ kind: 'center', pos: 'center', dims: true, html: T.card('Discard changes?', 'Your edits will be lost.', ['Keep editing', 'Discard']) });
    await p.entered; c.poster(); await c.sleep(700);
    c.say('Tap on the popup: nothing (dismissOnTap defaults to false).');
    await c.tap(p.el.querySelector('.pd-p')); c.chip('dismissOnTap = false → stays'); await c.sleep(700);
    c.say('Tap the dimmed backdrop: dismisses.');
    await c.tapAt(.5, .93); await p.exit(); c.chip(''); await c.sleep(500);
    c.say('.toast() sets dismissOnTap = true and no backdrop: tap the toast itself.');
    var t = c.present({ kind: 'toast', pos: 'top', html: T.toast('info', 'Tap to dismiss') });
    await t.entered; await c.sleep(600);
    await c.tap(t.el.querySelector('span')); await t.exit(); c.fingerOff(); c.chip(''); await c.sleep(900);
  } };

  DEFS.item = { app: 'items', run: async function (c) {
    var rows = c.app.querySelectorAll('[data-item]'), p = null;
    var HTML = ['<div class="pd-line"><b>Order #1042</b> — Shipped</div>', '<div class="pd-line"><b>Order #1043</b> — Packing</div>'];
    c.say('selected = Order #1042 → popup appears while item is non-nil');
    await c.rowTap(rows[0]);
    p = c.present({ kind: 'floater', pos: 'bottom', html: HTML[0] }); p.auto(3000);
    await p.entered; c.poster(); await c.sleep(1400);
    c.say('selected = Order #1043 while presented: content swaps, id changed → auto-dismiss restarts.');
    await c.rowTap(rows[1]);
    p.retarget({ kind: 'floater', pos: 'bottom', html: HTML[1] }); p.auto(3000);
    c.fingerOff(); await p.gone;
    c.say('Timer fires → item = nil → popup dismissed.'); await c.sleep(800);
  } };

  var Q = [
    ['info', 'Syncing…', 'top', '.info · .top', 'tap'],
    ['success', 'Saved', 'bottom', '.success · .bottom', 'auto'],
    ['warning', 'Low storage', 'topTrailing', '.warning · .topTrailing', 'swipe'],
    ['error', 'Upload failed', 'bottomLeading', '.error · .bottomLeading', 'auto']
  ];
  DEFS.queue = { gap: 700, run: async function (c) {
    var p = null, i, m, last = Q.length - 1;
    c.say('Four show(…) calls queued at once — DFToastQueue shows one at a time.');
    for (i = 0; i < Q.length; i++) {
      m = Q[i];
      var o = { kind: 'floater', pos: m[2], bare: true, html: T.capsule(m[0], m[1]) }, left = Q.length - i;
      if (!p) { p = c.present(o); await p.entered; if (i === 0) c.poster(); } else { p.setOffset(0, 0); p.retarget(o); }
      c.say('severity: ' + m[3].split(' · ')[0] + ', position: ' + m[3].split(' · ')[1] + '  (' + (m[4] === 'tap' ? 'tap to dismiss' : m[4] === 'swipe' ? 'swipe toward its edge' : 'auto-dismiss after 3s') + ')');
      c.chip('queue: ' + left + ' (showing 1, waiting ' + (left - 1) + ')');
      if (m[4] === 'tap') { await c.sleep(1100); await c.tap(p.el.querySelector('span')); c.fingerOff(); }
      else if (m[4] === 'swipe') {
        await c.sleep(1100);
        await c.dragPop(p, 0, (p.edge === 'top' ? -1 : 1) * 110, 600); c.release(); c.fingerOff();
      } else if (i === last) { p.auto(3000); await p.gone; }
      else { var j = c.after(3000, function () {}, 'auto-dismiss in'); await c.sleep(3000); }
      if (i < last) { c.say('Dismissed → the next message takes over the popup in place.'); await c.sleep(400); }
    }
    c.chip('queue: 0'); await c.sleep(700);
  } };

  /* ── Pro: scroll popup ── */
  function scrollBody() {
    var s = '', names = ['Ana', 'Ben', 'Chloe', 'Dev', 'Ella', 'Farid', 'Gus', 'Hana', 'Ivan', 'Jo'];
    names.forEach(function (n) { s += '<p><b>' + n + '</b>Left a comment on ticket #4821 — thanks, this looks good to me.</p>'; });
    return s;
  }
  function scrollDemo(fromTop) {
    return { gap: 700,
      run: async function (c) {
        var pt = c.pt(), ph = c.screen.clientHeight;
        var card = mk('div', 'pd-sp ' + (fromTop ? 'top' : 'bottom'),
          (fromTop ? '' : '<div class="pd-grab"></div>') + '<header>Ticket #4821</header><div class="pd-scroll"><div class="pd-scroll-in">' + scrollBody() + '</div></div>' + (fromTop ? '<div class="pd-grab"></div>' : ''));
        var back = mk('div', 'pd-back'); c.ovLayer.appendChild(back); c.ovLayer.appendChild(card); card.style.pointerEvents = 'none';
        var head = card.querySelector('header'), inner = card.querySelector('.pd-scroll-in'), sc = card.querySelector('.pd-scroll');
        var maxScroll = Math.max(0, inner.offsetHeight - sc.clientHeight), scroll = 0, cardOff = 0, dir = fromTop ? -1 : 1;
        function setScroll(v) { scroll = Math.max(0, Math.min(maxScroll, v)); inner.style.transform = 'translateY(' + (-scroll) + 'px)'; var top = scroll <= .5; head.classList.toggle('scrolled', !top); c.chip('scroll at top: ' + top); }
        function setCard(v) { cardOff = v; card.style.transform = 'translateY(' + v + 'px)'; }
        var hid = fromTop ? -(ph * .6 + 10) : ph * .6 + 10;
        c.say(fromTop ? 'fromTop: true — slides from the top edge, dismiss by dragging up.' : 'Bottom sheet-style popup, pinned header, scrollable body.');
        await Promise.all([c.anim(back, [{ opacity: 0 }, { opacity: BACKDROP }], { duration: DEFAULT_MS, easing: EASE }),
          c.anim(card, [{ transform: 'translateY(' + hid + 'px)' }, { transform: 'translateY(0)' }], { duration: DEFAULT_MS, easing: EASE })]);
        setScroll(0); c.poster();
        var center = { x: c.screen.clientWidth * .5, y: ph * (fromTop ? .3 : .7) };
        if (!fromTop) {
          await c.sleep(500);
          c.say('Drag up on the content: it scrolls; the card stays put (content is no longer at top).');
          await c.fingerTo({ x: center.x, y: center.y + 60 }); c.finger.classList.add('down');
          await c.tween(800, function (t) { c.fingerAt(center.x, center.y + 60 - 150 * t); setScroll(180 * t); }, lin);
          c.release(); await c.sleep(500);
          c.say('Drag down while scrolled: the drag scrolls back — it never grabs the card mid-scroll.');
          await c.fingerTo({ x: center.x, y: center.y - 60 }); c.finger.classList.add('down');
          await c.tween(800, function (t) { c.fingerAt(center.x, center.y - 60 + 140 * t); setScroll(180 * (1 - t)); }, lin);
          c.release(); await c.sleep(500);
          c.say('Now at the top: a drag down moves the card. Past 80pt (or a fast flick) it dismisses.');
          await c.fingerTo({ x: center.x, y: center.y - 30 }); c.finger.classList.add('down');
          await c.tween(800, function (t) { c.fingerAt(center.x, center.y - 30 + 130 * t); setCard(130 * t); c.chip('drag travel ' + Math.round(130 * t / pt) + 'pt / ' + SCROLL_DISMISS_PT + 'pt'); }, lin);
        } else {
          await c.sleep(500);
          c.say('Dragging the wrong way (down) does nothing: travel is measured toward the exit edge only.');
          await c.fingerTo({ x: center.x, y: center.y }); c.finger.classList.add('down');
          await c.tween(600, function (t) { c.fingerAt(center.x, center.y + 70 * t); }, lin); c.release(); await c.sleep(400);
          c.say('At scroll top, a drag up moves the card. Past 80pt (or a fast flick) it dismisses.');
          await c.fingerTo({ x: center.x, y: center.y + 20 }); c.finger.classList.add('down');
          await c.tween(800, function (t) { c.fingerAt(center.x, center.y + 20 - 130 * t); setCard(-130 * t); c.chip('drag travel ' + Math.round(130 * t / pt) + 'pt / ' + SCROLL_DISMISS_PT + 'pt'); }, lin);
        }
        c.release(); c.chip('travel ≥ 80pt → dismiss');
        var from = cardOff;
        await Promise.all([c.anim(back, [{ opacity: BACKDROP }, { opacity: 0 }], { duration: DEFAULT_MS, easing: EASE, keep: true }),
          c.anim(card, [{ transform: 'translateY(' + from + 'px)' }, { transform: 'translateY(' + hid + 'px)' }], { duration: DEFAULT_MS, easing: EASE, keep: true })]);
        c.fingerOff(); c.chip(''); await c.sleep(700);
      }
    };
  }
  DEFS['scroll-bottom'] = scrollDemo(false);
  DEFS['scroll-top'] = scrollDemo(true);

  /* ── Pro: window presentation above a sheet ── */
  DEFS.window = { app: 'nav', gap: 800, run: async function (c) {
    var back = mk('div', 'pd-sheetback'), sheet = mk('div', 'pd-sheet', '<div class="pd-grab"></div><h5>Edit profile</h5><div class="pd-field"></div><div class="pd-field"></div><span class="pd-btn">Save</span>');
    var ph = c.screen.clientHeight;
    c.sheetLayer.appendChild(back); c.sheetLayer.appendChild(sheet);
    c.say('A sheet is presented (system sheet, ~0.4s).');
    await Promise.all([c.anim(back, [{ opacity: 0 }, { opacity: .28 }], { duration: 400, easing: EASE }),
      c.anim(sheet, [{ transform: 'translateY(' + (ph * .62) + 'px)' }, { transform: 'translateY(0)' }], { duration: 400, easing: EASE })]);
    await c.sleep(500);
    c.say('.dfPopup(…): an overlay of the presenting view — the sheet sits above it.');
    var p1 = c.present({ kind: 'floater', pos: 'bottom', html: T.undo('Draft saved') });
    await p1.entered; c.chip('.dfPopup → hidden behind the sheet'); c.poster(); await c.sleep(1900);
    await p1.exit(); c.chip(''); await c.sleep(300);
    c.say('.dfPopupWindow(…): its own window, above sheets and navigation bars.');
    var p2 = c.present({ kind: 'floater', pos: 'bottom', win: true, html: T.undo('Draft saved') });
    await p2.entered; c.chip('.dfPopupWindow → above the sheet'); await c.sleep(900);
    c.say('No backdrop + no outside-tap dismissal: touches pass through everywhere except the popup.');
    var btn = sheet.querySelector('.pd-btn'); await c.fingerTo(btn); btn.classList.add('hl'); await c.press(); c.release(); await c.sleep(300); btn.classList.remove('hl');
    c.chip('tap reached the sheet’s Save button'); c.fingerOff(); await c.sleep(1200);
    await p2.exit(); c.chip('');
    await Promise.all([c.anim(back, [{ opacity: .28 }, { opacity: 0 }], { duration: 400, easing: EASE, keep: true }),
      c.anim(sheet, [{ transform: 'translateY(0)' }, { transform: 'translateY(' + (ph * .62) + 'px)' }], { duration: 400, easing: EASE, keep: true })]);
    await c.sleep(300);
  } };

  /* ── Pro: DFPopupCenter priority queue (mirrors the Swift logic) ── */
  var PRI = { low: 0, normal: 1, high: 2, critical: 3 };
  DEFS.center = {
    gap: 900,
    setup: function (c, wrap) {
      c.insp = mk('div', 'pd-insp', '<div><b>current</b><span class="i-cur"></span></div><div><b>waiting</b><span class="i-wait"></span></div>');
      wrap.appendChild(c.insp);
      c.renderInsp = function (cur, wait) {
        function tag(e) { return '<span class="pd-tag ' + e.pri + '">' + e.id + ' · .' + e.pri + '</span>'; }
        c.insp.querySelector('.i-cur').innerHTML = cur ? tag(cur) : '<span class="pd-note">empty</span>';
        c.insp.querySelector('.i-wait').innerHTML = wait.length ? wait.map(tag).join('') : '<span class="pd-note">none</span>';
      };
    },
    onReset: function (c) { if (c.renderInsp) c.renderInsp(null, []); },
    run: async function (c) {
      var cur = null, wait = [], serial = 0, pop = null, timer = null, entered = null;
      function cfg(e) { return { kind: e.kind, pos: e.pos, html: e.html, bare: e.html.indexOf('pd-capsule') >= 0 }; }
      function enqueue(e) { wait.push(e); wait.sort(function (a, b) { return (PRI[b.pri] - PRI[a.pri]) || (a.serial - b.serial); }); }
      function sync() {
        c.renderInsp(cur, wait);
        if (timer) { timer.cancel(); timer = null; }
        if (cur && !pop) { pop = c.present(cfg(cur)); entered = pop.entered; }
        else if (cur && pop) pop.retarget(cfg(cur));   // stays presented: content swaps in place, no transition
        else if (!cur && pop) { var q = pop; pop = null; q.exit(); return; }
        if (cur.haptic) c.haptic();
        var mine = cur;                                  // identity "\(id)#\(serial)" changed → auto-dismiss restarts
        timer = c.after(2500, function () { api.dismiss(mine.id); }, 'auto-dismiss in');
      }
      var api = {
        present: function (id, pri, kind, pos, html, haptic) {
          serial++; var e = { id: id, pri: pri, kind: kind, pos: pos, html: html, serial: serial, haptic: haptic };
          wait = wait.filter(function (w) { return w.id !== id; });
          if (cur && cur.id === id) { cur = e; sync(); return; }
          if (!cur) { cur = e; sync(); return; }
          if (PRI[e.pri] > PRI[cur.pri]) { enqueue(cur); cur = e; sync(); } else { enqueue(e); c.renderInsp(cur, wait); }
        },
        dismiss: function (id) {
          wait = wait.filter(function (w) { return w.id !== id; });
          if (cur && cur.id === id) { cur = wait.length ? wait.shift() : null; sync(); }
        }
      };
      c.say('present(id: "sync", priority: .low, …) — nothing showing, so it shows.');
      api.present('sync', 'low', 'floater', 'bottom', T.capsule('info', 'Syncing photos…'));
      await entered; await c.sleep(1300);
      c.say('present(id: "tip", priority: .normal) — something is showing, so it waits its turn.');
      api.present('tip', 'normal', 'floater', 'top', T.capsule('success', 'Tip: swipe to dismiss'));
      await c.sleep(1300);
      c.say('present(id: "offline", priority: .high, haptic: .warning) — preempts: sync goes back into the queue.');
      api.present('offline', 'high', 'toast', 'top', T.toast('warning', 'You’re offline'), true);
      await c.sleep(300); c.poster(); await c.sleep(1300);
      c.say('present(id: "tip") again — id de-duplication replaces the waiting entry instead of stacking a second one.');
      api.present('tip', 'normal', 'floater', 'top', T.capsule('success', 'Tip: updated copy'));
      await c.sleep(1200);
      c.say('When the current popup finishes, waiting ones run highest priority first: tip (.normal), then sync (.low). Swaps happen in place.');
      while (cur) await c.sleep(200);
      c.say('Queue empty → the popup slides out.'); await c.sleep(900);
    }
  };

  /* ── Pro: springs + separate enter/exit edges ── */
  function curvePath(sp) {
    var f = springFn(sp[0], sp[1]), pts = [], n = 60, tMax = springSamples(sp).ms / 1000 * 1.1, i;
    for (i = 0; i <= n; i++) { var t = i / n * tMax, y = 45 - f(t) * 32; pts.push((i / n * 196 + 2).toFixed(1) + ',' + Math.max(1, y).toFixed(1)); }
    return '<svg class="pd-curve" viewBox="0 0 200 48" aria-hidden="true"><line x1="0" y1="13" x2="200" y2="13"/><path d="M' + pts.join(' L') + '"/></svg>';
  }
  function springDemo(name) {
    return { app: 'list', gap: 300,
      setup: function (c, wrap) { var d = mk('div'); d.innerHTML = curvePath(SPRING[name]); d.style.cssText = 'width:100%;display:flex;justify-content:center;margin-top:10px'; wrap.appendChild(d); },
      run: async function (c) {
        var sp = SPRING[name];
        c.say('.motion(.' + name + ') → spring(response: ' + sp[0] + ', dampingFraction: ' + sp[1] + ')');
        var p = c.present({ kind: 'floater', pos: 'bottom', spring: name, html: T.text('Spring: .' + name) });
        await p.entered; c.poster(); await c.sleep(1300); await p.exit(); await c.sleep(500);
      } };
  }
  DEFS['spring-snappy'] = springDemo('snappy'); DEFS['spring-bouncy'] = springDemo('bouncy'); DEFS['spring-gentle'] = springDemo('gentle');

  DEFS.edges = { run: async function (c) {
    c.say('.motion(.bouncy, enterFrom: .bottom, exitTo: .trailing)');
    var p = c.present({ kind: 'floater', pos: 'center', spring: 'bouncy', tr: { ins: 'bottom', rem: 'right' }, html: T.text('In from the bottom…') });
    await p.entered; c.say('Enters from .bottom with a bouncy spring.'); c.poster(); await c.sleep(1400);
    c.say('…and leaves toward .trailing — independent edges (asymmetric transition).');
    await p.exit(); await c.sleep(900);
  } };

  /* ── Pro: countdown bar ── */
  DEFS.countdown = { run: async function (c) {
    c.say('DFPopupCountdownBar(duration: 5) inside a popup with autoDismissAfter: 5');
    var p = c.present({ kind: 'floater', pos: 'bottom', html: '<div class="pd-line-col"><div class="pd-line"><span>Message deleted</span><span class="pd-btn ghost">Undo</span></div><div class="pd-bar"><i></i></div></div>' });
    p.auto(5000, 'auto-dismiss in');
    await p.entered;
    var bar = p.el.querySelector('.pd-bar i');
    c.poster();
    c.say('The bar drains linearly over 5s — the same duration as the auto-dismiss timer.');
    c.tween(5000, function (t) { bar.style.transform = 'scaleX(' + (1 - t) + ')'; }, lin).catch(function () {});
    await p.gone;
    c.say('Bar empty → popup dismisses.'); await c.sleep(800);
  } };

  /* ───────────────────────── Boot ───────────────────────── */
  var demos = [];
  function boot() {
    highlight();
    Array.prototype.forEach.call(document.querySelectorAll('.pd-demo[data-demo]'), function (el) {
      var d = new Demo(el, el.dataset.demo); if (!d.def) return;
      demos.push(d);
    });
    // Poster frame first (static demos show their popup), then run only while visible.
    var io = 'IntersectionObserver' in window ? new IntersectionObserver(function (es) {
      es.forEach(function (e) {
        var d = e.target._pd; if (!d) return;
        if (e.isIntersecting) { d.visible = true; if (!d.running && !d.userStopped) d.start(); }
        else { d.visible = false; if (d.running) { d.tk++; d.running = false; d.reset(); } }
      });
    }, { threshold: .25 }) : null;
    demos.forEach(function (d) { d.root._pd = d; if (io) io.observe(d.root); else d.start(); });
    Array.prototype.forEach.call(document.querySelectorAll('[data-pd-toolbar]'), function (bar) {
      var seg = mk('div', 'pd-seg'); seg.setAttribute('role', 'group'); seg.setAttribute('aria-label', 'Demo phone theme');
      ['auto', 'light', 'dark'].forEach(function (m) {
        var b = mk('button', '', m[0].toUpperCase() + m.slice(1)); b.type = 'button'; b.setAttribute('aria-pressed', String(m === 'auto'));
        b.addEventListener('click', function () {
          if (m === 'auto') document.documentElement.removeAttribute('data-pd-theme'); else document.documentElement.setAttribute('data-pd-theme', m);
          document.querySelectorAll('[data-pd-toolbar] .pd-seg button').forEach(function (x) { x.setAttribute('aria-pressed', String(x.textContent.toLowerCase() === m)); });
        });
        seg.appendChild(b);
      });
      bar.appendChild(mk('span', '', 'Demo phone theme:')); bar.appendChild(seg);
      bar.appendChild(mk('span', 'pd-poster-tip', 'All demos are illustrative reproductions of the SwiftUI behaviour, not screen recordings.'));
    });
    mqReduce.addEventListener && mqReduce.addEventListener('change', function () { location.reload(); });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', boot); else boot();
  window.DFPopupDemos = { demos: demos };
})();
