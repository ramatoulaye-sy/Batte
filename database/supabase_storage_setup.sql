-- =====================================================
-- SUPABASE STORAGE SETUP: AVATARS BUCKET + RLS POLICIES
-- Run this in Supabase SQL Editor (or via migration) once per project
-- =====================================================

-- Create avatars bucket (public read)
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- Ensure RLS is enabled on storage.objects (usually enabled by default)
alter table if exists storage.objects enable row level security;

-- Clean up old policies if they exist
drop policy if exists "Public read for avatars" on storage.objects;
drop policy if exists "Authenticated insert to avatars" on storage.objects;
drop policy if exists "Update own avatar objects" on storage.objects;
drop policy if exists "Delete own avatar objects" on storage.objects;

-- Public read for all objects in avatars bucket
create policy "Public read for avatars"
on storage.objects for select
using (
  bucket_id = 'avatars'
);

-- Any authenticated user can insert into avatars bucket
create policy "Authenticated insert to avatars"
on storage.objects for insert
with check (
  bucket_id = 'avatars' and auth.role() = 'authenticated'
);

-- Only owner can update their own objects in avatars bucket
create policy "Update own avatar objects"
on storage.objects for update
using (
  bucket_id = 'avatars' and owner = auth.uid()
)
with check (
  bucket_id = 'avatars' and owner = auth.uid()
);

-- Only owner can delete their own objects in avatars bucket
create policy "Delete own avatar objects"
on storage.objects for delete
using (
  bucket_id = 'avatars' and owner = auth.uid()
);

-- Optional (stronger):
-- To restrict writes to a per-user folder like users/<uid>/..., replace the insert/update checks with:
--   (string_to_array(name, '/'))[1] = 'users'
--   and (string_to_array(name, '/'))[2] = auth.uid()::text
-- Then ensure your app writes to users/<uid>/...

-- =====================================================
-- END
-- =====================================================

