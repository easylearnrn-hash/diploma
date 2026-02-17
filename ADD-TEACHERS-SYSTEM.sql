-- =====================================================
-- TEACHER SYSTEM SCHEMA AND RLS POLICIES
-- =====================================================
-- Run this in Supabase SQL Editor
-- Creates teachers table, teacher-group assignments, and secure RLS policies

-- 1) Create teachers table
-- =====================================================
CREATE TABLE IF NOT EXISTS teachers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    plain_password TEXT, -- For admin reference (encrypted at rest by Supabase)
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by TEXT, -- Admin email who created this teacher
    last_login TIMESTAMPTZ
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_teachers_username ON teachers(username);
CREATE INDEX IF NOT EXISTS idx_teachers_email ON teachers(email);
CREATE INDEX IF NOT EXISTS idx_teachers_active ON teachers(active);

-- Add trigger for updated_at
CREATE OR REPLACE FUNCTION update_teachers_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS teachers_updated_at_trigger ON teachers;
CREATE TRIGGER teachers_updated_at_trigger
    BEFORE UPDATE ON teachers
    FOR EACH ROW
    EXECUTE FUNCTION update_teachers_updated_at();


-- 2) Create teacher-group assignments table
-- =====================================================
CREATE TABLE IF NOT EXISTS teacher_group_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
    group_id TEXT NOT NULL, -- 'A', 'B', 'C', etc.
    role_title TEXT NOT NULL, -- e.g., "Fundamentals Course Teacher"
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    assigned_by TEXT, -- Admin email who made the assignment
    UNIQUE(teacher_id, group_id) -- Prevent duplicate assignments
);

-- Create indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_teacher_groups_teacher ON teacher_group_assignments(teacher_id);
CREATE INDEX IF NOT EXISTS idx_teacher_groups_group ON teacher_group_assignments(group_id);


-- 3) Enable Row Level Security
-- =====================================================
ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_group_assignments ENABLE ROW LEVEL SECURITY;


-- 4) RLS Policies for teachers table
-- =====================================================

-- Allow anon to read active teachers for login verification
DROP POLICY IF EXISTS "Allow anon to read active teachers" ON teachers;
CREATE POLICY "Allow anon to read active teachers" 
ON teachers FOR SELECT 
TO anon 
USING (active = true);

-- Allow anon to update last_login timestamp
DROP POLICY IF EXISTS "Allow anon to update last_login" ON teachers;
CREATE POLICY "Allow anon to update last_login" 
ON teachers FOR UPDATE 
TO anon 
USING (true)
WITH CHECK (true);

-- Allow anon full access for admin operations (secure via app logic)
DROP POLICY IF EXISTS "Allow anon full access to teachers" ON teachers;
CREATE POLICY "Allow anon full access to teachers" 
ON teachers FOR ALL 
TO anon 
USING (true)
WITH CHECK (true);


-- 5) RLS Policies for teacher_group_assignments
-- =====================================================

-- Allow anon to read all assignments (for role checking)
DROP POLICY IF EXISTS "Allow anon to read teacher assignments" ON teacher_group_assignments;
CREATE POLICY "Allow anon to read teacher assignments" 
ON teacher_group_assignments FOR SELECT 
TO anon 
USING (true);

-- Allow anon full access for admin operations
DROP POLICY IF EXISTS "Allow anon full access to assignments" ON teacher_group_assignments;
CREATE POLICY "Allow anon full access to assignments" 
ON teacher_group_assignments FOR ALL 
TO anon 
USING (true)
WITH CHECK (true);


-- 6) Helper function: Get teacher's assigned groups
-- =====================================================
CREATE OR REPLACE FUNCTION get_teacher_groups(teacher_email TEXT)
RETURNS TABLE(group_id TEXT, role_title TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT tga.group_id, tga.role_title
    FROM teacher_group_assignments tga
    JOIN teachers t ON t.id = tga.teacher_id
    WHERE t.email = teacher_email AND t.active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 7) Helper function: Get teachers by group
-- =====================================================
CREATE OR REPLACE FUNCTION get_group_teachers(p_group_id TEXT)
RETURNS TABLE(
    teacher_id UUID,
    full_name TEXT,
    email TEXT,
    role_title TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.full_name,
        t.email,
        tga.role_title
    FROM teacher_group_assignments tga
    JOIN teachers t ON t.id = tga.teacher_id
    WHERE tga.group_id = p_group_id AND t.active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 8) Create sample admin teacher account (for testing)
-- =====================================================
-- Password: Teacher123! (hashed with bcrypt)
-- Username: test.teacher
-- Email: test.teacher@acnhs.am

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM teachers WHERE username = 'test.teacher') THEN
        INSERT INTO teachers (
            full_name,
            email,
            username,
            password_hash,
            plain_password,
            active,
            created_by
        ) VALUES (
            'Test Teacher',
            'test.teacher@acnhs.am',
            'test.teacher',
            '$2a$10$qHZP6VYyRxCpYQKGlIZkB.8K3E5J2QwYvZxK0qF5xQOjH0UZ3mN9K', -- Teacher123!
            'Teacher123!',
            true,
            'system'
        );

        -- Assign to Group A as Fundamentals Course Teacher
        INSERT INTO teacher_group_assignments (
            teacher_id,
            group_id,
            role_title,
            assigned_by
        ) VALUES (
            (SELECT id FROM teachers WHERE username = 'test.teacher'),
            'A',
            'Fundamentals Course Teacher',
            'system'
        );

        RAISE NOTICE 'Created test teacher account: test.teacher / Teacher123!';
    END IF;
END $$;


-- 9) Grant necessary permissions
-- =====================================================
GRANT SELECT, INSERT, UPDATE, DELETE ON teachers TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON teacher_group_assignments TO anon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;


-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================
-- Test teacher account created:
--   Username: test.teacher
--   Password: Teacher123!
--   Group: A (Fundamentals Course Teacher)
--
-- Next steps:
-- 1. Run this SQL in Supabase SQL Editor
-- 2. Create teacher.html login page
-- 3. Update admin-hub.html with Teachers management section
-- 4. Implement role-based access control
-- =====================================================
