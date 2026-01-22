# Complete Supabase Migration Guide

## Overview
This guide walks you through migrating your entire Armenian College of Nurses admission system from one Supabase account to another.

## Prerequisites
- ✅ Access to OLD Supabase account
- ✅ Access to NEW Supabase account  
- ✅ Supabase CLI installed (`npm install -g supabase`)
- ✅ All migration SQL files in this repository

---

## PHASE 1: EXPORT FROM OLD ACCOUNT (30 minutes)

### Step 1.1: Export Database Records
1. Open OLD Supabase SQL Editor
2. Run `EXPORT-ALL-DATA.sql`
3. **Save all output to CSV files** for each table:
   - applications.csv
   - registrations.csv
   - students.csv
   - email_history.csv
   - admin_users.csv
   - user_tasks.csv
   - transcripts.csv

### Step 1.2: Export Storage Files
```bash
# Install Supabase CLI if not already installed
npm install -g supabase

# Login to old account
supabase login

# Download all files from application-documents bucket
supabase storage download application-documents --project-ref OLD-PROJECT-ID --output ./backup/application-documents/

# Download all files from email-attachments bucket
supabase storage download email-attachments --project-ref OLD-PROJECT-ID --output ./backup/email-attachments/
```

### Step 1.3: Backup Edge Functions
```bash
# Already in your repo at:
# supabase/functions/send-sms/index.ts
# supabase/functions/send-email/index.ts
# supabase/functions/verify-sms/index.ts
```

### Step 1.4: Document Current Secrets
Save these from OLD Supabase Dashboard → Settings → Edge Functions:
```
TWILIO_ACCOUNT_SID=ACxxx...
TWILIO_AUTH_TOKEN=xxx...
TWILIO_PHONE_NUMBER=+1xxx...
RESEND_API_KEY=re_xxx...
RESEND_FROM_EMAIL=admin@acnhs.am
```

---

## PHASE 2: SETUP NEW ACCOUNT (20 minutes)

### Step 2.1: Create Database Schema
Run these in NEW Supabase SQL Editor in this exact order:

1. **Master Schema:**
   ```sql
   -- Copy/paste entire content of: supabase/schema.sql
   ```

2. **Storage Buckets:**
   ```sql
   -- Copy/paste: CREATE-STORAGE-BUCKET.sql
   -- Copy/paste: CREATE-EMAIL-ATTACHMENTS-BUCKET.sql
   ```

3. **Verify Setup:**
   ```sql
   -- Copy/paste: TEST-DATABASE-100-PERCENT.sql
   -- Should show: ✓✓✓ 100% READY ✓✓✓
   ```

### Step 2.2: Configure Storage Bucket Policies
In NEW Supabase Dashboard → Storage → application-documents → Policies:

```sql
-- Allow public read
CREATE POLICY "Public can view documents"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'application-documents');

-- Allow anon upload (for form submissions)
CREATE POLICY "Anon can upload documents"
ON storage.objects FOR INSERT
TO anon
WITH CHECK (bucket_id = 'application-documents');
```

Repeat for `email-attachments` bucket.

### Step 2.3: Deploy Edge Functions
```bash
# Login to new account
supabase login

# Link to new project
supabase link --project-ref NEW-PROJECT-ID

# Deploy functions
cd supabase/functions
supabase functions deploy send-sms --project-ref NEW-PROJECT-ID
supabase functions deploy send-email --project-ref NEW-PROJECT-ID
supabase functions deploy verify-sms --project-ref NEW-PROJECT-ID
```

### Step 2.4: Set Secrets in New Account
```bash
supabase secrets set TWILIO_ACCOUNT_SID=ACxxx... --project-ref NEW-PROJECT-ID
supabase secrets set TWILIO_AUTH_TOKEN=xxx... --project-ref NEW-PROJECT-ID
supabase secrets set TWILIO_PHONE_NUMBER=+1xxx... --project-ref NEW-PROJECT-ID
supabase secrets set RESEND_API_KEY=re_xxx... --project-ref NEW-PROJECT-ID
supabase secrets set RESEND_FROM_EMAIL=admin@acnhs.am --project-ref NEW-PROJECT-ID
```

---

## PHASE 3: IMPORT DATA (30 minutes)

### Step 3.1: Import Database Records

**Method A: CSV Import (Easiest)**
1. Go to NEW Supabase Dashboard → Table Editor
2. For each table (applications, registrations, students, etc.):
   - Click table name
   - Click "Insert" → "Import data from CSV"
   - Upload corresponding CSV file from Step 1.1
   - Map columns
   - Click "Import"

**Method B: SQL Import (Advanced)**
1. Open `IMPORT-ALL-DATA.sql`
2. Replace placeholder VALUES with your exported data
3. Run in NEW Supabase SQL Editor

### Step 3.2: Upload Storage Files
```bash
# Upload application documents
supabase storage upload application-documents ./backup/application-documents/* --project-ref NEW-PROJECT-ID

# Upload email attachments
supabase storage upload email-attachments ./backup/email-attachments/* --project-ref NEW-PROJECT-ID
```

### Step 3.3: Verify Data Import
Run in NEW Supabase SQL Editor:
```sql
-- Check record counts match old account
SELECT 'applications' as table_name, COUNT(*) FROM applications
UNION ALL
SELECT 'registrations', COUNT(*) FROM registrations
UNION ALL
SELECT 'students', COUNT(*) FROM students
UNION ALL
SELECT 'email_history', COUNT(*) FROM email_history;

-- Check storage files
SELECT bucket_id, COUNT(*) as file_count
FROM storage.objects
GROUP BY bucket_id;
```

