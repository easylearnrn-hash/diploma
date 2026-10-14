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
        'NOIR',
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

-- ============================================================
-- Test Grade History Answer Snapshots
-- ============================================================

ALTER TABLE public.test_grade_history
    ADD COLUMN IF NOT EXISTS answered_snapshot JSONB;

COMMENT ON COLUMN public.test_grade_history.answered_snapshot IS
    'Answered questions snapshot: array of {index, id, stem, answers:[{id,text}]}. Only answered questions stored.';

-- ============================================================
-- ALERT CENTER: student-portal alerts + homepage pop-ups
-- ============================================================
-- Consolidated, idempotent version of:
--   CREATE-PORTAL-ALERTS-SYSTEM.sql, ADD-ALERT-GROUP-TARGETING.sql,
--   UPGRADE-ALERTS-TO-RULE-ENGINE.sql, ADD-ALERT-POSITION-AND-LINK.sql,
--   ADD-PUBLIC-ALERT-AUDIENCE.sql and ADD-HOMEPAGE-POPUP-ALERTS.sql
-- Documentation: HOMEPAGE-POPUP-ALERTS-SETUP.md

CREATE TABLE IF NOT EXISTS public.portal_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    message_html TEXT NOT NULL,
    severity TEXT NOT NULL DEFAULT 'info' CHECK (severity IN ('info', 'success', 'warn', 'critical')),
    is_active BOOLEAN DEFAULT true,
    created_by TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    target_type TEXT NOT NULL DEFAULT 'all',
    target_student_ids JSONB DEFAULT '[]'::jsonb,
    display_mode TEXT NOT NULL DEFAULT 'once_ever' CHECK (display_mode IN ('every_load', 'once_ever', 'times_limit', 'daily', 'daily_first_login')),
    max_displays INTEGER,
    date_rule_type TEXT NOT NULL DEFAULT 'always' CHECK (date_rule_type IN ('always', 'date_range', 'monthly_range', 'custom_dates')),
    start_date DATE,
    end_date DATE,
    monthly_start_day INTEGER CHECK (monthly_start_day >= 1 AND monthly_start_day <= 31),
    monthly_end_day INTEGER CHECK (monthly_end_day >= 1 AND monthly_end_day <= 31),
    custom_dates JSONB DEFAULT '[]'::jsonb,
    timezone TEXT DEFAULT 'Asia/Yerevan',
    requires_response BOOLEAN DEFAULT false,
    response_type TEXT DEFAULT 'none' CHECK (response_type IN ('none', 'yes_no')),
    yes_label TEXT DEFAULT 'Yes',
    no_label TEXT DEFAULT 'No'
);

ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS target_group TEXT;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS display_position TEXT NOT NULL DEFAULT 'modal';
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS link_url TEXT;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS link_label TEXT DEFAULT 'Learn More';
ALTER TABLE public.portal_alerts DROP CONSTRAINT IF EXISTS portal_alerts_display_position_check;
ALTER TABLE public.portal_alerts ADD CONSTRAINT portal_alerts_display_position_check
    CHECK (display_position IN ('modal', 'banner_top', 'banner_bottom', 'toast_tr', 'toast_tl', 'toast_br', 'toast_bl'));

ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS targeting_rules JSONB DEFAULT '{"mode": "all", "include_students": [], "exclude_students": [], "groups": [], "statuses": [], "tags": [], "logic": "AND"}'::jsonb;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS frequency_rules JSONB DEFAULT '{"cap_type": "once_ever", "max_displays": null, "cooldown_hours": null, "per_period": null, "stop_after_response": false, "stop_after_days": null}'::jsonb;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS schedule_rules JSONB DEFAULT '{"recurrence_type": "always", "start_datetime": null, "end_datetime": null, "timezone": "Asia/Yerevan", "daily_pattern": null, "weekly_pattern": null, "monthly_pattern": null, "custom_dates": [], "exclude_dates": []}'::jsonb;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS trigger_rules JSONB DEFAULT '{"when": ["on_login"], "pages_whitelist": [], "pages_blacklist": [], "time_window": null}'::jsonb;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS interaction_rules JSONB DEFAULT '{"dismissible": true, "required_response": false, "remind_on_no": false, "auto_dismiss_seconds": null}'::jsonb;

