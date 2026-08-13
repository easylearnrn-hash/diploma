'use strict';

/**
 * Editable .docx generation for ACNHS documents.
 *
 * The same print HTML used for the PDF is loaded in Chromium, walked with
 * getComputedStyle, and turned into real WordprocessingML: paragraphs, runs,
 * tables, a repeating letterhead header, a page-number footer and page borders.
 * Nothing is rasterized, so the result stays fully editable in Word.
 */

const fs = require('fs');
const os = require('os');
const path = require('path');
const { execFileSync } = require('child_process');

const TWIPS_PER_PX = 15;      // 1px = 0.75pt = 15 twips
const EMU_PER_PX = 9525;

const PAGE_W = 11906;         // A4 twips
const PAGE_H = 16838;
const MARGIN_X = 1020;        // 18 mm — keeps text clear of the page border
const MARGIN_BOTTOM = 1418;   // 25 mm — footer band
const HEADER_DIST = 397;      // 7 mm
const FOOTER_DIST = 624;      // 11 mm

/* ── Browser-side extraction ─────────────────────────────────────────────── */

// Serialized into the page; must be self-contained.
function extractDocModel() {
  const PX_TW = 15;
  const SECTION_CONTENT_TW = 9860;
  const imgs = [];
  const imgIndex = new Map();
  const contentRoot = document.querySelector('.pdf-content') || document.body;

  const imgId = (src) => {
    if (!imgIndex.has(src)) { imgIndex.set(src, imgs.length); imgs.push(src); }
    return imgIndex.get(src);
  };

  // Word only gets embedded bytes, so anything that is not a data URL is
  // re-encoded through a canvas; `alpha` bakes the watermark fade into the PNG.
  function imgSource(el, alpha, size) {
    const src = el.currentSrc || el.src || '';
    if (!alpha && src.startsWith('data:')) return src;
    try {
      const w = size || el.naturalWidth || el.offsetWidth;
      const h = size || el.naturalHeight || el.offsetHeight;
      const cv = document.createElement('canvas');
      cv.width = w; cv.height = h;
      const ctx = cv.getContext('2d');
      if (alpha) ctx.globalAlpha = alpha;
      ctx.drawImage(el, 0, 0, w, h);
      return cv.toDataURL('image/png');
    } catch (e) {
      return src;
    }
  }

  const px = (v) => parseFloat(v) || 0;
  const tw = (v) => Math.round(px(v) * PX_TW);

  function colorHex(c, minAlpha) {
    const m = /rgba?\(([^)]+)\)/.exec(c || '');
    if (!m) return null;
    const parts = m[1].split(',').map(s => parseFloat(s));
    const a = parts.length > 3 ? parts[3] : 1;
    if (a <= (minAlpha === undefined ? 0.04 : minAlpha)) return null;
    const blend = (v) => Math.round(v * a + 255 * (1 - a));
    return [blend(parts[0]), blend(parts[1]), blend(parts[2])]
      .map(v => Math.max(0, Math.min(255, v)).toString(16).padStart(2, '0'))
      .join('')
      .toUpperCase();
  }

  function createInnerBorderOverlay(frameEl) {
    if (!frameEl) return null;
    const cs = getComputedStyle(frameEl);
    const rect = frameEl.getBoundingClientRect();
    const vw = Math.max(1, Math.round(window.innerWidth));
    const vh = Math.max(1, Math.round(window.innerHeight));

    const scale = 2;
    const cv = document.createElement('canvas');
    cv.width = vw * scale;
    cv.height = vh * scale;
    const ctx = cv.getContext('2d');
    if (!ctx) return null;

    ctx.scale(scale, scale);
    ctx.strokeStyle = '#' + (colorHex(cs.borderTopColor, 0.02) || '9A7A2C');
    const borderPx = Math.max(0.5, px(cs.borderTopWidth) || 0.5);
    ctx.lineWidth = borderPx;

    const inset = borderPx / 2;
    const x = rect.left + inset;
    const y = rect.top + inset;
    const w = Math.max(1, rect.width - borderPx);
    const h = Math.max(1, rect.height - borderPx);
    ctx.strokeRect(x, y, w, h);

    return { id: imgId(cv.toDataURL('image/png')), w: vw, h: vh };
  }

  function mapFont(family) {
    const f = (family || '').toLowerCase();
    if (f.includes('inter') || f.includes('noto sans') || f.includes('sans-serif')) return 'Arial';
    return 'Georgia';
  }

  function rPrOf(cs, extra) {
    const r = {
      font: mapFont(cs.fontFamily),
      sz: Math.max(10, Math.round(px(cs.fontSize) * 1.5)), // half-points
      b: parseInt(cs.fontWeight, 10) >= 600,
      i: cs.fontStyle === 'italic',
      color: colorHex(cs.color, 0.15) || '0A0F1E',
      spacing: Math.round(px(cs.letterSpacing) * PX_TW) || 0,
    };
    if (extra && extra.u) r.u = true;
    return r;
  }

  function borderOf(cs, side) {
    const w = px(cs['border' + side + 'Width']);
    const style = cs['border' + side + 'Style'];
    if (!w || style === 'none' || style === 'hidden') return null;
    const color = colorHex(cs['border' + side + 'Color'], 0.05);
    if (!color) return null;
    return { sz: Math.max(2, Math.min(48, Math.round(w * 6))), color, style: style === 'double' ? 'double' : 'single' };
  }

  function runsFrom(nodes, parentCs) {
    const runs = [];

    const walk = (node, cs, fmt) => {
      if (node.nodeType === 3) {
        let t = node.nodeValue.replace(/\s+/g, ' ');
        if (!t) return;
        if (cs.textTransform === 'uppercase') t = t.toUpperCase();
        if (!t.trim() && !runs.length) return;
        runs.push({ text: t, rPr: rPrOf(cs, fmt) });
        return;
      }
      if (node.nodeType !== 1) return;

      const tag = node.tagName.toLowerCase();
      if (tag === 'br') { runs.push({ br: true }); return; }

      const st = getComputedStyle(node);
      if (st.display === 'none' || st.visibility === 'hidden') return;

      if (tag === 'img') {
        if (!node.currentSrc && !node.src) return;
        const w = node.offsetWidth || node.naturalWidth || 60;
        const h = node.offsetHeight || node.naturalHeight || 60;
        runs.push({ img: { id: imgId(imgSource(node, 0, 0)), w, h } });
        return;
      }

      const childFmt = Object.assign({}, fmt);
      // An inline element with an underline-style bottom border is a fill-in line.
      if (px(st.borderBottomWidth) > 0 && st.borderBottomStyle !== 'none' && !node.children.length) {
        childFmt.u = true;
      }
      if (st.textDecorationLine && st.textDecorationLine.includes('underline')) childFmt.u = true;

      const before = getComputedStyle(node, '::before').content;
      if (before && before !== 'none' && before !== 'normal' && !/counter\(/.test(before) && !node.matches('li')) {
        const txt = before.replace(/^["']|["']$/g, '');
        if (txt.trim()) runs.push({ text: txt + ' ', rPr: rPrOf(getComputedStyle(node, '::before'), childFmt) });
      }

      const kids = Array.from(node.childNodes);
      if (!kids.length && childFmt.u) {
        // Empty signature value — emit an underlined blank line.
        runs.push({ text: '\u00A0'.repeat(26), rPr: rPrOf(st, childFmt) });
        return;
      }
      kids.forEach(c => walk(c, st, childFmt));
    };

    nodes.forEach(n => walk(n, parentCs, {}));

    while (runs.length && runs[runs.length - 1].text !== undefined && !runs[runs.length - 1].text.trim()) runs.pop();
    while (runs.length && runs[0].text !== undefined && !runs[0].text.trim()) runs.shift();
    return runs;
  }

  function runsOf(root) {
    return runsFrom(Array.from(root.childNodes), getComputedStyle(root));
  }

  function pPrOf(el, cs) {
    const align = { justify: 'both', center: 'center', right: 'right', end: 'right' }[cs.textAlign] || 'left';
    return {
      jc: align,
      before: tw(cs.marginTop) + tw(cs.paddingTop),
      after: tw(cs.marginBottom) + tw(cs.paddingBottom),
      line: Math.round(px(cs.lineHeight) * PX_TW) || 0,
      indLeft: tw(cs.marginLeft) + tw(cs.paddingLeft),
      indRight: tw(cs.marginRight) + tw(cs.paddingRight),
      shd: colorHex(cs.backgroundColor, 0.02),
      borders: {
        top: borderOf(cs, 'Top'),
        bottom: borderOf(cs, 'Bottom'),
        left: borderOf(cs, 'Left'),
        right: borderOf(cs, 'Right'),
      },
      keepNext: cs.breakAfter === 'avoid' || cs.pageBreakAfter === 'avoid',
    };
  }

  const BLOCKISH = /^(block|flex|grid|list-item|flow-root|table)/;

  function visibleChildren(el) {
    return Array.from(el.children).filter(c => {
      const st = getComputedStyle(c);
      return st.display !== 'none' && st.visibility !== 'hidden';
    });
  }

  function hasBlockChildren(el) {
    return visibleChildren(el).some(c => BLOCKISH.test(getComputedStyle(c).display));
  }

  function isRow(children) {
    if (children.length < 2) return false;
    const top = children[0].getBoundingClientRect().top;
    return children.every(c => Math.abs(c.getBoundingClientRect().top - top) < 6);
  }

  function isSideBySide(children) {
    return isRow(children) && children.some(c => c.getBoundingClientRect().height >= 34);
  }

  function tableOf(children) {
    const total = children.reduce((s, c) => s + c.getBoundingClientRect().width, 0) || 1;
    const usable = 9860; // content width in twips
    const cells = children.map(c => {
      const cs = getComputedStyle(c);
      const blocks = [];
      emit(c, blocks, true);
      if (!blocks.length) blocks.push({ t: 'p', pPr: pPrOf(c, cs), runs: [] });
      return {
        w: Math.max(400, Math.round((c.getBoundingClientRect().width / total) * usable)),
        shd: colorHex(cs.backgroundColor, 0.02),
        borders: {
          top: borderOf(cs, 'Top'),
          bottom: borderOf(cs, 'Bottom'),
          left: borderOf(cs, 'Left'),
          right: borderOf(cs, 'Right'),
        },
        mar: {
          top: tw(cs.paddingTop), bottom: tw(cs.paddingBottom),
          left: tw(cs.paddingLeft) + 60, right: tw(cs.paddingRight) + 60,
        },
        blocks,
      };
    });
    return { t: 'table', cells };
  }

  function singleHeaderSecurityLine(text) {
    const clean = String(text || '').replace(/\s+/g, ' ').trim();
    if (!clean) return '';

    const parts = clean.split('•').map(s => s.trim()).filter(Boolean);
    if (!parts.length) return clean;

    if (parts.length % 2 === 0) {
      const half = parts.length / 2;
      const a = parts.slice(0, half);
      const b = parts.slice(half);
      if (a.length && a.join('|').toLowerCase() === b.join('|').toLowerCase()) {
        return `${a.join(' • ')} •`;
      }
    }

    return `${parts.slice(0, Math.min(3, parts.length)).join(' • ')} •`;
  }

  function trimRunsEdgeWhitespace(runs) {
    if (!Array.isArray(runs) || !runs.length) return;
    const first = runs.find(r => typeof r.text === 'string' && r.text.length);
    const last = [...runs].reverse().find(r => typeof r.text === 'string' && r.text.length);
    if (first) first.text = first.text.replace(/^\s+/, '');
    if (last) last.text = last.text.replace(/\s+$/, '');
  }

  function normalizeRunsAfterBreak(runs) {
    if (!Array.isArray(runs) || !runs.length) return;

    let atLineStart = true;
    for (const run of runs) {
      if (run.br) {
        atLineStart = true;
        continue;
      }

      if (typeof run.text === 'string') {
        if (atLineStart) run.text = run.text.replace(/^\s+/, '');
        if (run.text.length) atLineStart = false;
        continue;
      }

      if (run.img) atLineStart = false;
    }

    for (let i = runs.length - 1; i >= 0; i--) {
      const r = runs[i];
      if (typeof r.text === 'string' && r.text.length === 0 && !r.br && !r.img) runs.splice(i, 1);
    }
  }

  function emit(el, out, insideCell) {
    const parentCs = getComputedStyle(el);
    // Flex items are blockified, so alignment has to come from the container.
    const flexJc = /flex|grid/.test(parentCs.display)
      ? ({ center: 'center', 'flex-end': 'right', end: 'right', right: 'right' }[parentCs.justifyContent] || null)
      : null;
    let pending = [];

    const flushInline = () => {
      if (!pending.length) return;
      const runs = runsFrom(pending, parentCs);
      pending = [];
      if (runs.some(r => (r.text && r.text.trim()) || r.img)) {
        out.push({
          t: 'p',
          pPr: {
            jc: flexJc || { justify: 'both', center: 'center', right: 'right', end: 'right' }[parentCs.textAlign] || 'left',
            line: Math.round(px(parentCs.lineHeight) * PX_TW) || 0,
            after: 60,
          },
          runs,
        });
      }
    };

    for (const node of Array.from(el.childNodes)) {
      if (node.nodeType === 3) {
        if (node.nodeValue.trim()) pending.push(node);
        continue;
      }
      if (node.nodeType !== 1) continue;

      const child = node;
      const cs = getComputedStyle(child);
      if (cs.display === 'none' || cs.visibility === 'hidden') continue;

      const tag = child.tagName.toLowerCase();
      const cls = typeof child.className === 'string' ? child.className : '';

      if (/pdf-frame-outer|pdf-frame-inner|pdf-watermark/.test(cls)) continue;
      if (tag === 'script' || tag === 'style') continue;

      if (!BLOCKISH.test(cs.display) && tag !== 'br' && tag !== 'hr') { pending.push(child); continue; }
      if (tag === 'br') { pending.push(child); continue; }
      flushInline();

      if (tag === 'hr') {
        const b = borderOf(cs, 'Top') || { sz: 4, color: 'D0D0D8', style: 'single' };
        out.push({ t: 'p', rule: b, pPr: { before: tw(cs.marginTop), after: tw(cs.marginBottom) }, runs: [] });
        continue;
      }

      if (/(^|\s)doc-sig-wrapper(\s|$)/.test(cls) && /flex/.test(cs.display) && child.children.length === 1) {
        const sigChild = child.children[0];
        const containerRect = child.getBoundingClientRect();
        const innerRect = sigChild.getBoundingClientRect();
        const rootRect = contentRoot.getBoundingClientRect();
        const sigCs = getComputedStyle(sigChild);

        const rootW = Math.max(1, rootRect.width);
        const minW = Math.max(0, px(sigCs.minWidth));
        const maxW = Math.max(0, px(sigCs.maxWidth));
        let desiredW = innerRect.width || minW || maxW || 280;
        if (maxW > 0) desiredW = Math.max(desiredW, Math.min(maxW, rootW));
        if (minW > 0) desiredW = Math.max(desiredW, minW);
        desiredW = Math.min(rootW, desiredW);

        let shiftPx = innerRect.left - rootRect.left;
        if (shiftPx < 4) {
          const rightShift = Math.max(0, containerRect.width - desiredW);
          shiftPx = Math.max(shiftPx, (containerRect.left - rootRect.left) + rightShift);
        }

        const shiftRatio = Math.max(0, Math.min(1, shiftPx / rootW));
        const widthRatio = Math.max(0, Math.min(1, desiredW / rootW));
        const shiftTw = Math.max(0, Math.round(SECTION_CONTENT_TW * shiftRatio));
        const blockRightTw = Math.max(0, Math.round(SECTION_CONTENT_TW * Math.max(0, 1 - shiftRatio - widthRatio)));

        const wrapperPr = pPrOf(child, cs);
        if (wrapperPr.before) out.push({ t: 'spacer', h: wrapperPr.before });

        const sigBlocks = [];
        emit(sigChild, sigBlocks, insideCell);
        if (shiftTw) {
          sigBlocks.forEach(b => {
            if (b.t !== 'p') return;
            b.pPr = b.pPr || {};
            if (b.rule) {
              const oldLeft = b.pPr.indLeft || 0;
              const oldRight = b.pPr.indRight || 0;
              const oldWidth = Math.max(0, SECTION_CONTENT_TW - oldLeft - oldRight);
              b.pPr.indLeft = shiftTw;
              b.pPr.indRight = Math.max(0, SECTION_CONTENT_TW - shiftTw - oldWidth);
              return;
            }

            b.pPr.jc = 'left';
            b.pPr.indLeft = shiftTw;
            b.pPr.indRight = blockRightTw;
            trimRunsEdgeWhitespace(b.runs || []);
            normalizeRunsAfterBreak(b.runs || []);
          });
        }
        out.push(...sigBlocks);

        if (wrapperPr.after) out.push({ t: 'spacer', h: wrapperPr.after });
        continue;
      }

      if (tag === 'img') {
        const pPr = pPrOf(child, cs);
        if (flexJc) pPr.jc = flexJc;
        out.push({ t: 'p', pPr, runs: runsFrom([child], cs) });
        continue;
      }

      if (tag === 'ul' || tag === 'ol') {
        const numbered = child.classList.contains('numbered') || tag === 'ol';
        Array.from(child.children).forEach((li, i) => {
          const liCs = getComputedStyle(li);
          const beforeCs = getComputedStyle(li, '::before');
          const marker = numbered ? (i + 1) + '.' : '\u2014';
          const pPr = pPrOf(li, liCs);
          pPr.indLeft = (pPr.indLeft || 0) + 340;
          pPr.hanging = 340;
          const runs = runsOf(li);
          runs.unshift({ text: marker + '\t', rPr: rPrOf(beforeCs, {}) });
          out.push({ t: 'p', pPr, runs, tab: pPr.indLeft });
        });
        continue;
      }

      if (tag === 'li') {
        out.push({ t: 'p', pPr: pPrOf(child, cs), runs: runsOf(child) });
        continue;
      }

      const grandKids = visibleChildren(child);

      // Flex/grid rows become tables when their items are tall, collapse to a
      // single paragraph when they are one line of inline content, and are
      // recursed when they stack real blocks.
      if (/flex|grid/.test(cs.display)) {
        const stacksBlocks = grandKids.some(g => hasBlockChildren(g));
        if (!insideCell && isSideBySide(grandKids)) { out.push(tableOf(grandKids)); continue; }
        if (!stacksBlocks && (grandKids.length <= 1 || isRow(grandKids))) {
          out.push({ t: 'p', pPr: pPrOf(child, cs), runs: runsOf(child) });
          continue;
        }
      }

      if (hasBlockChildren(child)) {
        const pPr = pPrOf(child, cs);
        if (pPr.before) out.push({ t: 'spacer', h: pPr.before });
        emit(child, out, insideCell);
        if (pPr.after) out.push({ t: 'spacer', h: pPr.after });
        continue;
      }

      const rect = child.getBoundingClientRect();
      const text = (child.textContent || '').trim();
      if (!text && !child.querySelector('img')) {
        // Decorative divider: an empty block drawn with a background or a border.
        const bg = colorHex(cs.backgroundColor, 0.05);
        const bb = borderOf(cs, 'Bottom') || borderOf(cs, 'Top');
        const rule = bb || (bg && rect.height > 0 && rect.height <= 4
          ? { sz: Math.max(2, Math.round(rect.height * 6)), color: bg, style: 'single' }
          : null);
        if (rule) {
          const rootRect = contentRoot.getBoundingClientRect();
          out.push({
            t: 'p',
            rule,
            pPr: {
              before: tw(cs.marginTop),
              after: tw(cs.marginBottom),
              indLeft: Math.max(0, Math.round((rect.left - rootRect.left) * PX_TW)),
              indRight: Math.max(0, Math.round((rootRect.right - rect.right) * PX_TW)),
            },
            runs: [],
          });
        }
        continue;
      }

      out.push({ t: 'p', pPr: pPrOf(child, cs), runs: runsOf(child) });
    }

    flushInline();
  }
  const content = contentRoot;
  const headerEl = content.querySelector('.doc-header');
  const microEl = content.querySelector('.doc-microtext');
  const watermarkImg = document.querySelector('.pdf-watermark img');

  const headerBlocks = [];
  if (headerEl) {
    const hLeft = headerEl.querySelector('.doc-header-left');
    const hCenter = headerEl.querySelector('.doc-header-center');
    const hRight = headerEl.querySelector('.doc-header-right');
    if (hLeft && hCenter && hRight) {
      // Keep header in a stable 3-column layout regardless of row detection noise.
      const headerTable = tableOf([hLeft, hCenter, hRight]);
      if (headerTable.cells && headerTable.cells.length === 3) {
        // Reserve enough center width so the logo is never clipped.
        const totalW = 9860;
        const centerW = 1700;
        const sideW = Math.floor((totalW - centerW) / 2);
        headerTable.cells[0].w = sideW;
        headerTable.cells[1].w = centerW;
        headerTable.cells[2].w = totalW - sideW - centerW;

        headerTable.cells[0].vAlign = 'top';
        headerTable.cells[1].vAlign = 'center';
        headerTable.cells[2].vAlign = 'top';

        const centerBlocks = headerTable.cells[1].blocks || [];
        centerBlocks.forEach(b => {
          if (b.t !== 'p' || !Array.isArray(b.runs) || !b.runs.length) return;
          const imageOnly = b.runs.every(r => r.img || r.br);
          if (!imageOnly) return;
          b.pPr = b.pPr || {};
          b.pPr.line = 0;
          b.pPr.before = 0;
          b.pPr.after = 0;
        });
      }
      headerBlocks.push(headerTable);
    } else {
      const kids = visibleChildren(headerEl);
      if (isSideBySide(kids)) headerBlocks.push(tableOf(kids));
      else emit(headerEl, headerBlocks, false);
    }
    const hcs = getComputedStyle(headerEl);
    const b = borderOf(hcs, 'Bottom');
    headerBlocks.push({ t: 'p', rule: b || { sz: 6, color: 'C8C8D0', style: 'single' }, pPr: { before: 40, after: 60 }, runs: [] });
  }
  if (microEl) {
    const mcs = getComputedStyle(microEl);
    const secLine = singleHeaderSecurityLine(microEl.textContent || '');
    if (secLine) {
      headerBlocks.push({
        t: 'p',
        pPr: pPrOf(microEl, mcs),
        runs: [{ text: ` ${secLine} `, rPr: rPrOf(mcs, {}) }],
      });
    }
  }

  const headerHeight = (headerEl ? headerEl.getBoundingClientRect().height : 0)
    + (microEl ? microEl.getBoundingClientRect().height : 0);

  // Body: everything except the letterhead and microtext (they live in the header part).
  if (headerEl) headerEl.remove();
  if (microEl) microEl.remove();

  const body = [];
  emit(content, body, false);

  const frame = document.querySelector('.pdf-frame-outer');
  const frameCs = frame ? getComputedStyle(frame) : null;
  const innerFrame = document.querySelector('.pdf-frame-inner');
  const innerBorderOverlay = createInnerBorderOverlay(innerFrame);

  return {
    body,
    header: headerBlocks,
    headerHeightTw: Math.round(headerHeight * PX_TW),
    images: imgs,
    watermark: watermarkImg ? { id: imgId(imgSource(watermarkImg, 0.055, 760)), w: 380, h: 380 } : null,
    innerBorderOverlay,
    frame: frameCs
      ? {
          color: colorHex(frameCs.borderTopColor, 0.05) || '2B3550',
          space: Math.round(px(frameCs.top) * 0.75),
          size: Math.max(4, Math.min(24, Math.round(px(frameCs.borderTopWidth) * 6))),
        }
      : null,
  };
}

/* ── OOXML helpers ───────────────────────────────────────────────────────── */

const esc = (s) => String(s == null ? '' : s)
  .replace(/&/g, '&amp;')
  .replace(/</g, '&lt;')
  .replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;')
  .replace(/[\u0000-\u0008\u000b\u000c\u000e-\u001f]/g, '');

function rPrXml(rPr) {
  if (!rPr) return '';
  const p = [];
  p.push(`<w:rFonts w:ascii="${rPr.font}" w:hAnsi="${rPr.font}" w:cs="${rPr.font}"/>`);
  if (rPr.b) p.push('<w:b/><w:bCs/>');
  if (rPr.i) p.push('<w:i/><w:iCs/>');
  if (rPr.u) p.push('<w:u w:val="single" w:color="A0A0B0"/>');
  if (rPr.color) p.push(`<w:color w:val="${rPr.color}"/>`);
  if (rPr.spacing) p.push(`<w:spacing w:val="${rPr.spacing}"/>`);
  p.push(`<w:sz w:val="${rPr.sz}"/><w:szCs w:val="${rPr.sz}"/>`);
  return `<w:rPr>${p.join('')}</w:rPr>`;
}

function drawingXml(img, relId, docPrId) {
  const cx = Math.round(img.w * EMU_PER_PX);
  const cy = Math.round(img.h * EMU_PER_PX);
  return `<w:r><w:drawing><wp:inline distT="0" distB="0" distL="0" distR="0">
    <wp:extent cx="${cx}" cy="${cy}"/><wp:effectExtent l="0" t="0" r="0" b="0"/>
    <wp:docPr id="${docPrId}" name="Image ${docPrId}"/>
    <wp:cNvGraphicFramePr><a:graphicFrameLocks noChangeAspect="1"/></wp:cNvGraphicFramePr>
    <a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
      <pic:pic><pic:nvPicPr><pic:cNvPr id="${docPrId}" name="image${docPrId}"/><pic:cNvPicPr/></pic:nvPicPr>
      <pic:blipFill><a:blip r:embed="${relId}"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>
      <pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="${cx}" cy="${cy}"/></a:xfrm>
      <a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr></pic:pic>
    </a:graphicData></a:graphic></wp:inline></w:drawing></w:r>`;
}

function watermarkXml(img, relId, docPrId) {
  const cx = Math.round(img.w * EMU_PER_PX);
  const cy = Math.round(img.h * EMU_PER_PX);
  return `<w:r><w:drawing><wp:anchor distT="0" distB="0" distL="0" distR="0" simplePos="0"
      relativeHeight="1" behindDoc="1" locked="0" layoutInCell="1" allowOverlap="1">
    <wp:simplePos x="0" y="0"/>
    <wp:positionH relativeFrom="page"><wp:align>center</wp:align></wp:positionH>
    <wp:positionV relativeFrom="page"><wp:align>center</wp:align></wp:positionV>
    <wp:extent cx="${cx}" cy="${cy}"/><wp:effectExtent l="0" t="0" r="0" b="0"/>
    <wp:wrapNone/>
    <wp:docPr id="${docPrId}" name="Watermark"/>
    <wp:cNvGraphicFramePr><a:graphicFrameLocks noChangeAspect="1"/></wp:cNvGraphicFramePr>
    <a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
      <pic:pic><pic:nvPicPr><pic:cNvPr id="${docPrId}" name="watermark"/><pic:cNvPicPr/></pic:nvPicPr>
      <pic:blipFill><a:blip r:embed="${relId}"/>
        <a:stretch><a:fillRect/></a:stretch></pic:blipFill>
      <pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="${cx}" cy="${cy}"/></a:xfrm>
      <a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr></pic:pic>
    </a:graphicData></a:graphic></wp:anchor></w:drawing></w:r>`;
}

function innerBorderOverlayXml(img, relId, docPrId) {
  const cx = Math.round(img.w * EMU_PER_PX);
  const cy = Math.round(img.h * EMU_PER_PX);
  return `<w:r><w:drawing><wp:anchor distT="0" distB="0" distL="0" distR="0" simplePos="0"
      relativeHeight="2" behindDoc="1" locked="0" layoutInCell="1" allowOverlap="1">
    <wp:simplePos x="0" y="0"/>
    <wp:positionH relativeFrom="page"><wp:align>center</wp:align></wp:positionH>
    <wp:positionV relativeFrom="page"><wp:align>center</wp:align></wp:positionV>
    <wp:extent cx="${cx}" cy="${cy}"/><wp:effectExtent l="0" t="0" r="0" b="0"/>
    <wp:wrapNone/>
    <wp:docPr id="${docPrId}" name="InnerBorder"/>
    <wp:cNvGraphicFramePr><a:graphicFrameLocks noChangeAspect="1"/></wp:cNvGraphicFramePr>
    <a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
      <pic:pic><pic:nvPicPr><pic:cNvPr id="${docPrId}" name="inner-border"/><pic:cNvPicPr/></pic:nvPicPr>
      <pic:blipFill><a:blip r:embed="${relId}"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill>
      <pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="${cx}" cy="${cy}"/></a:xfrm>
      <a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr></pic:pic>
    </a:graphicData></a:graphic></wp:anchor></w:drawing></w:r>`;
}

function bdrXml(tag, b) {
  return `<w:${tag} w:val="${b.style}" w:sz="${b.sz}" w:space="1" w:color="${b.color}"/>`;
}

function pPrXml(block) {
  const pPr = block.pPr || {};
  const p = [];
  if (pPr.keepNext) p.push('<w:keepNext/>');
  if (pPr.jc && pPr.jc !== 'left') p.push(`<w:jc w:val="${pPr.jc}"/>`);

  const b = pPr.borders || {};
  const rule = block.rule;
  if (rule) {
    p.push(`<w:pBdr>${bdrXml('bottom', rule)}</w:pBdr>`);
  } else if (b.top || b.bottom || b.left || b.right) {
    const parts = [];
    if (b.top) parts.push(bdrXml('top', b.top));
    if (b.left) parts.push(bdrXml('left', b.left));
    if (b.bottom) parts.push(bdrXml('bottom', b.bottom));
    if (b.right) parts.push(bdrXml('right', b.right));
    p.push(`<w:pBdr>${parts.join('')}</w:pBdr>`);
  }
  if (pPr.shd) p.push(`<w:shd w:val="clear" w:color="auto" w:fill="${pPr.shd}"/>`);

  const before = Math.min(pPr.before || 0, 900);
  const after = Math.min(pPr.after || 0, 900);
  const line = pPr.line && pPr.line > 120 ? ` w:line="${Math.min(pPr.line, 1200)}" w:lineRule="atLeast"` : '';
  p.push(`<w:spacing w:before="${before}" w:after="${after}"${line}/>`);

  const indLeft = pPr.indLeft || 0;
  const indRight = pPr.indRight || 0;
  if (indLeft || indRight || pPr.hanging) {
    p.push(`<w:ind w:left="${indLeft}" w:right="${indRight}"${pPr.hanging ? ` w:hanging="${pPr.hanging}"` : ''}/>`);
  }
  if (block.tab) p.push(`<w:tabs><w:tab w:val="left" w:pos="${block.tab}"/></w:tabs>`);
  return `<w:pPr>${p.join('')}</w:pPr>`;
}

/* ── Model → XML ─────────────────────────────────────────────────────────── */

function blocksToXml(blocks, ctx) {
  const out = [];
  for (const block of blocks) {
    if (block.t === 'spacer') {
      out.push(`<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="${Math.max(20, Math.min(block.h, 600))}" w:lineRule="exact"/></w:pPr></w:p>`);
      continue;
    }

    if (block.t === 'table') {
      const grid = block.cells.map(c => `<w:gridCol w:w="${c.w}"/>`).join('');
      const cells = block.cells.map(cell => {
        const bd = [];
        if (cell.borders.top) bd.push(bdrXml('top', cell.borders.top));
        if (cell.borders.left) bd.push(bdrXml('left', cell.borders.left));
        if (cell.borders.bottom) bd.push(bdrXml('bottom', cell.borders.bottom));
        if (cell.borders.right) bd.push(bdrXml('right', cell.borders.right));
        const tcPr = [
          `<w:tcW w:w="${cell.w}" w:type="dxa"/>`,
          bd.length ? `<w:tcBorders>${bd.join('')}</w:tcBorders>` : '',
          cell.shd ? `<w:shd w:val="clear" w:color="auto" w:fill="${cell.shd}"/>` : '',
          `<w:tcMar><w:top w:w="${cell.mar.top}" w:type="dxa"/><w:left w:w="${cell.mar.left}" w:type="dxa"/><w:bottom w:w="${cell.mar.bottom}" w:type="dxa"/><w:right w:w="${cell.mar.right}" w:type="dxa"/></w:tcMar>`,
          `<w:vAlign w:val="${cell.vAlign || 'center'}"/>`,
        ].join('');
        const inner = blocksToXml(cell.blocks, ctx) || '<w:p/>';
        return `<w:tc><w:tcPr>${tcPr}</w:tcPr>${inner}</w:tc>`;
      }).join('');

      out.push(`<w:tbl><w:tblPr><w:tblW w:w="5000" w:type="pct"/><w:tblLayout w:type="fixed"/>` +
        `<w:tblCellMar><w:left w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr>` +
        `<w:tblGrid>${grid}</w:tblGrid><w:tr>${cells}</w:tr></w:tbl>` +
        `<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr></w:p>`);
      continue;
    }

    const runs = (block.runs || []).map(run => {
      if (run.br) return '<w:r><w:br/></w:r>';
      if (run.img) {
        const relId = ctx.imageRel(run.img.id);
        return relId ? drawingXml(run.img, relId, ctx.nextId()) : '';
      }
      const text = run.text || '';
      if (text.includes('\t')) {
        return text.split('\t').map((part, i) =>
          `<w:r>${rPrXml(run.rPr)}${i ? '<w:tab/>' : ''}${part ? `<w:t xml:space="preserve">${esc(part)}</w:t>` : ''}</w:r>`
        ).join('');
      }
      return `<w:r>${rPrXml(run.rPr)}<w:t xml:space="preserve">${esc(text)}</w:t></w:r>`;
    }).join('');

    out.push(`<w:p>${pPrXml(block)}${runs}</w:p>`);
  }
  return out.join('\n');
}

function footerXml(refNo, email) {
  const rpr = '<w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:cs="Arial"/><w:color w:val="3A4A6B"/><w:sz w:val="16"/><w:szCs w:val="16"/></w:rPr>';
  const bold = '<w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:cs="Arial"/><w:b/><w:color w:val="0A0F1E"/><w:sz w:val="16"/><w:szCs w:val="16"/></w:rPr>';
  const field = (instr) =>
    `<w:r>${rpr}<w:fldChar w:fldCharType="begin"/></w:r>` +
    `<w:r>${rpr}<w:instrText xml:space="preserve"> ${instr} </w:instrText></w:r>` +
    `<w:r>${rpr}<w:fldChar w:fldCharType="separate"/></w:r>` +
    `<w:r>${rpr}<w:t>1</w:t></w:r>` +
    `<w:r>${rpr}<w:fldChar w:fldCharType="end"/></w:r>`;

  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
       xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <w:p>
    <w:pPr>
      <w:pBdr><w:top w:val="single" w:sz="4" w:space="6" w:color="D0D0D8"/></w:pBdr>
      <w:jc w:val="center"/>
      <w:spacing w:before="0" w:after="0"/>
    </w:pPr>
    <w:r>${bold}<w:t>www.acnhs.am</w:t></w:r>
    <w:r>${rpr}<w:t xml:space="preserve">  •  ${esc(email)}  •  Ref: ${esc(refNo)}  •  Page </w:t></w:r>
    ${field('PAGE')}
    <w:r>${rpr}<w:t xml:space="preserve"> of </w:t></w:r>
    ${field('NUMPAGES')}
  </w:p>
</w:ftr>`;
}

function stylesXml() {
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault><w:rPr>
      <w:rFonts w:ascii="Georgia" w:hAnsi="Georgia" w:cs="Georgia"/>
      <w:color w:val="0A0F1E"/><w:sz w:val="22"/><w:szCs w:val="22"/>
    </w:rPr></w:rPrDefault>
    <w:pPrDefault><w:pPr>
      <w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>
      <w:widowControl/>
    </w:pPr></w:pPrDefault>
  </w:docDefaults>
  <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
    <w:name w:val="Normal"/><w:qFormat/>
  </w:style>
</w:styles>`;
}

/* ── Package assembly ────────────────────────────────────────────────────── */

function dataUrlToBuffer(src) {
  const m = /^data:([^;,]+)(;base64)?,(.*)$/s.exec(src || '');
  if (!m) return null;
  const ext = /png/i.test(m[1]) ? 'png' : /jpe?g/i.test(m[1]) ? 'jpeg' : /gif/i.test(m[1]) ? 'gif' : 'png';
  const data = m[2] ? Buffer.from(m[3], 'base64') : Buffer.from(decodeURIComponent(m[3]), 'binary');
  return { ext, data };
}

// Images may be referenced by URL; only the local dev server is fetched.
async function fetchLocalImage(src) {
  let url;
  try { url = new URL(src); } catch (e) { return null; }
  if (!/^https?:$/.test(url.protocol)) return null;
  if (!/^(localhost|127\.0\.0\.1|\[::1\])$/i.test(url.hostname)) return null;

  const res = await fetch(url, { redirect: 'error' }).catch(() => null);
  if (!res || !res.ok) return null;
  const type = res.headers.get('content-type') || '';
  const ext = /jpe?g/i.test(type) ? 'jpeg' : /gif/i.test(type) ? 'gif' : 'png';
  const data = Buffer.from(await res.arrayBuffer());
  return data.length && data.length < 8 * 1024 * 1024 ? { ext, data } : null;
}

async function resolveImages(sources) {
  const media = [];
  for (let i = 0; i < sources.length; i++) {
    const img = dataUrlToBuffer(sources[i]) || await fetchLocalImage(sources[i]);
    if (img) media.push({ index: i, name: `image${i + 1}.${img.ext}`, ext: img.ext, data: img.data });
  }
  return media;
}

async function buildDocx(model, opts) {
  const refNo = opts.refNo || '';
  const email = opts.email || 'info@acnhs.am';

  const media = await resolveImages(model.images);

  const headerImageRel = new Map();
  media.forEach((m, i) => headerImageRel.set(m.index, `rIdImg${i + 1}`));

  let idSeq = 100;
  const ctx = {
    nextId: () => ++idSeq,
    imageRel: (id) => headerImageRel.get(id) || null,
  };

  const headerBody = blocksToXml(model.header, ctx);
  const innerBorderOverlay = model.innerBorderOverlay && ctx.imageRel(model.innerBorderOverlay.id)
    ? `<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr>` +
      innerBorderOverlayXml(model.innerBorderOverlay, ctx.imageRel(model.innerBorderOverlay.id), ctx.nextId()) + `</w:p>`
    : '';
  const watermark = model.watermark && ctx.imageRel(model.watermark.id)
    ? `<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/></w:pPr>` +
      watermarkXml(model.watermark, ctx.imageRel(model.watermark.id), ctx.nextId()) + `</w:p>`
    : '';

  const headerXml = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:hdr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
       xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
       xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
       xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
       xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
  ${innerBorderOverlay}
  ${watermark}
  ${headerBody}
</w:hdr>`;

  // Body images are not supported outside the letterhead; drop their relations.
  const bodyCtx = { nextId: ctx.nextId, imageRel: () => null };
  const bodyXml = blocksToXml(model.body, bodyCtx);

  const topMargin = Math.max(1200, HEADER_DIST + (model.headerHeightTw || 1400) + 400);
  const frameColor = (model.frame && model.frame.color) || '2B3550';
  const frameSpace = Math.max(6, Math.min(28, (model.frame && model.frame.space) || 11));
  const frameSize = Math.max(4, Math.min(24, (model.frame && model.frame.size) || 9));
  const pgBorder = ['top', 'left', 'bottom', 'right']
    .map(s => `<w:${s} w:val="single" w:sz="${frameSize}" w:space="${frameSpace}" w:color="${frameColor}"/>`)
    .join('');

  const documentXml = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
            xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
            xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
            xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
            xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
  <w:body>
    ${bodyXml}
    <w:sectPr>
      <w:headerReference w:type="default" r:id="rIdHdr"/>
      <w:footerReference w:type="default" r:id="rIdFtr"/>
      <w:pgSz w:w="${PAGE_W}" w:h="${PAGE_H}"/>
      <w:pgMar w:top="${topMargin}" w:right="${MARGIN_X}" w:bottom="${MARGIN_BOTTOM}" w:left="${MARGIN_X}"
               w:header="${HEADER_DIST}" w:footer="${FOOTER_DIST}" w:gutter="0"/>
      <w:pgBorders w:offsetFrom="page" w:display="allPages">${pgBorder}</w:pgBorders>
      <w:cols w:space="708"/>
      <w:docGrid w:linePitch="360"/>
    </w:sectPr>
  </w:body>
</w:document>`;

  const documentRels = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rIdStyles" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
  <Relationship Id="rIdHdr" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/header" Target="header1.xml"/>
  <Relationship Id="rIdFtr" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/>
</Relationships>`;

  const headerRels = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  ${media.map(m => `<Relationship Id="${headerImageRel.get(m.index)}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/${m.name}"/>`).join('\n  ')}
</Relationships>`;

  const contentTypes = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="png" ContentType="image/png"/>
  <Default Extension="jpeg" ContentType="image/jpeg"/>
  <Default Extension="gif" ContentType="image/gif"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/word/header1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml"/>
  <Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/>
</Types>`;

  const rootRels = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>`;

  const tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'acnhs-docx-'));
  const outDocx = path.join(os.tmpdir(), `acnhs-word-${Date.now()}-${Math.random().toString(36).slice(2)}.docx`);
  try {
    fs.mkdirSync(path.join(tmpRoot, '_rels'), { recursive: true });
    fs.mkdirSync(path.join(tmpRoot, 'word', '_rels'), { recursive: true });
    fs.mkdirSync(path.join(tmpRoot, 'word', 'media'), { recursive: true });

    fs.writeFileSync(path.join(tmpRoot, '[Content_Types].xml'), contentTypes, 'utf8');
    fs.writeFileSync(path.join(tmpRoot, '_rels', '.rels'), rootRels, 'utf8');
    fs.writeFileSync(path.join(tmpRoot, 'word', 'document.xml'), documentXml, 'utf8');
    fs.writeFileSync(path.join(tmpRoot, 'word', 'styles.xml'), stylesXml(), 'utf8');
    fs.writeFileSync(path.join(tmpRoot, 'word', 'header1.xml'), headerXml, 'utf8');
    fs.writeFileSync(path.join(tmpRoot, 'word', 'footer1.xml'), footerXml(refNo, email), 'utf8');
    fs.writeFileSync(path.join(tmpRoot, 'word', '_rels', 'document.xml.rels'), documentRels, 'utf8');
    fs.writeFileSync(path.join(tmpRoot, 'word', '_rels', 'header1.xml.rels'), headerRels, 'utf8');
    media.forEach(m => fs.writeFileSync(path.join(tmpRoot, 'word', 'media', m.name), m.data));

    execFileSync('zip', ['-q', '-X', '-r', outDocx, '[Content_Types].xml', '_rels', 'word'], { cwd: tmpRoot });
    return fs.readFileSync(outDocx);
  } finally {
    try { fs.rmSync(tmpRoot, { recursive: true, force: true }); } catch (_) {}
    try { fs.unlinkSync(outDocx); } catch (_) {}
  }
}

module.exports = { extractDocModel, buildDocx };
