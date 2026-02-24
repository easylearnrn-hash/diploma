-- =====================================================
-- FIX: Teacher Login — Diagnose & Repair Password Issues
-- =====================================================
-- Run this in Supabase SQL Editor to diagnose why new teachers
-- cannot log in despite having a password set.
-- =====================================================

-- STEP 1: Diagnose — see what each teacher's password_hash looks like
-- =====================================================
SELECT
    id,
    full_name,
    username,
    email,
    active,
    LEFT(password_hash, 20) AS hash_preview,
    CASE
        WHEN password_hash IS NULL OR password_hash = '' THEN '❌ EMPTY — no password set'
        WHEN password_hash LIKE 'pbkdf2:%'              THEN '✅ PBKDF2 hash (Edge Function worked)'
        WHEN password_hash LIKE '$2%'                   THEN '✅ bcrypt hash'
        ELSE                                                 '⚠️ Plain text stored (Edge Function failed at creation)'
    END AS password_status,
    plain_password,
    last_login,
    created_at
FROM teachers
ORDER BY created_at DESC;


-- =====================================================
-- STEP 2: For teachers with plain-text password_hash,
-- make plain_password match it so the login fallback works.
-- (Only needed if plain_password column still exists)
-- =====================================================
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'teachers' AND column_name = 'plain_password'
    ) THEN
        -- Copy plain-text password_hash into plain_password where plain_password is empty
        -- but password_hash looks like a plain password (not a hash)
        UPDATE teachers
        SET plain_password = password_hash
        WHERE active = true
          AND (plain_password IS NULL OR plain_password = '')
          AND password_hash IS NOT NULL
          AND password_hash NOT LIKE 'pbkdf2:%'
          AND password_hash NOT LIKE '$2%';

        RAISE NOTICE '✅ Synced plain_password for teachers with plain-text password_hash';
    ELSE
        RAISE NOTICE 'ℹ️ plain_password column does not exist — skipping sync';
    END IF;
END $$;


-- =====================================================
-- STEP 3: Ensure RLS allows anon to read from teachers
-- (required for login query to work)
-- =====================================================
DO $$
BEGIN
    -- Check if the SELECT policy exists
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'teachers'
          AND cmd = 'SELECT'
    ) THEN
        EXECUTE 'CREATE POLICY "Allow anon to read active teachers" ON teachers
                 FOR SELECT TO anon
                 USING (active = true)';
        RAISE NOTICE '✅ Created SELECT policy on teachers for anon';
    ELSE
        RAISE NOTICE 'ℹ️ SELECT policy on teachers already exists';
    END IF;
END $$;


-- =====================================================
-- STEP 4: Verify a specific teacher can be found
-- Replace ''n.abrahamyan@acnhs.am'' with the actual username/email
-- =====================================================
SELECT id, full_name, username, email, active,
       LEFT(password_hash, 30) AS hash_preview,
       plain_password
FROM teachers
WHERE LOWER(username) = LOWER('n.abrahamyan@acnhs.am')
   OR LOWER(email)    = LOWER('n.abrahamyan@acnhs.am');


-- =====================================================
-- HOW TO MANUALLY FIX A SPECIFIC TEACHER'S PASSWORD
-- (if Edge Function is not working reliably)
-- =====================================================
-- Replace the values below and run:
--
-- UPDATE teachers
-- SET password_hash  = 'their-plain-password-here',
--     plain_password = 'their-plain-password-here'
-- WHERE LOWER(email) = LOWER('n.abrahamyan@acnhs.am');
--
-- Once the Edge Function is confirmed working, reset the
-- password via Admin Hub to store a proper PBKDF2 hash.
-- =====================================================
