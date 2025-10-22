-- =====================================================
-- SCHÉMA SUPABASE POUR LE MODULE SERVICES
-- =====================================================

-- Extension pour UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. TABLES PRINCIPALES
-- =====================================================

-- Table des prestataires de services
CREATE TABLE IF NOT EXISTS service_providers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    bio TEXT,
    skills TEXT[], -- ['Nettoyage', 'Cuisine', 'Éducation']
    zones TEXT[], -- ['Kaloum', 'Dixinn', 'Matam']
    languages TEXT[] DEFAULT ARRAY['fr'], -- ['fr', 'en', 'sousan']
    rating DECIMAL(3,2) DEFAULT 0.0,
    total_jobs INTEGER DEFAULT 0,
    completed_jobs INTEGER DEFAULT 0,
    response_time_minutes INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des offres de services
CREATE TABLE IF NOT EXISTS service_offers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID NOT NULL REFERENCES service_providers(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL, -- 'cleaning', 'cooking', 'education', etc.
    price DECIMAL(10,2), -- Prix en GNF
    price_unit VARCHAR(20) DEFAULT 'fixed', -- 'fixed', 'hourly', 'daily'
    location VARCHAR(200),
    coverage_radius_km INTEGER DEFAULT 5,
    availability_rules JSONB, -- {"weekdays": [1,2,3,4,5], "weekends": true, "hours": "08:00-18:00"}
    photos TEXT[], -- URLs des photos
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des demandes de services
CREATE TABLE IF NOT EXISTS service_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    offer_id UUID REFERENCES service_offers(id) ON DELETE SET NULL, -- NULL si demande générale
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    budget DECIMAL(10,2), -- Budget maximum en GNF
    location VARCHAR(200),
    requirements TEXT[], -- Exigences particulières
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'accepted', 'in_progress', 'completed', 'cancelled'
    scheduled_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des messages entre clients et prestataires
CREATE TABLE IF NOT EXISTS service_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id UUID NOT NULL REFERENCES service_requests(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    attachments TEXT[], -- URLs des fichiers joints
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des avis et notes
CREATE TABLE IF NOT EXISTS service_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id UUID NOT NULL REFERENCES service_requests(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reviewee_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des paiements
CREATE TABLE IF NOT EXISTS service_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id UUID NOT NULL REFERENCES service_requests(id) ON DELETE CASCADE,
    amount_gnf DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL, -- 'orange_money', 'mtn_money', 'moov_money', 'bank', 'cash'
    payment_status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'held', 'released', 'refunded'
    transaction_id VARCHAR(200), -- ID de la transaction mobile money
    escrow_released_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table des catégories de services
CREATE TABLE IF NOT EXISTS service_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    icon VARCHAR(10), -- Emoji
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. INDEXES POUR PERFORMANCE
-- =====================================================

-- Indexes pour service_providers
CREATE INDEX IF NOT EXISTS idx_service_providers_user_id ON service_providers(user_id);
CREATE INDEX IF NOT EXISTS idx_service_providers_active ON service_providers(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_service_providers_verified ON service_providers(is_verified) WHERE is_verified = TRUE;

-- Indexes pour service_offers
CREATE INDEX IF NOT EXISTS idx_service_offers_provider ON service_offers(provider_id);
CREATE INDEX IF NOT EXISTS idx_service_offers_category ON service_offers(category);
CREATE INDEX IF NOT EXISTS idx_service_offers_active ON service_offers(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_service_offers_location ON service_offers USING GIN(to_tsvector('french', location));

-- Indexes pour service_requests
CREATE INDEX IF NOT EXISTS idx_service_requests_client ON service_requests(client_id);
CREATE INDEX IF NOT EXISTS idx_service_requests_offer ON service_requests(offer_id);
CREATE INDEX IF NOT EXISTS idx_service_requests_status ON service_requests(status);
CREATE INDEX IF NOT EXISTS idx_service_requests_category ON service_requests(category);
CREATE INDEX IF NOT EXISTS idx_service_requests_scheduled ON service_requests(scheduled_at);

-- Indexes pour service_messages
CREATE INDEX IF NOT EXISTS idx_service_messages_request ON service_messages(request_id);
CREATE INDEX IF NOT EXISTS idx_service_messages_sender ON service_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_service_messages_unread ON service_messages(is_read) WHERE is_read = FALSE;

-- Indexes pour service_reviews
CREATE INDEX IF NOT EXISTS idx_service_reviews_request ON service_reviews(request_id);
CREATE INDEX IF NOT EXISTS idx_service_reviews_reviewee ON service_reviews(reviewee_id);

-- Indexes pour service_payments
CREATE INDEX IF NOT EXISTS idx_service_payments_request ON service_payments(request_id);
CREATE INDEX IF NOT EXISTS idx_service_payments_status ON service_payments(payment_status);

-- =====================================================
-- 3. ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Activer RLS sur toutes les tables
ALTER TABLE service_providers ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_payments ENABLE ROW LEVEL SECURITY;

-- Policies pour service_providers
CREATE POLICY "Users can view all active providers" ON service_providers
    FOR SELECT USING (is_active = TRUE);

CREATE POLICY "Users can manage their own provider profile" ON service_providers
    FOR ALL USING (auth.uid() = user_id::uuid);

-- Policies pour service_offers
CREATE POLICY "Users can view all active offers" ON service_offers
    FOR SELECT USING (is_active = TRUE);

CREATE POLICY "Providers can manage their own offers" ON service_offers
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM service_providers sp 
            WHERE sp.id = provider_id AND sp.user_id = auth.uid()::uuid
        )
    );

-- Policies pour service_requests
CREATE POLICY "Users can view requests they're involved in" ON service_requests
    FOR SELECT USING (
        auth.uid() = client_id::uuid OR
        EXISTS (
            SELECT 1 FROM service_offers so 
            JOIN service_providers sp ON sp.id = so.provider_id
            WHERE so.id = offer_id AND sp.user_id = auth.uid()::uuid
        )
    );

CREATE POLICY "Users can create their own requests" ON service_requests
    FOR INSERT WITH CHECK (auth.uid() = client_id::uuid);

CREATE POLICY "Users can update their own requests" ON service_requests
    FOR UPDATE USING (auth.uid() = client_id::uuid);

-- Policies pour service_messages
CREATE POLICY "Users can view messages for their requests" ON service_messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM service_requests sr 
            WHERE sr.id = request_id AND (
                sr.client_id = auth.uid()::uuid OR
                EXISTS (
                    SELECT 1 FROM service_offers so 
                    JOIN service_providers sp ON sp.id = so.provider_id
                    WHERE so.id = sr.offer_id AND sp.user_id = auth.uid()::uuid
                )
            )
        )
    );

CREATE POLICY "Users can send messages for their requests" ON service_messages
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM service_requests sr 
            WHERE sr.id = request_id AND (
                sr.client_id = auth.uid()::uuid OR
                EXISTS (
                    SELECT 1 FROM service_offers so 
                    JOIN service_providers sp ON sp.id = so.provider_id
                    WHERE so.id = sr.offer_id AND sp.user_id = auth.uid()::uuid
                )
            )
        )
    );

