-- 家計簿のデータを入れる表を作ります（Supabase の SQL Editor に貼り付けて「Run」）
create table if not exists public.kb_docs (
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  col        text not null,
  id         text not null,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, col, id)
);

-- 本人のデータだけを読み書きできるようにする
alter table public.kb_docs enable row level security;
create policy "kb_select_own" on public.kb_docs for select to authenticated using (auth.uid() = user_id);
create policy "kb_insert_own" on public.kb_docs for insert to authenticated with check (auth.uid() = user_id);
create policy "kb_update_own" on public.kb_docs for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "kb_delete_own" on public.kb_docs for delete to authenticated using (auth.uid() = user_id);

-- PC とスマホのあいだで、変更がすぐ反映されるようにする
alter publication supabase_realtime add table public.kb_docs;
