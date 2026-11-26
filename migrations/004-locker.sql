-- Migration 004: Locker (encrypted passwords and secrets)
-- Run ONCE in Supabase → SQL Editor → New query → Run. Safe to run again.
--
-- Everything secret is encrypted IN THE BROWSER before it is sent here.
-- This database only ever sees scrambled text (base64). No plain passwords.

-- 1. One row per user: what the browser needs to rebuild the key from the locker password
--    salt  : random bytes mixed into the password (base64)
--    iters : how many PBKDF2 rounds (makes guessing slow)
--    check_iv / check_data : a known word encrypted with the key.
--                            If it decrypts, the locker password was right.
create table if not exists locker_meta (
  user_id     uuid primary key default auth.uid() references auth.users on delete cascade,
  salt        text not null,
  iters       int  not null,
  check_iv    text not null,
  check_data  text not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- 2. Locker items: each item is one encrypted blob (all its fields inside)
create table if not exists locker_items (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users on delete cascade,
  iv          text not null,
  data        text not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create index if not exists locker_items_user_idx on locker_items (user_id);

-- 3. Only you can see or change your own rows
grant select, insert, update, delete on locker_meta  to authenticated;
grant select, insert, update, delete on locker_items to authenticated;
alter table locker_meta  enable row level security;
alter table locker_items enable row level security;
drop policy if exists "own locker meta"  on locker_meta;
drop policy if exists "own locker items" on locker_items;
create policy "own locker meta" on locker_meta
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own locker items" on locker_items
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- 4. Keep updated_at correct on every edit
create or replace function locker_touch() returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;
drop trigger if exists locker_meta_touch  on locker_meta;
drop trigger if exists locker_items_touch on locker_items;
create trigger locker_meta_touch  before update on locker_meta  for each row execute function locker_touch();
create trigger locker_items_touch before update on locker_items for each row execute function locker_touch();
