const { chromium } = require('playwright');
const fs = require('fs');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  const html = fs.readFileSync('/tmp/print.html', 'utf8');
  await page.setContent(html);

  const res = await page.evaluate(() => {
    const headerEl = document.querySelector('.doc-header');
    return {
      childrenHeights: Array.from(headerEl.children).map(c => c.getBoundingClientRect().height),
      isSideBySide: Array.from(headerEl.children).some(c => c.getBoundingClientRect().height >= 34)
    }
  });
  console.log(res);
  await browser.close();
})();
