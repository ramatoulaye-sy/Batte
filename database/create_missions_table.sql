-- =====================================================
-- TABLE : MISSIONS (Missions quotidiennes/hebdomadaires)
-- =====================================================

-- Table des missions disponibles
CREATE TABLE IF NOT EXISTS public.missions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  type VARCHAR(20) DEFAULT 'daily' NOT NULL, -- 'daily' ou 'weekly'
  category VARCHAR(50) DEFAULT 'recycling' NOT NULL, -- 'recycling', 'social', 'learning'
  target_value NUMERIC NOT NULL, -- Valeur cible (ex: 5 pour "recycler 5kg")
  target_unit VARCHAR(50) DEFAULT 'kg' NOT NULL, -- 'kg', 'items', 'points', 'users'
  reward_points INTEGER DEFAULT 10 NOT NULL, -- Points gagnés
  reward_badge VARCHAR(100), -- Badge optionnel (ex: 'eco_warrior')
  icon VARCHAR(50) DEFAULT '🎯', -- Icône de la mission
  is_active BOOLEAN DEFAULT TRUE NOT NULL,
  start_date DATE DEFAULT CURRENT_DATE,
  end_date DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Table de progression des missions par utilisateur
CREATE TABLE IF NOT EXISTS public.user_missions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  mission_id UUID REFERENCES public.missions(id) ON DELETE CASCADE NOT NULL,
  progress NUMERIC DEFAULT 0 NOT NULL, -- Progression actuelle
  is_completed BOOLEAN DEFAULT FALSE NOT NULL,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  UNIQUE(user_id, mission_id)
);

-- Index pour optimiser les requêtes
CREATE INDEX IF NOT EXISTS idx_missions_type ON public.missions(type);
CREATE INDEX IF NOT EXISTS idx_missions_active ON public.missions(is_active);
CREATE INDEX IF NOT EXISTS idx_user_missions_user ON public.user_missions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_missions_completed ON public.user_missions(is_completed);

-- Trigger pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_user_missions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_user_missions_updated_at
  BEFORE UPDATE ON public.user_missions
  FOR EACH ROW
  EXECUTE FUNCTION update_user_missions_updated_at();

-- =====================================================
-- DONNÉES DE DÉMONSTRATION
-- =====================================================

-- Missions quotidiennes
INSERT INTO public.missions (title, description, type, category, target_value, target_unit, reward_points, icon) VALUES
  ('Premier recyclage du jour', 'Recycle tes premiers déchets aujourd''hui', 'daily', 'recycling', 1, 'items', 10, '🌱'),
  ('Recycler 5 kg', 'Atteins 5 kg de déchets recyclés aujourd''hui', 'daily', 'recycling', 5, 'kg', 25, '♻️'),
  ('3 transactions', 'Effectue 3 transactions de recyclage', 'daily', 'recycling', 3, 'items', 20, '💰'),
  ('Partage l''app', 'Partage Battè avec un ami', 'daily', 'social', 1, 'users', 15, '📲'),
  ('Visite la section Éducation', 'Consulte un contenu éducatif', 'daily', 'learning', 1, 'items', 10, '📚');

-- Missions hebdomadaires
INSERT INTO public.missions (title, description, type, category, target_value, target_unit, reward_points, reward_badge, icon) VALUES
  ('Champion du recyclage', 'Recycle 25 kg de déchets cette semaine', 'weekly', 'recycling', 25, 'kg', 100, 'eco_champion', '🏆'),
  ('Parraine 3 amis', 'Invite 3 nouveaux utilisateurs cette semaine', 'weekly', 'social', 3, 'users', 150, 'ambassador', '🎖️'),
  ('Série de 7 jours', 'Recycle au moins une fois par jour pendant 7 jours', 'weekly', 'recycling', 7, 'items', 200, 'streak_master', '🔥'),
  ('Expert écolo', 'Gagne 500 points d''éco-score cette semaine', 'weekly', 'learning', 500, 'points', 80, 'eco_expert', '⭐');

-- =====================================================
-- POLITIQUE DE SÉCURITÉ (RLS)
-- =====================================================

-- Activer RLS
ALTER TABLE public.missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_missions ENABLE ROW LEVEL SECURITY;

-- Politique : Tout le monde peut lire les missions actives
CREATE POLICY "Missions publiques" ON public.missions
  FOR SELECT
  USING (is_active = true);

-- Politique : Les utilisateurs peuvent voir leurs propres progressions
CREATE POLICY "Voir ses missions" ON public.user_missions
  FOR SELECT
  USING (auth.uid() = user_id);

-- Politique : Les utilisateurs peuvent créer leurs progressions
CREATE POLICY "Créer ses missions" ON public.user_missions
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Politique : Les utilisateurs peuvent mettre à jour leurs progressions
CREATE POLICY "Mettre à jour ses missions" ON public.user_missions
  FOR UPDATE
  USING (auth.uid() = user_id);

-- =====================================================
-- FONCTION : Assigner automatiquement les missions actives à un utilisateur
-- =====================================================

CREATE OR REPLACE FUNCTION assign_active_missions_to_user(p_user_id UUID)
RETURNS void AS $$
BEGIN
  INSERT INTO public.user_missions (user_id, mission_id, progress)
  SELECT p_user_id, m.id, 0
  FROM public.missions m
  WHERE m.is_active = true
    AND NOT EXISTS (
      SELECT 1 FROM public.user_missions um
      WHERE um.user_id = p_user_id AND um.mission_id = m.id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- FONCTION : Mettre à jour la progression d'une mission
-- =====================================================

CREATE OR REPLACE FUNCTION update_mission_progress(
  p_user_id UUID,
  p_mission_id UUID,
  p_progress_increment NUMERIC
)
RETURNS JSON AS $$
DECLARE
  v_mission RECORD;
  v_new_progress NUMERIC;
  v_is_completed BOOLEAN;
BEGIN
  -- Récupérer la mission et la progression actuelle
  SELECT m.target_value, COALESCE(um.progress, 0) + p_progress_increment AS new_progress
  INTO v_mission
  FROM public.missions m
  LEFT JOIN public.user_missions um ON um.mission_id = m.id AND um.user_id = p_user_id
  WHERE m.id = p_mission_id;

  v_new_progress := v_mission.new_progress;
  v_is_completed := v_new_progress >= v_mission.target_value;

  -- Insérer ou mettre à jour la progression
  INSERT INTO public.user_missions (user_id, mission_id, progress, is_completed, completed_at)
  VALUES (p_user_id, p_mission_id, v_new_progress, v_is_completed, CASE WHEN v_is_completed THEN NOW() ELSE NULL END)
  ON CONFLICT (user_id, mission_id)
  DO UPDATE SET
    progress = v_new_progress,
    is_completed = v_is_completed,
    completed_at = CASE WHEN v_is_completed AND user_missions.completed_at IS NULL THEN NOW() ELSE user_missions.completed_at END;

  RETURN json_build_object(
    'success', true,
    'progress', v_new_progress,
    'is_completed', v_is_completed
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- NOTES D'UTILISATION
-- =====================================================

-- Pour assigner les missions actives à un nouvel utilisateur :
-- SELECT assign_active_missions_to_user('USER_UUID');

-- Pour mettre à jour la progression (ex: +2 kg recyclés) :
-- SELECT update_mission_progress('USER_UUID', 'MISSION_UUID', 2);

