const { chromium } = require('playwright');
const fs = require('fs');
const { extractDocModel } = require('./word-export.js');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 794, height: 1123 }, deviceScaleFactor: 1 });
  const page = await context.newPage();
  const html = fs.readFileSync('/tmp/print.html', 'utf8');
  await page.setContent(html);

  const res = await page.evaluate(extractDocModel);
  console.log("Model Header Array Types:", res.header.map(h => h.t));
  await browser.close();
})();
