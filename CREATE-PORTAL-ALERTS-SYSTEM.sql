-- ==========================================
-- PORTAL ALERTS SYSTEM - COMPLETE SCHEMA
-- ==========================================
-- Run this in Supabase SQL Editor to create all alert tables
-- Last updated: 2026-02-13

-- ==========================================
-- 1. PORTAL ALERTS (main alerts table)
-- ==========================================

CREATE TABLE IF NOT EXISTS public.portal_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Basic info
    title TEXT NOT NULL,
    message_html TEXT NOT NULL,
    severity TEXT NOT NULL DEFAULT 'info' CHECK (severity IN ('info', 'success', 'warn', 'critical')),
    is_active BOOLEAN DEFAULT true,
    
    -- Audit
    created_by TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    
    -- Targeting
    target_type TEXT NOT NULL DEFAULT 'all' CHECK (target_type IN ('all', 'individual')),
    target_student_ids JSONB DEFAULT '[]'::jsonb,
    
    -- Display rules
    display_mode TEXT NOT NULL DEFAULT 'once_ever' CHECK (display_mode IN (
        'every_load',
        'once_ever',
        'times_limit',
        'daily',
        'daily_first_login'
    )),
    max_displays INTEGER,
    
    -- Date/schedule rules
    date_rule_type TEXT NOT NULL DEFAULT 'always' CHECK (date_rule_type IN (
        'always',
        'date_range',
        'monthly_range',
        'custom_dates'
    )),
    start_date DATE,
    end_date DATE,
    monthly_start_day INTEGER CHECK (monthly_start_day >= 1 AND monthly_start_day <= 31),
    monthly_end_day INTEGER CHECK (monthly_end_day >= 1 AND monthly_end_day <= 31),
    custom_dates JSONB DEFAULT '[]'::jsonb,
    timezone TEXT DEFAULT 'Asia/Yerevan',
    
    -- Interactivity
    requires_response BOOLEAN DEFAULT false,
    response_type TEXT DEFAULT 'none' CHECK (response_type IN ('none', 'yes_no')),
    yes_label TEXT DEFAULT 'Yes',
    no_label TEXT DEFAULT 'No'
);

-- Add columns if they don't exist (idempotent)
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS title TEXT;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS message_html TEXT;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS severity TEXT;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS is_active BOOLEAN;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS created_by TEXT;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS target_type TEXT;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS target_student_ids JSONB;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS display_mode TEXT;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS max_displays INTEGER;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS date_rule_type TEXT;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS start_date DATE;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS end_date DATE;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS monthly_start_day INTEGER;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS monthly_end_day INTEGER;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS custom_dates JSONB;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS timezone TEXT;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS requires_response BOOLEAN;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS response_type TEXT;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS yes_label TEXT;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS no_label TEXT;

-- Set defaults
ALTER TABLE public.portal_alerts ALTER COLUMN severity SET DEFAULT 'info';
ALTER TABLE public.portal_alerts ALTER COLUMN is_active SET DEFAULT true;
ALTER TABLE public.portal_alerts ALTER COLUMN target_type SET DEFAULT 'all';
ALTER TABLE public.portal_alerts ALTER COLUMN target_student_ids SET DEFAULT '[]'::jsonb;
ALTER TABLE public.portal_alerts ALTER COLUMN display_mode SET DEFAULT 'once_ever';
ALTER TABLE public.portal_alerts ALTER COLUMN date_rule_type SET DEFAULT 'always';
ALTER TABLE public.portal_alerts ALTER COLUMN custom_dates SET DEFAULT '[]'::jsonb;
ALTER TABLE public.portal_alerts ALTER COLUMN timezone SET DEFAULT 'Asia/Yerevan';
ALTER TABLE public.portal_alerts ALTER COLUMN requires_response SET DEFAULT false;
ALTER TABLE public.portal_alerts ALTER COLUMN response_type SET DEFAULT 'none';
ALTER TABLE public.portal_alerts ALTER COLUMN yes_label SET DEFAULT 'Yes';
ALTER TABLE public.portal_alerts ALTER COLUMN no_label SET DEFAULT 'No';
ALTER TABLE public.portal_alerts ALTER COLUMN created_at SET DEFAULT timezone('utc', now());
ALTER TABLE public.portal_alerts ALTER COLUMN updated_at SET DEFAULT timezone('utc', now());

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_portal_alerts_active ON public.portal_alerts(is_active);
CREATE INDEX IF NOT EXISTS idx_portal_alerts_target_type ON public.portal_alerts(target_type);
CREATE INDEX IF NOT EXISTS idx_portal_alerts_created_at ON public.portal_alerts(created_at DESC);

