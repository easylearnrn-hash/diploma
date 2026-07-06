'use strict';

/**
 * ACNHS PDF Server — Playwright-based
 * Port: 8001
 *
 * Start:
 *   node pdf-server.js
 *
 * First-time browser install (run once after npm install):
 *   npx playwright install chromium
 *
 * Then open http://localhost:8000/documents.html and click "Print / Save PDF".
 */

const http    = require('http');
const { chromium } = require('playwright');

const PORT      = 8001;
const ORIGIN    = 'http://localhost:8000';
const MAX_BYTES = 12 * 1024 * 1024; // 12 MB body limit

// ── Read request body as string ──────────────────────────────────────────────
function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    let size = 0;
    req.on('data', chunk => {
      size += chunk.length;
      if (size > MAX_BYTES) {
        req.destroy();
        return reject(new Error('Request body too large'));
      }
      data += chunk;
    });
    req.on('end',   () => resolve(data));
    req.on('error', reject);
  });
}

// ── HTTP server ──────────────────────────────────────────────────────────────
const server = http.createServer(async (req, res) => {

  // CORS — only allow the local static file server
  res.setHeader('Access-Control-Allow-Origin',  ORIGIN);
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    return res.end();
  }

  if (req.method !== 'POST' || req.url !== '/generate-pdf') {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ error: 'Not found' }));
  }

  // ── Parse body ──
  let html, filename, refNo;
  try {
    const raw = await readBody(req);
    ({ html, filename = 'document.pdf', refNo = '' } = JSON.parse(raw));
  } catch (e) {
    res.writeHead(400, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ error: e.message || 'Invalid request' }));
  }

  if (!html || typeof html !== 'string') {
    res.writeHead(400, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ error: 'html field is required' }));
  }

  // Sanitize filename for Content-Disposition header
  const safeFilename = String(filename || 'document.pdf')
    .replace(/[^a-zA-Z0-9._-]/g, '_') || 'document.pdf';

  // Sanitize refNo for HTML embedding inside the footer template
  const safeRef = String(refNo || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');

  let browser;
  try {
    browser = await chromium.launch({ headless: true });
    const page = await browser.newPage();

    // Load the self-contained print HTML; wait for all network resources (Google Fonts)
    await page.setContent(html, { waitUntil: 'networkidle', timeout: 30000 });

    // Wait for every web font (Noto, Playfair, Inter, EB Garamond) to be ready
    await page.evaluateHandle('document.fonts.ready');

    const pdfBuffer = await page.pdf({
      format:              'A4',
      printBackground:     true,   // render background colours, images, and the crosshatch
      preferCSSPageSize:   false,  // use format: 'A4' explicitly
      displayHeaderFooter: true,
      margin: {
        top:    '0',       // top spacing handled by page-content padding inside print HTML
        bottom: '22mm',    // reserved footer band (separate from body area)
        left:   '0',
        right:  '0',
      },
      // Blank header — the document letterhead is part of the HTML body
      headerTemplate: '<div></div>',
      // Footer band: appears in the reserved 22 mm bottom margin on every page
      footerTemplate: `
        <div style="
          font-size: 8px;
          width: 100%;
          text-align: center;
          font-family: Arial, Helvetica, sans-serif;
          color: rgba(10,15,30,0.52);
          padding: 5mm 0 0 0;
          margin: 0;
          box-sizing: border-box;
          line-height: 1.2;
          white-space: nowrap;
        ">
          <strong style="color:rgba(10,15,30,0.62);">www.acnhs.am</strong>
          &nbsp;&bull;&nbsp;
          info@acnhs.am
          &nbsp;&bull;&nbsp;
          Ref:&nbsp;${safeRef}
          &nbsp;&bull;&nbsp;
          Page&nbsp;<span class="pageNumber"></span>&nbsp;of&nbsp;<span class="totalPages"></span>
        </div>`,
    });

    res.writeHead(200, {
      'Content-Type':        'application/pdf',
      'Content-Disposition': `attachment; filename="${safeFilename}"`,
      'Content-Length':      String(pdfBuffer.length),
    });
    res.end(pdfBuffer);

    console.log(`[pdf-server] Generated: ${safeFilename} (${(pdfBuffer.length / 1024).toFixed(1)} KB)`);

  } catch (err) {
    console.error('[pdf-server] Error:', err.message);
    if (!res.headersSent) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: err.message }));
    }
  } finally {
    if (browser) await browser.close().catch(() => {});
  }
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`
  ╔══════════════════════════════════════════════════════╗
  ║         ACNHS PDF Server — http://127.0.0.1:${PORT}       ║
  ╚══════════════════════════════════════════════════════╝

  Open http://localhost:8000/documents.html
  Fill in the form, then click "Print / Save PDF".
  Press Ctrl+C to stop.
`);
});
