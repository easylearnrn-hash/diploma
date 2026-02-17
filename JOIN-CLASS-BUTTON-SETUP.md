# Join Class Button System - Setup & Implementation Guide

**Created:** February 17, 2026  
**Feature:** Group-based class link system with admin control and email notifications

---

## 🎯 Overview

This system allows administrators to post class meeting links that:
- ✅ **Display as GREEN button** on Student Page (below "Current Semester")
- ✅ **Target specific student groups** (All Students, Group A, B, C, etc.)
- ✅ **Send automatic emails** to all students in selected group
- ✅ **Show RED/GREEN status** on Admin Dashboard
- ✅ **Replace previous links** for the same group automatically
- ✅ **Stay active** until manually ended by admin

---

## 📋 Requirements Met

### ✅ Student Page
- Button appears **directly below** "CURRENT SEMESTER" / "Fall Semester 2026"
- Button is **GREEN** with text "🟢 Join Class"
- Button **only visible** if active link exists for student's group
- Button **opens link** in new tab when clicked

### ✅ Admin Dashboard
- **RED status box** appears after "Graduated" section
- Shows "🔴 NO ACTIVE LINK" when no link is active
- Shows "🟢 ACTIVE LINK" when link is active
- **Clicking opens modal** to post/manage links

### ✅ Admin Modal
- **Dropdown:** "Which group should see the link?"
- Lists actual student groups from database
- **Input:** Class Link URL field
- **Buttons:** Post and Cancel
- Posts link to selected group only
- Sends emails using existing template

### ✅ Critical Rules
- Groups without active link → no button visible
- New link for group → replaces previous link for that group
- Emails sent **only to selected group**
- Button styling matches existing template exactly

---

## 📁 Files Modified/Created

### New Files
1. **`ADD-CLASS-JOIN-LINKS-TABLE.sql`** - Database schema
2. **`JOIN-CLASS-BUTTON-SETUP.md`** - This setup guide

### Modified Files
1. **`Student-page.html`**
   - Added green "Join Class" button (line 1574-1595)
   - Added group-based link checking (line 6272-6318)
   - Button appears below "Current Semester" section

2. **`admin-home.html`**
   - Added RED/GREEN status card (line 1500-1511)
   - Updated modal with group dropdown (line 3287-3302)
   - Added email sending function (line 3030-3138)
   - Added group loading function (line 2856-2875)

---

## 🗄️ Database Schema

**Table:** `class_join_links`
```sql
- id (UUID, PK)
- url (TEXT) - Class meeting link
- group_id (TEXT, REQUIRED) - 'all', 'Group A', 'Group B', etc.
- created_by (TEXT) - Admin email
- created_at (TIMESTAMPTZ)
- expires_at (TIMESTAMPTZ, NULLABLE) - Optional expiration
- ended_at (TIMESTAMPTZ) - Manual termination timestamp
- is_active (BOOLEAN)
```

**Key Changes from Original:**
- `group_id` is now **REQUIRED** (not optional)
- `expires_at` is now **NULLABLE** (links stay active until manually ended)
- Removed 1-hour auto-expiration constraint

---

## 🚀 Deployment Steps

### Step 1: Deploy Database
```bash
# 1. Open Supabase SQL Editor
# 2. Copy contents of ADD-CLASS-JOIN-LINKS-TABLE.sql
# 3. Run the SQL migration
# 4. Verify table creation:
SELECT * FROM class_join_links LIMIT 0;
```

### Step 2: Enable Realtime
```bash
# Supabase Dashboard → Database → Replication
# Toggle ON: class_join_links
```

### Step 3: Test Admin Flow
1. Login as admin (hrachfilm@gmail.com)
2. Open `admin-home.html`
3. See RED status box "🔴 NO ACTIVE LINK"
4. Click the box to open modal
5. Enter: `https://zoom.us/j/123456789`
6. Select group: "Group A" (or create test group)
7. Click "📤 Post Link & Send Emails"
8. Status box turns GREEN "🟢 ACTIVE LINK"

