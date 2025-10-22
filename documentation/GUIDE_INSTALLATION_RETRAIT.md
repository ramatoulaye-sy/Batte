# 🔧 Guide d'Installation : Système de Retrait

## 📋 Vue d'ensemble

Ce guide explique comment configurer le système de retrait avec déduction automatique du solde dans votre projet Battè.

---

## ✅ Étape 1 : Exécuter le Script SQL dans Supabase

### 1.1 Ouvrir Supabase Dashboard

1. Va sur [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Connecte-toi avec ton compte
3. Sélectionne ton projet **Battè**

### 1.2 Ouvrir le SQL Editor

1. Dans le menu de gauche, clique sur **SQL Editor** (icône `</>`)
2. Clique sur **New Query** (Nouvelle requête)

### 1.3 Copier et Exécuter le Script

1. Ouvre le fichier `supabase_functions/process_withdrawal.sql`
2. **Copie TOUT le contenu** du fichier
3. **Colle-le** dans le SQL Editor de Supabase
4. Clique sur **Run** (Exécuter) en bas à droite

### 1.4 Vérifier que ça a marché

Tu devrais voir un message de succès :

```
Success. No rows returned
```

Cela signifie que la fonction `process_withdrawal` a été créée avec succès ! ✅

---

## ✅ Étape 2 : Tester le Système de Retrait

### 2.1 Ajouter du Solde à ton Compte (Test)

Avant de tester le retrait, tu dois avoir du solde. Va dans le SQL Editor et exécute :

```sql
-- Ajouter 100 000 GNF à ton compte pour tester
UPDATE public.users
SET balance = 100000
WHERE email = 'TON_EMAIL_ICI@example.com';
```

⚠️ Remplace `TON_EMAIL_ICI@example.com` par **ton vrai email** que tu utilises dans l'app.

### 2.2 Tester le Retrait dans l'App

1. Ouvre l'app **Battè** sur ton téléphone
2. Sur l'écran d'accueil, clique sur le bouton **"Retirer"**
3. Entre un montant (ex: `50000`)
4. Clique sur **"Confirmer"**

### 2.3 Vérifier le Résultat

Tu devrais voir :
- ✅ Un message de succès : "Retrait de 50 000 GNF effectué ! Nouveau solde: 50 000 GNF"
- ✅ Ton solde mis à jour sur l'écran principal
- ✅ Une nouvelle transaction dans "Activité récente"

---

## 🔍 Vérification dans Supabase

Pour vérifier que tout fonctionne bien :

### Vérifier les Transactions

Va dans Supabase → **Table Editor** → **transactions** :

```sql
SELECT * FROM public.transactions
WHERE type = 'withdrawal'
ORDER BY date DESC
LIMIT 5;
```

Tu devrais voir ta transaction de retrait.

### Vérifier le Solde Utilisateur

```sql
SELECT id, name, email, balance
FROM public.users
WHERE email = 'TON_EMAIL_ICI@example.com';
```

Le solde devrait être : `100 000 - 50 000 = 50 000 GNF`.

---

## ❌ Résolution des Problèmes

### Problème 1 : "Fonction de retrait non configurée"

**Erreur dans l'app :**
```
⚠️ Fonction de retrait non configurée dans Supabase.
Veuillez exécuter le script SQL fourni.
```

**Solution :**
- Tu n'as pas exécuté le script SQL
- Retourne à l'**Étape 1** et exécute le script `process_withdrawal.sql`

---

### Problème 2 : "Solde insuffisant"

**Erreur dans l'app :**
```
❌ Solde insuffisant pour ce retrait
```

**Solution :**
- Ton solde est inférieur au montant demandé
- Ajoute du solde avec le script de l'**Étape 2.1**
- Ou réduis le montant du retrait

---

### Problème 3 : "Utilisateur non trouvé"

**Erreur dans l'app :**
```
❌ Erreur: Utilisateur non trouvé
```

**Solution :**
- Tu n'as pas de profil dans la table `users`
- Déconnecte-toi et reconnecte-toi dans l'app
- Cela créera automatiquement ton profil

---

### Problème 4 : "permission denied for function process_withdrawal"

**Erreur dans l'app :**
```
❌ Erreur: permission denied for function process_withdrawal
```

**Solution :**
- Les permissions de la fonction ne sont pas correctes
- Exécute cette commande dans le SQL Editor :

```sql
GRANT EXECUTE ON FUNCTION process_withdrawal(UUID, NUMERIC, TEXT) TO authenticated;
```

---

## 🎉 Félicitations !

Si tout fonctionne, tu as maintenant :
- ✅ Un système de retrait fonctionnel
- ✅ Déduction automatique du solde
- ✅ Vérification du solde suffisant
- ✅ Historique des transactions

---

## 🚀 Prochaines Étapes

Maintenant que le système de retrait fonctionne, tu peux :

1. **Tester avec des montants différents**
2. **Ajouter des gains via le recyclage**
3. **Implémenter le système d'épargne** (utilise le même principe)
4. **Connecter la poubelle intelligente** pour ajouter des gains automatiquement

---

## 📞 Besoin d'Aide ?

Si tu rencontres des problèmes :
1. Vérifie que Supabase est bien connecté (vois les logs dans la console)
2. Vérifie que la fonction SQL a bien été créée
3. Envoie-moi une capture d'écran de l'erreur

**Bon courage ! 🎯**

