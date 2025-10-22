-- =====================================================
-- CORRECTION ERREUR: total_weight is ambiguous
-- =====================================================
-- Cette fonction corrige l'erreur "column reference total_weight is ambiguous"
-- en créant la fonction update_user_balance_and_points manquante
-- =====================================================

-- =====================================================
-- 1. CRÉER LA FONCTION update_user_balance_and_points
-- =====================================================

CREATE OR REPLACE FUNCTION update_user_balance_and_points(
  p_user_id UUID,
  p_amount NUMERIC,
  p_points INTEGER DEFAULT 0
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_new_balance NUMERIC;
  v_new_eco_score INTEGER;
  v_result JSON;
BEGIN
  -- Vérifier que l'utilisateur existe
  IF NOT EXISTS (SELECT 1 FROM public.users WHERE id = p_user_id) THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Utilisateur non trouvé'
    );
  END IF;

  -- Mettre à jour le solde utilisateur
  UPDATE public.users
  SET 
    balance = COALESCE(balance, 0) + p_amount,
    eco_score = COALESCE(eco_score, 0) + p_points,
    updated_at = NOW()
  WHERE id = p_user_id
  RETURNING balance, eco_score INTO v_new_balance, v_new_eco_score;

  -- Retourner le résultat
  v_result := json_build_object(
    'success', true,
    'new_balance', v_new_balance,
    'new_eco_score', v_new_eco_score,
    'amount_added', p_amount,
    'points_added', p_points,
    'message', 'Solde et points mis à jour avec succès'
  );

  RETURN v_result;

EXCEPTION
  WHEN OTHERS THEN
    -- En cas d'erreur, retourner l'erreur
    RETURN json_build_object(
      'success', false,
      'error', 'Erreur lors de la mise à jour: ' || SQLERRM
    );
END;
$$;

-- =====================================================
-- 2. DONNER LES PERMISSIONS NÉCESSAIRES
-- =====================================================

GRANT EXECUTE ON FUNCTION update_user_balance_and_points(UUID, NUMERIC, INTEGER) TO authenticated;

-- =====================================================
-- 3. COMMENTAIRES SUR LA FONCTION
-- =====================================================

COMMENT ON FUNCTION update_user_balance_and_points(UUID, NUMERIC, INTEGER) IS 
'Met à jour le solde et le score écologique d''un utilisateur après recyclage';

-- =====================================================
-- 4. TEST DE LA FONCTION
-- =====================================================

-- Test avec un utilisateur fictif (à supprimer après test)
-- SELECT update_user_balance_and_points(
--   '00000000-0000-0000-0000-000000000000'::UUID,
--   1000.00,
--   10
-- );

-- =====================================================
-- SUCCÈS !
-- =====================================================
-- La fonction update_user_balance_and_points a été créée
-- L'erreur "total_weight is ambiguous" devrait être résolue
-- =====================================================