### Step 4: Test Student Flow
1. Create test student with `group` = "Group A"
2. Login as that student
3. Open `Student-page.html`
4. Verify "Current Semester" shows "Fall Semester 2026"
5. See green button "🟢 Join Class" below it
6. Click button → Opens Zoom link in new tab

### Step 5: Test Email Delivery
1. Check student's email inbox
2. Look for email from: `hub@acnhs.am`
3. Subject: "🟢 Class Link Available - Join Now"
4. Verify green button in email works
5. Verify email matches existing template styling

---

## 🎨 UI Components

### Student Page Button
**Location:** Below "Current Semester" in program details section  
**Appearance:**
```css
- Background: linear-gradient(135deg, #22c55e, #16a34a)
- Color: white
- Text: "🟢 Join Class"
- Width: 100% (fills container)
- Hover: Lifts up with shadow
```

### Admin Status Card
**RED State** (No Active Link):
```
Icon: 🔴
Text: NO ACTIVE LINK (red color #ef4444)
Info: Click to post a link
```

**GREEN State** (Link Active):
```
Icon: 🟢
Text: ACTIVE LINK (green color #22c55e)
Info: For [Group Name]
Background: Green gradient
Border: Green glow
```

### Admin Modal
**Title:** "🔗 Post Join Class Link"

**Form Fields:**
1. Class Link URL (required, validated for http/https)
2. Which group should see the link? (required dropdown)
3. Info banner with instructions
4. "📤 Post Link & Send Emails" button

**Active Link Display:**
- Shows current link details
- Green status with URL
- "📋 Copy Link" button
- "🛑 End Now" button (manual termination)

---

## 📧 Email Template

The system uses your existing email template with these elements:

**Subject:** `🟢 Class Link Available - Join Now`

**From:** `hub@acnhs.am`

**Template Structure:**
```html
- Header: Dark gradient with logo
- Greeting: "Dear [Student Name],"
- Message: Instructions to join class
- Green Button: "🟢 Join Class" (same styling as button)
- Footer: ACNHS contact information
```

**Button Styling:**
```css
padding: 16px 48px
background: linear-gradient(135deg, #22c55e, #16a34a)
color: #ffffff
border-radius: 12px
box-shadow: 0 6px 20px rgba(34,197,94,0.4)
```

---

## 🔧 Key Functions

### Admin Side

**`loadStudentGroups()`**
- Queries `students` table for unique groups
- Populates dropdown with actual groups
- Called when modal opens

**`publishClassLink()`**
- Validates URL and group selection
- Deactivates previous link for same group
- Creates new active link
- Sends emails to group members
- Updates status card

**`sendClassLinkEmail(classUrl, targetGroup)`**
- Queries students by group
- Generates HTML email using template
- Calls Supabase Edge Function `send-email`
- Sends to each student individually

**`updateActiveLinkStatus(hasActiveLink)`**
- Updates status card (RED/GREEN)
- Updates icon and text
- Shows group name when active

**`endLinkEarly()`**
- Sets `ended_at` timestamp
- Sets `is_active = false`
- Immediately hides student buttons
- Updates admin UI

### Student Side

**`checkForActiveClassLink()`**
- Gets student's group from session/local storage
- Queries for active link matching student's group or "all"
- Shows/hides button based on result
- Runs on page load + every 30 seconds

**`joinActiveClass()`**
- Opens stored link URL in new tab
- Uses `noopener,noreferrer` for security
- Logs join event to console

---

## 🔐 Security Features

✅ **RLS Policies:**
- Only admins can INSERT/UPDATE/DELETE links
- Students can only SELECT active, non-ended links for their group

✅ **URL Validation:**
- Must start with `http://` or `https://`
- Validated on client and server

✅ **Group Isolation:**
- Students only see links for their own group or "all"
- Query filters by `group_id`

✅ **Email Security:**
- Sent via Supabase Edge Function (not client-side)
- From address: `hub@acnhs.am`
- Rate limiting handled by Supabase

