# Dynamic Subject & Topic System - Setup Guide

## 🎯 Overview

This new system allows you to dynamically add subjects and topics from Supabase instead of hardcoding categories. You can now organize questions by:
- **Subject** (e.g., "Fundamentals of Nursing", "Medical-Surgical", "Pharmacology")
- **Topic** (e.g., "Infection Control", "Vital Signs", "Medication Administration")

---

## 📋 Step-by-Step Setup

### Step 1: Create Subject & Topic Tables
Run this SQL in Supabase SQL Editor:
```bash
ADD-SUBJECTS-TOPICS-TABLE.sql
```

**This creates:**
- `test_subjects` table - Main subjects (Fundamentals, Med-Surg, etc.)
- `test_topics` table - Topics within each subject
- Automatically creates "Fundamentals of Nursing" with 11 topics
- Updates existing tables to link to subjects/topics

### Step 2: Add 50 Fundamentals Questions
Run this SQL in Supabase SQL Editor:
```bash
ADD-FUNDAMENTALS-50-QUESTIONS.sql
```

**This adds 50 NCLEX-style questions covering:**
1. **Infection Control** (5 questions) - Hand hygiene, PPE, precautions
2. **Vital Signs** (5 questions) - Temp, HR, RR, BP, O2 sat
3. **Physical Assessment** (7 questions) - I-P-P-A technique
4. **Documentation** (3 questions) - Accurate charting
5. **Ethics & Legal** (9 questions) - Autonomy, consent, principles
6. **Communication** (5 questions) - Therapeutic techniques
7. **Positioning & Mobility** (5 questions) - Fowler's, Sims, etc.
8. **Medication Administration** (4 questions) - 6 Rights
9. **Sterile Technique** (2 questions) - Catheter, wound care
10. **IV Therapy & Tubes** (3 questions) - Infiltration, phlebitis
11. **Safety** (2 questions) - Falls, orthostatic hypotension

---

## 🔧 How to Add New Subjects

### Add a New Subject:
```sql
INSERT INTO test_subjects (name, description, icon, display_order)
VALUES 
  ('Medical-Surgical Nursing', 
   'Adult health nursing across multiple systems', 
   '🏥', 
   2);
```

### Add Topics for That Subject:
```sql
-- First, get the subject_id
SELECT id FROM test_subjects WHERE name = 'Medical-Surgical Nursing';

-- Then insert topics
INSERT INTO test_topics (subject_id, name, description, display_order) VALUES
  ('YOUR-SUBJECT-ID-HERE', 'Cardiovascular', 'Heart disease, MI, HTN', 1),
  ('YOUR-SUBJECT-ID-HERE', 'Respiratory', 'COPD, asthma, pneumonia', 2),
  ('YOUR-SUBJECT-ID-HERE', 'Endocrine', 'Diabetes, thyroid disorders', 3);
```

### Add Questions for Topics:
```sql
-- Get topic_id
SELECT id FROM test_topics WHERE name = 'Cardiovascular';

INSERT INTO test_questions (test_id, topic_id, question_stem, options, correct_answers, is_multiple_choice, rationale, category, display_order)
VALUES
  ('00000000-0000-0000-0000-000000000001',
   'YOUR-TOPIC-ID-HERE',
   'Your question here?',
   '[{"id":"a","text":"Option A"},{"id":"b","text":"Option B"}]'::jsonb,
   ARRAY['a'],
   false,
   'Rationale here',
   'Cardiovascular',
   51);
```

---

## 📊 Database Structure

### test_subjects
```
id (UUID)
name (TEXT) - "Fundamentals of Nursing"
description (TEXT)
icon (TEXT) - "🏥"
display_order (INTEGER)
is_active (BOOLEAN)
```

### test_topics
```
id (UUID)
subject_id (UUID) → references test_subjects
name (TEXT) - "Infection Control"
description (TEXT)
display_order (INTEGER)
is_active (BOOLEAN)
```

### test_questions (updated)
```
id (UUID)
test_id (UUID)
topic_id (UUID) → references test_topics
question_stem (TEXT)
options (JSONB)
correct_answers (TEXT[])
is_multiple_choice (BOOLEAN)
rationale (TEXT)
category (TEXT) - kept for backward compatibility
display_order (INTEGER)
```

---

## 🎮 Using the Test Platform

