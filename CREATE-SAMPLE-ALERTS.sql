-- ==========================================
-- CREATE SAMPLE ALERTS WITH NEW RULE ENGINE
-- Run this to populate test data
-- ==========================================

-- Sample Alert 1: Welcome message for all students (always active)
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
  'Welcome to Student Portal',
  '<p>Welcome, {student_name}! We''re excited to have you in the Armenian College of Nursing and Health Sciences family.</p>',
  'info',
  true,
  'hrachfilm@gmail.com',
  '{"mode": "all", "include_students": [], "exclude_students": [], "groups": [], "statuses": [], "tags": [], "logic": "AND"}'::jsonb,
  '{"cap_type": "once_ever", "max_displays": null, "cooldown_hours": null, "per_period": null, "stop_after_response": false, "stop_after_days": null}'::jsonb,
  '{"recurrence_type": "always", "start_datetime": null, "end_datetime": null, "timezone": "Asia/Yerevan", "daily_pattern": null, "weekly_pattern": null, "monthly_pattern": null, "custom_dates": [], "exclude_dates": []}'::jsonb,
  '{"when": ["on_login"], "pages_whitelist": [], "pages_blacklist": [], "time_window": null}'::jsonb,
  '{"dismissible": true, "required_response": false, "remind_on_no": false, "auto_dismiss_seconds": null}'::jsonb
);

-- Sample Alert 2: Payment reminder (monthly, days 1-5)
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
  '💰 Tuition Payment Reminder',
  '<p>Dear {student_name},</p><p>Your tuition payment for {month} is due. Please visit the billing section to make your payment.</p>',
  'warn',
  true,
  'hrachfilm@gmail.com',
  '{"mode": "all", "include_students": [], "exclude_students": [], "groups": [], "statuses": ["active"], "tags": [], "logic": "AND"}'::jsonb,
  '{"cap_type": "daily", "max_displays": null, "cooldown_hours": null, "per_period": "day", "stop_after_response": false, "stop_after_days": null}'::jsonb,
  '{"recurrence_type": "monthly", "start_datetime": "2026-02-01T00:00:00", "end_datetime": null, "timezone": "Asia/Yerevan", "daily_pattern": null, "weekly_pattern": null, "monthly_pattern": {"day_range": [1, 5]}, "custom_dates": [], "exclude_dates": []}'::jsonb,
  '{"when": ["on_login"], "pages_whitelist": [], "pages_blacklist": [], "time_window": null}'::jsonb,
  '{"dismissible": true, "required_response": false, "remind_on_no": false, "auto_dismiss_seconds": null}'::jsonb
);

-- Sample Alert 3: Exam week announcement (specific date range)
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
  '📝 Midterm Exams This Week',
  '<p>Attention {student_name},</p><p>Midterm exams are scheduled this week. Please review your exam schedule and prepare accordingly. Good luck!</p>',
  'critical',
  true,
  'hrachfilm@gmail.com',
  '{"mode": "all", "include_students": [], "exclude_students": [], "groups": [], "statuses": [], "tags": [], "logic": "AND"}'::jsonb,
  '{"cap_type": "daily_first_login", "max_displays": null, "cooldown_hours": null, "per_period": "day", "stop_after_response": false, "stop_after_days": null}'::jsonb,
  '{"recurrence_type": "one_time", "start_datetime": "2026-03-15T00:00:00", "end_datetime": "2026-03-22T23:59:59", "timezone": "Asia/Yerevan", "daily_pattern": null, "weekly_pattern": null, "monthly_pattern": null, "custom_dates": [], "exclude_dates": []}'::jsonb,
  '{"when": ["on_login", "on_page_load"], "pages_whitelist": [], "pages_blacklist": [], "time_window": null}'::jsonb,
  '{"dismissible": true, "required_response": false, "remind_on_no": false, "auto_dismiss_seconds": 10}'::jsonb
);

-- Sample Alert 4: Class schedule change (requires response)
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
  '⏰ Important: Class Schedule Change',
  '<p>Hello {student_name},</p><p>Your Fundamentals of Nursing class has been moved to Room 204. Time remains the same.</p><p>Please confirm you''ve seen this message.</p>',
  'warn',
  true,
  'hrachfilm@gmail.com',
  '{"mode": "complex", "include_students": [], "exclude_students": [], "groups": ["group_a", "enrolled"], "statuses": ["active"], "tags": [], "logic": "AND"}'::jsonb,
  '{"cap_type": "until_response", "max_displays": 5, "cooldown_hours": 24, "per_period": null, "stop_after_response": true, "stop_after_days": 3}'::jsonb,
  '{"recurrence_type": "one_time", "start_datetime": "2026-02-13T08:00:00", "end_datetime": "2026-02-16T23:59:59", "timezone": "Asia/Yerevan", "daily_pattern": null, "weekly_pattern": null, "monthly_pattern": null, "custom_dates": [], "exclude_dates": []}'::jsonb,
  '{"when": ["on_login"], "pages_whitelist": [], "pages_blacklist": [], "time_window": {"start": "08:00", "end": "22:00"}}'::jsonb,
  '{"dismissible": false, "required_response": true, "remind_on_no": true, "auto_dismiss_seconds": null}'::jsonb
);

-- Sample Alert 5: Weekend wellness tip (weekly pattern)
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
  '🌟 Weekend Wellness Tip',
  '<p>Hi {student_name}!</p><p>Remember to take care of yourself this weekend. Get enough rest, stay hydrated, and enjoy some time with loved ones.</p>',
  'success',
  true,
  'hrachfilm@gmail.com',
  '{"mode": "all", "include_students": [], "exclude_students": [], "groups": [], "statuses": [], "tags": [], "logic": "AND"}'::jsonb,
  '{"cap_type": "weekly", "max_displays": null, "cooldown_hours": null, "per_period": "week", "stop_after_response": false, "stop_after_days": null}'::jsonb,
  '{"recurrence_type": "weekly", "start_datetime": "2026-02-01T00:00:00", "end_datetime": null, "timezone": "Asia/Yerevan", "daily_pattern": null, "weekly_pattern": {"days": ["saturday", "sunday"], "start_time": "09:00", "end_time": "21:00"}, "monthly_pattern": null, "custom_dates": [], "exclude_dates": []}'::jsonb,
  '{"when": ["on_login"], "pages_whitelist": [], "pages_blacklist": ["/admin-home.html", "/admin-applications.html"], "time_window": null}'::jsonb,
  '{"dismissible": true, "required_response": false, "remind_on_no": false, "auto_dismiss_seconds": 15}'::jsonb
);

-- Success message with count
DO $$ 
DECLARE
  alert_count INTEGER;
BEGIN 
  SELECT COUNT(*) INTO alert_count FROM portal_alerts;
  RAISE NOTICE '✅ Sample alerts created successfully!';
  RAISE NOTICE '📊 Total alerts in database: %', alert_count;
END $$;

-- Show the new alerts
SELECT 
  id,
  title,
  severity,
  targeting_rules->>'mode' as targeting_mode,
  frequency_rules->>'cap_type' as frequency_cap,
  schedule_rules->>'recurrence_type' as recurrence_type,
  is_active
FROM public.portal_alerts
ORDER BY created_at DESC;
