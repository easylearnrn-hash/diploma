const { chromium } = require('playwright');
const fs = require('fs');
const { extractDocModel, buildDocx } = require('./word-export.js');
const unzipper = require('unzipper');
const stream = require('stream');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ viewport: { width: 794, height: 1123 }, deviceScaleFactor: 1 });
  const page = await context.newPage();
  const html = fs.readFileSync('/tmp/print.html', 'utf8');
  await page.setContent(html);

  const model = await page.evaluate(extractDocModel);
  console.log("Model Header Blocks Table:", JSON.stringify(model.header[0], null, 2));
  
  await browser.close();
})();
