# 🚀 Video Library - Group Access Deployment Guide

## ✅ All Issues Fixed

1. ✅ **SQL Syntax Error**: Removed `RAISE NOTICE` statements
2. ✅ **Wrong Column Name**: Changed `group_name` → `name` (matches `student_groups.name`)
3. ✅ **Made Mandatory**: Group selection is now required, not optional
4. ✅ **Updated RLS**: Videos without groups are hidden from everyone

---

## 📋 Deployment Steps (Run in Order)

### Step 1: Deploy Group Access Column
```bash
# Open Supabase SQL Editor:
# https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql

# Copy and run: ADD-VIDEO-GROUP-ACCESS.sql
```

**What it does:**
- Adds `group_access TEXT[]` column to `video_library` table
- Updates RLS policy to require groups (NULL = hidden)
- Verifies column exists

**Expected output:**
```
✓ Column added
✓ RLS policy updated
✓ Verification query shows group_access column
```

---

### Step 2: Create Initial Student Groups
```bash
# In same Supabase SQL Editor
# Copy and run: CREATE-INITIAL-STUDENT-GROUPS.sql
```

**What it does:**
- Creates 5 default groups:
  - `2024-2025` (Academic Year 2024-2025)
  - `2025-2026` (Academic Year 2025-2026)
  - `2026-2027` (Academic Year 2026-2027)
  - `RN-Track` (RN Track)
  - `LPN-Track` (LPN Track)

**Expected output:**
```
✓ 5 rows inserted
✓ Verification shows groups with names and semesters
```

---

### Step 3: Refresh Admin Page
```bash
# Open admin-video-library.html
# Hard refresh: Cmd + Shift + R (Mac) or Ctrl + Shift + R (Windows)
```

**What to verify:**
1. Page loads without errors
2. Click "Add Video"
3. See "Group Access * (Required)" section
4. See 5 checkboxes with group names
5. Warning message: "⚠️ Select at least one group..."

---

### Step 4: Test Mandatory Validation
```bash
# In admin-video-library.html:
```

**Test Case 1: Try to save without groups**
1. Click "Add Video"
2. Fill in:
   - Title: "Test Video"
   - Description: "Testing mandatory groups"
   - Drive URL: `https://drive.google.com/file/d/1ABC123/view`
   - Category: "Nursing Skills/Fundamentals"
3. **Leave all group checkboxes UNCHECKED**
4. Click "Save Video"

**Expected**: ❌ Error toast: "⚠️ Group selection is mandatory! Select at least one group."

---

**Test Case 2: Save with one group**
1. Same form as above
2. **Check one group**: `2024-2025`
3. Click "Save Video"

**Expected**: ✅ Success toast: "Video added successfully"

---

**Test Case 3: Verify table display**
1. Find saved video in table
2. Check "Group Access" column

**Expected**: Shows "1 group(s)" (hover to see "2024-2025")

---

### Step 5: Test Multi-Group Selection
```bash
# Add another video:
```

1. Click "Add Video"
2. Fill in details
3. **Check multiple groups**: `2024-2025`, `2025-2026`, `RN-Track`
4. Click "Save Video"

**Expected**: 
- ✅ Saves successfully
- Table shows "3 group(s)" 
- Hover shows "2024-2025, 2025-2026, RN-Track"

---

### Step 6: Edit Existing Video
```bash
# Test editing:
```

1. Click Edit (pencil icon) on any video
2. Modal opens with form
3. **Verify**: Checkboxes reflect saved groups (previously selected groups are checked)
4. Uncheck one group
5. Save

**Expected**: 
- ✅ Updates successfully
- Table shows new group count

---

## 🎯 Current Business Logic

### Group Selection Rules
| Scenario | Result |
|----------|--------|
| No groups selected | ❌ **Cannot save** - Form validation prevents it |
| 1 group selected | ✅ Saves with `group_access = ['GroupName']` |
| Multiple groups | ✅ Saves with `group_access = ['Group1', 'Group2', ...]` |
| NULL in database | ⚠️ **Hidden from everyone** (legacy videos) |

### Student Visibility (RLS Enforced)
```sql
-- Students can only see videos where:
is_published = true 
AND group_access IS NOT NULL 
AND group_access != '{}'
```

**Currently**: All students with `anon` key see all published videos with groups  
**Future**: With proper auth, filter by student's group:
```sql
AND students.group_name = ANY(video_library.group_access)
```

---

## 🔧 Adding New Groups Dynamically

Groups are **dynamically loaded** from `student_groups` table on every page load.