-- ==========================================
-- 2. PORTAL ALERT TEMPLATES
-- ==========================================

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

ALTER TABLE public.portal_alert_templates ADD COLUMN IF NOT EXISTS template_name TEXT;
ALTER TABLE public.portal_alert_templates ADD COLUMN IF NOT EXISTS title TEXT;
ALTER TABLE public.portal_alert_templates ADD COLUMN IF NOT EXISTS message_html TEXT;
ALTER TABLE public.portal_alert_templates ADD COLUMN IF NOT EXISTS severity TEXT;
ALTER TABLE public.portal_alert_templates ADD COLUMN IF NOT EXISTS requires_response BOOLEAN;
ALTER TABLE public.portal_alert_templates ADD COLUMN IF NOT EXISTS response_type TEXT;
ALTER TABLE public.portal_alert_templates ADD COLUMN IF NOT EXISTS yes_label TEXT;
ALTER TABLE public.portal_alert_templates ADD COLUMN IF NOT EXISTS no_label TEXT;
ALTER TABLE public.portal_alert_templates ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_portal_alert_templates_name ON public.portal_alert_templates(template_name);

-- ==========================================
-- 3. PORTAL ALERT IMPRESSIONS (tracking)
-- ==========================================

CREATE TABLE IF NOT EXISTS public.portal_alert_impressions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_id UUID NOT NULL REFERENCES public.portal_alerts(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    shown_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    shown_date_local DATE NOT NULL,
    page_path TEXT,
    CONSTRAINT unique_impression UNIQUE (alert_id, student_id, shown_date_local)
);

ALTER TABLE public.portal_alert_impressions ADD COLUMN IF NOT EXISTS alert_id UUID;
ALTER TABLE public.portal_alert_impressions ADD COLUMN IF NOT EXISTS student_id UUID;
ALTER TABLE public.portal_alert_impressions ADD COLUMN IF NOT EXISTS shown_at TIMESTAMPTZ;
ALTER TABLE public.portal_alert_impressions ADD COLUMN IF NOT EXISTS shown_date_local DATE;
ALTER TABLE public.portal_alert_impressions ADD COLUMN IF NOT EXISTS page_path TEXT;

ALTER TABLE public.portal_alert_impressions ALTER COLUMN shown_at SET DEFAULT timezone('utc', now());

-- Indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_portal_alert_impressions_alert ON public.portal_alert_impressions(alert_id);
CREATE INDEX IF NOT EXISTS idx_portal_alert_impressions_student ON public.portal_alert_impressions(student_id);
CREATE INDEX IF NOT EXISTS idx_portal_alert_impressions_date ON public.portal_alert_impressions(shown_date_local);

-- ==========================================
-- 4. PORTAL ALERT RESPONSES (Yes/No answers)
-- ==========================================

CREATE TABLE IF NOT EXISTS public.portal_alert_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_id UUID NOT NULL REFERENCES public.portal_alerts(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    answer TEXT NOT NULL CHECK (answer IN ('yes', 'no')),
    answered_at TIMESTAMPTZ DEFAULT timezone('utc', now()),
    page_path TEXT,
    CONSTRAINT unique_response UNIQUE (alert_id, student_id)
);

ALTER TABLE public.portal_alert_responses ADD COLUMN IF NOT EXISTS alert_id UUID;
ALTER TABLE public.portal_alert_responses ADD COLUMN IF NOT EXISTS student_id UUID;
ALTER TABLE public.portal_alert_responses ADD COLUMN IF NOT EXISTS answer TEXT;
ALTER TABLE public.portal_alert_responses ADD COLUMN IF NOT EXISTS answered_at TIMESTAMPTZ;
ALTER TABLE public.portal_alert_responses ADD COLUMN IF NOT EXISTS page_path TEXT;

