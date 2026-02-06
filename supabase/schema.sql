-- SQL Schema for SMS Verification System
-- Run this in Supabase SQL Editor

-- Create sms_verifications table
CREATE TABLE IF NOT EXISTS public.sms_verifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    phone_number TEXT NOT NULL,
    code TEXT NOT NULL,
    purpose TEXT NOT NULL CHECK (purpose IN ('admission', 'login', 'password-reset')),
    verified BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    verified_at TIMESTAMP WITH TIME ZONE,
    attempts INTEGER DEFAULT 0
);

-- Create indexes idempotently for faster lookups
CREATE INDEX IF NOT EXISTS idx_sms_verifications_phone ON public.sms_verifications(phone_number);
CREATE INDEX IF NOT EXISTS idx_sms_verifications_code ON public.sms_verifications(code);
CREATE INDEX IF NOT EXISTS idx_sms_verifications_verified ON public.sms_verifications(verified);

-- Create sms_logs table (optional - for tracking all SMS sent)
CREATE TABLE IF NOT EXISTS public.sms_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    phone_number TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('admission', 'notification', 'verification', 'reminder')),
    status TEXT,
    message_sid TEXT,
    error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for logs (idempotent)
CREATE INDEX IF NOT EXISTS idx_sms_logs_phone ON public.sms_logs(phone_number);
CREATE INDEX IF NOT EXISTS idx_sms_logs_created ON public.sms_logs(created_at);

-- Enable Row Level Security (RLS)
ALTER TABLE public.sms_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sms_logs ENABLE ROW LEVEL SECURITY;

-- Create policies for sms_verifications (idempotent)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'sms_verifications'
          AND policyname = 'Service role can access all verifications'
    ) THEN
        CREATE POLICY "Service role can access all verifications"
            ON public.sms_verifications
            FOR ALL
            TO service_role
            USING (true)
            WITH CHECK (true);
    END IF;
END$$;

-- Create policies for sms_logs (idempotent)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'sms_logs'
          AND policyname = 'Service role can access all logs'
    ) THEN
        CREATE POLICY "Service role can access all logs"
            ON public.sms_logs
            FOR ALL
            TO service_role
            USING (true)
            WITH CHECK (true);
    END IF;
END$$;

-- Function to clean up expired verifications (run daily)
CREATE OR REPLACE FUNCTION cleanup_expired_verifications()
RETURNS void AS $$
BEGIN
    DELETE FROM public.sms_verifications
    WHERE expires_at < NOW() - INTERVAL '1 day';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Optional: Create a cron job to run cleanup daily (requires pg_cron extension)
-- SELECT cron.schedule('cleanup-expired-sms', '0 2 * * *', 'SELECT cleanup_expired_verifications();');

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO service_role;
GRANT ALL ON public.sms_verifications TO service_role;
GRANT ALL ON public.sms_logs TO service_role;

-- ==========================================
-- TRANSCRIPT VERIFICATION SYSTEM
-- ==========================================

-- Create transcripts table for verification codes
CREATE TABLE IF NOT EXISTS public.transcripts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    verification_code TEXT UNIQUE NOT NULL,
    student_id TEXT NOT NULL,
    student_name TEXT NOT NULL,
    date_of_birth DATE NOT NULL,
    program TEXT NOT NULL,
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
    transcript_type TEXT NOT NULL CHECK (transcript_type IN ('standard', 'ministry', 'us-evaluation')),
    status TEXT NOT NULL DEFAULT 'valid' CHECK (status IN ('valid', 'invalid', 'revoked')),
    cumulative_gpa DECIMAL(3,2),
    total_credits DECIMAL(5,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Create indexes for fast lookups (idempotent)
CREATE INDEX IF NOT EXISTS idx_transcripts_verification_code ON public.transcripts(verification_code);
CREATE INDEX IF NOT EXISTS idx_transcripts_student_id ON public.transcripts(student_id);
CREATE INDEX IF NOT EXISTS idx_transcripts_status ON public.transcripts(status);
CREATE INDEX IF NOT EXISTS idx_transcripts_issue_date ON public.transcripts(issue_date);

-- Enable Row Level Security
ALTER TABLE public.transcripts ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read valid transcripts by verification code (for public verification)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'transcripts'
          AND policyname = 'Public can verify transcripts'
    ) THEN
        CREATE POLICY "Public can verify transcripts"
            ON public.transcripts
            FOR SELECT
            USING (true);
    END IF;
