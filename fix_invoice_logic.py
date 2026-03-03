with open("invoice.html", "r") as f:
    content = f.read()

old = """                let paid = 0;
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
                };"""

new = """                let paid = 0;
                if (inv.status === 'paid') {
                  paid = total > 0 ? total : 1;
                } else if (inv.status === 'partial') {
                  partials.forEach(p => {
                    if (desc.includes(p.appliedTo) || p.appliedTo.includes(desc)) {
                      paid += p.amount;
                    }
                  });
                }

                let mStatus = 'unpaid';
                if (inv.status === 'paid') mStatus = 'paid';
                else if (paid >= total && total > 0) mStatus = 'paid';
                else if (paid > 0) mStatus = 'partial';

                const processKey = (k) => {
                  // Only allow status to worsen: paid → partial → unpaid
                  const current = monthStatuses[k];
                  const rank = { paid: 0, partial: 1, unpaid: 2 };
                  if (!current || rank[mStatus] > rank[current]) {
                    monthStatuses[k] = mStatus;
                  }
                  if (monthStatuses[k] !== 'paid') {
                    if (!unpaidMonths.includes(k)) unpaidMonths.push(k);
                  }
                };"""

# normalize whitespace for matching
import re
# Try direct replace first
if old in content:
    content = content.replace(old, new)
    print("Direct replacement succeeded.")
else:
    # Try normalizing - the file may have had different indentation saved
    # Find by known unique marker lines
    pattern = r"let paid = 0;\s+if \(inv\.status === 'paid'\) paid = total;\s+else if \(inv\.status === 'partial'\) \{.*?if \(!current.*?\}\s+\};"
    result = re.sub(pattern, new.strip(), content, flags=re.DOTALL, count=1)
    if result != content:
        content = result
        print("Regex replacement succeeded.")
    else:
        print("FAILED - could not match.")

with open("invoice.html", "w") as f:
    f.write(content)
