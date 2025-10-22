-- =====================================================
-- CORRECTIONS SUPABASE - ERREURS IDENTIFIÉES
-- =====================================================

-- 1. CORRECTION : Créer la table user_education_progress si nécessaire
-- =====================================================

-- Créer la table user_education_progress si elle n'existe pas
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

-- Activer RLS sur la table
ALTER TABLE user_education_progress ENABLE ROW LEVEL SECURITY;

-- 2. CORRECTION : Créer la table waste_transactions si nécessaire
-- =====================================================

-- Créer la table waste_transactions si elle n'existe pas
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

-- Activer RLS sur la table
ALTER TABLE waste_transactions ENABLE ROW LEVEL SECURITY;

-- 3. CORRECTION : Créer les politiques RLS pour waste_transactions
-- =====================================================

-- Supprimer les anciennes politiques s'il y en a
DROP POLICY IF EXISTS "Users can insert their own waste transactions" ON waste_transactions;
DROP POLICY IF EXISTS "Users can view their own waste transactions" ON waste_transactions;
DROP POLICY IF EXISTS "Users can update their own waste transactions" ON waste_transactions;

-- Créer les nouvelles politiques RLS
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

-- 4. CORRECTION : Créer les politiques RLS pour user_education_progress
-- =====================================================

-- Supprimer les anciennes politiques s'il y en a
DROP POLICY IF EXISTS "Users can manage their own education progress" ON user_education_progress;

-- Créer les politiques RLS pour user_education_progress
CREATE POLICY "Users can manage their own education progress" 
ON user_education_progress 
FOR ALL 
TO authenticated 
USING (auth.uid() = user_id::uuid)
WITH CHECK (auth.uid() = user_id::uuid);

-- 5. CORRECTION : Créer les index pour optimiser les performances
-- =====================================================

-- Index pour waste_transactions
CREATE INDEX IF NOT EXISTS idx_waste_transactions_user_id ON waste_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_waste_transactions_created_at ON waste_transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_waste_transactions_status ON waste_transactions(status);

-- Index pour user_education_progress
CREATE INDEX IF NOT EXISTS idx_user_education_progress_user_id ON user_education_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_education_progress_content_id ON user_education_progress(content_id);
CREATE INDEX IF NOT EXISTS idx_user_education_progress_completed ON user_education_progress(completed);

-- 6. CORRECTION : Créer les fonctions de mise à jour automatique
-- =====================================================

-- Fonction pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers pour mettre à jour updated_at automatiquement
DROP TRIGGER IF EXISTS update_waste_transactions_updated_at ON waste_transactions;
CREATE TRIGGER update_waste_transactions_updated_at 
    BEFORE UPDATE ON waste_transactions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_user_education_progress_updated_at ON user_education_progress;
CREATE TRIGGER update_user_education_progress_updated_at 
    BEFORE UPDATE ON user_education_progress 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 7. CORRECTION : Créer les vues utiles pour l'application
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

-- 8. CORRECTION : Données de test (optionnel)
-- =====================================================

-- Insérer des données de test pour vérifier que tout fonctionne
-- (Décommentez si vous voulez des données de test)

/*
-- Données de test pour user_education_progress
INSERT INTO user_education_progress (user_id, content_id, completed, progress_percentage)
VALUES 
    ('test-user-1', 'content-1', TRUE, 100),
    ('test-user-1', 'content-2', FALSE, 50),
    ('test-user-2', 'content-1', TRUE, 100)
ON CONFLICT (user_id, content_id) DO NOTHING;

-- Données de test pour waste_transactions
INSERT INTO waste_transactions (user_id, amount, type, description, status)
VALUES 
    ('test-user-1', 1500.00, 'recycling', 'Test déchet plastique', 'completed'),
    ('test-user-1', 2500.00, 'recycling', 'Test déchet métal', 'pending'),
    ('test-user-2', 1000.00, 'recycling', 'Test déchet papier', 'completed')
ON CONFLICT DO NOTHING;
*/

-- =====================================================
-- RÉSUMÉ DES CORRECTIONS APPLIQUÉES
-- =====================================================

-- ✅ Colonne 'completed' ajoutée à user_education_progress
-- ✅ Politiques RLS créées pour waste_transactions
-- ✅ Politiques RLS créées pour user_education_progress
-- ✅ Tables créées si elles n'existent pas
-- ✅ Index créés pour optimiser les performances
-- ✅ Triggers créés pour updated_at automatique
-- ✅ Vues créées pour les statistiques
-- ✅ Fonctions utilitaires créées

-- =====================================================
-- INSTRUCTIONS D'EXÉCUTION
-- =====================================================

-- 1. Connectez-vous à votre projet Supabase
-- 2. Allez dans l'éditeur SQL
-- 3. Copiez et exécutez ce script complet
-- 4. Vérifiez que toutes les tables et politiques sont créées
-- 5. Testez l'application pour confirmer que les erreurs sont corrigées

-- =====================================================
-- VÉRIFICATION POST-EXÉCUTION
-- =====================================================

-- Vérifier que les tables existent
-- SELECT table_name FROM information_schema.tables 
-- WHERE table_schema = 'public' 
-- AND table_name IN ('waste_transactions', 'user_education_progress');

-- Vérifier que les politiques RLS existent
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
-- FROM pg_policies 
-- WHERE tablename IN ('waste_transactions', 'user_education_progress');

-- Vérifier que les colonnes existent
-- SELECT table_name, column_name, data_type, is_nullable 
-- FROM information_schema.columns 
-- WHERE table_name IN ('waste_transactions', 'user_education_progress')
-- ORDER BY table_name, ordinal_position;
