-- ==========================================
-- UPGRADE ALERTS TO FLEXIBLE RULE ENGINE
-- ==========================================
-- Transform simple alerts into a professional targeting/scheduling system
-- Date: 2026-02-13

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

-- STEP 2: Add comments explaining the JSON structure
COMMENT ON COLUMN public.portal_alerts.targeting_rules IS 
'Targeting configuration:
{
  "mode": "all" | "include" | "exclude" | "complex",
  "include_students": ["student_id_1", "student_id_2"],
  "exclude_students": ["student_id_3"],
  "groups": ["group_a", "enrolled"],
  "statuses": ["active", "enrolled"],
  "tags": ["payment_overdue", "new_student"],
  "logic": "AND" | "OR"
}';

COMMENT ON COLUMN public.portal_alerts.frequency_rules IS
'Frequency & display caps:
{
  "cap_type": "once_ever" | "times_limit" | "daily" | "weekly" | "monthly" | "cooldown" | "until_response",
  "max_displays": 3,
  "cooldown_hours": 24,
  "per_period": "day" | "week" | "month",
  "stop_after_response": true,
  "stop_after_days": 30
}';

COMMENT ON COLUMN public.portal_alerts.schedule_rules IS
'Scheduling & recurrence:
{
  "recurrence_type": "always" | "one_time" | "daily" | "weekly" | "monthly" | "custom_dates",
  "start_datetime": "2026-02-13T08:00:00",
  "end_datetime": "2026-12-31T23:59:59",
  "timezone": "Asia/Yerevan",
  "daily_pattern": {"every_n_days": 1},
  "weekly_pattern": {"days": ["monday", "wednesday", "friday"], "start_time": "08:00", "end_time": "17:00"},
  "monthly_pattern": {"day_range": [1, 5], "nth_weekday": {"week": 1, "day": "monday"}},
  "custom_dates": ["2026-03-01", "2026-03-15"],
  "exclude_dates": ["2026-03-08"]
}';

COMMENT ON COLUMN public.portal_alerts.trigger_rules IS
'When/where to show:
{
  "when": ["on_login", "on_page_load", "on_refresh", "every_page"],
  "pages_whitelist": ["/student-portal.html", "/grades.html"],
  "pages_blacklist": ["/login.html"],
  "time_window": {"start": "08:00", "end": "22:00"}
}';

COMMENT ON COLUMN public.portal_alerts.interaction_rules IS
'User interaction behavior:
{
  "dismissible": true,
  "required_response": false,
  "remind_on_no": false,
  "auto_dismiss_seconds": 10
}';

-- STEP 3: Migrate existing alerts to new structure
UPDATE public.portal_alerts
SET 
  targeting_rules = jsonb_build_object(
    'mode', 
    CASE 
      WHEN target_type = 'all' THEN 'all'
      WHEN target_type = 'group' THEN 'complex'
      WHEN target_type = 'individual' THEN 'include'
      ELSE 'all'
    END,
    'include_students', COALESCE(target_student_ids, '[]'::jsonb),
    'exclude_students', '[]'::jsonb,
    'groups', 
    CASE 
      WHEN target_group IS NOT NULL THEN jsonb_build_array(target_group)
      ELSE '[]'::jsonb
    END,
    'statuses', '[]'::jsonb,
    'tags', '[]'::jsonb,
    'logic', 'AND'
  ),
  frequency_rules = jsonb_build_object(
    'cap_type', display_mode,
    'max_displays', max_displays,
    'cooldown_hours', 
    CASE 
      WHEN display_mode = 'daily' THEN 24
      ELSE NULL
    END,
    'per_period', 
    CASE 
      WHEN display_mode = 'daily' THEN 'day'
      ELSE NULL
    END,
    'stop_after_response', requires_response,
    'stop_after_days', NULL
  ),
  schedule_rules = jsonb_build_object(
    'recurrence_type', date_rule_type,
    'start_datetime', start_date,
    'end_datetime', end_date,
    'timezone', timezone,
    'daily_pattern', NULL,
    'weekly_pattern', NULL,
    'monthly_pattern', 
    CASE 
      WHEN date_rule_type = 'monthly_range' THEN 
        jsonb_build_object('day_range', jsonb_build_array(monthly_start_day, monthly_end_day))
      ELSE NULL
    END,
    'custom_dates', COALESCE(custom_dates, '[]'::jsonb),
    'exclude_dates', '[]'::jsonb
  ),
  trigger_rules = jsonb_build_object(
    'when', jsonb_build_array('on_login'),
    'pages_whitelist', '[]'::jsonb,
    'pages_blacklist', '[]'::jsonb,
    'time_window', NULL
  ),
  interaction_rules = jsonb_build_object(
    'dismissible', NOT requires_response,
    'required_response', requires_response,
    'remind_on_no', false,
    'auto_dismiss_seconds', NULL
  )
