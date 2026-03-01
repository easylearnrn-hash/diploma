const fs = require('fs');

function updateFile(file) {
  let content = fs.readFileSync(file, 'utf8');
  content = content.replace(/if \(paidAmt < requiredAmt - 0\.05\) \{/g, 'if (paidAmt <= 0) {'); // If they haven't paid anything towards it, glow red.
  fs.writeFileSync(file, content);
}

updateFile('admin-payments.html');
updateFile('invoice.html');

console.log('done');
