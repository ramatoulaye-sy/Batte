# 🔑 Comment Obtenir tes Clés Supabase

## Étape 1 : Va sur Supabase Dashboard

1. Ouvre ton navigateur
2. Va sur : **https://supabase.com/dashboard**
3. Connecte-toi avec ton compte

---

## Étape 2 : Sélectionne ton Projet

1. Clique sur ton projet **"Battè"** (ou le nom que tu lui as donné)
2. Tu verras le tableau de bord du projet

---

## Étape 3 : Récupère les Clés API

1. Dans le menu de gauche, clique sur **⚙️ Settings** (Paramètres)
2. Clique sur **API** dans le sous-menu
3. Tu verras deux sections importantes :

### 📋 Section "Project URL"
```
Project URL: https://zhtnqugrcubrtjvpdzty.supabase.co
```
👉 **Copie cette URL** → C'est ton `SUPABASE_URL`

### 🔑 Section "Project API keys"

Tu verras **2 clés** :

#### 1. `anon` `public` (Clé publique)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpodG...
```
👉 **Copie cette clé complète** → C'est ton `SUPABASE_ANON_KEY`

⚠️ **Important** : La clé est **TRÈS LONGUE** (environ 200+ caractères). Assure-toi de la copier **ENTIÈREMENT** !

#### 2. `service_role` `secret` (Clé secrète)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpodG...
```
👉 **Garde cette clé secrète** (ne la partage jamais)

---

## Étape 4 : Crée/Mets à Jour le fichier `.env`

1. Ouvre Notepad (Bloc-notes Windows)
2. Colle ce contenu en remplaçant par **TES** vraies clés :

```env
SUPABASE_URL=TON_PROJECT_URL_ICI
SUPABASE_ANON_KEY=TA_CLE_ANON_COMPLETE_ICI
FIREBASE_API_KEY=your-firebase-api-key
BIN_DEVICE_NAME=BATTE_BIN
BIN_SERVICE_UUID=4fafc201-1fb5-459e-8fcc-c5c9c331914b
ENVIRONMENT=development
```

3. **Enregistre sous** :
   - Nom du fichier : `.env` (avec le point au début)
   - Type : **Tous les fichiers (*.*)**
   - Emplacement : `C:\Users\USER\Desktop\Batte\batte\`

4. **IMPORTANT** : Assure-toi que le fichier s'appelle **`.env`** et **PAS** `.env.txt`

---

## Étape 5 : Redémarre l'Application

```powershell
# Arrête l'app si elle tourne
# Puis relance :
flutter run
```

---

## ✅ Vérification

Dans les logs Flutter, tu devrais voir :

```
✅ Fichier .env chargé avec succès
✅ Supabase initialisé
```

Et **PAS** :
```
❌ Erreur signup: AuthApiException(message: Invalid API key, statusCode: 401)
```

---

## 🆘 Si ça ne marche toujours pas

1. **Vérifie que Phone Auth est activé** :
   - Supabase Dashboard → **Authentication** → **Providers** → **Phone** → **Enabled**

2. **Vérifie le fichier `.env`** :
   ```powershell
   Get-Content .env
   ```
   Tu dois voir tes clés complètes.

3. **Supprime le cache Flutter** :
   ```powershell
   flutter clean
   flutter pub get
   flutter run
   ```

---

**Envoie-moi une capture d'écran de la section API dans Supabase si tu as besoin d'aide !** 📸

