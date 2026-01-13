# ACNHS Grade Calculator Integration - Complete Setup Guide

## 📘 Overview

The ACNHS Grade Calculator is a **centralized, deterministic, and auditable** system for calculating end-of-semester grades with hard gate enforcement. It follows the ACNHS Hard Grading Rules with **NO ROUNDING** and produces tamper-resistant audit trails.

## 🎯 Key Features

✅ **Hard Gate Enforcement**
- Gate A: Exam Average ≥ 78.00%
- Gate B: Final Exam ≥ 75.00%  
- Gate C: Clinical Status = PASS
- Optional: Attendance Administrative Gates

✅ **NO ROUNDING Policy**
- All calculations preserve exact decimal precision
- Gates require exact ≥ thresholds (77.99% ≠ 78.00%)
- Deterministic and reproducible results

✅ **Persistent Storage**
- Auto-saves every 800ms to Supabase
- Draft mode for in-progress grading
- Finalization locks records (immutable)

✅ **Full Audit Trail**
- Gate-by-gate decision log
- Timestamps and admin attribution
- Exportable for appeals/accreditation

✅ **Student Context Integration**
- Embedded in Admin Student Page as "Grades" tab
- Opens in new window with student/course/semester context
- Read-only mode for finalized grades

---

## 📂 File Structure

```
/admin/
 ├─ GradeCalculator.html         # Main calculator UI (URL: admin/GradeCalculator.html)
 ├─ grade-calculator.js          # Pure calculation logic (ES module)
 ├─ grade-calculator.css         # Styles for calculator UI
 ├─ grade-calculator-app.js      # Main app: connects UI + DB + logic
 └─ grade-service.js             # Supabase persistence layer

/
 ├─ admin-student-page.html      # Student page with Grades tab integration
 ├─ GRADE-CALCULATOR-TABLE-SETUP.sql  # Database migration
 └─ GRADE-CALCULATOR-INTEGRATION.md   # This file
```

---

## 🗄️ Database Setup

### Step 1: Run SQL Migration

**File:** `GRADE-CALCULATOR-TABLE-SETUP.sql`

1. Open Supabase SQL Editor: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql
2. Copy entire contents of `GRADE-CALCULATOR-TABLE-SETUP.sql`
3. Click **Run**
4. Verify success message in output

**Table Created:** `student_grades_calculator`

**Key Columns:**
- `student_id` (TEXT) - ACNHS student ID
- `course_id` (TEXT) - Course code (e.g., MED101)
- `semester` (TEXT) - Semester identifier (e.g., Fall2026)
- `unit_exams` (JSONB) - Array of `{name, score}` objects
- `final_exam`, `quiz_avg`, `standardized_avg` (NUMERIC)
- `clinical_status` (TEXT) - "PASS" or "FAIL"
- `exam_avg`, `theory_final`, `letter_grade` (NUMERIC/TEXT) - Calculated results
- `gate_*_passed` (BOOLEAN) - Gate pass/fail status
- `audit_log` (JSONB) - Immutable audit trail
- `is_finalized` (BOOLEAN) - When TRUE, record is LOCKED

**RLS Policies:**
- ⚠️ **Currently open for testing (anonymous access)**
- 🔒 **PRODUCTION:** Lock down to `authenticated` role with admin checks

---

## 🚀 Integration into Student Page

### Current Implementation

**Location:** `admin-student-page.html` → Grades Tab

**UI Components:**
1. **Calculator Card** - Overview with "Open Calculator" button
2. **Info Panel** - Shows hard grading gates
3. **GPA Calculator** - Existing cumulative GPA display
4. **Grades Table** - Existing course grades table

**Function:** `openGradeCalculator()`
- Reads `currentStudentId` from page context
- Builds URL: `admin/GradeCalculator.html?student_id=XXX&course_id=YYY&semester=ZZZ`
- Opens in new window (1400x900px)

### URL Parameters

The calculator reads these from the query string:

```javascript
// Example URL:
// admin/GradeCalculator.html?student_id=ACNHS-1234567&course_id=MED101&semester=Fall2026

?student_id=ACNHS-1234567   // Required: Student identifier
&course_id=MED101            // Required: Course code
&semester=Fall2026           // Required: Semester identifier
```

**Behavior:**
- If parameters present → Auto-loads saved grade from DB
- Shows student context banner at top
- Enables autosave + Save/Finalize buttons
- If grade is finalized → Enters read-only mode (all inputs disabled)

