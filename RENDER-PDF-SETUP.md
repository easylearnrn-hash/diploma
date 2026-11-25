# Cloud PDF rendering (Supabase Edge Function + Browserless)

PDF previews, PDF exports and Word exports are rendered in the cloud, so nothing depends on `localhost:8001` or on
running `pdf-server.js` any more.

```
documents.html  ──►  js/pdf-render.js  ──►  Supabase Edge Function `render-pdf`  ──►  Browserless (cloud Chromium)
   (editing and live pagination stay 100% in the browser and never call this)
```

* **Editing, live page cuts, undo, Live preview**: client side only, instant.
* **"Pages" preview, PDF button**: the same print HTML is rendered by Browserless; the returned PDF is shown with pdf.js / downloaded.
* **Word button**: built in the browser from that same PDF (one full-page image per page).
* The Browserless token only exists as a Supabase secret. It is never sent to, or stored in, any page or script.

## One-time setup (run on your own computer, in this folder)

The Supabase CLI on the development machine used for this work is logged into a *different* project, so deploy with
your own account and the explicit project ref below.

```bash
supabase login                                   # your account that owns project eyhksbiceueoiamwnqpr

# 1. Secrets (the token is read from your Browserless dashboard: https://browserless.io/account/)
supabase secrets set BROWSERLESS_TOKEN=PASTE_TOKEN_HERE --project-ref eyhksbiceueoiamwnqpr
supabase secrets set BROWSERLESS_URL=https://production-ams.browserless.io --project-ref eyhksbiceueoiamwnqpr   # your Browserless region

# 2. Deploy
supabase functions deploy render-pdf --project-ref eyhksbiceueoiamwnqpr
```

| Secret | Required | Default | Meaning |
|---|---|---|---|
| `BROWSERLESS_TOKEN` | yes | – | Browserless API token |
| `BROWSERLESS_URL` | no | `https://production-ams.browserless.io` | Browserless region endpoint (`production-sfo`, `production-lon`, `production-ams`) |
| `SITE_ORIGIN` | no | `https://www.acnhs.am` | Where `/assets/fonts` is fetched from while rendering |
| `ALLOWED_ORIGINS` | no | site + `acnhs.am` + localhost + `null` (file://) | Comma list of origins allowed to call the function. Set it to only `https://www.acnhs.am,https://acnhs.am` once testing is done |
| `RENDER_RATE_PER_MINUTE` | no | `20` | Per-admin limit |

`SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are provided by Supabase automatically (used only to check the admin).

## Test it before merging

1. Open `documents.html` locally (`python3 start-server.py`, or the file directly).
2. In the browser console force cloud-only (no silent local fallback):
   `localStorage.setItem('acnhs-render-backend', 'cloud')`
3. Press **PDF** and **Word**, and open the **Pages** preview. Compare with a PDF made the old way
   (`localStorage.setItem('acnhs-render-backend', 'local')` + `node pdf-server.js`): page count, text and layout should match.
4. Check logs if something fails: `supabase functions logs render-pdf --project-ref eyhksbiceueoiamwnqpr`

Error messages are shown in the page: *not set up yet* (secret/function missing), *sign in again* (admin session),
*busy / too many requests* (throttle), *took too long*.

## Security notes

* Only an **active admin** can render: the page sends the logged-in admin's id (`x-admin-id`), and the function checks it
  against `admin_users` (status `active`) with the service role. Other origins are refused (CORS + Origin check).
* The document must be plain print HTML: `<script>`, `<iframe>`, `<object>`, `<embed>`, `<form>`, inline `on…=` handlers and
  `javascript:` URLs are rejected, and Browserless is told to block every network request except your own site, `data:` and `about:`.
* Size cap 8 MB, 110 s time limit, per-admin rate limit.
* **Known weakness (pre-existing, not new):** the admin login is a custom `admin_users` table, not Supabase Auth, and that
  table is readable with the public anon key (the login page reads `password_hash` from it). The admin-id check is therefore a
  barrier against random abuse, not strong authentication. Moving admin login to Supabase Auth would let the function verify a
  real signed-in user.

## Verified against the real Browserless

Tested on `production-sfo` with a 4-page Armenian/English document: same page count and identical text on every page as the old local
export; Pages preview, PDF and Word all work. Known, harmless differences from a local Playwright export:
the cloud Chromium is newer (page height differs by about 1 pt), and the footer's Latin text uses Liberation Sans, the metric-compatible
stand-in for Arial on Linux. The Armenian page label «Էջ» in the footer is drawn as vector outlines of Noto Sans Armenian so it never
depends on font loading.

## Cost and behaviour to know

* Every Pages-preview refresh and every export is one Browserless render (the browser time counts against your plan). The
  preview waits for **2.5 s without typing** before rendering; switch to **Live** to stop previews entirely.
* The live page cuts inside the editors are measured by the browser you are using; the PDF is always made by the same cloud
  Chromium, so exports look identical on every device.
* Fonts and the stylesheet are fetched from `https://www.acnhs.am/assets/fonts`. If you add or change fonts, deploy the site before exporting.

## Local development without the cloud

`pdf-server.js` still works. On a developer machine (file:// or localhost) the page falls back to it automatically when the
cloud function is missing or unreachable. On the live site there is **no** fallback.
`localStorage.setItem('acnhs-render-backend', 'cloud' | 'local' | 'auto')` selects the behaviour (default `auto`).

## Going back (revert)

Nothing on `main` was changed by this work. The code lives on branch `cloud-rendering`; the last good state before it is the tag `pre-cloud-rendering`.

```bash
git checkout main                        # back to the old behaviour (local pdf-server.js); main is untouched until you merge
# If it was already merged into main and you want it out again, undo the merge without rewriting history:
git revert -m 1 <merge-commit-sha>
# (or inspect the old state any time:  git checkout pre-cloud-rendering)
supabase functions delete render-pdf --project-ref eyhksbiceueoiamwnqpr    # remove the function
supabase secrets unset BROWSERLESS_TOKEN --project-ref eyhksbiceueoiamwnqpr
```
