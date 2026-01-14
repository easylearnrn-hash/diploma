-- Find what's deleting emails from email_history

-- 1. Check DELETE policies (who can delete?)
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd as operation,
    qual as using_clause
FROM pg_policies 
WHERE tablename = 'email_history' 
  AND cmd = 'DELETE';

-- 2. Check ALL policies on email_history
SELECT 
    policyname,
    cmd as operation,
    roles,
    CASE 
        WHEN cmd = 'DELETE' THEN '🚨 DELETE - Can remove emails!'
        WHEN cmd = 'UPDATE' THEN '⚠️ UPDATE - Can modify emails'
        WHEN cmd = 'INSERT' THEN '✅ INSERT - Can add emails'
        WHEN cmd = 'SELECT' THEN '✅ SELECT - Can read emails'
        ELSE cmd
    END as risk_level,
    qual as using_clause,
    with_check as with_check_clause
FROM pg_policies 
WHERE tablename = 'email_history'
ORDER BY 
    CASE cmd 
        WHEN 'DELETE' THEN 1 
        WHEN 'UPDATE' THEN 2 
        WHEN 'INSERT' THEN 3 
        WHEN 'SELECT' THEN 4 
    END;

-- 3. Check if there's a trigger that deletes old emails
SELECT 
    trigger_name,
    event_manipulation as trigger_event,
    event_object_table as table_name,
    action_statement as trigger_action,
    action_timing as when_fires
FROM information_schema.triggers
WHERE event_object_table = 'email_history';

-- 4. CRITICAL: Disable DELETE policy if it exists
-- Run this if DELETE policy is found:
-- DROP POLICY "Allow public to delete email history" ON email_history;

-- 5. Show what happened in the last operations
SELECT 
    'Last DELETE happened between insert #1 and now' as analysis,
    'Check who has access to admin panel' as recommendation;