---

## 🔒 Finalization Lock System

### How It Works

1. **Draft Mode** (default)
   - `is_finalized = false`
   - Inputs editable
   - Auto-saves on every change (800ms debounce)
   - Can be reset

2. **Finalized Mode** (locked)
   - `is_finalized = true`
   - **ALL inputs disabled**
   - Red "🔒 FINALIZED — Read-Only Mode" banner
   - Save/Finalize buttons hidden
   - Database UPDATE policy prevents edits
   - Only super-admin can override (manual SQL)

### Finalize Process

```javascript
// User clicks "Finalize Semester Grade" button
→ Confirmation prompt: "This will LOCK the grade record..."
→ Saves current data
→ Calls gradeService.finalizeGrade(studentId, courseId, semester, adminEmail)
→ Sets is_finalized = true, finalized_at = NOW(), finalized_by = adminEmail
→ Page reloads in read-only mode
```

**Critical:** Once finalized, edits require:
1. Super-admin access to Supabase
2. Manual SQL: `UPDATE student_grades_calculator SET is_finalized = false WHERE id = '...'`
3. Audit log should record override reason

---

## 📊 Calculation Logic

### Hard Grading Gates (Sequential)

**Order matters!** Calculation stops immediately on first gate failure.

```
1. Attendance Gate (if enabled)
   - Clinical absences >= 2 → Clinical FAIL
   - Theory absences >= 3 → Course FAIL

2. Gate C: Clinical Status
   - Must be "PASS"
   - If "FAIL" → Course FAIL

3. Gate A: Exam Average
   - Average of all unit exams
   - Must be >= 78.00% (NO ROUNDING)
   - If fails → Course FAIL

4. Gate B: Final Exam Safety
   - Must be >= 75.00% (NO ROUNDING)
   - If fails → Course FAIL

5. Weighted Theory Final
   - Formula: (ExamAvg * 60%) + (Final * 20%) + (Quiz * 10%) + (Std * 10%)
   - NO ROUNDING at any step

6. Progression Threshold
   - Theory Final >= 78.00% (C+ minimum)
   - If fails → Course FAIL (cannot progress)

Course PASS = All gates passed AND progression threshold met
```

### Letter Grade Scale

| Percentage | Letter | Progression? |
|------------|--------|--------------|
| 93.00–100  | A      | ✅ Yes       |
| 90.00–92.99| A-     | ✅ Yes       |
| 87.00–89.99| B+     | ✅ Yes       |
| 83.00–86.99| B      | ✅ Yes       |
| 80.00–82.99| B-     | ✅ Yes       |
| 78.00–79.99| C+     | ✅ Yes       |
| 75.00–77.99| C      | ❌ No        |
| < 75.00    | F      | ❌ No        |

---

## 🧪 Testing Checklist

### ✅ Basic Functionality

- [ ] Calculator opens in new window from student page
- [ ] Student context (ID, course, semester) displays correctly
- [ ] Can add/remove unit exams
- [ ] All inputs accept decimal values (e.g., 78.50)
- [ ] Calculate button produces results with badges
- [ ] Audit trail shows gate-by-gate decisions

### ✅ Persistence

- [ ] Autosave triggers after input changes (see "Saving..." status)
- [ ] Refresh page → data persists
- [ ] "Save Draft" button works manually
- [ ] Grades saved to `student_grades_calculator` table in Supabase

### ✅ Finalization

- [ ] "Finalize Semester Grade" button appears (if context present)
- [ ] Confirmation prompt shows warning
- [ ] After finalization:
  - [ ] Red "FINALIZED" banner appears
  - [ ] All inputs disabled
  - [ ] Save/Finalize buttons hidden
  - [ ] `is_finalized = true` in database
  - [ ] Cannot edit via UI
  - [ ] RLS policy prevents UPDATE queries

### ✅ Gate Enforcement (NO ROUNDING)

Test these scenarios:

**Scenario 1: Pass All Gates**
- Exams: 80, 82, 78, 85 → Avg = 81.25% ✅
- Final: 80% ✅
- Quiz: 90%, Std: 85%
- Clinical: PASS ✅
- **Expected:** PASS, Letter B, Progression YES

