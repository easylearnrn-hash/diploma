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
  
  let headerContent = "";
  bufferStream.pipe(unzipper.Parse())
  .on('entry', function (entry) {
    const fileName = entry.path;
    if (fileName === 'word/header1.xml') {
      entry.buffer().then(content => {
        headerContent = content.toString('utf8');
        console.log("Does it contain <w:tbl>?", headerContent.includes('<w:tbl>'));
        console.log("-- TABLE SNIPPET --");
        if (headerContent.includes('<w:tbl>')) {
           let rows = headerContent.split('<w:tr>');
           console.log("Number of <w:tr> tags:", rows.length - 1);
        }
      });
    } else {
      entry.autodrain();
    }
  });

  await browser.close();
})();
