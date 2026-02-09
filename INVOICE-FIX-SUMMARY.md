# Invoice Save/Update Fix - Quick Reference

## What Changed?

### Before
- "Save New Invoice" and "Update Invoice" buttons did the SAME thing
- Both would update existing invoice if invoice number matched
- No way to clone an invoice for a different student

### After
- **"💾 Save New Invoice"** → ALWAYS creates NEW invoice with fresh number
- **"✏️ Update Invoice"** → Updates currently loaded invoice (only visible when invoice loaded)
- Can now clone invoices: Load existing → Change student → Save New

## Key Workflows

### Create New Invoice
1. Select student
2. Add items
3. Click **"Save New Invoice"**
4. Done! Invoice created

### Clone Invoice for Different Student
1. Click **"All Invoices"**, load existing invoice
2. Change student name
3. Click **"Save New Invoice"** (generates fresh number)
4. Original invoice untouched, new one created

### Edit Existing Invoice
1. Load invoice from **"All Invoices"**
2. Make changes
3. Click **"Update Invoice"**
4. Same invoice updated (number stays same)

## Technical Implementation

### State Tracking
```javascript
let currentLoadedInvoiceNumber = null; // Tracks loaded invoice
```

### Function Signature
```javascript
async function saveInvoiceToDatabase(forceNew = false)
```
- `forceNew = true` → INSERT new invoice
- `forceNew = false` → UPDATE existing invoice by currentLoadedInvoiceNumber

### Button Behavior
| Button | Action | Database Operation |
|--------|--------|-------------------|
| Save New Invoice | Generates fresh invoice number | `INSERT INTO invoices` |
| Update Invoice | Uses currentLoadedInvoiceNumber | `UPDATE invoices WHERE invoice_number = ...` |

## Files Modified
- **invoice.html** (5 sections)
  - Save button handler (lines ~2050)
  - Update button handler (lines ~2090)
  - saveInvoiceToDatabase function (lines ~2200)
  - loadInvoiceFromDB function (lines ~2438)
  - resetAll handler (lines ~2020)

## Status: ✅ COMPLETE

Date: January 26, 2025
