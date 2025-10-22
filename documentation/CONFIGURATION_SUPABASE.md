# 🚀 Configuration Supabase pour Battè

## ✅ Backend 100% Supabase (Sans Node.js)

Le backend Node.js a été **complètement supprimé** et remplacé par **Supabase**.

---

## 📋 Étapes de Configuration

### 1️⃣ Créer le fichier `.env` à la racine du projet

Créer manuellement un fichier nommé **`.env`** (sans `.txt`) dans le dossier `C:\Users\USER\Desktop\Batte\batte\` avec le contenu suivant :

```env
# Supabase (Backend complet)
SUPABASE_URL=https://zhtnqugrcubrtjvpdzty.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpodG5xdWdyY3VicnRqdnBkenR5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyNTk4ODMsImV4cCI6MjA3MDgzNTg4M30.Ci7BHifhK098NZUwRphvRew5T_DCoA17leVg3Z1daaY

# Firebase (Notifications uniquement)
FIREBASE_API_KEY=your-firebase-api-key

# Bluetooth (Poubelle intelligente)
BIN_DEVICE_NAME=BATTE_BIN
BIN_SERVICE_UUID=4fafc201-1fb5-459e-8fcc-c5c9c331914b

# Environment
ENVIRONMENT=development
```

---

### 2️⃣ Configurer Supabase Auth pour les OTP SMS

#### a) Activer Phone Auth dans Supabase

1. Va sur [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Sélectionne ton projet **Battè**
3. Va dans **Authentication** → **Providers**
4. Active **Phone**

#### b) Configurer Twilio pour les SMS (Optionnel)

**Note:** Supabase peut utiliser son propre service d'envoi de SMS en mode test, mais pour la production, tu dois configurer Twilio ou MessageBird.

**Pour le développement (mode test) :**
- Supabase génère un faux OTP que tu peux voir dans les logs
- Pas besoin de Twilio pour tester

**Pour la production :**
1. Crée un compte Twilio : [https://www.twilio.com/try-twilio](https://www.twilio.com/try-twilio)
2. Obtiens ton **Account SID** et **Auth Token**
3. Achète un numéro de téléphone Twilio
4. Dans Supabase Dashboard → **Authentication** → **Providers** → **Phone**
5. Configure Twilio :
   - **Twilio Account SID**
   - **Twilio Auth Token**
   - **Twilio Phone Number**

---

### 3️⃣ Activer Row Level Security (RLS) dans Supabase

Pour sécuriser les données, tu dois activer **Row Level Security** sur toutes les tables.

#### Script SQL à exécuter dans Supabase SQL Editor :

```sql
-- Activer RLS sur toutes les tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.waste_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.waste_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.collectors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.education_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_education_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fcm_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enterprise_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saving_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.withdrawal_transactions ENABLE ROW LEVEL SECURITY;

-- Politique RLS pour la table "users"
CREATE POLICY "Users can view own profile" 
ON public.users FOR SELECT 
USING (auth.uid()::text = id::text);

CREATE POLICY "Users can update own profile" 
ON public.users FOR UPDATE 
USING (auth.uid()::text = id::text);

CREATE POLICY "Users can insert own profile" 
ON public.users FOR INSERT 
WITH CHECK (auth.uid()::text = id::text);

-- Politique RLS pour la table "waste_transactions"
CREATE POLICY "Users can view own waste transactions" 
ON public.waste_transactions FOR SELECT 
USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own waste transactions" 
ON public.waste_transactions FOR INSERT 
WITH CHECK (auth.uid()::text = user_id::text);

-- Politique RLS pour "waste_types" (lecture publique)
CREATE POLICY "Anyone can view waste types" 
ON public.waste_types FOR SELECT 
USING (true);

-- Politique RLS pour "education_content" (lecture publique)
CREATE POLICY "Anyone can view education content" 
ON public.education_content FOR SELECT 
USING (true);

-- Politique RLS pour "user_education_progress"
CREATE POLICY "Users can manage own education progress" 
ON public.user_education_progress FOR ALL 
USING (auth.uid()::text = user_id::text);

-- Politique RLS pour "jobs" (lecture publique, création par utilisateur connecté)
CREATE POLICY "Anyone can view jobs" 
ON public.jobs FOR SELECT 
USING (true);

CREATE POLICY "Authenticated users can create jobs" 
ON public.jobs FOR INSERT 
WITH CHECK (auth.uid()::text = user_id::text);

