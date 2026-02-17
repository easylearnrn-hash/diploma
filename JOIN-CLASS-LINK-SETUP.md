# JOIN CLASS LINK SYSTEM - Complete Setup Guide
**Created:** 2026-02-17  
**Feature:** 1-hour expiring class links with admin control and student auto-display

---

## 🎯 Overview

This system allows administrators to post temporary "Join Class" links that:
- ✅ **Auto-expire after 1 hour**
- ✅ **Display as green button** in Student Hub
- ✅ **Disappear automatically** when expired
- ✅ **Support group targeting** (All/Group A/Group B/etc.)
- ✅ **Real-time synchronization** via Supabase Realtime
- ✅ **Manual early termination** by admin

---

## 📋 Step 1: Database Setup

### Run SQL Migration

1. Open **Supabase Dashboard** → https://supabase.com/dashboard
2. Navigate to **SQL Editor** (left sidebar)
3. Click **"New Query"**
4. Copy and paste the contents of: `ADD-CLASS-JOIN-LINKS-TABLE.sql`
5. Click **"Run"** (or press Cmd+Enter)

### Expected Output
```
✅ class_join_links table created successfully!
📋 Next steps:
   1. Run this SQL in Supabase SQL Editor ✓
   2. Enable Realtime in Dashboard > Database > Replication
   3. Test with: SELECT * FROM get_active_class_link('all');
```

### Verify Table Creation
```sql
-- Should return table structure
SELECT * FROM class_join_links LIMIT 0;

-- Should return empty result (no links yet)
SELECT * FROM get_active_class_link('all');
```

---

## 📋 Step 2: Enable Realtime Replication

### Enable Realtime Updates

1. In Supabase Dashboard, go to: **Database** → **Replication**
2. Find the `class_join_links` table in the list
3. **Toggle ON** the switch next to it
4. Wait ~10 seconds for replication to activate

### Verify Realtime
```sql
-- Check if realtime is enabled
SELECT * FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime' 
AND tablename = 'class_join_links';
```

Expected: One row showing the table is published.

---

## 📋 Step 3: Test Admin Functionality

### Access Admin Hub
1. Log in as admin: `hrachfilm@gmail.com` or `simonamikayelyan83@gmail.com`
2. Open `admin-home.html`
3. Look for **"Post Join Class Link"** card in Quick Actions

### Test Link Creation
1. Click **"Post Join Class Link"**
2. Enter a test URL: `https://zoom.us/j/123456789`
3. Select group: **All Students**
4. Click **"🚀 Publish Link (Expires in 1 Hour)"**
5. **Expected:** Success message appears, active link badge shows

### Verify Database Entry
```sql
-- Should return your newly created link
SELECT 
  id,
  url,
  group_id,
  created_by,
  created_at,
  expires_at,
  EXTRACT(EPOCH FROM (expires_at - NOW()))::INTEGER / 60 as minutes_remaining,
  is_active
FROM class_join_links 
WHERE is_active = true 
ORDER BY created_at DESC 
LIMIT 1;
```

---

## 📋 Step 4: Test Student View

### Access Student Portal
1. Log in as a student (or use existing student account)
2. Open `Student-page.html`
3. **Expected:** Green **"✅ JOIN THE CLASS"** button appears in header
4. Button should have pulsing glow animation

### Test Button Functionality
1. Click **"✅ JOIN THE CLASS"** button
2. **Expected:** Class link opens in new tab
3. **Verify:** Link matches the URL you entered in admin

### Test Real-Time Updates
1. Keep Student Portal open
2. In another tab, open Admin Hub
3. Click **"End Now"** on active link
4. **Expected:** Student button disappears within 1-2 seconds (no page refresh needed)

---

## 📋 Step 5: Test Expiration Logic

### Test 1-Hour Auto-Expiration

**Option A: Wait 1 Hour** (full test)
1. Create a link
2. Wait 1 hour
3. **Expected:** Button disappears automatically

**Option B: Manual Time Manipulation** (quick test)
1. Create a link
2. Run SQL to set expiration to past:
```sql
UPDATE class_join_links
SET expires_at = NOW() - INTERVAL '1 minute'
WHERE is_active = true;
```
3. Wait ~30 seconds (or refresh student page)
4. **Expected:** Button disappears

