-- ==========================================
-- FIX PAYMENT REMINDER MESSAGE WITH HTML
-- ==========================================
-- Updates the Payment Reminder alert to use proper HTML formatting

UPDATE portal_alerts
SET message_html = '<p><strong>Dear {student_name},</strong></p>

<p>Your invoice is now available. Please ensure that your payment is completed no later than <strong>February 15</strong> to avoid any disruption to your portal access, class participation, or enrollment status.</p>

<p>If you have already submitted your payment, please upload your payment receipt in the <strong>Upload Documents</strong> section and select <strong>Invoice Receipt</strong> as the document type.</p>

<p>If you have any questions, please contact the administration office.</p>

<p style="margin-top: 20px;"><em>Thank you for your prompt attention to this matter.</em></p>'
WHERE title = 'Payment Reminder'
RETURNING id, title, length(message_html) as new_length;

-- Verify the update
SELECT 
  id,
  title,
  substring(message_html, 1, 100) as html_preview,
  message_html LIKE '%<p>%' as has_html_tags
FROM portal_alerts 
WHERE title = 'Payment Reminder';
