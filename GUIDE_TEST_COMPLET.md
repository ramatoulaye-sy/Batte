# 🧪 GUIDE DE TEST COMPLET - APPLICATION BATTÈ v1.0.0

## 📱 **INFORMATIONS GÉNÉRALES**

- **Version**: 1.0.0
- **Plateforme**: Android
- **Taille APK**: 56.9 MB
- **Taille App Bundle**: 45.6 MB
- **Langues**: Français (principal), Anglais
- **Architecture**: Offline-first avec synchronisation Supabase

---

## 🚀 **INSTALLATION**

### **Option 1: APK Direct**
1. Téléchargez le fichier `app-release.apk` depuis le dossier `build/app/outputs/flutter-apk/`
2. Activez "Sources inconnues" dans les paramètres Android
3. Installez l'APK en le tapant

### **Option 2: App Bundle (Recommandé)**
1. Téléchargez le fichier `app-release.aab` depuis le dossier `build/app/outputs/bundle/release/`
2. Utilisez Google Play Console pour l'installer (plus optimisé)

---

## 🎯 **OBJECTIFS DE TEST**

L'application Battè transforme les déchets en argent via une poubelle intelligente connectée. Testez toutes les fonctionnalités pour valider l'expérience utilisateur complète.

---

## 📋 **CHECKLIST DE TEST PAR ÉCRAN**

### **1. 🚀 ÉCRAN DE DÉMARRAGE (Splash Screen)**

**À tester :**
- [ ] L'écran s'affiche avec le logo Battè
- [ ] Animation de chargement fonctionne
- [ ] Redirection automatique vers l'écran approprié
- [ ] Pas de crash ou freeze

**Durée estimée :** 30 secondes

---

### **2. 📚 ÉCRAN D'ONBOARDING**

**À tester :**
- [ ] Navigation entre les 3 écrans d'introduction
- [ ] Boutons "Suivant" et "Commencer" fonctionnent
- [ ] Design cohérent et animations fluides
- [ ] Possibilité de passer l'onboarding

**Durée estimée :** 2 minutes

---

### **3. 🔐 AUTHENTIFICATION**

#### **3.1 Écran de Connexion**
- [ ] Champs email et mot de passe fonctionnent
- [ ] Validation des champs (email valide, mot de passe requis)
- [ ] Bouton "Se connecter" fonctionne
- [ ] Lien "Créer un compte" fonctionne
- [ ] Messages d'erreur appropriés

#### **3.2 Écran d'Inscription**
- [ ] Tous les champs sont remplissables
- [ ] Validation des données (email, téléphone, mot de passe)
- [ ] Sélection du type de profil (Utilisateur/Collecteur)
- [ ] Bouton "Créer le compte" fonctionne
- [ ] Messages de confirmation

#### **3.3 Choix de Profil**
- [ ] Affichage des profils disponibles
- [ ] Boutons "Utilisateur" et "Collecteur" fonctionnent
- [ ] Redirection vers le bon dashboard

**Durée estimée :** 5 minutes

---

### **4. 🏠 DASHBOARD UTILISATEUR**

#### **4.1 Écran Principal**
- [ ] Header avec nom d'utilisateur et photo de profil
- [ ] Carte de solde avec montant total
- [ ] Carte des gains mensuels
- [ ] Score écologique affiché
- [ ] Statistiques de recyclage (poids total)
- [ ] Graphique des gains hebdomadaires
- [ ] Navigation vers les autres écrans

#### **4.2 Navigation Bottom Bar**
- [ ] Bouton "Accueil" → Dashboard principal
- [ ] Bouton "Recyclage" → Écran de recyclage
- [ ] Bouton "Budget" → Écran de budget
- [ ] Bouton "Éducation" → Écran d'éducation
- [ ] Bouton "Services" → Écran de services

**Durée estimée :** 3 minutes

---

### **5. ♻️ MODULE DE RECYCLAGE**

#### **5.1 Écran Principal de Recyclage**
- [ ] Affichage des types de déchets disponibles
- [ ] Bouton "Scanner avec Bluetooth" fonctionne
- [ ] Bouton "Ajouter manuellement" fonctionne
- [ ] Historique des recyclages affiché
- [ ] Statistiques de recyclage

#### **5.2 Ajout Manuel de Déchets**
- [ ] Sélection du type de déchet
- [ ] Saisie du poids
- [ ] Calcul automatique du prix
- [ ] Bouton "Ajouter" fonctionne
- [ ] Confirmation d'ajout
- [ ] Mise à jour du solde

