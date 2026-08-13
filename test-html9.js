const { chromium } = require('playwright');
const fs = require('fs');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  const html = fs.readFileSync('/tmp/print.html', 'utf8');
  await page.setContent(html);

  const res = await page.evaluate(() => {
    function visibleChildren(el) {
      if (!el) return [];
      return Array.from(el.children).filter(c => window.getComputedStyle(c).display !== 'none');
    }
    
    function isRow(children) {
      if (children.length < 2) return false;
      const parentCs = window.getComputedStyle(children[0].parentElement);
      if (/flex|grid/.test(parentCs.display)) return true;
      const top = children[0].getBoundingClientRect().top;
      return children.every(c => Math.abs(c.getBoundingClientRect().top - top) < 6);
    }
  
    function isSideBySide(children) {
      return isRow(children) && children.some(c => c.getBoundingClientRect().height >= 34);
    }

    const header = document.querySelector('.doc-header');
    if (!header) return { error: "No .doc-header found" };
    const kids = visibleChildren(header);
    
    if (isSideBySide(kids)) {
      return { msg: "Is side by side" };
    } else {
      return { msg: "IsNotSideBySide!" };
    }
  });
  console.log(res);
  await browser.close();
})();