END$$;

-- Policy: Only service role can insert/update/delete (idempotent)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'transcripts'
          AND policyname = 'Service role can manage transcripts'
    ) THEN
        CREATE POLICY "Service role can manage transcripts"
            ON public.transcripts
            FOR ALL
            TO service_role
            USING (true)
            WITH CHECK (true);
    END IF;
END$$;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger t
        JOIN pg_class c ON t.tgrelid = c.oid
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE t.tgname = 'update_transcripts_updated_at'
          AND n.nspname = 'public'
          AND c.relname = 'transcripts'
    ) THEN
        CREATE TRIGGER update_transcripts_updated_at
            BEFORE UPDATE ON public.transcripts
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END$$;

-- Grant permissions
GRANT ALL ON public.transcripts TO service_role;
GRANT SELECT ON public.transcripts TO anon;
GRANT SELECT ON public.transcripts TO authenticated;

-- Insert sample transcript for testing (idempotent)
INSERT INTO public.transcripts (
    verification_code,
    student_id,
    student_name,
    date_of_birth,
    program,
    transcript_type,
    issue_date,
    status,
    cumulative_gpa,
    total_credits,
    metadata
) VALUES (
    'TR-2025-001',
    'ACNHS2025001',
    'John Doe',
    '2000-05-15',
    'Bachelor of Science in Nursing',
    'standard',
    '2025-01-15',
    'valid',
    3.75,
    120.00,
    '{"term": "Spring 2025", "dean": "Dr. Sarah Johnson"}'::jsonb
)
ON CONFLICT (verification_code) DO NOTHING;


CREATE TABLE IF NOT EXISTS public.applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reference_number TEXT UNIQUE NOT NULL,  -- REF: ACNHS-ADM-20260106-960
    control_number TEXT UNIQUE,              -- CTRL: ACN-2026-136376
    document_id TEXT UNIQUE,                 -- DOC ID: ACN-2026-392908
    verification_hash TEXT,
    barcode TEXT UNIQUE NOT NULL,            -- Barcode: ACN2024001234VERIFY
    hash TEXT UNIQUE,                        -- HASH: SHA256-D82025
    username TEXT UNIQUE,
    password_hash TEXT,
    applicant_name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    date_of_birth TEXT,
    institutional_email TEXT,
    program TEXT,
    start_term TEXT,
    submission_date TIMESTAMPTZ DEFAULT timezone('utc', now()),
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    status TEXT DEFAULT 'SUBMITTED' CHECK (status IN (
        'SUBMITTED',
        'UNDER REVIEW',
        'ACTIVELY REVIEWING',
        'RFE PREPARING',
        'RFE SENT',
        'ADDITIONAL DOCUMENTS REQUESTED',
        'DOCUMENTS RECEIVED',
        'FINAL REVIEW',
        'APPROVED',
        'CONFIRMED',
        'ACCEPTANCE LETTER SENT',
        'ENROLLED',
        'DENIED',
        'ON HOLD',
        'WITHDRAWN'
    )),
    status_message TEXT,
    status_history JSONB DEFAULT '[]'::jsonb,
    status_updated_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    rfe_documents_requested JSONB DEFAULT '[]'::jsonb,
    admin_notes TEXT,
    uploaded_documents JSONB DEFAULT '[]'::jsonb,
    credentials_screenshot TEXT
);

