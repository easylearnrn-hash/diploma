const { chromium } = require('playwright');
const fs = require('fs');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  const html = fs.readFileSync('/tmp/print.html', 'utf8');
  await page.setContent(html);

  const res = await page.evaluate(() => {
    const leftHeader = document.querySelector('.doc-header-left');
    const children = Array.from(leftHeader.children);
    return children.map(c => ({
      text: c.textContent,
      display: window.getComputedStyle(c).display,
    }));
  });
  console.log(JSON.stringify(res, null, 2));
  await browser.close();
})();
