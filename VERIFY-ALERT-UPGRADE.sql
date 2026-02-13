-- ==========================================
-- VERIFY ALERT RULE ENGINE UPGRADE
-- Run this to check that everything worked
-- ==========================================

-- Check that new columns exist and have data
SELECT 
  id,
  title,
  severity,
  targeting_rules->>'mode' as targeting_mode,
  jsonb_array_length(targeting_rules->'include_students') as included_count,
  frequency_rules->>'cap_type' as frequency_cap,
  schedule_rules->>'recurrence_type' as recurrence_type,
  schedule_rules->>'start_datetime' as starts_at,
  schedule_rules->>'end_datetime' as ends_at,
  trigger_rules->'when' as trigger_events,
  interaction_rules->>'dismissible' as dismissible,
  is_active
FROM public.portal_alerts
ORDER BY created_at DESC
LIMIT 10;

-- Check helper view works
SELECT * FROM public.portal_alerts_summary LIMIT 5;

-- Count alerts with new rule structure
SELECT 
  COUNT(*) as total_alerts,
  COUNT(*) FILTER (WHERE targeting_rules IS NOT NULL) as with_targeting_rules,
  COUNT(*) FILTER (WHERE frequency_rules IS NOT NULL) as with_frequency_rules,
  COUNT(*) FILTER (WHERE schedule_rules IS NOT NULL) as with_schedule_rules,
  COUNT(*) FILTER (WHERE trigger_rules IS NOT NULL) as with_trigger_rules,
  COUNT(*) FILTER (WHERE interaction_rules IS NOT NULL) as with_interaction_rules
FROM public.portal_alerts;

-- Show sample JSON structure
SELECT 
  id,
  title,
  targeting_rules,
  frequency_rules,
  schedule_rules,
  trigger_rules,
  interaction_rules
FROM public.portal_alerts
LIMIT 1;
