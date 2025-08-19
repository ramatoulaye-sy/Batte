-- Script pour activer l'authentification par téléphone dans Supabase
-- À exécuter dans l'éditeur SQL de Supabase

-- 1. Activer le provider de téléphone
UPDATE auth.config 
SET phone_provider_enabled = true 
WHERE id = 1;

-- 2. Configurer les paramètres SMS (si vous utilisez un service SMS)
-- Note: Par défaut, Supabase utilise un service de test pour le développement

-- 3. Vérifier que la configuration est active
SELECT 
  phone_provider_enabled,
  phone_provider_config
FROM auth.config;

-- 4. Si vous voulez utiliser un vrai service SMS (optionnel)
-- UPDATE auth.config 
-- SET phone_provider_config = '{"provider": "twilio", "account_sid": "votre_sid", "auth_token": "votre_token"}'
-- WHERE id = 1;

-- 5. Vérifier les politiques RLS pour les utilisateurs
SELECT * FROM pg_policies WHERE tablename = 'users';

-- 6. S'assurer que les utilisateurs peuvent s'inscrire
-- Cette politique devrait déjà exister si vous avez exécuté le schéma principal
