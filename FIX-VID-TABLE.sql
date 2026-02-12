-- SIMPLE VID SETUP - NO FOREIGN KEY CONSTRAINTS
-- Run this in Supabase SQL Editor to fix the 406 error

-- Drop the table if it exists (to remove broken foreign key)
DROP TABLE IF EXISTS public.admin_private_notes CASCADE;

-- Create admin_private_notes table (NO FOREIGN KEYS)
CREATE TABLE public.admin_private_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_email TEXT NOT NULL,
  student_id TEXT NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(admin_email, student_id)
);

-- Create indexes for performance
CREATE INDEX idx_admin_notes_admin_email ON public.admin_private_notes(admin_email);
CREATE INDEX idx_admin_notes_student_id ON public.admin_private_notes(student_id);
CREATE INDEX idx_admin_notes_updated ON public.admin_private_notes(updated_at DESC);

-- Enable RLS
ALTER TABLE public.admin_private_notes ENABLE ROW LEVEL SECURITY;

-- DROP old policies if they exist
DROP POLICY IF EXISTS "Allow anon select" ON public.admin_private_notes;
DROP POLICY IF EXISTS "Allow anon insert" ON public.admin_private_notes;
DROP POLICY IF EXISTS "Allow anon update" ON public.admin_private_notes;
DROP POLICY IF EXISTS "Allow anon delete" ON public.admin_private_notes;

-- Create NEW policies with USING (true) for full access
CREATE POLICY "Allow anon select" 
  ON public.admin_private_notes 
  FOR SELECT 
  TO anon 
  USING (true);

CREATE POLICY "Allow anon insert" 
  ON public.admin_private_notes 
  FOR INSERT 
  TO anon 
  WITH CHECK (true);

CREATE POLICY "Allow anon update" 
  ON public.admin_private_notes 
  FOR UPDATE 
  TO anon 
  USING (true) 
  WITH CHECK (true);

CREATE POLICY "Allow anon delete" 
  ON public.admin_private_notes 
  FOR DELETE 
  TO anon 
  USING (true);

-- Auto-update timestamp function
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update
DROP TRIGGER IF EXISTS set_updated_at ON public.admin_private_notes;
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.admin_private_notes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Verify table and permissions
SELECT 
  'SUCCESS: admin_private_notes table created!' as status,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables 
WHERE tablename = 'admin_private_notes';

-- Test query to verify access
SELECT COUNT(*) as row_count FROM public.admin_private_notes;
