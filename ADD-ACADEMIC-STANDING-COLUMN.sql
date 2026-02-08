-- Add ALL missing columns from OLD acnhs_students to NEW students table
-- Run this in NEW project (eyhksbiceueoiamwnqpr) SQL Editor

-- Core student information
ALTER TABLE students ADD COLUMN IF NOT EXISTS student_id TEXT NOT NULL DEFAULT '';
ALTER TABLE students ADD COLUMN IF NOT EXISTS application_id UUID;
ALTER TABLE students ADD COLUMN IF NOT EXISTS full_name TEXT NOT NULL DEFAULT '';
ALTER TABLE students ADD COLUMN IF NOT EXISTS email TEXT NOT NULL DEFAULT '';
ALTER TABLE students ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS date_of_birth TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS gender TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS nationality TEXT;

-- Academic information
ALTER TABLE students ADD COLUMN IF NOT EXISTS program TEXT NOT NULL DEFAULT '';
ALTER TABLE students ADD COLUMN IF NOT EXISTS start_term TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS expected_graduation TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS enrollment_status TEXT DEFAULT 'active';
ALTER TABLE students ADD COLUMN IF NOT EXISTS current_gpa NUMERIC;
ALTER TABLE students ADD COLUMN IF NOT EXISTS total_credits_earned INTEGER DEFAULT 0;
ALTER TABLE students ADD COLUMN IF NOT EXISTS academic_standing TEXT;

-- Emergency contact
ALTER TABLE students ADD COLUMN IF NOT EXISTS emergency_contact_name TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS emergency_contact_phone TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS emergency_contact_relation TEXT;

-- Metadata and notes
ALTER TABLE students ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;
ALTER TABLE students ADD COLUMN IF NOT EXISTS notes TEXT;

-- Timestamps
ALTER TABLE students ADD COLUMN IF NOT EXISTS enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now());
ALTER TABLE students ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now());
ALTER TABLE students ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now());

-- Verify all columns were added
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'students'
ORDER BY ordinal_position;
