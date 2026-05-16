-- ══════════════════════════════════════════════════════════════
--  ACNHS  Student Grade Items Table
--  Maps every grade component (Attendance, Midterm, Final, etc.)
--  to each individual student, per course.
--
--  Run this in: https://supabase.com/dashboard → SQL Editor
-- ══════════════════════════════════════════════════════════════

-- ── 1. Create the table ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.student_grade_items (
  id              UUID          DEFAULT gen_random_uuid() PRIMARY KEY,

  -- Who
  student_id      UUID          NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,

  -- Which course
  course_code     TEXT          NOT NULL,

  -- Which component (matches courses.grade_items[].id)
  grade_item_id   TEXT          NOT NULL,   -- e.g. 'attendance', 'midterm_exam'
  grade_item_name TEXT          NOT NULL,   -- display name kept here for history

  -- Weight comes from the course schema; stored here for point-in-time accuracy
  weight          NUMERIC(5,2),             -- 0–100 (percent of final grade)

  -- The actual score
  score           NUMERIC(5,2)  CHECK (score IS NULL OR (score >= 0 AND score <= 100)),

  -- Workflow status
  status          TEXT          NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending','graded','excused','absent')),

  -- Audit fields
  graded_by       TEXT,                     -- admin email who entered the score
  graded_at       TIMESTAMPTZ,
  notes           TEXT,

  created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

  -- One row per student + course + component
  UNIQUE (student_id, course_code, grade_item_id)
);

-- ── 2. Indexes ─────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_sgi_student
  ON public.student_grade_items (student_id);

CREATE INDEX IF NOT EXISTS idx_sgi_course
  ON public.student_grade_items (course_code);

CREATE INDEX IF NOT EXISTS idx_sgi_student_course
  ON public.student_grade_items (student_id, course_code);

-- ── 3. Auto-update updated_at ──────────────────────────────────
CREATE OR REPLACE FUNCTION update_student_grade_items_ts()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sgi_updated_at ON public.student_grade_items;
CREATE TRIGGER trg_sgi_updated_at
  BEFORE UPDATE ON public.student_grade_items
  FOR EACH ROW EXECUTE FUNCTION update_student_grade_items_ts();

-- ── 4. Row Level Security ──────────────────────────────────────
ALTER TABLE public.student_grade_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "sgi anon select"  ON public.student_grade_items;
DROP POLICY IF EXISTS "sgi anon insert"  ON public.student_grade_items;
DROP POLICY IF EXISTS "sgi anon update"  ON public.student_grade_items;
DROP POLICY IF EXISTS "sgi anon delete"  ON public.student_grade_items;

CREATE POLICY "sgi anon select"
  ON public.student_grade_items FOR SELECT TO anon USING (true);

CREATE POLICY "sgi anon insert"
  ON public.student_grade_items FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "sgi anon update"
  ON public.student_grade_items FOR UPDATE TO anon USING (true);

CREATE POLICY "sgi anon delete"
  ON public.student_grade_items FOR DELETE TO anon USING (true);

-- ── 5. Seed helper: auto-create pending rows for all enrolled
--      students when grade components are already in `courses`
--  (Run manually after seeding courses; safe to run multiple times)
-- ──────────────────────────────────────────────────────────────
DO $$
DECLARE
  r   RECORD;
  gi  JSONB;
  item JSONB;
BEGIN
  FOR r IN
    SELECT s.id AS student_id, e.course_code
    FROM   public.students s
    JOIN   public.student_grades e
           ON e.student_id = s.id        -- reuse existing enrollment link
  LOOP
    SELECT grade_items INTO gi
    FROM   public.courses
    WHERE  code = r.course_code
    LIMIT  1;

    IF gi IS NOT NULL THEN
      FOR item IN SELECT * FROM jsonb_array_elements(gi)
      LOOP
        INSERT INTO public.student_grade_items
          (student_id, course_code, grade_item_id, grade_item_name, weight, status)
        VALUES (
          r.student_id,
          r.course_code,
          item->>'id',
          item->>'name',
          (item->>'weight')::NUMERIC,
          'pending'
        )
        ON CONFLICT (student_id, course_code, grade_item_id) DO NOTHING;
      END LOOP;
    END IF;
  END LOOP;
END;
$$;

-- ── 6. Convenience view: weighted score per student per course ─
CREATE OR REPLACE VIEW public.v_student_course_grades AS
SELECT
  sgi.student_id,
  sgi.course_code,
  COUNT(*)                                                     AS total_items,
  COUNT(*) FILTER (WHERE sgi.status = 'graded')               AS graded_items,
  ROUND(
    SUM(sgi.score * sgi.weight) FILTER (WHERE sgi.status = 'graded')
    / NULLIF(SUM(sgi.weight)    FILTER (WHERE sgi.status = 'graded'), 0),
  1)                                                           AS weighted_avg,
  CASE
    WHEN SUM(sgi.weight) FILTER (WHERE sgi.status = 'graded') IS NULL THEN 'No grades posted'
    WHEN ROUND(SUM(sgi.score*sgi.weight) FILTER (WHERE sgi.status='graded')
         / SUM(sgi.weight) FILTER (WHERE sgi.status='graded'), 1) >= 93 THEN 'A'
    WHEN ROUND(SUM(sgi.score*sgi.weight) FILTER (WHERE sgi.status='graded')
         / SUM(sgi.weight) FILTER (WHERE sgi.status='graded'), 1) >= 90 THEN 'A−'
    WHEN ROUND(SUM(sgi.score*sgi.weight) FILTER (WHERE sgi.status='graded')
         / SUM(sgi.weight) FILTER (WHERE sgi.status='graded'), 1) >= 87 THEN 'B+'
    WHEN ROUND(SUM(sgi.score*sgi.weight) FILTER (WHERE sgi.status='graded')
         / SUM(sgi.weight) FILTER (WHERE sgi.status='graded'), 1) >= 83 THEN 'B'
    WHEN ROUND(SUM(sgi.score*sgi.weight) FILTER (WHERE sgi.status='graded')
         / SUM(sgi.weight) FILTER (WHERE sgi.status='graded'), 1) >= 80 THEN 'B−'
    WHEN ROUND(SUM(sgi.score*sgi.weight) FILTER (WHERE sgi.status='graded')
         / SUM(sgi.weight) FILTER (WHERE sgi.status='graded'), 1) >= 77 THEN 'C+'
    WHEN ROUND(SUM(sgi.score*sgi.weight) FILTER (WHERE sgi.status='graded')
         / SUM(sgi.weight) FILTER (WHERE sgi.status='graded'), 1) >= 73 THEN 'C'
    WHEN ROUND(SUM(sgi.score*sgi.weight) FILTER (WHERE sgi.status='graded')
         / SUM(sgi.weight) FILTER (WHERE sgi.status='graded'), 1) >= 70 THEN 'C−'
    WHEN ROUND(SUM(sgi.score*sgi.weight) FILTER (WHERE sgi.status='graded')
         / SUM(sgi.weight) FILTER (WHERE sgi.status='graded'), 1) >= 60 THEN 'D'
    ELSE 'F'
  END                                                          AS letter_grade
FROM   public.student_grade_items sgi
GROUP  BY sgi.student_id, sgi.course_code;

-- ── 7. Quick sanity check ──────────────────────────────────────
-- SELECT * FROM public.student_grade_items LIMIT 10;
-- SELECT * FROM public.v_student_course_grades LIMIT 10;
