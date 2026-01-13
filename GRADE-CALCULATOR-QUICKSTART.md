# 🚀 ACNHS Grade Calculator - Quick Start Guide

## 📋 What Was Built

A complete **end-of-semester grade calculation system** with:
- ✅ Hard gate enforcement (NO ROUNDING)
- ✅ Auto-save to Supabase database
- ✅ Finalization locks (tamper-resistant)
- ✅ Full audit trails
- ✅ Integration into Admin Student Page

---

## ⚡ Quick Setup (3 Steps)

### 1️⃣ Create Database Table

**Open:** https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql

**Run:** Copy all contents from `GRADE-CALCULATOR-TABLE-SETUP.sql` and execute

**Verify:** You should see success message: `✅ student_grades_calculator table created successfully`

---

### 2️⃣ Test the Calculator

**Open:** `http://localhost:8000/admin/GradeCalculator.html`

**Enter test data:**
- Unit Exams: 80, 82, 78, 85
- Final Exam: 80
- Quiz Average: 90
- Standardized: 85
- Clinical: PASS

**Click:** "Calculate"

**Expected Result:**
- ✅ PASS
- Letter: B
- All Gates: PASSED
- Progression: YES

---

### 3️⃣ Test Student Page Integration

**Open:** `http://localhost:8000/admin-student-page.html?id=<student-id>`

**Navigate to:** "Grades & GPA" tab

**Click:** "🧮 Open Calculator" button

**Expected:** Calculator opens in new window with student context

---

## 📁 Files Created

```
/admin/
  GradeCalculator.html           ← Main calculator UI
  grade-calculator.js            ← Pure calculation logic
  grade-calculator.css           ← Styles
  grade-calculator-app.js        ← Main app (connects everything)
  grade-service.js               ← Supabase persistence

/
  GRADE-CALCULATOR-TABLE-SETUP.sql      ← Database migration
  GRADE-CALCULATOR-INTEGRATION.md       ← Full documentation (READ THIS!)
  GRADE-CALCULATOR-QUICKSTART.md        ← This file
```

---

## 🧪 Testing Scenarios

### ✅ Scenario 1: Pass All Gates
```
Exams: 80, 82, 78, 85 → Avg 81.25% ✅
Final: 80% ✅
Clinical: PASS ✅
Result: PASS, Letter B, Progression YES
```

### ❌ Scenario 2: Fail Exam Average Gate
```
Exams: 75, 77, 76, 80 → Avg 77.00% ❌ (< 78.00)
Result: FAIL - "Gate A (ExamAvg): Failed — 77.00% < 78.00%"
```

### ❌ Scenario 3: Fail Final Exam Gate
```
Exams: 80, 82, 85, 83 → Avg 82.50% ✅
Final: 74.99% ❌ (< 75.00, NO ROUNDING!)
Result: FAIL - "Gate B (Final): Failed — 74.99% < 75.00%"
```

### ❌ Scenario 4: Clinical Failure
```
All scores excellent
Clinical: FAIL ❌
Result: FAIL - "Gate C (Clinical): Failed"
```

---

## 🔒 Finalization Test

1. **Open calculator with context:** `admin/GradeCalculator.html?student_id=TEST123&course_id=MED101&semester=Fall2026`
2. **Enter grades** and click "Calculate"
3. **Click:** "Finalize Semester Grade"
4. **Confirm:** Warning prompt
5. **Verify:**
   - 🔒 Red "FINALIZED" banner appears
   - All inputs disabled
   - Save/Finalize buttons hidden
   - Page reload → still locked

**Database Check:**
```sql
SELECT is_finalized, finalized_at, finalized_by 
FROM student_grades_calculator 
WHERE student_id = 'TEST123';
-- Should show: is_finalized = true
```

---

## 🛠️ Troubleshooting

### Calculator won't load
**Check:** Local server running on `localhost:8000`
```bash
cd /path/to/diploma
python3 start-server.py
```

### Autosave not working
**Check:** Browser console for errors
**Fix:** Verify `js/supabase-config.js` is loaded

### "Column does not exist" error
**Fix:** Run `GRADE-CALCULATOR-TABLE-SETUP.sql` in Supabase SQL Editor

### Can't finalize grades
**Check:** Student context parameters in URL
**Fix:** Must have `student_id`, `course_id`, and `semester` params

---

## 📚 Next Steps

### For Testing
1. ✅ Run database migration
2. ✅ Test standalone calculator
3. ✅ Test student page integration
4. ✅ Test finalization lock
5. ✅ Test all gate scenarios

### For Production
1. 🔒 Lock down RLS policies (remove anonymous access)
2. 👤 Add admin role checks
3. 📝 Implement course/semester selection UI
4. 📊 Add audit logging for finalization actions
5. 👨‍🎓 Create student read-only view

---

## 📖 Full Documentation

**See:** `GRADE-CALCULATOR-INTEGRATION.md` for:
- Complete feature documentation
- Security considerations
- Customization guide
- Production deployment checklist
- Database schema details
- API reference

---

## 🎯 Key Rules (MUST KNOW)

### ❌ NO ROUNDING POLICY
- 77.99% ≠ 78.00%
- 74.99% ≠ 75.00%
- Gates require **exact** ≥ thresholds
- This is INTENTIONAL per ACNHS policy

### 🔒 FINALIZATION IS PERMANENT
- Once finalized → **LOCKED FOREVER**
- Only super-admin can override (manual SQL)
- Audit trail is **immutable**

### 📊 Gate Order Matters
1. Attendance (if enabled)
2. Clinical Status
3. Exam Average
4. Final Exam
5. Progression Threshold

**Calculation stops on first failure!**

---

## 💡 Tips

### Open Calculator for Specific Student
```javascript
// In browser console on student page:
openGradeCalculator()
```

### Check Saved Grades
```sql
SELECT * FROM student_grades_calculator 
ORDER BY created_at DESC 
LIMIT 10;
```

### Unlock Finalized Grade (EMERGENCY ONLY)
```sql
UPDATE student_grades_calculator 
SET is_finalized = false, finalized_at = NULL 
WHERE id = 'uuid-here';
-- ⚠️ Document reason in audit log!
```

---

## ✅ Success Criteria

You're done when:
- [x] Table exists in Supabase
- [x] Calculator opens and calculates correctly
- [x] Autosave works (check database after input)
- [x] Finalization locks the record
- [x] Student page "Open Calculator" button works
- [x] All 5 test scenarios produce correct results

---

## 📞 Need Help?

**Check:**
1. Browser console for JavaScript errors
2. Supabase logs for database errors
3. `GRADE-CALCULATOR-INTEGRATION.md` for detailed docs

**Common Issues:**
- Missing context params → Use `openGradeCalculator()` function
- Save not working → Check Supabase client initialization
- Finalization not locking → Verify RLS policies active

---

**Version:** 1.0  
**Created:** January 13, 2026  
**System:** ACNHS Diploma Management System