CREATE INDEX IF NOT EXISTS idx_applications_reference ON public.applications(reference_number);
CREATE INDEX IF NOT EXISTS idx_applications_control_number ON public.applications(control_number);
CREATE INDEX IF NOT EXISTS idx_applications_document_id ON public.applications(document_id);
CREATE INDEX IF NOT EXISTS idx_applications_barcode ON public.applications(barcode);
CREATE INDEX IF NOT EXISTS idx_applications_hash ON public.applications(hash);
CREATE INDEX IF NOT EXISTS idx_applications_program ON public.applications(program);
CREATE INDEX IF NOT EXISTS idx_applications_submission ON public.applications(submission_date);
CREATE INDEX IF NOT EXISTS idx_applications_username ON public.applications(username);
CREATE INDEX IF NOT EXISTS idx_applications_status ON public.applications(status);
CREATE INDEX IF NOT EXISTS idx_applications_verification_hash ON public.applications(verification_hash);
CREATE INDEX IF NOT EXISTS idx_applications_status_message ON public.applications(status_message);
CREATE INDEX IF NOT EXISTS idx_applications_uploaded_documents ON public.applications USING GIN (uploaded_documents);

ALTER TABLE public.applications ADD COLUMN IF NOT EXISTS date_of_birth TEXT;
COMMENT ON COLUMN public.applications.date_of_birth IS 'Applicant date of birth captured during submission (ISO string or raw text).';

-- Enable Row Level Security
ALTER TABLE public.applications ENABLE ROW LEVEL SECURITY;

-- POLICIES (adjust for production security requirements)
-- Allow anonymous inserts (public form submissions)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'applications'
          AND policyname = 'Public can submit applications'
    ) THEN
        CREATE POLICY "Public can submit applications"
            ON public.applications
            FOR INSERT
            TO anon
            WITH CHECK (true);
    END IF;
END$$;

-- Allow authenticated/anon read access for the lightweight admin page (lock down in production)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'applications'
          AND policyname = 'Public can read applications'
    ) THEN
        CREATE POLICY "Public can read applications"
            ON public.applications
            FOR SELECT
            TO anon
            USING (true);
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'applications'
          AND policyname = 'Public can update applications'
    ) THEN
        CREATE POLICY "Public can update applications"
            ON public.applications
            FOR UPDATE
            TO anon
            USING (true)
            WITH CHECK (true);
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'applications'
          AND policyname = 'Public can delete applications'
    ) THEN
        CREATE POLICY "Public can delete applications"
            ON public.applications
            FOR DELETE
            TO anon
            USING (true);
    END IF;
END$$;

GRANT ALL ON public.applications TO service_role;
GRANT INSERT, SELECT, UPDATE, DELETE ON public.applications TO anon;

-- ==========================================
-- REGISTRATIONS / WAITING LIST
-- ==========================================

-- Stores student registrations from the login page (waiting list)
CREATE TABLE IF NOT EXISTS public.registrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT NOT NULL,
    date_of_birth DATE NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    education_level TEXT NOT NULL,
    preferred_start_date TEXT NOT NULL,
    registration_date TIMESTAMPTZ DEFAULT timezone('utc', now()),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'contacted', 'approved', 'rejected')),
    notes TEXT,
    reminder_date DATE
);

-- Helpful indexes
CREATE INDEX IF NOT EXISTS idx_registrations_email ON public.registrations(email);
CREATE INDEX IF NOT EXISTS idx_registrations_status ON public.registrations(status);
CREATE INDEX IF NOT EXISTS idx_registrations_date ON public.registrations(registration_date);
CREATE INDEX IF NOT EXISTS idx_registrations_start_date ON public.registrations(preferred_start_date);
CREATE INDEX IF NOT EXISTS idx_registrations_reminder ON public.registrations(reminder_date);

-- Enable Row Level Security
ALTER TABLE public.registrations ENABLE ROW LEVEL SECURITY;