### Test Manual Early Termination
1. Create a new link
2. In Admin Hub modal, click **"🛑 End Now"**
3. **Expected:** 
   - Confirmation dialog appears
   - After confirming, link ends immediately
   - Student button disappears within 1-2 seconds

---

## 🔐 Security Verification

### Test RLS Policies

**Test 1: Admin Can Insert**
```sql
-- Run as admin user (should succeed)
INSERT INTO class_join_links (url, created_by, expires_at, group_id)
VALUES (
  'https://zoom.us/j/test',
  'hrachfilm@gmail.com',
  NOW() + INTERVAL '1 hour',
  'all'
);
```

**Test 2: Students Can Only See Active Links**
```sql
-- Run as anonymous/student (should only return active, non-expired links)
SELECT * FROM class_join_links;
```

**Test 3: Students Cannot Insert**
```sql
-- Run as student user (should fail with permission error)
INSERT INTO class_join_links (url, created_by, expires_at)
VALUES ('https://fake.com', 'student@test.com', NOW() + INTERVAL '1 hour');
```

Expected: **Error: permission denied**

---

## 🎨 UI/UX Features

### Admin Side (`admin-home.html`)

**Quick Actions Card:**
- 🔗 Icon with green gradient background
- Shows "🟢 ACTIVE LINK" badge when link is live
- Clickable to open modal

**Modal Features:**
- **Active Link Display** (when link exists):
  - Green status badge with countdown timer
  - Current URL display
  - "📋 Copy Link" button
  - "🛑 End Now" button (manual termination)
  
