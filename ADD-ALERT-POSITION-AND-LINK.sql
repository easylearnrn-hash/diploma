-- ==========================================
-- ADD DISPLAY POSITION & LINK TO PORTAL ALERTS
-- ==========================================
-- Run in Supabase SQL Editor
-- Date: 2026-02-20

-- 1. Add display_position column
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'portal_alerts' 
    AND column_name = 'display_position'
  ) THEN
    ALTER TABLE public.portal_alerts 
      ADD COLUMN display_position TEXT NOT NULL DEFAULT 'modal'
      CHECK (display_position IN ('modal','banner_top','banner_bottom','toast_tr','toast_tl','toast_br','toast_bl'));
    COMMENT ON COLUMN public.portal_alerts.display_position IS 
      'Where the alert appears: modal (center overlay), banner_top, banner_bottom, or toast at corner (tr/tl/br/bl)';
  END IF;
END $$;

-- 2. Add optional click-through link
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'portal_alerts' 
    AND column_name = 'link_url'
  ) THEN
    ALTER TABLE public.portal_alerts ADD COLUMN link_url TEXT;
    ALTER TABLE public.portal_alerts ADD COLUMN link_label TEXT DEFAULT 'Learn More';
    COMMENT ON COLUMN public.portal_alerts.link_url IS 
      'Optional URL shown as a button/link inside the alert';
  END IF;
END $$;

-- 3. Back-fill existing rows
UPDATE public.portal_alerts SET display_position = 'modal' WHERE display_position IS NULL;

-- Verify
SELECT id, title, display_position, link_url FROM public.portal_alerts LIMIT 10;

DO $$ BEGIN
  RAISE NOTICE '✅ display_position and link_url columns added to portal_alerts!';
END $$;
