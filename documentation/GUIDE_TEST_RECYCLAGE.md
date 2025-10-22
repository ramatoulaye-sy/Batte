# 🧪 Guide de Test - Écran Recyclage

## 🚀 Démarrage Rapide

```bash
cd C:\Users\USER\Desktop\Batte
flutter run
```

---

## ✅ Tests à Effectuer

### 1️⃣ **Formulaire Manuel d'Ajout**

#### Accès :
1. Lancer l'app
2. Se connecter (ou s'inscrire)
3. Aller sur l'écran **Recyclage** (2ème onglet)
4. Cliquer sur **"Ajouter manuellement"**

#### Tests :
- [ ] **Sélection de type** : Cliquer sur chaque type de déchet
  - Vérifier que la carte se colore en vert
  - Vérifier l'icône ✅ apparaît
  
- [ ] **Saisie de poids** :
  - Entrer `2.5` kg
  - Vérifier que la carte dorée "Valeur estimée" apparaît en temps réel
  
- [ ] **Calcul de valeur** :
  - Plastique 2.5 kg → `3 750 GNF`
  - Papier 2.5 kg → `2 000 GNF`
  - Métal 2.5 kg → `5 000 GNF`
  - Verre 2.5 kg → `1 250 GNF`
  - Organique 2.5 kg → `750 GNF`
  
- [ ] **Validation** :
  - Essayer sans type → Erreur affichée
  - Essayer avec poids 0 → Erreur "doit être supérieur à 0"
  - Essayer avec poids 1001 → Erreur "ne peut pas dépasser 1000 kg"
  - Essayer avec texte → Erreur "Poids invalide"
  
- [ ] **Soumission** :
  - Remplir correctement (ex: Plastique, 2.5 kg)
  - Cliquer sur "Valider le recyclage"
  - Vérifier le dialog de succès s'affiche
  - Vérifier la notification dans la console : `📢 Notification: 🎉 Recyclage réussi !`
  - Attendre 2 secondes → Retour automatique à l'écran Recyclage
  - Vérifier que le nouveau déchet apparaît dans l'historique récent

---

### 2️⃣ **Géolocalisation et Collecteurs**

#### Accès :
1. Sur l'écran **Recyclage**
2. Cliquer sur l'icône **📍 localisation** en haut à droite (dans le header blanc)

#### Tests :
- [ ] **Demande de permission** :
  - Première fois → Permission GPS demandée
  - Accepter ou refuser
  
- [ ] **Si GPS Accepté** :
  - Badge **"GPS activé"** apparaît dans l'AppBar
  - Liste de 5 collecteurs affichée
  - Chaque collecteur a une **distance** (ex: 1.2 km, 850 m)
  - Les collecteurs sont **triés par distance** (le plus proche en premier)
  
- [ ] **Si GPS Refusé** :
  - Message "Localisation désactivée" affiché
  - Liste de 5 collecteurs affichée (sans distances)
  - Texte "Distance non disponible" sous chaque collecteur
  
- [ ] **Interaction avec collecteurs** :
  - Cliquer sur **"Appeler"** → L'app téléphone s'ouvre
  - Cliquer sur **"Détails"** → BottomSheet s'affiche avec :
    - Avatar
    - Nom
    - Note (étoiles)
    - Localisation
    - Téléphone
    - Distance (si GPS activé)
    - Disponibilité (✅ ou ❌)
  
- [ ] **Rafraîchir** :
  - Cliquer sur l'icône **🔄 refresh** en haut à droite
  - Les distances sont recalculées

---

### 3️⃣ **Statistiques et Affichage**

#### Sur l'écran Recyclage :

- [ ] **Cartes de statistiques** :
  - Poids total (en kg)
  - Valeur totale (en GNF)
  
- [ ] **Graphique circulaire** :
  - Affiche la répartition par type
  - Légende avec couleurs
  
- [ ] **Cartes de types** :
  - Une carte par type de déchet
  - Affiche : icône, nom, prix/kg, poids total, valeur totale
  
- [ ] **Historique récent** :
  - 5 derniers déchets affichés
  - Chaque carte affiche : icône, type, date relative, poids, valeur
  - Date relative : "Il y a 2 heures", "Il y a 3 jours", etc.
  - Bouton "Voir tout" → Navigation vers l'historique complet

---

### 4️⃣ **Tests Réseau**

#### Mode Online :
- [ ] Ajouter un déchet → Sauvegardé dans Supabase
- [ ] Vérifier dans la base de données Supabase

#### Mode Offline (simuler) :
- [ ] Désactiver WiFi/données mobiles
- [ ] Ajouter un déchet
- [ ] Message affiché : "Sauvegardé en local. Sera synchronisé plus tard."
- [ ] Le déchet apparaît quand même dans l'historique (badge "non synchronisé")
- [ ] Réactiver WiFi/données
- [ ] Rafraîchir l'écran → Synchronisation automatique

---

## 🎯 Scénarios de Test Complets

### Scénario A : Utilisateur Nouveau (Aucun Déchet)
1. ✅ Écran Recyclage affiche :
   - Poids total : 0 kg
   - Valeur totale : 0 GNF
   - Graphique vide
   - Message "Aucun déchet recyclé"
   - "Scannez votre poubelle pour commencer"
2. ✅ Ajouter 1er déchet via formulaire manuel
3. ✅ Vérifier que tout s'affiche correctement après

### Scénario B : Utilisateur Actif (Plusieurs Déchets)
1. ✅ Ajouter 5 déchets de types différents
2. ✅ Vérifier les statistiques se mettent à jour
3. ✅ Vérifier le graphique circulaire affiche 5 parts
4. ✅ Vérifier l'historique récent affiche les 5
5. ✅ Cliquer sur "Voir tout" → Historique complet

### Scénario C : Test GPS Complet
1. ✅ Désactiver GPS sur le téléphone
2. ✅ Aller sur Collecteurs → Message "Localisation désactivée"
3. ✅ Activer GPS
4. ✅ Rafraîchir → Badge "GPS activé" apparaît
5. ✅ Vérifier les distances sont calculées
6. ✅ Vérifier le tri par proximité

---

## 🐛 Vérifications de Non-Régression

- [ ] **Navigation** :
  - Tous les onglets fonctionnent
  - Retour arrière fonctionne
  - Navigation entre écrans OK
  
- [ ] **Animations** :
  - Pas de lag
  - Transitions fluides
  - Pas de clignotement
  
- [ ] **Performance** :
  - Chargement rapide
  - Pas de freeze
  - Scroll fluide

---

## 📝 Checklist Rapide

### Formulaire Manuel
- [ ] Sélection type ✅
- [ ] Saisie poids ✅
- [ ] Calcul temps réel ✅
- [ ] Validation erreurs ✅
- [ ] Soumission + notification ✅
- [ ] Retour + refresh ✅

### Géolocalisation
- [ ] Permission GPS ✅
- [ ] Calcul distances ✅
- [ ] Tri collecteurs ✅
- [ ] Appel téléphone ✅
- [ ] Détails collecteur ✅

### Affichage
- [ ] Statistiques ✅
- [ ] Graphique ✅
- [ ] Types déchets ✅
- [ ] Historique ✅
- [ ] Dates relatives ✅

---

## 🎉 Résultat Attendu

Après avoir effectué tous ces tests, **TOUT devrait fonctionner parfaitement** ! 

Si une erreur survient, vérifiez :
1. `flutter pub get` a été exécuté
2. L'app a été redémarrée après l'ajout de `geolocator`
3. Les permissions GPS ont été accordées (pour les tests de localisation)

---

## 💡 Astuce de Debug

Si vous voyez des erreurs dans la console, elles commenceront par des emojis :
- ✅ : Succès
- ⚠️ : Avertissement (non bloquant)
- ❌ : Erreur (bloquant)
- 📢 : Notification

Exemple :
```
✅ Position obtenue: 9.6412, -13.5784
📢 Notification: 🎉 Recyclage réussi ! Vous avez gagné 3 750 GNF
```

---

## 🚀 Prochaine Étape

Une fois tous les tests passés ✅, la fonctionnalité est **PRODUCTION-READY** !

Quand la poubelle Bluetooth sera fabriquée, il suffira de :
1. Cliquer sur "Scanner ma poubelle"
2. Connecter la poubelle
3. Les données seront récupérées automatiquement

**Aucun code supplémentaire n'est nécessaire !** 🎊

