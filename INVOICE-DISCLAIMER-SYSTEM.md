# Invoice System with Mandatory Disclaimer - Complete Setup

## Overview
Each generated invoice now has:
1. **Unique invoice URL** - `invoice-view.html?id={uuid}`
2. **Mandatory non-refundable disclaimer** - Displayed prominently before invoice
3. **Printable dedicated page** - Professional layout with disclaimer included in footer
4. **Shareable links** - Send unique invoice URLs to students via email/SMS

## Files Created

### 1. `invoice-view.html`
**Purpose:** Dedicated page for viewing individual invoices with mandatory disclaimer

**Features:**
- Displays full non-refundable tuition payment disclaimer
- Shows complete invoice details from database
- Print-ready layout with disclaimer in footer
- Professional styling matching college branding
- Loads invoice by UUID from URL parameter

**Access:** `http://localhost:8000/invoice-view.html?id={invoice-uuid}`

### 2. Updated `invoice.html`
**Changes:**
- Auto-saves invoice to database on print
- Returns invoice UUID after save
- Shows success notification with unique invoice URL
- Added "View Invoice" button in All Invoices modal
- Copy link functionality for easy sharing

### 3. Updated `.gitignore`
**Added:** `invoice-view.html` to prevent deployment (local-only file)

## Mandatory Disclaimer Content

### What's Included
The disclaimer covers ALL scenarios where students might request refunds:

✅ **Academic reasons:**
- Exam failures
- Dismissal or suspension
- Academic probation

✅ **Personal decisions:**
- Voluntary withdrawal
- Decision not to continue
- Transfer to other programs

✅ **Life circumstances:**
- Medical reasons
- Family emergencies
- Financial hardship
- Immigration issues

✅ **Attendance:**
- Class absences
- Clinical session misses
- Schedule conflicts

✅ **Licensure:**
- Denial of certification
- Exam ineligibility
- Board rejections

✅ **Program progress:**
- Repetition of coursework
- Extended graduation timeline
- Non-completion

### Legal Protection
The disclaimer includes:
- **"All tuition payments are final and non-refundable"** - Clear, absolute statement
- **Comprehensive list of non-refund scenarios** - Covers every possible situation
- **Acknowledgment of acceptance** - "Submission of payment constitutes full acceptance"
- **Universal application** - "Regardless of payment method, date, or amount"

### Display Locations
1. **Before invoice (invoice-view.html):**
   - Large warning box at top of page
   - Red color scheme for visibility
   - ⚠️ icon for immediate attention
   - Cannot be missed before viewing invoice

2. **In invoice footer:**
   - "All tuition payments are final and non-refundable under any circumstances"
   - Printed on every invoice
   - Part of official invoice document

## Workflow

### Creating Invoice with Unique URL

1. **Fill out invoice in editor** (`invoice.html`)
2. **Click "🖨️ Print / Save PDF"**
3. **System automatically:**
   - Saves invoice to `invoices` table in Supabase
   - Generates unique UUID for invoice
   - Creates unique URL: `invoice-view.html?id={uuid}`
   - Shows success notification with buttons:
     - "View Invoice" - Opens dedicated invoice page
     - "Copy Link" - Copies URL to clipboard

4. **Share the link:**
   - Send URL to student via email
   - Add to SMS notifications
   - Include in acceptance letters
   - Share via admin portal

### Student Experience

1. **Receives unique invoice URL**
2. **Opens link in browser:**
   - Sees large disclaimer at top
   - Reads non-refundable payment policy
   - Scrolls down to see invoice details
3. **Can print invoice:**
   - Disclaimer included in footer
   - Professional layout
   - All payment instructions visible
4. **Makes payment:**
   - By submitting payment, accepts disclaimer policy

### Admin Management

#### View All Invoices
1. Click "📋 All Invoices" in invoice editor
2. Search by student name or invoice number
3. Filter by status (unpaid/paid/overdue/cancelled)
4. For each invoice:
   - **🔗 View Invoice** - Opens dedicated page in new tab
   - **Load** - Loads into editor for modifications
   - **Mark Paid** - Updates status when payment received
   - **Delete** - Removes invoice permanently

## Database Schema

### `invoices` Table
All invoices stored with:
- `id` - UUID (used in invoice URLs)
- `invoice_number` - Human-readable number (ACNHS-YYYYMMDD-HHMM-RRR)
- `student_name`, `student_id`, `program`
- `invoice_date`, `due_date`
- `payment_method`, `notes`
- `items` - JSONB array of line items
- `subtotal`, `tax_rate`, `tax_amount`, `total`
- `status` - unpaid/paid/overdue/cancelled
- `created_at`, `updated_at`

## Security & Privacy

### Local-Only Access
Both `invoice.html` and `invoice-view.html` are excluded from git repository:
- Won't be deployed to public website
- Only accessible via localhost:8000
- Students access via unique UUID links only

### RLS Policies
Supabase Row Level Security allows:
- Anonymous users can read invoices (needed for invoice-view.html)
- Only admins can modify invoice status
- UUID makes invoices impossible to guess
- No sequential IDs exposed

## Legal Compliance

### Non-Refundable Policy Enforcement

**Before Payment:**
- Disclaimer displayed prominently
- Cannot be bypassed or skipped
- Clear, unambiguous language
- Comprehensive coverage of scenarios

**During Payment:**
- Invoice includes disclaimer in footer
- Payment instructions reference policy
- Student must acknowledge by paying

