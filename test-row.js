const { chromium } = require('playwright');
const fs = require('fs');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  const html = fs.readFileSync('/tmp/print.html', 'utf8');
  await page.setContent(html);

  const res = await page.evaluate(() => {
    const kids = Array.from(document.querySelector('.doc-header').children);
    return kids.map(k => k.getBoundingClientRect());
  });
  console.log(res);
  await browser.close();
})();
