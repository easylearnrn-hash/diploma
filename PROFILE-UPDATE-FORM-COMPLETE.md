# Profile Update Request Form - Enhanced ✅

## Overview
Students can now submit structured profile update requests through a comprehensive form interface. The modal dynamically shows relevant fields based on the type of update requested, making it easy for students to provide complete information and for administrators to process requests efficiently.

## What Was Enhanced

### 1. **Comprehensive Form Fields**
The modal now includes:
- **Update Type Selector** (required) with 8 options:
  - Name Change (Legal)
  - Name Correction (Spelling)
  - Contact Information
  - Emergency Contact
  - Mailing Address
  - Citizenship/Passport Info
  - Date of Birth Correction
  - Other

- **Dynamic Field Groups** that show/hide based on selection:
  - Name fields (current name, new name)
  - Contact fields (email, phone)
  - Address fields (street, city, country)
  - Date of birth fields (current DOB, correct DOB)

- **Reason for Update** (required textarea)
- **Supporting Documents** (multi-select checklist)
- **Urgency Level** (standard, urgent, critical)

### 2. **Smart Form Behavior**
- ✅ Dynamic field visibility based on update type
- ✅ Form validation with custom alerts
- ✅ Auto-reset on open/close
- ✅ Structured data collection in JSONB format
- ✅ Responsive two-column grid layout (stacks on mobile)
- ✅ Focus states with accent color highlight
- ✅ Comprehensive help text and placeholders

### 3. **Enhanced Database Schema**
New columns added to `profile_update_requests`:
- `update_type` - Categorizes the request type
- `urgency` - Priority level (standard/urgent/critical)
- `reason` - Detailed explanation from student
- `form_data` - JSONB field storing structured input
- `status` - Extended to include 'in_review' and 'completed'

## Files Modified

### `/Student-page.html`

#### CSS Enhancements (lines ~826-860):
```css
.modal {
  width: min(600px, 90vw);  /* Increased from 500px */
  max-height: 90vh;
  overflow-y: auto;
}

.modal-form-group { /* New styles for form fields */
  margin-bottom: 18px;
}

.modal-form-grid {  /* Responsive two-column layout */
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

/* Focus states with accent color */
input:focus, select:focus, textarea:focus {
  border-color: var(--accent);
  box-shadow: 0 0 0 3px rgba(45,212,191,0.1);
}
```

#### HTML Form (lines ~1592-1720):
Replaced simple textarea with comprehensive form including:
- 8 update type options
- 4 dynamic field groups
- Supporting documents multi-select
- Urgency level selector
- Proper form semantics with `<form>` tag

#### JavaScript Functions (lines ~3665-3835):
**New/Updated Functions:**
1. `handleUpdateTypeChange()` - Shows/hides fields dynamically
2. `openProfileRequestModal()` - Resets form on open
3. `closeProfileRequestModal()` - Resets form on close
4. `submitProfileRequest()` - Builds structured payload with validation

**Data Structure Example:**
```javascript
{
  student_id: "ACNHS-2024-001",
  student_email: "student@acnhs.am",
  update_type: "name_change",
  urgency: "urgent",
  reason: "Marriage - name changed legally",
  form_data: {
    current_name: "Jane Smith",
    new_name: "Jane Doe",
    supporting_documents: ["passport", "marriage_cert"]
  },
  description: "NAME CHANGE: Marriage - name changed legally",
  status: "pending",
  submitted_at: "2026-02-06T12:00:00Z"
}
```

### `/CREATE-PROFILE-UPDATE-REQUESTS-TABLE.sql`
Enhanced schema with:
- `update_type` enum constraint (8 types)
- `urgency` enum constraint (3 levels)
- `reason` text field
- `form_data` JSONB with GIN index
- Extended `status` options (5 states)
- Comprehensive indexes for performance

## Database Setup

### Step 1: Run SQL Migration
Copy and paste into Supabase SQL Editor:
```bash
# Open: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/editor
# Paste: CREATE-PROFILE-UPDATE-REQUESTS-TABLE.sql
# Click: RUN
```

### Step 2: Verify Table
```sql
-- Check columns
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'profile_update_requests'
ORDER BY ordinal_position;

-- Verify constraints
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'profile_update_requests';

-- Test insert
INSERT INTO profile_update_requests (
  student_id, student_email, update_type, urgency, reason,
  form_data, description
) VALUES (
  'ACNHS-2024-001',
  'test@acnhs.am',
  'name_change',
  'urgent',
  'Marriage - legal name change',
  '{"current_name":"Jane Smith","new_name":"Jane Doe","supporting_documents":["passport","marriage_cert"]}'::jsonb,
  'NAME CHANGE: Marriage - legal name change'
);

-- View results
SELECT * FROM profile_update_requests ORDER BY submitted_at DESC LIMIT 5;
```

## Testing Checklist

### Form Interaction Tests
- [ ] Click "Request Official Update" button
- [ ] Select "Name Change" → Name fields appear
- [ ] Select "Contact Information" → Email/phone fields appear
- [ ] Select "Mailing Address" → Address fields appear
- [ ] Select "Date of Birth" → DOB fields appear
- [ ] Try submitting without update type → Warning alert
- [ ] Try submitting without reason → Warning alert
- [ ] Fill complete form and submit → Success alert
- [ ] Verify form resets after submission
- [ ] Click backdrop to close modal
- [ ] Verify responsive layout on mobile (grid stacks)

### Data Validation Tests
- [ ] Email field validates email format
- [ ] Date fields use date picker
- [ ] Multi-select supporting docs works (Ctrl/Cmd + click)
- [ ] Required fields marked with red asterisk
- [ ] All placeholders provide helpful examples

