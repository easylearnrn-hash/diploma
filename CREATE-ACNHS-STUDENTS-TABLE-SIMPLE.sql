-- ==========================================
-- ACNHS STUDENTS TABLE - SIMPLIFIED VERSION
-- Run this in Supabase SQL Editor
-- Avoids deadlocks by running operations separately
-- ==========================================

-- Step 1: Create the table
CREATE TABLE IF NOT EXISTS public.acnhs_students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id TEXT UNIQUE NOT NULL,
    application_id UUID,
    
    -- Personal Information
    full_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    date_of_birth TEXT,
    gender TEXT,
    nationality TEXT,
    
    -- Academic Information
    program TEXT NOT NULL,
    start_term TEXT,
    expected_graduation TEXT,
    enrollment_status TEXT DEFAULT 'active',
    
    -- Academic Performance
    current_gpa DECIMAL(3,2),
    total_credits_earned INTEGER DEFAULT 0,
    academic_standing TEXT,
    
    -- Additional Information
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT,
    emergency_contact_relation TEXT,
    
    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    notes TEXT,
    
    -- Timestamps
    enrolled_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    created_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ DEFAULT timezone('utc', now())
);

-- Step 2: Create indexes
CREATE INDEX IF NOT EXISTS idx_acnhs_students_student_id ON public.acnhs_students(student_id);
CREATE INDEX IF NOT EXISTS idx_acnhs_students_email ON public.acnhs_students(email);
CREATE INDEX IF NOT EXISTS idx_acnhs_students_application_id ON public.acnhs_students(application_id);
CREATE INDEX IF NOT EXISTS idx_acnhs_students_enrollment_status ON public.acnhs_students(enrollment_status);
CREATE INDEX IF NOT EXISTS idx_acnhs_students_program ON public.acnhs_students(program);

-- Step 3: Add constraints (only if they don't exist)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'acnhs_students_enrollment_status_check'
    ) THEN
        ALTER TABLE public.acnhs_students 
            ADD CONSTRAINT acnhs_students_enrollment_status_check 
            CHECK (enrollment_status IN ('active', 'inactive', 'withdrawn', 'graduated', 'suspended'));
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'acnhs_students_academic_standing_check'
    ) THEN
        ALTER TABLE public.acnhs_students 
            ADD CONSTRAINT acnhs_students_academic_standing_check 
            CHECK (academic_standing IN ('good', 'probation', 'warning', 'dismissed') OR academic_standing IS NULL);
    END IF;
END $$;

-- Step 4: Add foreign key (only if applications table exists)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'applications') THEN
        ALTER TABLE public.acnhs_students 
            DROP CONSTRAINT IF EXISTS acnhs_students_application_id_fkey;
        
        ALTER TABLE public.acnhs_students 
            ADD CONSTRAINT acnhs_students_application_id_fkey 
            FOREIGN KEY (application_id) 
            REFERENCES public.applications(id) 
            ON DELETE SET NULL;
    END IF;
END $$;

-- Step 5: Enable RLS
ALTER TABLE public.acnhs_students ENABLE ROW LEVEL SECURITY;

-- Step 6: Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow anonymous insert" ON public.acnhs_students;
DROP POLICY IF EXISTS "Allow anonymous select" ON public.acnhs_students;
DROP POLICY IF EXISTS "Allow anonymous update" ON public.acnhs_students;
DROP POLICY IF EXISTS "Allow anonymous delete" ON public.acnhs_students;

-- Step 7: Create RLS policies
CREATE POLICY "Allow anonymous insert"
    ON public.acnhs_students
    FOR INSERT
    TO anon
    WITH CHECK (true);

CREATE POLICY "Allow anonymous select"
    ON public.acnhs_students
    FOR SELECT
    TO anon
    USING (true);

CREATE POLICY "Allow anonymous update"
    ON public.acnhs_students
    FOR UPDATE
    TO anon
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow anonymous delete"
    ON public.acnhs_students
    FOR DELETE
    TO anon
    USING (true);

-- Step 8: Create auto-update function
CREATE OR REPLACE FUNCTION update_acnhs_students_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc', now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 9: Create trigger
DROP TRIGGER IF EXISTS trigger_update_acnhs_students_updated_at ON public.acnhs_students;

CREATE TRIGGER trigger_update_acnhs_students_updated_at
    BEFORE UPDATE ON public.acnhs_students
    FOR EACH ROW
    EXECUTE FUNCTION update_acnhs_students_updated_at();

-- Step 10: Grant permissions
GRANT USAGE ON SCHEMA public TO anon;
GRANT ALL ON public.acnhs_students TO anon;

-- Success!
SELECT 'ACNHS Students table created successfully!' AS status;
