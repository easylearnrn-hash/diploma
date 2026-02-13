-- ==========================================
-- UPDATE ALERT TEMPLATES WITH VARIABLES
-- ==========================================
-- Add template variable examples to existing alert templates
-- Date: 2026-02-13

-- 1. Payment 1-5 (Monthly Payment Reminder)
UPDATE public.portal_alert_templates
SET 
  title = 'Payment Due - {month} {year}',
  message_html = '<p>Dear <strong>{student_name}</strong>,</p><p>Your monthly payment is now due. Please submit your payment no later than the 5th of this month to avoid any interruption to your access and enrollment status.</p><p><strong>Student ID:</strong> {student_id}<br><strong>Due Date:</strong> {month} 5th, {year}<br><strong>Contact:</strong> {email}</p><p>If you have already made the payment, please disregard this message.</p>'
WHERE template_name = 'Payment 1-5';

-- 2. Payment Reminder (already updated)
UPDATE public.portal_alert_templates
SET 
  title = 'Payment Reminder - {month} {year}',
  message_html = '<p>Dear <strong>{student_name}</strong>,</p><p>This is a friendly reminder that your tuition payment for <strong>{month}</strong> is due. Please visit the finance office or use our online payment portal.</p><p><strong>Student ID:</strong> {student_id}<br><strong>Email:</strong> {email}<br><strong>Group:</strong> {group}</p>'
WHERE template_name = 'Payment Reminder';

-- 3. Class Time Change
UPDATE public.portal_alert_templates
SET 
  title = 'Schedule Change - {month} {year}',
  message_html = '<p>Dear <strong>{student_name}</strong>,</p><p>Please be advised that the following class has a schedule change:</p><p><strong>Course:</strong> [Course Name]<br><strong>New Time:</strong> [New Schedule]<br><strong>Effective Date:</strong> {date}</p><p><strong>Your Student ID:</strong> {student_id}<br><strong>Your Group:</strong> {group}</p><p>Please update your calendar accordingly. If you have any conflicts, contact the registrar''s office immediately.</p>'
WHERE template_name = 'Class Time Change';

-- 4. Clinical Schedule Acknowledgment
UPDATE public.portal_alert_templates
SET 
  title = 'Clinical Schedule Posted - {month} {year}',
  message_html = '<p>Dear <strong>{student_name}</strong>,</p><p>Your clinical rotation schedule for <strong>{month} {year}</strong> has been posted to your portal.</p><p><strong>Student ID:</strong> {student_id}<br><strong>Email:</strong> {email}<br><strong>Posted Date:</strong> {date}</p><p><strong>⚠️ Action Required:</strong> Please review your schedule and confirm receipt by clicking "Yes" below. Contact clinical coordination if you have any conflicts.</p>'
WHERE template_name = 'Clinical Schedule Acknowledgment';

-- 5. Exam Week Announcement
UPDATE public.portal_alert_templates
SET 
  title = 'Exam Week - {month} {year}',
  message_html = '<p>Dear <strong>{student_name}</strong>,</p><p><strong>Exam Week:</strong> [Exam dates in {month}]</p><p><strong>Important reminders:</strong></p><ul><li>Review your exam schedule on the portal</li><li>Arrive 15 minutes early</li><li>Bring valid student ID ({student_id})</li><li>No electronic devices allowed</li><li>Review academic integrity policy</li></ul><p><strong>Your Group:</strong> {group}<br><strong>Contact:</strong> {email}</p><p>Good luck with your exams!</p>'
WHERE template_name = 'Exam Week Announcement';

-- 6. Milestone Congratulations
UPDATE public.portal_alert_templates
SET 
  title = 'Congratulations, {student_name}!',
  message_html = '<p>Dear <strong>{student_name}</strong>,</p><p>Congratulations on your outstanding achievement in <strong>{month} {year}</strong>!</p><p>Your dedication and hard work have not gone unnoticed. This accomplishment is a testament to your commitment to excellence in nursing education.</p><p><strong>Student ID:</strong> {student_id}<br><strong>Recognition Date:</strong> {date}<br><strong>Group:</strong> {group}</p><p>Keep up the excellent work!</p><p><em>- Armenian College of Nurses and Health Sciences</em></p>'
WHERE template_name = 'Milestone Congratulations';

