-- Run once in Supabase → SQL Editor → New query → Run

create table if not exists items (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users on delete cascade,
  kind        text not null check (kind in ('todo', 'note')),
  title       text not null,
  body        text not null default '',
  tags        text[] not null default '{}',
  due         date,
  priority    smallint not null default 2 check (priority between 1 and 3),
  done        boolean not null default false,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists items_user_created on items (user_id, created_at desc);

-- Explicit API access (needed when "Automatically expose new tables" is OFF)
-- authenticated = you, logged in. anon = keep-alive ping only (RLS returns 0 rows to it).
grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on items to authenticated;
grant select on items to anon;

-- Privacy lock: each user sees only their own rows
alter table items enable row level security;

drop policy if exists "own rows" on items;
create policy "own rows" on items
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
