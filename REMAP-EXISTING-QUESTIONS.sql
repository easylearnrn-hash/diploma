-- ============================================
-- REMAP EXISTING 50 QUESTIONS TO TOPIC #1
-- ============================================
-- Run this AFTER ADD-SUBJECTS-TOPICS-TABLE.sql
-- All 50 existing questions belong to Topic 1: "Fundamentals"

-- Background:
-- The original 50 questions cover various fundamental nursing concepts:
-- - Infection control & precautions
-- - Vital signs interpretation
-- - Physical assessment techniques
-- - Documentation & informatics
-- - Informed consent scenarios
-- - SBAR communication
-- - Client positioning
-- - Care with tubes
-- - And other core fundamentals

-- These are all general overview questions for the "Fundamentals" topic.
-- Topics 2-29 are specialized topics that will need their own questions added later.

-- ============================================
-- DIAGNOSTIC: Check current state BEFORE update
-- ============================================
-- Run this first to see what we're working with
SELECT 
  'BEFORE UPDATE' as status,
  COUNT(*) as total_questions,
  COUNT(CASE WHEN topic_id IS NULL THEN 1 END) as null_topic_id,
  COUNT(CASE WHEN topic_id = '20000000-0000-0000-0000-000000000001' THEN 1 END) as already_fundamentals,
  COUNT(CASE WHEN topic_id IS NOT NULL AND topic_id != '20000000-0000-0000-0000-000000000001' THEN 1 END) as other_topics
FROM test_questions 
WHERE test_id = '00000000-0000-0000-0000-000000000001';

-- ============================================
-- UPDATE: Assign ALL existing questions to Topic 1 (Fundamentals)
-- ============================================
-- This will reassign any questions that might have been mapped to other topics
UPDATE test_questions 
SET topic_id = '20000000-0000-0000-0000-000000000001'
WHERE test_id = '00000000-0000-0000-0000-000000000001';

-- ============================================
-- VERIFICATION
-- ============================================

-- Show question count for Fundamentals topic
SELECT 
  t.name as topic_name,
  COUNT(q.id) as question_count
FROM test_topics t
LEFT JOIN test_questions q ON q.topic_id = t.id 
  AND q.test_id = '00000000-0000-0000-0000-000000000001'
WHERE t.id = '20000000-0000-0000-0000-000000000001'
GROUP BY t.id, t.name;
-- Expected: Fundamentals with 50 questions

-- Verify all 50 questions are now mapped to topic 1
SELECT COUNT(*) as total_questions_in_fundamentals
FROM test_questions 
WHERE test_id = '00000000-0000-0000-0000-000000000001'
  AND topic_id = '20000000-0000-0000-0000-000000000001';
-- Expected: 50
