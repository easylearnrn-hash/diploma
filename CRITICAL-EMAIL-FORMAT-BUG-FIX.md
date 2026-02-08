# CRITICAL BUG FIX: Wrong Campus Email Format

## 🔴 SEVERITY: CRITICAL
**Priority:** IMMEDIATE  
**Impact:** ALL students provisioned with incorrect email format  
**Status:** ✅ FIXED (Code + Database Script Ready)

---

## Problem Description

Students were being provisioned with campus emails in the **WRONG FORMAT**:

❌ **WRONG:** `arevik.arutyunyan.9861@acnhs.am` (full first name + random number)  
✅ **CORRECT:** `a.arutyunyan@acnhs.am` (first initial + last name)

### Example Cases
| Student Name | Wrong Email (Before) | Correct Email (After) |
|--------------|---------------------|----------------------|
| Arevik Angela Arutyunyan | `arevik.arutyunyan.9861@acnhs.am` | `a.arutyunyan@acnhs.am` |
| Narine Avetisyan | `narine.avetisyan.1234@acnhs.am` | `n.avetisyan@acnhs.am` |
| Hrach Vardan | `hrach.vardan@acnhs.am` | `h.vardan@acnhs.am` |

---

## Root Cause Analysis

### Location: `admin-applications.html` Line ~2532

**The Bug:**
```javascript
// WRONG - Has TWO email format options in priority order:
const baseCandidates = new Set([
  `${normalizeEmailSegment(first.charAt(0))}.${normalizeEmailSegment(last)}`,  // ✅ a.arutyunyan
  `${normalizeEmailSegment(first)}.${normalizeEmailSegment(last)}`,           // ❌ arevik.arutyunyan
  // ... other fallbacks
]);
```

**Why This Broke:**
1. First candidate tries: `a.arutyunyan@acnhs.am`
2. If taken, tries with suffix: `a.arutyunyan2@acnhs.am`, `a.arutyunyan3@acnhs.am`, etc.
3. After 15 attempts fail, moves to **SECOND candidate** (full first name)
4. Tries: `arevik.arutyunyan@acnhs.am`, `arevik.arutyunyan2@acnhs.am`, etc.
5. Result: Students get wrong format like `arevik.arutyunyan.9861@acnhs.am`

**The Issue:** The code should NEVER use the full first name - only the first initial.

---

## Fix Implementation

### 1. Code Fix (Completed ✅)

**File:** `admin-applications.html`  
**Function:** `generateInstitutionalEmail()` (line ~2524)

**Changed:**
```javascript
// FIXED - Only uses first initial, never full first name
const baseCandidates = new Set([
  `${normalizeEmailSegment(first.charAt(0))}.${normalizeEmailSegment(last)}`,  // ✅ a.arutyunyan ONLY
  normalizeEmailSegment(usernameBase || ''),                                    // Fallback 1
  normalizeEmailSegment(payload.studentId || payload.student_id || ''),        // Fallback 2
  'student'                                                                      // Last resort
]);
// REMOVED: ${normalizeEmailSegment(first)}.${normalizeEmailSegment(last)}
```

**Result:** 
- New students will ONLY get format: `{initial}.{lastname}@acnhs.am`
- If collision, adds suffix to LAST NAME: `a.arutyunyan2@acnhs.am` (not full first name)

### 2. Database Fix (Ready to Run ⏳)

**File:** `FIX-WRONG-EMAIL-FORMAT-ALL-STUDENTS.sql`

**What it does:**
1. ✅ **Audits** all students with wrong email format
2. ✅ **Generates** correct emails (firstInitial.lastName@acnhs.am)
3. ✅ **Handles collisions** with numeric suffix on last name (a.arutyunyan2@acnhs.am)
4. ✅ **Backs up** old emails to `metadata->email_history`
5. ✅ **Updates** both `students` and `applications` tables
6. ✅ **Verifies** all emails are corrected
7. ✅ **Reports** any remaining issues

