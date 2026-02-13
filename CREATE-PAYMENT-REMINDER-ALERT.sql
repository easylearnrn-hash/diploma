-- ==========================================
-- MONTHLY PAYMENT REMINDER ALERT
-- Shows daily (first login) from 1st-5th of each month
-- ==========================================

INSERT INTO public.portal_alerts (
  title,
  message_html,
  severity,
  is_active,
  created_by,
  targeting_rules,
  frequency_rules,
  schedule_rules,
  trigger_rules,
  interaction_rules
) VALUES (
  '💰 Monthly Tuition Payment Required',
  '<p><strong>Dear {student_name},</strong></p>
  <p>This is a friendly reminder that your tuition payment for <strong>{month} {year}</strong> is now due.</p>
  <p>⚠️ <strong>Important:</strong> To avoid interruption to your account access and enrollment status, please submit your payment no later than the <strong>5th of this month</strong>.</p>
  <p>📋 <strong>Payment Options:</strong></p>
  <ul style="margin-left: 20px; line-height: 1.8;">
    <li>Visit the Billing & Payments section in your portal</li>
    <li>Contact the finance office at <a href="mailto:finance@acnhs.am" style="color: #2dd4bf;">finance@acnhs.am</a></li>
    <li>Visit the administration office during business hours</li>
  </ul>
  <p>⏰ <strong>Late Payment Consequences:</strong></p>
  <ul style="margin-left: 20px; line-height: 1.8;">
    <li>Portal access will be temporarily suspended after the 5th</li>
    <li>Class attendance may be restricted</li>
    <li>Late fees may apply</li>
    <li>Enrollment status may be affected</li>
  </ul>
  <p>If you have already made your payment, please disregard this message. If you are experiencing financial difficulty, please contact the Student Services office immediately to discuss payment arrangements.</p>
  <p>Thank you for your prompt attention to this matter.</p>
  <p style="margin-top: 20px;"><em>Armenian College of Nursing and Health Sciences<br>Finance Department</em></p>',
  'critical',
  true,
  'hrachfilm@gmail.com',
  '{
    "mode": "all",
    "include_students": [],
    "exclude_students": [],
    "groups": [],
    "statuses": [],
    "tags": [],
    "logic": "AND"
  }'::jsonb,
  '{
    "cap_type": "daily_first_login",
    "max_displays": null,
    "cooldown_hours": null,
    "per_period": "day",
    "stop_after_response": false,
    "stop_after_days": null
  }'::jsonb,
  '{
    "recurrence_type": "monthly",
    "start_datetime": "2026-02-01T00:00:00",
    "end_datetime": null,
    "timezone": "Asia/Yerevan",
    "daily_pattern": null,
    "weekly_pattern": null,
    "monthly_pattern": {
      "day_range": [1, 5]
    },
    "custom_dates": [],
    "exclude_dates": []
  }'::jsonb,
  '{
    "when": ["on_login"],
    "pages_whitelist": [],
    "pages_blacklist": [],
    "time_window": null
  }'::jsonb,
  '{
    "dismissible": true,
    "required_response": false,
    "remind_on_no": false,
    "auto_dismiss_seconds": null
  }'::jsonb
);

-- Also populate old columns for backward compatibility
UPDATE public.portal_alerts 
SET 
  target_type = 'all',
  target_student_ids = '[]'::jsonb,
  target_group = null,
  display_mode = 'daily_first_login',
  max_displays = null,
  date_rule_type = 'monthly_range',
  start_date = '2026-02-01',
  end_date = null,
  monthly_start_day = 1,
  monthly_end_day = 5,
  requires_response = false,
  response_type = 'none',
  yes_label = 'Yes',
  no_label = 'No'
WHERE title = '💰 Monthly Tuition Payment Required';

-- Success message
DO $$ 
BEGIN 
  RAISE NOTICE '✅ Monthly payment reminder alert created!';
  RAISE NOTICE '📅 Shows: Every month from 1st-5th';
  RAISE NOTICE '🔄 Frequency: Once per day (first login)';
  RAISE NOTICE '🎯 Target: All students';
  RAISE NOTICE '⚠️  Severity: Critical (Red)';
END $$;

-- Show the new alert
SELECT 
  id,
  title,
  severity,
  targeting_rules->>'mode' as targeting_mode,
  frequency_rules->>'cap_type' as frequency_cap,
  schedule_rules->>'recurrence_type' as recurrence,
  schedule_rules->'monthly_pattern'->'day_range' as days,
  is_active
FROM public.portal_alerts
WHERE title = '💰 Monthly Tuition Payment Required';
