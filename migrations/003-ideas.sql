-- Migration 003: Ideas (a third kind next to tasks and notes)
-- Run ONCE in Supabase → SQL Editor → New query → Run. Safe to run again.

-- 1. Allow kind = 'idea'
alter table items drop constraint if exists items_kind_check;
alter table items add constraint items_kind_check check (kind in ('todo', 'note', 'idea'));

-- 2. Triage fields for ideas (ignored for tasks and notes)
--    status: new → exploring → doing, or parked
--    impact / effort: 1 low · 2 medium · 3 high. Empty = not rated yet.
alter table items add column if not exists status text not null default 'new';
alter table items drop constraint if exists items_status_check;
alter table items add constraint items_status_check check (status in ('new', 'exploring', 'doing', 'parked'));
alter table items add column if not exists impact smallint check (impact between 1 and 3);
alter table items add column if not exists effort smallint check (effort between 1 and 3);
