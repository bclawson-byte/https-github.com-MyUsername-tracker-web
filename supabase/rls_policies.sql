-- Alpha Omega CRM - RLS policies
-- Run after schema.sql.

alter table public.agencies enable row level security;
alter table public.profiles enable row level security;
alter table public.agency_memberships enable row level security;
alter table public.crm_clients enable row level security;
alter table public.crm_tasks enable row level security;
alter table public.crm_proposals enable row level security;
alter table public.activity_log enable row level security;

create or replace function public.current_user_agency_ids()
returns table(agency_id text)
language sql
stable
security definer
set search_path = public
as $$
  select m.agency_id
  from public.agency_memberships m
  where m.user_id = auth.uid();
$$;

revoke all on function public.current_user_agency_ids() from public;
grant execute on function public.current_user_agency_ids() to authenticated;

create or replace function public.current_user_role(target_agency_id text)
returns text
language sql
stable
security definer
set search_path = public
as $$
  select m.role
  from public.agency_memberships m
  where m.user_id = auth.uid()
    and m.agency_id = target_agency_id
  limit 1;
$$;

revoke all on function public.current_user_role(text) from public;
grant execute on function public.current_user_role(text) to authenticated;

drop policy if exists profiles_self_select on public.profiles;
create policy profiles_self_select on public.profiles
for select using (user_id = auth.uid());

drop policy if exists profiles_self_update on public.profiles;
create policy profiles_self_update on public.profiles
for update using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists memberships_select on public.agency_memberships;
create policy memberships_select on public.agency_memberships
for select using (
  agency_id in (select agency_id from public.current_user_agency_ids())
);

drop policy if exists agencies_select on public.agencies;
create policy agencies_select on public.agencies
for select using (
  id in (select agency_id from public.current_user_agency_ids())
);

drop policy if exists agencies_owner_update on public.agencies;
create policy agencies_owner_update on public.agencies
for update using (public.current_user_role(id) = 'owner')
with check (public.current_user_role(id) = 'owner');

drop policy if exists clients_read on public.crm_clients;
create policy clients_read on public.crm_clients
for select using (
  agency_id in (select agency_id from public.current_user_agency_ids())
);

drop policy if exists clients_write_owner_editor on public.crm_clients;
create policy clients_write_owner_editor on public.crm_clients
for all using (
  public.current_user_role(agency_id) in ('owner', 'editor')
)
with check (
  public.current_user_role(agency_id) in ('owner', 'editor')
);

drop policy if exists tasks_read on public.crm_tasks;
create policy tasks_read on public.crm_tasks
for select using (
  agency_id in (select agency_id from public.current_user_agency_ids())
);

drop policy if exists tasks_write_owner_editor on public.crm_tasks;
create policy tasks_write_owner_editor on public.crm_tasks
for all using (
  public.current_user_role(agency_id) in ('owner', 'editor')
)
with check (
  public.current_user_role(agency_id) in ('owner', 'editor')
);

drop policy if exists proposals_read on public.crm_proposals;
create policy proposals_read on public.crm_proposals
for select using (
  agency_id in (select agency_id from public.current_user_agency_ids())
);

drop policy if exists proposals_write_owner_editor on public.crm_proposals;
create policy proposals_write_owner_editor on public.crm_proposals
for all using (
  public.current_user_role(agency_id) in ('owner', 'editor')
)
with check (
  public.current_user_role(agency_id) in ('owner', 'editor')
);

drop policy if exists activity_read on public.activity_log;
create policy activity_read on public.activity_log
for select using (
  agency_id in (select agency_id from public.current_user_agency_ids())
);

drop policy if exists activity_write_owner_editor on public.activity_log;
create policy activity_write_owner_editor on public.activity_log
for all using (
  public.current_user_role(agency_id) in ('owner', 'editor')
)
with check (
  public.current_user_role(agency_id) in ('owner', 'editor')
);
