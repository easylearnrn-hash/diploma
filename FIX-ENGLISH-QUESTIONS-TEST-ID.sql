-- ============================================
-- FIX: Move English questions to the shared
-- test_id used by the Subject/Topic UI
-- ============================================
-- The subject/topic selector in test.html uses
-- test_id from the URL (default: 000...0001).
-- All other subject question files use test_id
-- 00000000-0000-0000-0000-000000000001.
--
-- Your English questions were inserted under
-- test_id 000...0025, so the UI shows 0.
--
-- This script moves all English questions to
-- test_id 000...0001 so the UI can see them.

-- Step 1: Move questions to shared test_id
UPDATE test_questions
SET test_id = '00000000-0000-0000-0000-000000000001'
WHERE test_id = '00000000-0000-0000-0000-000000000025';

-- Step 2: Verify counts under shared test_id
SELECT
  'English questions in shared test_id' AS check_name,
  COUNT(*) AS count
FROM test_questions
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id IN (
    '20000000-0000-0000-0000-000000000396',
    '20000000-0000-0000-0000-000000000397',
    '20000000-0000-0000-0000-000000000398',
    '20000000-0000-0000-0000-000000000399',
    '20000000-0000-0000-0000-000000000400',
    '20000000-0000-0000-0000-000000000401',
    '20000000-0000-0000-0000-000000000402',
    '20000000-0000-0000-0000-000000000403'
  );

-- ============================================
-- Optional: If you want English as its OWN test
-- instead, open:
-- test.html?test_id=00000000-0000-0000-0000-000000000025
-- ============================================