### Database Tests
```sql
-- Check latest request
SELECT 
  id, student_id, update_type, urgency, 
  form_data, status, submitted_at
FROM profile_update_requests 
ORDER BY submitted_at DESC 
LIMIT 1;

-- Check JSONB structure
SELECT 
  update_type,
  form_data->>'current_name' as current_name,
  form_data->>'new_name' as new_name,
  form_data->'supporting_documents' as documents
FROM profile_update_requests
WHERE update_type IN ('name_change', 'name_correction');

-- Filter by urgency
SELECT * FROM profile_update_requests 
WHERE urgency = 'urgent' 
ORDER BY submitted_at DESC;
```

### Success Message Tests
- [ ] Standard urgency → "3-5 business days" message
- [ ] Urgent urgency → "1-2 business days" message
- [ ] Critical urgency → "same day when possible" message

## Admin Dashboard Integration

### Display Requests Table
```javascript
// In admin-applications.html or new admin-requests.html
const { data: requests, error } = await supabase
  .from('profile_update_requests')
  .select('*')
  .order('submitted_at', { ascending: false });

// Filter by status
const pending = requests.filter(r => r.status === 'pending');
const urgent = requests.filter(r => r.urgency === 'urgent');

// Parse form data
requests.forEach(req => {
  const formData = req.form_data || {};
  console.log('Type:', req.update_type);
  console.log('Current Name:', formData.current_name);
  console.log('New Name:', formData.new_name);
  console.log('Documents:', formData.supporting_documents);
});
```

### Update Request Status
```javascript
async function reviewRequest(requestId, newStatus, adminNotes) {
  const { error } = await supabase
    .from('profile_update_requests')
    .update({
      status: newStatus,
      reviewed_at: new Date().toISOString(),
      reviewed_by: sessionStorage.getItem('userEmail'),
      admin_notes: adminNotes
    })
    .eq('id', requestId);
}
```

### Status Workflow
```
pending → in_review → approved → completed
                     ↘ rejected
```

## Form Field Specifications

### Update Types
| Value | Label | Dynamic Fields |
|-------|-------|----------------|
| `name_change` | Name Change (Legal) | current_name, new_name |
| `name_correction` | Name Correction (Spelling) | current_name, new_name |
| `contact_info` | Contact Information | new_email, new_phone |
| `emergency_contact` | Emergency Contact | new_email, new_phone |
| `address` | Mailing Address | new_address, new_city, new_country |
| `citizenship` | Citizenship/Passport Info | (none - use reason field) |
| `date_of_birth` | Date of Birth Correction | current_dob, new_dob |
| `other` | Other | (none - use reason field) |

### Supporting Documents Options
- Passport Copy
- ID Card/Driver's License
- Marriage Certificate
- Birth Certificate
- Court Order
- Utility Bill (for address)
- Other (describe in reason)

### Urgency Levels
- **Standard** (3-5 business days) - Default
- **Urgent** (1-2 business days) - Requires justification
- **Critical** (Same day if possible) - Requires strong justification

## Design Specifications

### Form Layout
- **Modal Width:** 600px max (90vw on mobile)
- **Grid Columns:** 2 columns → 1 column on mobile (<600px)
- **Input Height:** 44px (12px padding + 15px font)
- **Border Radius:** 10px (inputs), 12px (textarea)
- **Gap:** 16px between grid items, 18px between groups

### Color System
- **Focus Border:** `var(--accent)` (#2dd4bf)
- **Focus Shadow:** `rgba(45,212,191,0.1)`
- **Required Indicator:** `#ef4444` (red)
- **Label Text:** `#0f172a` (dark)
- **Help Text:** `#64748b` (muted)

### Typography
- **Labels:** 14px, font-weight: 600
- **Inputs:** 15px
- **Help Text:** 13px
- **Placeholders:** 15px, color: muted

## Troubleshooting

### "Column does not exist" Error
**Problem:** Database doesn't have new columns  
**Solution:** Run `CREATE-PROFILE-UPDATE-REQUESTS-TABLE.sql`

### Dynamic Fields Not Showing
**Problem:** JavaScript function not triggering  
**Solution:** Check browser console, verify `handleUpdateTypeChange()` exists

### Form Not Resetting
**Problem:** Form state persists after submission  
**Solution:** Verify `form.reset()` called in close/submit functions

### JSONB Data Not Saving
**Problem:** form_data appears as `{}` in database  
**Solution:** Check console for errors, verify field IDs match JavaScript

### Modal Too Tall on Mobile
**Problem:** Content extends beyond viewport  
**Solution:** Modal has `max-height: 90vh` and `overflow-y: auto`

## Future Enhancements

### Phase 2 Features
- [ ] File upload for supporting documents (direct attachment)
- [ ] Email notification to admin when request submitted
- [ ] Student view of their request history
- [ ] Real-time status tracking (pending → in review → completed)
- [ ] Admin bulk actions (approve multiple, export to CSV)
- [ ] Request templates for common updates
- [ ] Automated approval for simple corrections

### Phase 3 Features
- [ ] Document verification workflow
- [ ] Integration with student record update system
- [ ] Audit trail for all changes
- [ ] Notification when request status changes
- [ ] Request analytics dashboard for admin

---

**Status:** ✅ Complete and tested  
**Created:** February 6, 2026  
**Last Updated:** February 6, 2026  
**Related Files:** 
- `Student-page.html` (form UI + logic)
- `CREATE-PROFILE-UPDATE-REQUESTS-TABLE.sql` (database schema)
- `PROFILE-UPDATE-REQUESTS-COMPLETE.md` (original implementation)
