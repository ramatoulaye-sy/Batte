-- =====================================================
-- SUPABASE BUDGET TABLES - VERSION SIMPLIFIÉE
-- Exécutez ce script étape par étape dans Supabase SQL Editor
-- =====================================================

-- ÉTAPE 1: Créer la table withdrawal_transactions
CREATE TABLE IF NOT EXISTS withdrawal_transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    amount_gnf DECIMAL(10,2) NOT NULL CHECK (amount_gnf > 0),
    method VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')),
    reference VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    failure_reason TEXT
);

-- ÉTAPE 2: Créer la table saving_transactions
CREATE TABLE IF NOT EXISTS saving_transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    amount_gnf DECIMAL(10,2) NOT NULL CHECK (amount_gnf > 0),
    goal VARCHAR(100) NOT NULL,
    interest_rate DECIMAL(5,2) DEFAULT 0.0,
    duration_months INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
    maturity_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- ÉTAPE 3: Créer les index
CREATE INDEX IF NOT EXISTS idx_withdrawal_user_id ON withdrawal_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_withdrawal_status ON withdrawal_transactions(status);
CREATE INDEX IF NOT EXISTS idx_withdrawal_created ON withdrawal_transactions(created_at);

CREATE INDEX IF NOT EXISTS idx_saving_user_id ON saving_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_saving_status ON saving_transactions(status);
CREATE INDEX IF NOT EXISTS idx_saving_goal ON saving_transactions(goal);

-- ÉTAPE 4: Activer RLS sur withdrawal_transactions
ALTER TABLE withdrawal_transactions ENABLE ROW LEVEL SECURITY;

-- ÉTAPE 5: Créer les politiques pour withdrawal_transactions
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'withdrawal_transactions' AND policyname = 'Users can view own withdrawal transactions') THEN
        CREATE POLICY "Users can view own withdrawal transactions" ON withdrawal_transactions
            FOR SELECT USING (auth.uid() = user_id);
    END IF;
EXCEPTION WHEN OTHERS THEN
    -- Ignorer les erreurs
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'withdrawal_transactions' AND policyname = 'Users can create own withdrawal transactions') THEN
        CREATE POLICY "Users can create own withdrawal transactions" ON withdrawal_transactions
            FOR INSERT WITH CHECK (auth.uid() = user_id);
    END IF;
EXCEPTION WHEN OTHERS THEN
    -- Ignorer les erreurs
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'withdrawal_transactions' AND policyname = 'Users can update own withdrawal transactions') THEN
        CREATE POLICY "Users can update own withdrawal transactions" ON withdrawal_transactions
            FOR UPDATE USING (auth.uid() = user_id);
    END IF;
EXCEPTION WHEN OTHERS THEN
    -- Ignorer les erreurs
END $$;

-- ÉTAPE 6: Activer RLS sur saving_transactions
ALTER TABLE saving_transactions ENABLE ROW LEVEL SECURITY;

-- ÉTAPE 7: Créer les politiques pour saving_transactions
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'saving_transactions' AND policyname = 'Users can view own saving transactions') THEN
        CREATE POLICY "Users can view own saving transactions" ON saving_transactions
            FOR SELECT USING (auth.uid() = user_id);
    END IF;
EXCEPTION WHEN OTHERS THEN
    -- Ignorer les erreurs
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'saving_transactions' AND policyname = 'Users can create own saving transactions') THEN
        CREATE POLICY "Users can create own saving transactions" ON saving_transactions
            FOR INSERT WITH CHECK (auth.uid() = user_id);
    END IF;
EXCEPTION WHEN OTHERS THEN
    -- Ignorer les erreurs
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'saving_transactions' AND policyname = 'Users can update own saving transactions') THEN
        CREATE POLICY "Users can update own saving transactions" ON saving_transactions
            FOR UPDATE USING (auth.uid() = user_id);
    END IF;
EXCEPTION WHEN OTHERS THEN
    -- Ignorer les erreurs
END $$;

-- ÉTAPE 8: Créer la fonction pour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- ÉTAPE 9: Créer les triggers
DROP TRIGGER IF EXISTS update_withdrawal_transactions_updated_at ON withdrawal_transactions;
CREATE TRIGGER update_withdrawal_transactions_updated_at 
    BEFORE UPDATE ON withdrawal_transactions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_saving_transactions_updated_at ON saving_transactions;
CREATE TRIGGER update_saving_transactions_updated_at 
    BEFORE UPDATE ON saving_transactions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ÉTAPE 10: Vérifier que tout est créé
SELECT 
    'withdrawal_transactions' as table_name,
    COUNT(*) as row_count
FROM withdrawal_transactions
UNION ALL
SELECT 
    'saving_transactions' as table_name,
    COUNT(*) as row_count
FROM saving_transactions;

-- =====================================================
-- FIN - Tables créées avec succès !
-- =====================================================