---

## PHASE 4: UPDATE CODE (10 minutes)

### Step 4.1: Update Supabase Config
Edit `js/supabase-config.js`:
```javascript
const SUPABASE_CONFIG = {
  url: 'https://NEW-PROJECT-ID.supabase.co',  // Change this
  anonKey: 'NEW-ANON-KEY'                      // Change this
};
```

Get new values from NEW Supabase Dashboard → Settings → API

### Step 4.2: Find Any Hardcoded References
```bash
cd /Users/richyf/Library/Mobile\ Documents/com~apple~CloudDocs/DIPLOMA
grep -r "zlvnxvrzotamhpezqedr" . --exclude-dir=node_modules
grep -r "OLD-PROJECT-ID" . --exclude-dir=node_modules
```

Replace any found with NEW-PROJECT-ID.

### Step 4.3: Update Edge Function URLs (if hardcoded anywhere)
Old: `https://OLD-PROJECT-ID.supabase.co/functions/v1/send-sms`
New: `https://NEW-PROJECT-ID.supabase.co/functions/v1/send-sms`

---

## PHASE 5: TESTING (20 minutes)

### Test 1: Database Access
```bash
python3 start-server.py
# Open http://localhost:8000/check-database.html
# Should show all tables with green checkmarks
```

### Test 2: Form Submission
1. Open `http://localhost:8000/admission-form.html`
2. Fill out form (use test data)
3. Submit
4. Check NEW Supabase Dashboard → Table Editor → applications
5. Verify new record appears

### Test 3: Admin Dashboard
1. Open `http://localhost:8000/login.html`
2. Login with admin email: `Hrachfilm@gmail.com` (or your admin email)
3. Open `http://localhost:8000/admin-applications.html`
4. Verify you see all migrated applications
5. Test editing an application

### Test 4: SMS Sending (if using Twilio)
1. Open admin dashboard
2. Try sending test SMS to applicant
3. Check Twilio logs for delivery

### Test 5: Email Sending (if using Resend)
1. Try sending test email from admin
2. Check Resend dashboard for delivery
3. Verify email appears in email_history table

### Test 6: Storage/File Upload
1. In admin, try uploading a document
2. Verify file appears in Storage → application-documents
3. Try downloading the file

---

## PHASE 6: GO LIVE (5 minutes)

### Step 6.1: Commit Changes
```bash
cd /Users/richyf/Library/Mobile\ Documents/com~apple~CloudDocs/DIPLOMA
git add js/supabase-config.js
git commit -m "Migrate to new Supabase account"
git push origin main
```

### Step 6.2: Deploy to Production (if using GitHub Pages)
```bash
# If using custom domain, update DNS if needed
# Deploy will happen automatically on push to main
```

### Step 6.3: Monitor for Errors
- Check browser console for any Supabase connection errors
- Monitor NEW Supabase Dashboard → Logs for any issues
- Test all critical features again in production

---

## ROLLBACK PLAN (If Something Goes Wrong)

### Quick Rollback:
1. Revert `js/supabase-config.js` to old values:
   ```javascript
   url: 'https://OLD-PROJECT-ID.supabase.co'
   anonKey: 'OLD-ANON-KEY'
   ```
2. Git commit and push
3. Wait for deployment
4. Everything will point back to old account

---

## POST-MIGRATION CHECKLIST

- [ ] All tables have correct record counts
- [ ] All storage files uploaded successfully
- [ ] Edge functions deployed and working
- [ ] Admin login works
- [ ] Form submission works
- [ ] Email sending works (if enabled)
- [ ] SMS sending works (if enabled)
- [ ] File uploads work
- [ ] All admin features functional
- [ ] No console errors in browser
- [ ] `TEST-DATABASE-100-PERCENT.sql` shows ✓✓✓ 100% READY ✓✓✓

---

## TROUBLESHOOTING

### "Column does not exist" errors
- Re-run `supabase/schema.sql` in new account
- Check if all ADD-*.sql migrations were included in schema.sql

### "Bucket not found" errors
- Run `CREATE-STORAGE-BUCKET.sql` and `CREATE-EMAIL-ATTACHMENTS-BUCKET.sql`
- Verify buckets exist in Storage dashboard

### "Insufficient permissions" errors
- Check RLS policies are created
- Verify anon key is correct in `js/supabase-config.js`

### Edge functions not working
- Check secrets are set: `supabase secrets list --project-ref NEW-PROJECT-ID`
- Check function logs: `supabase functions logs send-sms --project-ref NEW-PROJECT-ID`

---

## ESTIMATED TOTAL TIME: ~2 hours

- Export: 30 min
- Setup: 20 min
- Import: 30 min
- Update code: 10 min
- Testing: 20 min
- Deploy: 5 min
- Buffer for troubleshooting: 15 min

---

## SUPPORT FILES INCLUDED

- `EXPORT-ALL-DATA.sql` - Export data from old account
- `IMPORT-ALL-DATA.sql` - Import template for new account
- `TEST-DATABASE-100-PERCENT.sql` - Verify new setup is complete
- `DATABASE-SETUP-ORDER.md` - Order to run CREATE and ADD SQL files
- `supabase/schema.sql` - Master schema (single file to run)

Good luck with your migration! 🚀
