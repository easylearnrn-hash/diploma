-- ADD MIDTERM EXAMINATION I CERTIFICATE TO ALL STUDENTS
-- Source: Narine Avetisyan (ACNHS-7022395) already has this record.
-- This script adds it to every other student who does not yet have it.
-- Safe to run multiple times — uses ON CONFLICT DO NOTHING.

INSERT INTO certificates (cert_number, student_id, student_name, program, exam_title, score, grade, semester, academic_year, issue_date, officer, officer_title, status)
SELECT
  'CERT-ACNHS-' || upper(substring(md5(s.student_id || 'midterm1'), 1, 10)) AS cert_number,
  s.student_id,
  s.full_name,
  'Bachelor of Science in Nursing (BSN)',
  'Midterm Examination I',
  '97.5',
  'A+',
  'Spring 2026',
  '2025 – 2026',
  'March 21, 2026',
  'Dr. Hrachya Vardanyan',
  'Dean of Academic Affairs',
  'valid'
FROM students s
WHERE NOT EXISTS (
  SELECT 1 FROM certificates c
  WHERE c.student_id = s.student_id
    AND c.exam_title = 'Midterm Examination I'
);
