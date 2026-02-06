-- Add missing date_of_birth column to applications table so forms/admin UI can persist DOB
-- Run in Supabase SQL Editor for project eyhksbiceueoiamwnqpr

ALTER TABLE public.applications
ADD COLUMN IF NOT EXISTS date_of_birth TEXT;

COMMENT ON COLUMN public.applications.date_of_birth IS 'Applicant date of birth captured during submission (ISO string or raw text).';