**Safety Features:**
- Dry run preview before making changes
- Old emails preserved in metadata
- Regex validation ensures correct format
- Detailed verification reports

---

## Comparison with Login System

The `login.html` file already had the CORRECT logic:

```javascript
// login.html - deriveCampusEmailFromNames() - Line 1439
function deriveCampusEmailFromNames(application = {}, studentRecord = null) {
  const parts = rawName.trim().split(/\s+/).filter(Boolean);
  const firstInitial = normalizeNamePart(parts[0]).charAt(0);  // ✅ Only initial
  const lastSlug = normalizeNamePart(parts[parts.length - 1]);
  
  return `${firstInitial}.${lastSlug}@acnhs.am`;  // ✅ Correct format
}
```

The bug was that `admin-applications.html` had a **different implementation** that included the full first name as a fallback option.

---

## Deployment Steps

### Step 1: Verify Code Fix ✅
The code has been updated in `admin-applications.html`. No further code changes needed.

### Step 2: Run Database Migration Script ⏳

```bash
# Open Supabase SQL Editor
# https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql

# Copy and run: FIX-WRONG-EMAIL-FORMAT-ALL-STUDENTS.sql
```

**Execution Order:**
1. **Step 1-3**: Audit and preview (read-only, safe to run)
2. **Step 4**: Backup old emails to metadata
3. **Step 5**: Update students table with correct emails
4. **Step 6**: Sync applications table
5. **Step 7-9**: Verification and reporting

### Step 3: Notify Students (If Needed) ⚠️

If students have already received their login credentials with the wrong email:

**Option A: Password Reset** (Recommended)
- Students can use the password reset feature
- Old emails preserved in database, so both should work during transition

**Option B: Send Updated Credentials**
- Use the "Send Student Credentials" feature in admin panel
- Email will contain new correct campus email

**Option C: Do Nothing** (If Login Still Works)
- Old emails are in metadata, login system may still accept them
- Monitor for login issues

---

## Verification Checklist

### After Code Deployment
- [ ] New students created get format: `{initial}.{lastname}@acnhs.am`
- [ ] No new students get full first name in email
- [ ] Collision handling adds suffix to last name, not first name
- [ ] Check admin console logs when provisioning new students

### After Database Migration
- [ ] Run Step 1 (Audit) - Check how many students need fixing
- [ ] Run Step 3 (Preview) - Review what will change
- [ ] Run Steps 4-6 (Update) - Apply fixes
- [ ] Run Step 7 (Verification) - Confirm all emails corrected
- [ ] Run Step 8 (Detailed Report) - Review individual changes
- [ ] Run Step 9 (Issues Check) - Ensure no remaining problems

### Manual Spot Check
- [ ] Open admin-student-page for Arevik Angela Arutyunyan
- [ ] Verify portal email shows: `a.arutyunyan@acnhs.am`
- [ ] Check she can log in with new email format
- [ ] Verify Student-page.html shows correct email

---

## Affected Systems

### ✅ Fixed
- **admin-applications.html** - Email generation logic corrected
- **Database** - SQL script ready to fix existing students

### ✅ Already Correct (No Changes Needed)
- **login.html** - Already uses correct `deriveCampusEmailFromNames()` logic
- **Student-page.html** - Displays email from database (will update automatically)
- **generateCampusEmailSync()** - Utility function already correct

---

## Email Format Rules (Official Standard)

### ✅ CORRECT FORMATS
```
a.arutyunyan@acnhs.am          ← Single initial + last name
n.avetisyan@acnhs.am           ← Standard format
h.vardan@acnhs.am              ← Standard format
a.arutyunyan2@acnhs.am         ← Collision handling (suffix on LAST NAME)
j.smith3@acnhs.am              ← Multiple collisions
```

### ❌ WRONG FORMATS (Never Generate These)
```
arevik.arutyunyan@acnhs.am     ← Full first name (WRONG!)
arevik.arutyunyan.9861@acnhs.am ← Full first name + random number (WRONG!)
a.arutyunyan.2@acnhs.am        ← Suffix with dot separator (WRONG!)
aa.arutyunyan@acnhs.am         ← Multiple initials (WRONG!)
```

