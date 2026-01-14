-- TEST: Send a test email and see if it gets saved
-- Step 1: Check current count
SELECT 
  'BEFORE TEST' as stage,
  COUNT(*) as email_count,
  MAX(sent_at) as last_email_time
FROM email_history;

-- Step 2: Manually insert a test email
INSERT INTO email_history (
  recipient,
  sender,
  subject,
  body,
  html_body,
  status,
  sent_at,
  resend_id
) VALUES (
  'manual-test@example.com',
  'admissions@acnhs.am',
  'Manual Test - ' || NOW()::text,
  'Testing if emails stay in database',
  '<p>Testing if emails stay in database</p>',
  'sent',
  NOW(),
  'manual-' || gen_random_uuid()::text
);

-- Step 3: Check count again immediately
SELECT 
  'AFTER INSERT' as stage,
  COUNT(*) as email_count,
  MAX(sent_at) as last_email_time
FROM email_history;

-- Step 4: Check for any DELETE triggers or policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE tablename = 'email_history'
  AND cmd = 'DELETE';

-- Step 5: Wait 5 seconds and check again (run this separately after 5 seconds)
-- SELECT 
--   'AFTER 5 SECONDS' as stage,
--   COUNT(*) as email_count,
--   MAX(sent_at) as last_email_time
-- FROM email_history;
