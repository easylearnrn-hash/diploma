# SQL Execution Order - Testing Platform Setup

## Quick Start: Run These Files in Supabase SQL Editor

### Step 1: Create Subject/Topic Structure
**File:** `ADD-SUBJECTS-TOPICS-TABLE.sql`

1. Open [Supabase SQL Editor](https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/sql/new)
2. Copy entire contents of `ADD-SUBJECTS-TOPICS-TABLE.sql`
3. Paste and click **Run**
4. **Expected result:** "Success. No rows returned"

**What this does:**
- Creates `test_subjects` table (if doesn't exist)
- Creates `test_topics` table (if doesn't exist)
- Adds `topic_id` column to `test_questions` (if doesn't exist)
- Adds `subject_id` to `test_configs` (if doesn't exist)
- Creates indexes for performance
- Sets up RLS policies for anonymous access
- Inserts "Fundamentals of Nursing" subject with 11 topics:
  - Infection Control
  - Vital Signs
  - Physical Assessment
  - Documentation
  - Ethics & Legal
  - Communication
  - Positioning & Mobility
  - Medication Administration
  - Sterile Technique
  - IV Therapy & Blood
  - Safety & Fall Prevention

---

### Step 2: Insert 50 Fundamentals Questions
**File:** `ADD-FUNDAMENTALS-50-QUESTIONS.sql`

1. After Step 1 completes successfully
2. Copy entire contents of `ADD-FUNDAMENTALS-50-QUESTIONS.sql`
3. Paste and click **Run**
4. **Expected result:** "Success. No rows returned" (50 INSERT statements)

**What this does:**
- Deletes any existing Fundamentals questions (prevents duplicates)
- Inserts 50 NCLEX-style questions across 11 topics
- Each question linked to topic via `topic_id`

---

### Step 3: Verify Installation

Run this query to check everything worked:

```sql
-- Count total questions
SELECT COUNT(*) as total_questions 
FROM test_questions 
WHERE test_id = '00000000-0000-0000-0000-000000000001';
-- Expected: 50

-- Count questions per topic
SELECT 
  t.name as topic_name,
  COUNT(q.id) as question_count
FROM test_questions q
JOIN test_topics t ON q.topic_id = t.id
WHERE q.test_id = '00000000-0000-0000-0000-000000000001'
GROUP BY t.id, t.name
ORDER BY t.display_order;
-- Expected: 11 rows with counts (5, 5, 7, 3, 9, 5, 5, 4, 2, 3, 2)

-- View all subjects
SELECT * FROM test_subjects ORDER BY display_order;
-- Expected: 1 row (Fundamentals of Nursing)

-- View all topics for Fundamentals
SELECT * FROM test_topics 
WHERE subject_id = '10000000-0000-0000-0000-000000000001'
ORDER BY display_order;
-- Expected: 11 rows
```

---

## Troubleshooting

### Error: "syntax error at or near 'NOT'"
**Solution:** You may have an old version of the SQL file. Make sure you're using the latest version where policies use:
```sql
DROP POLICY IF EXISTS policy_name ON table_name;
CREATE POLICY policy_name ...
```

### Error: "column 'topic_id' does not exist"
**Solution:** You skipped Step 1. Run `ADD-SUBJECTS-TOPICS-TABLE.sql` first.

### Error: "relation 'test_subjects' does not exist"
**Solution:** Run Step 1 first. The tables must be created before inserting data.

### Error: "duplicate key value violates unique constraint"
**Solution:** Questions already exist. The DELETE statement at the top of Step 2 should handle this. If error persists:
```sql
DELETE FROM test_questions WHERE test_id = '00000000-0000-0000-0000-000000000001';
```
Then run Step 2 again.

---

## What's Next?

After successful installation:

1. **Test in Browser:** Open `test.html?test_id=00000000-0000-0000-0000-000000000001`
2. **Add More Subjects:** See `DYNAMIC-SUBJECTS-SETUP.md` for instructions
3. **Customize:** Modify test_configs to change duration, passing score, etc.

---

## System Architecture

```
test_subjects (Fundamentals of Nursing)
    ↓ (1-to-many)
test_topics (Infection Control, Vital Signs, etc.)
    ↓ (1-to-many)
test_questions (50 NCLEX questions)
    ↓ (belongs-to)
test_configs (test settings)
```

**Dynamic Loading:** Students select subject → filter by topic → questions loaded from database

**No Hardcoding:** All subjects, topics, and questions managed from Supabase

---

## Quick Commands (if needed)

### Delete everything and start fresh:
```sql
DELETE FROM test_questions WHERE test_id = '00000000-0000-0000-0000-000000000001';
DELETE FROM test_topics WHERE subject_id = '10000000-0000-0000-0000-000000000001';
DELETE FROM test_subjects WHERE id = '10000000-0000-0000-0000-000000000001';
```

### Check what exists:
```sql
SELECT 'Subjects' as type, COUNT(*) as count FROM test_subjects
UNION ALL
SELECT 'Topics', COUNT(*) FROM test_topics
UNION ALL
SELECT 'Questions', COUNT(*) FROM test_questions WHERE test_id = '00000000-0000-0000-0000-000000000001';
```
