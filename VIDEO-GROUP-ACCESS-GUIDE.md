# Video Library Group Access Control - Setup Guide

## 🎯 Feature Overview

Added group access control to the video library system, allowing admins to restrict specific videos to certain student groups.

## 📦 What's Been Added

### 1. Database Changes
**File:** `ADD-VIDEO-GROUP-ACCESS.sql`

- Added `group_access` column (TEXT[] array) to `video_library` table
- Updated RLS policy to check group membership
- NULL or empty array = all groups can access
- Specific groups = only those groups can view

### 2. Admin Interface Updates
**File:** `admin-video-library.html`

**New Features:**
- ✅ Group selection checkboxes in Add/Edit video modal
- ✅ Loads all student groups from `student_groups` table
- ✅ Shows group access in video list ("All Groups" or "X group(s)")
- ✅ Saves selected groups as array in database

**UI Changes:**
- Added "Group Access (optional)" section in video form
- Added "Group Access" column in video table
- Checkboxes auto-populate from database

## 🚀 Deployment Steps

### Step 1: Run Database Migration
1. Open Supabase SQL Editor
2. Copy and paste contents of `ADD-VIDEO-GROUP-ACCESS.sql`
3. Execute the SQL
4. Verify: `SELECT column_name FROM information_schema.columns WHERE table_name = 'video_library' AND column_name = 'group_access';`

### Step 2: Refresh Admin Page
1. Open `admin-video-library.html` in browser
2. Hard refresh (Cmd+Shift+R on Mac, Ctrl+Shift+R on Windows)
3. You should now see group checkboxes when adding/editing videos

## 📖 How to Use

### For Admins:

**Adding a Video with Group Restriction:**
1. Click "Add Video" in admin-video-library.html
2. Fill in title, Drive link, category, etc.
3. In "Group Access" section, check the groups that should access this video
4. Leave all unchecked to allow ALL groups
5. Click "Save Video"

**Viewing Group Access:**
- Video table now shows "All Groups" or "3 group(s)" in the Group Access column
- Hover over "X group(s)" to see tooltip with group names

**Editing Group Access:**
1. Click edit button on any video
2. Group checkboxes will show current selection
3. Check/uncheck as needed
4. Save changes

### For Students:

**Automatic Filtering:**
- Students only see videos published to their group (or all groups)
- No UI changes needed - filtering happens server-side via RLS
- Students in "2024-2025" group won't see "2025-2026" exclusive videos

## 🔧 Technical Details

### Database Schema
```sql
ALTER TABLE video_library 
ADD COLUMN group_access TEXT[] DEFAULT NULL;
```

### RLS Policy Logic
```sql
-- Students can view if:
-- 1. Video is published AND
-- 2. (group_access is NULL OR empty OR contains student's group)
```

### JavaScript Functions Added
- `loadGroups()` - Fetches all groups from database
- `renderGroupCheckboxes(selectedGroups)` - Renders checkbox list
- Group selection saved in `saveVideo()` function

## 🧪 Testing Checklist

### Database Test:
```sql
-- Add test video with group restriction
INSERT INTO video_library (title, drive_url, embed_url, category, is_published, group_access)
VALUES ('Test Video', 'https://drive.google.com/file/d/ABC/view', 
        'https://drive.google.com/file/d/ABC/preview', 
        'Pharmacology', true, ARRAY['2024-2025']);

-- Verify
SELECT title, group_access, is_published FROM video_library;
```

### Admin Test:
1. ✅ Open admin-video-library.html
2. ✅ Click "Add Video"
3. ✅ Verify group checkboxes appear with all groups
4. ✅ Select 2 groups
5. ✅ Save video
6. ✅ Verify table shows "2 group(s)"
7. ✅ Edit video
8. ✅ Verify selected groups are checked
9. ✅ Uncheck all groups
10. ✅ Save
11. ✅ Verify shows "All Groups"

### Student Test:
1. ✅ Log in as student in "2024-2025" group
2. ✅ Navigate to Video Library
3. ✅ Should see:
   - Videos with no group restriction (group_access = NULL)
   - Videos restricted to "2024-2025"
4. ✅ Should NOT see:
   - Videos restricted to other groups only

## 📊 Database Query Examples

### Find videos accessible to specific group:
```sql
SELECT title, group_access 
FROM video_library 
WHERE is_published = true 
AND (group_access IS NULL OR '2024-2025' = ANY(group_access));
```

### Find videos restricted to specific groups only:
```sql
SELECT title, group_access 
FROM video_library 
WHERE group_access IS NOT NULL AND array_length(group_access, 1) > 0;
```

### Count videos per access type:
```sql
SELECT 
  CASE 
    WHEN group_access IS NULL THEN 'All Groups'
    ELSE 'Restricted'
  END as access_type,
  COUNT(*) as video_count
FROM video_library
WHERE is_published = true
GROUP BY access_type;
```

## 🔒 Security Notes

### RLS Protection:
- Students cannot bypass group restrictions (enforced at database level)
- RLS policies automatically filter based on student's group in `students` table
- Admin can view all videos regardless of group restrictions

### Current Implementation:
- Using anon key for testing (policy allows all published videos)
- **Production:** Replace with proper authentication
- **Production:** Update RLS policy to use `auth.uid()` for real user IDs

## 🎯 Use Cases

### 1. Year-Specific Content
- Restrict advanced content to senior cohorts
- Basic fundamentals for first-year students only

### 2. Program-Specific Videos
- RN program vs LPN program specific content
- Specialty track videos (Critical Care, Pediatrics, etc.)

### 3. Remediation Videos
- Videos for students needing additional support
- Restrict to specific remediation groups

### 4. Cohort-Based Learning
- Different teaching methods per cohort
- Sequential content release by group

## 📝 Example Workflows

### Scenario 1: New Video for All Groups
```
1. Admin adds video
2. Leaves all group checkboxes unchecked
3. Checks "Publish immediately"
4. Saves
Result: All students see the video
```

### Scenario 2: Advanced Content for Seniors Only
```
1. Admin adds video
2. Checks only "2024-2025" (senior cohort)
3. Checks "Publish immediately"
4. Saves
Result: Only 2024-2025 students see video
```

### Scenario 3: Multi-Group Access
```
1. Admin adds video
2. Checks "2024-2025" AND "2023-2024"
3. Checks "Publish immediately"
4. Saves
Result: Both groups see video, but not 2025-2026
```

## 🐛 Troubleshooting

### Groups not appearing in checkboxes:
- Check `student_groups` table exists and has data
- Console error? Check browser dev tools
- Refresh page to reload groups

### Students seeing wrong videos:
- Verify student's `group_name` in `students` table
- Check video's `group_access` array
- Confirm video is published (`is_published = true`)

### "All Groups" not working:
- Ensure `group_access` is NULL (not empty array)
- Empty array `[]` means NO groups (different from NULL)

### RLS blocking access:
- Check RLS policies on `video_library` table
- Verify anon policy exists for testing
- Production: Ensure authenticated policy uses correct user ID

## 🚀 Future Enhancements

- **Bulk update**: Select multiple videos, change group access at once
- **Smart suggestions**: "Videos similar to this are restricted to X groups"
- **Group analytics**: Which groups watch which categories most
- **Scheduled access**: "Available to Group A starting March 1"
- **Prerequisite chains**: "Must complete Video X before accessing Video Y"

---

**Last Updated:** February 18, 2026  
**Status:** ✅ Ready for Testing  
**Dependencies:** `student_groups` table, `video_library` table
