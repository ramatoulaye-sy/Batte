# 🌍 Battè - Application Mobile Guinéenne de Recyclage

> Transformez vos déchets en argent grâce à une poubelle intelligente connectée

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-green.svg)](https://supabase.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📁 Organisation du Projet

```
batte/
├── lib/              ← Code source Flutter
├── database/         ← Scripts SQL Supabase
├── documentation/    ← Guides et documentations (18 fichiers)
├── esp32/            ← Code pour la poubelle IoT
├── assets/           ← Images, icônes, audio
└── README.md         ← Ce fichier
```

**📚 Consulte le dossier `documentation/` pour tous les guides détaillés**

---

## ✨ Nouvelle Architecture (Octobre 2025)

Le backend Node.js a été **complètement supprimé** et remplacé par **Supabase** pour une architecture plus simple, stable et sans serveur.

### ✅ Avantages

- **Pas de serveur backend** à gérer
- **Pas de problèmes de port** ou d'adresse IP
- **Authentification sécurisée** par OTP SMS via Supabase Auth
- **API REST automatique** générée par Supabase
- **Base de données PostgreSQL** hébergée
- **Stockage de fichiers** inclus
- **Notifications push** via Firebase
- **Temps réel** avec WebSockets
- **Gratuit** jusqu'à 500 Mo de stockage

---

## 🚀 Démarrage Rapide

### 1️⃣ Créer le fichier `.env`

Crée un fichier **`.env`** à la racine du projet (`C:\Users\USER\Desktop\Batte\batte\.env`) :

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

### 2️⃣ Lancer l'application

```powershell
# Installer les dépendances
flutter pub get

# Lancer l'application sur un appareil connecté
flutter run
```

**C'est tout !** 🎉 Plus besoin de démarrer un serveur backend.

---

## 📱 Test de l'Inscription

1. Lance l'application : `flutter run`
2. Clique sur **"S'inscrire"**
3. Entre ton numéro de téléphone (format: **+224612345678**)
4. Entre ton nom
5. Clique sur **"Continuer"**
6. **En mode développement**, Supabase affiche le code OTP dans les logs ou dans le Dashboard → **Authentication** → **Users**
7. Entre le code OTP
8. ✅ Tu es connecté !

---

## ⚙️ Configuration Supabase (Important)

Pour que l'application fonctionne, tu dois configurer Supabase :

### Étape 1 : Activer Phone Auth

1. Va sur [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Sélectionne ton projet **Battè**
3. Va dans **Authentication** → **Providers**
4. Active **Phone**

### Étape 2 : Activer Row Level Security (RLS)

Va dans **SQL Editor** et exécute le script complet dans le fichier [`CONFIGURATION_SUPABASE.md`](./CONFIGURATION_SUPABASE.md) (section 3️⃣).

Ou exécute rapidement ce script minimum :

```sql
-- Activer RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.waste_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.education_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;

-- Politique pour "users"
CREATE POLICY "Users can view own profile" 
ON public.users FOR SELECT 
USING (auth.uid()::text = id::text);

CREATE POLICY "Users can update own profile" 
ON public.users FOR UPDATE 
USING (auth.uid()::text = id::text);

CREATE POLICY "Users can insert own profile" 
ON public.users FOR INSERT 
WITH CHECK (auth.uid()::text = id::text);

-- Politique pour "waste_transactions"
CREATE POLICY "Users can view own waste transactions" 
ON public.waste_transactions FOR SELECT 
USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own waste transactions" 
ON public.waste_transactions FOR INSERT 
WITH CHECK (auth.uid()::text = user_id::text);

-- Lecture publique pour certaines tables
CREATE POLICY "Anyone can view education content" 
ON public.education_content FOR SELECT 
USING (true);

CREATE POLICY "Anyone can view jobs" 
ON public.jobs FOR SELECT 
USING (true);
```

### Étape 3 : Créer les fonctions SQL

Exécute ce script dans **SQL Editor** :

```sql
-- Fonction pour les statistiques de déchets
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

-- Fonction pour mettre à jour le solde et les points
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
```

---

## 📂 Structure du Projet

```
batte/
├── lib/
│   ├── main.dart                      # Point d'entrée (initialise Supabase)
│   ├── app.dart                       # Configuration de l'application
│   ├── services/
│   │   ├── supabase_service.dart      # 🆕 Service Supabase (remplace ApiService)
│   │   ├── auth_service.dart          # 🔄 Authentification via Supabase
│   │   ├── storage_service.dart       # Stockage local
│   │   └── notification_service.dart  # Notifications Firebase
│   ├── providers/
│   │   ├── auth_provider.dart         # État d'authentification
│   │   ├── waste_provider.dart        # État des déchets
│   │   └── ...
│   ├── screens/
│   │   ├── splash/                    # Écran de démarrage
│   │   ├── auth/                      # Login/Signup
│   │   ├── home/                      # Dashboard
│   │   ├── recycling/                 # Module Recyclage
│   │   ├── budget/                    # Module Budget
│   │   ├── education/                 # Module Éducation
│   │   └── services/                  # Module Services
│   ├── widgets/                       # Composants réutilisables
│   ├── models/                        # Modèles de données
│   └── core/                          # Constantes et utils
├── assets/
│   ├── images/                        # Logo et images
│   ├── icons/                         # Icônes de l'app
│   └── translations/                  # Fichiers de traduction
├── .env                               # 🔑 Variables d'environnement
├── pubspec.yaml                       # Dépendances Flutter
├── README.md                          # Ce fichier
└── CONFIGURATION_SUPABASE.md          # Guide détaillé Supabase
```

---

## 🛠️ Technologies Utilisées

### Frontend
- **Flutter** (Dart) - Framework mobile cross-platform
- **Provider** - Gestion d'état
- **Supabase Flutter** - Client Supabase pour Flutter
- **Firebase** - Notifications push (FCM)
- **Hive** - Base de données locale
- **fl_chart** - Graphiques
- **flutter_blue_plus** - Bluetooth (ESP32)

### Backend
- **Supabase** - Backend as a Service (BaaS)
  - PostgreSQL (base de données)
  - Auth (authentification par OTP SMS)
  - Storage (stockage de fichiers)
  - Realtime (WebSockets)
  - Edge Functions (fonctions serverless)

### IoT
- **ESP32** - Microcontrôleur pour la poubelle intelligente
- **Bluetooth** - Communication Flutter ↔ ESP32
- **Capteurs** : HX711 (poids), HC-SR04 (niveau), SIM800L (GSM)

---

## 🎨 Palette de Couleurs

- **Vert foncé** : `#38761D` (Primary)
- **Jaune/Or** : `#FBC02D` (Secondary)
- **Vert clair** : `#C8E6C9` (Card Background)
- **Violet** : `#8B5CF6` (Accents)

---

## 📞 En cas de Problème

### ❌ Erreur : "SUPABASE_URL ou SUPABASE_ANON_KEY manquant"

**Solution** : Vérifie que le fichier `.env` existe à la racine et contient les bonnes valeurs.

### ❌ Erreur : "Session invalide après vérification OTP"

**Solution** : Vérifie que Phone Auth est activé dans Supabase Dashboard → **Authentication** → **Providers**.

### ❌ Code OTP non reçu

**Solution** : En mode développement, le code OTP s'affiche dans les logs Supabase ou dans **Dashboard** → **Authentication** → **Users**.

Pour la production, configure Twilio dans Supabase (voir [`CONFIGURATION_SUPABASE.md`](./CONFIGURATION_SUPABASE.md)).

---

## 📄 Documentation Complète

- **[CONFIGURATION_SUPABASE.md](./CONFIGURATION_SUPABASE.md)** - Guide détaillé de configuration Supabase (RLS, Auth, SQL, etc.)

---

## 🤝 Contribuer

1. Fork le projet
2. Crée une branche (`git checkout -b feature/AmazingFeature`)
3. Commit tes changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvre une Pull Request

---

## 📜 Licence

Ce projet est sous licence MIT.

---

## 👥 Équipe

- **Ramatoulaye SY** - Développeuse principale
- **Battè Team** - Équipe Guinée

---

## 🌟 Remerciements

- [Supabase](https://supabase.com) - Backend as a Service
- [Flutter](https://flutter.dev) - Framework mobile
- [Firebase](https://firebase.google.com) - Notifications push

---

**Fait avec ❤️ en Guinée pour les femmes guinéennes**
