# 🔧 GUIDE DE DÉPANNAGE RAPIDE - ERREUR UUID/TEXT

## ❌ **ERREUR RENCONTRÉE :**
```
ERROR: 42883: operator does not exist: text = uuid
HINT: No operator matches the given name and argument types. 
You might need to add explicit type casts.
```

## 🔍 **CAUSE DU PROBLÈME :**

Le problème vient du fait que :
- `auth.uid()` retourne un **UUID**
- `user_id` dans nos tables est de type **TEXT**
- PostgreSQL ne peut pas comparer directement ces deux types

## ✅ **SOLUTION RAPIDE :**

### **Étape 1 : Exécuter le script de correction**
1. Ouvrir Supabase → SQL Editor
2. Copier le contenu de `fix_uuid_type_error.sql`
3. Exécuter le script
4. Vérifier que les politiques sont créées

### **Étape 2 : Vérifier la correction**
```sql
-- Vérifier que les politiques sont créées
SELECT tablename, policyname, cmd 
FROM pg_policies 
WHERE tablename IN ('waste_transactions', 'user_education_progress');
```

## 🔧 **CE QUI A ÉTÉ CORRIGÉ :**

### **AVANT (causait l'erreur) :**
```sql
CREATE POLICY "Users can insert their own waste transactions" 
ON waste_transactions 
FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid()::text = user_id); -- ❌ Erreur de type
```

### **APRÈS (corrigé) :**
```sql
CREATE POLICY "Users can insert their own waste transactions" 
ON waste_transactions 
FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = user_id::uuid); -- ✅ Conversion correcte
```

## 📋 **POLITIQUES CORRIGÉES :**

1. **waste_transactions** :
   - ✅ INSERT : `auth.uid() = user_id::uuid`
   - ✅ SELECT : `auth.uid() = user_id::uuid`
   - ✅ UPDATE : `auth.uid() = user_id::uuid`

2. **user_education_progress** :
   - ✅ ALL : `auth.uid() = user_id::uuid`

## 🚀 **TEST DE LA CORRECTION :**

### **Test 1 : Vérifier les politiques**
```sql
SELECT 
    tablename,
    policyname,
    cmd,
    '✅ OK' as statut
FROM pg_policies 
WHERE tablename IN ('waste_transactions', 'user_education_progress');
```

### **Test 2 : Tester l'application**
1. Redémarrer l'application Flutter
2. Essayer d'ajouter un déchet
3. Vérifier les logs - plus d'erreur RLS

## 🎯 **RÉSULTAT ATTENDU :**

Après la correction :
- ✅ **Plus d'erreur "operator does not exist"**
- ✅ **Politiques RLS fonctionnelles**
- ✅ **Ajout de déchets sans erreur**
- ✅ **Sauvegarde éducation sans erreur**

## 📞 **SI LE PROBLÈME PERSISTE :**

### **Vérifier les types de colonnes :**
```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name IN ('waste_transactions', 'user_education_progress')
AND column_name = 'user_id';
```

### **Vérifier le type de auth.uid() :**
```sql
SELECT pg_typeof(auth.uid()) as auth_uid_type;
```

### **Solution alternative (si nécessaire) :**
```sql
-- Changer le type de user_id en UUID
ALTER TABLE waste_transactions 
ALTER COLUMN user_id TYPE UUID USING user_id::uuid;

ALTER TABLE user_education_progress 
ALTER COLUMN user_id TYPE UUID USING user_id::uuid;
```

## ✅ **VALIDATION FINALE :**

Une fois le script `fix_uuid_type_error.sql` exécuté :

1. **Vérifier** : Les politiques sont créées sans erreur
2. **Tester** : L'application Flutter fonctionne
3. **Confirmer** : Plus d'erreurs dans les logs

**Votre application sera alors 100% fonctionnelle !** 🎉