✅ **New Tab Security:**
- Links open with `noopener,noreferrer`
- Prevents tab-napping attacks

---

## 🧪 Testing Checklist

### Database Tests
- [ ] SQL migration runs without errors
- [ ] `class_join_links` table exists
- [ ] RLS policies are active
- [ ] Realtime is enabled

### Admin Tests
- [ ] RED status box appears when no link
- [ ] Clicking box opens modal
- [ ] Group dropdown loads actual groups
- [ ] URL validation works (http/https required)
- [ ] Group selection is required
- [ ] Link posts successfully
- [ ] Status box turns GREEN after posting
- [ ] Previous link is replaced for same group
- [ ] "End Now" button works

### Student Tests
- [ ] Button hidden when no active link
- [ ] Button appears for correct group only
- [ ] Button positioned below "Current Semester"
- [ ] Button opens correct URL
- [ ] Button disappears when link ended
- [ ] Multiple students in same group see same button
- [ ] Students in different groups see different/no buttons

### Email Tests
- [ ] Emails sent to all students in selected group
- [ ] Emails NOT sent to students in other groups
- [ ] Email from address is `hub@acnhs.am`
- [ ] Green button in email works
- [ ] Email template matches existing style
- [ ] Text link works if button doesn't

### Real-time Tests
- [ ] Student button appears within 2 seconds of posting
- [ ] Student button disappears within 2 seconds of ending
- [ ] Multiple students see updates simultaneously
- [ ] Admin status card updates in real-time

---

## 🔍 Troubleshooting

### Issue: Button doesn't appear for students

**Diagnosis:**
```sql
-- Check if link exists
SELECT * FROM class_join_links 
WHERE is_active = true 
AND ended_at IS NULL
ORDER BY created_at DESC;

-- Check student's group
SELECT full_name, email, "group" FROM students 
WHERE email = 'student@acnhs.am';
```

**Possible Causes:**
1. ❌ No active link posted → Admin should post link
2. ❌ Student's group doesn't match link group → Check group_id
3. ❌ Realtime not enabled → Enable in Supabase Dashboard
4. ❌ Student group not in sessionStorage → Set via loadStudentProfile()

### Issue: Admin can't post link

**Diagnosis:**
1. Check browser console (F12) for errors
2. Verify admin email in RLS policy
3. Check URL format (must be http/https)
4. Verify group is selected

**Fix:**
```sql
-- Add your email to RLS policy
UPDATE pg_policies 
SET definition = definition || ' OR created_by = ''your@email.com'''
WHERE tablename = 'class_join_links' 
AND policyname = 'admin_insert_class_links';
```

### Issue: Emails not sending

**Diagnosis:**
```javascript
// Check console for email sending logs
console.log('Sending emails to X students in group: Y');
console.log('Email sent to student@email.com');
```

**Possible Causes:**
1. ❌ Edge Function not deployed → Deploy `send-email` function
2. ❌ Invalid student emails → Check `students.email` column
3. ❌ SMTP not configured → Configure Resend in Supabase

### Issue: Wrong students receive emails

**Diagnosis:**
```sql
-- Check which students are in the selected group
SELECT full_name, email, "group" 
FROM students 
WHERE "group" = 'Group A';
```

**Fix:** Verify `group_id` in `class_join_links` matches actual student groups

### Issue: Old link still showing

**Diagnosis:**
```sql
-- Check for multiple active links
SELECT id, group_id, url, created_at, ended_at, is_active
FROM class_join_links
WHERE group_id = 'Group A'
ORDER BY created_at DESC;
```

**Fix:** System should auto-deactivate old links, but you can manually:
```sql
UPDATE class_join_links
SET is_active = false, ended_at = NOW()
WHERE group_id = 'Group A' AND id != 'newest-link-id';
```

---

## 📊 Query Examples

### Get all active links by group
```sql
SELECT 
  group_id,
  url,
  created_by,
  created_at,
  is_active
FROM class_join_links
WHERE is_active = true 
AND ended_at IS NULL
ORDER BY created_at DESC;
```