-- POLICIES
-- Allow anonymous inserts (public form submissions)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'registrations'
          AND policyname = 'Public can submit registrations'
    ) THEN
        CREATE POLICY "Public can submit registrations"
            ON public.registrations
            FOR INSERT
            TO anon
            WITH CHECK (true);
    END IF;
END$$;

-- Allow authenticated/anon read access for admin page
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'registrations'
          AND policyname = 'Public can read registrations'
    ) THEN
        CREATE POLICY "Public can read registrations"
            ON public.registrations
            FOR SELECT
            TO anon
            USING (true);
    END IF;
END$$;

-- Allow anonymous update access for admin page
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'registrations'
          AND policyname = 'Public can update registrations'
    ) THEN
        CREATE POLICY "Public can update registrations"
            ON public.registrations
            FOR UPDATE
            TO anon
            USING (true)
            WITH CHECK (true);
    END IF;
END$$;

-- Allow anonymous delete access for admin page
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'registrations'
          AND policyname = 'Public can delete registrations'
    ) THEN
        CREATE POLICY "Public can delete registrations"
            ON public.registrations
            FOR DELETE
            TO anon
            USING (true);
    END IF;
END$$;

GRANT ALL ON public.registrations TO service_role;
GRANT INSERT, SELECT, UPDATE, DELETE ON public.registrations TO anon;

-- ==========================================
-- STUDENT RECORDS
-- ==========================================

CREATE TABLE IF NOT EXISTS public.students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id TEXT UNIQUE NOT NULL,
    full_name TEXT,
    email TEXT,
    phone TEXT,
    date_of_birth TEXT,
    program TEXT,
    start_term TEXT,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'withdrawn')),
    application_id UUID REFERENCES public.applications(id) ON DELETE SET NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ DEFAULT timezone('utc', now())
);

ALTER TABLE public.students ADD COLUMN IF NOT EXISTS student_id TEXT;
ALTER TABLE public.students ADD COLUMN IF NOT EXISTS full_name TEXT;
ALTER TABLE public.students ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE public.students ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE public.students ADD COLUMN IF NOT EXISTS date_of_birth TEXT;
ALTER TABLE public.students ADD COLUMN IF NOT EXISTS program TEXT;
ALTER TABLE public.students ADD COLUMN IF NOT EXISTS start_term TEXT;
ALTER TABLE public.students ADD COLUMN IF NOT EXISTS status TEXT;
ALTER TABLE public.students ADD COLUMN IF NOT EXISTS application_id UUID;
ALTER TABLE public.students ADD COLUMN IF NOT EXISTS metadata JSONB;
ALTER TABLE public.students ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ;
ALTER TABLE public.students ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ;

ALTER TABLE public.students ALTER COLUMN status SET DEFAULT 'active';
ALTER TABLE public.students ALTER COLUMN metadata SET DEFAULT '{}'::jsonb;
ALTER TABLE public.students ALTER COLUMN created_at SET DEFAULT timezone('utc', now());
ALTER TABLE public.students ALTER COLUMN updated_at SET DEFAULT timezone('utc', now());

UPDATE public.students
SET student_id = CONCAT('ACNHS-', LPAD((FLOOR(random() * 1000000000))::text, 9, '0'))
WHERE student_id IS NULL;

ALTER TABLE public.students ALTER COLUMN student_id SET NOT NULL;

CREATE INDEX IF NOT EXISTS idx_students_student_id ON public.students(student_id);
CREATE INDEX IF NOT EXISTS idx_students_status ON public.students(status);
CREATE INDEX IF NOT EXISTS idx_students_application ON public.students(application_id);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'public.students'::regclass
          AND conname = 'students_student_id_key'
    ) THEN
        ALTER TABLE public.students
            ADD CONSTRAINT students_student_id_key UNIQUE (student_id);
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'public.students'::regclass
          AND conname = 'students_application_id_fkey'
    ) THEN
        ALTER TABLE public.students
            ADD CONSTRAINT students_application_id_fkey
            FOREIGN KEY (application_id)
            REFERENCES public.applications(id)
            ON DELETE SET NULL;
    END IF;
