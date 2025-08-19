-- =====================================================
-- SUPABASE BUDGET TABLES: WITHDRAWAL & SAVING TRANSACTIONS
-- Run this in Supabase SQL Editor to support Budget page functionality
-- =====================================================

-- Table pour les transactions de retrait
CREATE TABLE IF NOT EXISTS withdrawal_transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    amount_gnf DECIMAL(10,2) NOT NULL CHECK (amount_gnf > 0),
    method VARCHAR(50) NOT NULL, -- 'Orange Money', 'MTN Mobile Money', 'Crédit téléphonique'
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')),
    reference VARCHAR(100), -- Référence externe (numéro de transaction)
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    failure_reason TEXT
);

-- Table pour les transactions d'épargne
CREATE TABLE IF NOT EXISTS saving_transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    amount_gnf DECIMAL(10,2) NOT NULL CHECK (amount_gnf > 0),
    goal VARCHAR(100) NOT NULL, -- 'Objectif Court Terme', 'Objectif Moyen Terme', 'Objectif Long Terme'
    interest_rate DECIMAL(5,2) DEFAULT 0.0, -- Taux d'intérêt en pourcentage
    duration_months INTEGER DEFAULT 0, -- Durée en mois
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
    maturity_date DATE, -- Date d'échéance
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_withdrawal_user_id ON withdrawal_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_withdrawal_status ON withdrawal_transactions(status);
CREATE INDEX IF NOT EXISTS idx_withdrawal_created ON withdrawal_transactions(created_at);

CREATE INDEX IF NOT EXISTS idx_saving_user_id ON saving_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_saving_status ON saving_transactions(status);
CREATE INDEX IF NOT EXISTS idx_saving_goal ON saving_transactions(goal);

-- RLS (Row Level Security) pour withdrawal_transactions
ALTER TABLE withdrawal_transactions ENABLE ROW LEVEL SECURITY;

-- Politiques pour withdrawal_transactions (avec gestion d'erreur robuste)
DO $$ BEGIN
    CREATE POLICY "Users can view own withdrawal transactions" ON withdrawal_transactions
        FOR SELECT USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

DO $$ BEGIN
    CREATE POLICY "Users can create own withdrawal transactions" ON withdrawal_transactions
        FOR INSERT WITH CHECK (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

DO $$ BEGIN
    CREATE POLICY "Users can update own withdrawal transactions" ON withdrawal_transactions
        FOR UPDATE USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

-- RLS pour saving_transactions
ALTER TABLE saving_transactions ENABLE ROW LEVEL SECURITY;

-- Politiques pour saving_transactions (avec gestion d'erreur robuste)
DO $$ BEGIN
    CREATE POLICY "Users can view own saving transactions" ON saving_transactions
        FOR SELECT USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

DO $$ BEGIN
    CREATE POLICY "Users can create own saving transactions" ON saving_transactions
        FOR INSERT WITH CHECK (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

DO $$ BEGIN
    CREATE POLICY "Users can update own saving transactions" ON saving_transactions
        FOR UPDATE USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END; $$;

-- Fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers pour mettre à jour automatiquement updated_at
DROP TRIGGER IF EXISTS update_withdrawal_transactions_updated_at ON withdrawal_transactions;
CREATE TRIGGER update_withdrawal_transactions_updated_at 
    BEFORE UPDATE ON withdrawal_transactions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_saving_transactions_updated_at ON saving_transactions;
CREATE TRIGGER update_saving_transactions_updated_at 
    BEFORE UPDATE ON saving_transactions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Note: Les données d'exemple ne sont pas insérées ici car elles nécessitent
-- un utilisateur réel existant dans la table auth.users
-- Vous pouvez ajouter des données d'exemple manuellement après avoir créé un utilisateur

-- =====================================================
-- END
-- =====================================================
