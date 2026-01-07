-- Add unique identifier columns to applications table
-- Run this in Supabase SQL Editor

-- Add control_number column (CTRL: ACN-2026-136376)
ALTER TABLE public.applications 
ADD COLUMN IF NOT EXISTS control_number TEXT UNIQUE;

-- Add document_id column (DOC ID: ACN-2026-392908)
ALTER TABLE public.applications 
ADD COLUMN IF NOT EXISTS document_id TEXT UNIQUE;

-- Add hash column (HASH: SHA256-D82025)
ALTER TABLE public.applications 
ADD COLUMN IF NOT EXISTS hash TEXT UNIQUE;

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_applications_control_number ON public.applications(control_number);
CREATE INDEX IF NOT EXISTS idx_applications_document_id ON public.applications(document_id);
CREATE INDEX IF NOT EXISTS idx_applications_hash ON public.applications(hash);

-- Add comments for documentation
COMMENT ON COLUMN public.applications.reference_number IS 'Reference Number (REF: ACNHS-ADM-20260106-960)';
COMMENT ON COLUMN public.applications.control_number IS 'Control Number (CTRL: ACN-2026-136376)';
COMMENT ON COLUMN public.applications.document_id IS 'Document ID (DOC ID: ACN-2026-392908)';
COMMENT ON COLUMN public.applications.barcode IS 'Barcode (ACN2024001234VERIFY)';
COMMENT ON COLUMN public.applications.hash IS 'SHA256 Hash (HASH: SHA256-D82025)';

-- Note: All fields are UNIQUE to ensure each application has distinct identifiers
