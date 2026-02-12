-- 🔍 VERIFY NOTES ARE SAVING TO SUPABASE
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr

-- 1. Check all your saved notes
SELECT 
  student_id,
  LEFT(notes, 100) as note_preview,
  LENGTH(notes) as note_length,
  updated_at,
  created_at
FROM admin_private_notes
WHERE admin_email = 'hrachfilm@gmail.com'
ORDER BY updated_at DESC;

-- 2. Check for problematic empty notes (should be ZERO after fix)
SELECT 
  student_id,
  notes,
  updated_at
FROM admin_private_notes
WHERE admin_email = 'hrachfilm@gmail.com'
  AND (notes = '' OR notes IS NULL)
ORDER BY updated_at DESC;

-- 3. Count total notes vs empty notes
SELECT 
  COUNT(*) as total_notes,
  COUNT(CASE WHEN notes = '' OR notes IS NULL THEN 1 END) as empty_notes,
  COUNT(CASE WHEN LENGTH(notes) > 0 THEN 1 END) as valid_notes
FROM admin_private_notes
WHERE admin_email = 'hrachfilm@gmail.com';

-- 4. Find Robert Zakaryan's note (if it exists)
SELECT 
  *
FROM admin_private_notes
WHERE admin_email = 'hrachfilm@gmail.com'
  AND student_id ILIKE '%robert%zakaryan%'
ORDER BY updated_at DESC;

-- 5. Recent note activity (last 24 hours)
SELECT 
  student_id,
  LEFT(notes, 50) as note_preview,
  updated_at,
  created_at,
  (NOW() - updated_at) as time_since_update
FROM admin_private_notes
WHERE admin_email = 'hrachfilm@gmail.com'
  AND updated_at > NOW() - INTERVAL '24 hours'
ORDER BY updated_at DESC;

-- 6. Check table structure (verify columns exist)
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns
WHERE table_name = 'admin_private_notes'
ORDER BY ordinal_position;
