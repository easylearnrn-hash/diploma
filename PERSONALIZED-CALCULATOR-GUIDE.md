# 👤 Personalized Student Grade Calculator - How It Works

## Overview

Each student now has their **own personalized calculator** with pre-filled information that:
- ✅ Shows their name, course, and semester
- ✅ Auto-loads any previously saved grades
- ✅ Auto-saves as they work (every 800ms)
- ✅ Locks permanently when finalized
- ✅ Is unique per student/course/semester combination

---

## How to Use

### From Admin Student Page

1. **Open a student's profile** in `admin-student-page.html`
2. **Navigate to "Grades & GPA" tab**
3. **Click "Open Calculator" button**
4. **System will prompt for:**
   - Course Code (e.g., MED101, NURS201)
   - Semester (e.g., Fall2026, Spring2027)
5. **Calculator opens with:**
   - ✅ Student name pre-filled and locked
   - ✅ Course information displayed
   - ✅ Any existing grades auto-loaded
   - ✅ Unique save context for this student/course/semester

---

## What Gets Pre-Filled

### Automatically Set (from URL):
- **Student ID** - Passed from student page
- **Student Name** - Displayed and locked (can't edit)
- **Course Code** - From user prompt, displayed in banner
- **Semester** - From user prompt, displayed in banner
- **Program** - Student's program (if available)

### Auto-Loaded from Database:
If the student has previously started grading for this course/semester:
- **Unit Exam Scores** - All saved exam scores
- **Final Exam** - Previously entered final exam score
- **Quiz/Assignment Average** - Previously saved average
- **Standardized/OSCE Score** - Previously saved score
- **Clinical Status** - PASS or FAIL status
- **Attendance Records** - Theory and clinical absences
- **Calculated Results** - Previous grade calculation

---

## URL Format

```
admin/GradeCalculator.html?
  student_id=ACNHS-1234567
  &student_name=John%20Doe
  &course_id=MED101
  &semester=Fall2026
  &program=Nursing
```

---

## Database Storage

Each student's grades are stored uniquely by:

```sql
UNIQUE (student_id, course_id, semester)
```

This means:
- ✅ Same student can have different grades for different courses
- ✅ Same student can have different grades for different semesters
- ✅ Each combination is isolated and independent
- ✅ No mixing or overwriting of data

**Example:**
```
Student: ACNHS-1234567
├── MED101 - Fall2026 (unique record)
├── MED101 - Spring2027 (unique record)
├── NURS201 - Fall2026 (unique record)
└── NURS201 - Spring2027 (unique record)
```

---

## Personalization Features

### 1. Student Context Banner
```
┌─────────────────────────────────────────┐
│ 📋 Student Grade Record                 │
│ Student: John Doe                       │
│ Course: MED101    Semester: Fall2026    │
└─────────────────────────────────────────┘
```

### 2. Auto-Save Status
```
Saving...           → Currently saving
✓ Saved at 2:45 PM  → Save successful
✗ Error: ...        → Save failed (with reason)
```

### 3. Lock Status (if finalized)
```
🔒 FINALIZED — Read-Only Mode
All inputs disabled
Cannot be edited without super-admin override
```

---

## Workflow Example

### Scenario: Grading John Doe for MED101 Fall2026

**Step 1: Open Calculator**
```
Admin clicks "Open Calculator" from John's student page
→ Prompted: "Enter Course Code" → Types "MED101"
→ Prompted: "Enter Semester" → Types "Fall2026"
→ Calculator opens with John's info pre-filled
```

**Step 2: First Time (No Saved Data)**
```
Calculator shows:
✓ Student Name: John Doe (locked, can't edit)
✓ Course: MED101 - Nursing Program
✓ Empty grade fields (ready for input)
✓ Default 4 unit exams
```

**Step 3: Enter Grades**
```
Admin enters:
- Exam 1: 82.5
- Exam 2: 78.0
- Exam 3: 85.5
- Exam 4: 80.0
- Final: 82.0
- Quiz Avg: 90.0
- Standardized: 85.0
- Clinical: PASS

Auto-saves every 800ms ✓
```

**Step 4: Close and Reopen**
```
Admin closes calculator
Later, opens again for same student/course/semester
→ All previous data auto-loads ✓
→ Can continue editing
```

**Step 5: Finalize**
```
Admin clicks "Finalize Semester Grade"
→ Confirmation prompt
→ Record locks permanently
→ Future opens show read-only mode
```

---

## Multiple Students Workflow

### Grading Multiple Students for Same Course

**Example: MED101 Fall2026 class with 20 students**

1. Open **Student A's page** → Grades tab → "Open Calculator"
   - Prompted: MED101, Fall2026
   - Enter Student A's grades
   - Auto-saves ✓

2. Open **Student B's page** → Grades tab → "Open Calculator"
   - Prompted: MED101, Fall2026
   - Enter Student B's grades (separate record)
   - Auto-saves ✓

3. Each student has **isolated, independent** calculator
4. No data mixing or overwriting
5. Each can be finalized separately

---

## Benefits of Personalization

### ✅ Data Integrity
- No risk of entering grades in wrong student's calculator
- Clear visual indication whose grades you're working on
- Student name locked to prevent accidental changes

### ✅ Workflow Efficiency
- No manual student selection in calculator
- Pre-filled information saves time
- Auto-load prevents re-entering data

### ✅ Audit Trail
- Each grade tied to specific student/course/semester
- Timestamps show when grades entered
- Finalization locks prevent tampering

### ✅ Multi-Course Support
- Same student can have grades for multiple courses
- Each course isolated in its own calculator
- Easy to manage semester-by-semester

---

## Security & Privacy

### Access Control
- **Current:** Open from any student page (testing)
- **Production:** Should verify admin credentials
- **Future:** Log who accessed which student's calculator

### Data Isolation
- Each student's data completely separate
- No cross-contamination possible
- Unique database record per student/course/semester

### Finalization Lock
- Once finalized → read-only forever
- Prevents post-grade tampering
- Only super-admin can unlock (manual SQL)

---

## Troubleshooting

### Issue: "No student selected"
**Cause:** Opened calculator directly without student context  
**Fix:** Always open via "Open Calculator" button on student page

### Issue: Wrong student name showing
**Cause:** Student page loaded wrong student  
**Fix:** Verify URL has correct `?id=` parameter

### Issue: Calculator empty when student has grades
**Cause:** Different course/semester than saved data  
**Fix:** Enter exact same course code and semester as before

### Issue: Can't edit existing grades
**Cause:** Grades were finalized  
**Fix:** Check for "🔒 FINALIZED" banner (intended behavior)

---

## Future Enhancements

### Phase 2
- [ ] **Course Dropdown** - Select from student's enrolled courses
- [ ] **Semester Selector** - Pick from available semesters
- [ ] **Bulk Grading** - Grade multiple students in same course at once
- [ ] **Grade History** - View all past grades for student

### Phase 3
- [ ] **Student View** - Read-only calculator for students to see their grades
- [ ] **Email Notification** - Auto-notify student when grades finalized
- [ ] **Grade Comparison** - Compare student's grades to class average
- [ ] **Progress Tracking** - See grade trends across semesters

---

## Summary

**Before:** Generic calculator, no student context  
**After:** Personalized calculator for each student

**Key Changes:**
1. ✅ Student info passed via URL parameters
2. ✅ Name and course pre-filled from context
3. ✅ Database saves by student/course/semester (unique)
4. ✅ Auto-loads existing grades when reopened
5. ✅ Clear visual banner showing whose grades

**Result:** Each student has their own calculator that remembers their grades and auto-saves their progress! 🎉

---

**Version:** 1.1 (Personalized)  
**Date:** January 13, 2026  
**Feature:** Per-Student Grade Calculators
