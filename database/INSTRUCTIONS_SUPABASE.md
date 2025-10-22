# 🗄️ INSTRUCTIONS SUPABASE - NOUVELLES TABLES

## 📋 ORDRE D'EXÉCUTION DES SCRIPTS

Exécute les scripts SQL **dans cet ordre** dans le SQL Editor de Supabase :

### ✅ **1. NOTIFICATIONS**
**Fichier :** `create_notifications_table.sql`  
**Description :** Table pour les notifications in-app  
**Durée estimée :** 5 secondes

```sql
-- Copie et colle le contenu de create_notifications_table.sql
```

---

### ✅ **2. MISSIONS**
**Fichier :** `create_missions_table.sql`  
**Description :** Tables pour les missions quotidiennes/hebdomadaires  
**Durée estimée :** 10 secondes

```sql
-- Copie et colle le contenu de create_missions_table.sql
```

**Inclut :**
- Table `missions` : Missions disponibles
- Table `user_missions` : Progression des utilisateurs
- Données de démonstration (5 missions daily + 4 weekly)
- Fonctions : `assign_active_missions_to_user()`, `update_mission_progress()`

---

### ✅ **3. LEADERBOARD**
**Fichier :** `create_leaderboard_view.sql`  
**Description :** Vue matérialisée pour le classement  
**Durée estimée :** 8 secondes

```sql
-- Copie et colle le contenu de create_leaderboard_view.sql
```

**Inclut :**
- Vue matérialisée `leaderboard` : Classement général
- Vues simplifiées : `leaderboard_by_weight`, `leaderboard_by_points`, `leaderboard_by_earnings`
- Fonction : `get_user_rank()`, `refresh_leaderboard()`

**⚠️ ERREUR POSSIBLE :**
```
ERROR: syntax error at or near "LEANGUAGE"
```
**Solution :** Change `LEANGUAGE` en `LANGUAGE` à la ligne du CREATE FUNCTION `refresh_leaderboard()`

---

### ✅ **4. REFERRALS**
**Fichier :** `create_referrals_table.sql`  
**Description :** Tables pour le programme de parrainage  
**Durée estimée :** 10 secondes

```sql
-- Copie et colle le contenu de create_referrals_table.sql
```

**Inclut :**
- Table `referral_codes` : Codes de parrainage
- Table `referrals` : Historique des parrainages
- Fonctions : `generate_referral_code()`, `apply_referral_code()`, `pay_referral_bonus()`
- Trigger automatique : Génère un code à chaque nouvel utilisateur

---

## 🚀 COMMENT EXÉCUTER DANS SUPABASE

### **Méthode 1 : SQL Editor (Recommandée)**