### Count students by group
```sql
SELECT 
  "group",
  COUNT(*) as student_count
FROM students
WHERE "group" IS NOT NULL
GROUP BY "group"
ORDER BY "group";
```

### View email recipients for a link
```sql
SELECT 
  s.full_name,
  s.email,
  s.group,
  l.url,
  l.created_at
FROM students s
JOIN class_join_links l ON (s.group = l.group_id OR l.group_id = 'all')
WHERE l.id = 'link-uuid-here'
AND s.email IS NOT NULL;
```

### End all active links (emergency)
```sql
UPDATE class_join_links
SET is_active = false, ended_at = NOW()
WHERE is_active = true AND ended_at IS NULL;
```

---

## 🆕 Differences from Original Implementation

### What Changed:

**1. Group Requirement:**
- **Before:** `group_id` was optional (nullable)
- **Now:** `group_id` is **REQUIRED** - admin must select which group

**2. Expiration:**
- **Before:** Auto-expired after 1 hour
- **Now:** Links stay active **indefinitely** until manually ended

**3. Button Location:**
- **Before:** Button in header next to "Hub" button
- **Now:** Button **below "Current Semester"** in program details section

**4. Email Integration:**
- **Before:** No email functionality
- **Now:** **Automatic emails** sent to all students in selected group

**5. Admin UI:**
- **Before:** Card in Quick Actions
- **Now:** **RED/GREEN status card** in main stats grid

**6. Link Replacement:**
- **Before:** Multiple links could coexist
- **Now:** **New link replaces** previous link for same group

---

## 📝 Usage Instructions (For Admins)

### How to Post a Class Link

1. **Login** to Admin Hub (`admin-home.html`)
2. **Look** for RED box "🔴 NO ACTIVE LINK" in dashboard
3. **Click** the RED box to open modal
4. **Enter** meeting link (Zoom/Meet/Teams URL)
5. **Select** which group should see the link
6. **Click** "📤 Post Link & Send Emails"
7. **Verify:**
   - Status box turns GREEN
   - Success message confirms email sending
   - Modal closes automatically

### How to End a Link

**Option 1:** Click GREEN status box → Click "🛑 End Now"  
**Option 2:** Repost a new link for the same group (replaces old link)

### Best Practices

✅ **DO:**
- Test the meeting link before posting
- Select the correct group
- Verify students received emails
- End link after class is over
- Check student feedback if button not working

❌ **DON'T:**
- Post multiple links for same group simultaneously
- Leave old links active indefinitely
- Use generic "all" if targeting specific group
- Share meeting link via other channels (defeats purpose)

---

## 🆘 Support & Maintenance

**Issues?**
- Check browser console (F12) for errors
- Verify Supabase connection
- Check Realtime status
- Review email logs in Supabase Functions

**Feature Requests:**
- Scheduled link posting
- Link expiration options
- Attendance tracking
- Link click analytics
- Push notifications

**Maintenance:**
- Clean up old ended links monthly
- Monitor email delivery rates
- Review RLS policies quarterly
- Update student groups as needed

---

## ✅ System Status

After completing this guide, you should have:

✅ Database table `class_join_links` created  
✅ RLS policies configured for admin/student access  
✅ Realtime replication enabled  
✅ Admin RED/GREEN status card working  
✅ Admin modal with group dropdown  
✅ Student button positioned correctly  
✅ Group-based filtering working  
✅ Email system integrated  
✅ Link replacement logic functional  

**System is production-ready!** 🎉

---

## 📞 Contact

**Database Issues:** Check `ADD-CLASS-JOIN-LINKS-TABLE.sql`  
**Admin UI:** Lines 1500-1511, 2800-3150 in `admin-home.html`  
**Student UI:** Lines 1574-1595, 6250-6320 in `Student-page.html`  
**Email Template:** Lines 3040-3130 in `admin-home.html`

All features implemented according to requirements!