#### **5.3 Connexion Bluetooth**
- [ ] Scan des appareils disponibles
- [ ] Connexion à une poubelle intelligente
- [ ] Réception des données de poids
- [ ] Calcul automatique du prix
- [ ] Sauvegarde de la transaction

#### **5.4 Historique des Recyclages**
- [ ] Liste des recyclages passés
- [ ] Filtres par date (Aujourd'hui, Cette semaine, Ce mois)
- [ ] Détails de chaque recyclage
- [ ] Possibilité de supprimer un recyclage
- [ ] Statistiques globales

**Durée estimée :** 10 minutes

---

### **6. 💰 MODULE DE BUDGET**

#### **6.1 Écran Principal de Budget**
- [ ] Solde total affiché
- [ ] Gains mensuels
- [ ] Graphique des revenus
- [ ] Liste des transactions récentes
- [ ] Bouton "Demander un retrait"

#### **6.2 Historique des Transactions**
- [ ] Liste complète des transactions
- [ ] Filtres par type (Recyclage, Retrait)
- [ ] Filtres par date
- [ ] Détails de chaque transaction
- [ ] Export des données (si disponible)

#### **6.3 Demandes de Retrait**
- [ ] Formulaire de demande de retrait
- [ ] Sélection du montant
- [ ] Choix de la méthode de paiement
- [ ] Validation et soumission
- [ ] Suivi du statut

**Durée estimée :** 8 minutes

---

### **7. 📚 MODULE D'ÉDUCATION**

#### **7.1 Écran Principal d'Éducation**
- [ ] Liste des articles éducatifs
- [ ] Catégories disponibles
- [ ] Progression de lecture
- [ ] Points gagnés par lecture

#### **7.2 Lecture d'Articles**
- [ ] Affichage du contenu complet
- [ ] Navigation entre les pages
- [ ] Bouton "Marquer comme lu"
- [ ] Attribution des points
- [ ] Retour à la liste

#### **7.3 Quiz et Défis**
- [ ] Questions à choix multiples
- [ ] Validation des réponses
- [ ] Attribution des points
- [ ] Progression des défis

**Durée estimée :** 7 minutes

---

### **8. 🛠️ MODULE DE SERVICES**

#### **8.1 Écran Principal des Services**
- [ ] Liste des offres de services
- [ ] Liste des demandes de services
- [ ] Boutons "Je propose" et "Je cherche"
- [ ] Filtres par catégorie

#### **8.2 Proposer un Service**
- [ ] Formulaire de création d'offre
- [ ] Champs : Titre, Description, Catégorie, Prix, Durée, Adresse
- [ ] Validation des champs
- [ ] Bouton "Publier" fonctionne
- [ ] Confirmation de publication

#### **8.3 Demander un Service**
- [ ] Formulaire de création de demande
- [ ] Champs : Titre, Description, Budget, Durée, Adresse
- [ ] Validation des champs
- [ ] Bouton "Publier" fonctionne
- [ ] Confirmation de publication

#### **8.4 Gestion des Services**
- [ ] Affichage des services publiés
- [ ] Possibilité de contacter le prestataire
- [ ] Système de messagerie (si disponible)

**Durée estimée :** 12 minutes

---

### **9. 🚛 DASHBOARD COLLECTEUR**

#### **9.1 Écran Principal Collecteur**
- [ ] Header avec nom d'entreprise
- [ ] Statut de disponibilité (Disponible/Indisponible)
- [ ] Carte de gains totaux
- [ ] Statistiques de collectes
- [ ] Graphique des gains hebdomadaires
- [ ] Actions rapides

#### **9.2 Navigation Collecteur**
- [ ] Bouton "Accueil" → Dashboard collecteur
- [ ] Bouton "Collectes" → Historique des collectes
- [ ] Bouton "Profil" → Profil collecteur
- [ ] Bouton "Paramètres" → Paramètres collecteur

#### **9.3 Historique des Collectes**
- [ ] Liste des collectes effectuées
- [ ] Filtres par période
- [ ] Détails de chaque collecte
- [ ] Statistiques de performance
- [ ] Actions sur les collectes

#### **9.4 Profil Collecteur**
- [ ] Informations de l'entreprise
- [ ] Statistiques personnelles
- [ ] Documents du collecteur
- [ ] Édition des informations
- [ ] Actions disponibles

#### **9.5 Paramètres Collecteur**
- [ ] Statut de disponibilité
- [ ] Paramètres de travail (rayon, heures)
- [ ] Notifications
- [ ] Localisation
- [ ] Paramètres avancés

**Durée estimée :** 15 minutes

---

### **10. 👤 PROFIL UTILISATEUR**

#### **10.1 Écran de Profil**
- [ ] Photo de profil affichée
- [ ] Informations personnelles
- [ ] Statistiques de recyclage
- [ ] Historique des activités
- [ ] Paramètres du compte

#### **10.2 Édition du Profil**
- [ ] Modification des informations
- [ ] Changement de photo
- [ ] Mise à jour des préférences
- [ ] Sauvegarde des modifications

**Durée estimée :** 5 minutes

---

## 🔧 **TESTS TECHNIQUES**

### **Performance**
- [ ] L'application se lance rapidement (< 5 secondes)
- [ ] Navigation fluide entre les écrans
- [ ] Pas de lag ou freeze
- [ ] Consommation mémoire raisonnable

### **Connectivité**
- [ ] Fonctionnement en mode hors ligne
- [ ] Synchronisation lors du retour en ligne
- [ ] Gestion des erreurs de réseau
- [ ] Messages d'erreur appropriés

### **Bluetooth**
- [ ] Scan des appareils disponibles
- [ ] Connexion aux poubelles intelligentes
- [ ] Réception des données
- [ ] Gestion des déconnexions

### **Géolocalisation**
- [ ] Demande de permissions
- [ ] Calcul des distances
- [ ] Affichage des collecteurs proches
- [ ] Gestion des erreurs de localisation

---

## 🐛 **RAPPORT DE BUGS**

Pour chaque bug trouvé, notez :

1. **Écran concerné** : Dans quel écran le bug apparaît
2. **Actions effectuées** : Quelles actions ont causé le bug
3. **Comportement attendu** : Ce qui devrait se passer
4. **Comportement observé** : Ce qui s'est réellement passé
5. **Sévérité** : Critique / Important / Mineur
6. **Screenshots** : Si possible, capturez l'écran

**Exemple de rapport :**
```
Écran : Module de Recyclage - Ajout Manuel
Actions : Sélectionner "Plastique", saisir "5.5" kg
Attendu : Prix calculé automatiquement (27500 GNF)
Observé : Prix reste à 0 GNF
Sévérité : Important
```

---

## 📊 **CRITÈRES DE VALIDATION**

### **✅ Test Réussi Si :**
- Tous les écrans s'affichent correctement
- La navigation fonctionne sans erreur
- Les formulaires valident et sauvegardent les données
- Les calculs de prix sont corrects
- L'interface est intuitive et agréable
- Pas de crash ou freeze majeur

### **❌ Test Échoué Si :**
- Crash de l'application
- Données non sauvegardées
- Calculs incorrects
- Interface non fonctionnelle
- Navigation bloquée

---

## 📝 **RAPPORT FINAL**

À la fin des tests, remplissez ce rapport :

### **Informations Générales**
- **Nom du testeur** : ________________
- **Date de test** : ________________
- **Durée totale** : ________________
- **Appareil utilisé** : ________________
- **Version Android** : ________________

### **Résultats par Module**
- **Authentification** : ✅ Réussi / ❌ Échec
- **Dashboard Utilisateur** : ✅ Réussi / ❌ Échec
- **Module Recyclage** : ✅ Réussi / ❌ Échec
- **Module Budget** : ✅ Réussi / ❌ Échec
- **Module Éducation** : ✅ Réussi / ❌ Échec
- **Module Services** : ✅ Réussi / ❌ Échec
- **Dashboard Collecteur** : ✅ Réussi / ❌ Échec

### **Bugs Trouvés**
- **Nombre total** : ________________
- **Critiques** : ________________
- **Importants** : ________________
- **Mineurs** : ________________

### **Recommandations**
- **Améliorations suggérées** : ________________
- **Fonctionnalités manquantes** : ________________
- **Expérience utilisateur** : ________________

### **Note Globale**
- **Note sur 10** : ________________
- **Recommandation** : ✅ Prêt pour production / ❌ Nécessite des corrections

---

## 📞 **SUPPORT**

En cas de problème ou de question :
- **Email** : batte@example.com
- **GitHub** : https://github.com/ramatoulaye-sy/Batte
- **Documentation** : Voir le dossier `documentation/`

---

## 🎉 **MERCI !**

Merci de participer aux tests de l'application Battè ! Votre feedback est essentiel pour améliorer l'expérience utilisateur et préparer le lancement officiel.

**Bonne chance avec les tests ! 🚀**
