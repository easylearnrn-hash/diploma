-- ==========================================
-- UPGRADE ALERTS TO FLEXIBLE RULE ENGINE
-- Copy and paste this ENTIRE file into Supabase SQL Editor
-- ==========================================

-- STEP 1: Add new JSON-based rule columns
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS targeting_rules JSONB DEFAULT '{
  "mode": "all",
  "include_students": [],
  "exclude_students": [],
  "groups": [],
  "statuses": [],
  "tags": [],
  "logic": "AND"
}'::jsonb;

ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS frequency_rules JSONB DEFAULT '{
  "cap_type": "once_ever",
  "max_displays": null,
  "cooldown_hours": null,
  "per_period": null,
  "stop_after_response": false,
  "stop_after_days": null
}'::jsonb;

ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS schedule_rules JSONB DEFAULT '{
  "recurrence_type": "always",
  "start_datetime": null,
  "end_datetime": null,
  "timezone": "Asia/Yerevan",
  "daily_pattern": null,
  "weekly_pattern": null,
  "monthly_pattern": null,
  "custom_dates": [],
  "exclude_dates": []
}'::jsonb;

ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS trigger_rules JSONB DEFAULT '{
  "when": ["on_login"],
  "pages_whitelist": [],
  "pages_blacklist": [],
  "time_window": null
}'::jsonb;

ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS interaction_rules JSONB DEFAULT '{
  "dismissible": true,
  "required_response": false,
  "remind_on_no": false,
  "auto_dismiss_seconds": null
}'::jsonb;

-- STEP 2: Migrate existing data from old columns to new JSON structure
UPDATE public.portal_alerts
SET 
  targeting_rules = jsonb_build_object(
    'mode', COALESCE(target_type, 'all'),
    'include_students', COALESCE(target_student_ids::jsonb, '[]'::jsonb),
    'exclude_students', '[]'::jsonb,
    'groups', CASE WHEN target_group IS NOT NULL THEN to_jsonb(ARRAY[target_group]) ELSE '[]'::jsonb END,
    'statuses', '[]'::jsonb,
    'tags', '[]'::jsonb,
    'logic', 'AND'
  ),
  frequency_rules = jsonb_build_object(
    'cap_type', COALESCE(display_mode, 'once_ever'),
    'max_displays', NULL,
    'cooldown_hours', NULL,
    'per_period', NULL,
    'stop_after_response', false,
    'stop_after_days', NULL
  ),
  schedule_rules = jsonb_build_object(
    'recurrence_type', COALESCE(date_rule_type, 'always'),
    'start_datetime', start_date,
    'end_datetime', end_date,
    'timezone', 'Asia/Yerevan',
    'daily_pattern', NULL,
    'weekly_pattern', NULL,
    'monthly_pattern', NULL,
    'custom_dates', '[]'::jsonb,
    'exclude_dates', '[]'::jsonb
  ),
  trigger_rules = jsonb_build_object(
    'when', to_jsonb(ARRAY['on_login']::text[]),
    'pages_whitelist', '[]'::jsonb,
    'pages_blacklist', '[]'::jsonb,
    'time_window', NULL
  ),
  interaction_rules = jsonb_build_object(
    'dismissible', true,
    'required_response', false,
    'remind_on_no', false,
    'auto_dismiss_seconds', NULL
  )
WHERE targeting_rules IS NULL OR frequency_rules IS NULL OR schedule_rules IS NULL;

-- STEP 3: Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_alerts_targeting_mode 
ON public.portal_alerts USING gin ((targeting_rules->'mode'));

CREATE INDEX IF NOT EXISTS idx_alerts_schedule_type 
ON public.portal_alerts USING gin ((schedule_rules->'recurrence_type'));

CREATE INDEX IF NOT EXISTS idx_alerts_active_dates 
ON public.portal_alerts (
  (schedule_rules->>'start_datetime'), 
  (schedule_rules->>'end_datetime')
);

-- STEP 4: Create helper view for easy querying (drop first if exists)
DROP VIEW IF EXISTS public.portal_alerts_summary CASCADE;
CREATE VIEW public.portal_alerts_summary AS
SELECT 
  id,
  title,
  severity,
  is_active,
  targeting_rules->>'mode' as targeting_mode,
  (targeting_rules->'include_students')::text as included_students_count,
  frequency_rules->>'cap_type' as frequency_cap,
  schedule_rules->>'recurrence_type' as recurrence_type,
  schedule_rules->>'start_datetime' as starts_at,
  schedule_rules->>'end_datetime' as ends_at,
  trigger_rules->'when' as trigger_events,
  interaction_rules->>'required_response' as requires_response,
  created_at,
  created_by
