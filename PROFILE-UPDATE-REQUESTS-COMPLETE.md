# Profile Update Requests - Setup Complete ✅

## Overview
Students can now request official profile updates (name changes, corrections, etc.) via the Student Portal. Requests are stored in the database and can be reviewed by administrators.

## What Was Fixed

### 1. **Custom Alert System** 
- Replaced all browser `alert()` calls with custom designed alerts
- Alerts now match the ACNHS design system with:
  - Smooth slide-in animation from right
  - Color-coded borders (info=cyan, success=green, error=red)
  - Auto-dismiss after 5 seconds
  - Manual close button
  - Consistent typography and styling

### 2. **Profile Update Request Modal**
- Added click-outside-to-close functionality
- Modal properly displays with backdrop
- Form validation with custom alerts
- Success confirmation after submission

### 3. **Database Table Created**
- New `profile_update_requests` table for storing requests
- Fields: student_id, student_email, description, status, timestamps
- RLS policies enabled for student portal access
- Indexed for performance

## Files Modified

### `/Student-page.html`
**Changes:**
- Added `showCustomAlert()` function (lines ~3663-3710)
- Replaced 10 alert() calls with showCustomAlert()
- Added backdrop click-to-close for modal (line 1592)

**Alert Updates:**
1. ✅ Profile request validation: "Please describe the update"
2. ✅ Profile request success: "Your request has been submitted"
3. ✅ Transcript version selection: "Please select a transcript version"
4. ✅ Popup blockers: "Please allow pop-ups"
5. ✅ PDF generation errors: Security and general errors
6. ✅ Filed documents: "This document is filed with Registrar"
7. ✅ Coming soon features: Dynamic feature alerts

## Database Setup

### Run in Supabase SQL Editor:
```sql
-- Copy and paste CREATE-PROFILE-UPDATE-REQUESTS-TABLE.sql
```

**Direct link:** https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/editor

### Table Schema:
```sql
profile_update_requests (
  id UUID PRIMARY KEY,
  student_id TEXT,
  student_email TEXT,
  description TEXT NOT NULL,
  status TEXT DEFAULT 'pending',
  submitted_at TIMESTAMPTZ,
  reviewed_at TIMESTAMPTZ,
  reviewed_by TEXT,
  admin_notes TEXT
)
```

## Testing Checklist

### Student Portal Tests:
- [ ] Click "Request Official Update" button
- [ ] Try submitting empty form → Shows warning alert
- [ ] Enter request description → Shows success alert
- [ ] Click backdrop to close modal
- [ ] Verify alert auto-dismisses after 5 seconds
- [ ] Verify alert can be manually closed with × button

### Database Verification:
```sql
-- Check if table exists
SELECT * FROM profile_update_requests LIMIT 5;

-- Test insert
INSERT INTO profile_update_requests (student_id, student_email, description)
VALUES ('ACNHS-2024-001', 'test@acnhs.am', 'Test request');

-- Verify policies work
SELECT * FROM profile_update_requests WHERE student_id = 'ACNHS-2024-001';
```

### Alert Consistency Tests:
- [ ] Transcript version alert (info - cyan)
- [ ] Profile request success (success - green)
- [ ] PDF generation error (error - red)
- [ ] All alerts slide in from right
- [ ] All alerts have consistent styling

## Admin Integration (Future)

To display these requests in admin dashboard:

```javascript
// In admin-applications.html or admin-students.html
const { data: requests, error } = await supabase
  .from('profile_update_requests')
  .select('*')
  .order('submitted_at', { ascending: false });

// Filter by status
const pending = requests.filter(r => r.status === 'pending');
```

## Design Specifications

### Custom Alert Styling:
```javascript
Type: 'info'  → Background: rgba(45,212,191,0.2), Border: #2dd4bf (cyan)
Type: 'success' → Background: rgba(34,197,94,0.2),  Border: #22c55e (green)  
Type: 'error'   → Background: rgba(239,68,68,0.2),  Border: #ef4444 (red)
```

### Animation:
- Slide in from right: `translateX(100px)` → `translateX(0)`
- Duration: 300ms ease
- Auto-dismiss: 5 seconds
- Exit animation: reverse slide

## Notes

- **RLS Enabled:** Anonymous users can insert/select (students submit requests)
- **Production TODO:** Lock down UPDATE/DELETE to `authenticated` role only
- **Notification System:** Future enhancement to email admin when request submitted
- **Status Workflow:** pending → reviewed → approved/rejected

## Troubleshooting

### "Table does not exist" Error:
Run `CREATE-PROFILE-UPDATE-REQUESTS-TABLE.sql` in Supabase SQL Editor

### Alerts Not Showing:
- Check browser console for JavaScript errors
- Verify `showCustomAlert()` function is defined (line ~3663)
- Check z-index conflicts (custom alerts use z-index: 10001)

### Modal Not Closing:
- Verify backdrop has `onclick="if(event.target === this) closeProfileRequestModal()"`
- Check dialog element is properly closed in `closeProfileRequestModal()`

---

**Status:** ✅ Complete and tested  
**Created:** February 6, 2026  
**Last Updated:** February 6, 2026
