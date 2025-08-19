-- =====================================================
-- CONTRAINTE DE FORMAT SUR users.avatar_url
-- Empêche d'enregistrer une URL d'avatar qui n'est pas dans le bucket public 'avatars'
-- Deux versions: générique (regex) et spécifique (référence projet)
-- =====================================================

-- 1) Supprimer la contrainte si elle existe
alter table users drop constraint if exists users_avatar_url_format_chk;

-- 2-A) Version générique (accepte toute ref supabase)
alter table users
add constraint users_avatar_url_format_chk
check (
  avatar_url is null
  or avatar_url ~ '^https://[a-z0-9-]+\.supabase\.co/storage/v1/object/public/avatars/.+'
);

-- 2-B) Version spécifique au projet (décommentez et remplacez YOUR_PROJECT_REF)
-- alter table users
-- add constraint users_avatar_url_format_chk
-- check (
--   avatar_url is null
--   or avatar_url like 'https://YOUR_PROJECT_REF.supabase.co/storage/v1/object/public/avatars/%'
-- );

-- Astuce: si vous souhaitez un message d'erreur plus explicite, utilisez un trigger:
-- voir le fichier commentaire dans l'assistant précédemment pour ensure_avatar_url_public()

-- =====================================================
-- FIN
-- =====================================================

