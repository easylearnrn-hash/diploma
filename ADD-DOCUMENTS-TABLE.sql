-- ══════════════════════════════════════════════════════════════
--  ACNHS Document Registry Table
--  Run this in: https://supabase.com/dashboard → SQL Editor
-- ══════════════════════════════════════════════════════════════

-- 1. Create the table
CREATE TABLE IF NOT EXISTS documents (
  id              BIGSERIAL PRIMARY KEY,
  doc_type        TEXT        NOT NULL,          -- 'CAA' | 'MOU' | etc.
  ref_number      TEXT        NOT NULL UNIQUE,   -- e.g. ACNHS-CAA-2026-003
  partner_name    TEXT,                          -- Hospital / Institution name
  partner_address TEXT,
  issued_date     DATE        NOT NULL DEFAULT CURRENT_DATE,
  start_date      DATE,
  created_by      TEXT,                          -- admin email
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  pdf_filename    TEXT,                          -- filename used for export
  form_data       JSONB                          -- full serialized form fields for reload
);

-- 2. Index for fast lookups by type + year
CREATE INDEX IF NOT EXISTS idx_documents_type_year
  ON documents (doc_type, EXTRACT(YEAR FROM issued_date));

-- 3. RLS: allow anon reads and inserts (admin-only in production)
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow anon insert documents" ON documents;
CREATE POLICY "Allow anon insert documents"
  ON documents FOR INSERT TO anon WITH CHECK (true);

DROP POLICY IF EXISTS "Allow anon select documents" ON documents;
CREATE POLICY "Allow anon select documents"
  ON documents FOR SELECT TO anon USING (true);

-- 3b. Add form_data column to existing table (idempotent)
ALTER TABLE documents ADD COLUMN IF NOT EXISTS form_data JSONB;

-- 4. Helper function: get next sequential number for a doc type in a given year
CREATE OR REPLACE FUNCTION next_doc_sequence(p_type TEXT, p_year INT)
RETURNS INT
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(
    MAX(
      CAST(
        SPLIT_PART(ref_number, '-', 4) AS INT
      )
    ), 0
  ) + 1
  FROM documents
  WHERE doc_type = p_type
    AND EXTRACT(YEAR FROM issued_date) = p_year;
$$;
