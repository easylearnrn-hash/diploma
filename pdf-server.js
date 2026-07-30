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

const fs = require('fs');
const os = require('os');
const path = require('path');
const http = require('http');
const { execFileSync } = require('child_process');
const { chromium } = require('playwright');

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

const A4_TWIP_W = '11906';
const A4_TWIP_H = '16838';
const A4_EMU_W = '7559060';
const A4_EMU_H = '10692130';
const SCREEN_A4_W = 794;
const SCREEN_A4_H = 1123;

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

function buildWordDocumentXml(pageCount) {
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

    if (i < pageCount) {
      pages.push('<w:p><w:r><w:br w:type="page"/></w:r></w:p>');
    }
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

function buildWordDocumentRelsXml(pageCount) {
  const rels = [];
  for (let i = 1; i <= pageCount; i++) {
    rels.push(`<Relationship Id="rId${i}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/page-${i}.png"/>`);
  }
  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  ${rels.join('\n  ')}
</Relationships>`;
}

function createDocxFromPngPages(pngPages) {
  if (!pngPages || pngPages.length === 0) {
    throw new Error('No pages were rendered for Word export');
  }

  const tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'acnhs-docx-'));
  const outDocx = path.join(os.tmpdir(), `acnhs-word-${Date.now()}-${Math.random().toString(36).slice(2)}.docx`);

  try {
    fs.mkdirSync(path.join(tmpRoot, '_rels'), { recursive: true });
    fs.mkdirSync(path.join(tmpRoot, 'word', '_rels'), { recursive: true });
    fs.mkdirSync(path.join(tmpRoot, 'word', 'media'), { recursive: true });

    const contentTypesXml = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="png" ContentType="image/png"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>`;

    const rootRelsXml = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>`;

    fs.writeFileSync(path.join(tmpRoot, '[Content_Types].xml'), contentTypesXml, 'utf8');
    fs.writeFileSync(path.join(tmpRoot, '_rels', '.rels'), rootRelsXml, 'utf8');
    fs.writeFileSync(path.join(tmpRoot, 'word', 'document.xml'), buildWordDocumentXml(pngPages.length), 'utf8');
    fs.writeFileSync(path.join(tmpRoot, 'word', '_rels', 'document.xml.rels'), buildWordDocumentRelsXml(pngPages.length), 'utf8');

    for (let i = 0; i < pngPages.length; i++) {
      fs.writeFileSync(path.join(tmpRoot, 'word', 'media', `page-${i + 1}.png`), pngPages[i]);
    }

    execFileSync('zip', ['-q', '-r', outDocx, '.'], { cwd: tmpRoot });
    return fs.readFileSync(outDocx);
  } finally {
    try { fs.rmSync(tmpRoot, { recursive: true, force: true }); } catch (_) {}
    try { fs.unlinkSync(outDocx); } catch (_) {}
  }
}

async function renderA4PngPages(html) {
  let browser;
  let context;
  try {
    browser = await chromium.launch({ headless: true });
    context = await browser.newContext({
      viewport: { width: SCREEN_A4_W, height: SCREEN_A4_H },
      deviceScaleFactor: 2,
    });
    const page = await context.newPage();

    await page.emulateMedia({ media: 'print' });
    await page.setContent(html, { waitUntil: 'networkidle', timeout: 30000 });
    await page.evaluateHandle('document.fonts.ready');

    const totalHeight = await page.evaluate(() =>
      Math.max(
        document.documentElement.scrollHeight,
        document.body ? document.body.scrollHeight : 0
      )
    );
    const pageCount = Math.max(1, Math.ceil(totalHeight / SCREEN_A4_H));

    const pages = [];
    for (let i = 0; i < pageCount; i++) {
      await page.evaluate(y => window.scrollTo(0, y), i * SCREEN_A4_H);
      await page.waitForTimeout(70);
      const png = await page.screenshot({ type: 'png' });
      pages.push(png);
    }

    return pages;
  } finally {
    if (context) await context.close().catch(() => {});
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

  let browser;
  try {
    if (isWordRoute) {
      const pngPages = await renderA4PngPages(html);
      const docxBuffer = createDocxFromPngPages(pngPages);

      res.writeHead(200, {
        'Content-Type': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'Content-Disposition': `attachment; filename="${safeFilename}"`,
        'Content-Length': String(docxBuffer.length),
      });
      res.end(docxBuffer);

      console.log(`[export-server] Generated Word: ${safeFilename} (${pngPages.length} pages)`);
      return;
    }

    browser = await chromium.launch({ headless: true });
    const page = await browser.newPage();

    // Load the self-contained print HTML; wait for all network resources (Google Fonts)
    await page.setContent(html, { waitUntil: 'networkidle', timeout: 30000 });

    // Wait for every web font (Noto, Playfair, Inter, EB Garamond) to be ready
    await page.evaluateHandle('document.fonts.ready');

    const pdfBuffer = await page.pdf({
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
  } finally {
    if (browser) await browser.close().catch(() => {});
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