### View Available Subjects:
```sql
SELECT * FROM test_subjects WHERE is_active = true ORDER BY display_order;
```

### View Topics for a Subject:
```sql
SELECT t.* 
FROM test_topics t
JOIN test_subjects s ON t.subject_id = s.id
WHERE s.name = 'Fundamentals of Nursing'
ORDER BY t.display_order;
```

### Count Questions by Topic:
```sql
SELECT 
  s.name as subject,
  t.name as topic, 
  COUNT(q.id) as question_count 
FROM test_questions q
JOIN test_topics t ON q.topic_id = t.id
JOIN test_subjects s ON t.subject_id = s.id
WHERE q.test_id = '00000000-0000-0000-0000-000000000001'
GROUP BY s.name, t.name, t.display_order
ORDER BY s.name, t.display_order;
```

---

## 🚀 Next Steps

### 1. **Test the 50 Fundamentals Questions**
```
Open: test.html?test_id=00000000-0000-0000-0000-000000000001
- All 50 questions should load
- Topics should filter correctly
- Test duration: 60 minutes
- Passing score: 75%
```

### 2. **Add More Subjects** (Examples)
- **Pharmacology** - Drug calculations, classifications, side effects
- **Maternal-Child** - OB, pediatrics, growth & development
- **Mental Health** - Depression, anxiety, therapeutic communication
- **Community Health** - Epidemiology, health promotion
- **Leadership** - Delegation, prioritization, legal issues

### 3. **Expand Topics Within Subjects**
Each subject can have unlimited topics. For example:
- **Fundamentals** → 11 topics (already created)
- **Med-Surg** → 15+ topics (Cardiac, Respiratory, Neuro, etc.)
- **Pharmacology** → 10+ topics (Antibiotics, Analgesics, Cardiac drugs, etc.)

---

## 📝 Example: Adding Pharmacology Subject

```sql
-- 1. Add Subject
INSERT INTO test_subjects (name, description, icon, display_order)
VALUES 
  ('Pharmacology', 'Drug therapy, calculations, and safety', '💊', 3)
RETURNING id;

-- 2. Add Topics (use the returned id)
INSERT INTO test_topics (subject_id, name, display_order) VALUES
  ('subject-id-from-above', 'Drug Calculations', 1),
  ('subject-id-from-above', 'Antibiotics', 2),
  ('subject-id-from-above', 'Cardiac Medications', 3),
  ('subject-id-from-above', 'Analgesics', 4),
  ('subject-id-from-above', 'Adverse Effects', 5);

-- 3. Create Test Config
INSERT INTO test_configs (subject_id, title, duration_minutes, passing_score_percent)
VALUES 
  ('subject-id', 'Pharmacology NCLEX Review', 45, 70);

-- 4. Add Questions (link to topic_id)
-- See ADD-FUNDAMENTALS-50-QUESTIONS.sql for format
```

---

## ✅ Verification Queries

### Check Setup:
```sql
-- Subjects
SELECT name, 
       (SELECT COUNT(*) FROM test_topics WHERE subject_id = test_subjects.id) as topics,
       (SELECT COUNT(*) FROM test_questions q 
        JOIN test_topics t ON q.topic_id = t.id 
        WHERE t.subject_id = test_subjects.id) as questions
FROM test_subjects;

-- Topics with question counts
SELECT s.name as subject, t.name as topic, COUNT(q.id) as questions
FROM test_subjects s
LEFT JOIN test_topics t ON t.subject_id = s.id
LEFT JOIN test_questions q ON q.topic_id = t.id
GROUP BY s.name, t.name
ORDER BY s.name, t.name;
```

---

## 🎓 Benefits of This System

✅ **Dynamic** - Add subjects/topics from Supabase admin without touching code  
✅ **Organized** - Clear hierarchy: Subject → Topic → Questions  
✅ **Scalable** - Supports unlimited subjects and topics  
✅ **Flexible** - Filter questions by subject, topic, or both  
✅ **NCLEX-Aligned** - Matches NCLEX test plan categories  
✅ **Reusable** - Same topic can be used across multiple test configs  

---

## 📚 Current Status

**Subjects:** 1 (Fundamentals of Nursing)  
**Topics:** 11 (Infection Control → Safety)  
**Questions:** 50 (NCLEX-style comprehensive assessment)  
**Test Duration:** 60 minutes  
**Passing Score:** 75%

**Ready to expand with more subjects and questions!** 🚀
