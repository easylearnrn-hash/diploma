-- Add grade_items column to courses table if it doesn't exist
-- Run this in Supabase SQL Editor

-- Add the column
ALTER TABLE courses 
ADD COLUMN IF NOT EXISTS grade_items JSONB DEFAULT '[]'::jsonb;

-- Update NUR101 to have empty grade items array
UPDATE courses 
SET grade_items = '[]'::jsonb 
WHERE code = 'NUR101' AND (grade_items IS NULL OR grade_items::text = 'null');

-- Verify
SELECT code, name, semester, grade_items FROM courses WHERE code = 'NUR101';
