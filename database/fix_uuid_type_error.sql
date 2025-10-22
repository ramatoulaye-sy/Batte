-- =====================================================
-- CORRECTION RAPIDE - ERREUR TYPE UUID/TEXT
-- =====================================================

-- Cette erreur se produit car auth.uid() retourne un UUID
-- mais user_id est stocké comme TEXT dans nos tables
-- Solution : Convertir user_id en UUID pour la comparaison

-- 1. CORRIGER LES POLITIQUES RLS EXISTANTES
-- =====================================================

-- Supprimer les politiques existantes qui causent l'erreur
DROP POLICY IF EXISTS "Users can insert their own waste transactions" ON waste_transactions;
DROP POLICY IF EXISTS "Users can view their own waste transactions" ON waste_transactions;
DROP POLICY IF EXISTS "Users can update their own waste transactions" ON waste_transactions;
DROP POLICY IF EXISTS "Users can manage their own education progress" ON user_education_progress;

-- Recréer les politiques avec la bonne conversion de type
CREATE POLICY "Users can insert their own waste transactions" 
ON waste_transactions 
FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id::uuid);

CREATE POLICY "Users can view their own waste transactions" 
ON waste_transactions 
FOR SELECT 
TO authenticated 
USING (auth.uid() = user_id::uuid);

CREATE POLICY "Users can update their own waste transactions" 
ON waste_transactions 
FOR UPDATE 
TO authenticated 
USING (auth.uid() = user_id::uuid)
WITH CHECK (auth.uid() = user_id::uuid);

CREATE POLICY "Users can manage their own education progress" 
ON user_education_progress 
FOR ALL 
TO authenticated 
USING (auth.uid() = user_id::uuid)
WITH CHECK (auth.uid() = user_id::uuid);

-- 2. VÉRIFIER QUE LES POLITIQUES SONT CRÉÉES
-- =====================================================

SELECT 
    'Politiques RLS créées' as verification,
    tablename,
    policyname,
    cmd as operation,
    '✅ Corrigé' as statut
FROM pg_policies 
WHERE tablename IN ('waste_transactions', 'user_education_progress')
ORDER BY tablename, policyname;

-- 3. TEST RAPIDE (optionnel)
-- =====================================================

-- Test avec un UUID valide (remplacez par un vrai UUID d'utilisateur)
-- SELECT auth.uid() = 'votre-uuid-utilisateur'::uuid;

-- =====================================================
-- EXPLICATION DE L'ERREUR
-- =====================================================

-- PROBLÈME :
-- auth.uid() retourne un UUID
-- user_id dans nos tables est de type TEXT
-- PostgreSQL ne peut pas comparer directement UUID et TEXT

-- SOLUTION :
-- Convertir user_id en UUID avec ::uuid
-- auth.uid() = user_id::uuid

-- =====================================================
-- INSTRUCTIONS
-- =====================================================

-- 1. Exécutez ce script dans Supabase SQL Editor
-- 2. Vérifiez que les politiques sont créées sans erreur
-- 3. Testez votre application Flutter
-- 4. Les erreurs RLS devraient être corrigées