CREATE INDEX IF NOT EXISTS idx_portal_alerts_active ON public.portal_alerts(is_active);
CREATE INDEX IF NOT EXISTS idx_portal_alerts_target_type ON public.portal_alerts(target_type);
CREATE INDEX IF NOT EXISTS idx_portal_alerts_created_at ON public.portal_alerts(created_at DESC);

-- Alert Center V2 columns
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS display_surface   TEXT        NOT NULL DEFAULT 'portal';
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS lifecycle_status  TEXT        NOT NULL DEFAULT 'published';
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS priority          TEXT        NOT NULL DEFAULT 'normal';
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS publish_at        TIMESTAMPTZ;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS expires_at        TIMESTAMPTZ;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS popup_frequency   TEXT        NOT NULL DEFAULT 'once_per_session';
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS dismiss_behavior  TEXT        NOT NULL DEFAULT 'dismissible';
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS acknowledge_label TEXT;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS link_new_tab      BOOLEAN     NOT NULL DEFAULT true;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS revision          INTEGER     NOT NULL DEFAULT 1;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS published_at      TIMESTAMPTZ;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS published_by      TEXT;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS updated_by        TEXT;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS archived_at       TIMESTAMPTZ;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS archived_by       TEXT;

DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT conname
    FROM pg_constraint
    WHERE conrelid = 'public.portal_alerts'::regclass
      AND contype = 'c'
      AND pg_get_constraintdef(oid) ILIKE '%target_type%'
  LOOP
    EXECUTE format('ALTER TABLE public.portal_alerts DROP CONSTRAINT %I', r.conname);
  END LOOP;
END $$;

ALTER TABLE public.portal_alerts ADD CONSTRAINT portal_alerts_target_type_check
  CHECK (target_type IN ('all', 'group', 'individual', 'public', 'students'));
ALTER TABLE public.portal_alerts DROP CONSTRAINT IF EXISTS portal_alerts_display_surface_check;
ALTER TABLE public.portal_alerts ADD CONSTRAINT portal_alerts_display_surface_check
  CHECK (display_surface IN ('portal', 'homepage', 'both'));
ALTER TABLE public.portal_alerts DROP CONSTRAINT IF EXISTS portal_alerts_lifecycle_status_check;
ALTER TABLE public.portal_alerts ADD CONSTRAINT portal_alerts_lifecycle_status_check
  CHECK (lifecycle_status IN ('draft', 'published', 'archived'));
ALTER TABLE public.portal_alerts DROP CONSTRAINT IF EXISTS portal_alerts_priority_check;
ALTER TABLE public.portal_alerts ADD CONSTRAINT portal_alerts_priority_check
  CHECK (priority IN ('normal', 'important', 'urgent', 'critical'));
ALTER TABLE public.portal_alerts DROP CONSTRAINT IF EXISTS portal_alerts_popup_frequency_check;
ALTER TABLE public.portal_alerts ADD CONSTRAINT portal_alerts_popup_frequency_check
  CHECK (popup_frequency IN ('every_visit', 'once_per_session', 'once_per_visitor'));
ALTER TABLE public.portal_alerts DROP CONSTRAINT IF EXISTS portal_alerts_dismiss_behavior_check;
ALTER TABLE public.portal_alerts ADD CONSTRAINT portal_alerts_dismiss_behavior_check
  CHECK (dismiss_behavior IN ('dismissible', 'acknowledge'));
ALTER TABLE public.portal_alerts DROP CONSTRAINT IF EXISTS portal_alerts_revision_check;
ALTER TABLE public.portal_alerts ADD CONSTRAINT portal_alerts_revision_check
  CHECK (revision >= 1);