### Add New Group via SQL:
```sql
INSERT INTO student_groups (id, name, semester, student_ids)
VALUES ('2027-2028', '2027-2028', 'Academic Year 2027-2028', ARRAY[]::TEXT[]);
```

### Add New Group via Admin UI (Future Enhancement):
- Create `admin-student-groups.html` page
- CRUD interface for managing groups
- Auto-refreshes video library form

---

## 🐛 Troubleshooting

### Problem: No checkboxes appear in form
**Cause**: `student_groups` table empty or doesn't exist  
**Solution**: Run `CREATE-INITIAL-STUDENT-GROUPS.sql`

---

### Problem: Form allows saving without groups
**Cause**: JavaScript validation not running  
**Check**: Browser console for errors  
**Solution**: Hard refresh (Cmd+Shift+R), clear cache

---

### Problem: Videos not showing in student hub
**Cause**: `group_access` is NULL or empty  
**Solution**: Edit video and select at least one group

---

### Problem: "column group_name does not exist" error
**Cause**: Fixed! Was using wrong column name  
**Confirm**: Check `loadGroups()` function uses `.select('name')` not `group_name`

---

## 📊 Verify Deployment Success

Run these SQL queries to confirm everything is working:

```sql
-- 1. Verify group_access column exists
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'video_library' AND column_name = 'group_access';
-- Expected: 1 row (group_access | ARRAY)

-- 2. Check student groups exist
SELECT COUNT(*) FROM student_groups;
-- Expected: 5 (or more if you added custom groups)

-- 3. Find videos with groups assigned
SELECT title, array_length(group_access, 1) as group_count, is_published
FROM video_library 
WHERE group_access IS NOT NULL;
-- Expected: Your test videos with group counts

-- 4. Find hidden videos (need group assignment)
SELECT id, title, is_published 
FROM video_library 
WHERE group_access IS NULL OR group_access = '{}';
-- Expected: Empty (or legacy videos that need editing)

-- 5. Test student visibility (anon key simulation)
SELECT title, category, group_access 
FROM video_library 
WHERE is_published = true 
  AND group_access IS NOT NULL 
  AND group_access != '{}';
-- Expected: Only published videos with groups
```

---

## 📝 Migration Notes for Existing Videos

If you have **existing videos** in the database (from before this update):

### Check for legacy videos:
```sql
SELECT id, title, is_published, group_access 
FROM video_library 
WHERE group_access IS NULL;
```

### Fix Option 1: Bulk assign to one group
```sql
UPDATE video_library 
SET group_access = ARRAY['2024-2025']
WHERE group_access IS NULL;
```

### Fix Option 2: Assign different groups by category
```sql
-- First-year content
UPDATE video_library 
SET group_access = ARRAY['2024-2025', '2025-2026', '2026-2027']
WHERE category IN ('Nursing Skills/Fundamentals', 'Medical Terminology', 'Human Anatomy')
AND group_access IS NULL;

-- Advanced content
UPDATE video_library 
SET group_access = ARRAY['2025-2026', '2026-2027']
WHERE category IN ('Pharmacology', 'Medical-Surgical Care')
AND group_access IS NULL;

-- Track-specific
UPDATE video_library 
SET group_access = ARRAY['RN-Track']
WHERE category = 'Mental Health'
AND group_access IS NULL;
```

### Fix Option 3: Edit manually via admin UI
1. Go to admin-video-library.html
2. For each video showing "⚠️ No Groups (Hidden)"
3. Click Edit → Select appropriate groups → Save

---

## 🎉 Success Checklist

- [ ] SQL migrations run without errors
- [ ] 5+ student groups exist in database
- [ ] Admin page loads and shows group checkboxes
- [ ] Cannot save video without selecting groups
- [ ] Can save video with 1 group
- [ ] Can save video with multiple groups
- [ ] Table displays group count correctly
- [ ] Edit modal shows previously selected groups
- [ ] No videos have NULL group_access (all assigned to groups)
- [ ] Published videos with groups visible to students

---

## 🚀 You're Ready!

All code changes deployed:
- ✅ `ADD-VIDEO-GROUP-ACCESS.sql` (fixed syntax errors)
- ✅ `admin-video-library.html` (mandatory validation, correct column name)
- ✅ `CREATE-INITIAL-STUDENT-GROUPS.sql` (initial group data)

**Next**: Run Step 1 and Step 2 in Supabase SQL Editor!

**Documentation**:
- Full details: `VIDEO-GROUP-ACCESS-MANDATORY.md`
- Original guide: `VIDEO-GROUP-ACCESS-GUIDE.md` (now outdated - use new guide)
