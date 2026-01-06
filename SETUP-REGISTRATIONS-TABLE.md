# 🔧 Run This in Supabase SQL Editor

Follow these steps to add the registrations/waiting list table:

## Steps:

1. **Go to Supabase Dashboard**: https://supabase.com/dashboard
2. **Select your project**: zlvnxvrzotamhpezqedr
3. **Click "SQL Editor"** in the left sidebar
4. **Click "+ New Query"**
5. **Copy and paste the SQL below**
6. **Click "Run"** or press `Cmd/Ctrl + Enter`

## SQL to Run:

```sql
-- ==========================================
-- REGISTRATIONS / WAITING LIST
-- ==========================================

-- Stores student registrations from the login page (waiting list)
CREATE TABLE IF NOT EXISTS public.registrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT NOT NULL,
    date_of_birth DATE NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    education_level TEXT NOT NULL,
    preferred_start_date TEXT NOT NULL,
    registration_date TIMESTAMPTZ DEFAULT timezone('utc', now()),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'contacted', 'approved', 'rejected')),
    notes TEXT
);

-- Helpful indexes
CREATE INDEX IF NOT EXISTS idx_registrations_email ON public.registrations(email);
CREATE INDEX IF NOT EXISTS idx_registrations_status ON public.registrations(status);
CREATE INDEX IF NOT EXISTS idx_registrations_date ON public.registrations(registration_date);
CREATE INDEX IF NOT EXISTS idx_registrations_start_date ON public.registrations(preferred_start_date);

-- Enable Row Level Security
ALTER TABLE public.registrations ENABLE ROW LEVEL SECURITY;

-- POLICIES
-- Allow anonymous inserts (public form submissions)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'registrations'
          AND policyname = 'Public can submit registrations'
    ) THEN
        CREATE POLICY "Public can submit registrations"
            ON public.registrations
            FOR INSERT
            TO anon
            WITH CHECK (true);
    END IF;
END$$;

-- Allow authenticated/anon read access for admin page
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'registrations'
          AND policyname = 'Public can read registrations'
    ) THEN
        CREATE POLICY "Public can read registrations"
            ON public.registrations
            FOR SELECT
            TO anon
            USING (true);
    END IF;
END$$;

GRANT ALL ON public.registrations TO service_role;
GRANT INSERT, SELECT ON public.registrations TO anon;
```

---

## ✅ After Running:

You should see:
- "Success. No rows returned"

This means the table is created!

---

## 🎉 NEW: Collapsible Admin Sidebar

The admin sidebar is now on **ALL admin pages** and can be:
- **Collapsed/Expanded**: Click the toggle button (◀) on the sidebar
- **Persistent**: Your preference is saved in localStorage
- **Mobile Friendly**: Hamburger menu on mobile devices

The sidebar appears automatically on:
- admin-home.html
- admin-applications.html
- Any other admin pages you add

---

## 🧪 Test It:

1. Go to http://localhost:8000/login.html
2. Click "Register"
3. Fill out the form
4. Submit
5. Go to http://localhost:8000/admin-applications.html
6. Click "Waiting List" tab
7. You should see the registration!

**Try the sidebar:**
- Click the ◀ button to collapse/expand
- Navigate between pages - sidebar stays in same state
- On mobile, use the hamburger menu (☰)
