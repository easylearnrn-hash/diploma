-- ============================================
-- SUBJECTS AND TOPICS SYSTEM
-- ============================================
-- This creates a flexible system where you can add subjects and topics from Supabase

-- Create subjects table
CREATE TABLE IF NOT EXISTS test_subjects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  icon TEXT, -- emoji or icon code
  display_order INTEGER,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create topics table (belongs to a subject)
CREATE TABLE IF NOT EXISTS test_topics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id UUID NOT NULL REFERENCES test_subjects(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  display_order INTEGER,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(subject_id, name)
);

-- Update test_configs to use subject_id instead of hardcoded test
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='test_configs' AND column_name='subject_id') THEN
    ALTER TABLE test_configs ADD COLUMN subject_id UUID REFERENCES test_subjects(id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='test_configs' AND column_name='topic_id') THEN
    ALTER TABLE test_configs ADD COLUMN topic_id UUID REFERENCES test_topics(id);
  END IF;
END $$;

-- Update test_questions to link to topics
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='test_questions' AND column_name='topic_id') THEN
    ALTER TABLE test_questions ADD COLUMN topic_id UUID REFERENCES test_topics(id);
  END IF;
  
  -- Keep category column for backward compatibility, don't drop it
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='test_questions' AND column_name='category') THEN
    ALTER TABLE test_questions ADD COLUMN category TEXT;
  END IF;
END $$;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_test_subjects_active ON test_subjects(is_active);
CREATE INDEX IF NOT EXISTS idx_test_topics_subject_id ON test_topics(subject_id);
CREATE INDEX IF NOT EXISTS idx_test_topics_active ON test_topics(is_active);
CREATE INDEX IF NOT EXISTS idx_test_configs_subject ON test_configs(subject_id);
CREATE INDEX IF NOT EXISTS idx_test_configs_topic ON test_configs(topic_id);
CREATE INDEX IF NOT EXISTS idx_test_questions_topic ON test_questions(topic_id);

-- RLS Policies
ALTER TABLE test_subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE test_topics ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can view active subjects" ON test_subjects;
DROP POLICY IF EXISTS "Anyone can view active topics" ON test_topics;
DROP POLICY IF EXISTS "Authenticated can manage subjects" ON test_subjects;
DROP POLICY IF EXISTS "Authenticated can manage topics" ON test_topics;

-- Allow anonymous read
CREATE POLICY "Anyone can view active subjects"
  ON test_subjects FOR SELECT
  USING (is_active = true);

CREATE POLICY "Anyone can view active topics"
  ON test_topics FOR SELECT
  USING (is_active = true);

-- Allow authenticated users to manage
CREATE POLICY "Authenticated can manage subjects"
  ON test_subjects FOR ALL
  USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated can manage topics"
  ON test_topics FOR ALL
  USING (auth.role() = 'authenticated');

-- ============================================
-- INSERT INITIAL DATA: Fundamentals Subject
-- ============================================

-- Insert Fundamentals of Nursing subject
INSERT INTO test_subjects (id, name, description, icon, display_order)
VALUES 
  ('10000000-0000-0000-0000-000000000001', 
   'Fundamentals of Nursing', 
   'Core nursing principles and essential skills', 
   '🏥', 
   1)
ON CONFLICT (name) DO NOTHING;

