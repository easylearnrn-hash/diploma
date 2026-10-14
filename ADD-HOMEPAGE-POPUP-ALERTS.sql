-- ==========================================================================
-- ALERT CENTER V2
-- Homepage pop-up alerts, lifecycle statuses, priority levels, precise
-- scheduling, display frequency and acknowledgement rules.
-- ==========================================================================
-- Run in the Supabase SQL Editor: https://supabase.com/dashboard
--   Project: eyhksbiceueoiamwnqpr  ->  SQL Editor  ->  paste  ->  Run
--
-- * Safe to run more than once (idempotent).
-- * Purely additive: every existing alert, template, impression and response
--   keeps working. Existing alerts become "student portal" alerts.
-- * Prerequisites (already applied in production):
--     CREATE-PORTAL-ALERTS-SYSTEM.sql, UPGRADE-ALERTS-TO-RULE-ENGINE.sql,
--     ADD-ALERT-GROUP-TARGETING.sql,   ADD-ALERT-POSITION-AND-LINK.sql
-- * Documentation: HOMEPAGE-POPUP-ALERTS-SETUP.md
-- ==========================================================================


-- --------------------------------------------------------------------------
-- 1. NEW COLUMNS
-- --------------------------------------------------------------------------

-- Where the alert is delivered: student portal pages, the public homepage, or both
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS display_surface   TEXT        NOT NULL DEFAULT 'portal';
-- Lifecycle: draft -> published -> archived (Scheduled / Live / Paused / Expired are derived)
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS lifecycle_status  TEXT        NOT NULL DEFAULT 'published';
-- Importance level (controls ordering and styling)
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS priority          TEXT        NOT NULL DEFAULT 'normal';
-- Precise go-live and expiry moments (NULL = no limit)
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS publish_at        TIMESTAMPTZ;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS expires_at        TIMESTAMPTZ;
-- Homepage frequency: every_visit | once_per_session | once_per_visitor
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS popup_frequency   TEXT        NOT NULL DEFAULT 'once_per_session';
-- dismissible = can be closed; acknowledge = visitor must press the acknowledge button
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS dismiss_behavior  TEXT        NOT NULL DEFAULT 'dismissible';
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS acknowledge_label TEXT;
-- Open the action button link in a new tab (true) or the same tab (false)
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS link_new_tab      BOOLEAN     NOT NULL DEFAULT true;
-- Content revision: increases whenever visible content changes, so
-- "once per visitor" pop-ups appear again after the alert is updated.
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS revision          INTEGER     NOT NULL DEFAULT 1;
-- Audit trail
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS published_at      TIMESTAMPTZ;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS published_by      TEXT;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS updated_by        TEXT;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS archived_at       TIMESTAMPTZ;
ALTER TABLE public.portal_alerts ADD COLUMN IF NOT EXISTS archived_by       TEXT;


-- --------------------------------------------------------------------------
-- 2. CHECK CONSTRAINTS
-- --------------------------------------------------------------------------

-- Audience types: all (everyone), public (visitors who are not signed in),
-- students (signed-in students), group, individual.
-- Drops whatever constraint currently guards target_type, whatever it is called.
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN
    SELECT conname
    FROM pg_constraint
    WHERE conrelid = 'public.portal_alerts'::regclass
      AND contype = 'c'
      AND pg_get_constraintdef(oid) ILIKE '%target_type%'
  LOOP
    EXECUTE format('ALTER TABLE public.portal_alerts DROP CONSTRAINT %I', r.conname);
  END LOOP;
END $$;

ALTER TABLE public.portal_alerts ADD CONSTRAINT portal_alerts_target_type_check
  CHECK (target_type IN ('all', 'group', 'individual', 'public', 'students'));

ALTER TABLE public.portal_alerts DROP CONSTRAINT IF EXISTS portal_alerts_display_surface_check;
ALTER TABLE public.portal_alerts ADD CONSTRAINT portal_alerts_display_surface_check
  CHECK (display_surface IN ('portal', 'homepage', 'both'));

ALTER TABLE public.portal_alerts DROP CONSTRAINT IF EXISTS portal_alerts_lifecycle_status_check;
ALTER TABLE public.portal_alerts ADD CONSTRAINT portal_alerts_lifecycle_status_check
  CHECK (lifecycle_status IN ('draft', 'published', 'archived'));

ALTER TABLE public.portal_alerts DROP CONSTRAINT IF EXISTS portal_alerts_priority_check;
ALTER TABLE public.portal_alerts ADD CONSTRAINT portal_alerts_priority_check
  CHECK (priority IN ('normal', 'important', 'urgent', 'critical'));

ALTER TABLE public.portal_alerts DROP CONSTRAINT IF EXISTS portal_alerts_popup_frequency_check;
ALTER TABLE public.portal_alerts ADD CONSTRAINT portal_alerts_popup_frequency_check
  CHECK (popup_frequency IN ('every_visit', 'once_per_session', 'once_per_visitor'));