END$$;

ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'students'
          AND policyname = 'Public can read students'
    ) THEN
        CREATE POLICY "Public can read students"
            ON public.students
            FOR SELECT
            TO anon
            USING (true);
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'students'
          AND policyname = 'Public can insert students'
    ) THEN
        CREATE POLICY "Public can insert students"
            ON public.students
            FOR INSERT
            TO anon
            WITH CHECK (true);
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'students'
          AND policyname = 'Public can update students'
    ) THEN
        CREATE POLICY "Public can update students"
            ON public.students
            FOR UPDATE
            TO anon
            USING (true)
            WITH CHECK (true);
    END IF;
END$$;

CREATE OR REPLACE FUNCTION maintain_students_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = timezone('utc', now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_trigger t
        JOIN pg_class c ON t.tgrelid = c.oid
        JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE t.tgname = 'students_updated_at_trg'
          AND n.nspname = 'public'
          AND c.relname = 'students'
    ) THEN
        CREATE TRIGGER students_updated_at_trg
            BEFORE UPDATE ON public.students
            FOR EACH ROW
            EXECUTE FUNCTION maintain_students_updated_at();
    END IF;
END$$;

GRANT ALL ON public.students TO service_role;
GRANT INSERT, SELECT, UPDATE, DELETE ON public.students TO anon;

-- ==========================================
-- USER ACTIVITY LOG
-- ==========================================

CREATE TABLE IF NOT EXISTS public.user_activity_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.admin_users(id) ON DELETE CASCADE,
    user_email TEXT NOT NULL,
    user_name TEXT NOT NULL,
    action_type TEXT NOT NULL,
    action_category TEXT NOT NULL,
    action_description TEXT NOT NULL,
    target_type TEXT,
    target_id TEXT,
    target_name TEXT,
    old_value JSONB,
    new_value JSONB,
    ip_address TEXT,
    user_agent TEXT,
    session_id TEXT,
    created_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    metadata JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_activity_user_id ON public.user_activity_log(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_user_email ON public.user_activity_log(user_email);
CREATE INDEX IF NOT EXISTS idx_activity_created_at ON public.user_activity_log(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_activity_action_type ON public.user_activity_log(action_type);
CREATE INDEX IF NOT EXISTS idx_activity_action_category ON public.user_activity_log(action_category);
CREATE INDEX IF NOT EXISTS idx_activity_target_id ON public.user_activity_log(target_id);

ALTER TABLE public.user_activity_log ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'user_activity_log'
          AND policyname = 'Anon can insert activity logs'
    ) THEN
        CREATE POLICY "Anon can insert activity logs"
            ON public.user_activity_log
            FOR INSERT
            TO anon
            WITH CHECK (true);
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'user_activity_log'
          AND policyname = 'Anon can read activity logs'
    ) THEN
        CREATE POLICY "Anon can read activity logs"
            ON public.user_activity_log
            FOR SELECT
            TO anon
            USING (true);
    END IF;
END$$;

GRANT ALL ON public.user_activity_log TO service_role;
GRANT INSERT, SELECT ON public.user_activity_log TO anon;

COMMENT ON TABLE public.user_activity_log IS 'Comprehensive activity log for all user actions in the admin system';
COMMENT ON COLUMN public.user_activity_log.action_type IS 'Type of action: create, update, delete, view, send, export, login, logout';
COMMENT ON COLUMN public.user_activity_log.action_category IS 'Category: application, student, email, user, document, system';
COMMENT ON COLUMN public.user_activity_log.old_value IS 'JSON snapshot of data before change (for updates/deletes)';
COMMENT ON COLUMN public.user_activity_log.new_value IS 'JSON snapshot of data after change (for creates/updates)';
