const notes = `***PAYMENT INSTRUCTIONS***
--- PARTIAL PAYMENT RECORDED ---
Date: 2/28/2026
Amount: $500.00
Applied To: Enrollment Down Payment (Non-Refundable)

--- PARTIAL PAYMENT RECORDED ---
Date: 2/28/2026
Amount: $2,000.00
Applied To: February Tuition – Bachelor of Science in Nursing
`;

const sections = notes.split('--- PARTIAL PAYMENT RECORDED ---');
const paymentsByItem = {};
sections.forEach((sec, i) => {
  if (i === 0 && !sec.includes('Date:')) return;
  const amtMatch = sec.match(/Amount:\s*\$?([\d,]+\.?\d*)/);
  const appMatch = sec.match(/Applied To:\s*(.+?)(?=\n|$)/);
  if (amtMatch && appMatch) {
    const amt = parseFloat(amtMatch[1].replace(/,/g, '')) || 0;
    const desc = appMatch[1].trim();
    paymentsByItem[desc] = (paymentsByItem[desc] || 0) + amt;
  }
});
console.log(paymentsByItem);

const desc1 = "Enrollment Down Payment (Non-Refundable)".toLowerCase();
const paymentsByItemLower = Object.fromEntries(Object.entries(paymentsByItem).map(([k, v]) => [k.toLowerCase(), v]));
console.log(paymentsByItemLower[desc1]);
