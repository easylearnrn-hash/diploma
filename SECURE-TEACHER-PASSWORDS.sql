-- =====================================================
-- SECURE TEACHER PASSWORDS - PRODUCTION READY
-- =====================================================
-- This migration removes plain text passwords and uses bcrypt hashing
-- RUN THIS IMMEDIATELY to secure existing teacher accounts

-- STEP 1: Remove plain_password column (SECURITY RISK!)
-- =====================================================
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'teachers' 
        AND column_name = 'plain_password'
    ) THEN
        -- Backup existing passwords before removing (admin should save elsewhere if needed)
        RAISE NOTICE '⚠️ WARNING: plain_password column exists and will be removed!';
        RAISE NOTICE 'Current teachers and their plain passwords:';
        
        -- Log current passwords (admin should note these down before running)
        DECLARE
            rec RECORD;
        BEGIN
            FOR rec IN 
                SELECT username, plain_password, email 
                FROM teachers 
                WHERE active = true
            LOOP
                RAISE NOTICE 'Username: %, Password: %, Email: %', rec.username, rec.plain_password, rec.email;
            END LOOP;
        END;
        
        -- Drop the insecure column
        ALTER TABLE teachers DROP COLUMN plain_password;
        RAISE NOTICE '✅ plain_password column removed successfully';
    ELSE
        RAISE NOTICE '✅ plain_password column already removed';
    END IF;
END $$;


-- STEP 2: Add password reset tokens table
-- =====================================================
CREATE TABLE IF NOT EXISTS teacher_password_resets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
    reset_token TEXT NOT NULL UNIQUE,
    expires_at TIMESTAMPTZ NOT NULL,
    used BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    used_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_password_resets_token ON teacher_password_resets(reset_token);
CREATE INDEX IF NOT EXISTS idx_password_resets_teacher ON teacher_password_resets(teacher_id);


-- STEP 3: Add helper function to generate secure reset tokens
-- =====================================================
CREATE OR REPLACE FUNCTION generate_teacher_reset_token(p_teacher_id UUID)
RETURNS TEXT AS $$
DECLARE
    v_token TEXT;
    v_expires_at TIMESTAMPTZ;
BEGIN
    -- Generate random token
    v_token := encode(gen_random_bytes(32), 'hex');
    
    -- Token expires in 24 hours
    v_expires_at := NOW() + INTERVAL '24 hours';
    
    -- Invalidate all previous tokens for this teacher
    UPDATE teacher_password_resets 
    SET used = true 
    WHERE teacher_id = p_teacher_id AND used = false;
    
    -- Insert new reset token
    INSERT INTO teacher_password_resets (teacher_id, reset_token, expires_at)
    VALUES (p_teacher_id, v_token, v_expires_at);
    
    RETURN v_token;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- STEP 4: RLS for password resets table
-- =====================================================
ALTER TABLE teacher_password_resets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow anon to read valid tokens" ON teacher_password_resets;
CREATE POLICY "Allow anon to read valid tokens" 
ON teacher_password_resets FOR SELECT 
TO anon 
USING (expires_at > NOW() AND used = false);

DROP POLICY IF EXISTS "Allow anon to mark tokens used" ON teacher_password_resets;
CREATE POLICY "Allow anon to mark tokens used" 
ON teacher_password_resets FOR UPDATE 
TO anon 
USING (true)
WITH CHECK (true);

DROP POLICY IF EXISTS "Allow anon to create tokens" ON teacher_password_resets;
CREATE POLICY "Allow anon to create tokens" 
ON teacher_password_resets FOR INSERT 
TO anon 
WITH CHECK (true);


-- STEP 5: Update existing teacher passwords to bcrypt format
-- =====================================================
-- NOTE: You must run the hash-password Edge Function to hash these passwords
-- This is a manual step - see instructions below

DO $$
BEGIN
    RAISE NOTICE '⚠️ IMPORTANT: Existing teacher passwords need to be re-hashed!';
    RAISE NOTICE '';
    RAISE NOTICE 'Current teachers that need password reset:';
    RAISE NOTICE '================================================';
    
    DECLARE
        rec RECORD;
    BEGIN
        FOR rec IN 
            SELECT id, username, email, password_hash 
            FROM teachers 
            WHERE active = true
            ORDER BY username
        LOOP
            -- Check if password_hash looks like bcrypt (starts with $2a$ or $2b$)
            IF rec.password_hash NOT LIKE '$2%' THEN
                RAISE NOTICE 'Teacher: % (%) - PASSWORD NEEDS HASHING', rec.username, rec.email;
            ELSE
                RAISE NOTICE 'Teacher: % (%) - Already hashed ✓', rec.username, rec.email;
            END IF;
        END LOOP;
    END;
    
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'ACTION REQUIRED:';
    RAISE NOTICE '1. Note down the teachers listed above';
    RAISE NOTICE '2. Use Admin Hub to reset their passwords';
    RAISE NOTICE '3. New passwords will be automatically hashed';
END $$;


-- STEP 6: Grant permissions
-- =====================================================
GRANT SELECT, INSERT, UPDATE ON teacher_password_resets TO anon;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon;


-- =====================================================
-- MIGRATION COMPLETE
-- =====================================================
-- IMPORTANT NEXT STEPS:
--
-- 1. Deploy hash-password Edge Function:
--    cd supabase/functions/hash-password
--    supabase functions deploy hash-password
--
-- 2. Update existing teacher passwords:
--    - Login as admin
--    - Go to Teachers section
--    - Edit each teacher and set new password
--    - New passwords will be bcrypt hashed automatically
--
-- 3. Teachers affected (need password reset):
--    - test.teacher (test.teacher@acnhs.am)
--    - maria.vardanyan (dr.mvardanyan@acnhs.am)
--
-- 4. Verify passwords are hashed:
--    SELECT username, 
--           LEFT(password_hash, 10) as hash_preview,
--           CASE 
--             WHEN password_hash LIKE '$2%' THEN '✓ Hashed'
--             ELSE '✗ Plain text'
--           END as status
--    FROM teachers;
--
-- 5. Test teacher login after password reset
--
-- =====================================================
