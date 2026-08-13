'use strict';

/**
 * ACNHS Export Server - Playwright-based
 * Port: 8001
 *
 * Start:
 *   node pdf-server.js
 *
 * First-time browser install (run once after npm install):
 *   npx playwright install chromium
 *
 * Then open http://localhost:8000/documents.html and use PDF / Word export.
 */

const http = require('http');
const { chromium } = require('playwright');
const { extractDocModel, buildDocx } = require('./word-export');

const PORT = 8001;
const ORIGIN = 'http://localhost:8000';
const MAX_BYTES = 12 * 1024 * 1024; // 12 MB body limit

function resolveAllowedOrigin(requestOrigin) {
  if (!requestOrigin) return ORIGIN;
  if (requestOrigin === 'null') return 'null'; // file:// pages
  if (/^https?:\/\/localhost(?::\d+)?$/i.test(requestOrigin)) return requestOrigin;
  if (/^https?:\/\/127\.0\.0\.1(?::\d+)?$/i.test(requestOrigin)) return requestOrigin;
  return ORIGIN;
}

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

function sanitizeFilename(name, fallback, ext) {
  const base = String(name || fallback)
    .replace(/\.[a-zA-Z0-9]+$/, '')
    .replace(/[^a-zA-Z0-9._-]/g, '_') || fallback;
  return `${base}.${ext}`;
}

// Single source of truth for page layout: PDF and Word both come from this.
async function renderPdfBuffer(html, safeRef) {
  let browser;
  try {
    browser = await chromium.launch({ headless: true });
    const page = await browser.newPage();

    // Load the self-contained print HTML; wait for all network resources (Google Fonts)
    await page.setContent(html, { waitUntil: 'networkidle', timeout: 30000 });

    // Wait for every web font (Noto, Playfair, Inter, EB Garamond) to be ready
    await page.evaluateHandle('document.fonts.ready');

    return await page.pdf({
      format: 'A4',
      printBackground: true,
      preferCSSPageSize: false,
      displayHeaderFooter: true,
      margin: {
        top: '0',
        bottom: '22mm',
        left: '0',
        right: '0',
      },
      headerTemplate: '<div></div>',
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
  } finally {
    if (browser) await browser.close().catch(() => {});
  }
}

// Build an editable .docx from the same print HTML that drives the PDF.
async function renderDocx(html, refNo) {
  let browser;
  try {
    browser = await chromium.launch({ headless: true });
    const context = await browser.newContext({ viewport: { width: 794, height: 1123 }, deviceScaleFactor: 1 });
    const page = await context.newPage();

    await page.setContent(html, { waitUntil: 'networkidle', timeout: 30000 });
    await page.evaluateHandle('document.fonts.ready');

    const model = await page.evaluate(extractDocModel);
    return await buildDocx(model, { refNo });
  } finally {
    if (browser) await browser.close().catch(() => {});
  }
}

// ── HTTP server ──────────────────────────────────────────────────────────────
const server = http.createServer(async (req, res) => {

  // CORS — allow local hosts and file:// pages (Origin: null)
  res.setHeader('Access-Control-Allow-Origin', resolveAllowedOrigin(req.headers.origin));
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    return res.end();
  }

  const isPdfRoute = req.url === '/generate-pdf';
  const isWordRoute = req.url === '/generate-word';

  if (req.method !== 'POST' || (!isPdfRoute && !isWordRoute)) {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ error: 'Not found' }));
  }

  // ── Parse body ──
  let html, filename, refNo;
  try {
    const raw = await readBody(req);
    ({ html, filename = isWordRoute ? 'document.docx' : 'document.pdf', refNo = '' } = JSON.parse(raw));
  } catch (e) {
    res.writeHead(400, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ error: e.message || 'Invalid request' }));
  }

  if (!html || typeof html !== 'string') {
    res.writeHead(400, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ error: 'html field is required' }));
  }

  const safeFilename = isWordRoute
    ? sanitizeFilename(filename, 'document', 'docx')
    : sanitizeFilename(filename, 'document', 'pdf');

  // Sanitize refNo for HTML embedding inside the footer template
  const safeRef = String(refNo || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');

  try {
    if (isWordRoute) {
      const docxBuffer = await renderDocx(html, refNo || '');

      res.writeHead(200, {
        'Content-Type': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'Content-Disposition': `attachment; filename="${safeFilename}"`,
        'Content-Length': String(docxBuffer.length),
      });
      res.end(docxBuffer);

      console.log(`[export-server] Generated Word: ${safeFilename} (${(docxBuffer.length / 1024).toFixed(1)} KB)`);
      return;
    }

    const pdfBuffer = await renderPdfBuffer(html, safeRef);

    res.writeHead(200, {
      'Content-Type': 'application/pdf',
      'Content-Disposition': `attachment; filename="${safeFilename}"`,
      'Content-Length': String(pdfBuffer.length),
    });
    res.end(pdfBuffer);

    console.log(`[export-server] Generated PDF: ${safeFilename} (${(pdfBuffer.length / 1024).toFixed(1)} KB)`);
  } catch (err) {
    console.error('[pdf-server] Error:', err.message);
    if (!res.headersSent) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: err.message }));
    }
  }
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`
  ╔══════════════════════════════════════════════════════╗
  ║       ACNHS Export Server - http://127.0.0.1:${PORT}      ║
  ╚══════════════════════════════════════════════════════╝

  Open http://localhost:8000/documents.html
  Fill in the form, then click "Print / Save PDF" or "Export to Word".
  Press Ctrl+C to stop.
`);
});
