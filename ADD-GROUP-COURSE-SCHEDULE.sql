-- Add Course Schedule System for Student Groups
-- This allows each group to have specific courses scheduled on specific days
-- Run this in Supabase SQL Editor

-- Create group_course_schedule table
CREATE TABLE IF NOT EXISTS group_course_schedule (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id TEXT NOT NULL REFERENCES student_groups(id) ON DELETE CASCADE,
  course_code TEXT NOT NULL,
  course_name TEXT NOT NULL,
  semester TEXT NOT NULL,
  
  -- Days of the week (true = class day, false = no class)
  monday BOOLEAN DEFAULT false,
  tuesday BOOLEAN DEFAULT false,
  wednesday BOOLEAN DEFAULT false,
  thursday BOOLEAN DEFAULT false,
  friday BOOLEAN DEFAULT false,
  saturday BOOLEAN DEFAULT false,
  sunday BOOLEAN DEFAULT false,
  
  -- Optional time information
  start_time TIME,
  end_time TIME,
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by TEXT,
  
  -- Prevent duplicate course schedules for same group
  UNIQUE(group_id, course_code, semester)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_group_course_schedule_group 
ON group_course_schedule(group_id);

CREATE INDEX IF NOT EXISTS idx_group_course_schedule_course 
ON group_course_schedule(course_code);

-- Add RLS policies (allow anon for testing, lock down later)
ALTER TABLE group_course_schedule ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow anon to read group_course_schedule"
ON group_course_schedule FOR SELECT
TO anon
USING (true);

CREATE POLICY "Allow anon to insert group_course_schedule"
ON group_course_schedule FOR INSERT
TO anon
WITH CHECK (true);

CREATE POLICY "Allow anon to update group_course_schedule"
ON group_course_schedule FOR UPDATE
TO anon
USING (true);

CREATE POLICY "Allow anon to delete group_course_schedule"
ON group_course_schedule FOR DELETE
TO anon
USING (true);

-- Verify table was created
SELECT * FROM group_course_schedule LIMIT 1;

COMMENT ON TABLE group_course_schedule IS 'Stores which courses are taught on which days for each student group';
