-- ============================================================
-- ACNHS Certificates Table
-- Run this in the Supabase SQL Editor:
-- https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr/sql
-- ============================================================

CREATE TABLE IF NOT EXISTS public.certificates (
    id               UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    cert_number      TEXT        UNIQUE NOT NULL,          -- e.g. CERT-ACNHS-A3F7B2...
    student_id       TEXT        NOT NULL DEFAULT '',
    student_name     TEXT        NOT NULL,
    program          TEXT        NOT NULL DEFAULT '',
    exam_title       TEXT        NOT NULL DEFAULT '',
    score            TEXT,                                  -- e.g. "91%"
    grade            TEXT        NOT NULL DEFAULT '',       -- e.g. "A", "B+", "Pass"
    semester         TEXT,                                  -- e.g. "Spring 2026"
    academic_year    TEXT,                                  -- e.g. "2025 – 2026"
    issue_date       TEXT        NOT NULL,                  -- formatted display date
    officer          TEXT,
    officer_title    TEXT,
    signatory2       TEXT,
    signatory2_title TEXT,
    status           TEXT        NOT NULL DEFAULT 'valid'
                                 CHECK (status IN ('valid', 'revoked')),
    created_at       TIMESTAMPTZ DEFAULT NOW(),
    updated_at       TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_certificates_cert_number ON public.certificates (cert_number);
CREATE INDEX IF NOT EXISTS idx_certificates_student_id  ON public.certificates (student_id);
CREATE INDEX IF NOT EXISTS idx_certificates_status      ON public.certificates (status);

-- Auto-update updated_at on row change
CREATE OR REPLACE FUNCTION update_certificates_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_certificates_updated_at ON public.certificates;
CREATE TRIGGER trg_certificates_updated_at
    BEFORE UPDATE ON public.certificates
    FOR EACH ROW EXECUTE FUNCTION update_certificates_updated_at();

-- ── Row Level Security ────────────────────────────────────────────
ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;

-- Public can look up any certificate (for QR verification)
DROP POLICY IF EXISTS "Public read certificates" ON public.certificates;
CREATE POLICY "Public read certificates"
    ON public.certificates FOR SELECT
    TO anon, authenticated
    USING (true);

-- Anon (admin via browser) can insert new certificates
DROP POLICY IF EXISTS "Anon insert certificates" ON public.certificates;
CREATE POLICY "Anon insert certificates"
    ON public.certificates FOR INSERT
    TO anon
    WITH CHECK (true);

-- Anon can update certificates (e.g. revoke)
DROP POLICY IF EXISTS "Anon update certificates" ON public.certificates;
CREATE POLICY "Anon update certificates"
    ON public.certificates FOR UPDATE
    TO anon
    USING (true)
    WITH CHECK (true);

-- ── Done ─────────────────────────────────────────────────────────
-- After running this, certificates issued in certificate.html
-- will be stored here and verifiable at:
-- https://www.acnhs.am/verify-transcript.html?cert=CERT-ACNHS-XXXXXX