ALTER TABLE public.portal_alerts DROP CONSTRAINT IF EXISTS portal_alerts_dismiss_behavior_check;
ALTER TABLE public.portal_alerts ADD CONSTRAINT portal_alerts_dismiss_behavior_check
  CHECK (dismiss_behavior IN ('dismissible', 'acknowledge'));

ALTER TABLE public.portal_alerts DROP CONSTRAINT IF EXISTS portal_alerts_revision_check;
ALTER TABLE public.portal_alerts ADD CONSTRAINT portal_alerts_revision_check
  CHECK (revision >= 1);


-- --------------------------------------------------------------------------
-- 3. ONE-TIME BACK-FILL OF PRIORITY FROM THE OLD "SEVERITY" FIELD
-- --------------------------------------------------------------------------
-- Alerts created before this upgrade keep their look in the student portal
-- (severity is unchanged). The new priority is simply derived from it so the
-- Alert Center shows a meaningful value.
UPDATE public.portal_alerts
SET priority = CASE severity WHEN 'critical' THEN 'critical' WHEN 'warn' THEN 'important' ELSE priority END
WHERE priority = 'normal'
  AND severity IN ('critical', 'warn');


-- --------------------------------------------------------------------------
-- 4. GUARD TRIGGER: lifecycle rules, content safety, revision counter
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.portal_alerts_v2_guard()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_url TEXT;
BEGIN
  -- Drafts and archived alerts can never be delivered by any engine.
  IF NEW.lifecycle_status IN ('draft', 'archived') THEN
    NEW.is_active := FALSE;
  ELSIF NEW.is_active IS NULL THEN
    NEW.is_active := TRUE;
  END IF;

  -- Publication / archive timestamps
  IF NEW.lifecycle_status = 'published' THEN
    IF TG_OP = 'INSERT' THEN
      NEW.published_at := COALESCE(NEW.published_at, now());
    ELSIF OLD.lifecycle_status IS DISTINCT FROM 'published'
          AND NEW.published_at IS NOT DISTINCT FROM OLD.published_at THEN
      NEW.published_at := now();
    END IF;
  END IF;

  IF NEW.lifecycle_status = 'archived' THEN
    IF TG_OP = 'INSERT' OR OLD.lifecycle_status IS DISTINCT FROM 'archived' THEN
      NEW.archived_at := COALESCE(NEW.archived_at, now());
    END IF;
  ELSE
    NEW.archived_at := NULL;
    NEW.archived_by := NULL;
  END IF;

  -- Size limits
  IF char_length(COALESCE(NEW.title, '')) > 200 THEN
    RAISE EXCEPTION 'Alert title is too long (maximum 200 characters).' USING ERRCODE = '22023';
  END IF;
  IF char_length(COALESCE(NEW.message_html, '')) > 20000 THEN
    RAISE EXCEPTION 'Alert message is too long (maximum 20,000 characters).' USING ERRCODE = '22023';
  END IF;
  IF char_length(COALESCE(NEW.link_label, '')) > 80 THEN
    RAISE EXCEPTION 'Button label is too long (maximum 80 characters).' USING ERRCODE = '22023';
  END IF;

  -- Alerts are shown on the public homepage: block executable markup outright.
  IF NEW.message_html ~* '<\s*/?\s*(script|iframe|object|embed|style|link|meta|base|form|svg|math)(\s|>|/|$)'
     OR NEW.message_html ~* '<[^>]*\son[a-z]+\s*='
     OR NEW.message_html ~* 'javascript\s*:'
     OR NEW.message_html ~* 'data\s*:\s*text/html' THEN
    RAISE EXCEPTION 'Alert message contains markup that is not allowed (scripts, frames, styles or event handlers).' USING ERRCODE = '22023';
  END IF;

  -- Action button link: https://, http://, mailto:, tel: or a relative page (hub.html, /apply)
  v_url := NULLIF(btrim(COALESCE(NEW.link_url, '')), '');
  IF v_url IS NOT NULL THEN
    IF NOT (v_url ~* '^(https?://|mailto:|tel:)[^[:space:]<>"'']+$' OR v_url ~ '^[^:[:space:]<>"'']+$') THEN
      RAISE EXCEPTION 'Alert link must start with https://, http://, mailto:, tel: or be a relative page such as hub.html.' USING ERRCODE = '22023';
    END IF;
  END IF;
  NEW.link_url := v_url;

  -- Schedule sanity
  IF NEW.publish_at IS NOT NULL AND NEW.expires_at IS NOT NULL AND NEW.expires_at <= NEW.publish_at THEN
    RAISE EXCEPTION 'The expiration time must be later than the start time.' USING ERRCODE = '22023';
  END IF;

  -- Bump the revision when anything a visitor can see changes (not on pause/resume,
  -- schedule or audience edits), unless the caller already changed it explicitly.
  IF TG_OP = 'UPDATE' AND NEW.revision IS NOT DISTINCT FROM OLD.revision THEN
    IF NEW.title             IS DISTINCT FROM OLD.title
       OR NEW.message_html      IS DISTINCT FROM OLD.message_html
       OR NEW.link_url          IS DISTINCT FROM OLD.link_url
       OR NEW.link_label        IS DISTINCT FROM OLD.link_label
       OR NEW.link_new_tab      IS DISTINCT FROM OLD.link_new_tab
       OR NEW.priority          IS DISTINCT FROM OLD.priority
       OR NEW.dismiss_behavior  IS DISTINCT FROM OLD.dismiss_behavior
       OR NEW.acknowledge_label IS DISTINCT FROM OLD.acknowledge_label THEN
      NEW.revision := OLD.revision + 1;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS portal_alerts_v2_guard_trg ON public.portal_alerts;
