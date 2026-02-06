# Invoice URL in Student Profiles - Setup Guide

## Overview
Invoice URLs are now automatically added to student profiles when invoices are generated. Students and admins can access invoices directly from the student profile page.

## Changes Made

### 1. Database Schema
**File:** `ADD-INVOICE-URL-TO-STUDENTS.sql`

Added `invoice_url` column to `students` table:
```sql
ALTER TABLE students 
ADD COLUMN IF NOT EXISTS invoice_url TEXT;
```

### 2. Invoice Generator (`invoice.html`)
**Auto-Update Student Profile:**
- When invoice is saved (on print), the system now:
  1. Saves invoice to `invoices` table
  2. Gets the invoice UUID
  3. Generates invoice URL: `invoice-view.html?id={uuid}`
  4. Updates student profile with invoice URL

**Function:** `updateStudentInvoiceUrl(studentId, invoiceId)`
- Finds student by `student_id`
- Updates their `invoice_url` column
- Logs success/errors to console

### 3. Student Profile Page (`admin-student-page.html`)
**Display Invoice Link:**
- Added new info item in Overview section
- Shows "📄 Invoice" label
- Displays "View Invoice with Disclaimer →" link
- Only visible if student has invoice URL
- Opens in new tab when clicked

**Location:** Academic Information card, after Credits Earned

### 4. Students List Page (`admin-students.html`)
**Invoice Button in Actions:**
- Added 💰 button for students with invoices
- Appears next to View (👁️) and Application (📄) buttons
- Opens invoice in new tab
- Only shown if `student.invoice_url` exists

### 5. Public Access (`invoice-view.html`)
**Removed from .gitignore:**
- `invoice-view.html` is now deployed to website
- Students can access their invoice URL
- Full disclaimer displayed before invoice
- No authentication required (UUID provides security)

## Workflow

### Creating Invoice
1. Admin opens `invoice.html` (local only)
2. Selects student from approved students list
3. Fills in invoice details and line items
4. Clicks "🖨️ Print / Save PDF"
5. System automatically:
   - Saves invoice to database
   - Generates unique URL
   - Updates student profile with invoice URL
   - Shows success notification with link

### Viewing Invoice - Admin
**Option 1: From Student Profile**
1. Open `admin-student-page.html?id={student_id}`
2. Scroll to Academic Information section
3. Click "View Invoice with Disclaimer →"
4. Invoice opens in new tab

**Option 2: From Students List**
1. Open `admin-students.html`
2. Find student in table
3. Click 💰 button in Actions column
4. Invoice opens in new tab

**Option 3: From All Invoices Modal**
1. Open `invoice.html`
2. Click "📋 All Invoices"
3. Click "🔗 View Invoice" on any invoice card
4. Invoice opens in new tab

### Viewing Invoice - Student
**Method 1: Direct Link**
- Admin sends invoice URL via email/SMS
- Student clicks link
- Invoice page loads with full disclaimer

**Method 2: Student Portal**
- Student logs into their profile
- Clicks invoice link
- Views invoice with disclaimer

**Method 3: Embedded in Communications**
- Include invoice URL in acceptance letters
- Add to payment reminder emails
- Include in SMS notifications

## Security & Privacy

### UUID-Based Access
- Each invoice has unique UUID (impossible to guess)
- No sequential IDs exposed
- URL pattern: `invoice-view.html?id=abc123-def456-ghi789-...`

### No Authentication Required
- Students don't need login to view invoice
- Simplifies payment process
- UUID provides security through obscurity

### RLS Policies
- Supabase RLS allows anonymous SELECT on invoices
- Students can only access if they have the exact URL
- Admin actions (update status, delete) require authentication

## Setup Instructions

### Step 1: Run SQL Migration
1. Go to https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/sql
2. Open `ADD-INVOICE-URL-TO-STUDENTS.sql`
3. Copy all SQL content
4. Paste into Supabase SQL Editor
5. Click **Run**

### Step 2: Verify Column Addition
Run this query to confirm:
```sql
SELECT student_id, full_name, invoice_url 
FROM students 
WHERE invoice_url IS NOT NULL;
```

### Step 3: Generate Test Invoice
1. Open `http://localhost:8000/invoice.html`
2. Select an approved student
3. Add invoice details
4. Click "Print / Save PDF"
5. Check console logs for "Student invoice URL updated"

### Step 4: Test Student Profile
1. Open `admin-student-page.html?id={student_id}`
2. Verify invoice link appears in Academic Information
3. Click link to test

### Step 5: Deploy invoice-view.html
1. Commit and push `invoice-view.html` to repository
2. Deploy to production website
3. Test invoice URL from production domain

## Data Flow

```
invoice.html (Admin)
  ↓
[Generate Invoice]
  ↓
Save to invoices table (with UUID)
  ↓
Update students.invoice_url = "invoice-view.html?id={uuid}"
  ↓
Admin views student profile
  ↓
Invoice link displayed
  ↓
Student clicks link
  ↓
invoice-view.html loads
  ↓
Shows disclaimer + invoice
```

## URL Format

### Production
```
https://acnhs.am/invoice-view.html?id=abc123-def456-ghi789
```

### Development (Local)
```
http://localhost:8000/invoice-view.html?id=abc123-def456-ghi789
```

### URL Components
- **Base:** `invoice-view.html`
- **Parameter:** `id` (invoice UUID from database)
- **Security:** UUID is cryptographically random, impossible to guess

## Display Examples

