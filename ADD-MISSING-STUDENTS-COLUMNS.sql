-- ==========================================
-- ADD MISSING COLUMNS TO STUDENTS TABLE
-- Run this in Supabase SQL Editor
-- ==========================================

-- First, check if the students table exists
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'students'
    ) THEN
        RAISE EXCEPTION 'students table does not exist. Create it first!';
    END IF;
END $$;

-- Add emergency contact columns if they don't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'emergency_contact_name'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN emergency_contact_name TEXT;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'emergency_contact_relation'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN emergency_contact_relation TEXT;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'emergency_contact_phone'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN emergency_contact_phone TEXT;
    END IF;
END $$;

-- Add other potentially missing columns
DO $$
BEGIN
    -- Add gender if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'gender'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN gender TEXT;
    END IF;

    -- Add nationality if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'nationality'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN nationality TEXT;
    END IF;

    -- Add date_of_birth if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'date_of_birth'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN date_of_birth TEXT;
    END IF;

    -- Add metadata if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'metadata'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN metadata JSONB DEFAULT '{}'::jsonb;
    END IF;

    -- Add status if missing (renamed from enrollment_status)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'status'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN status TEXT DEFAULT 'active';
    END IF;

    -- Add application_id if missing
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'students' 
        AND column_name = 'application_id'
    ) THEN
        ALTER TABLE public.students 
        ADD COLUMN application_id UUID;
    END IF;
END $$;

-- Verify all columns exist
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'students' 
  AND table_schema = 'public'
ORDER BY ordinal_position;
