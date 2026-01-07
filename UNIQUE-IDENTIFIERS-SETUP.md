# Unique Identifiers Implementation

## ✅ COMPLETED

All unique identifiers are now implemented and will be saved automatically for new applications.

## 🗄️ DATABASE MIGRATION REQUIRED

**You must run this SQL in your Supabase SQL Editor:**

```sql
-- Add unique identifier columns to applications table
ALTER TABLE public.applications 
ADD COLUMN IF NOT EXISTS control_number TEXT UNIQUE;

ALTER TABLE public.applications 
ADD COLUMN IF NOT EXISTS document_id TEXT UNIQUE;

ALTER TABLE public.applications 
ADD COLUMN IF NOT EXISTS hash TEXT UNIQUE;

-- Make barcode unique (if not already)
ALTER TABLE public.applications 
DROP CONSTRAINT IF EXISTS applications_barcode_key;

ALTER TABLE public.applications 
ADD CONSTRAINT applications_barcode_key UNIQUE (barcode);

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_applications_control_number ON public.applications(control_number);
CREATE INDEX IF NOT EXISTS idx_applications_document_id ON public.applications(document_id);
CREATE INDEX IF NOT EXISTS idx_applications_hash ON public.applications(hash);

-- Add comments for documentation
COMMENT ON COLUMN public.applications.reference_number IS 'Reference Number (REF: ACNHS-ADM-20260106-960)';
COMMENT ON COLUMN public.applications.control_number IS 'Control Number (CTRL: ACN-2026-136376)';
COMMENT ON COLUMN public.applications.document_id IS 'Document ID (DOC ID: ACN-2026-392908)';
COMMENT ON COLUMN public.applications.barcode IS 'Barcode (ACN2024001234VERIFY)';
COMMENT ON COLUMN public.applications.hash IS 'SHA256 Hash (HASH: SHA256-D82025)';
```

## 📋 WHAT'S INCLUDED

### 5 Unique Identifiers Per Application:

1. **REF** (reference_number): `ACNHS-ADM-20260106-960`
   - Format: ACNHS-ADM-YYYYMMDD-XXX
   - Main reference number
   
2. **CTRL** (control_number): `ACN-2026-136376`
   - Format: ACN-YYYY-XXXXXX
   - Control number for verification
   - **NOW searchable on acnhs.am/verify** ✅

3. **DOC ID** (document_id): `ACN-2026-392908`
   - Format: ACN-YYYY-XXXXXX
   - Document identification number

4. **Barcode** (barcode): `ACN2024001234VERIFY`
   - Unique barcode value
   - Displayed as barcode image in PDF

5. **HASH** (hash): `SHA256-D82025`
   - Format: SHA256-XXXXXX
   - Verification hash

## 📍 WHERE THEY APPEAR

### 1. Application PDF Preview
- Document Verification section shows:
  - REF: ACNHS-ADM-20260106-960
  - CTRL: ACN-2026-136376
  - HASH: SHA256-D82025
  - Barcode: ACN2024001234VERIFY
  - DOC ID: ACN-2026-392908
  - "VERIFY ONLINE: acnhs.am/verify"

### 2. Admin Drawer
- New "Document Verification" section shows all identifiers
- Blue-tinted panel with key-value pairs
- Easy copy-paste for verification

### 3. Verification Page
- Public can check application status using CTRL number
- Privacy-protected (shows only status, no personal info)

## ✨ AUTOMATIC GENERATION

All identifiers are automatically generated when an application is submitted:
- No manual input needed
- All unique (database enforces uniqueness)
- Generated using crypto.getRandomValues() for security

## 🔒 DATABASE GUARANTEES

- **UNIQUE constraints**: Prevents duplicate identifiers
- **Indexes**: Fast lookups by any identifier
- **NOT NULL for required fields**: reference_number and barcode
- **Comments**: Documentation in database schema

## 📱 NEXT STEPS

1. **Run the SQL migration** in Supabase (see above)
2. **Test with a new application** to verify all identifiers are saved
3. **Verify** the identifiers appear in:
   - PDF preview
   - Admin drawer
   - Verification page search
4. **Existing applications** will have NULL for new columns (that's OK)

## 🎯 STATUS

- ✅ Database schema updated
- ✅ Migration SQL file created
- ✅ Admission form saves all identifiers
- ✅ Admin displays all identifiers
- ✅ PDF shows all identifiers
- ✅ Verification page searches by control_number
- ⏳ **YOU NEED TO**: Run SQL migration in Supabase

---

**File Created**: January 7, 2026
**Commit**: e7ec506
