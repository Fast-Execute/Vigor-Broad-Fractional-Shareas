-- Vigor Broad Supabase catalog bootstrap
-- Applied to the dedicated VigorBroad Supabase project; source reference for the catalog schema.
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

-- Public clients can read active sectors and published developments only.
-- Authenticated writes require the protected app_metadata admin claim shown below.

-- Seed the sector taxonomy; no development is published or presented as a verified offer.
insert into public.investment_sectors (slug, name, description, display_order, is_active) values
('bootcamp', 'Bootcamp', 'Technology and career training concepts.', 1, true),
('education', 'Education', 'Learning spaces and education access concepts.', 2, true),
('healthcare', 'Healthcare', 'Community health and wellness concepts.', 3, true),
('factory', 'Factory', 'Local manufacturing and production concepts.', 4, true),
('real-estate', 'Real Estate', 'Housing and mixed-use development concepts.', 5, true),
('innovation', 'Innovation', 'Technology and new venture concepts.', 6, true),
('agriculture', 'Agriculture', 'Sustainable farming and food-system concepts.', 7, true)
on conflict (slug) do update
set name = excluded.name,
    description = excluded.description,
    display_order = excluded.display_order,
    is_active = excluded.is_active;

-- Agriculture concept records remain drafts until reviewed; no amounts or returns are asserted.
insert into public.investment_developments (sector_id, slug, name, summary, status)
select s.id, v.slug, v.name, v.summary, 'draft'
from public.investment_sectors s
cross join (values
 ('smallholder-irrigation-cooperative','Smallholder irrigation cooperative','Shared drip-irrigation infrastructure designed to help small farms use water more efficiently through dry seasons.'),
 ('regenerative-grain-farming','Regenerative grain farming','A concept for crop rotation, cover crops and reduced tillage that aims to restore soil structure while maintaining local grain supply.'),
 ('fresh-produce-cold-chain-hub','Fresh-produce cold-chain hub','Pre-cooling, packing and refrigerated aggregation intended to reduce post-harvest losses and connect growers to regional buyers.'),
 ('solar-powered-farm-microgrid','Solar-powered farm microgrid','A farm-scale energy concept pairing solar generation with storage for irrigation pumps, packhouses and essential equipment.'),
 ('citrus-orchard-renewal','Citrus orchard renewal','Replanting and water-efficient management for a mixed citrus orchard, with a focus on local packing and market access.'),
 ('climate-smart-greenhouse-cluster','Climate-smart greenhouse cluster','Modular protected growing space for vegetables and seedlings, with efficient irrigation and shared technical support.'),
 ('community-grain-storage-network','Community grain storage network','Small silos and moisture-controlled storage that could help farming groups preserve harvest quality and time sales.'),
 ('farm-equipment-sharing-service','Farm equipment-sharing service','A cooperative model for booking tractors and implements, helping smaller producers access machinery without owning every tool.'),
 ('local-fruit-processing-workshop','Local fruit-processing workshop','A small-scale facility concept for sorting, drying or pulping surplus fruit to support local processing and reduce waste.'),
 ('sustainable-aquaculture-pilot','Sustainable aquaculture pilot','A monitored freshwater fish-farming concept designed around responsible water use, local feed sourcing and nearby demand.')
) as v(slug, name, summary)
where s.slug = 'agriculture'
on conflict (slug) do nothing;

-- Admin writes require an Auth JWT app_metadata claim set by a trusted project owner.
grant insert, update, delete on public.investment_sectors to authenticated;
grant insert, update, delete on public.investment_developments to authenticated;

create policy "Administrators manage investment sectors"
  on public.investment_sectors
  for all
  to authenticated
  using (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'admin')
  with check (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'admin');

create policy "Administrators manage investment developments"
  on public.investment_developments
  for all
  to authenticated
  using (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'admin')
  with check (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'admin');

-- Private admin audit trail; the security-invoker view applies the table's RLS policy.
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to authenticated;

create table private.investment_development_audit (
  id bigint generated always as identity primary key,
  development_id uuid not null,
  event_type text not null check (event_type in ('insert', 'update', 'delete')),
  actor_id uuid references auth.users(id) on delete set null,
  old_record jsonb,
  new_record jsonb,
  created_at timestamptz not null default now()
);
create index investment_development_audit_created_at_idx
  on private.investment_development_audit (created_at desc);
alter table private.investment_development_audit enable row level security;
grant select on private.investment_development_audit to authenticated;
create policy "Administrators can read development audit"
  on private.investment_development_audit
  for select to authenticated
  using (((select auth.jwt()) -> 'app_metadata' ->> 'role') = 'admin');

create or replace function private.log_investment_development_change()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare
  claim_role text;
  previous_value jsonb;
  next_value jsonb;
  changed_id uuid;
  action_name text;
begin
  claim_role := coalesce(((select auth.jwt()) -> 'app_metadata' ->> 'role'), '');
  if claim_role <> 'admin'
     and coalesce(((select auth.jwt()) ->> 'role'), '') <> 'service_role'
     and session_user not in ('postgres', 'supabase_admin') then
    raise exception 'Authorized database role required to record development changes';
  end if;
  if tg_op = 'INSERT' then
    previous_value := null; next_value := to_jsonb(new); changed_id := new.id; action_name := 'insert';
  elsif tg_op = 'UPDATE' then
    previous_value := to_jsonb(old); next_value := to_jsonb(new); changed_id := new.id; action_name := 'update';
  else
    previous_value := to_jsonb(old); next_value := null; changed_id := old.id; action_name := 'delete';
  end if;
  insert into private.investment_development_audit (development_id,event_type,actor_id,old_record,new_record)
  values (changed_id,action_name,(select auth.uid()),previous_value,next_value);
  if tg_op = 'DELETE' then return old; end if;
  return new;
end;
$$;
revoke all on function private.log_investment_development_change() from public, anon, authenticated;
grant execute on function private.log_investment_development_change() to authenticated, service_role;
drop trigger if exists investment_development_audit_trigger on public.investment_developments;
create trigger investment_development_audit_trigger
after insert or update or delete on public.investment_developments
for each row execute function private.log_investment_development_change();

create or replace view public.investment_development_audit with (security_invoker = true) as
select id,development_id,event_type,actor_id,old_record,new_record,created_at
from private.investment_development_audit;
grant select on public.investment_development_audit to authenticated;
