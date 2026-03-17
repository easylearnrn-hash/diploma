-- ============================================
-- ADD shuffle_seed COLUMN TO saved_test_sessions
-- ============================================
-- Stores the exact shuffle seed used when the session was created so that
-- option order is perfectly reproduced on resume (instead of re-deriving
-- the seed from selectedTopicIds, which could differ in array order).
--
-- Run this in: Supabase Dashboard → SQL Editor

ALTER TABLE IF EXISTS saved_test_sessions
  ADD COLUMN IF NOT EXISTS shuffle_seed BIGINT;
