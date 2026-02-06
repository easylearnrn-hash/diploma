-- RECOVER PASSWORDS FOR EXISTING ENROLLED STUDENTS
-- Run this to check which students need password reset

-- Check students with "NeedReset" password
SELECT 
  a.id,
  a.reference_number,
  a.applicant_name,
  a.username,
  a.plain_password,
  a.status,
  a.submission_date
FROM applications a
WHERE a.plain_password = 'NeedReset'
  AND a.status = 'ENROLLED'
ORDER BY a.applicant_name;

-- EXPLANATION:
-- These students were enrolled BEFORE the plain_password column was added.
-- Their original passwords were generated during admission but not stored in plain text.
-- The password_hash is still valid, but we can't recover the plain text password.

-- SOLUTION:
-- Use the Settings tab to reset their passwords:
-- 1. Open student profile in admin-student-page.html
-- 2. Go to Settings tab
-- 3. Click "Reset Password" button
-- 4. Enter new password (min 8 characters)
-- 5. New password will be stored in plain_password and password_hash

-- ALTERNATIVE: Set a temporary password for all affected students
-- Uncomment and modify this if you want to set a standard temporary password:
/*
UPDATE applications
SET plain_password = 'TempPass2026!'
WHERE plain_password = 'NeedReset'
  AND status = 'ENROLLED';

-- Then notify students to login with:
-- Username: their institutional email (e.g., n.avetisyan7022395@acnhs.am)
-- Password: TempPass2026!
-- They should change password after first login
*/
