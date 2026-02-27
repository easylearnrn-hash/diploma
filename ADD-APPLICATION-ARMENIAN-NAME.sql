-- Adds a dedicated column for storing the applicant's full name in Armenian
-- as it appears on passport/legal documents.
--
-- Safe to run multiple times.

ALTER TABLE IF EXISTS public.applications
ADD COLUMN IF NOT EXISTS applicant_name_armenian text;

COMMENT ON COLUMN public.applications.applicant_name_armenian IS
$$Applicant full name in Armenian alphabet (including father's name) as per passport/legal documents; used for Armenian Ministry of Education diploma issuance.$$;