UPDATE public.portal_alerts
SET priority = CASE severity WHEN 'critical' THEN 'critical' WHEN 'warn' THEN 'important' ELSE priority END
WHERE priority = 'normal'
  AND severity IN ('critical', 'warn');

CREATE INDEX IF NOT EXISTS idx_portal_alerts_surface_status
  ON public.portal_alerts (display_surface, lifecycle_status, is_active);
CREATE INDEX IF NOT EXISTS idx_portal_alerts_window
  ON public.portal_alerts (publish_at, expires_at);

CREATE TABLE IF NOT EXISTS public.portal_alert_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_name TEXT NOT NULL,
    title TEXT NOT NULL,
    message_html TEXT NOT NULL,
    severity TEXT NOT NULL DEFAULT 'info' CHECK (severity IN ('info', 'success', 'warn', 'critical')),
    requires_response BOOLEAN DEFAULT false,
    response_type TEXT DEFAULT 'none' CHECK (response_type IN ('none', 'yes_no')),
    yes_label TEXT DEFAULT 'Yes',
    no_label TEXT DEFAULT 'No',
    created_at TIMESTAMPTZ DEFAULT timezone('utc', now())
);
CREATE INDEX IF NOT EXISTS idx_portal_alert_templates_name ON public.portal_alert_templates(template_name);

CREATE TABLE IF NOT EXISTS public.portal_alert_impressions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_id UUID NOT NULL REFERENCES public.portal_alerts(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    shown_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    shown_date_local DATE NOT NULL,
    page_path TEXT,
    CONSTRAINT unique_impression UNIQUE (alert_id, student_id, shown_date_local)
);
CREATE INDEX IF NOT EXISTS idx_portal_alert_impressions_alert ON public.portal_alert_impressions(alert_id);
CREATE INDEX IF NOT EXISTS idx_portal_alert_impressions_student ON public.portal_alert_impressions(student_id);
CREATE INDEX IF NOT EXISTS idx_portal_alert_impressions_date ON public.portal_alert_impressions(shown_date_local);

CREATE TABLE IF NOT EXISTS public.portal_alert_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_id UUID NOT NULL REFERENCES public.portal_alerts(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    answer TEXT NOT NULL CHECK (answer IN ('yes', 'no')),
    answered_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    page_path TEXT,
    CONSTRAINT unique_response UNIQUE (alert_id, student_id)
);
CREATE INDEX IF NOT EXISTS idx_portal_alert_responses_alert ON public.portal_alert_responses(alert_id);
CREATE INDEX IF NOT EXISTS idx_portal_alert_responses_student ON public.portal_alert_responses(student_id);
CREATE INDEX IF NOT EXISTS idx_portal_alert_responses_answer ON public.portal_alert_responses(answer);

ALTER TABLE public.portal_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portal_alert_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portal_alert_impressions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portal_alert_responses ENABLE ROW LEVEL SECURITY;

-- NOTE: anonymous access is required because admin sign-in is client-side (see HOMEPAGE-POPUP-ALERTS-SETUP.md,
-- "Security model"). Content safety is enforced by the portal_alerts_v2_guard trigger below.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'portal_alerts' AND policyname = 'Admin full access to alerts') THEN
        CREATE POLICY "Admin full access to alerts" ON public.portal_alerts FOR ALL TO anon USING (true) WITH CHECK (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'portal_alert_templates' AND policyname = 'Admin full access to templates') THEN
        CREATE POLICY "Admin full access to templates" ON public.portal_alert_templates FOR ALL TO anon USING (true) WITH CHECK (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'portal_alert_impressions' AND policyname = 'Students can insert own impressions') THEN
        CREATE POLICY "Students can insert own impressions" ON public.portal_alert_impressions FOR INSERT TO anon WITH CHECK (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'portal_alert_impressions' AND policyname = 'Admin can read impressions') THEN
        CREATE POLICY "Admin can read impressions" ON public.portal_alert_impressions FOR SELECT TO anon USING (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'portal_alert_responses' AND policyname = 'Students can insert own responses') THEN
        CREATE POLICY "Students can insert own responses" ON public.portal_alert_responses FOR INSERT TO anon WITH CHECK (true);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'portal_alert_responses' AND policyname = 'Admin can read responses') THEN
        CREATE POLICY "Admin can read responses" ON public.portal_alert_responses FOR SELECT TO anon USING (true);
    END IF;