**After Payment:**
- Invoice URL remains accessible
- Disclaimer permanently visible
- Proof of disclosure maintained

### Chargeback Protection
The disclaimer protects against:
- Credit card chargebacks - "I didn't know it was non-refundable"
- Bank disputes - "I changed my mind"
- Legal claims - "This wasn't disclosed"

Evidence you can provide:
1. **Invoice URL** with timestamp showing disclaimer
2. **Printed invoice** with disclaimer in footer
3. **Database record** showing invoice was sent
4. **Acceptance acknowledgment** - "Submission of payment constitutes full acceptance"

## Usage Examples

### Example 1: Email Invoice to Student
```
Subject: ACNHS Invoice - Tuition Payment

Dear [Student Name],

Please review your invoice for the Practical Nursing program:

Invoice URL: http://localhost:8000/invoice-view.html?id=abc123-def456-ghi789

This invoice includes our non-refundable tuition payment policy. 
Please read the disclaimer carefully before submitting payment.

Payment Instructions:
[ARNOMA bank details from invoice]

Thank you,
ACNHS Admissions
```

### Example 2: Include in Acceptance Letter
After student is accepted, generate invoice and include URL:
```
Congratulations! You've been accepted to ACNHS.

Next Steps:
1. Review your tuition invoice: [invoice URL]
2. Read the non-refundable payment policy
3. Submit payment by [due date]
4. Attend orientation on [date]
```

### Example 3: Payment Reminder SMS
```
ACNHS: Payment due [date]. View invoice: [short URL]. 
All payments non-refundable. Questions? Call [phone].
```

## Testing Checklist

### Before Going Live
- [ ] Run `CREATE-INVOICES-TABLE.sql` in Supabase
- [ ] Generate test invoice in `invoice.html`
- [ ] Click Print/Save PDF
- [ ] Verify success notification appears
- [ ] Click "View Invoice" button
- [ ] Confirm `invoice-view.html` opens in new tab
- [ ] Verify disclaimer displays at top
- [ ] Check invoice details load correctly
- [ ] Test Print button (Ctrl/Cmd + P)
- [ ] Confirm disclaimer appears in print preview footer
- [ ] Click "Copy Link" and paste in new tab
- [ ] Verify invoice loads from copied URL
- [ ] Test on mobile device (responsive layout)
- [ ] Check all invoice card buttons work
- [ ] Verify "Mark Paid" updates status
- [ ] Test invoice search and filtering

## Troubleshooting

### "Invoice not found" error
**Cause:** Invoice ID in URL doesn't exist in database
**Fix:** 
1. Check URL has valid UUID
2. Run: `SELECT id FROM invoices;` in Supabase
3. Verify invoice was saved (check console logs)

### Disclaimer not showing
**Cause:** CSS not loading or JavaScript error
**Fix:**
1. Open browser console (F12)
2. Check for JavaScript errors
3. Verify Supabase connection
4. Clear browser cache

### Invoice URL not generating
**Cause:** Database save failed
**Fix:**
1. Check Supabase connection in invoice.html
2. Verify `CREATE-INVOICES-TABLE.sql` was run
3. Check browser console for errors
4. Ensure invoice has required fields (student name, invoice number)

### Disclaimer not printing
**Cause:** Print CSS hiding disclaimer
**Fix:**
- Disclaimer is intentionally hidden from print in invoice-view.html
- Footer includes disclaimer statement on printed invoice
- This is correct behavior - full disclaimer only on screen

## Production Deployment Notes

### DO NOT Deploy These Files:
- `invoice.html` - Admin tool, local only
- `invoice-view.html` - Contains database access, local only

### What Students Should Receive:
- Unique invoice URLs sent via email/SMS
- URLs point to local server (for development)
- In production, host `invoice-view.html` on secure subdomain

### Production Considerations:
1. **Hosting:** Deploy invoice-view.html to `invoices.acnhs.am` subdomain
2. **Authentication:** Add password protection or token-based access
3. **RLS:** Lock down Supabase policies to authenticated users only
4. **SSL:** Ensure HTTPS for secure invoice access
5. **Logging:** Track who views invoices and when
6. **Expiration:** Consider adding invoice expiration dates

## Future Enhancements

### Possible Additions:
- [ ] Email invoice links automatically after generation
- [ ] SMS notifications with invoice URLs
- [ ] Payment tracking integration
- [ ] Digital signature for disclaimer acceptance
- [ ] PDF generation server-side
- [ ] Invoice expiration after due date
- [ ] Payment receipt generation
- [ ] Multi-language disclaimer support
- [ ] Invoice amendment/correction workflow
- [ ] Bulk invoice generation for cohorts

## Support

### Common Questions

**Q: Can students edit the invoice?**
A: No, invoice-view.html is read-only. Only admins can edit via invoice.html.

**Q: What if student claims they didn't see disclaimer?**
A: Every invoice URL displays disclaimer prominently at top. It's impossible to miss. Plus footer statement on printed invoice.

**Q: Can invoice URL expire?**
A: Not currently, but can be added. Invoice remains accessible indefinitely.

**Q: What if we need to correct an invoice?**
A: Load invoice in editor, make changes, print again. Updates existing invoice, same URL.

**Q: Can we revoke access to an invoice?**
A: Delete invoice from database. URL will show "Invoice not found" error.

**Q: Is the disclaimer legally binding?**
A: Consult your legal counsel. This wording is based on common institutional policies but should be reviewed by your attorney.
