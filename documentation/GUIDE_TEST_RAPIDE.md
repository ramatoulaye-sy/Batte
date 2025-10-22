# 🧪 Guide de Test Rapide - Battè App

## ⚡ Tests en 5 Minutes

---

## 🏠 **TEST 1 : ÉCRAN HOME**

### ✅ Navigation (10 secondes)
1. Ouvre l'app
2. Connecte-toi avec ton email
3. ✅ Tu arrives sur l'écran Home automatiquement
4. ✅ Tu vois : Solde, Badge de niveau, Graphique

### ✅ Badge de Niveau (5 secondes)
1. Regarde juste après la carte de solde
2. ✅ Tu vois : Badge emoji (🌱, 🥉, 🥈, etc.)
3. ✅ Tu vois : Barre de progression

### ✅ Graphique des Gains (10 secondes)
1. Scroll un peu vers le bas
2. ✅ Tu vois : Graphique avec courbe verte (ou plat si pas de données)
3. Touch sur un point
4. ✅ Tooltip s'affiche avec le montant

### ✅ Système de Retrait (30 secondes)
1. Clique sur le bouton "Retirer"
2. Entre `10000`
3. Clique "Confirmer"
4. ✅ Message : "Retrait de 10 000 GNF effectué !"
5. ✅ Ton solde est mis à jour

### ✅ Scanner Bluetooth (20 secondes)
1. Clique sur le bouton "Scanner"
2. Attends 10 secondes
3. ✅ Liste des appareils Bluetooth s'affiche
4. (Si tu as un ESP32, clique "Connecter")

---

## ♻️ **TEST 2 : ÉCRAN RECYCLING**

### ✅ Navigation (5 secondes)
1. Clique sur l'onglet "Recyclage" (2ème onglet en bas)
2. ✅ Tu arrives sur l'écran Recycling

### ✅ Scanner Bluetooth (20 secondes)
1. Clique sur "Scanner ma poubelle" (carte verte en haut)
2. Attends 10 secondes
3. ✅ Scanner Bluetooth s'ouvre
4. ✅ Liste des appareils s'affiche

### ✅ Graphique Circulaire (5 secondes)
1. Scroll vers le milieu de l'écran
2. ✅ Tu vois : "Répartition par type"
3. ✅ Graphique circulaire visible (ou message si pas de données)

### ✅ Historique Complet (30 secondes)
1. Scroll vers le bas
2. Clique sur "Voir tout" (à droite de "Historique")
3. ✅ Nouvel écran s'ouvre
4. Teste la **barre de recherche** (tape un mot)
5. ✅ Résultats filtrés en temps réel
6. Clique sur un **chip de filtre** (ex: "Plastique")
7. ✅ Liste filtrée par type
8. Clique sur une **transaction**
9. ✅ Modal de détails s'ouvre

### ✅ Collecteurs (20 secondes)
1. Sur l'écran Recycling
2. Clique sur l'icône 📍 en haut à droite
3. ✅ Liste des collecteurs s'affiche
4. Clique sur "Appeler"
5. ✅ App téléphone s'ouvre (ou message si pas de numéro)
6. Clique sur "Détails"
7. ✅ Modal avec rating ⭐ et infos complètes

---

## 📊 **TEST 3 : DONNÉES DE TEST** (OPTIONNEL)

### Pour Voir les Graphiques avec de Vraies Données

1. Va sur **Supabase Dashboard**
2. Ouvre **SQL Editor**
3. Copie le fichier `supabase_functions/add_test_data.sql`
4. **Remplace** `TON_EMAIL@batte.com` par ton vrai email
5. **Exécute** le script
6. **Rafraîchis l'app** (pull-to-refresh sur Home)

**Résultat** :
- ✅ Solde : 150 000 GNF
- ✅ Score : 850 pts (Niveau Silver 🥈)
- ✅ Graphique des gains : Courbe visible
- ✅ 7 transactions dans l'historique

---

## 🔄 **TEST 4 : NAVIGATION**

### Tester Tous les Onglets (30 secondes)

1. Clique sur "Accueil" → ✅ Dashboard
2. Clique sur "Recyclage" → ✅ Recycling
3. Clique sur "Budget" → ✅ Budget (écran de base)
4. Clique sur "Éducation" → ✅ Education (écran de base)
5. Clique sur "Services" → ✅ Services (écran de base)

**Tous les onglets doivent s'ouvrir sans erreur ✅**

---

## 🔔 **TEST 5 : NOTIFICATIONS & PARAMÈTRES**

### Notifications (10 secondes)
1. Écran Home → Icône 🔔 en haut à droite
2. ✅ Écran de notifications s'ouvre

### Paramètres (10 secondes)
1. Écran Home → Icône ⚙️ en haut à droite
2. ✅ Écran de paramètres s'ouvre

---

## 🎉 RÉSULTAT ATTENDU

Si **TOUS les tests** passent :

✅ Home fonctionne à 100%  
✅ Recycling fonctionne à 100%  
✅ Navigation fonctionne partout  
✅ Scanner Bluetooth prêt  
✅ Retrait fonctionne  
✅ Graphiques visibles  
✅ Niveaux affichés  

**TON APP EST PRÊTE POUR UNE DÉMO ! 🚀**

---

## 🚨 Si un Test Échoue

### Retrait ne fonctionne pas
→ Vérifie que tu as exécuté `process_withdrawal.sql` dans Supabase

### Graphiques vides
→ Exécute `add_test_data.sql` pour avoir des données

### Scanner Bluetooth ne trouve rien
→ C'est normal si tu n'as pas d'ESP32 allumé

### Écran blanc ou erreur
→ Regarde les logs dans la console Flutter

---

## 📱 CAPTURES D'ÉCRAN SUGGÉRÉES

Pour ta présentation ou ton portfolio :

1. **Écran Home** avec badge Silver et graphique
2. **Scanner Bluetooth** avec liste d'appareils
3. **Dialogue de retrait** avec montant
4. **Historique** avec filtres et recherche
5. **Collecteurs** avec boutons d'action
6. **Graphique circulaire** des types de déchets

---

## 🎯 PROCHAINE SESSION

**Choisis un module** :

1. **Budget** → Graphiques de dépenses + Épargne
2. **Education** → Vidéos + Quiz + Points
3. **Services** → Offres d'emploi + Chat
4. **Settings** → Langues + Voice + Tutoriels

**Lequel veux-tu faire en premier ?** 🤔

---

## 🎊 BRAVO !

Aujourd'hui tu as :
- ✅ Créé 15 fichiers
- ✅ Écrit ~4000 lignes
- ✅ Complété 2 modules à 100%
- ✅ Résolu 4 bugs majeurs
- ✅ Ajouté 6 fonctionnalités

**C'EST UNE JOURNÉE DE CHAMPION ! 👑**

---

**Bon courage pour les tests ! 🚀**