-- Politique RLS pour "collectors" (lecture publique)
CREATE POLICY "Anyone can view collectors" 
ON public.collectors FOR SELECT 
USING (true);

-- Politique RLS pour "notifications"
CREATE POLICY "Users can view own notifications" 
ON public.notifications FOR SELECT 
USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own notifications" 
ON public.notifications FOR UPDATE 
USING (auth.uid()::text = user_id::text);
```

---

### 4️⃣ Créer des fonctions SQL pour les statistiques

Exécute ce script dans Supabase SQL Editor :

```sql
-- Fonction pour calculer les statistiques de déchets d'un utilisateur
CREATE OR REPLACE FUNCTION get_waste_stats(user_id uuid)
RETURNS json AS $$
DECLARE
  result json;
BEGIN
  SELECT json_build_object(
    'total_weight_kg', COALESCE(SUM(weight_kg), 0),
    'total_amount_gnf', COALESCE(SUM(amount_gnf), 0),
    'total_transactions', COUNT(*)
  ) INTO result
  FROM waste_transactions
  WHERE waste_transactions.user_id = get_waste_stats.user_id;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour mettre à jour le solde et les points d'un utilisateur
CREATE OR REPLACE FUNCTION update_user_balance_and_points(
  user_id uuid,
  amount numeric,
  points integer
)
RETURNS void AS $$
BEGIN
  UPDATE users
  SET 
    balance = balance + amount,
    points = users.points + points,
    updated_at = NOW()
  WHERE id = update_user_balance_and_points.user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour trouver les collecteurs à proximité
CREATE OR REPLACE FUNCTION get_nearby_collectors(
  user_lat double precision,
  user_lng double precision,
  radius_km double precision DEFAULT 10.0
)
RETURNS TABLE (
  id uuid,
  business_name varchar,
  rating numeric,
  distance_km double precision
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.business_name,
    c.rating,
    (6371 * acos(
      cos(radians(user_lat)) * 
      cos(radians(c.current_location_lat)) * 
      cos(radians(c.current_location_lng) - radians(user_lng)) + 
      sin(radians(user_lat)) * 
      sin(radians(c.current_location_lat))
    )) AS distance_km
  FROM collectors c
  WHERE c.is_available = true
  HAVING distance_km <= radius_km
  ORDER BY distance_km;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 🎯 Comment utiliser

### Démarrer l'application Flutter

```powershell
# 1. Installer les dépendances
flutter pub get

# 2. Lancer l'application
flutter run
```

**C'est tout !** Plus besoin de démarrer un serveur Node.js ni de configurer `adb reverse`. 🎉

---

## 📱 Test de l'inscription

1. Lance l'application : `flutter run`
2. Clique sur **"S'inscrire"**
3. Entre ton **numéro de téléphone** (format: +224612345678)
4. Entre ton **nom**
5. Clique sur **"Continuer"**
6. **En mode développement** :
   - Supabase affiche le code OTP dans les logs
   - Ou va dans Supabase Dashboard → **Authentication** → **Users** pour voir l'OTP
7. Entre le code OTP
8. Tu es connecté ! ✅

---

## 🔒 Avantages de cette nouvelle architecture

✅ **Pas de serveur backend** à gérer  
✅ **Pas de problèmes de port** ou d'adresse IP  
✅ **Authentification sécurisée** par Supabase Auth  
✅ **API REST automatique** générée  
✅ **Row Level Security** pour protéger les données  
✅ **Temps réel** avec WebSockets intégré  
✅ **Stockage de fichiers** inclus  
✅ **Gratuit** jusqu'à 500 Mo  

---

## 🛠️ En cas de problème

### Problème 1 : "SUPABASE_URL ou SUPABASE_ANON_KEY manquant"

**Solution :** Vérifie que le fichier `.env` existe bien à la racine du projet et qu'il contient les bonnes valeurs.

### Problème 2 : "Session invalide après vérification OTP"

**Solution :** Vérifie que Phone Auth est bien activé dans Supabase Dashboard → **Authentication** → **Providers**.

### Problème 3 : "Code OTP non reçu"

**Solution :** 
- En mode développement, le code OTP s'affiche dans les logs Supabase.
- Pour la production, configure Twilio dans Supabase.

---

## 📞 Support

Si tu rencontres des problèmes, envoie-moi :
1. Les logs Flutter (après `flutter run`)
2. Les logs Supabase (dans le Dashboard → **Logs**)
3. Une capture d'écran de l'erreur

---

**Bonne chance avec Battè ! 🎉**

