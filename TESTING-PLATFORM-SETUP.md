# ACNHS Testing Platform - Supabase Integration Setup

## 📋 Overview
The testing platform now stores questions, test configurations, and student attempts in Supabase instead of hardcoded data.

## 🗄️ Database Structure

### Tables Created:
1. **test_configs** - Test metadata and settings
2. **test_questions** - Individual questions with options
3. **test_attempts** - Student submission records

## 🚀 Setup Instructions

### Step 1: Run SQL Schema
1. Open Supabase Dashboard: https://supabase.com/dashboard
2. Go to your project: `eyhksbiceueoiamwnqpr`
3. Click **SQL Editor** in left sidebar
4. Copy entire contents of `CREATE-TEST-TABLES.sql`
5. Paste and click **Run**
6. Verify success - you should see "Success. No rows returned"

### Step 2: Verify Data
Run these queries in SQL Editor to confirm:

```sql
-- Check test config
SELECT * FROM test_configs;

-- Check questions count (should be 10)
SELECT COUNT(*) FROM test_questions;

-- View all questions
SELECT display_order, question_stem, category 
FROM test_questions 
ORDER BY display_order;
```

### Step 3: Test the Platform
1. Open `test.html` in browser
2. URL format: `test.html?test_id=00000000-0000-0000-0000-000000000001`
3. Click "Start Test"
4. Questions should load from database

## 🔧 Configuration Options

### Test Configuration Fields (`test_configs` table):
```javascript
{
  title: "Test Name",
  duration_minutes: 60,
  shuffle_questions: true,
  shuffle_options: true,
  show_back_button: true,
  allow_review: true,
  passing_score_percent: 70,
  is_active: true,
  category: "Midterm",
  semester: "Semester 1"
}
```

### Question Format (`test_questions` table):
```javascript
{
  question_stem: "Question text?",
  options: [
    {"id": "a", "text": "Option A"},
    {"id": "b", "text": "Option B"}
  ],
  correct_answers: ["a"], // Array supports multiple correct answers
  is_multiple_choice: false, // false = radio, true = checkboxes
  rationale: "Explanation text",
  category: "Category Name",
  display_order: 1
}
```

## ✏️ Adding New Questions

### Method 1: SQL Insert
```sql
INSERT INTO test_questions (
  test_id, 
  question_stem, 
  options, 
  correct_answers, 
  is_multiple_choice, 
  rationale, 
  category, 
  display_order
) VALUES (
  '00000000-0000-0000-0000-000000000001',
  'Your question text here?',
  '[
    {"id": "a", "text": "First option"},
    {"id": "b", "text": "Second option"},
    {"id": "c", "text": "Third option"},
    {"id": "d", "text": "Fourth option"}
  ]'::jsonb,
  ARRAY['b'], -- Correct answer(s)
  false, -- Single choice
  'Explanation of correct answer',
  'Assessment',
  11 -- Order number
);
```

### Method 2: Supabase Table Editor
1. Go to **Table Editor** → **test_questions**
2. Click **Insert** → **Insert row**
3. Fill in fields (options and correct_answers are JSON)
4. Click **Save**

## 🎯 Creating New Tests

```sql
-- 1. Create test configuration
INSERT INTO test_configs (
  id,
  title, 
  description, 
  duration_minutes, 
  passing_score_percent,
  category,
  semester
) VALUES (
  gen_random_uuid(), -- Auto-generate UUID
  'Quiz 1 - Patient Assessment',
  'Short quiz on vital signs and patient assessment',
  30,
  75,
  'Quiz',
  'Semester 1'
) RETURNING id;

-- 2. Use returned ID to add questions
-- Copy the UUID from previous query and use it as test_id
INSERT INTO test_questions (test_id, ...) VALUES (...);
```

## 📊 Viewing Student Results

```sql
-- View all attempts for a test
SELECT 
  ta.completed_at,
  ta.student_id,
  ta.score_percent,
  ta.passed,
  ta.time_taken_seconds,
  ta.correct_count,
  ta.total_questions
FROM test_attempts ta
WHERE ta.test_id = '00000000-0000-0000-0000-000000000001'
ORDER BY ta.completed_at DESC;

-- View detailed answers for a specific attempt
SELECT 
  ta.student_id,
  ta.score_percent,
  ta.answers
FROM test_attempts ta
WHERE ta.session_id = 'test_1739595600000_abc123xyz';

-- Calculate average score for a test
SELECT 
  AVG(score_percent) as avg_score,
  COUNT(*) as total_attempts,
  COUNT(CASE WHEN passed = true THEN 1 END) as passed_count
FROM test_attempts
WHERE test_id = '00000000-0000-0000-0000-000000000001';
```

## 🔐 Security Notes

### Current RLS Policies:
- ✅ Anonymous users can VIEW active tests and questions
- ✅ Anonymous users can INSERT test attempts
- ✅ All users can view test attempts (modify based on your auth)

### Recommended for Production:
```sql
-- Only allow authenticated students to submit
DROP POLICY "Anyone can submit test attempts" ON test_attempts;

CREATE POLICY "Authenticated users submit attempts"
  ON test_attempts FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- Students see only their own attempts
DROP POLICY "Users can view own test attempts" ON test_attempts;

CREATE POLICY "Users view own attempts only"
  ON test_attempts FOR SELECT
  USING (student_id = auth.uid()::text);
```

## 🔗 URL Parameters

### Required:
- `test_id` - UUID of test from test_configs table

### Optional:
- `student_id` - Student identifier (defaults to 'guest')

### Example URLs:
```
test.html?test_id=00000000-0000-0000-0000-000000000001
test.html?test_id=00000000-0000-0000-0000-000000000001&student_id=ACNHS-0001234
```

## 🐛 Troubleshooting

### "Cannot connect to database"
- Check Supabase credentials in `js/supabase-config.js`
- Verify Supabase CDN script is loading
- Check browser console for errors

### "No questions found"
- Verify test_id exists: `SELECT * FROM test_configs WHERE id = 'your-id';`
- Check questions exist: `SELECT COUNT(*) FROM test_questions WHERE test_id = 'your-id';`
- Ensure `is_active = true` on both tables

### Questions not shuffling
- Check `shuffle_questions` and `shuffle_options` in test_configs
- Clear localStorage: `localStorage.clear()`

### Can't submit test
- Check browser console for errors
- Verify RLS policies allow INSERT on test_attempts
- Check network tab for failed requests

## 📱 Integration with Student Portal

To integrate with your student dashboard:

```html
<!-- In student portal -->
<a href="test.html?test_id=00000000-0000-0000-0000-000000000001&student_id=<?= $student_id ?>" 
   class="btn btn-primary">
  Take Midterm Exam
</a>
```

## 🎨 Customization

### Change Default Test ID
Edit in `test.html` line ~1110:
```javascript
const testId = urlParams.get('test_id') || 'YOUR-DEFAULT-TEST-ID';
```

### Disable Anonymous Access
```sql
-- Require authentication
DROP POLICY "Anyone can view active test configs" ON test_configs;

CREATE POLICY "Authenticated view test configs"
  ON test_configs FOR SELECT
  USING (auth.uid() IS NOT NULL AND is_active = true);
```

## 📈 Next Steps

1. ✅ Run SQL schema
2. ✅ Verify sample data loaded
3. ✅ Test the platform with sample test
4. 📝 Add your own questions
5. 🔗 Integrate with student portal
6. 🔐 Implement proper authentication
7. 📊 Create admin dashboard for managing tests

---

**Need Help?** Check Supabase docs: https://supabase.com/docs
