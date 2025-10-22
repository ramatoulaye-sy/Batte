-- =====================================================
-- SCRIPT DE VÉRIFICATION POST-CORRECTION SUPABASE
-- =====================================================

-- 1. VÉRIFIER QUE LES TABLES EXISTENT
-- =====================================================
SELECT 
    'Tables existantes' as verification,
    table_name,
    '✅ Existe' as statut
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('waste_transactions', 'user_education_progress')
ORDER BY table_name;

-- 2. VÉRIFIER QUE LA COLONNE 'completed' EXISTE
-- =====================================================
SELECT 
    'Colonnes user_education_progress' as verification,
    column_name,
    data_type,
    is_nullable,
    '✅ Existe' as statut
FROM information_schema.columns 
WHERE table_name = 'user_education_progress'
ORDER BY ordinal_position;

-- 3. VÉRIFIER LES POLITIQUES RLS POUR waste_transactions
-- =====================================================
SELECT 
    'Politiques RLS waste_transactions' as verification,
    policyname,
    cmd as operation,
    '✅ Active' as statut
FROM pg_policies 
WHERE tablename = 'waste_transactions'
ORDER BY policyname;

-- 4. VÉRIFIER LES POLITIQUES RLS POUR user_education_progress
-- =====================================================
SELECT 
    'Politiques RLS user_education_progress' as verification,
    policyname,
    cmd as operation,
    '✅ Active' as statut
FROM pg_policies 
WHERE tablename = 'user_education_progress'
ORDER BY policyname;

-- 5. VÉRIFIER LES INDEX
-- =====================================================
SELECT 
    'Index créés' as verification,
    indexname,
    tablename,
    '✅ Optimisé' as statut
FROM pg_indexes 
WHERE tablename IN ('waste_transactions', 'user_education_progress')
AND schemaname = 'public'
ORDER BY tablename, indexname;

-- 6. VÉRIFIER LES TRIGGERS
-- =====================================================
SELECT 
    'Triggers actifs' as verification,
    trigger_name,
    event_object_table as table_name,
    '✅ Fonctionnel' as statut
FROM information_schema.triggers 
WHERE event_object_table IN ('waste_transactions', 'user_education_progress')
AND trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

-- 7. VÉRIFIER LES VUES CRÉÉES
-- =====================================================
SELECT 
    'Vues créées' as verification,
    table_name as view_name,
    '✅ Disponible' as statut
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'VIEW'
AND table_name IN ('user_waste_stats', 'user_education_stats')
ORDER BY table_name;

-- 8. TEST DE FONCTIONNEMENT (optionnel)
-- =====================================================

-- Test d'insertion dans waste_transactions (avec un utilisateur test)
-- Décommentez pour tester si vous avez un utilisateur test

/*
-- Créer un utilisateur test temporaire
INSERT INTO auth.users (id, email, created_at, updated_at)
VALUES ('test-user-123', 'test@example.com', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Test d'insertion dans waste_transactions
INSERT INTO waste_transactions (user_id, amount, type, description, status)
VALUES ('test-user-123', 1000.00, 'recycling', 'Test insertion', 'completed');

-- Test d'insertion dans user_education_progress
INSERT INTO user_education_progress (user_id, content_id, completed, progress_percentage)
VALUES ('test-user-123', 'test-content-1', TRUE, 100);

-- Vérifier les insertions
SELECT 'Test waste_transactions' as test, COUNT(*) as count FROM waste_transactions WHERE user_id = 'test-user-123';
SELECT 'Test user_education_progress' as test, COUNT(*) as count FROM user_education_progress WHERE user_id = 'test-user-123';

-- Nettoyer les données de test
DELETE FROM waste_transactions WHERE user_id = 'test-user-123';
DELETE FROM user_education_progress WHERE user_id = 'test-user-123';
DELETE FROM auth.users WHERE id = 'test-user-123';
*/

-- =====================================================
-- RÉSUMÉ DE VÉRIFICATION
-- =====================================================

-- Compter les éléments créés
SELECT 
    'RÉSUMÉ FINAL' as verification,
    'Tables' as element,
    COUNT(*) as nombre,
    CASE WHEN COUNT(*) = 2 THEN '✅ OK' ELSE '❌ MANQUANT' END as statut
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('waste_transactions', 'user_education_progress')

UNION ALL

SELECT 
    'RÉSUMÉ FINAL',
    'Politiques RLS',
    COUNT(*),
    CASE WHEN COUNT(*) >= 4 THEN '✅ OK' ELSE '❌ MANQUANT' END
FROM pg_policies 
WHERE tablename IN ('waste_transactions', 'user_education_progress')

UNION ALL

SELECT 
    'RÉSUMÉ FINAL',
    'Index',
    COUNT(*),
    CASE WHEN COUNT(*) >= 6 THEN '✅ OK' ELSE '❌ MANQUANT' END
FROM pg_indexes 
WHERE tablename IN ('waste_transactions', 'user_education_progress')
AND schemaname = 'public'

UNION ALL

SELECT 
    'RÉSUMÉ FINAL',
    'Triggers',
    COUNT(*),
    CASE WHEN COUNT(*) >= 2 THEN '✅ OK' ELSE '❌ MANQUANT' END
FROM information_schema.triggers 
WHERE event_object_table IN ('waste_transactions', 'user_education_progress')
AND trigger_schema = 'public'

UNION ALL

SELECT 
    'RÉSUMÉ FINAL',
    'Vues',
    COUNT(*),
    CASE WHEN COUNT(*) = 2 THEN '✅ OK' ELSE '❌ MANQUANT' END
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'VIEW'
AND table_name IN ('user_waste_stats', 'user_education_stats');

-- =====================================================
-- INSTRUCTIONS D'UTILISATION
-- =====================================================

-- 1. Exécutez ce script après avoir exécuté fix_supabase_errors.sql
-- 2. Vérifiez que tous les éléments montrent "✅ OK"
-- 3. Si vous voyez "❌ MANQUANT", relancez le script de correction
-- 4. Une fois tout "✅ OK", votre application fonctionnera parfaitement
