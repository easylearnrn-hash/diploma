# Student Login Identity Fix - Complete ✅

## Problem
Students were logging in but seeing different/wrong names on the Student Portal page. This happened because:

1. **Login stored one email** (e.g., `j.doe@acnhs.am`)
2. **Student-page.html looked up by email** in `acnhs_students.email` column
3. **Email didn't match** because the student record had a different email stored

## Solution Implemented

### 1. Enhanced Student Lookup (Student-page.html)
Now tries **6 different lookup methods** in priority order:

**Priority 1:** `studentRecordId` (acnhs_students.id) - **Most Reliable**
- Stored during successful login
- Primary key lookup - fastest & most accurate

**Priority 2:** `student_id` (e.g., ACNHS-0000123)
- Unique student identifier
- Stored in sessionStorage during login

**Priority 3:** `email` (acnhs_students.email column)
- Direct email column lookup
- Normalized (lowercase, trimmed)

**Priority 4:** `metadata->institutional_email`
- Checks JSONB field for institutional email
- Matches campus emails like `j.doe@acnhs.am`

**Priority 5:** `metadata->portal->institutional_email`
- Nested JSONB field check
- Additional fallback for complex metadata structures

**Priority 6:** `application_id`
- Links back to original application
- Last resort if other methods fail

### 2. Login Enhancement (login.html)
Now fetches and stores complete student record during login:

```javascript
// NEW: Fetch linked student record
const studentRecord = await fetchLinkedStudentRecord(supabase, application);

// Store full context
persistStudentPortalSession(application, { 
  loginEmail: normalizedEmail,
  studentRecord: studentRecord  // ← Now includes full student data
});
```

### 3. Session Storage Keys
After successful login, these are stored:

```javascript
sessionStorage.setItem('studentRecordId', studentRecord.id);      // ← NEW! Primary key
sessionStorage.setItem('userId', studentId);                      // ACNHS-xxxxxxx
sessionStorage.setItem('userEmail', institutionalEmail);          // Campus email
sessionStorage.setItem('studentInstitutionalEmail', campusEmail); // Campus email
sessionStorage.setItem('studentPersonalEmail', personalEmail);    // Personal email
sessionStorage.setItem('studentApplicationId', applicationId);    // Application ID
```

## Testing Instructions

### Test 1: Fresh Login
1. **Clear browser storage**: Open DevTools → Application → Clear Storage → Clear all
2. **Login as a student** using their credentials
3. **Check console logs** - you should see:
   ```
   ✅ Student found by record ID: <uuid>
   ```
4. **Verify name** - Should display correct student name at top of page

### Test 2: Different Students
1. **Login as Student A** → Verify correct name shows
2. **Logout** (or clear storage)
3. **Login as Student B** → Verify Student B's name (not A's!) shows
4. **Check console** - should show which lookup method succeeded

### Test 3: Existing Sessions
1. **Login as a student**
2. **Refresh page** → Should still show correct name
3. **Close browser tab**
4. **Reopen** `Student-page.html` → Should still be logged in with correct data

## Debugging

### If Wrong Name Still Appears

**Step 1: Check Console Logs**
```javascript
console.log('Session data:', {
  studentRecordId: sessionStorage.getItem('studentRecordId'),
  userId: sessionStorage.getItem('userId'),
  userEmail: sessionStorage.getItem('userEmail')
});
```

**Step 2: Check Database**
Open Supabase SQL Editor and run:
```sql
-- Find student record by email
SELECT id, student_id, full_name, email, 
       metadata->>'institutional_email' as meta_email,
       metadata->'portal'->>'institutional_email' as portal_email
FROM acnhs_students
WHERE email = 'student@acnhs.am'
   OR metadata->>'institutional_email' = 'student@acnhs.am'
   OR metadata->'portal'->>'institutional_email' = 'student@acnhs.am';
```

**Step 3: Check Application Record**
```sql
-- Find application record
SELECT id, applicant_name, email, username, status,
       payload->>'institutionalEmail' as inst_email,
       payload->>'studentEmail' as student_email
FROM applications
WHERE email = 'student@acnhs.am'
   OR username = 'j.doe.1234'
   OR payload->>'institutionalEmail' = 'student@acnhs.am';
```

**Step 4: Check Linkage**
```sql
-- Verify application ↔ student linkage
SELECT 
  a.id as app_id,
  a.applicant_name,
  a.email as app_email,
  s.id as student_id,
  s.student_id as student_number,
  s.full_name,
  s.email as student_email,
  s.application_id
FROM applications a
LEFT JOIN acnhs_students s ON s.application_id = a.id
WHERE a.email = 'student@acnhs.am'
   OR s.email = 'student@acnhs.am';
```

### Common Issues & Fixes

**Issue: Student record not found**
```
❌ Student not found. Tried: { studentRecordId: null, studentId: null, email: 'student@acnhs.am' }
```
**Fix:** Student record doesn't exist in `acnhs_students` table
```sql
-- Check if student was created
SELECT COUNT(*) FROM acnhs_students WHERE email ILIKE '%student%';
```

**Issue: Multiple student records found**
```
⚠️ Found multiple students - using first result
```
**Fix:** Duplicate records in database
```sql
-- Find duplicates
SELECT email, COUNT(*) 
FROM acnhs_students 
GROUP BY email 
HAVING COUNT(*) > 1;
```

**Issue: Email mismatch**
```
✅ Student found by metadata.portal.institutional_email: j.doe@acnhs.am
```
**Fix:** Update `acnhs_students.email` column to match:
```sql
UPDATE acnhs_students
SET email = metadata->'portal'->>'institutional_email'
WHERE email IS NULL 
  AND metadata->'portal'->>'institutional_email' IS NOT NULL;
```

## Files Changed

1. **Student-page.html** (lines ~1236-1330)
   - Enhanced `fetchStudentProfile()` function
   - 6 priority-based lookup methods
   - Automatic `studentRecordId` caching

2. **login.html** (lines ~1184-1235)
   - Updated `authenticateStudentPortalLogin()` function
   - Now fetches `studentRecord` before session persistence
   - Passes full context to `persistStudentPortalSession()`

## Success Criteria

✅ Each student sees **their own name** when logged in
✅ Refreshing page shows **same student's data**
✅ Logging out then logging in as different student shows **different data**
✅ Console shows which lookup method succeeded
✅ No "Student not found" errors for valid enrolled students

## Next Steps

1. **Test with real student accounts** - Try 3-5 different students
2. **Monitor console logs** - Verify correct lookup methods are used
3. **Check error rates** - If >10% of students fail lookup, investigate database schema
4. **Document any edge cases** - Note any students who still have issues

## Support

If issues persist:
1. Export student's `acnhs_students` record (SQL query above)
2. Export student's `applications` record (SQL query above)
3. Check browser console for error messages
4. Verify `application_id` column matches between tables
