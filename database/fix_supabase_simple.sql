-- =====================================================
-- SCRIPT SIMPLIFIÉ - CORRECTION SUPABASE
-- =====================================================

-- 1. CRÉER LES TABLES SI ELLES N'EXISTENT PAS
-- =====================================================

-- Table user_education_progress
CREATE TABLE IF NOT EXISTS user_education_progress (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL,
    content_id TEXT NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    progress_percentage INTEGER DEFAULT 0,
    last_accessed TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, content_id)
);

-- Table waste_transactions
CREATE TABLE IF NOT EXISTS waste_transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL,
    waste_id TEXT,
    amount DECIMAL(10,2) NOT NULL,
    type TEXT NOT NULL DEFAULT 'recycling',
    description TEXT,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. ACTIVER RLS SUR LES TABLES
-- =====================================================

ALTER TABLE user_education_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE waste_transactions ENABLE ROW LEVEL SECURITY;

-- 3. CRÉER LES POLITIQUES RLS
-- =====================================================

-- Politiques pour waste_transactions
DROP POLICY IF EXISTS "Users can insert their own waste transactions" ON waste_transactions;
DROP POLICY IF EXISTS "Users can view their own waste transactions" ON waste_transactions;
DROP POLICY IF EXISTS "Users can update their own waste transactions" ON waste_transactions;

CREATE POLICY "Users can insert their own waste transactions" 
ON waste_transactions FOR INSERT TO authenticated 
WITH CHECK (auth.uid() = user_id::uuid);

CREATE POLICY "Users can view their own waste transactions" 
ON waste_transactions FOR SELECT TO authenticated 
USING (auth.uid() = user_id::uuid);

CREATE POLICY "Users can update their own waste transactions" 
ON waste_transactions FOR UPDATE TO authenticated 
USING (auth.uid() = user_id::uuid)
WITH CHECK (auth.uid() = user_id::uuid);

-- Politiques pour user_education_progress
DROP POLICY IF EXISTS "Users can manage their own education progress" ON user_education_progress;

CREATE POLICY "Users can manage their own education progress" 
ON user_education_progress FOR ALL TO authenticated 
USING (auth.uid() = user_id::uuid)
WITH CHECK (auth.uid() = user_id::uuid);

-- 4. CRÉER LES INDEX POUR OPTIMISER LES PERFORMANCES
-- =====================================================

-- Index pour waste_transactions
CREATE INDEX IF NOT EXISTS idx_waste_transactions_user_id ON waste_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_waste_transactions_created_at ON waste_transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_waste_transactions_status ON waste_transactions(status);

-- Index pour user_education_progress
CREATE INDEX IF NOT EXISTS idx_user_education_progress_user_id ON user_education_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_education_progress_content_id ON user_education_progress(content_id);
CREATE INDEX IF NOT EXISTS idx_user_education_progress_completed ON user_education_progress(completed);

-- 5. CRÉER LES FONCTIONS ET TRIGGERS
-- =====================================================

-- Fonction pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers pour updated_at automatique
DROP TRIGGER IF EXISTS update_waste_transactions_updated_at ON waste_transactions;
CREATE TRIGGER update_waste_transactions_updated_at 
    BEFORE UPDATE ON waste_transactions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_education_progress_updated_at ON user_education_progress;
CREATE TRIGGER update_user_education_progress_updated_at 
    BEFORE UPDATE ON user_education_progress 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 6. CRÉER LES VUES UTILES
-- =====================================================

-- Vue pour les statistiques de déchets par utilisateur
CREATE OR REPLACE VIEW user_waste_stats AS
SELECT 
    user_id,
    COUNT(*) as total_wastes,
    SUM(amount) as total_amount,
    AVG(amount) as average_amount,
    MAX(created_at) as last_waste_date,
    COUNT(*) FILTER (WHERE status = 'completed') as completed_wastes,
    COUNT(*) FILTER (WHERE status = 'pending') as pending_wastes
FROM waste_transactions
GROUP BY user_id;

-- Vue pour les statistiques d'éducation par utilisateur
CREATE OR REPLACE VIEW user_education_stats AS
SELECT 
    user_id,
    COUNT(*) as total_contents,
    COUNT(*) FILTER (WHERE completed = TRUE) as completed_contents,
    ROUND(
        (COUNT(*) FILTER (WHERE completed = TRUE)::DECIMAL / COUNT(*)) * 100, 
        2
    ) as completion_percentage,
    MAX(last_accessed) as last_activity
FROM user_education_progress
GROUP BY user_id;

-- =====================================================
-- VÉRIFICATION RAPIDE
-- =====================================================

-- Vérifier que les tables existent
SELECT 'Tables créées' as verification, table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('waste_transactions', 'user_education_progress')
ORDER BY table_name;

-- Vérifier que les politiques RLS existent
SELECT 'Politiques RLS' as verification, tablename, policyname, cmd 
FROM pg_policies 
WHERE tablename IN ('waste_transactions', 'user_education_progress')
ORDER BY tablename, policyname;

-- Vérifier que les colonnes existent
SELECT 'Colonnes' as verification, table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name IN ('waste_transactions', 'user_education_progress')
AND column_name IN ('user_id', 'completed', 'amount', 'status')
ORDER BY table_name, column_name;

-- =====================================================
-- RÉSUMÉ
-- =====================================================

-- ✅ Tables créées avec colonne 'completed'
-- ✅ Politiques RLS créées avec conversion UUID correcte
-- ✅ Index créés pour optimiser les performances
-- ✅ Triggers créés pour updated_at automatique
-- ✅ Vues créées pour les statistiques

-- =====================================================
-- INSTRUCTIONS
-- =====================================================

-- 1. Copiez et exécutez ce script dans Supabase SQL Editor
-- 2. Vérifiez que toutes les vérifications montrent les éléments attendus
-- 3. Testez votre application Flutter
-- 4. Les erreurs Supabase devraient être corrigées
