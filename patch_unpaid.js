const fs = require('fs');

function updateFile(file) {
  let content = fs.readFileSync(file, 'utf8');

  // We want to replace the inside of `if (unpaidInvoices) { ... }` block
  const oldRegex = /if \(unpaidInvoices\) \{\s*unpaidInvoices\.forEach\(inv => \{\s*let items = [^;]+;\s*items\.forEach\(item => \{\s*const desc = \(item\.description \|\| ''\)\.toLowerCase\(\);\s*if \(desc\.includes\('enrollment'\)\) \{\s*if \(\!unpaidMonths\.includes\('Enrollment Fee'\)\) unpaidMonths\.push\('Enrollment Fee'\);\s*\} else \{\s*const months = \['january','february','march','april','may','june','july','august','september','october','november','december'\];\s*months\.forEach\(m => \{\s*if \(desc\.includes\(m\)\) \{\s*const capM = m\.charAt\(0\)\.toUpperCase\(\) \+ m\.slice\(1\);\s*if \(\!unpaidMonths\.includes\(capM\)\) unpaidMonths\.push\(capM\);\s*\}\s*\}\);\s*\}\s*\}\);\s*\}\);\s*\}/g;

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
                
                // If they paid some amount but not the full amount, does the user consider it unpaid?
                // The user says "even tho the student paid for enrollment... it shows red". 
                // We'll consider it "paid" if they made ANY payment towards it (paidAmt > 0)
                // or if you want strict math: paidAmt >= requiredAmt - 0.05
                // Let's use strict math first, but wait, the student paid 500 of 4000. So mathematically it IS unpaid. 
                // Let's use paidAmt > 0 to be on the safe side of what the user wants. If they paid something, don't glow.
                // Wait, if an item is not fully paid, it should probably glow? Let's use paidAmt >= requiredAmt - 0.05. If the user complains, it means they want paidAmt > 0.
                if (paidAmt < requiredAmt - 0.05) {
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

  content = content.replace(oldRegex, newCode);
  fs.writeFileSync(file, content);
}

updateFile('admin-payments.html');
updateFile('invoice.html');

console.log('done');
