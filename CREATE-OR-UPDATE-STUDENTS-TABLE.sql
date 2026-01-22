-- ==========================================
-- CREATE OR UPDATE STUDENTS TABLE
-- Run this in Supabase SQL Editor
-- This will create the table if missing, or add missing columns
-- ==========================================

-- Step 1: Create the students table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.students (
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
    status TEXT DEFAULT 'active',
    
    -- Emergency Contact Information
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT,
    emergency_contact_relation TEXT,
    
    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ DEFAULT timezone('utc', now())
);

-- Step 2: Add missing columns if table already exists
DO $$
BEGIN
    -- Add emergency_contact_name if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'emergency_contact_name'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN emergency_contact_name TEXT;
        RAISE NOTICE 'Added emergency_contact_name column';
    END IF;

    -- Add emergency_contact_relation if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'emergency_contact_relation'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN emergency_contact_relation TEXT;
        RAISE NOTICE 'Added emergency_contact_relation column';
    END IF;

    -- Add emergency_contact_phone if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'emergency_contact_phone'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN emergency_contact_phone TEXT;
        RAISE NOTICE 'Added emergency_contact_phone column';
    END IF;

    -- Add gender if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'gender'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN gender TEXT;
        RAISE NOTICE 'Added gender column';
    END IF;

    -- Add nationality if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'nationality'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN nationality TEXT;
        RAISE NOTICE 'Added nationality column';
    END IF;

    -- Add date_of_birth if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'date_of_birth'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN date_of_birth TEXT;
        RAISE NOTICE 'Added date_of_birth column';
    END IF;

    -- Add metadata if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'metadata'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN metadata JSONB DEFAULT '{}'::jsonb;
        RAISE NOTICE 'Added metadata column';
    END IF;

    -- Add status if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'status'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN status TEXT DEFAULT 'active';
        RAISE NOTICE 'Added status column';
    END IF;

    -- Add application_id if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'application_id'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN application_id UUID;
        RAISE NOTICE 'Added application_id column';
    END IF;

    -- Add phone if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'phone'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN phone TEXT;
        RAISE NOTICE 'Added phone column';
    END IF;

    -- Add program if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'program'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN program TEXT NOT NULL DEFAULT 'Pending';
        RAISE NOTICE 'Added program column';
    END IF;

    -- Add start_term if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'start_term'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN start_term TEXT;
        RAISE NOTICE 'Added start_term column';
    END IF;
END $$;

-- Step 3: Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_students_student_id ON public.students(student_id);
CREATE INDEX IF NOT EXISTS idx_students_email ON public.students(email);
CREATE INDEX IF NOT EXISTS idx_students_application_id ON public.students(application_id);
CREATE INDEX IF NOT EXISTS idx_students_status ON public.students(status);
CREATE INDEX IF NOT EXISTS idx_students_program ON public.students(program);

-- Step 4: Add foreign key constraint if applications table exists
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'applications' 
        AND table_schema = 'public'
    ) THEN
        -- Drop existing constraint if it exists
        ALTER TABLE public.students 
            DROP CONSTRAINT IF EXISTS students_application_id_fkey;
        
        -- Add the constraint
        ALTER TABLE public.students 
            ADD CONSTRAINT students_application_id_fkey 
            FOREIGN KEY (application_id) 
            REFERENCES public.applications(id) 
            ON DELETE SET NULL;
        
        RAISE NOTICE 'Added foreign key constraint to applications table';
    END IF;
END $$;

-- Step 5: Add status constraint with all valid values
DO $$
BEGIN
    -- Drop existing constraint if it exists
    ALTER TABLE public.students 
        DROP CONSTRAINT IF EXISTS students_status_check;
    
    -- Add constraint with all valid statuses
    ALTER TABLE public.students 
        ADD CONSTRAINT students_status_check 
        CHECK (status IN (
            'active',
            'inactive', 
            'withdrawn',
            'graduated',
            'suspended',
            'enrolled',
            'pending'
        ));
    
    RAISE NOTICE 'Added status constraint with valid values';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Status constraint may already exist or column is missing';
END $$;

-- Step 6: Enable RLS
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;

-- Step 7: Create RLS policies
DROP POLICY IF EXISTS "Allow anonymous insert students" ON public.students;
DROP POLICY IF EXISTS "Allow anonymous select students" ON public.students;
DROP POLICY IF EXISTS "Allow anonymous update students" ON public.students;
DROP POLICY IF EXISTS "Allow anonymous delete students" ON public.students;

CREATE POLICY "Allow anonymous insert students"
ON public.students
FOR INSERT
TO anon
WITH CHECK (true);

CREATE POLICY "Allow anonymous select students"
ON public.students
FOR SELECT
TO anon
USING (true);

CREATE POLICY "Allow anonymous update students"
ON public.students
FOR UPDATE
TO anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Allow anonymous delete students"
ON public.students
FOR DELETE
TO anon
USING (true);

-- Step 7: Create updated_at trigger
CREATE OR REPLACE FUNCTION public.update_students_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc', now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_students_updated_at ON public.students;
CREATE TRIGGER update_students_updated_at
    BEFORE UPDATE ON public.students
    FOR EACH ROW
    EXECUTE FUNCTION public.update_students_updated_at();

-- Step 8: Verify the table structure
SELECT 
    column_name, 
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'students' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Students table is ready with all required columns!';
END $$;
