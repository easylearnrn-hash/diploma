# Student Record Auto-Provisioning Troubleshooting

## Issue Summary
When changing an application status to "ENROLLED" in the admin panel, the system should automatically:
1. Create a student record in `acnhs_students` table
2. Generate a unique student ID (format: ACNHS-YYYYMMDD-XXXX)
3. Provision institutional email (e.g., h.vardan@acnhs.am)
4. Update application payload with student information

**Problem:** For Hrach Vardan (username: hrach.vardan.5789), this automatic provisioning failed silently, causing Student Login tab to fail with "campus login has not been provisioned yet" error.

## How Auto-Provisioning Works

### Code Location
`admin-applications.html` lines 5960-5990 and 6136-6166

### Trigger Logic
```javascript
function shouldAutoCreateStudent(status = '') {
  const normalized = (status || '').toString().trim().toLowerCase();
  if (!normalized) return false;
  return ['approve', 'confirm', 'accept', 'admit', 'enroll'].some(keyword => 
    normalized.includes(keyword)
  );
}
```

When status update includes keywords: **approve**, **confirm**, **accept**, **admit**, or **enroll** (case-insensitive), the system:

1. Calls `ensureStudentRecordLinked()` → checks for existing student record, creates if missing
2. Calls `ensureEnrollmentProvisioned()` → updates institutional email and metadata

### Success Flow
```
Status Change to "ENROLLED"
    ↓
shouldAutoCreateStudent() → true
    ↓
ensureStudentRecordLinked() → creates acnhs_students record
    ↓
ensureEnrollmentProvisioned() → sets h.vardan@acnhs.am email
    ↓
Student Login tab authentication works
```

### Failure Flow (What Happened)
```
Status Change to "ENROLLED"
    ↓
shouldAutoCreateStudent() → true
    ↓
ensureStudentRecordLinked() → ERROR (silent failure)
    ↓
Status update completes BUT student record missing
    ↓
Student Login tab fails with provisioning error
```

## Why It Failed

### Possible Root Causes

1. **Database Table Missing**
   - `acnhs_students` table didn't exist when status was changed
   - Error: "relation 'public.acnhs_students' does not exist"
   - **Fix:** Run `CREATE-ACNHS-STUDENTS-TABLE.sql` in Supabase

2. **RLS Policy Blocking Insert**
   - Anonymous user can't INSERT into `acnhs_students`
   - **Fix:** Add policy:
   ```sql
   CREATE POLICY "Allow anon insert students"
   ON public.acnhs_students FOR INSERT
   TO anon WITH CHECK (true);
   ```

3. **Constraint Violation**
   - Unique constraint on `student_id` or `email` failed
   - Rare due to random ID generation
   - **Check:** Query for existing records with same email

4. **JavaScript Error in Browser Console**
   - Network timeout during Supabase call
   - Browser console error not caught properly
   - **Check:** Browser DevTools Console for red errors

5. **Payload Data Issues**
   - Missing required fields in application payload
   - Date parsing errors (dob format)
   - **Check:** Inspect `applications.payload` JSON structure

## How to Check What Went Wrong

### 1. Check Browser Console (During Status Update)
Open DevTools Console and look for:
```javascript
// Success indicators:
✅ Student record created: { student_id: "ACNHS-20250126-XXXX" }
✅ Enrollment provisioned: { institutionalEmail: "h.vardan@acnhs.am" }

// Error indicators:
❌ Failed to create student record for approved application
❌ relation "public.acnhs_students" does not exist
❌ duplicate key value violates unique constraint
❌ Network request failed
```

### 2. Check Supabase Logs
Dashboard → Logs → Filter by "acnhs_students"
Look for INSERT errors around the time status was changed

### 3. Verify Table Exists
```sql
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'acnhs_students'
);
```

### 4. Check RLS Policies
```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename = 'acnhs_students';
```

### 5. Inspect Application Payload
```sql
SELECT 
  id,
  applicant_name,
  status,
  payload->>'studentId' AS has_student_id,
  payload->>'institutionalEmail' AS has_institutional_email,
  payload
FROM applications
WHERE username = 'hrach.vardan.5789';
```

