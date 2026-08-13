const { chromium } = require('playwright');
const fs = require('fs');
const { extractDocModel, buildDocx } = require('./word-export.js');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 794, height: 1123 }, deviceScaleFactor: 1 });
  const page = await context.newPage();
  const html = fs.readFileSync('/tmp/print.html', 'utf8');
  await page.setContent(html);

  const model = await page.evaluate(extractDocModel);
  const docxBytes = await buildDocx(model, { refNo: "TEST-01" });
  fs.writeFileSync('output.docx', docxBytes);
  console.log("Wrote to output.docx, size:", docxBytes.length);
  await browser.close();
})();