**Scenario 2: Fail Gate A (ExamAvg)**
- Exams: 75, 77, 76, 80 → Avg = 77.00% ❌ (< 78.00)
- Final: 85% ✅
- Clinical: PASS ✅
- **Expected:** FAIL, "Gate A (ExamAvg): Failed — 77.00% < 78.00%"

**Scenario 3: Fail Gate B (Final)**
- Exams: 80, 82, 85, 83 → Avg = 82.50% ✅
- Final: 74.99% ❌ (< 75.00, NO ROUNDING UP)
- Clinical: PASS ✅
- **Expected:** FAIL, "Gate B (Final): Failed — 74.99% < 75.00%"

**Scenario 4: Fail Clinical Gate**
- Exams: 85, 90, 88, 92 → Avg = 88.75% ✅
- Final: 90% ✅
- Clinical: FAIL ❌
- **Expected:** FAIL, "Gate C (Clinical): Failed"

**Scenario 5: Pass Gates but Fail Progression**
- Exams: 78, 79, 77, 80 → Avg = 78.50% ✅
- Final: 75% ✅
- Quiz: 70%, Std: 70%
- Theory Final: (78.5*60%) + (75*20%) + (70*10%) + (70*10%) = 76.10%
- Clinical: PASS ✅
- **Expected:** FAIL, Letter C, "Progression Threshold: Failed — 76.10% < 78.00%"

---

## 🎨 Customization

### Change Default Weights

**File:** `admin/grade-calculator-app.js`

```javascript
// Line ~150
calculator = new GradeCalculator({
  wExams: 60.00,  // Unit exams weight
  wFinal: 20.00,  // Final exam weight
  wQuiz: 10.00,   // Quiz/assignments weight
  wStd: 10.00     // Standardized/OSCE weight
});
```

### Change Gate Thresholds

**File:** `admin/GradeCalculator.html` (defaults in Advanced section)

```html
<input type="number" id="gateExamMin" value="78.00" />  <!-- Gate A -->
<input type="number" id="gateFinalMin" value="75.00" /> <!-- Gate B -->
<input type="number" id="progMin" value="78.00" />      <!-- C+ threshold -->
```

### Enable Attendance Gates by Default

**File:** `admin/GradeCalculator.html`

```html
<select id="enableAttendance">
  <option value="off">Off</option>
  <option value="on" selected>On (Hard)</option> <!-- Make this default -->
</select>
```

---

## 🔐 Security Considerations

### Current State (Testing)

⚠️ **Anonymous RLS policies enabled** - Anyone can read/write grades

### Production Lockdown

**Required Changes:**

1. **Update RLS Policies** (`GRADE-CALCULATOR-TABLE-SETUP.sql`)

```sql
-- Remove anonymous policies
DROP POLICY "Allow anon read student_grades_calculator" ON student_grades_calculator;
DROP POLICY "Allow anon insert student_grades_calculator" ON student_grades_calculator;
DROP POLICY "Allow anon update student_grades_calculator" ON student_grades_calculator;

-- Add authenticated policies
CREATE POLICY "Allow authenticated read" ON student_grades_calculator
  FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated insert" ON student_grades_calculator
  FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated update (not finalized)" ON student_grades_calculator
  FOR UPDATE TO authenticated
  USING (NOT is_finalized)
  WITH CHECK (NOT is_finalized);
```

2. **Add Role-Based Access Control**

Add admin email check in JavaScript:

```javascript
const ADMIN_EMAILS = ['admin@acnhs.edu', 'instructor@acnhs.edu'];
const userEmail = sessionStorage.getItem('adminEmail');

if (!ADMIN_EMAILS.includes(userEmail)) {
  alert('Access denied: Instructor/Admin access required');
  window.close();
}
```

3. **Audit Finalization Actions**

Log to `user_activity_log` table:

```javascript
await supabase.from('user_activity_log').insert({
  user_email: adminEmail,
  action: 'FINALIZE_GRADE',
  target_id: studentId,
  details: `Finalized ${courseId} - ${semester}`,
  ip_address: await fetch('https://api.ipify.org').then(r => r.text())
});
```

---

## 📱 Student View (Read-Only)

### Option 1: Embed in Student Portal

**File:** `student-portal.html` or `student-grades.html`

```html
<iframe 
  src="admin/GradeCalculator.html?student_id=ACNHS-1234567&course_id=MED101&semester=Fall2026&readonly=true"
  width="100%" 
  height="800px" 
  style="border: none; border-radius: 16px;">
</iframe>
```

