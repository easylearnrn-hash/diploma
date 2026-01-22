-- ==========================================
-- DIAGNOSTIC: CHECK STUDENTS TABLE STATUS
-- Run this in Supabase SQL Editor first
-- ==========================================

-- Check which student tables exist
SELECT 
    tablename,
    schemaname
FROM pg_tables 
WHERE tablename IN ('students', 'acnhs_students')
  AND schemaname = 'public';

-- If students table exists, show its columns
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'students' 
        AND table_schema = 'public'
    ) THEN
        RAISE NOTICE 'students table EXISTS';
    ELSE
        RAISE NOTICE 'students table DOES NOT EXIST';
    END IF;

    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'acnhs_students' 
        AND table_schema = 'public'
    ) THEN
        RAISE NOTICE 'acnhs_students table EXISTS';
    ELSE
        RAISE NOTICE 'acnhs_students table DOES NOT EXIST';
    END IF;
END $$;

-- Show columns for students table if it exists
SELECT 
    'students' as table_name,
    column_name, 
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'students' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- Show columns for acnhs_students table if it exists
SELECT 
    'acnhs_students' as table_name,
    column_name, 
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'acnhs_students' 
  AND table_schema = 'public'
ORDER BY ordinal_position;