CREATE TRIGGER portal_alerts_v2_guard_trg
  BEFORE INSERT OR UPDATE ON public.portal_alerts
  FOR EACH ROW
  EXECUTE FUNCTION public.portal_alerts_v2_guard();


-- --------------------------------------------------------------------------
-- 5. INDEXES
-- --------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_portal_alerts_surface_status
  ON public.portal_alerts (display_surface, lifecycle_status, is_active);
CREATE INDEX IF NOT EXISTS idx_portal_alerts_window
  ON public.portal_alerts (publish_at, expires_at);


-- --------------------------------------------------------------------------
-- 6. PUBLIC DELIVERY FUNCTION
-- --------------------------------------------------------------------------
-- One cheap call for the homepage: returns only alerts that are published,
-- switched on, assigned to the requested surface and inside their start /
-- expiry window, evaluated with the DATABASE clock (not the visitor's clock).
-- The homepage script does the audience, frequency and acknowledgement logic.
CREATE OR REPLACE FUNCTION public.get_site_alerts(p_surface TEXT DEFAULT 'homepage')
RETURNS JSONB
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT jsonb_build_object(
    'server_time', to_jsonb(now()),
    'alerts', COALESCE(jsonb_agg(to_jsonb(a) ORDER BY a.prio_rank DESC, a.sort_ts DESC), '[]'::jsonb)
  )
  FROM (
    SELECT
      id, title, message_html, severity, priority, display_surface, display_position,
      link_url, link_label, link_new_tab, dismiss_behavior, acknowledge_label,
      popup_frequency, revision, target_type, target_student_ids, target_group,
      targeting_rules, schedule_rules, date_rule_type, monthly_start_day,
      monthly_end_day, custom_dates, publish_at, expires_at, published_at, created_at,
      CASE priority WHEN 'critical' THEN 4 WHEN 'urgent' THEN 3 WHEN 'important' THEN 2 ELSE 1 END AS prio_rank,
      COALESCE(publish_at, published_at, created_at) AS sort_ts
    FROM public.portal_alerts
    WHERE p_surface IN ('homepage', 'portal')
      AND is_active IS TRUE
      AND lifecycle_status = 'published'
      AND display_surface IN (p_surface, 'both')
      AND (publish_at IS NULL OR publish_at <= now())
      AND (expires_at IS NULL OR expires_at > now())
  ) a;
$$;

REVOKE ALL ON FUNCTION public.get_site_alerts(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_site_alerts(TEXT) TO anon, authenticated, service_role;


-- --------------------------------------------------------------------------
-- 7. DOCUMENTATION COMMENTS
-- --------------------------------------------------------------------------
COMMENT ON COLUMN public.portal_alerts.display_surface  IS 'portal = student portal pages | homepage = public website pop-up | both';
COMMENT ON COLUMN public.portal_alerts.lifecycle_status IS 'draft | published | archived. Scheduled, live, paused and expired are derived from is_active, publish_at and expires_at.';
COMMENT ON COLUMN public.portal_alerts.priority         IS 'normal | important | urgent | critical (display order and styling)';
COMMENT ON COLUMN public.portal_alerts.publish_at       IS 'Moment the alert goes live (NULL = immediately)';
COMMENT ON COLUMN public.portal_alerts.expires_at       IS 'Moment the alert stops being shown (NULL = never)';
COMMENT ON COLUMN public.portal_alerts.popup_frequency  IS 'Homepage frequency: every_visit | once_per_session | once_per_visitor (until the alert is updated)';
COMMENT ON COLUMN public.portal_alerts.dismiss_behavior IS 'dismissible = visitor may close it | acknowledge = visitor must press the acknowledge button';
COMMENT ON COLUMN public.portal_alerts.revision         IS 'Increases when visible content changes; resets "once per visitor" tracking in browsers';
COMMENT ON FUNCTION public.get_site_alerts(TEXT)        IS 'Published, enabled, in-window alerts for a surface (homepage | portal). Used by js/homepage-alerts.js';

DO $$
BEGIN
  RAISE NOTICE 'Alert Center V2 installed: lifecycle, priority, schedule, homepage pop-ups.';
END $$;

-- Make the new columns and function visible to the website immediately
NOTIFY pgrst, 'reload schema';