**Modification Required:** Add `readonly` param support to `grade-calculator-app.js`

```javascript
const urlParams = new URLSearchParams(window.location.search);
const readonly = urlParams.get('readonly') === 'true';

if (readonly) {
  isLocked = true;
  document.querySelectorAll('button:not(#btnPrint)').forEach(btn => btn.style.display = 'none');
}
```

### Option 2: Generate PDF Report

Use the **Print / Save PDF** button:
- Hides buttons and interactive elements
- Shows only results + audit trail
- Students can save via browser's "Save as PDF"

---

## 🐛 Troubleshooting

### Issue: "Cannot save: Missing context"

**Cause:** Calculator opened without `student_id`, `course_id`, or `semester` params

**Fix:** Always open via `openGradeCalculator()` function in student page

### Issue: Autosave not working

**Cause:** Supabase client not initialized

**Fix:** Verify `js/supabase-config.js` is loaded before `grade-calculator-app.js`

```html
<script src="../js/supabase-config.js"></script> <!-- Must be first -->
<script type="module" src="grade-calculator-app.js"></script>
```

### Issue: "Column does not exist" error

**Cause:** Migration not run or table name mismatch

**Fix:** 
1. Check table exists: `SELECT * FROM student_grades_calculator LIMIT 1;`
2. If not, run `GRADE-CALCULATOR-TABLE-SETUP.sql`
3. Verify table name in `grade-service.js` matches

### Issue: Finalized grade still editable

**Cause:** RLS policy not working or `is_finalized` column not checked

**Fix:**
1. Verify policy exists: `SELECT * FROM pg_policies WHERE tablename = 'student_grades_calculator';`
2. Test UPDATE: Should fail with "new row violates row-level security policy"
3. Check UI: `isLocked` variable should be `true` in console

### Issue: Grades calculate to 77.99% instead of 78.00%

**Cause:** This is correct! NO ROUNDING means 77.99% ≠ 78.00%

**Fix:** This is intentional per ACNHS policy. Student must improve score.

---

## 📞 Support & Maintenance

### Key Files for Debugging

1. **`admin/grade-calculator.js`** - Calculation logic (pure functions)
2. **`admin/grade-service.js`** - Database operations
3. **`admin/grade-calculator-app.js`** - UI + glue code

### Browser Console Commands

```javascript
// Check loaded grade data
const urlParams = new URLSearchParams(window.location.search);
console.log('Student:', urlParams.get('student_id'));

// Check Supabase connection
console.log('Supabase client:', window.supabase || window.sbClient);

// Check calculation result
calculator.calculate({
  exams: [{name: 'Exam 1', score: 78.5}],
  finalExam: 80,
  quizAvg: 85,
  stdAvg: 82,
  clinical: 'PASS'
});
```

### Database Queries

```sql
-- Check all grades for a student
SELECT * FROM student_grades_calculator
WHERE student_id = 'ACNHS-1234567'
ORDER BY created_at DESC;

-- Find finalized grades
SELECT student_id, course_id, semester, letter_grade, course_outcome, finalized_at
FROM student_grades_calculator
WHERE is_finalized = true;

-- Unlock a finalized grade (CAUTION)
UPDATE student_grades_calculator
SET is_finalized = false, finalized_at = NULL
WHERE id = 'uuid-here';
```

---

## ✅ Final Checklist

Before deploying to production:

- [ ] Run `GRADE-CALCULATOR-TABLE-SETUP.sql` in Supabase
- [ ] Test all gate scenarios (see Testing section)
- [ ] Verify autosave works (check database after input)
- [ ] Test finalization lock (should prevent edits)
- [ ] Lock down RLS policies (remove anonymous access)
- [ ] Add admin role checks in JavaScript
- [ ] Configure course/semester selection UI (currently hardcoded)
- [ ] Set up audit logging for finalization actions
- [ ] Test student read-only view
- [ ] Train instructors on NO ROUNDING policy
- [ ] Document appeal process for locked grades

---

## 📚 Related Documentation

- `GRADE-CALCULATOR-TABLE-SETUP.sql` - Database schema
- `admin/grade-calculator.js` - Pure calculation logic
- `admin/grade-service.js` - Persistence layer
- `admin/GradeCalculator.html` - UI markup
- `admin-student-page.html` - Integration point

---

**Version:** 1.0  
**Last Updated:** January 13, 2026  
**Maintainer:** ACNHS Development Team
