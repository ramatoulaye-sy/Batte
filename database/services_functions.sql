-- =====================================================
-- FONCTIONS EDGE SUPABASE POUR LE MODULE SERVICES
-- =====================================================

-- =====================================================
-- 1. FONCTION: Créer un profil prestataire
-- =====================================================

CREATE OR REPLACE FUNCTION create_service_provider(
    p_bio TEXT DEFAULT NULL,
    p_skills TEXT[] DEFAULT NULL,
    p_zones TEXT[] DEFAULT NULL,
    p_languages TEXT[] DEFAULT ARRAY['fr']
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID;
    v_provider_id UUID;
    v_result JSON;
BEGIN
    -- Vérifier l'authentification
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Non authentifié'
        );
    END IF;

    -- Vérifier si le profil existe déjà
    IF EXISTS (SELECT 1 FROM service_providers WHERE user_id = v_user_id) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Profil prestataire déjà existant'
        );
    END IF;

    -- Créer le profil prestataire
    INSERT INTO service_providers (
        user_id, bio, skills, zones, languages
    ) VALUES (
        v_user_id, p_bio, p_skills, p_zones, p_languages
    ) RETURNING id INTO v_provider_id;

    -- Retourner le résultat
    SELECT json_build_object(
        'success', true,
        'provider_id', v_provider_id,
        'message', 'Profil prestataire créé avec succès'
    ) INTO v_result;

    RETURN v_result;

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Erreur lors de la création du profil: ' || SQLERRM
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 2. FONCTION: Créer une offre de service
-- =====================================================

CREATE OR REPLACE FUNCTION create_service_offer(
    p_title VARCHAR(200),
    p_description TEXT,
    p_category VARCHAR(50),
    p_price DECIMAL(10,2) DEFAULT NULL,
    p_price_unit VARCHAR(20) DEFAULT 'fixed',
    p_location VARCHAR(200) DEFAULT NULL,
    p_coverage_radius_km INTEGER DEFAULT 5,
    p_availability_rules JSONB DEFAULT NULL,
    p_photos TEXT[] DEFAULT NULL,
    p_expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID;
    v_provider_id UUID;
    v_offer_id UUID;
    v_result JSON;
BEGIN
    -- Vérifier l'authentification
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Non authentifié'
        );
    END IF;

    -- Récupérer l'ID du prestataire
    SELECT id INTO v_provider_id 
    FROM service_providers 
    WHERE user_id = v_user_id AND is_active = TRUE;

    IF v_provider_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Profil prestataire non trouvé ou inactif'
        );
    END IF;

    -- Créer l'offre
    INSERT INTO service_offers (
        provider_id, title, description, category, price, price_unit,
        location, coverage_radius_km, availability_rules, photos, expires_at
    ) VALUES (
        v_provider_id, p_title, p_description, p_category, p_price, p_price_unit,
        p_location, p_coverage_radius_km, p_availability_rules, p_photos, p_expires_at
    ) RETURNING id INTO v_offer_id;

    -- Retourner le résultat
    SELECT json_build_object(
        'success', true,
        'offer_id', v_offer_id,
        'message', 'Offre créée avec succès'
    ) INTO v_result;

    RETURN v_result;

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Erreur lors de la création de l\'offre: ' || SQLERRM
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 3. FONCTION: Créer une demande de service
-- =====================================================

CREATE OR REPLACE FUNCTION create_service_request(
    p_title VARCHAR(200),
    p_description TEXT,
    p_category VARCHAR(50),
    p_budget DECIMAL(10,2) DEFAULT NULL,
    p_location VARCHAR(200) DEFAULT NULL,
    p_requirements TEXT[] DEFAULT NULL,
    p_offer_id UUID DEFAULT NULL,
    p_scheduled_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID;
    v_request_id UUID;
    v_result JSON;
BEGIN
    -- Vérifier l'authentification
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Non authentifié'
        );
    END IF;

    -- Créer la demande
    INSERT INTO service_requests (
        client_id, offer_id, title, description, category,
        budget, location, requirements, scheduled_at
    ) VALUES (
        v_user_id, p_offer_id, p_title, p_description, p_category,
        p_budget, p_location, p_requirements, p_scheduled_at
    ) RETURNING id INTO v_request_id;

    -- Retourner le résultat
    SELECT json_build_object(
        'success', true,
        'request_id', v_request_id,
        'message', 'Demande créée avec succès'
    ) INTO v_result;

    RETURN v_result;

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Erreur lors de la création de la demande: ' || SQLERRM
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 4. FONCTION: Accepter une demande
-- =====================================================

