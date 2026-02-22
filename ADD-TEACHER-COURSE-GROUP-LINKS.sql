-- ============================================================
-- ADD-TEACHER-COURSE-GROUP-LINKS.sql
-- Run in Supabase SQL Editor
-- Links: courses ↔ teachers, attendance_records ↔ groups
-- ============================================================

-- 1. Add teacher_id to courses table
--    Links a course to the teacher responsible for it
ALTER TABLE courses
  ADD COLUMN IF NOT EXISTS teacher_id UUID REFERENCES teachers(id) ON DELETE SET NULL;

-- 2. Add group_id to attendance_records
--    Allows filtering/querying attendance by group
ALTER TABLE attendance_records
  ADD COLUMN IF NOT EXISTS group_id TEXT;

-- 3. Index for fast group-based attendance queries
CREATE INDEX IF NOT EXISTS idx_attendance_group_id
  ON attendance_records(group_id);

CREATE INDEX IF NOT EXISTS idx_attendance_course_group
  ON attendance_records(course_code, group_id, session_date);

-- 4. Index for course → teacher lookups
CREATE INDEX IF NOT EXISTS idx_courses_teacher_id
  ON courses(teacher_id);

-- 5. Backfill: link existing courses to teachers based on teachers.subjects matching course.name
--    This runs a best-effort match: if a teacher's subjects array contains the course name, link them
DO $$
DECLARE
  rec RECORD;
  matched_teacher_id UUID;
BEGIN
  FOR rec IN SELECT id, name FROM courses WHERE teacher_id IS NULL LOOP
    SELECT id INTO matched_teacher_id
    FROM teachers
    WHERE subjects @> ARRAY[rec.name]::text[]
    LIMIT 1;

    IF matched_teacher_id IS NOT NULL THEN
      UPDATE courses SET teacher_id = matched_teacher_id WHERE id = rec.id;
      RAISE NOTICE 'Linked course % to teacher %', rec.name, matched_teacher_id;
    END IF;
  END LOOP;
END $$;

-- 6. Helper view: course → enrolled groups → students → teacher
--    Use this to see the full academic relationship in one query
CREATE OR REPLACE VIEW course_group_teacher_view AS
SELECT
  c.id          AS course_id,
  c.code        AS course_code,
  c.name        AS course_name,
  c.semester,
  c.teacher_id,
  t.full_name   AS teacher_name,
  t.email       AS teacher_email,
  ce.id         AS enrollment_id,
  ce.enrolled_group_ids,
  sg.id         AS group_id,
  sg.name       AS group_name,
  sg.student_ids
FROM courses c
LEFT JOIN teachers t ON t.id = c.teacher_id
LEFT JOIN course_enrollments ce
  ON ce.course_code = c.code AND ce.semester = c.semester
LEFT JOIN student_groups sg
  ON sg.id = ANY(ce.enrolled_group_ids);

-- Grant anonymous read access (required for client-side queries)
GRANT SELECT ON course_group_teacher_view TO anon;
