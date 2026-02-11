-- Check if published_notes table exists and has data
SELECT COUNT(*) as total_published_notes FROM published_notes;

-- Check which students have published notes
SELECT 
  s.student_id, 
  s.full_name,
  COUNT(pn.id) as note_count
FROM students s
LEFT JOIN published_notes pn ON pn.student_id = s.id
GROUP BY s.student_id, s.full_name
ORDER BY note_count DESC;

-- Check for Ani Ezabela Abovian specifically
SELECT 
  s.student_id,
  s.full_name,
  pn.note_id,
  pn.published_at,
  pn.published_by
FROM students s
LEFT JOIN published_notes pn ON pn.student_id = s.id
WHERE s.full_name ILIKE '%Ani%Abovian%'
ORDER BY pn.published_at DESC;