CREATE OR REPLACE FUNCTION accept_service_request(
    p_request_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID;
    v_provider_id UUID;
    v_request_exists BOOLEAN;
    v_result JSON;
BEGIN
    -- Vérifier l'authentification
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Non authentifié'
        );
    END IF;

    -- Vérifier que l'utilisateur est un prestataire
    SELECT id INTO v_provider_id 
    FROM service_providers 
    WHERE user_id = v_user_id AND is_active = TRUE;

    IF v_provider_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Profil prestataire non trouvé'
        );
    END IF;

    -- Vérifier que la demande existe et est liée à une offre du prestataire
    SELECT EXISTS (
        SELECT 1 FROM service_requests sr
        JOIN service_offers so ON so.id = sr.offer_id
        WHERE sr.id = p_request_id 
        AND so.provider_id = v_provider_id
        AND sr.status = 'pending'
    ) INTO v_request_exists;

    IF NOT v_request_exists THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Demande non trouvée ou déjà traitée'
        );
    END IF;

    -- Accepter la demande
    UPDATE service_requests 
    SET status = 'accepted', updated_at = NOW()
    WHERE id = p_request_id;

    -- Retourner le résultat
    SELECT json_build_object(
        'success', true,
        'message', 'Demande acceptée avec succès'
    ) INTO v_result;

    RETURN v_result;

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Erreur lors de l\'acceptation: ' || SQLERRM
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 5. FONCTION: Marquer un service comme terminé
-- =====================================================

CREATE OR REPLACE FUNCTION complete_service_request(
    p_request_id UUID
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID;
    v_request_exists BOOLEAN;
    v_result JSON;
BEGIN
    -- Vérifier l'authentification
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Non authentifié'
        );
    END IF;

    -- Vérifier que la demande existe et que l'utilisateur est impliqué
    SELECT EXISTS (
        SELECT 1 FROM service_requests sr
        WHERE sr.id = p_request_id 
        AND (sr.client_id = v_user_id OR 
             EXISTS (
                 SELECT 1 FROM service_offers so 
                 JOIN service_providers sp ON sp.id = so.provider_id
                 WHERE so.id = sr.offer_id AND sp.user_id = v_user_id
             ))
        AND sr.status = 'in_progress'
    ) INTO v_request_exists;

    IF NOT v_request_exists THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Demande non trouvée ou non en cours'
        );
    END IF;

    -- Marquer comme terminé
    UPDATE service_requests 
    SET status = 'completed', completed_at = NOW(), updated_at = NOW()
    WHERE id = p_request_id;

    -- Retourner le résultat
    SELECT json_build_object(
        'success', true,
        'message', 'Service marqué comme terminé'
    ) INTO v_result;

    RETURN v_result;

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Erreur lors de la finalisation: ' || SQLERRM
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 6. FONCTION: Envoyer un message
-- =====================================================

CREATE OR REPLACE FUNCTION send_service_message(
    p_request_id UUID,
    p_content TEXT,
    p_attachments TEXT[] DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID;
    v_request_exists BOOLEAN;
    v_message_id UUID;
    v_result JSON;
BEGIN
    -- Vérifier l'authentification
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Non authentifié'
        );
    END IF;

    -- Vérifier que l'utilisateur peut envoyer des messages pour cette demande
    SELECT EXISTS (
        SELECT 1 FROM service_requests sr 
        WHERE sr.id = p_request_id AND (
            sr.client_id = v_user_id OR
            EXISTS (
                SELECT 1 FROM service_offers so 
                JOIN service_providers sp ON sp.id = so.provider_id
                WHERE so.id = sr.offer_id AND sp.user_id = v_user_id
            )
        )
    ) INTO v_request_exists;

    IF NOT v_request_exists THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Accès non autorisé à cette demande'
        );
    END IF;

    -- Envoyer le message
    INSERT INTO service_messages (
        request_id, sender_id, content, attachments
    ) VALUES (
        p_request_id, v_user_id, p_content, p_attachments
    ) RETURNING id INTO v_message_id;

    -- Retourner le résultat
    SELECT json_build_object(
        'success', true,
        'message_id', v_message_id,
        'message', 'Message envoyé avec succès'
    ) INTO v_result;

    RETURN v_result;

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Erreur lors de l\'envoi du message: ' || SQLERRM
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 7. FONCTION: Noter un service
-- =====================================================

