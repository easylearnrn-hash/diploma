const fs = require('fs');

const file = 'invoice.html';
let content = fs.readFileSync(file, 'utf8');

const oldRegex = /if \(unpaidInvoices\) \{\s*unpaidInvoices\.forEach\(inv => \{\s*let items = \[\];\s*try \{ items.*?catch\(e\)\{\}\s*items\.forEach\(item => \{\s*const desc = \(item\.description \|\| ''\)\.toLowerCase\(\);\s*if \(desc\.includes\('enrollment'\)\) \{\s*if \(\!unpaidMonths\.includes\('Enrollment Fee'\)\) unpaidMonths\.push\('Enrollment Fee'\);\s*\} else \{\s*const months = \['january','february','march','april','may','june','july','august','september','october','november','december'\];\s*months\.forEach\(m => \{\s*if \(desc\.includes\(m\)\) \{\s*const capM = m\.charAt\(0\)\.toUpperCase\(\) \+ m\.slice\(1\);\s*if \(\!unpaidMonths\.includes\(capM\)\) unpaidMonths\.push\(capM\);\s*\}\s*\}\);\s*\}\s*\}\);\s*\}\);\s*\}/s;

const newCode = `if (unpaidInvoices) {
            unpaidInvoices.forEach(inv => {
              const notes = inv.notes || '';
              const sections = notes.split('--- PARTIAL PAYMENT RECORDED ---');
              const paymentsByItem = {};
              sections.forEach((sec, i) => {
                if (i === 0 && !sec.includes('Date:')) return;
                const amtMatch = sec.match(/Amount:\\s*\\$?([\\d,]+\\.?\\d*)/);
                const appMatch = sec.match(/Applied To:\\s*(.+?)(?=\\n|$)/);
                if (amtMatch && appMatch) {
                  const amt = parseFloat(amtMatch[1].replace(/,/g, '')) || 0;
                  const descLower = appMatch[1].trim().toLowerCase();
                  paymentsByItem[descLower] = (paymentsByItem[descLower] || 0) + amt;
                }
              });

              let items = [];
              try { items = typeof inv.items === 'string' ? JSON.parse(inv.items) : (inv.items || []); } catch(e){}
              items.forEach(item => {
                const desc = (item.description || '').toLowerCase();
                const qty = item.qty || 1;
                const price = parseFloat(item.price) || 0;
                const disc = parseFloat(item.discount) || 0;
                const sub = qty * price;
                const requiredAmt = sub - (sub * disc / 100);
                const paidAmt = paymentsByItem[desc] || 0;
                
                if (paidAmt <= 0) {
                  if (desc.includes('enrollment')) {
                    if (!unpaidMonths.includes('Enrollment Fee')) unpaidMonths.push('Enrollment Fee');
                  } else {
                    const months = ['january','february','march','april','may','june','july','august','september','october','november','december'];
                    months.forEach(m => {
                      if (desc.includes(m)) {
                        const capM = m.charAt(0).toUpperCase() + m.slice(1);
                        if (!unpaidMonths.includes(capM)) unpaidMonths.push(capM);
                      }
                    });
                  }
                }
              });
            });
          }`;

if (oldRegex.test(content)) {
  content = content.replace(oldRegex, newCode);
  fs.writeFileSync(file, content);
  console.log("Replaced successfully in invoice.html");
} else {
  console.log("Regex did not match in invoice.html");
}
