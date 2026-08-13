const { chromium } = require('playwright');
const fs = require('fs');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  const html = fs.readFileSync('/tmp/print.html', 'utf8');
  await page.setContent(html);

  const res = await page.evaluate(() => {
    function isRow(children) {
      if (children.length < 2) return false;
      const parent = children[0].parentElement;
      const display = window.getComputedStyle(parent).display;
      if (/flex|grid/.test(display)) return true;
      const top = children[0].getBoundingClientRect().top;
      return children.every(c => Math.abs(c.getBoundingClientRect().top - top) < 6);
    }

    const header = document.querySelector('.doc-header');
    const kids = Array.from(header.children).filter(c => window.getComputedStyle(c).display !== 'none');
    return isRow(kids);
  });
  console.log(res);
  await browser.close();
})();