ALTER TABLE public.portal_alert_responses ALTER COLUMN answered_at SET DEFAULT timezone('utc', now());

-- Indexes
CREATE INDEX IF NOT EXISTS idx_portal_alert_responses_alert ON public.portal_alert_responses(alert_id);
CREATE INDEX IF NOT EXISTS idx_portal_alert_responses_student ON public.portal_alert_responses(student_id);
CREATE INDEX IF NOT EXISTS idx_portal_alert_responses_answer ON public.portal_alert_responses(answer);

-- ==========================================
-- 5. ROW LEVEL SECURITY (RLS)
-- ==========================================

ALTER TABLE public.portal_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portal_alert_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portal_alert_impressions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.portal_alert_responses ENABLE ROW LEVEL SECURITY;

-- Admin can do everything
DO $$
BEGIN
    -- Portal alerts - admin access
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE schemaname = 'public' 
        AND tablename = 'portal_alerts' AND policyname = 'Admin full access to alerts'
    ) THEN
        CREATE POLICY "Admin full access to alerts"
            ON public.portal_alerts FOR ALL TO anon USING (true) WITH CHECK (true);
    END IF;
    
    -- Templates - admin access
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE schemaname = 'public' 
        AND tablename = 'portal_alert_templates' AND policyname = 'Admin full access to templates'
    ) THEN
        CREATE POLICY "Admin full access to templates"
            ON public.portal_alert_templates FOR ALL TO anon USING (true) WITH CHECK (true);
    END IF;
    
    -- Impressions - students can insert their own
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE schemaname = 'public' 
        AND tablename = 'portal_alert_impressions' AND policyname = 'Students can insert own impressions'
    ) THEN
        CREATE POLICY "Students can insert own impressions"
            ON public.portal_alert_impressions FOR INSERT TO anon WITH CHECK (true);
    END IF;
    
    -- Impressions - admin can read all
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE schemaname = 'public' 
        AND tablename = 'portal_alert_impressions' AND policyname = 'Admin can read impressions'
    ) THEN
        CREATE POLICY "Admin can read impressions"
            ON public.portal_alert_impressions FOR SELECT TO anon USING (true);
    END IF;
    
    -- Responses - students can insert/update their own
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE schemaname = 'public' 
        AND tablename = 'portal_alert_responses' AND policyname = 'Students can insert own responses'
    ) THEN
        CREATE POLICY "Students can insert own responses"
            ON public.portal_alert_responses FOR INSERT TO anon WITH CHECK (true);
    END IF;
    
    -- Responses - admin can read all
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE schemaname = 'public' 
        AND tablename = 'portal_alert_responses' AND policyname = 'Admin can read responses'
    ) THEN
        CREATE POLICY "Admin can read responses"
            ON public.portal_alert_responses FOR SELECT TO anon USING (true);
    END IF;
END$$;

-- ==========================================
-- 6. TRIGGERS (auto-update timestamps)
-- ==========================================

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

-- ==========================================
-- 7. INSERT DEFAULT TEMPLATES (10 prebuilt)
-- ==========================================

