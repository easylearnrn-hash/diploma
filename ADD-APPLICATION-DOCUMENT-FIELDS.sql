-- ========================================
-- ADD APPLICATION DOCUMENT + CONTROL COLUMNS
-- Run this in Supabase SQL Editor after the
-- base applications table has been created.
-- ========================================

ALTER TABLE public.applications
ADD COLUMN IF NOT EXISTS document_id TEXT,
ADD COLUMN IF NOT EXISTS control_number TEXT,
ADD COLUMN IF NOT EXISTS verification_hash TEXT;

-- Optional but helpful indexes for quick lookups
CREATE INDEX IF NOT EXISTS idx_applications_document_id ON public.applications(document_id);
CREATE INDEX IF NOT EXISTS idx_applications_control_number ON public.applications(control_number);
CREATE INDEX IF NOT EXISTS idx_applications_verification_hash ON public.applications(verification_hash);
