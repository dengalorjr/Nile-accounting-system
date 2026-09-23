# Nile Accounting Online

This is the same accounting system you had (students, trainers, courses, enrollments,
payments, expenses, audit log, backup/restore) — now backed by a shared **Supabase**
(Postgres) database and hosted for free on **GitHub Pages**, so everyone on the team
can use it from any phone or computer with the same live data.

## What changed from the offline version

- Data now lives in Supabase instead of the browser's IndexedDB, so it's shared
  across everyone who opens the site (real online, multi-device).
- Login still works the same way (pick your username, enter your password) —
  nothing changes for day-to-day use.
- I removed some duplicate/leftover code from the old file and closed one small
  gap where a non-admin role could delete a student record without permission
  (delete buttons for students/trainers/expenses now consistently check the
  same role permission).
- Everything else — dashboard, receipts, Excel export per course, JSON backup/restore —
  works exactly as before, just against the shared database.

## Files in this folder

| File | Purpose |
|---|---|
| `index.html` | The app shell (loads Supabase's JS library, then `config.js`, then `app.js`) |
| `config.js` | **You edit this** — your Supabase project URL + anon key |
| `app.js` | All the app logic |
| `styles.css`, `theme.css`, `font.css` | Styling (unchanged) |
| `nile-logo.png`, `Alexandria-VariableFont_wght.ttf` | Logo + font (unchanged) |
| `schema.sql` | **You run this once** in Supabase to create the tables |

---

## Step 1 — Create your Supabase project

1. Go to **supabase.com/dashboard** and sign in (or create a free account).
2. Click **New project**. Pick an organization, give the project a name (e.g.
   `nile-accounting`), set a database password (save it somewhere safe — you
   won't need it for this app, but keep it), choose a region close to Egypt,
   and click **Create new project**. It takes a minute or two to spin up.

## Step 2 — Create the tables

1. In your new project, open **SQL Editor** in the left sidebar.
2. Click **New query**.
3. Open `schema.sql` from this folder, copy all of it, paste it into the editor.
4. Click **Run**. You should see "Success. No rows returned." All 9 tables
   (users, students, trainers, courses, enrollments, payments, expenses,
   audit_logs, settings) are now created, with security policies applied.

## Step 3 — Get your API keys

1. In the left sidebar, go to **Project Settings → API**.
2. Copy the **Project URL** (looks like `https://xxxxx.supabase.co`).
3. Copy the **anon / public** key (a long string starting with `eyJ...`). Do
   **not** copy the `service_role` key — that one must never go in client code.
4. Open `config.js` in this folder and paste them in:

```js
window.NILE_CONFIG = {
  SUPABASE_URL: 'https://xxxxx.supabase.co',
  SUPABASE_ANON_KEY: 'eyJ...'
};
```

## Step 4 — Put it on GitHub and turn on GitHub Pages

1. On GitHub, create a new repository (e.g. `nile-accounting`). It can be
   public or private — GitHub Pages works with either on a paid plan; on the
   free plan Pages sites are public, so if the login data shouldn't be
   publicly browsable, keep that in mind (the RLS security note below matters
   more than the repo visibility either way).
2. Upload every file in this folder to the repository (drag-and-drop on the
   GitHub website works, or `git add . && git commit -m "Nile Accounting online" && git push`
   if you're using the command line).
3. In the repository, go to **Settings → Pages**.
4. Under **Build and deployment → Source**, choose **Deploy from a branch**.
5. Under **Branch**, choose `main` (or your default branch) and folder `/ (root)`, then **Save**.
6. After a minute, GitHub shows you the live URL (something like
   `https://your-username.github.io/nile-accounting/`). That's the app.

## First login

- Username: **admin**, password: **admin123** (same as before).
- You'll be asked to change the password immediately — do that first thing.

## Security notes — please read before using this for real money

To keep "simple login" (no Supabase Auth), the app does its own login screen
in the browser and talks to Supabase with the public **anon key**. That key
is not a secret — it's visible to anyone who views the page source, since it
has to be, for the app to work at all in the browser.

The `schema.sql` policies grant that anon key full read/write access to every
table. In practice that means:

- The app's login screen is a UI gate, not a hard security boundary — someone
  who extracts the anon key from the page and calls the Supabase API directly
  could read or write data without logging in through the app.
- This is a known, inherent trade-off of doing custom username/password auth
  entirely in the browser against a publicly reachable database — it isn't a
  bug I can code around while keeping "simple" auth.

To reduce the risk in the meantime:

- Don't reuse this Supabase project or its keys for anything else.
- If the key ever leaks somewhere it shouldn't (e.g. committed with the wrong
  repo visibility, pasted in a chat), rotate it in **Project Settings → API**.
- Keep regular JSON backups (**Settings → تصدير نسخة احتياطية** in the app)
  in case data is ever tampered with.
- If this system starts handling significant amounts of money or sensitive
  student data, it's worth revisiting and switching to real Supabase Auth
  (email + password, with row-level security tied to logged-in users) —
  that's the standard, more secure pattern; I kept this version simple
  because that's what you asked for.

## Backup and restore

Unchanged: **Settings → تصدير نسخة احتياطية** downloads a JSON file with
everything. **استعادة النسخة** replaces all data in the shared database with
the contents of a backup file — so it now affects everyone, not just your
browser, so use it carefully and always export a fresh backup first.

## If something doesn't load

Open the page, right-click → **Inspect** → **Console** tab. If `config.js`
still has the placeholder URL/key, or if the values were mistyped, you'll see
a connection error there and on the login screen itself.
