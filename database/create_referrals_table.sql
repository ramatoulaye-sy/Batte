-- =====================================================
-- TABLE : REFERRALS (Programme de parrainage)
-- =====================================================

-- Table des codes de parrainage
CREATE TABLE IF NOT EXISTS public.referral_codes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  code VARCHAR(20) UNIQUE NOT NULL, -- Code unique (ex: "BATTE-ABC123")
  total_referrals INTEGER DEFAULT 0 NOT NULL,
  total_bonus_earned NUMERIC DEFAULT 0 NOT NULL,
  is_active BOOLEAN DEFAULT TRUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Table des parrainages effectués
CREATE TABLE IF NOT EXISTS public.referrals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  referrer_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL, -- Parrain
  referred_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL, -- Filleul
  referral_code VARCHAR(20) NOT NULL,
  bonus_amount NUMERIC DEFAULT 500 NOT NULL, -- Bonus en GNF (500 par défaut)
  bonus_paid BOOLEAN DEFAULT FALSE NOT NULL,
  bonus_paid_at TIMESTAMP WITH TIME ZONE,
  status VARCHAR(20) DEFAULT 'pending' NOT NULL, -- 'pending', 'completed', 'cancelled'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  UNIQUE(referred_id) -- Un utilisateur ne peut être parrainé qu'une seule fois
);

-- Index pour optimiser les requêtes
CREATE INDEX IF NOT EXISTS idx_referral_codes_user ON public.referral_codes(user_id);
CREATE INDEX IF NOT EXISTS idx_referral_codes_code ON public.referral_codes(code);
CREATE INDEX IF NOT EXISTS idx_referrals_referrer ON public.referrals(referrer_id);
CREATE INDEX IF NOT EXISTS idx_referrals_referred ON public.referrals(referred_id);
CREATE INDEX IF NOT EXISTS idx_referrals_status ON public.referrals(status);

-- Trigger pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_referral_codes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_referral_codes_updated_at
  BEFORE UPDATE ON public.referral_codes
  FOR EACH ROW
  EXECUTE FUNCTION update_referral_codes_updated_at();

-- =====================================================
-- FONCTION : Générer un code de parrainage unique
-- =====================================================

CREATE OR REPLACE FUNCTION generate_referral_code(p_user_id UUID)
RETURNS VARCHAR AS $$
DECLARE
  v_code VARCHAR(20);
  v_exists BOOLEAN;
BEGIN
  LOOP
    -- Générer un code au format BATTE-XXXXXX (6 caractères alphanumériques)
    v_code := 'BATTE-' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT || NOW()::TEXT) FROM 1 FOR 6));
    
    -- Vérifier si le code existe déjà
    SELECT EXISTS(SELECT 1 FROM public.referral_codes WHERE code = v_code) INTO v_exists;
    
    EXIT WHEN NOT v_exists;
  END LOOP;
  
  -- Insérer le code
  INSERT INTO public.referral_codes (user_id, code)
  VALUES (p_user_id, v_code)
  ON CONFLICT (user_id) DO NOTHING;
  
  RETURN v_code;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- FONCTION : Appliquer un code de parrainage
-- =====================================================

CREATE OR REPLACE FUNCTION apply_referral_code(
  p_referred_user_id UUID,
  p_referral_code VARCHAR
)
RETURNS JSON AS $$
DECLARE
  v_referrer_id UUID;
  v_bonus_amount NUMERIC := 500; -- Bonus par défaut
  v_referral_id UUID;
