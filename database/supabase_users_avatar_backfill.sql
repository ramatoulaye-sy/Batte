-- =====================================================
-- BACKFILL DES AVATARS UTILISATEURS
-- Remplit users.avatar_url à partir des objets du bucket 'avatars'
-- Hypothèse: les fichiers sont uploadés avec owner = auth.uid()
-- Optionnel: si vous utilisez la convention users/<uid>/..., activez le filtre indiqué
-- =====================================================

-- 1) Nettoyer les URLs invalides (gardez seulement les URLs publiques du bucket avatars)
update users
set avatar_url = null
where avatar_url is not null
  and avatar_url !~ '^https://[a-z0-9-]+\.supabase\.co/storage/v1/object/public/avatars/.+';

-- 2) Sélectionner le dernier objet (plus récent) par owner
with latest as (
  select distinct on (owner)
         owner, name, created_at
  from storage.objects
  where bucket_id = 'avatars'
  order by owner, created_at desc
)
update users u
set avatar_url = 'https://' || (
    select split_part(current_setting('app.settings.supabase_ref', true), ':', 1)
  ) || '.supabase.co/storage/v1/object/public/avatars/' || l.name
from latest l
where l.owner::text = u.id::text
  and (u.avatar_url is null or u.avatar_url = '');

-- NOTE IMPORTANTE:
-- La ligne ci-dessus construit l'URL publique avec une variable de session optionnelle
-- app.settings.supabase_ref. Si vous ne l'utilisez pas, remplacez par votre ref projet:
--   'https://YOUR_PROJECT_REF.supabase.co/storage/v1/object/public/avatars/' || l.name
-- Vous pouvez définir temporairement la variable pour la session:
--   select set_config('app.settings.supabase_ref', 'YOUR_PROJECT_REF', false);

-- 3) (Optionnel) Restreindre par convention users/<uid>/...
-- Ajoutez à la clause WHERE ci-dessus:
--   and l.name like ('users/' || u.id || '/%')

-- =====================================================
-- FIN
-- =====================================================

