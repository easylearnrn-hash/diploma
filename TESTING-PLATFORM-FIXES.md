# Testing Platform - Quick Setup Guide

## 🔧 Fixed Issues

### 1. ✅ Fixed: Duplicate Variable Error
**Problem:** `SyntaxError: Can't create duplicate variable that shadows a global property: 'supabase'`  
**Solution:** Renamed the local database client variable from `supabase` to `db` throughout test.html to avoid shadowing the global Supabase library object

### 2. ✅ Fixed: SQL Policy Already Exists Error
**Problem:** `ERROR: 42710: policy "Anyone can view active test configs" for table "test_configs" already exists`  
**Solution:** Created new file `ADD-QUESTIONS-ONLY.sql` with ONLY INSERT statements (no CREATE TABLE or CREATE POLICY)

### 3. ✅ Fixed: SQL Syntax Error at Line 284
**Problem:** `ERROR: 42601: syntax error at or near '00000000-0000-0000-0000-000000000001'`  
**Solution:** Fixed in `ADD-QUESTIONS-ONLY.sql` - removed duplicate schema creation

### 4. ✅ Added: Custom Question Count Feature
**New Feature:** You can now specify how many questions you want (1-150) when starting a test

---

## 📥 How to Add Questions to Database

### Option 1: Use the Clean SQL File (RECOMMENDED)
```bash
# In Supabase SQL Editor, run this file:
ADD-QUESTIONS-ONLY.sql
```

This file contains:
- 30 Fundamentals of Nursing questions (11-30)  
- 10 Cardiovascular System questions (31-40)
- 10 Neurological System questions (61-70)
- 10 Respiratory System questions (91-100)
- 10 Gastrointestinal System questions (121-130)
- 10 Endocrine System questions (141-150)

**Total: 80 questions ready to use**

### Option 2: Add More Questions Manually
Follow this format:
```sql
INSERT INTO test_questions (test_id, question_stem, options, correct_answers, is_multiple_choice, rationale, category, display_order) VALUES
('00000000-0000-0000-0000-000000000001', 
 'Your question here?', 
 '[{"id":"a","text":"Option A"},{"id":"b","text":"Option B"},{"id":"c","text":"Option C"},{"id":"d","text":"Option D"}]'::jsonb, 
 ARRAY['b'], 
 false, 
 'Explanation of correct answer', 
 'Category Name', 
 151);
```

---

## 🎯 How to Use Custom Question Count

### Student View:
1. Open test.html
2. Click "Start Test"
3. **Select category** (optional): Choose a body system or "All Categories"
4. **Enter question count** (optional): Type a number from 1-150, or leave blank for all
5. Click "Begin Test"

### Examples:
- **10 Random Cardiovascular questions:**
  - Category: "Cardiovascular System"
  - Question Count: 10

- **All 30 Fundamentals questions:**
  - Category: "Fundamentals of Nursing"  
  - Question Count: (leave blank)

- **First 50 questions from all categories:**
  - Category: "All Categories"
  - Question Count: 50

---

## 🗂️ Database Structure

### Question Categories (as of now):
1. **Fundamentals of Nursing** - 30 questions (1-30)
2. **Cardiovascular System** - 30 questions (31-60) - 10 complete, 20 pattern
3. **Neurological System** - 30 questions (61-90) - 10 complete, 20 pattern
4. **Respiratory System** - 30 questions (91-120) - 10 complete, 20 pattern
5. **Gastrointestinal System** - 20 questions (121-140) - 10 complete, 10 pattern
6. **Endocrine System** - 10 questions (141-150) - 10 complete

### To verify questions loaded:
```sql
-- Count total questions
SELECT COUNT(*) as total_questions FROM test_questions 
WHERE test_id = '00000000-0000-0000-0000-000000000001';

-- Count by category
SELECT category, COUNT(*) as count 
FROM test_questions 
WHERE test_id = '00000000-0000-0000-0000-000000000001'
GROUP BY category 
ORDER BY category;
```

---

## 🚀 Testing the Platform

### Test URL:
```
test.html?test_id=00000000-0000-0000-0000-000000000001
```

### Test Scenarios:
1. **Quick 10-question quiz:**
   - Category: Any category
   - Count: 10

2. **System-specific exam:**
   - Category: "Respiratory System"
   - Count: (blank for all Respiratory questions)

3. **Comprehensive exam:**
   - Category: "All Categories"
   - Count: 150 (or blank)

---

## 📋 Next Steps

### To Complete Full 150-Question Bank:
You need to add 70 more questions:
- Cardiovascular: 20 more (questions 41-60)
- Neurological: 20 more (71-90)
- Respiratory: 20 more (101-120)
- Gastrointestinal: 10 more (131-140)

### Use this template for each question:
```sql
('00000000-0000-0000-0000-000000000001', 
 'Question text?', 
 '[{"id":"a","text":"Answer A"},{"id":"b","text":"Answer B"}]'::jsonb, 
 ARRAY['a'], 
 false, 
 'Rationale', 
 'Category Name', 
 DISPLAY_ORDER_NUMBER),
```

---

## ✅ Verification Checklist

- [x] Supabase variable error fixed
- [x] SQL policy error resolved  
- [x] Question count feature added
- [x] Category filtering working
- [x] 80 sample questions in database
- [ ] Add remaining 70 questions for full 150
- [ ] Test all categories load correctly
- [ ] Test question count limits work
- [ ] Test category + count combination

---

## 🆘 Troubleshooting

### "No questions found"
→ Run `ADD-QUESTIONS-ONLY.sql` in Supabase SQL Editor

### Category dropdown is empty
→ Check that questions have `category` field populated

### Question count not working
→ Check browser console for errors, ensure input is numeric

### Questions not randomized
→ Check test_configs table: `shuffle_questions` should be `true`