FROM public.portal_alerts
ORDER BY created_at DESC;

-- STEP 5: Add validation function
CREATE OR REPLACE FUNCTION public.validate_alert_rules()
RETURNS TRIGGER AS $$
BEGIN
  -- Validate targeting_rules has required keys
  IF NOT (NEW.targeting_rules ? 'mode') THEN
    RAISE EXCEPTION 'targeting_rules must contain "mode" key';
  END IF;
  
  -- Validate frequency_rules has required keys
  IF NOT (NEW.frequency_rules ? 'cap_type') THEN
    RAISE EXCEPTION 'frequency_rules must contain "cap_type" key';
  END IF;
  
  -- Validate schedule_rules has required keys
  IF NOT (NEW.schedule_rules ? 'recurrence_type') THEN
    RAISE EXCEPTION 'schedule_rules must contain "recurrence_type" key';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- STEP 6: Create trigger (drop first if exists)
DROP TRIGGER IF EXISTS validate_alert_rules_trigger ON public.portal_alerts;
CREATE TRIGGER validate_alert_rules_trigger
  BEFORE INSERT OR UPDATE ON public.portal_alerts
  FOR EACH ROW
  EXECUTE FUNCTION public.validate_alert_rules();

-- STEP 7: Add comments for documentation
COMMENT ON COLUMN public.portal_alerts.targeting_rules IS 
'JSON object controlling who sees the alert. 
Structure: {
  "mode": "all" | "include" | "exclude" | "complex",
  "include_students": ["student_id1", ...],
  "exclude_students": ["student_id1", ...],
  "groups": ["group_a", "enrolled", ...],
  "statuses": ["active", "paused", ...],
  "tags": ["at_risk", "honors", ...],
  "logic": "AND" | "OR"
}';

COMMENT ON COLUMN public.portal_alerts.frequency_rules IS 
'JSON object controlling how often alert shows.
Structure: {
  "cap_type": "once_ever" | "times_limit" | "daily" | "weekly" | "cooldown" | "until_response",
  "max_displays": number | null,
  "cooldown_hours": number | null,
  "per_period": "day" | "week" | null,
  "stop_after_response": boolean,
  "stop_after_days": number | null
}';

COMMENT ON COLUMN public.portal_alerts.schedule_rules IS 
'JSON object controlling when alert is active.
Structure: {
  "recurrence_type": "always" | "one_time" | "daily" | "weekly" | "monthly" | "custom_dates",
  "start_datetime": ISO timestamp | null,
  "end_datetime": ISO timestamp | null,
  "timezone": "Asia/Yerevan",
  "daily_pattern": {"every_n_days": number} | null,
  "weekly_pattern": {"days": [...], "start_time": "HH:MM", "end_time": "HH:MM"} | null,
  "monthly_pattern": {"day_range": [start, end]} | {"nth_weekday": {"week": 1-4|-1, "day": "monday"}} | null,
  "custom_dates": ["YYYY-MM-DD", ...],
  "exclude_dates": ["YYYY-MM-DD", ...]
}';

COMMENT ON COLUMN public.portal_alerts.trigger_rules IS 
'JSON object controlling what triggers alert display.
Structure: {
  "when": ["on_login", "on_page_load", "on_refresh", "every_page"],
  "pages_whitelist": ["/page1.html", ...],
  "pages_blacklist": ["/page2.html", ...],
  "time_window": {"start": "HH:MM", "end": "HH:MM"} | null
}';

COMMENT ON COLUMN public.portal_alerts.interaction_rules IS 
'JSON object controlling alert interaction behavior.
Structure: {
  "dismissible": boolean,
  "required_response": boolean,
  "remind_on_no": boolean,
  "auto_dismiss_seconds": number | null
}';

-- Success message
DO $$ 
BEGIN 
  RAISE NOTICE '✅ Alert Rule Engine Upgrade Complete!';
  RAISE NOTICE '📊 Total alerts with new rules: %', (SELECT COUNT(*) FROM portal_alerts WHERE targeting_rules IS NOT NULL);
END $$;
