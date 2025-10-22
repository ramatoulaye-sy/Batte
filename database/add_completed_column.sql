-- =====================================================
-- CORRECTION RAPIDE - COLONNE "completed" MANQUANTE
-- =====================================================

-- Cette erreur se produit car la table user_education_progress existe déjà
-- mais sans la colonne 'completed' nécessaire pour l'application

-- 1. VÉRIFIER SI LA COLONNE EXISTE
-- =====================================================

SELECT 
    'Vérification colonne' as verification,
    column_name,
    data_type,
    is_nullable,
    CASE 
        WHEN column_name = 'completed' THEN '✅ Existe'
        ELSE '❌ Manquante'
    END as statut
FROM information_schema.columns 
WHERE table_name = 'user_education_progress'
AND column_name = 'completed';

-- 2. AJOUTER LA COLONNE SI ELLE N'EXISTE PAS
-- =====================================================

-- Ajouter la colonne 'completed' si elle n'existe pas
DO $$ 
BEGIN
    -- Vérifier si la colonne 'completed' existe déjà
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'user_education_progress' 
        AND column_name = 'completed'
    ) THEN
        -- Ajouter la colonne 'completed'
        ALTER TABLE user_education_progress 
        ADD COLUMN completed BOOLEAN DEFAULT FALSE;
        
        RAISE NOTICE 'Colonne "completed" ajoutée à la table user_education_progress';
    ELSE
        RAISE NOTICE 'Colonne "completed" existe déjà dans user_education_progress';
    END IF;
END $$;

-- 3. VÉRIFIER QUE LA COLONNE A ÉTÉ AJOUTÉE
-- =====================================================

SELECT 
    'Colonne ajoutée' as verification,
    column_name,
    data_type,
    is_nullable,
    column_default,
    '✅ Ajoutée' as statut
FROM information_schema.columns 
WHERE table_name = 'user_education_progress'
AND column_name = 'completed';

-- 4. VÉRIFIER LA STRUCTURE COMPLÈTE DE LA TABLE
-- =====================================================

SELECT 
    'Structure complète' as verification,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_education_progress'
ORDER BY ordinal_position;

-- 5. TEST RAPIDE (optionnel)
-- =====================================================

-- Test d'insertion avec la colonne 'completed'
-- Décommentez pour tester si vous avez un utilisateur test

/*
-- Test avec un utilisateur test (remplacez par un vrai UUID)
INSERT INTO user_education_progress (user_id, content_id, completed, progress_percentage)
VALUES ('test-user-123', 'test-content-1', TRUE, 100)
ON CONFLICT (user_id, content_id) DO UPDATE SET
    completed = EXCLUDED.completed,
    progress_percentage = EXCLUDED.progress_percentage,
    updated_at = NOW();

-- Vérifier l'insertion
SELECT 'Test insertion' as verification, user_id, content_id, completed, progress_percentage
FROM user_education_progress 
WHERE user_id = 'test-user-123';

-- Nettoyer le test
DELETE FROM user_education_progress WHERE user_id = 'test-user-123';
*/

-- =====================================================
-- EXPLICATION DE L'ERREUR
-- =====================================================

-- PROBLÈME :
-- La table user_education_progress existe déjà dans Supabase
-- mais elle n'a pas la colonne 'completed' nécessaire pour l'application
-- L'application essaie d'accéder à cette colonne et génère l'erreur

-- SOLUTION :
-- Ajouter la colonne 'completed' à la table existante
-- ALTER TABLE user_education_progress ADD COLUMN completed BOOLEAN DEFAULT FALSE;

-- =====================================================
-- INSTRUCTIONS
-- =====================================================

-- 1. Exécutez ce script dans Supabase SQL Editor
-- 2. Vérifiez que la colonne 'completed' est ajoutée
-- 3. Testez votre application Flutter
-- 4. L'erreur "column completed does not exist" devrait être corrigée

-- =====================================================
-- VÉRIFICATION POST-EXÉCUTION
-- =====================================================

-- Après l'exécution, vous devriez voir :
-- - "Colonne completed ajoutée à la table user_education_progress"
-- - La colonne 'completed' dans la structure de la table
-- - L'application Flutter fonctionne sans erreur
