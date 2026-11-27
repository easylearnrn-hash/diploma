# Student / teacher password security (portal-auth)

Student, applicant and teacher passwords are no longer readable with the public (anon) key.

## What changed
- **`portal-auth` Edge Function** checks passwords on the server: `student-verify`, `student-change-password`, `teacher-verify`.
  Pages call it through `js/portal-auth.js` (`PortalAuth.verifyStudent / changeStudentPassword / verifyTeacher`).
  Failed attempts are throttled (8 per account+IP and 60 per IP in 10 minutes).
- **`admin-auth`** got three admin-only actions (signed admin token required): `student-credentials-get`,
  `student-credentials-set`, `teacher-set-password` (`AdminAuth.studentCredentials.get/set`, `AdminAuth.teachers.setPassword`).
- **`application_secrets` table** (RLS on, no access for `anon`/`authenticated`) holds each application's password hash, plain-text
  password (admins view/e-mail it), the "latest credentials" password and every other password that used to sit inside
  `applications.payload`. `applications.password_hash` / `plain_password` and those payload keys are now always empty.
- **Triggers on `applications`** move any secret a browser writes (admission form, old pages) into `application_secrets`
  and blank it in the row. A browser can set secrets only when it INSERTS a new application; an UPDATE that tries to
  change a password is ignored, so nobody can take over an account by writing to the table.
- **`teachers.password_hash`** is invisible and read-only for browsers (column privileges). Pages must list columns
  explicitly (`select('*')` and `insert(...).select()` on `teachers` are denied). Legacy plain-text teacher passwords are
  re-saved as PBKDF2 hashes the first time the teacher signs in.
- The student-viewer test account (`test@acnhs.am`) is verified by `admin-auth` (`viewer-login`) against the Supabase secrets
  `STUDENT_VIEWER_EMAIL` and `STUDENT_VIEWER_PASSWORD_HASH`.

## Files
- `supabase/portal-auth-step1-private-passwords.sql` — additive: secrets table, helper functions, backfill (safe to re-run)
- `supabase/portal-auth-step2-lock.sql` — attaches the triggers, blanks existing rows, locks `teachers.password_hash`
- `supabase/portal-auth-rollback.sql` — puts everything back and re-opens the columns

## Deploy / roll back
```bash
supabase functions deploy portal-auth --project-ref eyhksbiceueoiamwnqpr
supabase functions deploy admin-auth  --project-ref eyhksbiceueoiamwnqpr
supabase db query --linked -f supabase/portal-auth-step1-private-passwords.sql
# publish the pages, wait ~15 minutes for browser caches, then:
supabase db query --linked -f supabase/portal-auth-step2-lock.sql
# rollback: supabase db query --linked -f supabase/portal-auth-rollback.sql
```
Secret `PORTAL_AUTH_ORIGINS` (comma list, default: the site + local dev origins) should be set to
`https://www.acnhs.am,https://acnhs.am` in production.

## Still open
- Student/applicant personal data in `applications` (names, documents, ...) and ~45 other tables remain readable/writable
  with the public key. They need the same treatment (tokens per student/admin) as a separate project.
- Passwords are still unsalted SHA-256 in `application_secrets` (same value the pages always sent) and the default password
  `Welcome2026!` is assigned to every enrolled student.

## Salted, slow password storage and the forced first change
- **Stored form:** `p2:<iterations>:<salt>:<PBKDF2-SHA256>` (210,000 rounds, random 16-byte salt) computed over the SHA-256 value the pages send, so
  nothing the pages do had to change. Admins (`admin_users.password_hash`), students (`application_secrets.password_hash`) and teachers
  (`teachers.password_hash`, computed over the plain password they send) all use it. Old bare SHA-256 values still work and are replaced the
  first time the owner signs in; `rehash-passwords` (admin action, repeat until `remaining` is 0) converts the ones the server can verify
  against the plain text it holds.
- **Default password:** `Welcome<current year>!` (computed in `admin-applications.html`). Setting a default or an admin-set password sends
  `mustChange: true`; the `application_secrets.must_change` flag makes `student-verify` answer `mustChange: true` and withhold the session token.
  The login pages then show the "Create your new password" window (`PortalAuth.promptNewPassword`); `student-change-password` stores the new
  password salted and slow, does **not** keep its plain text, clears the flag and returns the token. The new password may not look like the default
  (`Welcome<year>!`) or equal the old one.
- **Not covered:** an admin whose stored hash is bcrypt (`$2a$...`, e.g. `hrach@acnhs.am`) cannot sign in until another admin sets a new
  password for them in User Management (it is then stored salted and slow). Students who chose their own password before this change still have
  their old plain text saved; it is removed when they next change their password.