END$$;

CREATE OR REPLACE FUNCTION update_portal_alerts_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc', now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_portal_alerts_timestamp ON public.portal_alerts;
CREATE TRIGGER trigger_update_portal_alerts_timestamp
    BEFORE UPDATE ON public.portal_alerts
    FOR EACH ROW
    EXECUTE FUNCTION update_portal_alerts_updated_at();

CREATE OR REPLACE FUNCTION validate_alert_rules()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT (NEW.targeting_rules ? 'mode') THEN
    RAISE EXCEPTION 'targeting_rules must have "mode" key';
  END IF;
  IF NOT (NEW.frequency_rules ? 'cap_type') THEN
    RAISE EXCEPTION 'frequency_rules must have "cap_type" key';
  END IF;
  IF NOT (NEW.schedule_rules ? 'recurrence_type') THEN
    RAISE EXCEPTION 'schedule_rules must have "recurrence_type" key';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS validate_alert_rules_trigger ON public.portal_alerts;
CREATE TRIGGER validate_alert_rules_trigger
  BEFORE INSERT OR UPDATE ON public.portal_alerts
  FOR EACH ROW
  EXECUTE FUNCTION validate_alert_rules();

-- Lifecycle rules, content safety (public homepage!) and the revision counter
CREATE OR REPLACE FUNCTION public.portal_alerts_v2_guard()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_url TEXT;
BEGIN
  IF NEW.lifecycle_status IN ('draft', 'archived') THEN
    NEW.is_active := FALSE;
  ELSIF NEW.is_active IS NULL THEN
    NEW.is_active := TRUE;
  END IF;

  IF NEW.lifecycle_status = 'published' THEN
    IF TG_OP = 'INSERT' THEN
      NEW.published_at := COALESCE(NEW.published_at, now());
    ELSIF OLD.lifecycle_status IS DISTINCT FROM 'published'
          AND NEW.published_at IS NOT DISTINCT FROM OLD.published_at THEN
      NEW.published_at := now();
    END IF;
  END IF;

  IF NEW.lifecycle_status = 'archived' THEN
    IF TG_OP = 'INSERT' OR OLD.lifecycle_status IS DISTINCT FROM 'archived' THEN
      NEW.archived_at := COALESCE(NEW.archived_at, now());
    END IF;
  ELSE
    NEW.archived_at := NULL;
    NEW.archived_by := NULL;
  END IF;

  IF char_length(COALESCE(NEW.title, '')) > 200 THEN
    RAISE EXCEPTION 'Alert title is too long (maximum 200 characters).' USING ERRCODE = '22023';
  END IF;
  IF char_length(COALESCE(NEW.message_html, '')) > 20000 THEN
    RAISE EXCEPTION 'Alert message is too long (maximum 20,000 characters).' USING ERRCODE = '22023';
  END IF;
  IF char_length(COALESCE(NEW.link_label, '')) > 80 THEN
    RAISE EXCEPTION 'Button label is too long (maximum 80 characters).' USING ERRCODE = '22023';
  END IF;

  IF NEW.message_html ~* '<\s*/?\s*(script|iframe|object|embed|style|link|meta|base|form|svg|math)(\s|>|/|$)'
     OR NEW.message_html ~* '<[^>]*\son[a-z]+\s*='
     OR NEW.message_html ~* 'javascript\s*:'
     OR NEW.message_html ~* 'data\s*:\s*text/html' THEN
    RAISE EXCEPTION 'Alert message contains markup that is not allowed (scripts, frames, styles or event handlers).' USING ERRCODE = '22023';
  END IF;

  v_url := NULLIF(btrim(COALESCE(NEW.link_url, '')), '');
  IF v_url IS NOT NULL THEN
    IF NOT (v_url ~* '^(https?://|mailto:|tel:)[^[:space:]<>"'']+$' OR v_url ~ '^[^:[:space:]<>"'']+$') THEN
      RAISE EXCEPTION 'Alert link must start with https://, http://, mailto:, tel: or be a relative page such as hub.html.' USING ERRCODE = '22023';
    END IF;
  END IF;
  NEW.link_url := v_url;

  IF NEW.publish_at IS NOT NULL AND NEW.expires_at IS NOT NULL AND NEW.expires_at <= NEW.publish_at THEN
    RAISE EXCEPTION 'The expiration time must be later than the start time.' USING ERRCODE = '22023';
  END IF;

  IF TG_OP = 'UPDATE' AND NEW.revision IS NOT DISTINCT FROM OLD.revision THEN
    IF NEW.title             IS DISTINCT FROM OLD.title
       OR NEW.message_html      IS DISTINCT FROM OLD.message_html
       OR NEW.link_url          IS DISTINCT FROM OLD.link_url
       OR NEW.link_label        IS DISTINCT FROM OLD.link_label
       OR NEW.link_new_tab      IS DISTINCT FROM OLD.link_new_tab
       OR NEW.priority          IS DISTINCT FROM OLD.priority
       OR NEW.dismiss_behavior  IS DISTINCT FROM OLD.dismiss_behavior
       OR NEW.acknowledge_label IS DISTINCT FROM OLD.acknowledge_label THEN
      NEW.revision := OLD.revision + 1;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS portal_alerts_v2_guard_trg ON public.portal_alerts;