-- Policies pour service_reviews
CREATE POLICY "Users can view reviews for completed requests" ON service_reviews
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM service_requests sr 
            WHERE sr.id = request_id AND sr.status = 'completed'
        )
    );

CREATE POLICY "Users can create reviews for their completed requests" ON service_reviews
    FOR INSERT WITH CHECK (
        auth.uid() = reviewer_id::uuid AND
        EXISTS (
            SELECT 1 FROM service_requests sr 
            WHERE sr.id = request_id AND sr.status = 'completed'
        )
    );

-- Policies pour service_payments
CREATE POLICY "Users can view payments for their requests" ON service_payments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM service_requests sr 
            WHERE sr.id = request_id AND (
                sr.client_id = auth.uid()::uuid OR
                EXISTS (
                    SELECT 1 FROM service_offers so 
                    JOIN service_providers sp ON sp.id = so.provider_id
                    WHERE so.id = sr.offer_id AND sp.user_id = auth.uid()::uuid
                )
            )
        )
    );

-- =====================================================
-- 4. TRIGGERS POUR MISE À JOUR AUTOMATIQUE
-- =====================================================

-- Fonction pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers pour updated_at
CREATE TRIGGER update_service_providers_updated_at 
    BEFORE UPDATE ON service_providers 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_service_offers_updated_at 
    BEFORE UPDATE ON service_offers 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_service_requests_updated_at 
    BEFORE UPDATE ON service_requests 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger pour mettre à jour les statistiques du prestataire
CREATE OR REPLACE FUNCTION update_provider_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.status = 'completed' THEN
        UPDATE service_providers 
        SET completed_jobs = completed_jobs + 1,
            total_jobs = total_jobs + 1
        WHERE id = (
            SELECT so.provider_id 
            FROM service_offers so 
            WHERE so.id = NEW.offer_id
        );
    ELSIF TG_OP = 'UPDATE' AND OLD.status != 'completed' AND NEW.status = 'completed' THEN
        UPDATE service_providers 
        SET completed_jobs = completed_jobs + 1
        WHERE id = (
            SELECT so.provider_id 
            FROM service_offers so 
            WHERE so.id = NEW.offer_id
        );
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_provider_stats_trigger
    AFTER INSERT OR UPDATE ON service_requests
    FOR EACH ROW EXECUTE FUNCTION update_provider_stats();

-- =====================================================
-- 5. DONNÉES INITIALES
-- =====================================================

-- Insérer les catégories de services
INSERT INTO service_categories (name, icon, description) VALUES
('cleaning', '🧹', 'Services de nettoyage et ménage'),
('cooking', '🍳', 'Services de cuisine et restauration'),
('education', '📚', 'Services éducatifs et cours particuliers'),
('technology', '💻', 'Services informatiques et technologiques'),
('agriculture', '🌾', 'Services agricoles et jardinage'),
('commerce', '🛒', 'Services commerciaux et vente'),
('other', '👩🏽‍🔧', 'Autres services')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- 6. VUES UTILES
-- =====================================================

-- Vue pour les offres avec informations du prestataire
CREATE OR REPLACE VIEW service_offers_with_provider AS
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
WHERE so.is_active = TRUE AND sp.is_active = TRUE;

-- Vue pour les demandes avec informations du client
CREATE OR REPLACE VIEW service_requests_with_client AS
SELECT 
    sr.*,
    au.email as client_email,
    au.raw_user_meta_data->>'name' as client_name,
    au.raw_user_meta_data->>'phone' as client_phone
FROM service_requests sr
JOIN auth.users au ON au.id = sr.client_id;

COMMENT ON SCHEMA public IS 'Module Services pour Battè - Marketplace de services à domicile';
