const inv1 = {
  status: 'partial',
  notes: '--- PARTIAL PAYMENT RECORDED ---\nDate: 2026-03-01\nAmount: $500\nApplied To: March\n--- PARTIAL PAYMENT RECORDED ---\nDate: 2026-03-02\nAmount: $200\nApplied To: March',
  items: JSON.stringify([{ description: 'March Tuition', qty: 1, unit_price: 1500, discount: 0 }])
};

const allInvoices = [inv1];
let monthStatuses = {};
let unpaidMonths = [];

allInvoices.forEach(inv => {
  let partials = [];
  if (inv.notes) {
    const sections = inv.notes.split('--- PARTIAL PAYMENT RECORDED ---');
    sections.forEach((sec, i) => {
      if (i === 0 && !sec.includes('Date:')) return;
      const amtMatch = sec.match(/Amount:\s*\$?([\d,]+\.?\d*)/);
      const appMatch = sec.match(/Applied To:\s*(.+?)(?=\n|$)/);
      // Let's add logging here
      if (amtMatch && appMatch) {
         console.log("matched:", amtMatch[1], appMatch[1].trim().toLowerCase());
         partials.push({ amount: parseFloat(amtMatch[1].replace(/,/g, '')) || 0, appliedTo: appMatch[1].trim().toLowerCase() });
      }
    });
  }

  let items = typeof inv.items === 'string' ? JSON.parse(inv.items) : (inv.items || []);
  items.forEach(item => {
    const desc = (item.description || '').toLowerCase();
    if (!desc) return;

    const qty = Number(item.qty || 1);
    const price = parseFloat(String(item.unit_price).replace(/,/g, '')) || 0;
    const disc = parseFloat(String(item.discount).replace(/,/g, '')) || 0;
    const sub = qty * price;
    const total = sub - (sub * (disc / 100));

    let paid = 0;
    if (inv.status === 'paid') paid = total;
    else if (inv.status === 'partial') {
      partials.forEach(p => {
        if (desc.includes(p.appliedTo) || p.appliedTo.includes(desc)) {
          paid += p.amount;
        }
      });
    }

    let mStatus = 'unpaid';
    if (paid >= total && total > 0) mStatus = 'paid';
    else if (paid > 0 && paid < total) mStatus = 'partial';
    else if (inv.status === 'paid') mStatus = 'paid';

    const processKey = (k) => { 
      const current = monthStatuses[k];
      if (!current || (mStatus !== 'paid' && current === 'paid') || (mStatus === 'unpaid' && current === 'partial')) {
        monthStatuses[k] = mStatus; 
      }
      if (mStatus !== 'paid') {
        if (!unpaidMonths.includes(k)) unpaidMonths.push(k);
      }
    };

    if (desc.includes('enrollment')) {
      processKey('Enrollment Fee');
    } else {
      const months = ['january','february','march','april','may','june','july','august','september','october','november','december'];
      months.forEach(m => {
        if (desc.includes(m)) {
          processKey(m.charAt(0).toUpperCase() + m.slice(1));
        }
      });
    }
  });
});

console.log(monthStatuses);
