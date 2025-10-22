-- =====================================================
-- VUE : LEADERBOARD (Classement des utilisateurs)
-- =====================================================

-- Vue matérialisée pour le classement général
CREATE MATERIALIZED VIEW IF NOT EXISTS public.leaderboard AS
SELECT
  u.id AS user_id,
  u.name,
  u.avatar_url,
  u.city,
  u.eco_score,
  u.total_weight,
  u.balance,
  COALESCE(SUM(CASE WHEN t.type = 'recycling' THEN t.amount ELSE 0 END), 0) AS total_earnings,
  COUNT(DISTINCT t.id) FILTER (WHERE t.type = 'recycling') AS total_wastes,
  COUNT(DISTINCT t.id) AS total_transactions,
  u.created_at,
  RANK() OVER (ORDER BY u.total_weight DESC NULLS LAST) AS rank_by_weight,
  RANK() OVER (ORDER BY u.eco_score DESC NULLS LAST) AS rank_by_points,
  RANK() OVER (ORDER BY COALESCE(SUM(CASE WHEN t.type = 'recycling' THEN t.amount ELSE 0 END), 0) DESC NULLS LAST) AS rank_by_earnings,
  CASE
    WHEN u.eco_score >= 1000 THEN '🏆'
    WHEN u.eco_score >= 500 THEN '🥇'
    WHEN u.eco_score >= 200 THEN '🥈'
    WHEN u.eco_score >= 100 THEN '🥉'
    ELSE '🌱'
  END AS badge
FROM public.users u
LEFT JOIN public.transactions t ON t.user_id = u.id
GROUP BY u.id, u.name, u.avatar_url, u.city, u.eco_score, u.total_weight, u.balance, u.created_at
ORDER BY u.eco_score DESC NULLS LAST;

-- Index pour optimiser les requêtes
CREATE INDEX IF NOT EXISTS idx_leaderboard_rank_weight ON public.leaderboard(rank_by_weight);
CREATE INDEX IF NOT EXISTS idx_leaderboard_rank_points ON public.leaderboard(rank_by_points);
CREATE INDEX IF NOT EXISTS idx_leaderboard_rank_earnings ON public.leaderboard(rank_by_earnings);

-- =====================================================
-- FONCTION : Rafraîchir le leaderboard
-- =====================================================

CREATE OR REPLACE FUNCTION refresh_leaderboard()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW public.leaderboard;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- VUES SIMPLIFIÉES POUR L'APPLICATION
-- =====================================================

-- Top 10 par poids recyclé
CREATE OR REPLACE VIEW public.leaderboard_by_weight AS
SELECT
  user_id,
  name,
  avatar_url,
  city,
  total_weight,
  badge,
  rank_by_weight AS rank
FROM public.leaderboard
ORDER BY rank_by_weight ASC
LIMIT 10;

-- Top 10 par points d'éco-score
CREATE OR REPLACE VIEW public.leaderboard_by_points AS
SELECT
  user_id,
  name,
  avatar_url,
  city,
  eco_score,
  badge,
  rank_by_points AS rank
FROM public.leaderboard
ORDER BY rank_by_points ASC
LIMIT 10;

-- Top 10 par gains totaux
CREATE OR REPLACE VIEW public.leaderboard_by_earnings AS
SELECT
  user_id,
  name,
  avatar_url,
  city,
  total_earnings,
  badge,
  rank_by_earnings AS rank
FROM public.leaderboard
ORDER BY rank_by_earnings ASC
LIMIT 10;

-- =====================================================
-- FONCTION : Obtenir le classement d'un utilisateur spécifique
-- =====================================================

CREATE OR REPLACE FUNCTION get_user_rank(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  v_result JSON;
BEGIN
  SELECT json_build_object(
    'user_id', user_id,
    'name', name,
    'avatar_url', avatar_url,
    'rank_by_weight', rank_by_weight,
    'rank_by_points', rank_by_points,
    'rank_by_earnings', rank_by_earnings,
    'total_weight', total_weight,
    'eco_score', eco_score,
    'total_earnings', total_earnings,
    'badge', badge
  )
  INTO v_result
  FROM public.leaderboard
  WHERE user_id = p_user_id;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- POLITIQUE DE SÉCURITÉ (RLS)
-- =====================================================

-- Autoriser tous les utilisateurs authentifiés à voir le leaderboard
GRANT SELECT ON public.leaderboard TO authenticated;
GRANT SELECT ON public.leaderboard_by_weight TO authenticated;
GRANT SELECT ON public.leaderboard_by_points TO authenticated;
GRANT SELECT ON public.leaderboard_by_earnings TO authenticated;

-- =====================================================
-- NOTES D'UTILISATION
-- =====================================================

-- Pour obtenir le top 10 par poids :
-- SELECT * FROM public.leaderboard_by_weight;

-- Pour obtenir le top 10 par points :
-- SELECT * FROM public.leaderboard_by_points;

-- Pour obtenir le classement d'un utilisateur :
-- SELECT get_user_rank('USER_UUID');

-- Pour rafraîchir manuellement le leaderboard :
-- SELECT refresh_leaderboard();
