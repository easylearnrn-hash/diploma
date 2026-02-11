# Notes Publishing System - Supabase Setup

## ⚡ Quick Start

### 1. Run SQL in Supabase SQL Editor
Execute the SQL in `CREATE-PUBLISHED-NOTES-TABLE.sql`

### 2. That's it!
The system is now ready to use.

## 📊 How It Works

### Database Schema
```
published_notes
├── id (UUID, primary key)
├── note_id (TEXT) - matches note file name
├── student_id (UUID) - foreign key to students.id
├── published_at (timestamp)
├── published_by (TEXT) - admin email
└── created_at (timestamp)
```

### Admin Hub Workflow
1. Go to **Admin Hub** → **📝 Notes Library**
2. Click **📤 Publish** on any note
3. Select students from the list
4. Click **✓ Publish to Selected Students**
5. System saves to `published_notes` table in Supabase

### Student Hub Workflow
1. Student opens their hub
2. Goes to **Notes Library**
3. System queries: `SELECT note_id FROM published_notes WHERE student_id = current_user_id`
4. Shows only notes published to that student
5. Categories show count of accessible notes only

## 🔄 Data Flow

### Publishing a Note
```javascript
// Admin clicks Publish → System runs:
db.from('published_notes')
  .insert([
    { note_id: 'note_1', student_id: 'uuid-1', published_by: 'admin@acnhs.am' },
    { note_id: 'note_1', student_id: 'uuid-2', published_by: 'admin@acnhs.am' }
  ])
```

### Student Viewing Notes
```javascript
// Student opens Notes Library → System runs:
const { data } = await db
  .from('published_notes')
  .select('note_id')
  .eq('student_id', studentData.id)

// Only shows notes where note_id is in returned data
```

### Unpublishing
```javascript
// Admin clicks Unpublish → System runs:
db.from('published_notes')
  .delete()
  .eq('note_id', 'note_1') // Removes from ALL students
```

## 🎯 Key Features

✅ **No localStorage** - Everything stored in Supabase  
✅ **Per-student access control** - Each student sees only their notes  
✅ **Real-time sync** - Changes appear immediately  
✅ **Admin tracking** - Records who published each note  
✅ **Bulk operations** - Unpublish multiple notes at once  
✅ **Foreign key constraints** - Auto-deletes if student removed  

## 🔍 Debugging

### Check what notes a student has access to:
```sql
SELECT n.note_id, n.published_at, n.published_by
FROM published_notes n
WHERE n.student_id = 'STUDENT_UUID_HERE';
```

### Check which students have access to a specific note:
```sql
SELECT s.full_name, s.student_id, s.email, pn.published_at
FROM published_notes pn
JOIN students s ON pn.student_id = s.id
WHERE pn.note_id = 'note_1';
```

### Count notes per student:
```sql
SELECT s.full_name, s.student_id, COUNT(pn.note_id) as note_count
FROM students s
LEFT JOIN published_notes pn ON s.id = pn.student_id
WHERE s.enrollment_status = 'active'
GROUP BY s.id, s.full_name, s.student_id
ORDER BY note_count DESC;
```

## 🚨 Common Issues

**Issue:** Student sees "No notes found"  
**Fix:** Check if any notes are published to their student_id in the database

**Issue:** Notes show in admin but not student  
**Fix:** Verify `studentData.id` matches the UUID in `published_notes.student_id`

**Issue:** Publish button doesn't work  
**Fix:** Check browser console for Supabase errors, verify RLS policies allow insert

## 📝 Note IDs
Each note has an ID matching its entry in `HARDCODED_NOTES` array:
- `note_1` = Fundamentals of Nursing
- `note_2` = Nurse's Role in Informed Consent
- `note_3` = Scope of Practice
- ...and so on (29 total notes)

These IDs are stored in `published_notes.note_id` column.
