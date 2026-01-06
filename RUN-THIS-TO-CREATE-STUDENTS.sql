-- Run this script inside the Supabase SQL editor to provision the students table

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
SET student_id = CONCAT('TMP-', LPAD((FLOOR(random() * 1000000000))::text, 9, '0'))
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

GRANT ALL ON public.students TO service_role;
GRANT INSERT, SELECT, UPDATE, DELETE ON public.students TO anon;