CREATE TRIGGER portal_alerts_v2_guard_trg
  BEFORE INSERT OR UPDATE ON public.portal_alerts
  FOR EACH ROW
  EXECUTE FUNCTION public.portal_alerts_v2_guard();

-- Delivery function for the public homepage (js/homepage-alerts.js)
CREATE OR REPLACE FUNCTION public.get_site_alerts(p_surface TEXT DEFAULT 'homepage')
RETURNS JSONB
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT jsonb_build_object(
    'server_time', to_jsonb(now()),
    'alerts', COALESCE(jsonb_agg(to_jsonb(a) ORDER BY a.prio_rank DESC, a.sort_ts DESC), '[]'::jsonb)
  )
  FROM (
    SELECT
      id, title, message_html, severity, priority, display_surface, display_position,
      link_url, link_label, link_new_tab, dismiss_behavior, acknowledge_label,
      popup_frequency, revision, target_type, target_student_ids, target_group,
      targeting_rules, schedule_rules, date_rule_type, monthly_start_day,
      monthly_end_day, custom_dates, publish_at, expires_at, published_at, created_at,
      CASE priority WHEN 'critical' THEN 4 WHEN 'urgent' THEN 3 WHEN 'important' THEN 2 ELSE 1 END AS prio_rank,
      COALESCE(publish_at, published_at, created_at) AS sort_ts
    FROM public.portal_alerts
    WHERE p_surface IN ('homepage', 'portal')
      AND is_active IS TRUE
      AND lifecycle_status = 'published'
      AND display_surface IN (p_surface, 'both')
      AND (publish_at IS NULL OR publish_at <= now())
      AND (expires_at IS NULL OR expires_at > now())
  ) a;
$$;

REVOKE ALL ON FUNCTION public.get_site_alerts(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_site_alerts(TEXT) TO anon, authenticated, service_role;

GRANT ALL ON public.portal_alerts, public.portal_alert_templates, public.portal_alert_impressions, public.portal_alert_responses TO service_role;
GRANT INSERT, SELECT, UPDATE, DELETE ON public.portal_alerts, public.portal_alert_templates TO anon;
GRANT INSERT, SELECT ON public.portal_alert_impressions, public.portal_alert_responses TO anon;
