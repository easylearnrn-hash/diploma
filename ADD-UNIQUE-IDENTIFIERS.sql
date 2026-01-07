-- Add unique identifier columns to applications table
-- Run this in Supabase SQL Editor

-- STEP 1: Check what columns already exist (run CHECK-EXISTING-COLUMNS.sql first if you want to see)

-- STEP 2: Add columns only if they don't exist (no error if they already exist)

-- Add control_number column (CTRL: ACN-2026-136376)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'applications' 
        AND column_name = 'control_number'
    ) THEN
        ALTER TABLE public.applications ADD COLUMN control_number TEXT;
    END IF;
END $$;

-- Add document_id column (DOC ID: ACN-2026-392908)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'applications' 
        AND column_name = 'document_id'
    ) THEN
        ALTER TABLE public.applications ADD COLUMN document_id TEXT;
    END IF;
END $$;

-- Add hash column (HASH: SHA256-D82025)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'applications' 
        AND column_name = 'hash'
    ) THEN
        ALTER TABLE public.applications ADD COLUMN hash TEXT;
    END IF;
END $$;

-- Add status column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'applications' 
        AND column_name = 'status'
    ) THEN
        ALTER TABLE public.applications ADD COLUMN status TEXT DEFAULT 'Pending Review';
    END IF;
END $$;

-- Add status_history column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'applications' 
        AND column_name = 'status_history'
    ) THEN
        ALTER TABLE public.applications ADD COLUMN status_history JSONB DEFAULT '[]'::jsonb;
    END IF;
END $$;

-- STEP 3: Add UNIQUE constraints (will skip if already exists)
DO $$ 
BEGIN
    -- control_number unique constraint
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'applications_control_number_key'
    ) THEN
        ALTER TABLE public.applications ADD CONSTRAINT applications_control_number_key UNIQUE (control_number);
    END IF;
    
    -- document_id unique constraint
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'applications_document_id_key'
    ) THEN
        ALTER TABLE public.applications ADD CONSTRAINT applications_document_id_key UNIQUE (document_id);
    END IF;
    
    -- hash unique constraint
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'applications_hash_key'
    ) THEN
        ALTER TABLE public.applications ADD CONSTRAINT applications_hash_key UNIQUE (hash);
    END IF;
END $$;

-- STEP 4: Create indexes for faster lookups (will skip if already exists)
CREATE INDEX IF NOT EXISTS idx_applications_control_number ON public.applications(control_number);
CREATE INDEX IF NOT EXISTS idx_applications_document_id ON public.applications(document_id);
CREATE INDEX IF NOT EXISTS idx_applications_hash ON public.applications(hash);

-- STEP 5: Add comments for documentation (safe to run multiple times)
DO $$ 
BEGIN
    EXECUTE 'COMMENT ON COLUMN public.applications.reference_number IS ''Reference Number (REF: ACNHS-ADM-20260106-960)''';
    EXECUTE 'COMMENT ON COLUMN public.applications.control_number IS ''Control Number (CTRL: ACN-2026-136376)''';
    EXECUTE 'COMMENT ON COLUMN public.applications.document_id IS ''Document ID (DOC ID: ACN-2026-392908)''';
    EXECUTE 'COMMENT ON COLUMN public.applications.barcode IS ''Barcode (ACN2024001234VERIFY)''';
    EXECUTE 'COMMENT ON COLUMN public.applications.hash IS ''SHA256 Hash (HASH: SHA256-D82025)''';
EXCEPTION WHEN OTHERS THEN
    NULL; -- Ignore errors if columns don't exist yet
END $$;

-- Note: All new fields have UNIQUE constraints to ensure each application has distinct identifiers
-- This script is idempotent - safe to run multiple times