## Manual Fix (Immediate Solution)

Run `MANUAL-PROVISION-HRACH-VARDAN.sql` in Supabase SQL Editor:
- Generates unique student ID
- Creates acnhs_students record
- Links to application
- Updates application payload
- Sets institutional email to h.vardan@acnhs.am

**After running:**
1. Refresh admin-applications.html
2. Student Login tab should work with h.vardan@acnhs.am
3. Credentials drawer shows student ID

## Prevention Strategy

### For Future Enrollments

1. **Pre-Flight Check**
   Before marking as ENROLLED, verify:
   ```javascript
   // Add to admin-applications.html status update modal
   async function validateEnrollmentReadiness(app) {
     const checks = {
       tableExists: await checkTableExists('acnhs_students'),
       rlsPolicyOk: await checkInsertPolicy('acnhs_students'),
       payloadValid: validatePayload(app.payload),
       credentialsSet: app.username && app.password_hash
     };
     
     if (!Object.values(checks).every(Boolean)) {
       throw new Error('System not ready for enrollment: ' + JSON.stringify(checks));
     }
   }
   ```

2. **Better Error Handling**
   Replace silent try-catch with user-facing alerts:
   ```javascript
   try {
     studentLinkResult = await ensureStudentRecordLinked(supabase, currentApp);
   } catch (studentError) {
     // Show error modal to admin
     alert(`⚠️ Student record creation failed!\n\n${studentError.message}\n\nStatus will not be changed. Please contact support.`);
     return; // Don't proceed with status update
   }
   ```

3. **Retry Logic**
   Add automatic retry for network failures:
   ```javascript
   async function ensureStudentRecordLinkedWithRetry(supabase, app, retries = 3) {
     for (let i = 0; i < retries; i++) {
       try {
         return await ensureStudentRecordLinked(supabase, app);
       } catch (error) {
         if (i === retries - 1) throw error;
         await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
       }
     }
   }
   ```

4. **Status Update Success Modal**
   After successful ENROLLED update, show confirmation:
   ```
   ✅ Status updated to ENROLLED
   
   Student Record Created:
   - Student ID: ACNHS-20250126-5432
   - Institutional Email: h.vardan@acnhs.am
   - Portal Username: hrach.vardan.5789
   
   Student can now log in via Student Login tab.
   ```

## Testing Procedure

### Test Auto-Provisioning End-to-End

1. Create test application via admission form
2. Set admin credentials (username/password)
3. In admin panel, change status to "ENROLLED"
4. **Verify in Console:** No red errors appear
5. **Verify in Supabase:** Query `acnhs_students` for new record
6. **Verify Login:** Use Student Login tab with institutional email
7. **Expected:** Login succeeds, sees student portal

### Rollback Plan if Provisioning Fails Again

```sql
-- Delete orphaned student record
DELETE FROM acnhs_students 
WHERE application_id = (
  SELECT id FROM applications WHERE username = 'hrach.vardan.5789'
);

-- Reset application status and payload
UPDATE applications
SET 
  status = 'APPROVED',
  payload = payload - 'studentId' - 'studentRecordId' - 'institutionalEmail' - 'studentPortal' - 'enrollmentProvisionedAt',
  updated_at = NOW()
WHERE username = 'hrach.vardan.5789';

-- Retry status change in admin panel
```

## Related Documentation
- `CREATE-ACNHS-STUDENTS-TABLE.sql` - Table schema
- `ACNHS-STUDENTS-TABLE-SETUP.md` - Setup guide
- `WIRING-COMPLETE.md` - Data flow diagrams
- `login.html` - Student authentication logic (lines 450-550)

## Contact
If auto-provisioning continues to fail after manual fix:
1. Export browser console logs (right-click → Save as...)
2. Export Supabase logs for timestamp range
3. Check if `CREATE-ACNHS-STUDENTS-TABLE.sql` was run
4. Verify RLS policies allow anonymous inserts (testing phase)
