-- Table pour gerer les profils utilisateur/collecteur
-- Un user peut avoir les deux profils
-- Executer dans Supabase SQL Editor

CREATE TABLE IF NOT EXISTS public.user_profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  profile_type TEXT NOT NULL CHECK (profile_type IN ('user', 'collector')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, profile_type)
);

-- Index pour recherche rapide
CREATE INDEX idx_user_profiles_user_id ON public.user_profiles(user_id);
CREATE INDEX idx_user_profiles_type ON public.user_profiles(profile_type);

-- RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Politique: Chacun voit ses propres profils
CREATE POLICY "Users can view own profiles"
  ON public.user_profiles FOR SELECT
  USING (auth.uid() = user_id);

-- Politique: Chacun peut creer ses profils
CREATE POLICY "Users can create own profiles"
  ON public.user_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Fonction helper: Verifier si user a un profil
CREATE OR REPLACE FUNCTION public.user_has_profile(p_user_id UUID, p_profile_type TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE user_id = p_user_id
    AND profile_type = p_profile_type
    AND is_active = true
  );
END;
$$;

-- Fonction: Obtenir les profils d'un user
CREATE OR REPLACE FUNCTION public.get_user_profiles(p_user_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN (
    SELECT COALESCE(
      json_agg(
        json_build_object(
          'profile_type', profile_type,
          'is_active', is_active,
          'created_at', created_at
        )
      ),
      '[]'::json
    )
    FROM public.user_profiles
    WHERE user_id = p_user_id
    AND is_active = true
  );
END;
$$;

-- Permissions
GRANT SELECT, INSERT ON public.user_profiles TO authenticated;
GRANT EXECUTE ON FUNCTION public.user_has_profile TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_profiles TO authenticated;

-- Creer profil user par defaut pour tous les users existants
INSERT INTO public.user_profiles (user_id, profile_type)
SELECT id, 'user'
FROM public.users
ON CONFLICT (user_id, profile_type) DO NOTHING;

-- Verification
SELECT * FROM public.user_profiles LIMIT 5;

