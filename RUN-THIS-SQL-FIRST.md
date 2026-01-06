# ⚠️ IMPORTANT: Run This SQL in Supabase First!

## Before registrations will work, you MUST create the table in Supabase.

### Quick Steps:

1. **Open Supabase Dashboard**
   - Go to: https://supabase.com/dashboard
   - Select your project: `zlvnxvrzotamhpezqedr`

2. **Open SQL Editor**
   - Click "SQL Editor" in the left sidebar
   - Click "New Query"

3. **Copy and Run This SQL:**

```sql
-- Create registrations table
CREATE TABLE IF NOT EXISTS public.registrations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  full_name TEXT NOT NULL,
  date_of_birth DATE NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  education_level TEXT,
  preferred_start_date TEXT,
  status TEXT DEFAULT 'pending',
  registration_date TIMESTAMPTZ DEFAULT NOW(),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.registrations ENABLE ROW LEVEL SECURITY;

-- Policy to allow anonymous users to insert
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'registrations' 
    AND policyname = 'Allow anonymous insert'
  ) THEN
    CREATE POLICY "Allow anonymous insert"
    ON public.registrations
    FOR INSERT
    TO anon
    WITH CHECK (true);
  END IF;
END $$;

-- Policy to allow authenticated users to read
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'registrations' 
    AND policyname = 'Allow authenticated read'
  ) THEN
    CREATE POLICY "Allow authenticated read"
    ON public.registrations
    FOR SELECT
    TO authenticated
    USING (true);
  END IF;
END $$;

-- Policy to allow authenticated users to update
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'registrations' 
    AND policyname = 'Allow authenticated update'
  ) THEN
    CREATE POLICY "Allow authenticated update"
    ON public.registrations
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);
  END IF;
END $$;
```

4. **Click "Run" button** (or press Cmd+Enter)

5. **Verify Success**
   - You should see "Success. No rows returned"
   - Go back to your admin panel
   - Click the "Refresh" button on the Waiting List tab
   - You should now see the registration!

---

## Troubleshooting

**If you see an error:**
- Make sure you're logged into the correct Supabase project
- Check that you copied the entire SQL code
- Look at the error message - it will tell you what went wrong

**If registrations still don't appear:**
- Open the browser console (F12)
- Look for error messages
- Make sure the user who registered used the form AFTER running this SQL

---

## What This SQL Does:

1. ✅ Creates the `registrations` table with all required fields
2. ✅ Enables Row Level Security (RLS)
3. ✅ Allows anyone to register (anonymous insert)
4. ✅ Allows admins to view/edit registrations (authenticated access)
5. ✅ Uses safe idempotent SQL (won't error if run multiple times)