-- 7. Missing Documents Reminder
UPDATE public.portal_alert_templates
SET 
  title = 'Action Required: Missing Documents',
  message_html = '<p>Dear <strong>{student_name}</strong>,</p><p>Our records indicate that you have outstanding documents that need to be submitted:</p><ul><li>[Document 1]</li><li>[Document 2]</li><li>[Document 3]</li></ul><p><strong>Student ID:</strong> {student_id}<br><strong>Email:</strong> {email}<br><strong>Deadline:</strong> [Specific Date]<br><strong>Today:</strong> {date}</p><p>Please submit these documents to the registrar''s office or upload them to your student portal as soon as possible.</p>'
WHERE template_name = 'Missing Documents Reminder';

-- 8. New Notes Posted
UPDATE public.portal_alert_templates
SET 
  title = 'New Course Materials - {month} {year}',
  message_html = '<p>Hi <strong>{student_name}</strong>,</p><p>New lecture notes and course materials have been posted for:</p><ul><li><strong>[Course Name]</strong> - {date}</li></ul><p><strong>Student ID:</strong> {student_id}<br><strong>Group:</strong> {group}<br><strong>Posted:</strong> {month} {year}</p><p>Log in to your portal to access the materials. Review them before the next class session.</p>'
WHERE template_name = 'New Notes Posted';

-- 9. Orientation Confirmation
UPDATE public.portal_alert_templates
SET 
  title = 'Welcome {student_name} - Orientation {month} {year}',
  message_html = '<p>Welcome to Armenian College of Nurses, <strong>{student_name}</strong>! We are excited to have you join our community.</p><p><strong>New Student Orientation:</strong><br>📅 Date: [Orientation Date in {month}]<br>🕐 Time: [Start Time]<br>📍 Location: [Building/Room]</p><p><strong>Your Details:</strong><br>Student ID: {student_id}<br>Email: {email}<br>Group: {group}</p><p><strong>⚠️ Please confirm:</strong> Click "Yes" below to confirm your attendance. If you cannot attend, click "No" and contact admissions immediately.</p>'
WHERE template_name = 'Orientation Confirmation';

-- 10. Policy Update Acknowledgment
UPDATE public.portal_alert_templates
SET 
  title = 'Policy Update - Acknowledgment Required',
  message_html = '<p>Dear <strong>{student_name}</strong>,</p><p>The college has updated its <strong>[Policy Name]</strong> policy, effective <strong>{date}</strong>.</p><p><strong>Key Changes:</strong></p><ul><li>[Change 1]</li><li>[Change 2]</li><li>[Change 3]</li></ul><p><strong>Student ID:</strong> {student_id}<br><strong>Email:</strong> {email}<br><strong>Update Date:</strong> {month} {year}</p><p><strong>⚠️ Action Required:</strong> Please review the full policy document on the portal and click "Yes" below to acknowledge you have read and understood the changes.</p>'
WHERE template_name = 'Policy Update Acknowledgment';

-- 11. Portal Maintenance Notice
UPDATE public.portal_alert_templates
SET 
  title = 'Portal Maintenance - {date}',
  message_html = '<p>Hi <strong>{student_name}</strong>,</p><p>The student portal will undergo scheduled maintenance on <strong>{date}</strong> from <strong>12:00 AM to 4:00 AM</strong> (Armenia Time).</p><p><strong>What this means for you:</strong></p><ul><li>Portal will be temporarily unavailable</li><li>No access to grades, schedules, or documents</li><li>Email notifications will continue normally</li></ul><p><strong>Student ID:</strong> {student_id}<br><strong>Email:</strong> {email}</p><p>We apologize for any inconvenience. The portal will be faster and more reliable after this maintenance.</p>'
WHERE template_name = 'Portal Maintenance Notice';

-- Verification query
SELECT 
  template_name, 
  title,
  SUBSTRING(message_html, 1, 100) || '...' as message_preview,
  CASE 
    WHEN message_html LIKE '%{student_name}%' THEN '✅' 
    ELSE '❌' 
  END as has_student_name,
  CASE 
    WHEN message_html LIKE '%{month}%' OR message_html LIKE '%{date}%' THEN '✅' 
    ELSE '❌' 
  END as has_date_vars
FROM public.portal_alert_templates
ORDER BY template_name;

-- Success message
DO $$ 
BEGIN
  RAISE NOTICE '✅ Alert templates updated with personalization variables!';
  RAISE NOTICE 'Available variables: {student_name}, {student_id}, {email}, {month}, {year}, {date}, {group}';
END $$;