INSERT INTO public.portal_alert_templates (template_name, title, message_html, severity, requires_response, response_type, yes_label, no_label)
VALUES
(
    'Portal Maintenance Notice',
    'Scheduled Portal Maintenance',
    '<p>The student portal will undergo scheduled maintenance on <strong>[DATE]</strong> from <strong>[TIME START]</strong> to <strong>[TIME END]</strong>.</p><p>During this time, the portal may be temporarily unavailable. We apologize for any inconvenience.</p>',
    'warn',
    false,
    'none',
    'Yes',
    'No'
),
(
    'Payment Reminder',
    'Tuition Payment Reminder',
    '<p>This is a friendly reminder that your tuition payment for <strong>[SEMESTER]</strong> is due by <strong>[DUE DATE]</strong>.</p><ul><li>Amount due: <strong>[AMOUNT]</strong></li><li>Payment methods: Bank transfer, online portal</li></ul><p>Please ensure timely payment to avoid late fees.</p>',
    'warn',
    false,
    'none',
    'Yes',
    'No'
),
(
    'Orientation Confirmation',
    'Confirm Your Attendance: New Student Orientation',
    '<p>Welcome to Armenian College of Nurses! We are excited to have you join our community.</p><p><strong>New Student Orientation</strong><br>Date: <strong>[DATE]</strong><br>Time: <strong>[TIME]</strong><br>Location: <strong>[LOCATION]</strong></p><p>Will you be attending?</p>',
    'info',
    true,
    'yes_no',
    'Yes, I will attend',
    'No, I cannot attend'
),
(
    'Clinical Schedule Acknowledgment',
    'Clinical Schedule Posted - Acknowledgment Required',
    '<p>Your clinical rotation schedule for <strong>[TERM]</strong> has been posted to your portal.</p><p>Please review your schedule carefully and confirm that you have received and understood the schedule.</p><ul><li>Review dates and times</li><li>Note hospital locations</li><li>Check required documentation</li></ul><p>Have you reviewed your clinical schedule?</p>',
    'critical',
    true,
    'yes_no',
    'Yes, I have reviewed it',
    'No, I need help'
),
(
    'Exam Week Announcement',
    'Upcoming Exam Week - Important Information',
    '<p><strong>Exam Week:</strong> <strong>[DATE RANGE]</strong></p><p><strong>Important reminders:</strong></p><ul><li>Bring your student ID to all exams</li><li>Arrive 15 minutes before scheduled time</li><li>Review exam locations posted on portal</li><li>No make-up exams without prior approval</li></ul><p>Good luck with your studies!</p>',
    'info',
    false,
    'none',
    'Yes',
    'No'
),
(
    'New Notes Posted',
    'New Course Materials Available',
    '<p>New lecture notes and course materials have been posted for:</p><ul><li><strong>[COURSE NAME]</strong></li><li>Posted by: <strong>[INSTRUCTOR]</strong></li><li>Date: <strong>[DATE]</strong></li></ul><p>Access the materials through the "My Courses" section.</p>',
    'success',
    false,
    'none',
    'Yes',
    'No'
),
(
    'Policy Update Acknowledgment',
    'Important Policy Update - Acknowledgment Required',
    '<p>The college has updated its <strong>[POLICY NAME]</strong> policy, effective <strong>[EFFECTIVE DATE]</strong>.</p><p><strong>Key changes:</strong></p><ul><li>[CHANGE 1]</li><li>[CHANGE 2]</li><li>[CHANGE 3]</li></ul><p>Please review the full policy document in your portal under "College Policies."</p><p>I acknowledge that I have read and understood this policy update.</p>',
    'critical',
    true,
    'yes_no',
    'I acknowledge',
    'I need clarification'
),
(
    'Missing Documents Reminder',
    'Action Required: Missing Documents',
    '<p>Our records indicate that you have outstanding documents that need to be submitted:</p><ul><li>[DOCUMENT 1]</li><li>[DOCUMENT 2]</li></ul><p><strong>Deadline:</strong> <strong>[DEADLINE]</strong></p><p>Please upload these documents through your portal as soon as possible. Failure to submit may affect your enrollment status.</p>',
    'warn',
    false,
    'none',
    'Yes',
    'No'
),
(
    'Class Time Change',
    'Schedule Change Notification',
    '<p>Please be advised that the following class has a schedule change:</p><p><strong>Course:</strong> [COURSE NAME]<br><strong>Original time:</strong> [OLD TIME]<br><strong>New time:</strong> [NEW TIME]<br><strong>Effective date:</strong> [DATE]</p><p>Please update your personal schedule accordingly.</p>',
    'warn',
    false,
    'none',
    'Yes',
    'No'
),
(
    'Milestone Congratulations',
    'Congratulations on Your Achievement!',
    '<p>Dear Student,</p><p>Congratulations on <strong>[ACHIEVEMENT]</strong>!</p><p>Your dedication and hard work have not gone unnoticed. The faculty and staff at Armenian College of Nurses are proud of your accomplishments.</p><p>Keep up the excellent work!</p><p><em>— ACNHS Administration</em></p>',
    'success',
    false,
    'none',
    'Yes',
    'No'
)
ON CONFLICT DO NOTHING;

-- ==========================================
-- VERIFICATION
-- ==========================================

SELECT 
    'Portal alerts system created successfully!' AS status,
    (SELECT COUNT(*) FROM public.portal_alert_templates) AS template_count;
