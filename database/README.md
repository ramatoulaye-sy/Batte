# 🗄️ SCRIPTS SQL POUR SUPABASE

Ce dossier contient tous les scripts SQL nécessaires pour créer les tables et vues dans Supabase.

## 📋 FICHIERS DISPONIBLES

| Fichier | Description | Tables créées |
|---------|-------------|---------------|
| `create_notifications_table.sql` | Système de notifications | `notifications` |
| `create_missions_table.sql` | Missions quotidiennes/hebdomadaires | `missions`, `user_missions` |
| `create_leaderboard_view.sql` | Classement des utilisateurs | Vue `leaderboard` + 3 vues |
| `create_referrals_table.sql` | Programme de parrainage | `referral_codes`, `referrals` |

## 🚀 ORDRE D'EXÉCUTION

Exécute les scripts **dans cet ordre** :

1. ✅ `create_notifications_table.sql`
2. ✅ `create_missions_table.sql`
3. ✅ `create_leaderboard_view.sql`
4. ✅ `create_referrals_table.sql`

## 📖 GUIDE COMPLET

Consulte le fichier **`INSTRUCTIONS_SUPABASE.md`** pour :
- Instructions détaillées étape par étape
- Vérifications après exécution
- Solutions aux problèmes courants
- Configuration des tâches CRON
- Insertion de données de test

## ⚡ EXÉCUTION RAPIDE

```sql
-- 1. Notifications
\i database/create_notifications_table.sql

-- 2. Missions
\i database/create_missions_table.sql

-- 3. Leaderboard
\i database/create_leaderboard_view.sql

-- 4. Parrainage
\i database/create_referrals_table.sql
```

## 🔒 SÉCURITÉ

Tous les scripts incluent :
- ✅ Row Level Security (RLS) activé
- ✅ Politiques d'accès configurées
- ✅ Fonctions SECURITY DEFINER
- ✅ Validation des données

## 📊 FONCTIONNALITÉS INCLUSES

### **Notifications**
- Stockage des notifications in-app
- Types : info, warning, success, transaction, mission
- Statut lu/non lu

### **Missions**
- Missions quotidiennes et hebdomadaires
- Suivi de progression automatique
- Système de récompenses (points + badges)
- 9 missions de démonstration incluses

### **Leaderboard**
- Classement en temps réel
- Tri par : poids, points, gains
- Badges automatiques selon le niveau
- Fonction de rafraîchissement

### **Parrainage**
- Génération automatique de codes uniques
- Suivi des parrainages
- Système de bonus (500 GNF par défaut)
- Historique complet

## ⚠️ PRÉREQUIS

Assure-toi que ces tables existent déjà :
- ✅ `users`
- ✅ `transactions`
- ✅ `wastes`

Si elles n'existent pas, exécute d'abord les migrations de base.

## 🆘 SUPPORT

En cas de problème :
1. Vérifie les logs d'erreur dans Supabase
2. Consulte `INSTRUCTIONS_SUPABASE.md`
3. Vérifie que les tables `users`, `transactions`, `wastes` existent

---

Développé pour **Battè** - Guinée 🇬🇳

