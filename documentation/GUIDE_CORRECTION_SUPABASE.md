# 🔧 GUIDE DE CORRECTION DES ERREURS SUPABASE

## 🎯 **PROBLÈMES À CORRIGER :**

1. ❌ **Colonne manquante** : `user_education_progress.completed` n'existe pas
2. ❌ **Politique RLS** : `waste_transactions` bloque les insertions

## 📋 **ÉTAPES DE CORRECTION :**

### **Étape 1 : Accéder à Supabase**
1. Ouvrez votre navigateur
2. Allez sur [supabase.com](https://supabase.com)
3. Connectez-vous à votre compte
4. Sélectionnez votre projet Batte

### **Étape 2 : Ouvrir l'éditeur SQL**
1. Dans le menu de gauche, cliquez sur **"SQL Editor"**
2. Cliquez sur **"New query"**

### **Étape 3 : Exécuter le script de correction**
1. Copiez tout le contenu du fichier `fix_supabase_errors.sql`
2. Collez-le dans l'éditeur SQL
3. Cliquez sur **"Run"** (ou Ctrl+Enter)

### **Étape 4 : Vérifier l'exécution**
Vous devriez voir des messages comme :
```
NOTICE: Colonne "completed" ajoutée à la table user_education_progress
NOTICE: Politique "Users can insert their own waste transactions" créée
NOTICE: Politique "Users can view their own waste transactions" créée
NOTICE: Politique "Users can update their own waste transactions" créée
```

## 🔍 **VÉRIFICATION POST-CORRECTION :**

### **Vérifier les tables :**
```sql
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('waste_transactions', 'user_education_progress');
```

### **Vérifier les colonnes :**
```sql
SELECT table_name, column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'user_education_progress'
AND column_name = 'completed';
```

### **Vérifier les politiques RLS :**
```sql
SELECT tablename, policyname, cmd 
FROM pg_policies 
WHERE tablename = 'waste_transactions';
```

## ✅ **RÉSULTATS ATTENDUS :**

Après l'exécution du script, vous devriez avoir :

### **Table `user_education_progress` :**
- ✅ Colonne `completed` (BOOLEAN)
- ✅ Politique RLS pour les utilisateurs authentifiés
- ✅ Index pour optimiser les performances

### **Table `waste_transactions` :**
- ✅ Politiques RLS pour INSERT, SELECT, UPDATE
- ✅ Index pour optimiser les performances
- ✅ Triggers pour `updated_at` automatique

## 🚀 **TEST DE L'APPLICATION :**

Après avoir exécuté le script :

1. **Redémarrez l'application Flutter**
2. **Testez l'ajout de déchets** - ne devrait plus y avoir d'erreur RLS
3. **Testez l'écran Éducation** - ne devrait plus y avoir d'erreur de colonne manquante
4. **Vérifiez les logs** - plus d'erreurs Supabase

## 🆘 **EN CAS DE PROBLÈME :**

### **Erreur "operator does not exist: text = uuid" :**
- **Cause** : Conflit de types entre `auth.uid()` (UUID) et `user_id` (TEXT)
- **Solution** : Exécuter le script `fix_uuid_type_error.sql`
- **Explication** : Les politiques RLS utilisent maintenant `user_id::uuid`

### **Erreur "permission denied" :**
- Vérifiez que vous êtes connecté avec un compte administrateur
- Vérifiez que votre projet Supabase est actif

### **Erreur "table already exists" :**
- C'est normal, le script utilise `IF NOT EXISTS`
- L'exécution continue normalement

### **Erreur "policy already exists" :**
- Le script supprime d'abord les anciennes politiques
- Si l'erreur persiste, supprimez manuellement les politiques existantes

## 📞 **SUPPORT :**

Si vous rencontrez des problèmes :
1. Vérifiez les logs Supabase dans l'onglet "Logs"
2. Vérifiez que votre projet est bien configuré
3. Contactez le support Supabase si nécessaire

## 🎉 **UNE FOIS CORRIGÉ :**

L'application Batte fonctionnera parfaitement avec :
- ✅ Ajout de déchets sans erreur RLS
- ✅ Sauvegarde du progrès éducatif
- ✅ Synchronisation des données
- ✅ Fonctionnalités offline-first

**Votre application sera 100% fonctionnelle !** 🚀
