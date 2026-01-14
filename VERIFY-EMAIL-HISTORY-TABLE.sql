-- Verify and Fix Email History Table
-- Run this in Supabase SQL Editor to ensure all columns exist

-- ========================================
-- STEP 1: Check current table structure
-- ========================================
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'email_history' 
ORDER BY ordinal_position;

-- ========================================
-- STEP 2: Add missing columns if needed
-- ========================================

-- Add sender column (if not exists)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'email_history' 
        AND column_name = 'sender'
    ) THEN
        ALTER TABLE email_history ADD COLUMN sender TEXT;
        RAISE NOTICE 'Added sender column';
    ELSE
        RAISE NOTICE 'sender column already exists';
    END IF;
END $$;

-- Add html_body column (if not exists)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'email_history' 
        AND column_name = 'html_body'
    ) THEN
        ALTER TABLE email_history ADD COLUMN html_body TEXT;
        RAISE NOTICE 'Added html_body column';
    ELSE
        RAISE NOTICE 'html_body column already exists';
    END IF;
END $$;

-- ========================================
-- STEP 3: Create indexes for performance
-- ========================================
CREATE INDEX IF NOT EXISTS idx_email_history_sender ON email_history(sender);
CREATE INDEX IF NOT EXISTS idx_email_history_recipient ON email_history(recipient);
CREATE INDEX IF NOT EXISTS idx_email_history_status ON email_history(status);
CREATE INDEX IF NOT EXISTS idx_email_history_sent_at ON email_history(sent_at DESC);

-- ========================================
-- STEP 4: Verify RLS policies
-- ========================================
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'email_history';

-- ========================================
-- STEP 5: Check recent email records
-- ========================================
SELECT 
    id,
    sender,
    recipient,
    subject,
    status,
    sent_at,
    resend_id,
    CASE 
        WHEN html_body IS NOT NULL THEN 'Has HTML'
        WHEN body IS NOT NULL THEN 'Has Text'
        ELSE 'Empty'
    END as body_status,
    LENGTH(COALESCE(html_body, body, '')) as body_length
FROM email_history 
ORDER BY sent_at DESC 
LIMIT 10;

-- ========================================
-- STEP 6: Test insert (will rollback)
-- ========================================
DO $$ 
DECLARE
    test_id UUID;
BEGIN
    -- Try to insert a test record
    INSERT INTO email_history (
        recipient,
        sender,
        subject,
        body,
        html_body,
        status,
        sent_at
    ) VALUES (
        'test@example.com',
        'admissions@acnhs.am',
        'Test Email',
        'Test body',
        '<p>Test HTML body</p>',
        'sent',
        NOW()
    ) RETURNING id INTO test_id;
    
    RAISE NOTICE 'Test insert successful! ID: %', test_id;
    
    -- Delete test record
    DELETE FROM email_history WHERE id = test_id;
    RAISE NOTICE 'Test record cleaned up';
    
EXCEPTION WHEN OTHERS THEN
    RAISE WARNING 'Test insert failed: %', SQLERRM;
END $$;

-- ========================================
-- FINAL SUMMARY
-- ========================================
SELECT 
    'email_history' as table_name,
    COUNT(*) as total_records,
    COUNT(DISTINCT sender) as unique_senders,
    COUNT(DISTINCT recipient) as unique_recipients,
    MAX(sent_at) as last_email_sent,
    COUNT(*) FILTER (WHERE status = 'sent') as sent_count,
    COUNT(*) FILTER (WHERE status = 'failed') as failed_count
FROM email_history;

-- List all columns for verification
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'email_history' 
ORDER BY ordinal_position;
