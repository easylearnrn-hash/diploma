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
  const docxBytes = await buildDocx(model, { refNo: "TEST-01" });
  
  const bufferStream = new stream.PassThrough();
  bufferStream.end(docxBytes);
  
  bufferStream.pipe(unzipper.Parse())
  .on('entry', function (entry) {
    const fileName = entry.path;
    if (fileName === 'word/header1.xml') {
      entry.buffer().then(content => {
        const text = content.toString('utf8');
        let lines = text.replace(/></g, '>\n<').split('\n');
        let inTable = false;
        let vAlign = [];
        for (const line of lines) {
           if (line.includes('<w:tbl>')) inTable = true;
           if (line.includes('</w:tbl>')) inTable = false;
           if (inTable && line.includes('vAlign')) vAlign.push(line);
        }
        console.log("vAligns:", vAlign);
      });
    } else {
      entry.autodrain();
    }
  });

  await browser.close();
})();
