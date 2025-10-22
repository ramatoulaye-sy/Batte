# 🧪 GUIDE DE TEST - 9 NOUVEAUX ÉCRANS UTILISATEURS

## 📱 COMMENT TESTER LES NOUVEAUX ÉCRANS

Tous les écrans sont maintenant **intégrés et accessibles** depuis l'application ! Voici comment y accéder :

---

## ✅ **1. PROFIL COMPLET** (`profile_screen.dart`)

**Comment y accéder :**
1. Va dans l'onglet **Services** (barre de navigation)
2. Clique sur l'**icône de profil** en haut à droite
3. OU depuis **Paramètres** → icône profil

**Ce qu'il contient :**
- Avatar utilisateur (avec bouton pour changer la photo)
- Nom, email, téléphone
- Statistiques : déchets recyclés, gains, retraits, eco-score, niveau
- Informations du compte (ville, langue)
- Actions : Modifier profil, Parrainer des amis, Changer mot de passe, Supprimer compte, Déconnexion

---

## ✅ **2. MODIFIER PROFIL** (`edit_profile_screen.dart`)

**Comment y accéder :**
1. Va dans **Profil** (voir ci-dessus)
2. Clique sur **"Modifier mon profil"**

**Ce qu'il contient :**
- Formulaire pour modifier : Nom, Email, Téléphone, Ville, Adresse, Bio
- Bouton **"Enregistrer les modifications"**

---

## ✅ **3. HISTORIQUE DES TRANSACTIONS AMÉLIORÉ** (`enhanced_transactions_screen.dart`)

**Comment y accéder :**
1. Va dans l'onglet **Budget**
2. Clique sur le bouton **"Historique"** (en haut)

**Ce qu'il contient :**
- Toutes les transactions avec filtres avancés
- **Filtres par type** : Tout, Recyclage, Retrait
- **Filtres par date** : Cette semaine, Ce mois, 3 derniers mois, Cette année
- **Recherche** par description
- **Export PDF/CSV** (boutons en haut à droite)
- Affichage détaillé : type, montant, date, description

---

## ✅ **4. MÉTHODES DE RETRAIT** (`withdrawal_methods_screen.dart`)

**Comment y accéder :**
1. Va dans l'onglet **Budget**
2. Clique sur le bouton **"Retirer"** (en haut, vert)

**Ce qu'il contient :**
- Choix de la méthode de retrait :
  - **Mobile Money** (Orange, MTN, Moov)
  - **Compte bancaire**
- Formulaire pour saisir les informations de retrait
- Montant à retirer
- Bouton **"Confirmer le retrait"**

---

## ✅ **5. NOTIFICATIONS** (`notifications_list_screen.dart`)

**Comment y accéder :**
1. Va dans l'onglet **Paramètres** (icône engrenage en bas)
2. Scroll vers le bas jusqu'à la section **"Fonctionnalités"**
3. Clique sur **"Notifications"**

**Ce qu'il contient :**
- Liste de toutes les notifications
- Badge "Non lu" pour les nouvelles notifications
- Types : Info, Succès, Avertissement, Transaction, Mission
- Date et heure de réception
- Action pour marquer comme lu

---

## ✅ **6. FAQ / AIDE** (`faq_screen.dart`)

**Comment y accéder :**
1. Va dans **Paramètres**
2. Section **"À propos"**
3. Clique sur **"Aide et support"**

**Ce qu'il contient :**
- Questions fréquentes avec réponses
- Catégories : Compte, Recyclage, Paiements, Technique
- Accordéon dépliable pour chaque question

---

## ✅ **7. MISSIONS QUOTIDIENNES** (`missions_screen.dart`)

**Comment y accéder :**
1. Va dans **Paramètres**
2. Section **"Fonctionnalités"**
3. Clique sur **"Missions quotidiennes"**

**Ce qu'il contient :**
- **Missions quotidiennes** : petites tâches à accomplir (ex: recycler 5 kg)
- **Missions hebdomadaires** : objectifs plus ambitieux
- Barre de progression pour chaque mission
- Récompenses en points et badges
- Statut : En cours / Terminée

