-- ============================================================
-- DIAGNOSTIC: Why can't a student see their published notes?
-- Run this in Supabase SQL Editor to pinpoint the root cause.
-- Replace 'Arevik' with the student's actual name if needed.
-- ============================================================

-- STEP 1: Find the student's UUID and enrollment_status
SELECT
  id,
  full_name,
  student_id,
  email,
  enrollment_status,
  "group"
FROM students
WHERE
  full_name ILIKE '%Arevik%'
  OR full_name ILIKE '%Arutyunyan%';

-- ============================================================
-- STEP 2: Check if any published_notes rows exist for this student
-- (Replace the UUID with the `id` value returned in Step 1)
-- ============================================================

-- Option A: Join via name (no UUID needed)
SELECT
  pn.note_id,
  pn.student_id,
  pn.published_by,
  pn.published_at
FROM published_notes pn
JOIN students s ON s.id = pn.student_id
WHERE
  s.full_name ILIKE '%Arevik%'
  OR s.full_name ILIKE '%Arutyunyan%'
ORDER BY pn.published_at DESC;

-- Option B: Direct UUID lookup (paste UUID from Step 1)
-- SELECT * FROM published_notes WHERE student_id = 'PASTE-UUID-HERE';

-- ============================================================
-- STEP 3: If NO rows returned in Step 2 — fix enrollment_status
-- so she appears in future bulk publish operations
-- ============================================================

-- Check what values exist in the enrollment_status column:
SELECT DISTINCT enrollment_status, COUNT(*) AS student_count
FROM students
GROUP BY enrollment_status
ORDER BY student_count DESC;

-- Fix: Set her enrollment_status to 'active'
-- (Uncomment and run ONLY after confirming her name in Step 1)
/*
UPDATE students
SET enrollment_status = 'active'
WHERE full_name ILIKE '%Arevik%'
  AND (enrollment_status IS NULL OR enrollment_status != 'active');
*/

-- ============================================================
-- STEP 4: List all 15 students who received published notes
-- (to confirm whether Arevik is among them)
-- ============================================================

SELECT
  s.id          AS student_uuid,
  s.full_name,
  s.student_id,
  s.email,
  s.enrollment_status,
  COUNT(pn.note_id) AS notes_published
FROM published_notes pn
JOIN students s ON s.id = pn.student_id
GROUP BY s.id, s.full_name, s.student_id, s.email, s.enrollment_status
ORDER BY s.full_name;

-- ============================================================
-- STEP 5: Emergency direct insert — publish ALL notes to Arevik
-- Run ONLY after confirming her UUID from Step 1 or Step 4.
-- Replace 'PASTE-AREVIK-UUID-HERE' with her actual UUID.
-- ============================================================

/*
INSERT INTO published_notes (note_id, student_id, published_by, published_at)
SELECT
  note_id,
  'PASTE-AREVIK-UUID-HERE',
  'admin-direct-fix',
  NOW()
FROM (
  SELECT DISTINCT note_id FROM published_notes
) existing_notes
ON CONFLICT (note_id, student_id) DO NOTHING;
*/