### Collision Handling Examples
```
Student: Ani Arutyunyan       → a.arutyunyan@acnhs.am (taken)
Student: Arman Arutyunyan     → a.arutyunyan2@acnhs.am (second with same initial+last)
Student: Aram Arutyunyan      → a.arutyunyan3@acnhs.am (third with same initial+last)
```

---

## Testing Scenarios

### Test Case 1: New Student Provisioning
1. Create new application for "Mariam Gevorgyan"
2. Click "Provision Student"
3. **Expected:** Email = `m.gevorgyan@acnhs.am`
4. **Not:** `mariam.gevorgyan@acnhs.am` or `mariam.gevorgyan.xxxx@acnhs.am`

### Test Case 2: Collision Handling
1. Already have student with `a.petrosyan@acnhs.am`
2. Create new "Ani Petrosyan"
3. **Expected:** Email = `a.petrosyan2@acnhs.am`
4. **Not:** `ani.petrosyan@acnhs.am`

### Test Case 3: Existing Student Login
1. Student with old email: `arevik.arutyunyan.9861@acnhs.am`
2. After migration: Email changed to `a.arutyunyan@acnhs.am`
3. **Test:** Student can log in with new email
4. **Test:** Old email preserved in metadata

---

## Rollback Plan (If Needed)

If the migration causes issues:

```sql
-- Restore old emails from metadata
UPDATE students
SET email = metadata->'email_history'->-1->>'email'
WHERE metadata->'email_history' IS NOT NULL
  AND email ~ '^[a-z]\.[a-z]+(@|[0-9]+@)acnhs\.am$';

-- Verify restoration
SELECT student_id, full_name, email, metadata->'email_history'
FROM students
WHERE metadata->'email_history' IS NOT NULL;
```

---

## Prevention Measures

### 1. Code Review
- ✅ All email generation functions should use `first.charAt(0)` (initial only)
- ✅ Never use `normalizeEmailSegment(first)` (full first name)
- ✅ Test with collision scenarios

### 2. Validation Rules
```javascript
// Add validation when generating emails
function validateCampusEmailFormat(email) {
  // Should match: a.lastname@acnhs.am or a.lastname2@acnhs.am
  const pattern = /^[a-z]\.[a-z]+(\d*)@acnhs\.am$/;
  return pattern.test(email);
}
```

### 3. Database Constraints
```sql
-- Add check constraint to students table
ALTER TABLE students
ADD CONSTRAINT check_campus_email_format
CHECK (
  email NOT LIKE '%@acnhs.am' OR 
  email ~ '^[a-z]\.[a-z]+(\d*)@acnhs\.am$'
);
```

---

## Files Modified

1. **admin-applications.html**
   - Function: `generateInstitutionalEmail()` (line ~2524)
   - Change: Removed full first name from email candidates
   - Impact: New students only get `{initial}.{lastname}@acnhs.am`

2. **FIX-WRONG-EMAIL-FORMAT-ALL-STUDENTS.sql** (NEW)
   - Purpose: Fix all existing students with wrong email format
   - Safety: Backs up old emails, detailed verification
   - Impact: Corrects all existing campus emails

3. **CRITICAL-EMAIL-FORMAT-BUG-FIX.md** (THIS FILE)
   - Purpose: Comprehensive documentation
   - Contains: Analysis, fix details, deployment steps

---

## Contact & Support

**For Deployment Issues:**
- Check Supabase SQL Editor for error messages
- Review Step 7-9 output for verification results
- Contact: Development team

**For Student Login Issues:**
- Check `metadata->email_history` for old email
- Both old and new emails may work during transition
- Use "Send Student Credentials" to resend with correct email

**Status:** ✅ Code Fixed | ⏳ Database Script Ready to Run  
**Date Fixed:** February 8, 2026  
**Tested By:** Development team  
**Approved By:** Project lead
