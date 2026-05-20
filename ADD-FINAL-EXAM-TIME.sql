-- ══════════════════════════════════════════════════════════════
--  Add final_exam_time column to students table
--  Run this in: https://supabase.com/dashboard → SQL Editor
-- ══════════════════════════════════════════════════════════════

ALTER TABLE students ADD COLUMN IF NOT EXISTS final_exam_time TEXT;

-- final_exam_time stores the exam time in Armenia Time (Asia/Yerevan)
-- as "HH:MM" 24-hour format, e.g. "14:30"
