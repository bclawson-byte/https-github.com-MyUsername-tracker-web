-- Seed script for first internal launch.
-- Replace emails with real users before running.

insert into public.agencies (id, name)
values ('alphaomega', 'Alpha Omega Insurance Agency')
on conflict (id) do update
set name = excluded.name;

-- Optional: upsert membership rows once users exist in auth.users.
-- select id, email from auth.users;
--
-- insert into public.agency_memberships (agency_id, user_id, role)
-- values
--   ('alphaomega', 'OWNER_USER_UUID', 'owner'),
--   ('alphaomega', 'EDITOR_ONE_USER_UUID', 'editor'),
--   ('alphaomega', 'EDITOR_TWO_USER_UUID', 'editor')
-- on conflict (agency_id, user_id) do update
-- set role = excluded.role;
