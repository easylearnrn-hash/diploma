-- =====================================================
-- FIX: Teacher Login — Diagnose & Repair Password Issues
-- =====================================================
-- Run this in Supabase SQL Editor to diagnose why new teachers
-- cannot log in despite having a password set.
-- plain_password column has already been dropped — all steps
-- below work without it.
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
    last_login,
    created_at
FROM teachers
ORDER BY created_at DESC;


-- =====================================================
-- STEP 2: Ensure RLS allows anon to read from teachers
-- (required for login query to work)
-- =====================================================
DO $$
BEGIN
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
-- STEP 3: Verify a specific teacher can be found
-- Replace ''n.abrahamyan@acnhs.am'' with the actual username/email
-- =====================================================
SELECT id, full_name, username, email, active,
       LEFT(password_hash, 30) AS hash_preview
FROM teachers
WHERE LOWER(username) = LOWER('n.abrahamyan@acnhs.am')
   OR LOWER(email)    = LOWER('n.abrahamyan@acnhs.am');


-- =====================================================
-- STEP 4: Fix a teacher whose password was stored as plain text
-- (Edge Function failed silently at creation time)
--
-- If STEP 1 shows "⚠️ Plain text stored" for a teacher,
-- their login will work via the direct fallback in teacher.html.
-- To upgrade to a proper hash, reset via Admin Hub → Teachers → Edit.
--
-- To manually force a known plain-text password right now:
-- =====================================================
-- UPDATE teachers
-- SET password_hash = 'their-plain-password-here'
-- WHERE LOWER(email) = LOWER('n.abrahamyan@acnhs.am');
--
-- After this, they can log in. Then reset via Admin Hub
-- to store a proper PBKDF2 hash.
-- =====================================================

