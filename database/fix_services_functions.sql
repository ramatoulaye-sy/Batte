-- =====================================================
-- CORRECTION ERREURS SUPABASE SERVICES
-- =====================================================
-- Ce script corrige les erreurs des fonctions manquantes
-- pour le module Services
-- =====================================================

-- =====================================================
-- 1. FONCTION search_services
-- =====================================================

CREATE OR REPLACE FUNCTION search_services(
  p_query TEXT DEFAULT NULL,
  p_category TEXT DEFAULT NULL,
  p_location TEXT DEFAULT NULL,
  p_max_price NUMERIC DEFAULT NULL,
  p_offset INTEGER DEFAULT 0,
  p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
  id UUID,
  title TEXT,
  description TEXT,
  category TEXT,
  price NUMERIC,
  location TEXT,
  user_id UUID,
  user_name TEXT,
  user_phone TEXT,
  created_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    so.id,
    so.title,
    so.description,
    so.category,
    so.price,
    so.location,
    so.user_id,
    so.user_name,
    so.user_phone,
    so.created_at,
    so.updated_at
  FROM service_offers so
  WHERE 
    (p_query IS NULL OR so.title ILIKE '%' || p_query || '%' OR so.description ILIKE '%' || p_query || '%')
    AND (p_category IS NULL OR so.category = p_category)
    AND (p_location IS NULL OR so.location ILIKE '%' || p_location || '%')
    AND (p_max_price IS NULL OR so.price <= p_max_price)
  ORDER BY so.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

-- =====================================================
-- 2. FONCTION create_service_offer
-- =====================================================

CREATE OR REPLACE FUNCTION create_service_offer(
  p_title TEXT,
  p_description TEXT,
  p_category TEXT,
  p_price NUMERIC,
  p_location TEXT DEFAULT NULL,
  p_photos TEXT[] DEFAULT NULL,
  p_availability_rules JSONB DEFAULT NULL,
  p_coverage_radius_km INTEGER DEFAULT NULL,
  p_price_unit TEXT DEFAULT 'GNF',
  p_expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_user_name TEXT;
  v_user_phone TEXT;
  v_offer_id UUID;
  v_result JSON;
BEGIN
  -- Récupérer les informations de l'utilisateur connecté
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Utilisateur non authentifié'
    );
  END IF;
  
  -- Récupérer les informations utilisateur
  SELECT name, phone INTO v_user_name, v_user_phone
  FROM profiles
  WHERE id = v_user_id;
  
  -- Créer l'offre de service
  INSERT INTO service_offers (
    title,
    description,
    category,
    price,
    location,
    photos,
    availability_rules,
    coverage_radius_km,
    price_unit,
    expires_at,
    user_id,
    user_name,
    user_phone,
    status
  ) VALUES (
    p_title,
    p_description,
    p_category,
    p_price,
    p_location,
    p_photos,
    p_availability_rules,
    p_coverage_radius_km,
    p_price_unit,
    p_expires_at,
    v_user_id,
    COALESCE(v_user_name, 'Utilisateur'),
    v_user_phone,
    'active'
  ) RETURNING id INTO v_offer_id;
  
  -- Retourner le résultat
  v_result := json_build_object(
    'success', true,
    'offer_id', v_offer_id,
    'message', 'Offre créée avec succès'
  );
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', SQLERRM
    );
END;
$$;

-- =====================================================
-- 3. FONCTION create_service_request
-- =====================================================

CREATE OR REPLACE FUNCTION create_service_request(
  p_title TEXT,
  p_description TEXT,
  p_category TEXT,
  p_budget NUMERIC,
  p_location TEXT DEFAULT NULL,
  p_requirements TEXT[] DEFAULT NULL,
  p_urgency TEXT DEFAULT 'normal',
  p_preferred_time TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_id UUID;
  v_user_name TEXT;
  v_user_phone TEXT;
  v_request_id UUID;
  v_result JSON;
BEGIN
  -- Récupérer les informations de l'utilisateur connecté
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Utilisateur non authentifié'
    );
  END IF;
  
  -- Récupérer les informations utilisateur
  SELECT name, phone INTO v_user_name, v_user_phone
  FROM profiles
  WHERE id = v_user_id;
  
  -- Créer la demande de service
  INSERT INTO service_requests (
    title,
    description,
    category,
    budget,
    location,
    requirements,
    urgency,
    preferred_time,
    user_id,
    user_name,
    user_phone,
    status
  ) VALUES (
    p_title,
    p_description,
    p_category,
    p_budget,
    p_location,
    p_requirements,
    p_urgency,
    p_preferred_time,
    v_user_id,
    COALESCE(v_user_name, 'Utilisateur'),
    v_user_phone,
    'open'
  ) RETURNING id INTO v_request_id;
  
  -- Retourner le résultat
  v_result := json_build_object(
    'success', true,
    'request_id', v_request_id,
    'message', 'Demande créée avec succès'
  );
  
  RETURN v_result;
  
EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', SQLERRM
    );
END;
$$;

-- =====================================================
-- 4. PERMISSIONS
-- =====================================================

-- Permettre l'exécution des fonctions aux utilisateurs authentifiés
GRANT EXECUTE ON FUNCTION search_services TO authenticated;
GRANT EXECUTE ON FUNCTION create_service_offer TO authenticated;
GRANT EXECUTE ON FUNCTION create_service_request TO authenticated;

-- =====================================================
-- 5. COMMENTAIRES
-- =====================================================

COMMENT ON FUNCTION search_services IS 'Recherche des offres de services avec filtres';
COMMENT ON FUNCTION create_service_offer IS 'Crée une nouvelle offre de service';
COMMENT ON FUNCTION create_service_request IS 'Crée une nouvelle demande de service';
