# 🔧 Fix "No questions found" Error - Quick Setup

## Problem
Your 50 existing questions are still mapped to old topic IDs. The new 29-topic structure uses different IDs and names, so when you select topics, no questions are found.

## Solution (3 SQL Files in Order)

### Step 1: Add Status Column
**File:** `ADD-TOPIC-STATUS-COLUMN.sql`

```bash
# Run in Supabase SQL Editor
```

This adds `status` column (`draft`/`published`) to topics.

---

### Step 2: Create New 29 Topics
**File:** `ADD-SUBJECTS-TOPICS-TABLE.sql` (updated)

```bash
# Run in Supabase SQL Editor
```

This creates your exact 29 topics:
1. Fundamentals
2. Nurse's Role in Informed Consent
3. Scope of Practice
4. Delegation
5. Family Dynamics
6. Maslow's Hierarchy of Needs
7. SBAR Communication
8. Precautions
9. Vital Signs Interpretation
10. Physical Exam & Bowel Sounds
11. Physical Assessment
12. Head-to-Toe Assessment
13. Nursing Diagnosis
14. Documentation & Informatics
15. Client Positioning
16. Care of a Client With a Tube
17. Administration of Blood Products
18. Amputation
19. Nursing Calculations
20. BMI Calculation
21. Complementary and Alternative Medicine (CAM)
22. Emergency Triage Tag Colors (MCI)
23. Hygiene & Grooming
24. Elimination & Intake and Output (I&O)
25. Nutrition & Feeding
26. Oxygenation Basics
27. Pain Assessment
28. Skin Integrity & Pressure Injuries
29. Sleep & Sensory Needs

---

### Step 3: Remap Existing 50 Questions
**File:** `REMAP-EXISTING-QUESTIONS.sql` ⭐ **NEW - CRITICAL**

```bash
# Run in Supabase SQL Editor AFTER Step 2
```

This maps your 50 questions to appropriate new topics:

| Old Topic | Questions | New Topic ID | New Topic Name |
|-----------|-----------|--------------|----------------|
| Infection Control | Q1-5 | `...0008` | Precautions |
| Vital Signs | Q6-10 | `...0009` | Vital Signs Interpretation |
| Physical Assessment | Q11-17 | `...0011` | Physical Assessment |
| Documentation | Q18-20 | `...0014` | Documentation & Informatics |
| Ethics & Legal | Q21-29 | `...0002` | Nurse's Role in Informed Consent |
| Communication | Q30-34 | `...0007` | SBAR Communication |
| Positioning | Q35-39 | `...0015` | Client Positioning |
| Medication Admin | Q40-43 | `...0001` | Fundamentals |
| Sterile Technique | Q44-45 | `...0001` | Fundamentals |
| IV Therapy | Q46-48 | `...0016` | Care of a Client With a Tube |
| Safety | Q49-50 | `...0001` | Fundamentals |

---

## Verification Queries

After running all 3 files, verify:

```sql
-- Check topic count
SELECT COUNT(*) FROM test_topics 
WHERE subject_id = '10000000-0000-0000-0000-000000000001';
-- Expected: 29

-- Check question mapping
SELECT 
  t.name,
  COUNT(q.id) as questions
FROM test_topics t
LEFT JOIN test_questions q ON q.topic_id = t.id
WHERE t.subject_id = '10000000-0000-0000-0000-000000000001'
GROUP BY t.name
HAVING COUNT(q.id) > 0
ORDER BY t.display_order;
-- Expected: 8 topics with questions distributed

-- Check unmapped questions
SELECT COUNT(*) 
FROM test_questions 
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id IS NULL;
-- Expected: 0 (all should be mapped)
```

---

## Test Flow After Fix

1. **Open:** `http://localhost:8000/test.html?test_id=00000000-0000-0000-0000-000000000001`
2. **Click:** "Start Test"
3. **Select:** Fundamentals subject
4. **See:** 29 topics (8 have questions, 21 are empty)
5. **Select:** Topics with questions:
   - ✅ Fundamentals (11 questions)
   - ✅ Nurse's Role in Informed Consent (9 questions)
   - ✅ SBAR Communication (5 questions)
   - ✅ Precautions (5 questions)
   - ✅ Vital Signs Interpretation (5 questions)
   - ✅ Physical Assessment (7 questions)
   - ✅ Documentation & Informatics (3 questions)
   - ✅ Client Positioning (5 questions)
   - ✅ Care of a Client With a Tube (3 questions)
6. **Start Test:** Should load questions successfully!

---

## Topics Ready for New Questions

These 21 topics need questions added:
- Scope of Practice
- Delegation
- Family Dynamics
- Maslow's Hierarchy of Needs
- Physical Exam & Bowel Sounds
- Head-to-Toe Assessment
- Nursing Diagnosis
- Administration of Blood Products
- Amputation
- Nursing Calculations
- BMI Calculation
- Complementary and Alternative Medicine (CAM)
- Emergency Triage Tag Colors (MCI)
- Hygiene & Grooming
- Elimination & Intake and Output (I&O)
- Nutrition & Feeding
- Oxygenation Basics
- Pain Assessment
- Skin Integrity & Pressure Injuries
- Sleep & Sensory Needs

---

## Quick Fix Summary

```bash
# In Supabase SQL Editor, run these 3 files in order:

1. ADD-TOPIC-STATUS-COLUMN.sql          # Adds status field
2. ADD-SUBJECTS-TOPICS-TABLE.sql        # Creates 29 topics
3. REMAP-EXISTING-QUESTIONS.sql         # ⭐ Maps 50 questions to new topics

# Then refresh test page and try again!
```

**The error will be fixed once you run REMAP-EXISTING-QUESTIONS.sql!**
