const fs = require('fs');
const html = fs.readFileSync('test.html', 'utf8');

const idRegex = /id=\"([^\"]+)\"/g;
let ids = new Set();
let match;
while ((match = idRegex.exec(html)) !== null) ids.add(match[1]);

// Some dynamically generated IDs are fine (e.g., option_...)
const getElementRegex = /getElementById\(['"]([^'\"]+)['"]\)/g;
let missing = new Set();
while ((match = getElementRegex.exec(html)) !== null) {
  if (!ids.has(match[1]) && !match[1].includes('$') && !match[1].startsWith('sidebar-') && !match[1].includes('_')) {
    missing.add(match[1]);
  }
}

console.log('Missing IDs:', [...missing]);