CREATE OR REPLACE FUNCTION rate_service(
    p_request_id UUID,
    p_rating INTEGER,
    p_comment TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID;
    v_reviewee_id UUID;
    v_request_exists BOOLEAN;
    v_review_id UUID;
    v_result JSON;
BEGIN
    -- Vérifier l'authentification
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Non authentifié'
        );
    END IF;

    -- Vérifier que la demande est terminée et que l'utilisateur peut la noter
    SELECT EXISTS (
        SELECT 1 FROM service_requests sr 
        WHERE sr.id = p_request_id 
        AND sr.status = 'completed'
        AND sr.client_id = v_user_id
    ) INTO v_request_exists;

    IF NOT v_request_exists THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Demande non trouvée ou non terminée'
        );
    END IF;

    -- Récupérer l'ID de la personne à noter (le prestataire)
    SELECT so.provider_id INTO v_reviewee_id
    FROM service_requests sr
    JOIN service_offers so ON so.id = sr.offer_id
    WHERE sr.id = p_request_id;

    -- Vérifier qu'il n'y a pas déjà une note
    IF EXISTS (
        SELECT 1 FROM service_reviews 
        WHERE request_id = p_request_id AND reviewer_id = v_user_id
    ) THEN
        RETURN json_build_object(
            'success', false,
            'error', 'Note déjà donnée pour ce service'
        );
    END IF;

    -- Créer la note
    INSERT INTO service_reviews (
        request_id, reviewer_id, reviewee_id, rating, comment
    ) VALUES (
        p_request_id, v_user_id, v_reviewee_id, p_rating, p_comment
    ) RETURNING id INTO v_review_id;

    -- Mettre à jour la note moyenne du prestataire
    UPDATE service_providers 
    SET rating = (
        SELECT AVG(rating)::DECIMAL(3,2) 
        FROM service_reviews 
        WHERE reviewee_id = service_providers.id
    )
    WHERE id = v_reviewee_id;

    -- Retourner le résultat
    SELECT json_build_object(
        'success', true,
        'review_id', v_review_id,
        'message', 'Note enregistrée avec succès'
    ) INTO v_result;

    RETURN v_result;

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Erreur lors de l\'enregistrement de la note: ' || SQLERRM
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 8. FONCTION: Rechercher des services
-- =====================================================

CREATE OR REPLACE FUNCTION search_services(
    p_query TEXT DEFAULT NULL,
    p_category VARCHAR(50) DEFAULT NULL,
    p_location VARCHAR(200) DEFAULT NULL,
    p_max_price DECIMAL(10,2) DEFAULT NULL,
    p_limit INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_services JSON;
BEGIN
    -- Construire la requête de recherche
    WITH filtered_services AS (
        SELECT 
            so.*,
            sp.user_id as provider_user_id,
            sp.bio as provider_bio,
            sp.rating as provider_rating,
            sp.total_jobs as provider_total_jobs,
            sp.completed_jobs as provider_completed_jobs,
            sp.is_verified as provider_verified
        FROM service_offers so
        JOIN service_providers sp ON sp.id = so.provider_id
        WHERE so.is_active = TRUE 
        AND sp.is_active = TRUE
        AND (p_query IS NULL OR to_tsvector('french', so.title || ' ' || so.description) @@ plainto_tsquery('french', p_query))
        AND (p_category IS NULL OR so.category = p_category)
        AND (p_location IS NULL OR so.location ILIKE '%' || p_location || '%')
        AND (p_max_price IS NULL OR so.price IS NULL OR so.price <= p_max_price)
        ORDER BY 
            sp.is_verified DESC,
            sp.rating DESC,
            so.created_at DESC
        LIMIT p_limit OFFSET p_offset
    )
    SELECT json_agg(
        json_build_object(
            'id', id,
            'title', title,
            'description', description,
            'category', category,
            'price', price,
            'price_unit', price_unit,
            'location', location,
            'coverage_radius_km', coverage_radius_km,
            'photos', photos,
            'created_at', created_at,
            'provider', json_build_object(
                'user_id', provider_user_id,
                'bio', provider_bio,
                'rating', provider_rating,
                'total_jobs', provider_total_jobs,
                'completed_jobs', provider_completed_jobs,
                'is_verified', provider_verified
            )
        )
    ) INTO v_services
    FROM filtered_services;

    -- Retourner le résultat
    SELECT json_build_object(
        'success', true,
        'services', COALESCE(v_services, '[]'::json),
        'count', COALESCE(json_array_length(v_services), 0)
    ) INTO v_result;

    RETURN v_result;

EXCEPTION WHEN OTHERS THEN
    RETURN json_build_object(
        'success', false,
        'error', 'Erreur lors de la recherche: ' || SQLERRM
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION create_service_provider IS 'Créer un profil prestataire';
COMMENT ON FUNCTION create_service_offer IS 'Créer une offre de service';
COMMENT ON FUNCTION create_service_request IS 'Créer une demande de service';
COMMENT ON FUNCTION accept_service_request IS 'Accepter une demande de service';
COMMENT ON FUNCTION complete_service_request IS 'Marquer un service comme terminé';
COMMENT ON FUNCTION send_service_message IS 'Envoyer un message dans une demande';
COMMENT ON FUNCTION rate_service IS 'Noter un service terminé';
COMMENT ON FUNCTION search_services IS 'Rechercher des services avec filtres';
