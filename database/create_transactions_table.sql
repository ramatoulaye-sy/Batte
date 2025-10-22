-- =====================================================
-- Création de la table transactions
-- =====================================================
-- Cette table stocke toutes les transactions financières
-- (retraits, gains de recyclage, épargne, etc.)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  amount NUMERIC(10, 2) NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('withdrawal', 'recycling', 'savings', 'reward', 'bonus')),
  description TEXT,
  status TEXT NOT NULL DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed', 'cancelled')),
  date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- Index pour améliorer les performances
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON public.transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON public.transactions(date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON public.transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_status ON public.transactions(status);

-- =====================================================
-- Activer Row Level Security (RLS)
-- =====================================================
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- Policies RLS : Chaque utilisateur ne peut voir que ses propres transactions
-- =====================================================

-- Policy pour SELECT : L'utilisateur peut voir ses propres transactions
DROP POLICY IF EXISTS transactions_select_own ON public.transactions;
CREATE POLICY transactions_select_own
  ON public.transactions
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Policy pour INSERT : L'utilisateur peut créer ses propres transactions
DROP POLICY IF EXISTS transactions_insert_own ON public.transactions;
CREATE POLICY transactions_insert_own
  ON public.transactions
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Policy pour UPDATE : L'utilisateur peut mettre à jour ses propres transactions
DROP POLICY IF EXISTS transactions_update_own ON public.transactions;
CREATE POLICY transactions_update_own
  ON public.transactions
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy pour DELETE : L'utilisateur peut supprimer ses propres transactions
DROP POLICY IF EXISTS transactions_delete_own ON public.transactions;
CREATE POLICY transactions_delete_own
  ON public.transactions
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- =====================================================
-- Fonction pour mettre à jour automatiquement updated_at
-- =====================================================
CREATE OR REPLACE FUNCTION update_transactions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Trigger pour mettre à jour updated_at automatiquement
-- =====================================================
DROP TRIGGER IF EXISTS update_transactions_updated_at_trigger ON public.transactions;
CREATE TRIGGER update_transactions_updated_at_trigger
  BEFORE UPDATE ON public.transactions
  FOR EACH ROW
  EXECUTE FUNCTION update_transactions_updated_at();

-- =====================================================
-- Donner les permissions nécessaires
-- =====================================================
GRANT SELECT, INSERT, UPDATE, DELETE ON public.transactions TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- =====================================================
-- Commentaires sur la table et les colonnes
-- =====================================================
COMMENT ON TABLE public.transactions IS 'Table des transactions financières (retraits, gains, épargne)';
COMMENT ON COLUMN public.transactions.id IS 'Identifiant unique de la transaction';
COMMENT ON COLUMN public.transactions.user_id IS 'Référence vers l''utilisateur propriétaire';
COMMENT ON COLUMN public.transactions.amount IS 'Montant de la transaction en GNF';
COMMENT ON COLUMN public.transactions.type IS 'Type de transaction: withdrawal, recycling, savings, reward, bonus';
COMMENT ON COLUMN public.transactions.description IS 'Description optionnelle de la transaction';
COMMENT ON COLUMN public.transactions.status IS 'Statut: pending, completed, failed, cancelled';
COMMENT ON COLUMN public.transactions.date IS 'Date et heure de la transaction';

-- =====================================================
-- SUCCÈS !
-- =====================================================
-- La table transactions a été créée avec succès
-- =====================================================

