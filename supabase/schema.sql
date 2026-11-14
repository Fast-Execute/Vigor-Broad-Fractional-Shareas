-- Vigor Broad Supabase catalog bootstrap
-- Apply only after a dedicated Vigor Supabase project has been provisioned.
-- Investment orders, investor identity data, and payments are intentionally out of scope.

create table public.investment_sectors (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  name text not null,
  description text,
  display_order integer not null default 0,
  is_active boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.investment_developments (
  id uuid primary key default gen_random_uuid(),
  sector_id uuid not null references public.investment_sectors(id) on delete restrict,
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  name text not null,
  summary text not null,
  description text,
  country_code char(2) not null default 'ZA' check (country_code = 'ZA'),
  province text,
  status text not null default 'draft'
    check (status in ('draft', 'review', 'published', 'paused', 'closed', 'archived')),
  currency char(3) not null default 'ZAR' check (currency = 'ZAR'),
  target_amount numeric(14,2) check (target_amount is null or target_amount >= 0),
  amount_raised numeric(14,2) check (amount_raised is null or amount_raised >= 0),
  risk_summary text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index investment_developments_sector_status_idx
  on public.investment_developments (sector_id, status);

alter table public.investment_sectors enable row level security;
alter table public.investment_developments enable row level security;

grant select on public.investment_sectors to anon, authenticated;
grant select on public.investment_developments to anon, authenticated;

create policy "Public can read active sectors"
  on public.investment_sectors
  for select
  to anon, authenticated
  using (is_active);

create policy "Public can read published developments"
  on public.investment_developments
  for select
  to anon, authenticated
  using (status = 'published');

-- No client write policies or grants are created. Publish and funding updates
-- must come from a trusted server workflow after the project is reviewed.
