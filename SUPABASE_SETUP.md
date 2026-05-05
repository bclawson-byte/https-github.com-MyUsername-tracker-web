# Supabase Setup (3-user internal launch)

This setup is for one agency (`alphaomega`) with 3 users (1 owner + 2 editors).

## 1) Create project and collect keys

From Supabase dashboard:

1. Create project(s): `tracker-staging` and `tracker-production`.
2. Copy:
   - Project URL
   - `anon` key
   - `service_role` key (keep private; server/script only)

## 2) Run SQL in order

Run these in the SQL editor:

1. `supabase/schema.sql`
2. `supabase/rls_policies.sql`
3. `supabase/seed_alphaomega.sql`

## 3) Configure auth

1. Enable Email auth provider.
2. Choose magic link or password sign-in.
3. Invite the two additional users from `Authentication -> Users`.
4. After they exist in `auth.users`, add memberships in `agency_memberships`:
   - You = `owner`
   - Two users = `editor`

## 4) App-side config

Set localStorage values in browser devtools before loading app:

```js
localStorage.setItem("tracker.supabase.url", "https://YOUR_PROJECT.supabase.co");
localStorage.setItem("tracker.supabase.anonKey", "YOUR_ANON_KEY");
localStorage.setItem("tracker.supabase.agencyId", "alphaomega");
```

Then reload the app.

## 5) Data migration

1. Export current tracker JSON snapshot (or use your Drive JSON payload).
2. Run:

```powershell
powershell -ExecutionPolicy Bypass -File "./scripts/migrate-tracker-json-to-supabase.ps1" `
  -SupabaseUrl "https://YOUR_PROJECT.supabase.co" `
  -ServiceRoleKey "YOUR_SERVICE_ROLE_KEY" `
  -AgencyId "alphaomega" `
  -JsonPath "C:\path\to\Client Followups Tracker.json"
```

## 6) Pilot checklist (3 users)

- All 3 users can log in.
- Owner/editor permissions behave correctly.
- Data changes persist across refresh.
- No unauthorized table access (RLS enforced).