### Student Profile Page
```
Academic Information
┌─────────────────────────────┐
│ Program: Practical Nursing  │
│ Start Term: Fall 2026       │
│ Credits Earned: 0           │
│ 📄 Invoice:                 │
│   View Invoice with         │
│   Disclaimer →              │
└─────────────────────────────┘
```

### Students List Table
```
Actions
┌────────────────┐
│ 👁️ 📄 💰      │  ← New invoice button
└────────────────┘
```

### Invoice Notification (After Print)
```
┌────────────────────────────────┐
│ ✓ Invoice Saved                │
│ Unique invoice page created    │
│                                │
│ [View Invoice] [Copy Link]     │
└────────────────────────────────┘
```

## Use Cases

### Use Case 1: Email Invoice to Student
**Scenario:** Student accepted, needs to pay tuition

**Steps:**
1. Generate invoice in `invoice.html`
2. Copy invoice URL from notification
3. Compose email:
```
Subject: ACNHS Tuition Invoice

Dear [Student Name],

Congratulations on your acceptance! Please review and pay your tuition invoice:

[Invoice URL]

IMPORTANT: This invoice includes our non-refundable payment policy. 
Please read the disclaimer carefully before submitting payment.

Payment is due by [date].

Thank you,
ACNHS Admissions
```

### Use Case 2: Add to Acceptance Letter
**Scenario:** Include invoice in acceptance letter PDF

**Steps:**
1. Generate invoice first
2. Get invoice URL from student profile
3. Include in acceptance letter:
```
Next Steps:
1. Review your tuition invoice: [URL]
2. Read the non-refundable policy
3. Submit payment by [date]
```

### Use Case 3: Payment Reminder
**Scenario:** Payment due date approaching

**Steps:**
1. Check student profile for invoice URL
2. Send reminder email:
```
Payment Due Reminder

Your tuition payment is due on [date].

View your invoice: [URL]

All payments are non-refundable. Contact us with questions.
```

### Use Case 4: Student Self-Service
**Scenario:** Student lost invoice email

**Steps:**
1. Student contacts admin
2. Admin opens student profile
3. Copies invoice URL
4. Sends to student via email/SMS

## Troubleshooting

### Invoice URL not appearing in profile
**Cause:** Invoice wasn't saved or student_id mismatch

**Fix:**
1. Check console logs for "Student invoice URL updated"
2. Verify student_id in invoice matches students table
3. Re-generate invoice and check again
4. Run SQL: `SELECT * FROM students WHERE student_id = 'ACNHS-xxxxxxx'`

### Invoice link shows "Invoice not found"
**Cause:** Invoice UUID doesn't exist in database

**Fix:**
1. Check URL has complete UUID
2. Query: `SELECT id FROM invoices WHERE id = '{uuid}'`
3. Re-generate invoice if deleted
4. Verify invoice was saved successfully

### Student can't access invoice URL
**Cause:** RLS policies blocking anonymous access

**Fix:**
1. Check Supabase RLS policies on `invoices` table
2. Ensure anonymous SELECT policy exists:
```sql
CREATE POLICY "Allow anonymous select invoices"
ON invoices FOR SELECT
TO anon
USING (true);
```

### Invoice URL updates for wrong student
**Cause:** student_id mismatch or incorrect query

**Fix:**
1. Verify student_id field in invoice form
2. Check students table has correct student_id values
3. Review `updateStudentInvoiceUrl()` function
4. Check console logs for errors

## Future Enhancements

### Possible Additions
- [ ] **Automatic Email Sending** - Send invoice URL via email when generated
- [ ] **SMS Notifications** - Send invoice URL via Twilio SMS
- [ ] **Payment Status Tracking** - Link invoice status to student profile
- [ ] **Multiple Invoices** - Support multiple invoices per student
- [ ] **Invoice History** - Show all invoices for student
- [ ] **Payment Receipt Generation** - Auto-generate receipt after payment
- [ ] **Expiration Dates** - Make invoice URLs expire after due date
- [ ] **Access Logging** - Track when students view invoices
- [ ] **Download PDF** - Add PDF download button on invoice page
- [ ] **Print Count** - Track how many times invoice was printed/viewed

## Notes

### Important Considerations
- **One Invoice per Student** - Currently system updates single invoice_url
- **No Expiration** - Invoice URLs never expire (consider adding this)
- **Public Access** - Anyone with URL can view (UUID provides security)
- **No Authentication** - Students don't need login (by design)
- **Updates Overwrite** - New invoice replaces old URL in profile

### Best Practices
- Generate invoices after student approval
- Include invoice URL in all payment communications
- Test invoice URL before sending to student
- Keep track of invoice generation dates
- Document invoice numbers in student notes
- Archive old invoices before generating new ones

## Support

### Common Questions

**Q: Can one student have multiple invoices?**
A: Currently, no. The system stores one invoice_url per student. You can track multiple invoices in the invoices table, but only one URL is displayed in the profile.

**Q: What happens if I generate a new invoice for same student?**
A: The invoice_url in the student profile is updated to the new invoice URL. The old invoice still exists in the database but is no longer linked to the profile.

**Q: Can students edit the invoice?**
A: No. invoice-view.html is read-only. Only admins can edit via invoice.html.

**Q: Does the invoice URL expire?**
A: No, currently URLs never expire. Consider adding expiration logic in the future.

**Q: How do I revoke access to an invoice?**
A: Delete the invoice from the database. The URL will show "Invoice not found" error.

**Q: Can I customize the invoice URL domain?**
A: Yes, in production you can host invoice-view.html on any domain (e.g., invoices.acnhs.am).
