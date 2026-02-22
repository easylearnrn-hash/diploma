-- ============================================
-- ADD SUBJECTS COLUMN TO TEACHERS TABLE
-- Purpose: Store which subject categories a teacher teaches
-- This drives notes filtering in the teacher hub
-- Run in: Supabase SQL Editor
-- ============================================

ALTER TABLE teachers
  ADD COLUMN IF NOT EXISTS subjects TEXT[] DEFAULT '{}';

-- Index for fast subject lookups
CREATE INDEX IF NOT EXISTS idx_teachers_subjects ON teachers USING GIN(subjects);

-- Verify
SELECT id, full_name, subjects FROM teachers LIMIT 5;