WHERE targeting_rules IS NULL OR targeting_rules::text = 'null';

-- STEP 4: Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_alerts_targeting_mode ON public.portal_alerts USING gin ((targeting_rules->'mode'));
CREATE INDEX IF NOT EXISTS idx_alerts_schedule_type ON public.portal_alerts USING gin ((schedule_rules->'recurrence_type'));
CREATE INDEX IF NOT EXISTS idx_alerts_active_dates ON public.portal_alerts (is_active, created_at) WHERE is_active = true;

-- STEP 5: Add helper view for easy querying
CREATE OR REPLACE VIEW public.portal_alerts_summary AS
SELECT 
  id,
  title,
  severity,
  is_active,
  targeting_rules->>'mode' as targeting_mode,
  jsonb_array_length(COALESCE(targeting_rules->'include_students', '[]'::jsonb)) as included_students_count,
  jsonb_array_length(COALESCE(targeting_rules->'exclude_students', '[]'::jsonb)) as excluded_students_count,
  frequency_rules->>'cap_type' as frequency_cap,
  schedule_rules->>'recurrence_type' as recurrence_type,
  (trigger_rules->'when')::text as triggers,
  created_at,
  created_by
FROM public.portal_alerts
ORDER BY created_at DESC;

-- STEP 6: Add validation function (optional but recommended)
CREATE OR REPLACE FUNCTION validate_alert_rules()
RETURNS TRIGGER AS $$
BEGIN
  -- Validate targeting_rules has required keys
  IF NOT (NEW.targeting_rules ? 'mode') THEN
    RAISE EXCEPTION 'targeting_rules must have "mode" key';
  END IF;
  
  -- Validate frequency_rules
  IF NOT (NEW.frequency_rules ? 'cap_type') THEN
    RAISE EXCEPTION 'frequency_rules must have "cap_type" key';
  END IF;
  
  -- Validate schedule_rules
  IF NOT (NEW.schedule_rules ? 'recurrence_type') THEN
    RAISE EXCEPTION 'schedule_rules must have "recurrence_type" key';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_alert_rules_trigger
  BEFORE INSERT OR UPDATE ON public.portal_alerts
  FOR EACH ROW
  EXECUTE FUNCTION validate_alert_rules();

-- Success message
DO $$ 
BEGIN
  RAISE NOTICE '✅ Alert system upgraded to flexible rule engine!';
  RAISE NOTICE '📊 New columns: targeting_rules, frequency_rules, schedule_rules, trigger_rules, interaction_rules';
  RAISE NOTICE '🔍 View created: portal_alerts_summary';
  RAISE NOTICE '⚡ Indexes created for performance';
  RAISE NOTICE '✔️  Validation trigger added';
END $$;

-- Verification query
SELECT 
  'Total Alerts' as metric,
  count(*) as value
FROM public.portal_alerts
UNION ALL
SELECT 
  'With New Rules' as metric,
  count(*) as value
FROM public.portal_alerts
WHERE targeting_rules IS NOT NULL;
