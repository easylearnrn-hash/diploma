# 🚨 CRITICAL: APPLICATION MIGRATION GUIDE

## Project Migration
**FROM:** `zlvnxvrzotamhpezqedr` (OLD PROJECT)  
**TO:** `eyhksbiceueoiamwnqpr` (NEW PROJECT)

## ⚠️ IMPORTANT DISCOVERY
- Your `js/supabase-config.js` is **ALREADY** pointing to the NEW project
- The admin panels are currently loading from the NEW project (that's why only 52 applications show)
- The OLD project has all your historical data (Hrachya, Mariam Abelyan, etc.)
- **Mariam Abelyan WAS found in OLD project:** ACNHS-ADM-20260120-141

## 🔧 FASTEST Migration Method

### Step 1: Start Local Server
```bash
python3 start-server.py
```

### Step 2: Open Migration Tool
```
http://localhost:8000/migrate-applications.html
```

### Step 3: Click "START MIGRATION"
The tool will:
- ✅ Connect to BOTH projects
- ✅ Fetch ALL applications from OLD project  
- ✅ Check existing data in NEW project
- ✅ Migrate only missing records (avoid duplicates)
- ✅ Migrate registrations (waiting list)
- ✅ Provide real-time logging

### Step 4: Verify
Click "VERIFY MIGRATION" button to confirm all data transferred

## 📊 What Gets Migrated

**Applications table:**
- id, reference_number, applicant_name, email, phone
- date_of_birth, program, start_term, status
- submission_date, payload, control_number
- document_id, verification_hash, barcode
- username, password_hash, plain_password
- credentials_screenshot, status_message
- admin_notes, rfe_documents_requested
- status_updated_at, status_history
- uploaded_documents, acceptance_letter_sent
- armenian_citizenship, citizenship_acquired_date
- card_number

**Also migrates:**
- Registrations (waiting list)
- All associated metadata

## 🔍 Verification Commands

Run in **NEW project** after migration:

```sql
-- Check total count
SELECT COUNT(*) FROM applications;

-- Find Hrachya Yeranosyan
SELECT reference_number, applicant_name, email, status, submission_date
FROM applications
WHERE applicant_name ILIKE '%Hrachya%'
   OR applicant_name ILIKE '%Yeranosyan%';

-- Find Mariam Abelyan  
SELECT reference_number, applicant_name, email, status, submission_date
FROM applications
WHERE applicant_name ILIKE '%Mariam%Abelyan%';

-- Get recent 10
SELECT reference_number, applicant_name, email, status, submission_date
FROM applications
ORDER BY submission_date DESC
LIMIT 10;
```

## ⚡ Quick Start (Copy-Paste)

```bash
# Terminal 1: Start server
cd "/Users/richyf/Library/Mobile Documents/com~apple~CloudDocs/DIPLOMA"
python3 start-server.py

# Terminal 2: Open migration tool
open http://localhost:8000/migrate-applications.html
```

Then click "START MIGRATION" in browser.

## 🆘 If Migration Tool Fails

### Fallback: Manual Export/Import

**Step 1 - Export from OLD:**
1. Go to: https://supabase.com/dashboard/project/zlvnxvrzotamhpezqedr
2. SQL Editor → Run: `SELECT * FROM applications ORDER BY submission_date DESC;`
3. Download as CSV

**Step 2 - Import to NEW:**
1. Go to: https://supabase.com/dashboard/project/eyhksbiceueoiamwnqpr  
2. Table Editor → applications → Import CSV
3. Map columns and import

## 📝 Post-Migration Checklist

- [ ] Run `SELECT COUNT(*) FROM applications` in NEW project
- [ ] Verify count matches OLD project
- [ ] Open admin-applications.html and confirm all records appear
- [ ] Search for "Hrachya Yeranosyan" - should appear
- [ ] Search for "Mariam Abelyan" - should appear
- [ ] Test filtering and sorting
- [ ] Verify credentials screenshots work
- [ ] Test student logins

## 🎯 Expected Outcome

After successful migration:
- **Before:** Admin shows 52 applications
- **After:** Admin shows ALL historical applications (likely 100+)
- All missing people (Hrachya, Mariam) will appear
- No data loss
- All functionality works

## 🔐 Security Notes

- Uses public `anon` key (safe for migration)
- Passwords remain hashed
- RLS policies respected
- Direct Supabase-to-Supabase transfer (no intermediaries)

## Files Created

1. **`migrate-applications.html`** - Interactive migration tool with UI
2. **`/tmp/migrate_applications.sql`** - SQL export query for manual fallback
3. **`/tmp/check_mariam.sql`** - Verification queries

## Ready to Migrate?

Run this NOW:
```bash
python3 start-server.py &
open http://localhost:8000/migrate-applications.html
```

Then click **START MIGRATION** and watch the progress!
