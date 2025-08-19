-- =====================================================
-- SCHÉMA DE BASE DE DONNÉES BATTE
-- Application de valorisation des déchets
-- =====================================================

-- Extension pour UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABLE DES UTILISATEURS
-- =====================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    avatar_url TEXT,
    location_lat DOUBLE PRECISION DEFAULT 9.5370, -- Conakry par défaut
    location_lng DOUBLE PRECISION DEFAULT -13.6785,
    address TEXT,
    city VARCHAR(100) DEFAULT 'Conakry',
    country VARCHAR(100) DEFAULT 'Guinée',
    points INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1,
    balance DECIMAL(10,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE DES COLLECTEURS
-- =====================================================
CREATE TABLE collectors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    business_name VARCHAR(200),
    license_number VARCHAR(100),
    vehicle_info TEXT,
    service_area_radius INTEGER DEFAULT 20, -- km
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_collections INTEGER DEFAULT 0,
    total_earnings DECIMAL(10,2) DEFAULT 0.00,
    is_available BOOLEAN DEFAULT true,
    current_location_lat DOUBLE PRECISION,
    current_location_lng DOUBLE PRECISION,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE DES TYPES DE DÉCHETS
-- =====================================================
CREATE TABLE waste_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price_per_kg DECIMAL(8,2) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE DES TRANSACTIONS DE DÉCHETS
-- =====================================================
CREATE TABLE waste_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    waste_type_id UUID REFERENCES waste_types(id),
    weight_kg DECIMAL(6,3) NOT NULL,
    amount_gnf DECIMAL(8,2) NOT NULL,
    points_earned INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending', -- pending, collected, completed, cancelled
    collection_date TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE DES COLLECTES
-- =====================================================
CREATE TABLE collections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    collector_id UUID REFERENCES collectors(id),
    waste_transaction_id UUID REFERENCES waste_transactions(id),
    status VARCHAR(50) DEFAULT 'requested', -- requested, accepted, in_progress, completed, cancelled
    requested_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    accepted_at TIMESTAMP WITH TIME ZONE,
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    actual_weight_kg DECIMAL(6,3),
    actual_amount_gnf DECIMAL(8,2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE DES PAIEMENTS
-- =====================================================
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    collection_id UUID REFERENCES collections(id),
    amount DECIMAL(8,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL, -- orange_money, mtn_money, moov_money, bank_transfer
    transaction_id VARCHAR(200),
    status VARCHAR(50) DEFAULT 'pending', -- pending, completed, failed, refunded
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE DES NOTATIONS
-- =====================================================
CREATE TABLE ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    collector_id UUID REFERENCES collectors(id),
    collection_id UUID REFERENCES collections(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    is_anonymous BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE DES STOCKS
-- =====================================================
CREATE TABLE stocks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    collector_id UUID REFERENCES collectors(id) ON DELETE CASCADE,
    waste_type_id UUID REFERENCES waste_types(id),
    quantity_kg DECIMAL(8,3) NOT NULL,
    price_per_kg DECIMAL(8,2) NOT NULL,
    location_lat DOUBLE PRECISION,
    location_lng DOUBLE PRECISION,
    description TEXT,
    is_available BOOLEAN DEFAULT true,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE DES COMMANDES D'ENTREPRISE
-- =====================================================
CREATE TABLE enterprise_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    enterprise_name VARCHAR(200) NOT NULL,
    enterprise_contact VARCHAR(100),
    enterprise_phone VARCHAR(20),
    stock_id UUID REFERENCES stocks(id),
    quantity_requested DECIMAL(8,3) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending', -- pending, confirmed, in_progress, delivered, cancelled
    delivery_address TEXT,
    delivery_date TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE DES NOTIFICATIONS
-- =====================================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    is_read BOOLEAN DEFAULT false,
    data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE DES TOKENS FCM
-- =====================================================
CREATE TABLE fcm_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    device_info JSONB,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE DES RÉFÉRENCES
-- =====================================================
CREATE TABLE referrals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    referrer_id UUID REFERENCES users(id) ON DELETE CASCADE,
    referred_id UUID REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(50) DEFAULT 'pending', -- pending, completed, expired
    points_awarded INTEGER DEFAULT 0,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLE DES ACTIVITÉS
-- =====================================================
CREATE TABLE user_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    activity_type VARCHAR(100) NOT NULL,
    description TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- INDEX POUR LES PERFORMANCES
-- =====================================================

-- Index sur les utilisateurs
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_location ON users(location_lat, location_lng);
CREATE INDEX idx_users_points ON users(points);
CREATE INDEX idx_users_level ON users(level);

-- Index sur les collecteurs
CREATE INDEX idx_collectors_user_id ON collectors(user_id);
CREATE INDEX idx_collectors_location ON collectors(current_location_lat, current_location_lng);
CREATE INDEX idx_collectors_rating ON collectors(rating);
CREATE INDEX idx_collectors_available ON collectors(is_available);

-- Index sur les transactions
CREATE INDEX idx_waste_transactions_user_id ON waste_transactions(user_id);
CREATE INDEX idx_waste_transactions_status ON waste_transactions(status);
CREATE INDEX idx_waste_transactions_created_at ON waste_transactions(created_at);

-- Index sur les collectes
CREATE INDEX idx_collections_user_id ON collections(user_id);
CREATE INDEX idx_collections_collector_id ON collections(collector_id);
CREATE INDEX idx_collections_status ON collections(status);
CREATE INDEX idx_collections_requested_at ON collections(requested_at);

-- Index sur les paiements
CREATE INDEX idx_payments_collection_id ON payments(collection_id);
CREATE INDEX idx_payments_status ON payments(status);

-- Index sur les notations
CREATE INDEX idx_ratings_user_id ON ratings(user_id);
CREATE INDEX idx_ratings_collector_id ON ratings(collector_id);
CREATE INDEX idx_ratings_rating ON ratings(rating);

-- Index sur les stocks
CREATE INDEX idx_stocks_collector_id ON stocks(collector_id);
CREATE INDEX idx_stocks_waste_type_id ON stocks(waste_type_id);
CREATE INDEX idx_stocks_available ON stocks(is_available);

-- Index sur les notifications
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- =====================================================
-- DONNÉES INITIALES
-- =====================================================

-- Types de déchets par défaut
INSERT INTO waste_types (name, category, price_per_kg, description) VALUES
('Plastique PET', 'plastic', 150.00, 'Bouteilles et emballages en plastique PET'),
('Plastique HDPE', 'plastic', 180.00, 'Bouteilles et emballages en plastique HDPE'),
('Déchets organiques', 'organic', 100.00, 'Déchets alimentaires et végétaux'),
('Verre', 'glass', 200.00, 'Bouteilles et récipients en verre'),
('Métal ferreux', 'metal', 300.00, 'Fer, acier et métaux ferreux'),
('Métal non-ferreux', 'metal', 400.00, 'Aluminium, cuivre et métaux précieux'),
('Papier blanc', 'paper', 120.00, 'Papier blanc et carton propre'),
('Papier mixte', 'paper', 100.00, 'Papier et carton mélangés'),
('Électronique', 'electronics', 500.00, 'Appareils électroniques et composants'),
('Textiles', 'textiles', 80.00, 'Vêtements et tissus usagés');

-- =====================================================
-- FONCTIONS ET TRIGGERS
-- =====================================================

-- Fonction pour mettre à jour le timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers pour mettre à jour les timestamps
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_collectors_updated_at BEFORE UPDATE ON collectors FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_waste_transactions_updated_at BEFORE UPDATE ON waste_transactions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_collections_updated_at BEFORE UPDATE ON collections FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_stocks_updated_at BEFORE UPDATE ON stocks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_enterprise_orders_updated_at BEFORE UPDATE ON enterprise_orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_fcm_tokens_updated_at BEFORE UPDATE ON fcm_tokens FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Fonction pour calculer les points
CREATE OR REPLACE FUNCTION calculate_points(weight_kg DECIMAL, waste_type_id UUID)
RETURNS INTEGER AS $$
DECLARE
    points INTEGER;
BEGIN
    -- 1 point par kg de base
    points := FLOOR(weight_kg);
    
    -- Bonus selon le type de déchet
    IF waste_type_id IN (SELECT id FROM waste_types WHERE category IN ('electronics', 'metal')) THEN
        points := points + 1; -- Bonus pour les déchets précieux
    END IF;
    
    RETURN points;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour calculer le niveau
CREATE OR REPLACE FUNCTION calculate_level(points INTEGER)
RETURNS INTEGER AS $$
BEGIN
    IF points < 10 THEN RETURN 1;
    ELSIF points < 25 THEN RETURN 2;
    ELSIF points < 50 THEN RETURN 3;
    ELSIF points < 100 THEN RETURN 4;
    ELSIF points < 200 THEN RETURN 5;
    ELSIF points < 400 THEN RETURN 6;
    ELSIF points < 800 THEN RETURN 7;
    ELSIF points < 1600 THEN RETURN 8;
    ELSIF points < 3200 THEN RETURN 9;
    ELSE RETURN 10;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- POLITIQUES DE SÉCURITÉ RLS (Row Level Security)
-- =====================================================

-- Activer RLS sur toutes les tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE collectors ENABLE ROW LEVEL SECURITY;
ALTER TABLE waste_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE stocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE enterprise_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE fcm_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_activities ENABLE ROW LEVEL SECURITY;

-- Politiques de base (à personnaliser selon vos besoins)
-- Les utilisateurs peuvent voir et modifier leurs propres données
-- Les collecteurs peuvent voir les demandes de collecte dans leur zone
-- Les administrateurs ont accès à tout

-- Exemple de politique pour les utilisateurs
CREATE POLICY "Users can view own data" ON users
    FOR SELECT USING (auth.uid()::text = id::text);

CREATE POLICY "Users can update own data" ON users
    FOR UPDATE USING (auth.uid()::text = id::text);

-- =====================================================
-- COMMENTAIRES
-- =====================================================

COMMENT ON TABLE users IS 'Table des utilisateurs de l''application Batte';
COMMENT ON TABLE collectors IS 'Table des collecteurs de déchets';
COMMENT ON TABLE waste_types IS 'Types de déchets et leurs prix';
COMMENT ON TABLE waste_transactions IS 'Transactions de vente de déchets';
COMMENT ON TABLE collections IS 'Demandes et suivi des collectes';
COMMENT ON TABLE payments IS 'Paiements pour les collectes';
COMMENT ON TABLE ratings IS 'Notations des collecteurs par les utilisateurs';
COMMENT ON TABLE stocks IS 'Stocks de déchets disponibles à la vente';
COMMENT ON TABLE enterprise_orders IS 'Commandes des entreprises';
COMMENT ON TABLE notifications IS 'Notifications push et in-app';
COMMENT ON TABLE fcm_tokens IS 'Tokens Firebase Cloud Messaging';
COMMENT ON TABLE referrals IS 'Système de parrainage';
COMMENT ON TABLE user_activities IS 'Historique des activités utilisateur';

-- =====================================================
-- FIN DU SCHÉMA
-- =====================================================
