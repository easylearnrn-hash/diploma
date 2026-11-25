/* ACNHS cloud rendering client
 *
 * - renderPdf(): sends the print HTML to the Supabase Edge Function `render-pdf` (Browserless cloud Chromium) and
 *   returns the PDF bytes. No credentials live here: the Browserless token is a Supabase secret.
 * - On a developer machine (file:// or localhost) a failed cloud call may fall back to the old local pdf-server.js.
 *   On the live site there is no fallback: it always uses the cloud.
 *   Console switch for testing: localStorage.setItem('acnhs-render-backend', 'cloud' | 'local' | 'auto')  (default auto).
 * - pdfDocToDocx(): builds the Word file (one full-page image per PDF page) in the browser from the cloud PDF.
 *
 * Editing and live pagination never call this: it is only used for the exact page preview and for exports.
 */
(function () {
  'use strict';

  const LOCAL_SERVER = 'http://localhost:8001';
  const isDevHost = () => location.protocol === 'file:' || /^(localhost|127\.0\.0\.1)$/.test(location.hostname);

  class RenderError extends Error {
    constructor(message, code, status) { super(message); this.name = 'RenderError'; this.code = code || 'error'; this.status = status || 0; }
  }

  function adminId() {
    try { return localStorage.getItem('userId') || sessionStorage.getItem('userId') || ''; } catch (_) { return ''; }
  }

  const MESSAGES = {
    not_configured: 'Cloud PDF rendering is not set up yet: the render-pdf function has not been deployed to Supabase (or its Browserless token is missing). See RENDER-PDF-SETUP.md.',
    unauthorized: 'Please sign in again as an admin to create PDFs.',
    forbidden_origin: 'This page is not allowed to use cloud rendering.',
    busy: 'The rendering service is busy. Please try again in a few seconds.',
    rate_limited: 'Too many PDFs were requested in a short time. Please wait a few seconds.',
    timeout: 'Rendering took too long. Please try again.',
    too_large: 'The document is too large to render.',
    upstream_auth: 'The rendering service rejected the Supabase credentials. Please contact the site owner.',
    unreachable: 'Could not reach the cloud rendering service. Check your internet connection, or that the render-pdf function has been deployed.',
  };

  async function cloudPdf(payload, signal) {
    const cfg = (typeof SUPABASE_CONFIG !== 'undefined') ? SUPABASE_CONFIG : null;
    if (!cfg || !cfg.url) throw new RenderError('Supabase is not configured', 'not_configured');
    const id = adminId();
    if (!id) throw new RenderError(MESSAGES.unauthorized, 'unauthorized', 401);

    let res;
    try {
      res = await fetch(cfg.url + '/functions/v1/render-pdf', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          apikey: cfg.anonKey,
          Authorization: 'Bearer ' + cfg.anonKey,
          'x-admin-id': id,
        },
        body: JSON.stringify(payload),
        signal,
      });
    } catch (e) {
      if (e && e.name === 'AbortError') throw e;
      throw new RenderError(MESSAGES.unreachable, 'unreachable');
    }
    if (!res.ok) {
      let code = 'error', msg = 'Rendering failed (' + res.status + ')';
      try { const j = await res.json(); if (j && j.code) code = String(j.code); if (j && (j.error || j.message)) msg = j.error || j.message; } catch (_) { /* not JSON */ }
      // The function is not deployed yet: the platform itself answers 404 (body like {"code":"NOT_FOUND",...})
      if (res.status === 404) code = 'not_configured';
      throw new RenderError(MESSAGES[code] || msg, code, res.status);
    }
    const bytes = new Uint8Array(await res.arrayBuffer());
    if (String.fromCharCode(bytes[0], bytes[1], bytes[2], bytes[3]) !== '%PDF') throw new RenderError('Rendering returned an invalid file', 'upstream_error');
    return bytes;
  }

  async function localPdf(payload, signal) {
    const res = await fetch(LOCAL_SERVER + '/generate-pdf', {
      method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload), signal,
    });
    if (!res.ok) throw new RenderError('Local export server error ' + res.status, 'local_error', res.status);
    return new Uint8Array(await res.arrayBuffer());
  }

  // Which backend produced the last PDF: the page preview waits longer between renders for the cloud (each render costs credits)
  const state = { lastBackend: 'cloud' };

  async function renderPdf(payload, opts) {
    const signal = opts && opts.signal;
    let preferred = 'auto';
    try { preferred = localStorage.getItem('acnhs-render-backend') || 'auto'; } catch (_) { /* default */ }
    const dev = isDevHost();

    if (preferred === 'local' && dev) { const b = await localPdf(payload, signal); state.lastBackend = 'local'; return b; }
    try {
      const b = await cloudPdf(payload, signal);
      state.lastBackend = 'cloud';
      return b;
    } catch (e) {
      if (e && e.name === 'AbortError') throw e;
      // Developer machines only: keep working with the local server while the cloud function is not deployed or not reachable
      const cloudDown = e instanceof RenderError && ['not_configured', 'unreachable', 'upstream_unreachable'].includes(e.code);
      if (dev && cloudDown && preferred !== 'cloud') {
        try { const b = await localPdf(payload, signal); state.lastBackend = 'local'; return b; } catch (le) { if (le && le.name === 'AbortError') throw le; /* report the cloud error */ }
      }
      throw e;
    }
  }

  /* ───────────────────────── Word (.docx) from PDF pages ───────────────────────── */

  const A4_TWIP_W = 11906, A4_TWIP_H = 16838, A4_EMU_W = 7559060, A4_EMU_H = 10692130;

  const CRC_TABLE = (() => {
    const t = new Uint32Array(256);
    for (let n = 0; n < 256; n++) { let c = n; for (let k = 0; k < 8; k++) c = c & 1 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1; t[n] = c >>> 0; }
    return t;
  })();
  function crc32(bytes) {
    let c = 0xFFFFFFFF;
    for (let i = 0; i < bytes.length; i++) c = CRC_TABLE[(c ^ bytes[i]) & 0xFF] ^ (c >>> 8);
    return (c ^ 0xFFFFFFFF) >>> 0;
  }

  // Minimal ZIP writer (no compression: PNG pages are already compressed, the XML parts are tiny)
  function makeZip(files) {
    const enc = new TextEncoder();
    const parts = [], central = [];
    let offset = 0;
    const dosTime = 0, dosDate = (46 << 9) | (1 << 5) | 1;   // 2026-01-01, fixed so the output is reproducible
    for (const f of files) {
      const name = enc.encode(f.name), data = f.data, crc = crc32(data);
      const lh = new DataView(new ArrayBuffer(30));
      lh.setUint32(0, 0x04034b50, true); lh.setUint16(4, 20, true); lh.setUint16(6, 0x0800, true); lh.setUint16(8, 0, true);
      lh.setUint16(10, dosTime, true); lh.setUint16(12, dosDate, true); lh.setUint32(14, crc, true);
      lh.setUint32(18, data.length, true); lh.setUint32(22, data.length, true); lh.setUint16(26, name.length, true); lh.setUint16(28, 0, true);
      parts.push(new Uint8Array(lh.buffer), name, data);
      const ch = new DataView(new ArrayBuffer(46));
      ch.setUint32(0, 0x02014b50, true); ch.setUint16(4, 20, true); ch.setUint16(6, 20, true); ch.setUint16(8, 0x0800, true); ch.setUint16(10, 0, true);
      ch.setUint16(12, dosTime, true); ch.setUint16(14, dosDate, true); ch.setUint32(16, crc, true);
      ch.setUint32(20, data.length, true); ch.setUint32(24, data.length, true); ch.setUint16(28, name.length, true);
      ch.setUint32(42, offset, true);
      central.push(new Uint8Array(ch.buffer), name);
      offset += 30 + name.length + data.length;
    }
    const centralSize = central.reduce((n, p) => n + p.length, 0);
    const end = new DataView(new ArrayBuffer(22));
    end.setUint32(0, 0x06054b50, true); end.setUint16(8, files.length, true); end.setUint16(10, files.length, true);
    end.setUint32(12, centralSize, true); end.setUint32(16, offset, true);
    return new Blob([...parts, ...central, new Uint8Array(end.buffer)], { type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' });
  }

  function documentXml(pageCount) {
    const pages = [];
    for (let i = 1; i <= pageCount; i++) {
      pages.push(`
    <w:p>
      <w:r>
        <w:drawing>
          <wp:inline distT="0" distB="0" distL="0" distR="0">
            <wp:extent cx="${A4_EMU_W}" cy="${A4_EMU_H}"/>
            <wp:effectExtent l="0" t="0" r="0" b="0"/>
            <wp:docPr id="${i}" name="Page ${i}"/>
            <wp:cNvGraphicFramePr>
              <a:graphicFrameLocks noChangeAspect="1"/>
            </wp:cNvGraphicFramePr>
            <a:graphic>
              <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                <pic:pic>
                  <pic:nvPicPr>
                    <pic:cNvPr id="0" name="page-${i}.png"/>
                    <pic:cNvPicPr/>
                  </pic:nvPicPr>
                  <pic:blipFill>
                    <a:blip r:embed="rId${i}"/>
                    <a:stretch><a:fillRect/></a:stretch>
                  </pic:blipFill>
                  <pic:spPr>
                    <a:xfrm>
                      <a:off x="0" y="0"/>
                      <a:ext cx="${A4_EMU_W}" cy="${A4_EMU_H}"/>
                    </a:xfrm>
                    <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
                  </pic:spPr>
                </pic:pic>
              </a:graphicData>
            </a:graphic>
          </wp:inline>
        </w:drawing>
      </w:r>
    </w:p>`);
      if (i < pageCount) pages.push('<w:p><w:r><w:br w:type="page"/></w:r></w:p>');
    }
    return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
  <w:body>
    ${pages.join('\n')}
    <w:sectPr>
      <w:pgSz w:w="${A4_TWIP_W}" w:h="${A4_TWIP_H}"/>
      <w:pgMar w:top="0" w:right="0" w:bottom="0" w:left="0" w:header="0" w:footer="0" w:gutter="0"/>
    </w:sectPr>
  </w:body>
</w:document>`;
  }

  function relsXml(pageCount) {
    const rels = [];
    for (let i = 1; i <= pageCount; i++) rels.push(`<Relationship Id="rId${i}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/page-${i}.png"/>`);
    return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  ${rels.join('\n  ')}
</Relationships>`;
  }

  const CONTENT_TYPES = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="png" ContentType="image/png"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>`;

  const ROOT_RELS = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>`;

  // pngPages: Uint8Array[] (one full-page PNG each)
  function docxFromPngPages(pngPages) {
    if (!pngPages || !pngPages.length) throw new Error('No pages were rendered for Word export');
    const enc = new TextEncoder();
    const files = [
      { name: '[Content_Types].xml', data: enc.encode(CONTENT_TYPES) },
      { name: '_rels/.rels', data: enc.encode(ROOT_RELS) },
      { name: 'word/document.xml', data: enc.encode(documentXml(pngPages.length)) },
      { name: 'word/_rels/document.xml.rels', data: enc.encode(relsXml(pngPages.length)) },
    ];
    pngPages.forEach((png, i) => files.push({ name: `word/media/page-${i + 1}.png`, data: png }));
    return makeZip(files);
  }

  // pdfDoc: a pdf.js document. Every page is drawn at 2x of its 794 x 1123 px A4 size, as the old Word export did.
  async function pdfDocToDocx(pdfDoc) {
    const pages = [];
    for (let i = 1; i <= pdfDoc.numPages; i++) {
      const page = await pdfDoc.getPage(i);
      const base = page.getViewport({ scale: 1 });
      const vp = page.getViewport({ scale: (794 * 2) / base.width });
      const canvas = document.createElement('canvas');
      canvas.width = Math.round(vp.width); canvas.height = Math.round(vp.height);
      await page.render({ canvasContext: canvas.getContext('2d'), viewport: vp }).promise;
      const blob = await new Promise((resolve, reject) => canvas.toBlob(b => b ? resolve(b) : reject(new Error('Could not encode a page image')), 'image/png'));
      pages.push(new Uint8Array(await blob.arrayBuffer()));
      canvas.width = canvas.height = 0;   // release the bitmap right away on long documents
    }
    return docxFromPngPages(pages);
  }

  window.ACNHSRender = { renderPdf, pdfDocToDocx, docxFromPngPages, RenderError, state, isDevHost };
})();
