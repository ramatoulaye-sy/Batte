-- =====================================================
-- Fonction PostgreSQL : process_withdrawal
-- =====================================================
-- Cette fonction gère automatiquement le retrait d'argent :
-- 1. Vérifie que le solde est suffisant
-- 2. Crée la transaction de retrait
-- 3. Déduit le montant du solde utilisateur
-- =====================================================

CREATE OR REPLACE FUNCTION process_withdrawal(
  p_user_id UUID,
  p_amount NUMERIC,
  p_description TEXT DEFAULT 'Retrait de gains'
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_current_balance NUMERIC;
  v_transaction_id UUID;
  v_result JSON;
BEGIN
  -- 1. Récupérer le solde actuel
  SELECT balance INTO v_current_balance
  FROM public.users
  WHERE id = p_user_id;
  
  -- 2. Vérifier si le solde est suffisant
  IF v_current_balance IS NULL THEN
    RAISE EXCEPTION 'Utilisateur non trouvé';
  END IF;
  
  IF v_current_balance < p_amount THEN
    RAISE EXCEPTION 'Solde insuffisant. Solde actuel: % GNF, Montant demandé: % GNF', 
      v_current_balance, p_amount;
  END IF;
  
  -- 3. Créer la transaction de retrait
  INSERT INTO public.transactions (
    user_id,
    amount,
    type,
    description,
    status,
    date
  )
  VALUES (
    p_user_id,
    p_amount,
    'withdrawal',
    p_description,
    'completed',
    NOW()
  )
  RETURNING id INTO v_transaction_id;
  
  -- 4. Déduire le montant du solde utilisateur
  UPDATE public.users
  SET 
    balance = balance - p_amount,
    updated_at = NOW()
  WHERE id = p_user_id;
  
  -- 5. Récupérer le nouveau solde
  SELECT balance INTO v_current_balance
  FROM public.users
  WHERE id = p_user_id;
  
  -- 6. Retourner le résultat
  v_result := json_build_object(
    'success', TRUE,
    'transaction_id', v_transaction_id,
    'new_balance', v_current_balance,
    'amount_withdrawn', p_amount,
    'message', 'Retrait effectué avec succès'
  );
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    -- En cas d'erreur, annuler toutes les modifications
    RAISE EXCEPTION 'Erreur lors du retrait: %', SQLERRM;
END;
$$;

-- =====================================================
-- Donner les permissions nécessaires
-- =====================================================
GRANT EXECUTE ON FUNCTION process_withdrawal(UUID, NUMERIC, TEXT) TO authenticated;

-- =====================================================
-- INSTRUCTIONS D'UTILISATION
-- =====================================================
-- 1. Copiez tout ce fichier
-- 2. Allez sur Supabase Dashboard → SQL Editor
-- 3. Collez et exécutez le script
-- 4. La fonction sera créée et prête à être utilisée
-- =====================================================