- **New Link Form** (when no link active):
  - URL input with validation (must start with http:// or https://)
  - Group selector (All/Group A/B/C)
  - Info banner about 1-hour expiration
  - "🚀 Publish" button with gradient

**Countdown Timer:**
- Updates every second
- Format: `MM:SS remaining`
- Turns red when < 5 minutes
- Shows "EXPIRED" when time is up

### Student Side (`Student-page.html`)

**Button Appearance:**
- Large green gradient button
- Text: **"✅ JOIN THE CLASS"** (all caps)
- Pulsing glow animation
- Appears in header next to "Hub" button

**Button Behavior:**
- Only visible when active link exists
- Opens link in new tab (`noopener,noreferrer` for security)
- Disappears when link expires or is ended
- No empty space when hidden (display: none)

**Animation:**
```css
@keyframes pulseGlow {
  0%, 100% { box-shadow: 0 6px 20px rgba(34,197,94,0.4); }
  50% { box-shadow: 0 8px 32px rgba(34,197,94,0.7); }
}
```

---

## 🔧 Configuration Options

### Change Expiration Time

**Default:** 1 hour  
**Location:** `admin-home.html` line ~2913

```javascript
const expiresAt = new Date();
expiresAt.setHours(expiresAt.getHours() + 1); // Change to 2 for 2 hours
```

### Add More Groups

**Location:** `admin-home.html` line ~2890

```html
<select id="classLinkGroup">
  <option value="all">All Students</option>
  <option value="group-a">Group A</option>
  <option value="group-b">Group B</option>
  <option value="group-c">Group C</option>
  <!-- Add more groups here -->
  <option value="group-d">Group D</option>
</select>
```

### Change Polling Interval

**Default:** 30 seconds  
**Location:** `Student-page.html` line ~6265

```javascript
// Check every 30 seconds (30000ms)
linkCheckInterval = setInterval(checkForActiveClassLink, 30000);
// Change to 15000 for 15 seconds
```

---

## 🛠️ Troubleshooting

### Issue: Button Doesn't Appear for Students

**Diagnosis:**
```sql
-- Check if link exists and is active
SELECT id, url, expires_at, ended_at, is_active,
       NOW() < expires_at as is_not_expired
FROM class_join_links
WHERE is_active = true
ORDER BY created_at DESC;
```

**Possible Causes:**
1. ❌ Link already expired → Create new link
2. ❌ Link ended early → Check `ended_at` column
3. ❌ Realtime not enabled → Go to Database > Replication
4. ❌ RLS blocking students → Check policies

### Issue: Admin Can't Create Links

**Diagnosis:**
1. Check browser console for errors (F12)
2. Verify admin email in RLS policy:

```sql
-- Check if your email is allowed
SELECT * FROM pg_policies 
WHERE tablename = 'class_join_links' 
AND policyname = 'admin_insert_class_links';
```

**Fix:** Add your email to policy in `ADD-CLASS-JOIN-LINKS-TABLE.sql`

### Issue: Countdown Not Updating

**Diagnosis:**
- Open browser console (F12)
- Look for JavaScript errors

**Common Cause:** Modal closed while countdown running

**Fix:** Already handled - countdown stops when modal closes

### Issue: Button Doesn't Disappear After Expiration

**Diagnosis:**
```javascript
// Check in browser console
console.log('Active link:', activeClassLink);
console.log('Expires at:', activeClassLink?.expires_at);
console.log('Current time:', new Date().toISOString());
```

**Possible Causes:**
1. ❌ Realtime subscription failed
2. ❌ Polling interval not running
3. ❌ Time zone mismatch

**Fix:** Refresh page as temporary workaround

---

## 📊 Database Schema Reference

### Table: `class_join_links`

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key (auto-generated) |
| `url` | TEXT | Class meeting URL (Zoom/Meet/Teams) |
| `group_id` | TEXT | Target group ('all', 'group-a', etc.) |
| `created_by` | TEXT | Admin email who created link |
| `created_at` | TIMESTAMPTZ | When link was created |
| `expires_at` | TIMESTAMPTZ | When link expires (created_at + 1 hour) |
| `ended_at` | TIMESTAMPTZ | When admin ended link early (null if not ended) |
| `is_active` | BOOLEAN | Whether link is currently active |

### Helper Function: `get_active_class_link()`

```sql
-- Get active link for a group
SELECT * FROM get_active_class_link('all');
SELECT * FROM get_active_class_link('group-a');

-- Returns:
-- - id (UUID)
-- - url (TEXT)
-- - expires_at (TIMESTAMPTZ)
-- - minutes_remaining (INTEGER)
```

---

## 🚀 Production Checklist

Before deploying to production:

- [ ] Run `ADD-CLASS-JOIN-LINKS-TABLE.sql` in production Supabase
- [ ] Enable Realtime replication for `class_join_links`
- [ ] Update admin email list in RLS policies
- [ ] Test admin link creation
- [ ] Test student button visibility
- [ ] Test real-time updates (create/end link)
- [ ] Test 1-hour expiration (or set shorter time for testing)
- [ ] Test group targeting (if using groups)
- [ ] Verify security: students can't create/delete links
- [ ] Test on mobile devices (button should be visible)
- [ ] Set up monitoring for expired links cleanup

---

## 📝 Usage Instructions (For Admins)

### How to Post a Class Link

1. **Log into Admin Hub** (`admin-home.html`)
2. **Click** "Post Join Class Link" card
3. **Enter** your meeting URL:
   - Zoom: `https://zoom.us/j/123456789`
   - Google Meet: `https://meet.google.com/abc-def-ghi`
   - Microsoft Teams: Copy link from Teams
4. **Select** target group (or leave as "All Students")
5. **Click** "🚀 Publish Link"
6. **Share** with students: "Check your Student Hub!"

### How to End a Link Early

1. **Open** "Post Join Class Link" modal
2. **Click** "🛑 End Now" button
3. **Confirm** termination
4. **Result:** Button disappears from all student views immediately

### Best Practices

✅ **DO:**
- Post link 5-10 minutes before class starts
- Test the link yourself before posting
- Use "End Now" if class is cancelled
- Keep URL simple and direct (avoid redirects)

❌ **DON'T:**
- Post links hours before class (they expire in 1 hour)
- Share direct URLs via email (use the button system)
- Create multiple overlapping links (only one shows)

---

## 🆘 Support & Contact

**Issues?**
- Check browser console (F12) for error messages
- Verify Supabase connection in `js/supabase-config.js`
- Check Realtime status in Supabase Dashboard

**Feature Requests:**
- Add more expiration time options
- Support for recurring class schedules
- Student attendance tracking
- Link click analytics

---

## ✅ System Status

After completing this guide, you should have:

✅ Database table `class_join_links` created  
✅ RLS policies configured for security  
✅ Realtime replication enabled  
✅ Admin UI with modal and controls  
✅ Student Hub with green JOIN button  
✅ Real-time synchronization working  
✅ 1-hour auto-expiration functional  
✅ Manual early termination working  

**System is production-ready!** 🎉
