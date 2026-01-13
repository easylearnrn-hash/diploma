-- ==========================================
-- ACNHS STUDENTS TABLE
-- Run this in Supabase SQL Editor
-- ==========================================

-- Create acnhs_students table for approved students only
CREATE TABLE IF NOT EXISTS public.acnhs_students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id TEXT UNIQUE NOT NULL,
    application_id UUID REFERENCES public.applications(id) ON DELETE SET NULL,
    
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
    enrollment_status TEXT DEFAULT 'active' CHECK (enrollment_status IN ('active', 'inactive', 'withdrawn', 'graduated', 'suspended')),
    
    -- Academic Performance
    current_gpa DECIMAL(3,2),
    total_credits_earned INTEGER DEFAULT 0,
    academic_standing TEXT CHECK (academic_standing IN ('good', 'probation', 'warning', 'dismissed')),
    
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

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_acnhs_students_student_id ON public.acnhs_students(student_id);
CREATE INDEX IF NOT EXISTS idx_acnhs_students_email ON public.acnhs_students(email);
CREATE INDEX IF NOT EXISTS idx_acnhs_students_application_id ON public.acnhs_students(application_id);
CREATE INDEX IF NOT EXISTS idx_acnhs_students_enrollment_status ON public.acnhs_students(enrollment_status);
CREATE INDEX IF NOT EXISTS idx_acnhs_students_program ON public.acnhs_students(program);

-- Add unique constraint on student_id
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'public.acnhs_students'::regclass
          AND conname = 'acnhs_students_student_id_key'
    ) THEN
        ALTER TABLE public.acnhs_students
            ADD CONSTRAINT acnhs_students_student_id_key UNIQUE (student_id);
    END IF;
END$$;

-- Enable Row Level Security
ALTER TABLE public.acnhs_students ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
DO $$
BEGIN
    -- Policy for anonymous users to insert (for form submissions)
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'acnhs_students'
          AND policyname = 'Allow anonymous insert'
    ) THEN
        CREATE POLICY "Allow anonymous insert"
            ON public.acnhs_students
            FOR INSERT
            TO anon
            WITH CHECK (true);
    END IF;

    -- Policy for anonymous users to read
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'acnhs_students'
          AND policyname = 'Allow anonymous select'
    ) THEN
        CREATE POLICY "Allow anonymous select"
            ON public.acnhs_students
            FOR SELECT
            TO anon
            USING (true);
    END IF;

    -- Policy for anonymous users to update
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'acnhs_students'
          AND policyname = 'Allow anonymous update'
    ) THEN
        CREATE POLICY "Allow anonymous update"
            ON public.acnhs_students
            FOR UPDATE
            TO anon
            USING (true)
            WITH CHECK (true);
    END IF;

    -- Policy for anonymous users to delete
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'acnhs_students'
          AND policyname = 'Allow anonymous delete'
    ) THEN
        CREATE POLICY "Allow anonymous delete"
            ON public.acnhs_students
            FOR DELETE
            TO anon
            USING (true);
    END IF;
END$$;

-- Create function to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_acnhs_students_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc', now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update updated_at
DROP TRIGGER IF EXISTS trigger_update_acnhs_students_updated_at ON public.acnhs_students;
CREATE TRIGGER trigger_update_acnhs_students_updated_at
    BEFORE UPDATE ON public.acnhs_students
    FOR EACH ROW
    EXECUTE FUNCTION update_acnhs_students_updated_at();

-- Grant permissions
GRANT USAGE ON SCHEMA public TO anon;
GRANT ALL ON public.acnhs_students TO anon;

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ ACNHS Students table created successfully!';
    RAISE NOTICE '📊 Table: public.acnhs_students';
    RAISE NOTICE '🔐 RLS Policies: Enabled';
    RAISE NOTICE '⚡ Indexes: Created';
    RAISE NOTICE '🔄 Auto-update trigger: Enabled';
END$$;