1. Va sur [Supabase Dashboard](https://supabase.com/dashboard)
2. Sélectionne ton projet **Battè**
3. Dans le menu de gauche, clique sur **SQL Editor**
4. Clique sur **New query**
5. Copie le contenu d'un fichier SQL
6. Colle-le dans l'éditeur
7. Clique sur **Run** (ou Ctrl+Enter)
8. Vérifie qu'il n'y a pas d'erreurs (message vert "Success")
9. Répète pour les 4 fichiers

### **Méthode 2 : Via psql (Avancé)**

```bash
# Récupère ta connection string depuis Supabase Dashboard > Project Settings > Database
psql "postgresql://postgres:[PASSWORD]@[HOST]:5432/postgres"

# Puis exécute chaque fichier
\i database/create_notifications_table.sql
\i database/create_missions_table.sql
\i database/create_leaderboard_view.sql
\i database/create_referrals_table.sql
```

---

## ✅ VÉRIFICATION

Après l'exécution, vérifie que tout s'est bien passé :

### **1. Vérifie les tables créées**

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('notifications', 'missions', 'user_missions', 'referral_codes', 'referrals');
```

**Résultat attendu :** 5 lignes

### **2. Vérifie les vues créées**

```sql
SELECT viewname 
FROM pg_views 
WHERE schemaname = 'public' 
  AND viewname LIKE 'leaderboard%';
```

**Résultat attendu :** 4 vues (leaderboard, leaderboard_by_weight, leaderboard_by_points, leaderboard_by_earnings)

### **3. Vérifie les missions de démo**

```sql
SELECT COUNT(*) FROM public.missions;
```

**Résultat attendu :** 9 missions (5 daily + 4 weekly)

### **4. Teste une fonction**

```sql
-- Génère un code de parrainage pour un utilisateur test
SELECT generate_referral_code('A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11');
```

**Résultat attendu :** Un code au format `BATTE-XXXXXX`

---

## 🔧 CONFIGURATION SUPPLÉMENTAIRE

### **1. Rafraîchir le leaderboard automatiquement (Optionnel)**

Dans Supabase Dashboard > Database > Cron Jobs :

```sql
SELECT cron.schedule(
  'refresh-leaderboard',
  '0 * * * *', -- Toutes les heures
  $$ SELECT refresh_leaderboard(); $$
);
```

### **2. Générer des codes pour les utilisateurs existants**

Si tu as déjà des utilisateurs dans la base :

```sql
-- Générer des codes pour tous les utilisateurs sans code
INSERT INTO public.referral_codes (user_id, code)
SELECT 
  u.id,
  'BATTE-' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT || u.id::TEXT) FROM 1 FOR 6))
FROM public.users u
WHERE u.role = 'user'
  AND NOT EXISTS (SELECT 1 FROM public.referral_codes rc WHERE rc.user_id = u.id);
```

### **3. Assigner les missions aux utilisateurs existants**

```sql
-- Pour un utilisateur spécifique
SELECT assign_active_missions_to_user('USER_UUID');

-- Pour tous les utilisateurs
SELECT assign_active_missions_to_user(id) FROM public.users WHERE role = 'user';
```

---

## ⚠️ PROBLÈMES COURANTS

### **Erreur : "relation already exists"**
**Cause :** Tu as déjà exécuté le script  
**Solution :** Supprime la table/vue existante avant de réexécuter

```sql
DROP TABLE IF EXISTS public.missions CASCADE;
DROP MATERIALIZED VIEW IF EXISTS public.leaderboard CASCADE;
```

### **Erreur : "permission denied"**
**Cause :** Problème de permissions  
**Solution :** Vérifie que tu es connecté en tant que propriétaire du projet

### **Erreur : "function does not exist"**
**Cause :** Une fonction dépendante n'existe pas  
**Solution :** Exécute les scripts dans l'ordre indiqué

---

## 📊 DONNÉES DE TEST

Pour tester les nouvelles fonctionnalités, tu peux insérer des données de test :

```sql
-- Notification de test
INSERT INTO public.notifications (user_id, title, message, type)
VALUES (
  'TON_USER_UUID',
  'Bienvenue sur Battè ! 🎉',
  'Tu as gagné 10 points de bienvenue',
  'success'
);

-- Progression de mission de test
SELECT update_mission_progress(
  'TON_USER_UUID',
  (SELECT id FROM public.missions WHERE title = 'Premier recyclage du jour' LIMIT 1),
  1
);
```

---

## 🎯 RÉSULTAT FINAL

Après l'exécution de tous les scripts, tu auras :

✅ **4 nouvelles tables** : notifications, missions, user_missions, referral_codes, referrals  
✅ **1 vue matérialisée** : leaderboard  
✅ **3 vues simplifiées** : leaderboard_by_weight, leaderboard_by_points, leaderboard_by_earnings  
✅ **8 fonctions SQL** : génération de codes, progression de missions, paiement de bonus, etc.  
✅ **Politiques RLS** : Sécurité au niveau des lignes activée  
✅ **Données de démo** : 9 missions prêtes à l'emploi  

---

Bon courage ! 💪

