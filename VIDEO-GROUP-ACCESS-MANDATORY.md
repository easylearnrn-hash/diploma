# Video Library - Mandatory Group Access

## Changes Implemented

### 1. Fixed SQL Errors
- **Removed**: `RAISE NOTICE` statements that caused syntax errors
- **File**: `ADD-VIDEO-GROUP-ACCESS.sql` now runs without errors

### 2. Fixed Database Column Name
- **Corrected**: `student_groups.group_name` → `student_groups.name`
- **Schema**: The actual column is `name` (from `MIGRATE-ALL-TO-SUPABASE.sql`)
```sql
CREATE TABLE student_groups (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,  -- ← This is the correct column
  semester TEXT NOT NULL,
  student_ids TEXT[] NOT NULL DEFAULT '{}'
);
```

### 3. Made Group Selection Mandatory
**Old behavior**: 
- NULL group_access = all students can see video
- Optional group selection

**New behavior**:
- NULL or empty array = **NO ONE** can see video
- At least one group must be selected
- Form validates and prevents saving without groups

### 4. Updated RLS Policy
```sql
-- Old: is_published = true (all students see all published videos)
-- New: Must have group_access AND not empty
CREATE POLICY "Students can view published videos (anon)"
    ON public.video_library
    FOR SELECT
    USING (
        is_published = true
        AND group_access IS NOT NULL 
        AND group_access != '{}'
    );
```

### 5. Updated Admin UI

**Form Label**:
```html
<label>Group Access <span style="color:red;">*</span> (Required)</label>
```

**Warning Message**:
```
⚠️ Select at least one group - videos with no groups selected will not be visible to anyone
```

**Validation**:
```javascript
if (selectedGroups.length === 0) {
  showToast('⚠️ Group selection is mandatory! Select at least one group.', 'error');
  return;
}
```

**Table Display**:
- Shows "X group(s)" when groups selected
- Shows "⚠️ No Groups (Hidden)" in red when NULL (shouldn't happen now)

## Deployment Steps

### Step 1: Run SQL Migration
```bash
# Open Supabase SQL Editor
# https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql

# Run: ADD-VIDEO-GROUP-ACCESS.sql
```

The SQL will:
1. Add `group_access TEXT[]` column to `video_library` table
2. Update RLS policy to require group_access
3. Verify the column exists

### Step 2: Refresh Admin Page
```bash
# Hard refresh admin-video-library.html
# Mac: Cmd + Shift + R
# Windows: Ctrl + Shift + R
```

### Step 3: Test Mandatory Selection
1. Click "Add Video"
2. Fill in title, description, Drive URL
3. **Try to save without selecting groups** → Should show error
4. Select at least one group → Should save successfully
5. Verify table shows "1 group(s)" or "2 group(s)"

## Student Groups Table

The system dynamically loads groups from `student_groups` table:

```sql
SELECT name FROM student_groups ORDER BY name;
```

**To add new groups**, insert into `student_groups`:
```sql
INSERT INTO student_groups (id, name, semester, student_ids)
VALUES 
  ('2026-2027', '2026-2027', 'Fall 2026', ARRAY[]::TEXT[]),
  ('LPN-Track', 'LPN Track', 'All Semesters', ARRAY[]::TEXT[]);
```

**Groups automatically appear** in admin UI checkboxes on next page load.

## Validation Rules

| Scenario | Allowed? | Message |
|----------|----------|---------|
| No groups selected | ❌ No | "Group selection is mandatory!" |
| 1 group selected | ✅ Yes | Saves with `group_access = ['GroupName']` |
| Multiple groups | ✅ Yes | Saves with `group_access = ['Group1', 'Group2']` |
| NULL in database | ⚠️ Hidden | Video not visible to anyone |

## Migration Notes

**Existing videos** in database:
- Have `group_access = NULL` by default
- Are now **hidden** from all students
- **Action required**: Admin must edit each video and select groups

**Script to check hidden videos**:
```sql
SELECT id, title, is_published, group_access 
FROM video_library 
WHERE (group_access IS NULL OR group_access = '{}')
AND is_published = true;
```

**Bulk update example** (assign all videos to one group):
```sql
UPDATE video_library 
SET group_access = ARRAY['2024-2025']
WHERE group_access IS NULL;
```

## Technical Details

### JavaScript Changes
1. **loadGroups()**: Changed `group_name` → `name`
2. **saveVideo()**: Added mandatory validation
3. **renderGroupCheckboxes()**: Unchanged (uses allGroups array)

### Database Schema
```sql
ALTER TABLE video_library 
ADD COLUMN group_access TEXT[] DEFAULT NULL;
```

### RLS Logic
```sql
-- Students only see videos where:
-- 1. Video is published
-- 2. group_access is not NULL
-- 3. group_access is not empty array
-- 4. Their group_name exists in video's group_access array (future with auth)
```

## FAQ

**Q: Can I make a video visible to all groups?**  
A: Yes, check all group checkboxes when adding/editing the video.

**Q: What happens if I delete a group from student_groups?**  
A: Videos with that group in group_access will still work. The group name is stored as a string array in the video record.

**Q: Can groups be added/removed dynamically?**  
A: Yes! The admin UI loads groups from `student_groups` table on every page load. Add new groups via SQL INSERT and they appear immediately.

**Q: What if no groups exist in student_groups table?**  
A: The form will show "Loading groups..." and no checkboxes. Admin cannot save videos. Must create groups first.

**Q: How do I create the first groups?**  
A: Run this SQL in Supabase:
```sql
INSERT INTO student_groups (id, name, semester, student_ids) VALUES
  ('2024-2025', '2024-2025', 'Academic Year 2024-2025', ARRAY[]::TEXT[]),
  ('2025-2026', '2025-2026', 'Academic Year 2025-2026', ARRAY[]::TEXT[]),
  ('2026-2027', '2026-2027', 'Academic Year 2026-2027', ARRAY[]::TEXT[]);
```

## Troubleshooting

### Error: "column student_groups.group_name does not exist"
**Solution**: Already fixed. Changed to `student_groups.name`.

### Error: "syntax error at or near 'RAISE'"
**Solution**: Already fixed. Removed RAISE NOTICE statements from SQL.

### No checkboxes showing in form
**Cause**: `student_groups` table empty or doesn't exist  
**Solution**: Check table exists and has records:
```sql
SELECT * FROM student_groups;
```

### Video saved but not visible to students
**Cause**: RLS policy requires group_access not NULL  
**Solution**: Edit video and select at least one group

### Form doesn't prevent saving without groups
**Cause**: JavaScript validation not working  
**Solution**: Check browser console for errors, ensure saveVideo() function updated

## Summary

✅ **Fixed**: SQL syntax errors  
✅ **Fixed**: Column name (`group_name` → `name`)  
✅ **Changed**: Group selection now **mandatory**  
✅ **Changed**: NULL group_access = **hidden from everyone**  
✅ **Added**: Form validation prevents saving without groups  
✅ **Added**: Clear warning messages in UI  
✅ **Dynamic**: Groups loaded from `student_groups` table

**Deploy now**: Run `ADD-VIDEO-GROUP-ACCESS.sql` in Supabase!
