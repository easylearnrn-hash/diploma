-- Fix admin_private_notes foreign key constraint issue
-- VID uses control_numbers from applications table, not student IDs

-- 1. Drop the foreign key constraint that's causing the issue
ALTER TABLE admin_private_notes 
DROP CONSTRAINT IF EXISTS fk_student;

-- 2. Drop the old constraint name variations
ALTER TABLE admin_private_notes 
DROP CONSTRAINT IF EXISTS admin_private_notes_student_id_fkey;

ALTER TABLE admin_private_notes 
DROP CONSTRAINT IF EXISTS fk_student_id;

-- 3. Make student_id just a regular text field (no foreign key)
-- This allows VID to store control_numbers (ACN-2026-XXXXXX) or student IDs
-- The field is already text, so no need to alter column type

-- 4. Verify the constraint is gone
SELECT 
  conname AS constraint_name,
  contype AS constraint_type
FROM pg_constraint
WHERE conrelid = 'admin_private_notes'::regclass;

-- Expected result: Should NOT show fk_student or any foreign key to students table

-- 5. Test insert with control_number
INSERT INTO admin_private_notes (admin_email, student_id, notes, updated_at)
VALUES (
  'hrachfilm@gmail.com',
  'ACN-2026-812029',
  'Test note - VID foreign key fix',
  NOW()
)
ON CONFLICT (admin_email, student_id) 
DO UPDATE SET 
  notes = EXCLUDED.notes,
  updated_at = EXCLUDED.updated_at;

-- 6. Verify the insert worked
SELECT * FROM admin_private_notes 
WHERE student_id = 'ACN-2026-812029';