-- Insert topics for Fundamentals (29 topics - using your exact names)
INSERT INTO test_topics (id, subject_id, name, description, display_order) VALUES
  ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'Fundamentals', 'Core nursing fundamentals overview', 1),
  ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'Nurse''s Role in Informed Consent', 'Legal aspects and witnessing consent', 2),
  ('20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000001', 'Scope of Practice', 'RN scope, boundaries, legal limits', 3),
  ('20000000-0000-0000-0000-000000000004', '10000000-0000-0000-0000-000000000001', 'Delegation', 'Task delegation to UAP and LPN', 4),
  ('20000000-0000-0000-0000-000000000005', '10000000-0000-0000-0000-000000000001', 'Family Dynamics', 'Family assessment and support', 5),
  ('20000000-0000-0000-0000-000000000006', '10000000-0000-0000-0000-000000000001', 'Maslow''s Hierarchy of Needs', 'Prioritization using Maslow', 6),
  ('20000000-0000-0000-0000-000000000007', '10000000-0000-0000-0000-000000000001', 'SBAR Communication', 'Situation, Background, Assessment, Recommendation', 7),
  ('20000000-0000-0000-0000-000000000008', '10000000-0000-0000-0000-000000000001', 'Precautions', 'Standard, contact, droplet, airborne precautions', 8),
  ('20000000-0000-0000-0000-000000000009', '10000000-0000-0000-0000-000000000001', 'Vital Signs Interpretation', 'Temperature, pulse, respiration, BP, O2 sat', 9),
  ('20000000-0000-0000-0000-000000000010', '10000000-0000-0000-0000-000000000001', 'Physical Exam & Bowel Sounds', 'Auscultation techniques and findings', 10),
  ('20000000-0000-0000-0000-000000000011', '10000000-0000-0000-0000-000000000001', 'Physical Assessment', 'Inspection, palpation, percussion, auscultation', 11),
  ('20000000-0000-0000-0000-000000000012', '10000000-0000-0000-0000-000000000001', 'Head-to-Toe Assessment', 'Systematic patient assessment', 12),
  ('20000000-0000-0000-0000-000000000013', '10000000-0000-0000-0000-000000000001', 'Nursing Diagnosis', 'NANDA diagnoses and care planning', 13),
  ('20000000-0000-0000-0000-000000000014', '10000000-0000-0000-0000-000000000001', 'Documentation & Informatics', 'Accurate, objective, timely charting', 14),
  ('20000000-0000-0000-0000-000000000015', '10000000-0000-0000-0000-000000000001', 'Client Positioning', 'Fowlers, Sims, Trendelenburg, transfers', 15),
  ('20000000-0000-0000-0000-000000000016', '10000000-0000-0000-0000-000000000001', 'Care of a Client With a Tube', 'NG tubes, chest tubes, catheters', 16),
  ('20000000-0000-0000-0000-000000000017', '10000000-0000-0000-0000-000000000001', 'Administration of Blood Products', 'Transfusion protocols and reactions', 17),
  ('20000000-0000-0000-0000-000000000018', '10000000-0000-0000-0000-000000000001', 'Amputation', 'Pre/post-op care, phantom pain', 18),
  ('20000000-0000-0000-0000-000000000019', '10000000-0000-0000-0000-000000000001', 'Nursing Calculations', 'Dosage, drip rate, conversions', 19),
  ('20000000-0000-0000-0000-000000000020', '10000000-0000-0000-0000-000000000001', 'BMI Calculation', 'Body mass index formulas', 20),
  ('20000000-0000-0000-0000-000000000021', '10000000-0000-0000-0000-000000000001', 'Complementary and Alternative Medicine (CAM)', 'Holistic therapies and integrative care', 21),
  ('20000000-0000-0000-0000-000000000022', '10000000-0000-0000-0000-000000000001', 'Emergency Triage Tag Colors (MCI)', 'Mass casualty incident triage', 22),
  ('20000000-0000-0000-0000-000000000023', '10000000-0000-0000-0000-000000000001', 'Hygiene & Grooming', 'Bathing, oral care, skin integrity', 23),
  ('20000000-0000-0000-0000-000000000024', '10000000-0000-0000-0000-000000000001', 'Elimination & Intake and Output (I&O)', 'Urinary and bowel assessment/care', 24),
  ('20000000-0000-0000-0000-000000000025', '10000000-0000-0000-0000-000000000001', 'Nutrition & Feeding', 'Diet, feeding support, NPO', 25),
  ('20000000-0000-0000-0000-000000000026', '10000000-0000-0000-0000-000000000001', 'Oxygenation Basics', 'Airway, breathing, oxygen devices', 26),
  ('20000000-0000-0000-0000-000000000027', '10000000-0000-0000-0000-000000000001', 'Pain Assessment', 'Pain scales and interventions', 27),
  ('20000000-0000-0000-0000-000000000028', '10000000-0000-0000-0000-000000000001', 'Skin Integrity & Pressure Injuries', 'Wound care, pressure ulcer prevention', 28),
  ('20000000-0000-0000-0000-000000000029', '10000000-0000-0000-0000-000000000001', 'Sleep & Sensory Needs', 'Sleep hygiene and sensory disturbances', 29)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  display_order = EXCLUDED.display_order;

-- Create or update test config for Fundamentals
INSERT INTO test_configs (id, subject_id, title, description, duration_minutes, passing_score_percent, shuffle_questions, shuffle_options, allow_review, show_back_button, is_active)
VALUES 
  ('00000000-0000-0000-0000-000000000001',
   '10000000-0000-0000-0000-000000000001',
   'Fundamentals of Nursing – NCLEX Comprehensive Assessment',
   'Core nursing principles and essential skills for NCLEX preparation',
   60,
   75,
   true,
   true,
   true,
   true,
   true)
ON CONFLICT (id) DO UPDATE SET
  subject_id = EXCLUDED.subject_id,
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  duration_minutes = EXCLUDED.duration_minutes,
  passing_score_percent = EXCLUDED.passing_score_percent;

-- ============================================
-- VERIFICATION
-- ============================================

SELECT 'Subjects created:' as info, COUNT(*) as count FROM test_subjects;
SELECT 'Topics created:' as info, COUNT(*) as count FROM test_topics;
SELECT name, (SELECT COUNT(*) FROM test_topics WHERE subject_id = test_subjects.id) as topic_count 
FROM test_subjects;
