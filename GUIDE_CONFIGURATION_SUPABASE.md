# 🔧 GUIDE DE CONFIGURATION SUPABASE

## ❌ **ERREUR ACTUELLE :**
```
Failed host lookup: 'zhtnqugrcubrtjvpdzty.supabase.co'
```

## ✅ **SOLUTIONS :**

### **1. Créer le fichier .env :**
Créez un fichier `.env` à la racine du projet avec :

```env
SUPABASE_URL=https://votre-projet.supabase.co
SUPABASE_ANON_KEY=votre-clé-anon-supabase
```

### **2. Obtenir les clés Supabase :**

1. **Aller sur [supabase.com](https://supabase.com)**
2. **Se connecter** avec votre compte
3. **Créer un nouveau projet** ou sélectionner un existant
4. **Aller dans Settings → API**
5. **Copier :**
   - **Project URL** → `SUPABASE_URL`
   - **anon public** key → `SUPABASE_ANON_KEY`

### **3. Exécuter le schéma SQL :**

1. **Aller dans Supabase Dashboard → SQL Editor**
2. **Exécuter** le contenu de `database/services_schema.sql`
3. **Exécuter** le contenu de `database/services_functions.sql`

### **4. Tester la connexion :**

```bash
flutter clean
flutter pub get
flutter run
```

## 🚀 **ALTERNATIVE : MODE HORS LIGNE**

Si vous voulez tester sans Supabase :

1. **L'app fonctionne déjà en mode offline-first**
2. **Les données sont sauvegardées localement**
3. **La synchronisation se fera quand Supabase sera configuré**

## 📱 **TESTER LE MODULE SERVICES :**

1. **Ouvrir l'app** → Services
2. **Taper "Je propose"** → Créer une offre
3. **Taper "Je cherche"** → Créer une demande
4. **Vérifier** que les données apparaissent dans la liste

## 🔍 **VÉRIFICATION :**

Si Supabase est bien configuré, vous devriez voir :
```
✅ Supabase initialisé avec succès
✅ Client créé: true
```

Au lieu de :
```
❌ Erreur get profiles: ClientException...
```

## 🆘 **AIDE SUPPLÉMENTAIRE :**

- **Documentation Supabase :** https://supabase.com/docs
- **Guide Flutter :** https://supabase.com/docs/guides/getting-started/tutorials/with-flutter
- **Support :** https://supabase.com/support