---

## ✅ **8. CLASSEMENT / LEADERBOARD** (`leaderboard_screen.dart`)

**Comment y accéder :**
1. Va dans **Paramètres**
2. Section **"Fonctionnalités"**
3. Clique sur **"Classement"**

**Ce qu'il contient :**
- **Top 10** des meilleurs recycleurs
- Classement par : Poids recyclé, Points, Gains
- Ton classement actuel avec badge
- Avatar, nom, score de chaque utilisateur

---

## ✅ **9. CARTE INTERACTIVE** (`interactive_map_screen.dart`)

**Comment y accéder :**
1. Va dans l'onglet **Accueil** (Dashboard)
2. Clique sur la carte **"Carte interactive"** dans les statistiques

**Ce qu'il contient :**
- Carte de Conakry avec marqueurs
- **Collecteurs disponibles** (icône camion vert)
- **Points de collecte** (icône corbeille bleue)
- Infos au clic : nom, adresse, distance, disponibilité
- Bouton **"Appeler"** pour contacter
- Ta position actuelle

---

## ✅ **10. PARRAINAGE** (`referral_screen.dart`)

**Comment y accéder :**
1. Va dans **Profil** (voir ci-dessus)
2. Clique sur **"Parrainer des amis"**

**Ce qu'il contient :**
- Ton **code de parrainage unique**
- Statistiques : amis parrainés, bonus gagnés
- Bouton **"Copier le code"**
- Boutons de partage : WhatsApp, Facebook, SMS, Email
- Historique des parrainages avec date et bonus

---

## 🎯 **CHECKLIST DE TEST**

### ✅ Test 1 : Navigation
- [ ] Tous les écrans sont accessibles via la navigation
- [ ] Les boutons retour fonctionnent correctement
- [ ] Pas d'erreurs dans les logs

### ✅ Test 2 : Affichage
- [ ] Les données s'affichent correctement (pas de null/undefined)
- [ ] Les images et avatars se chargent
- [ ] Pas d'overflow ou de débordement de texte

### ✅ Test 3 : Interactions
- [ ] Les formulaires acceptent les saisies
- [ ] Les boutons répondent au clic
- [ ] Les filtres fonctionnent (transactions, missions, etc.)
- [ ] La recherche fonctionne (transactions)

### ✅ Test 4 : Fonctionnalités
- [ ] Modification de profil → enregistrement
- [ ] Copie du code de parrainage
- [ ] Export PDF/CSV (transactions)
- [ ] Tri et filtres (leaderboard, transactions)
- [ ] Marquage des notifications comme lues

---

## ⚠️ **LIMITATIONS ACTUELLES**

Ces écrans sont **fonctionnels** mais nécessitent encore des **données Supabase** pour être pleinement opérationnels :

1. **Notifications** : Table `notifications` non créée → Exécuter le script SQL fourni
2. **Missions** : Table `missions` non créée → À créer dans Supabase
3. **Leaderboard** : Nécessite plusieurs utilisateurs enregistrés
4. **Carte** : Utilise des données de démonstration (collecteurs fictifs)
5. **Parrainage** : Code généré localement, pas encore lié à Supabase

---

## 🚀 **PROCHAINES ÉTAPES**

1. **Tester chaque écran** en suivant les chemins ci-dessus
2. **Créer les tables Supabase** manquantes (missions, leaderboard, referrals)
3. **Implémenter les notifications push** (Firebase Cloud Messaging)
4. **Connecter la carte** à des données réelles de collecteurs
5. **Ajouter l'upload d'avatar** (Supabase Storage)

---

## 📝 **NOTES IMPORTANTES**

- **Tous les écrans sont pour UTILISATEURS** (pas collecteurs)
- **Aucun écran existant n'a été cassé** ✅
- **La navigation est fluide** entre tous les écrans
- Les écrans utilisent les **mêmes providers** (AuthProvider, BudgetProvider, WasteProvider)

---

Bon test ! 🎉

