-- Create Initial Student Groups for Video Library
-- Run this AFTER running ADD-VIDEO-GROUP-ACCESS.sql

-- Check if groups already exist
SELECT id, name, semester FROM student_groups ORDER BY name;

-- Insert initial academic year groups (if they don't exist)
INSERT INTO student_groups (id, name, semester, student_ids)
VALUES 
  ('2024-2025', '2024-2025', 'Academic Year 2024-2025', ARRAY[]::TEXT[]),
  ('2025-2026', '2025-2026', 'Academic Year 2025-2026', ARRAY[]::TEXT[]),
  ('2026-2027', '2026-2027', 'Academic Year 2026-2027', ARRAY[]::TEXT[]),
  ('RN-Track', 'RN Track', 'All Years', ARRAY[]::TEXT[]),
  ('LPN-Track', 'LPN Track', 'All Years', ARRAY[]::TEXT[])
ON CONFLICT (id) DO NOTHING;

-- Verify groups created
SELECT id, name, semester, array_length(student_ids, 1) as student_count 
FROM student_groups 
ORDER BY name;

-- Test query: Check what groups are available for video library
SELECT name FROM student_groups ORDER BY name;
