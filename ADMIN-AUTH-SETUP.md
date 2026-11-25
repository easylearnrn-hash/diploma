# Admin login security (admin-auth)

Admin accounts live in the `admin_users` table. The browser can no longer read or write that table: it is locked
(Row Level Security on, no access for `anon`/`authenticated`). All admin work goes through the `admin-auth` Edge Function.

## How it works
- `login.html` (and the other admin sign-in pages) call `AdminAuth.login()` from `js/admin-auth.js`.
- The function checks the password hash on the server and returns the profile (never `password_hash`) plus a signed token (12 h).
- The token is kept as `adminToken` in session/local storage and sent as `x-admin-token`. Pages that manage admins
  (`admin-users.html`, e-mail pages, `admin-home.html` directory) and the `render-pdf` function require it.
- A session opened before this update has no token: the pages that need it ask the admin to sign in again once.
- Failed logins are throttled (8 per account+IP and 40 per IP in 10 minutes).

## Supabase secrets
| Secret | Value |
|---|---|
| `ADMIN_TOKEN_SECRET` | long random string (signs tokens; shared by `admin-auth` and `render-pdf`) |
| `ADMIN_AUTH_ORIGINS` | `https://www.acnhs.am,https://acnhs.am` (add `http://localhost:8000,null` temporarily for local testing) |

## Deploy
```bash
supabase functions deploy admin-auth --project-ref eyhksbiceueoiamwnqpr
supabase functions deploy render-pdf --project-ref eyhksbiceueoiamwnqpr
```

## Lock / rollback
`supabase/lock-admin-users.sql` applies the lock; the rollback statements are at the bottom of that file
(run them with `supabase db query --linked "<sql>"` if something unexpected breaks).

## Not covered yet
Other tables (applications, teachers, ...) still have open anon policies and student/teacher password hashes are readable.
