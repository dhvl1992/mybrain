-- Migration 002: separate lists + shopping store type
-- Run ONCE in Supabase → SQL Editor → New query → Run. Safe to run again.

-- 1. Lists table (one row per list, per user)
create table if not exists lists (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users on delete cascade,
  name        text not null,
  position    int  not null default 0,
  created_at  timestamptz not null default now(),
  unique (user_id, name)
);

grant select, insert, update, delete on lists to authenticated;
alter table lists enable row level security;
drop policy if exists "own lists" on lists;
create policy "own lists" on lists
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 2. Items get a list and (for shopping) a store type
alter table items add column if not exists list_id uuid references lists(id) on delete set null;
alter table items add column if not exists store text;

-- 3. Default lists for every existing user
insert into lists (user_id, name, position)
select u.id, d.name, d.pos
from auth.users u
cross join (values ('Inbox',0),('Office',1),('Home',2),('Shopping',3),('Research',4)) as d(name, pos)
on conflict (user_id, name) do nothing;

-- 4. Old items go to Inbox
update items i set list_id = l.id
from lists l
where i.list_id is null and l.user_id = i.user_id and l.name = 'Inbox';
