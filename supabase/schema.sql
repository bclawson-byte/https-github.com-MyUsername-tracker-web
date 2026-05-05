-- Alpha Omega CRM - Supabase schema (single agency first, multi-agency ready)
-- Run in Supabase SQL editor.

create extension if not exists pgcrypto;

create table if not exists public.agencies (
  id text primary key,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id)
);

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  full_name text default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.agency_memberships (
  id uuid primary key default gen_random_uuid(),
  agency_id text not null references public.agencies(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('owner', 'editor', 'viewer')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (agency_id, user_id)
);

create table if not exists public.crm_clients (
  id uuid primary key default gen_random_uuid(),
  agency_id text not null references public.agencies(id) on delete cascade,
  sort_order integer not null default 0,
  client_name text not null default '',
  carrier text not null default '',
  premium text not null default '',
  savings text not null default '',
  date_sent text not null default '',
  status text not null default '',
  last_contact text not null default '',
  next_follow_up text not null default '',
  email text not null default '',
  phone text not null default '',
  quote_number text not null default '',
  renewal_date text not null default '',
  date_bound text not null default '',
  lead_source text not null default '',
  notes text not null default '',
  activity_log jsonb not null default '[]'::jsonb,
  client_docs jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id)
);

create index if not exists crm_clients_agency_sort_idx
  on public.crm_clients (agency_id, sort_order, updated_at);

create table if not exists public.crm_tasks (
  id text primary key,
  agency_id text not null references public.agencies(id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id)
);

create index if not exists crm_tasks_agency_sort_idx
  on public.crm_tasks (agency_id, sort_order, updated_at);

create table if not exists public.crm_proposals (
  id uuid primary key default gen_random_uuid(),
  agency_id text not null references public.agencies(id) on delete cascade,
  client_email text not null default '',
  client_name text not null default '',
  carrier text not null default '',
  premium text not null default '',
  savings text not null default '',
  sent_date text not null default '',
  proposal_status text not null default '',
  gmail_subject text not null default '',
  gmail_thread_id text not null default '',
  notes text not null default '',
  source_client_id uuid references public.crm_clients(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id)
);

create index if not exists crm_proposals_agency_sent_idx
  on public.crm_proposals (agency_id, sent_date, updated_at);

create table if not exists public.activity_log (
  id uuid primary key default gen_random_uuid(),
  agency_id text not null references public.agencies(id) on delete cascade,
  actor_user_id uuid references auth.users(id) on delete set null,
  entity_type text not null,
  entity_id text not null,
  action text not null,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists activity_log_agency_created_idx
  on public.activity_log (agency_id, created_at desc);

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_profiles_touch on public.profiles;
create trigger trg_profiles_touch before update on public.profiles
for each row execute function public.touch_updated_at();

drop trigger if exists trg_agencies_touch on public.agencies;
create trigger trg_agencies_touch before update on public.agencies
for each row execute function public.touch_updated_at();

drop trigger if exists trg_agency_memberships_touch on public.agency_memberships;
create trigger trg_agency_memberships_touch before update on public.agency_memberships
for each row execute function public.touch_updated_at();

drop trigger if exists trg_crm_clients_touch on public.crm_clients;
create trigger trg_crm_clients_touch before update on public.crm_clients
for each row execute function public.touch_updated_at();

drop trigger if exists trg_crm_tasks_touch on public.crm_tasks;
create trigger trg_crm_tasks_touch before update on public.crm_tasks
for each row execute function public.touch_updated_at();

drop trigger if exists trg_crm_proposals_touch on public.crm_proposals;
create trigger trg_crm_proposals_touch before update on public.crm_proposals
for each row execute function public.touch_updated_at();