BEGIN
  -- Vérifier que le code existe et est actif
  SELECT user_id INTO v_referrer_id
  FROM public.referral_codes
  WHERE code = p_referral_code AND is_active = true;
  
  IF v_referrer_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Code de parrainage invalide ou inactif'
    );
  END IF;
  
  -- Vérifier que l'utilisateur ne se parraine pas lui-même
  IF v_referrer_id = p_referred_user_id THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Vous ne pouvez pas utiliser votre propre code'
    );
  END IF;
  
  -- Vérifier que l'utilisateur n'a pas déjà été parrainé
  IF EXISTS(SELECT 1 FROM public.referrals WHERE referred_id = p_referred_user_id) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Vous avez déjà utilisé un code de parrainage'
    );
  END IF;
  
  -- Créer le parrainage
  INSERT INTO public.referrals (referrer_id, referred_id, referral_code, bonus_amount, status)
  VALUES (v_referrer_id, p_referred_user_id, p_referral_code, v_bonus_amount, 'pending')
  RETURNING id INTO v_referral_id;
  
  -- Mettre à jour les statistiques du parrain
  UPDATE public.referral_codes
  SET total_referrals = total_referrals + 1
  WHERE user_id = v_referrer_id;
  
  RETURN json_build_object(
    'success', true,
    'referral_id', v_referral_id,
    'bonus_amount', v_bonus_amount,
    'message', 'Parrainage enregistré avec succès !'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- FONCTION : Payer le bonus de parrainage
-- =====================================================

CREATE OR REPLACE FUNCTION pay_referral_bonus(p_referral_id UUID)
RETURNS JSON AS $$
DECLARE
  v_referral RECORD;
  v_transaction_id UUID;
BEGIN
  -- Récupérer les infos du parrainage
  SELECT * INTO v_referral
  FROM public.referrals
  WHERE id = p_referral_id AND status = 'pending' AND bonus_paid = false;
  
  IF v_referral IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Parrainage introuvable ou déjà payé'
    );
  END IF;
  
  -- Créditer le compte du parrain
  UPDATE public.users
  SET balance = balance + v_referral.bonus_amount
  WHERE id = v_referral.referrer_id;
  
  -- Créer une transaction
  INSERT INTO public.transactions (user_id, type, amount, description)
  VALUES (
    v_referral.referrer_id,
    'bonus',
    v_referral.bonus_amount,
    'Bonus de parrainage - Code: ' || v_referral.referral_code
  )
  RETURNING id INTO v_transaction_id;
  
  -- Marquer le bonus comme payé
  UPDATE public.referrals
  SET
    bonus_paid = true,
    bonus_paid_at = NOW(),
    status = 'completed'
  WHERE id = p_referral_id;
  
  -- Mettre à jour les statistiques
  UPDATE public.referral_codes
  SET total_bonus_earned = total_bonus_earned + v_referral.bonus_amount
  WHERE user_id = v_referral.referrer_id;
  
  RETURN json_build_object(
    'success', true,
    'transaction_id', v_transaction_id,
    'bonus_amount', v_referral.bonus_amount
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- POLITIQUE DE SÉCURITÉ (RLS)
-- =====================================================

-- Activer RLS
ALTER TABLE public.referral_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;

-- Politique : Les utilisateurs peuvent voir leur propre code
CREATE POLICY "Voir son code" ON public.referral_codes
  FOR SELECT
  USING (auth.uid() = user_id);

-- Politique : Les utilisateurs peuvent créer leur code
CREATE POLICY "Créer son code" ON public.referral_codes
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Politique : Les utilisateurs peuvent voir leurs parrainages (en tant que parrain)
CREATE POLICY "Voir ses parrainages" ON public.referrals
  FOR SELECT
  USING (auth.uid() = referrer_id OR auth.uid() = referred_id);

-- Politique : Les utilisateurs peuvent créer un parrainage (en tant que filleul)
CREATE POLICY "Créer un parrainage" ON public.referrals
  FOR INSERT
  WITH CHECK (auth.uid() = referred_id);

-- =====================================================
-- TRIGGER : Générer automatiquement un code à l'inscription
-- =====================================================

CREATE OR REPLACE FUNCTION auto_generate_referral_code()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM generate_referral_code(NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_auto_generate_referral_code
  AFTER INSERT ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION auto_generate_referral_code();

-- =====================================================
-- NOTES D'UTILISATION
-- =====================================================

-- Pour générer manuellement un code pour un utilisateur :
-- SELECT generate_referral_code('USER_UUID');

-- Pour appliquer un code de parrainage :
-- SELECT apply_referral_code('NEW_USER_UUID', 'BATTE-ABC123');

-- Pour payer un bonus de parrainage :
-- SELECT pay_referral_bonus('REFERRAL_UUID');

-- Pour voir les parrainages d'un utilisateur :
-- SELECT * FROM public.referrals WHERE referrer_id = 'USER_UUID';

-- Pour voir le code d'un utilisateur :
-- SELECT * FROM public.referral_codes WHERE user_id = 'USER_UUID';

