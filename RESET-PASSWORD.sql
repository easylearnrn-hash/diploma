-- ========================================
-- RESET VLADISLAV'S PASSWORD
-- ========================================
-- This will set a new temporary password for him
-- ========================================

-- First, let's use the reference number as the password (simple and recoverable)
-- You'll need to hash it the same way your app does

-- IMPORTANT: You need to hash the password the same way as admission-form.html
-- The password hash is created using: await hashPassword(password)

-- ========================================
-- TEMPORARY WORKAROUND:
-- Set password to the reference number
-- ========================================

-- Since we can't hash it in SQL the same way as JavaScript (bcrypt),
-- you have two options:

-- OPTION 1: Use the reference number as the new password
-- You'll need to generate the hash in JavaScript and update manually

-- OPTION 2: Contact Vladislav and ask him to re-submit
-- OR provide him with credentials via email/phone

-- ========================================
-- TO GET THE CURRENT HASH:
-- ========================================

SELECT 
    reference_number,
    username,
    password_hash,
    payload->>'email' as email
FROM applications
WHERE reference_number = 'ACNHS-ADM-20260107-799';

-- ========================================
-- RECOMMENDED ACTION:
-- ========================================
-- 1. Create a "Forgot Password" feature in Student-page.html
-- 2. OR email Vladislav his credentials
-- 3. OR provide a password reset link from admin dashboard
-- ========================================
