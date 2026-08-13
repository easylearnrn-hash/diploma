const { chromium } = require('playwright');
const fs = require('fs');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  const html = fs.readFileSync('/tmp/print.html', 'utf8');
  await page.setContent(html);

  const res = await page.evaluate(() => {
    const parent = document.querySelector('.doc-header');
    return {
      className: parent.className,
      rect: parent.getBoundingClientRect(),
      display: window.getComputedStyle(parent).display,
    };
  });
  console.log(JSON.stringify(res, null, 2));
  await browser.close();
})();
