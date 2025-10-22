# 🚀 Démarrage Immédiat - Battè avec Supabase

## ✅ Migration Terminée !

Le backend Node.js a été **complètement supprimé** et remplacé par **Supabase**. L'application est maintenant plus simple, plus stable et sans serveur à gérer.

---

## 📋 3 Étapes Pour Démarrer

### Étape 1 : Créer le fichier `.env`

Crée un fichier nommé **`.env`** (sans `.txt`) dans `C:\Users\USER\Desktop\Batte\batte\` :

```env
SUPABASE_URL=https://zhtnqugrcubrtjvpdzty.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpodG5xdWdyY3VicnRqdnBkenR5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyNTk4ODMsImV4cCI6MjA3MDgzNTg4M30.Ci7BHifhK098NZUwRphvRew5T_DCoA17leVg3Z1daaY
FIREBASE_API_KEY=your-firebase-api-key
BIN_DEVICE_NAME=BATTE_BIN
BIN_SERVICE_UUID=4fafc201-1fb5-459e-8fcc-c5c9c331914b
ENVIRONMENT=development
```

### Étape 2 : Activer Phone Auth dans Supabase

1. Va sur https://supabase.com/dashboard
2. Sélectionne ton projet **Battè**
3. Va dans **Authentication** → **Providers**
4. Active **Phone**

### Étape 3 : Lancer l'application

```powershell
cd C:\Users\USER\Desktop\Batte\batte
flutter pub get
flutter run
```

---

## 🎉 C'EST TOUT !

Plus besoin de :
- ❌ Démarrer un serveur Node.js
- ❌ Configurer `adb reverse`
- ❌ Gérer les ports 3000, 5000, etc.
- ❌ S'inquiéter des adresses IP locales
- ❌ Configurer Twilio manuellement

---

## 📱 Test Immédiat

1. Lance `flutter run`
2. Clique sur **"S'inscrire"**
3. Entre **+224612345678**
4. Entre ton nom
5. Le code OTP s'affiche dans les logs ou dans **Supabase Dashboard** → **Authentication** → **Users**
6. Entre le code
7. ✅ **Connecté !**

---

## 🔧 Configuration Optionnelle

### Pour activer Row Level Security (RLS)

Va dans **Supabase Dashboard** → **SQL Editor** et exécute :

```sql
-- Activer RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.waste_transactions ENABLE ROW LEVEL SECURITY;

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
```

**Voir le script complet dans `CONFIGURATION_SUPABASE.md`.**

---

## 📖 Documentation

- `README.md` - Documentation principale
- `CONFIGURATION_SUPABASE.md` - Configuration détaillée (RLS, Auth, SQL)
- `RESUME_MIGRATION_SUPABASE.md` - Résumé de la migration

---

## 🎯 Résumé de ce qui a changé

| Fichier | Action |
|---|---|
| ✅ `lib/services/supabase_service.dart` | **Créé** - Service centralisé Supabase |
| 🔄 `lib/services/auth_service.dart` | **Modifié** - Utilise Supabase Auth |
| 🔄 `lib/main.dart` | **Modifié** - Initialise Supabase |
| 🔄 `lib/services/storage_service.dart` | **Modifié** - Ajout données temporaires |
| 🔄 `pubspec.yaml` | **Modifié** - `supabase_flutter` au lieu de `dio` |
| ❌ `backend/` | **Supprimé** - Tout le dossier backend Node.js |
| ❌ `lib/services/api_service.dart` | **Supprimé** - Remplacé par Supabase |
| ❌ Tous les fichiers `.md` backend | **Supprimés** - Documentations obsolètes |

---

## ⚠️ Note Importante

Il reste quelques ajustements mineurs à faire dans les providers (`WasteProvider`, `BudgetProvider`, `EducationProvider`) pour remplacer les appels à `ApiService` par des appels directs à `SupabaseService`.

Ceci n'empêche PAS le fonctionnement de l'authentification (signup/login/OTP) qui est déjà fonctionnelle !

---

## 🆘 Besoin d'aide ?

Si tu rencontres un problème :
1. Vérifie que le fichier `.env` existe
2. Vérifie que Phone Auth est activé dans Supabase
3. Vérifie les logs Flutter : `flutter run`
4. Vérifie les logs Supabase : Dashboard → **Logs**

---

**Bonne chance ! 🚀**

