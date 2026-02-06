# Invoices Table Setup Guide

## Purpose
The `invoices` table stores all generated invoices from the invoice generator, allowing you to:
- Track all invoices in one place
- Search by student name or invoice number
- Filter by payment status (unpaid, paid, overdue, cancelled)
- Load previous invoices for editing or reprinting
- Mark invoices as paid
- Delete old invoices

## Features Added
1. **📋 All Invoices Button** - View all generated invoices in a modal
2. **Auto-save on Print** - Every time you print/save PDF, invoice is automatically saved to database
3. **Search & Filter** - Search by student name or invoice number, filter by payment status
4. **Load Invoice** - Click any invoice to load it back into the editor
5. **Mark as Paid** - Update invoice status with one click
6. **Delete Invoice** - Remove invoices you no longer need

## Setup Instructions

### Step 1: Run SQL in Supabase
1. Go to https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/sql
2. Open `CREATE-INVOICES-TABLE.sql` from your DIPLOMA folder
3. Copy all the SQL content
4. Paste into Supabase SQL Editor
5. Click **Run**

### Step 2: Verify Table Creation
Run this query to confirm:
```sql
SELECT * FROM invoices LIMIT 1;
```

## Table Schema

### Columns
- `id` - UUID primary key
- `invoice_number` - Unique invoice number (ACNHS-YYYYMMDD-HHMM-RRR)
- `student_name` - Student's full name
- `student_id` - Student ID (ACNHS-xxxxxxx)
- `program` - Program name (e.g., "Practical Nursing (PN)")
- `invoice_date` - Invoice issue date
- `due_date` - Payment due date
- `payment_method` - Payment method selected
- `notes` - Payment instructions/notes
- `items` - JSONB array of line items with description, qty, price
- `subtotal` - Calculated subtotal before tax
- `tax_rate` - Tax percentage (default 0)
- `tax_amount` - Calculated tax amount
- `total` - Final total amount
- `status` - Payment status: unpaid, paid, overdue, cancelled
- `created_at` - Timestamp when invoice was first saved
- `updated_at` - Timestamp when invoice was last updated

### Indexes
- Fast lookup by invoice_number
- Search by student_name
- Sort by invoice_date
- Filter by status
- Recent invoices by created_at

## Usage Workflow

### Creating New Invoice
1. Fill out invoice form in editor
2. Add line items
3. Click "🖨️ Print / Save PDF"
4. Invoice is automatically saved to database
5. Print or save as PDF

### Viewing All Invoices
1. Click "📋 All Invoices" button
2. Modal opens showing all invoices sorted by newest first
3. Use search box to find specific student or invoice number
4. Use status filter to show only unpaid/paid/overdue/cancelled

### Loading Previous Invoice
1. Open "All Invoices" modal
2. Click on any invoice card or click "Load" button
3. Invoice data loads into editor
4. Modify as needed and print/save again (updates existing invoice)

### Managing Invoices
- **Mark as Paid**: Click "Mark Paid" on any invoice card
- **Delete**: Click "Delete" button (requires confirmation)
- **Edit**: Load invoice, make changes, print again (auto-updates)

## Invoice Status Meanings
- **Unpaid** (Yellow) - Invoice issued, payment pending
- **Paid** (Green) - Payment received and confirmed
- **Overdue** (Red) - Payment past due date
- **Cancelled** (Gray) - Invoice cancelled/voided

## Security
- RLS policies allow anonymous access for local development
- **Production**: Lock down with authenticated user policies
- All CRUD operations logged with timestamps

## Troubleshooting

### "Table does not exist" error
→ Run CREATE-INVOICES-TABLE.sql in Supabase SQL Editor

### Invoices not appearing in modal
→ Check browser console for errors
→ Verify Supabase connection in Network tab

### Search not working
→ Clear search box and try again
→ Check status filter is not too restrictive

### Can't delete invoice
→ Confirm deletion in dialog
→ Check RLS policies allow DELETE

## Notes
- Invoices are saved automatically when you print
- Duplicate invoice numbers update the existing invoice
- Search is case-insensitive and matches partial text
- All amounts stored as DECIMAL(10,2) for accuracy
- Items stored as JSONB for flexible line item structure
