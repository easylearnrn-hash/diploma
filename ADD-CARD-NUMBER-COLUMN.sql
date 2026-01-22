-- Add card_number column to students and applications tables
-- This column stores the unique card tracking number for each student ID card

-- Add to students table
ALTER TABLE students 
ADD COLUMN IF NOT EXISTS card_number TEXT;

-- Add to applications table as backup
ALTER TABLE applications 
ADD COLUMN IF NOT EXISTS card_number TEXT;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_students_card_number ON students(card_number);
CREATE INDEX IF NOT EXISTS idx_applications_card_number ON applications(card_number);

-- Add comment explaining the column
COMMENT ON COLUMN students.card_number IS 'Unique card tracking number for student ID card (format: CN-XXXX-YYNNN)';
COMMENT ON COLUMN applications.card_number IS 'Unique card tracking number for student ID card (format: CN-XXXX-YYNNN)';
