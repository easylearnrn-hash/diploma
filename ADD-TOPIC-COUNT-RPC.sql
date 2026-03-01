-- ============================================================
-- Performance Fix: get_topic_question_counts RPC
-- Run this in Supabase SQL Editor once.
--
-- Replaces the slow paginated JavaScript loop that fetched
-- ALL questions page-by-page just to count them per topic.
-- This single server-side function does the GROUP BY in the
-- database and returns one row per topic — much faster.
-- ============================================================

CREATE OR REPLACE FUNCTION get_topic_question_counts()
RETURNS TABLE(topic_id UUID, question_count BIGINT)
LANGUAGE SQL
STABLE
SECURITY DEFINER
AS $$
  SELECT topic_id, COUNT(*)::BIGINT AS question_count
  FROM test_questions
  WHERE is_active = TRUE AND topic_id IS NOT NULL
  GROUP BY topic_id;
$$;

-- Allow anonymous (frontend) access
GRANT EXECUTE ON FUNCTION get_topic_question_counts() TO anon;
GRANT EXECUTE ON FUNCTION get_topic_question_counts() TO authenticated;
