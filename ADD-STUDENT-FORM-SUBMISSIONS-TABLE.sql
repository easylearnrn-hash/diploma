-- ============================================================
-- Student Form Submissions Table
-- Run this in Supabase SQL Editor BEFORE using forms.html
-- Project: https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr
-- ============================================================

CREATE TABLE IF NOT EXISTS public.student_form_submissions (
    id                  UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    reference_number    TEXT NOT NULL UNIQUE,
    form_key            TEXT NOT NULL,
    form_title          TEXT NOT NULL,
    form_category       TEXT NOT NULL,

    -- Student Identity
    student_id          TEXT,
    full_name           TEXT,
    institutional_email TEXT,
    program             TEXT,

    -- Submission Content
    subject             TEXT NOT NULL,
    statement           TEXT NOT NULL,
    effective_date      DATE,
    attachments         JSONB DEFAULT '[]'::jsonb,

    -- Status & Workflow
    status              TEXT NOT NULL DEFAULT 'submitted'
                            CHECK (status IN ('submitted','review','approved','denied','docs','closed')),
    priority            TEXT NOT NULL DEFAULT 'normal'
                            CHECK (priority IN ('low','normal','high','urgent')),

    -- Administrative
    admin_notes         TEXT,
    reviewed_by         TEXT,
    reviewed_at         TIMESTAMP WITH TIME ZONE,
    action_history      JSONB DEFAULT '[]'::jsonb,

    -- Timestamps
    submitted_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_sfs_student_id       ON public.student_form_submissions(student_id);
CREATE INDEX IF NOT EXISTS idx_sfs_status           ON public.student_form_submissions(status);
CREATE INDEX IF NOT EXISTS idx_sfs_reference_number ON public.student_form_submissions(reference_number);
CREATE INDEX IF NOT EXISTS idx_sfs_submitted_at     ON public.student_form_submissions(submitted_at DESC);
CREATE INDEX IF NOT EXISTS idx_sfs_email            ON public.student_form_submissions(institutional_email);
CREATE INDEX IF NOT EXISTS idx_sfs_priority         ON public.student_form_submissions(priority);

-- Enable Row Level Security
ALTER TABLE public.student_form_submissions ENABLE ROW LEVEL SECURITY;

-- RLS Policies (idempotent)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename  = 'student_form_submissions'
          AND policyname = 'Allow anon insert student form submissions'
    ) THEN
        CREATE POLICY "Allow anon insert student form submissions"
            ON public.student_form_submissions
            FOR INSERT TO anon
            WITH CHECK (true);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename  = 'student_form_submissions'
          AND policyname = 'Allow anon select student form submissions'
    ) THEN
        CREATE POLICY "Allow anon select student form submissions"
            ON public.student_form_submissions
            FOR SELECT TO anon
            USING (true);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename  = 'student_form_submissions'
          AND policyname = 'Allow anon update student form submissions'
    ) THEN
        CREATE POLICY "Allow anon update student form submissions"
            ON public.student_form_submissions
            FOR UPDATE TO anon
            USING (true)
            WITH CHECK (true);
    END IF;
END $$;

-- ============================================================
-- Supabase Storage: student-documents bucket
-- Run this AFTER the table above to enable document uploads
-- ============================================================

-- Create the bucket (public = files accessible via public URL)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'student-documents',
    'student-documents',
    true,
    10485760,  -- 10 MB limit
    ARRAY['application/pdf','application/msword',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          'image/jpeg','image/png','image/gif','image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- RLS policies for storage.objects
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'storage'
          AND tablename  = 'objects'
          AND policyname = 'Allow anon upload to student-documents'
    ) THEN
        CREATE POLICY "Allow anon upload to student-documents"
            ON storage.objects FOR INSERT TO anon
            WITH CHECK (bucket_id = 'student-documents');
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'storage'
          AND tablename  = 'objects'
          AND policyname = 'Allow anon read from student-documents'
    ) THEN
        CREATE POLICY "Allow anon read from student-documents"
            ON storage.objects FOR SELECT TO anon
            USING (bucket_id = 'student-documents');
    END IF;
END $$;
