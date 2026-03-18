-- ============================================================
-- Delete "Thyroid Gland and Its Hormones" topic and its questions
-- Run in: Supabase Dashboard → SQL Editor
-- ============================================================

-- 1. Delete all questions belonging to this topic
DELETE FROM public.test_questions
WHERE topic_id = (
  SELECT id FROM public.test_topics
  WHERE name ILIKE 'Thyroid Gland and Its Hormones'
  LIMIT 1
);

-- 2. Delete the topic itself
DELETE FROM public.test_topics
WHERE name ILIKE 'Thyroid Gland and Its Hormones';

-- 3. Verify — both should return 0 rows
SELECT * FROM public.test_topics WHERE name ILIKE 'Thyroid Gland and Its Hormones';
SELECT * FROM public.test_questions WHERE category ILIKE 'Thyroid Gland and Its Hormones';
