-- =====================================================
-- SCRIPT ULTRA-SIMPLE - AJOUTER COLONNE "completed"
-- =====================================================

-- Ajouter la colonne 'completed' à la table user_education_progress
ALTER TABLE user_education_progress 
ADD COLUMN IF NOT EXISTS completed BOOLEAN DEFAULT FALSE;

-- Vérifier que la colonne a été ajoutée
SELECT 
    'Colonne ajoutée' as verification,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_education_progress'
AND column_name = 'completed';

-- =====================================================
-- INSTRUCTIONS
-- =====================================================

-- 1. Copiez et exécutez ce script dans Supabase SQL Editor
-- 2. Vérifiez que la colonne 'completed' est ajoutée
-- 3. Testez votre application Flutter
-- 4. L'erreur "column completed does not exist" sera corrigée

-- =====================================================
-- RÉSULTAT ATTENDU
-- =====================================================

-- Vous devriez voir :
-- - La colonne 'completed' ajoutée à la table
-- - Type: boolean
-- - Nullable: YES
-- - Default: false
-- - L'application Flutter fonctionne sans erreur
