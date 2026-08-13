const { chromium } = require('playwright');
const fs = require('fs');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  const html = `
    <html><head><style>
      body { font-family: sans-serif; margin: 0; padding: 0; }
      .frame { position: fixed; top: -14mm; left: -14mm; right: -14mm; bottom: -14mm; border: 2px solid red; }
      p { margin-bottom: 200px; }
    </style></head><body>
      <div class="frame"></div>
      <h1>Page 1</h1><p>Test</p><p>Test</p><p>Test</p><p>Test</p><p>Test</p><p>Test</p>
    </body></html>
  `;
  await page.setContent(html);
  await page.pdf({ 
    path: 'test.pdf', format: 'A4', printBackground: true,
    margin: { top: '24mm', bottom: '28mm', left: '20mm', right: '20mm' },
    displayHeaderFooter: true,
    footerTemplate: '<div style="font-size: 10px; width:100%; text-align:center;">Footer <span class="pageNumber"></span></div>'
  });
  await browser.close();
  console.log('done');
})();
