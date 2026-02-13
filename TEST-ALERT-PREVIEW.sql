-- ==========================================
-- TEST ALERT PREVIEW ISSUE
-- ==========================================
-- This checks if the alert data is properly formatted

-- 1. Check the Payment Reminder alert structure
SELECT 
  id,
  title,
  length(message_html) as msg_length,
  message_html IS NOT NULL as has_message,
  message_html != '' as msg_not_empty,
  is_active,
  severity,
  substring(message_html, 1, 100) as message_preview
FROM portal_alerts 
WHERE title = 'Payment Reminder';

-- 2. Check for any special characters that might break rendering
SELECT 
  id,
  title,
  position(E'\n' in message_html) > 0 as has_newlines,
  position(E'\r' in message_html) > 0 as has_carriage_returns,
  position(E'\t' in message_html) > 0 as has_tabs
FROM portal_alerts 
WHERE title = 'Payment Reminder';

-- 3. Set alert to show on every load for testing
UPDATE portal_alerts 
SET 
  frequency_rules = jsonb_set(frequency_rules, '{cap_type}', '"every_load"'),
  display_mode = 'every_load'
WHERE title = 'Payment Reminder'
RETURNING id, title, frequency_rules->>'cap_type' as cap_type, display_mode;

-- 4. Verify the update worked
SELECT 
  id,
  title,
  frequency_rules->>'cap_type' as frequency_cap,
  display_mode,
  is_active,
  targeting_rules->>'mode' as targeting_mode
FROM portal_alerts 
WHERE title = 'Payment Reminder';
