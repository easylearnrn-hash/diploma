<!-- cspell:disable -->

# ENROLLED STATUS FIX & VERIFICATION GUIDE

## Why this exists
Admin updates to `applications.status` were failing with `applications_status_check` constraint errors whenever "ENROLLED" (and other late-stage statuses) were selected from `admin-applications.html`. The database constraint still referenced the older status list, so Supabase rejected the update with error `23514`.

## What changed
1. **New migration (`ADD-ENROLLED-STATUS.sql`)**
   - Normalizes legacy `Pending Review` rows to `SUBMITTED`.
   - Sets the column default to `SUBMITTED` (matching the frontend).
   - Rebuilds `applications_status_check` with the complete, supported list:
     - `SUBMITTED`, `UNDER REVIEW`, `ACTIVELY REVIEWING`, `RFE PREPARING`, `RFE SENT`, `ADDITIONAL DOCUMENTS REQUESTED`, `DOCUMENTS RECEIVED`, `FINAL REVIEW`, `APPROVED`, `CONFIRMED`, `ACCEPTANCE LETTER SENT`, `ENROLLED`, `DENIED`, `ON HOLD`, `WITHDRAWN`.
2. **`supabase/schema.sql` alignment**
   - Applications table definition now includes the modern columns (status messaging, RFE metadata, uploaded documents, credentials screenshot, etc.).
   - Inline CHECK constraint mirrors the same status list so future deploys stay consistent.
   - Added indexes for `username`, `status`, `verification_hash`, `status_message`, and `uploaded_documents` to match production.

## How to apply the fix
1. Open the Supabase dashboard → SQL Editor → project `zlvnxvrzotamhpezqedr`.
2. Paste the contents of `ADD-ENROLLED-STATUS.sql` and run it (or upload the file directly).
3. Confirm the output shows the constraint definition with the expanded status list. The script already runs `SELECT conname, pg_get_constraintdef(...)` for you.

## How to verify
1. In the SQL editor (or psql), run:
   ```sql
   SELECT DISTINCT status FROM public.applications ORDER BY status;
   ```
   Ensure "ENROLLED" and "CONFIRMED" appear.
2. On `admin-applications.html`, pick an existing record, open the status drawer, select **ENROLLED**, add a status message, and click **Update Status & Notify**. The toast should succeed instead of throwing the previous 400/23514 error.
3. Optionally, log into `application-status.html` with that applicant's credentials to confirm the UI shows the new status and timeline update.

## Rollback plan
If necessary, rerun the previous constraint script (e.g., `ADD-RFE-TRACKING.sql`) to restore the old list, but be aware it will break ENROLLED updates again.

<!-- cspell:enable -->
