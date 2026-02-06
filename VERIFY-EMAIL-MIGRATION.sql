-- Verify Email System is Connected to New Supabase Project
-- Run this in the NEW Supabase project SQL Editor
-- Project: eyhksbiceueoiamwnqpr
-- URL: https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr/sql

-- 1. Check if email_history table exists
SELECT 
  table_name, 
  table_schema 
FROM information_schema.tables 
WHERE table_name = 'email_history';

-- Expected: Should show 1 row with table_name = 'email_history'

-- 2. Check recent emails in the new database
SELECT 
  id,
  recipient,
  subject,
  created_at,
  sent_by_admin
FROM email_history 
ORDER BY created_at DESC 
LIMIT 10;

-- Expected: Should show recent emails after the migration fix

-- 3. Count total emails in new database
SELECT COUNT(*) as total_emails 
FROM email_history;

-- 4. Check if RLS policies allow email insertion
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'email_history';

-- Expected: Should see INSERT policy allowing 'anon' role

-- 5. Test email insertion (simulated)
-- This simulates what the Edge Function does:
INSERT INTO email_history (
  recipient,
  subject,
  body,
  html_body,
  sender,
  sent_by_admin,
  created_at
) VALUES (
  'test@example.com',
  '[TEST] Email System Migration Verification',
  'This is a test email to verify the migration to the new Supabase project.',
  '<p>This is a test email to verify the migration to the new Supabase project.</p>',
  'system@acnhs.am',
  true,
  NOW()
) RETURNING id, recipient, subject, created_at;

-- Expected: Should successfully insert and return the new row
-- If it fails with "permission denied", RLS policies need to be updated

-- 6. Verify the test email was inserted
SELECT 
  id,
  recipient,
  subject,
  created_at
FROM email_history 
WHERE subject LIKE '%Email System Migration Verification%'
ORDER BY created_at DESC 
LIMIT 1;

-- 7. Clean up test email (optional)
-- DELETE FROM email_history WHERE subject LIKE '%Email System Migration Verification%';

-- ========================================
-- EXPECTED RESULTS SUMMARY
-- ========================================
-- ✅ Table email_history exists
-- ✅ RLS policies allow anon INSERT
-- ✅ Test email can be inserted
-- ✅ Recent emails show up after migration fix
-- ========================================
