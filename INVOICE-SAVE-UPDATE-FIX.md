# Invoice Save vs Update Functionality - FIXED

## Problem
Previously, both "Save New Invoice" and "Update Invoice" buttons called the same `saveInvoiceToDatabase()` function, which checked if an invoice with the same number existed. This meant:
- If you loaded an existing invoice and changed the student name, clicking "Save New Invoice" would UPDATE the existing invoice instead of creating a new one
- No way to clone an invoice for a different student
- Confusing behavior - buttons did the same thing

## Solution Implemented

### 1. **Button Behavior Clarified**
- **"💾 Save New Invoice"** → ALWAYS creates a brand new invoice with a fresh invoice number
- **"✏️ Update Invoice"** → Updates the currently loaded invoice (only visible when invoice is loaded)

### 2. **State Tracking**
Added global variable:
```javascript
let currentLoadedInvoiceNumber = null;
```

This tracks which invoice is currently loaded for editing.

### 3. **Updated `saveInvoiceToDatabase(forceNew)` Function**
- Takes `forceNew` parameter (boolean)
- **When `forceNew = true`**: ALWAYS inserts new invoice (used by "Save New Invoice")
- **When `forceNew = false`**: Updates existing invoice by `currentLoadedInvoiceNumber` (used by "Update Invoice")

### 4. **Button Handlers**

#### Save New Invoice Button
```javascript
document.getElementById('saveInvoice').addEventListener('click', async () => {
  // Generate FRESH invoice number
  const newInvoiceNumber = generateInvoiceNumber();
  document.getElementById('invoiceNumber').value = newInvoiceNumber;
  
  // Force creation of NEW invoice
  const invoiceId = await saveInvoiceToDatabase(true);
  
  // Track the newly created invoice
  currentLoadedInvoiceNumber = newInvoiceNumber;
  
  // Show Update button for future edits
  document.getElementById('updateInvoice').style.display = 'block';
});
```

#### Update Invoice Button
```javascript
document.getElementById('updateInvoice').addEventListener('click', async () => {
  // Check if there's an invoice loaded
  if (!currentLoadedInvoiceNumber) {
    showNotification('No invoice loaded to update', 'warning');
    return;
  }
  
  // Update the existing invoice
  const invoiceId = await saveInvoiceToDatabase(false);
});
```

### 5. **Load Invoice Function**
```javascript
window.loadInvoiceFromDB = async function(invoiceId) {
  // ... load invoice data ...
  
  // Track the loaded invoice
  currentLoadedInvoiceNumber = invoice.invoice_number;
  
  // Show Update button
  document.getElementById('updateInvoice').style.display = 'block';
  
  showNotification('Invoice loaded - You can now UPDATE it or change details and SAVE NEW', 'success');
};
```

### 6. **Reset All Function**
```javascript
document.getElementById('resetAll').addEventListener('click', () => {
  // ... clear all fields ...
  
  // Clear loaded invoice tracking
  currentLoadedInvoiceNumber = null;
  
  // Hide Update button
  document.getElementById('updateInvoice').style.display = 'none';
});
```

## User Workflows

### Workflow 1: Create New Invoice from Scratch
1. Select student from dropdown
2. Add line items
3. Click **"💾 Save New Invoice"**
4. Invoice created with unique number
5. **"✏️ Update Invoice"** button appears
6. Future edits: Click **"Update Invoice"** to save changes

### Workflow 2: Clone Existing Invoice for Different Student
1. Click **"📋 All Invoices"**
2. Click on existing invoice to load it
3. Change student name in selector (or manually)
4. Modify line items if needed
5. Click **"💾 Save New Invoice"**
6. **NEW invoice created** with fresh invoice number
7. Original invoice remains unchanged

### Workflow 3: Edit Existing Invoice
1. Load invoice from **"📋 All Invoices"**
2. Modify fields (prices, notes, etc.)
3. Click **"✏️ Update Invoice"**
4. Changes saved to the SAME invoice
5. Invoice number stays the same

## Technical Details

### Database Behavior
- **`forceNew = true`**: Executes `INSERT INTO invoices (...)`
- **`forceNew = false`**: Executes `UPDATE invoices SET ... WHERE invoice_number = currentLoadedInvoiceNumber`

### Invoice Number Management
- New invoices: Fresh number generated via `generateInvoiceNumber()`
- Format: `ACNHS-YYYYMMDD-HHMM-RRR` (e.g., `ACNHS-20250126-1430-847`)
- Updated invoices: Can optionally change invoice number, but updates tracked by `currentLoadedInvoiceNumber`

### Notification Messages
- **Save New**: "✓ New Invoice Created Successfully - Invoice #ACNHS-xxx"
- **Update**: "✓ Invoice Updated Successfully - Invoice #ACNHS-xxx"
- **Load**: "Invoice loaded - You can now UPDATE it or change details and SAVE NEW"

## Files Modified
- `invoice.html` (lines 2047-2520)
  - Added `currentLoadedInvoiceNumber` global variable
  - Updated `saveInvoice` button handler
  - Updated `updateInvoice` button handler  
  - Modified `saveInvoiceToDatabase(forceNew)` function
  - Updated `loadInvoiceFromDB()` function
  - Modified `resetAll` button handler
  - Updated `printInvoice` button handler

## Testing Checklist
- ✅ Create new invoice from scratch
- ✅ Save new invoice multiple times (should create separate invoices)
- ✅ Load existing invoice
- ✅ Update existing invoice (verify original is updated)
- ✅ Load invoice, change student, save new (verify clone created)
- ✅ Reset all clears tracking and hides Update button
- ✅ Print button saves correctly (new vs update)

## Status
✅ **COMPLETE** - All functionality implemented and tested
