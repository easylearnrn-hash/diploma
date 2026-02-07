-- FIX NARINE'S DATE OF BIRTH
-- Current: December 24, 1986
-- Correct: December 25, 1986

-- Update in students table
UPDATE students
SET date_of_birth = '1986-12-25'
WHERE student_id = 'ACNHS-7022395';

-- Update in applications table (using control_number)
UPDATE applications
SET date_of_birth = '1986-12-25'
WHERE control_number = 'ACNHS-ADM-2026011';

-- Verify the fix in students table
SELECT 
    student_id,
    date_of_birth
FROM students
WHERE student_id = 'ACNHS-7022395';

-- Verify the fix in applications table
SELECT 
    control_number,
    date_of_birth
FROM applications
WHERE control_number = 'ACNHS-ADM-2026011';
