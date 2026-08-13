const { chromium } = require('playwright');
const fs = require('fs');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  const html = fs.readFileSync('/tmp/print.html', 'utf8');
  await page.setContent(html);

  const res = await page.evaluate(() => {
    const leftHeader = document.querySelector('.doc-header-left');
    const cs = window.getComputedStyle(leftHeader);
    return {
      textAlign: cs.textAlign,
      display: cs.display
    };
  });
  console.log(res);
  await browser.close();
})();
