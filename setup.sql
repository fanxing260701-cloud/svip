-- 在 Supabase SQL Editor 中运行一次
create table if not exists public.svip_store (
  id integer primary key check (id = 1),
  version bigint not null default 0,
  data jsonb not null default '{"users":{},"snapshots":{},"logs":[]}'::jsonb
);
insert into public.svip_store (id, version, data) values (1,0,'{"users":{},"snapshots":{},"logs":[]}'::jsonb)
on conflict (id) do nothing;
-- 禁止浏览器使用公开 anon key 访问；所有请求必须走 Netlify 服务器函数
alter table public.svip_store enable row level security;
revoke all on table public.svip_store from anon, authenticated;
-- 不创建任何 anon / authenticated RLS policy
