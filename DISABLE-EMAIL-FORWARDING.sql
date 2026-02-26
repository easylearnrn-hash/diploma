-- Emergency kill switch: disable all auto-forwarding rules
UPDATE email_forwarding_rules
SET enabled = false
WHERE enabled = true;

-- Optional: verify
-- SELECT acnhs_email, forward_to_email, enabled FROM email_forwarding_rules;
