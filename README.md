# 🗑️ **Batte - Application de Valorisation des Déchets**

> **Initiative technologique pour équiper les foyers guinéens d'une poubelle intelligente et d'une application mobile/web pour le tri et la valorisation des déchets.**

## 🎯 **Vue d'ensemble**

Batte est une solution complète qui transforme la gestion des déchets en opportunité économique et environnementale. L'application permet aux utilisateurs de :

- **Monétiser leurs déchets** en les vendant aux collecteurs
- **Suivre leur impact environnemental** avec des statistiques détaillées
- **Accéder à du contenu éducatif** sur la gestion des déchets
- **Gérer leur budget** et économiser leurs gains
- **Participer à une communauté** engagée pour un environnement plus propre

## 🏗️ **Architecture du Projet**

### **Structure des Dossiers**
```
lib/
├── core/                           # Configuration et utilitaires
│   ├── app_theme.dart             # Thèmes et couleurs de l'application
│   └── routes.dart                # Système de navigation
├── features/                       # Fonctionnalités par module
│   ├── home/                      # Page d'accueil
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── home_page.dart
│   │       └── widgets/
│   │           ├── bottom_navigation.dart
│   │           ├── home_header.dart
│   │           ├── interactive_map.dart
│   │           └── quick_actions.dart
│   ├── monetization/              # Monétisation des déchets
│   │   └── presentation/
│   │       └── pages/
│   │           └── monetization_page.dart
│   ├── pour_moi/                  # Section personnalisée
│   ├── budget/                    # Gestion du budget
│   ├── profile/                   # Profil utilisateur
│   ├── collector/                 # Interface collecteur
│   └── auth/                      # Authentification
├── shared/                        # Composants partagés
└── main.dart                      # Point d'entrée de l'application
```

## 🚀 **Fonctionnalités Principales**

### **1. Page d'Accueil**
- **Carte interactive** avec localisation des collecteurs et utilisateurs
- **En-tête personnalisé** avec solde et points
- **Actions rapides** : Scan QR, Bluetooth, saisie manuelle
- **Navigation intuitive** entre les 5 sections principales

### **2. Monétisation**
- **Saisie manuelle** des déchets par catégorie
- **Conversion automatique** KG → GNF
- **Validation intelligente** (minimum 1kg pour vendre)
- **Prix par catégorie** :
  - Plastique : 150 GNF/kg
  - Organique : 100 GNF/kg
  - Verre : 200 GNF/kg
  - Métal : 300 GNF/kg
  - Papier : 120 GNF/kg

### **3. Système de Points**
- **Accumulation** de points lors des ventes
- **Bonus** pour la satisfaction des collecteurs
- **Conversion** points → GNF ou crédit téléphonique
- **Gamification** pour encourager la participation

## 🎨 **Design et UX**

### **Palette de Couleurs**
- **Primaire** : `#00A550` (Vert Batte)
- **Secondaire** : `#FFD700` (Or)
- **Accent** : `#1E88E5` (Bleu)
- **Succès** : `#4CAF50` (Vert)
- **Avertissement** : `#FF9800` (Orange)
- **Erreur** : `#D32F2F` (Rouge)

### **Principes de Design**
- **Material Design 3** pour une interface moderne
- **Responsive** et adaptatif à tous les écrans
- **Accessible** avec des contrastes optimisés
- **Intuitif** avec moins de 3 clics pour les actions principales

## 📱 **Scénarios d'Utilisation**

### **Scénario 1 : Sofia (Utilisatrice)**
1. **Scan du QR code** de sa poubelle intelligente
2. **Conversion automatique** du poids en monétisation
3. **Activation du bouton "Vendre"** si > 1kg
4. **Sélection du collecteur** avec le plus de points
5. **Suivi en temps réel** de l'arrivée du collecteur
6. **Paiement** et notation de satisfaction
7. **Gain de points** et gestion du budget

### **Scénario 2 : Collecteur**
1. **Visualisation** des demandes de collecte sur la carte
2. **Sélection** selon points, distance et disponibilité
3. **Navigation** vers l'utilisateur
4. **Paiement** et notation
5. **Publication** des stocks collectés

### **Scénario 3 : Entreprise**
1. **Consultation** des stocks disponibles
2. **Commande** via dashboard web
3. **Suivi** des livraisons

## 🔧 **Technologies Utilisées**

### **Frontend Mobile**
- **Framework** : Flutter 3.8.1+
- **Langage** : Dart
- **Architecture** : Clean Architecture avec Feature-based
- **État** : StatefulWidget + setState (Phase 1)

### **Backend (Phase 2)**
- **Runtime** : Node.js + Express
- **Base de données** : PostgreSQL (Supabase)
- **Authentification** : OTP SMS
- **Notifications** : Firebase Cloud Messaging

### **Poubelle Intelligente (Phase 2)**
- **Microcontrôleur** : ESP32
- **Capteurs** : 5× HX711 (précision ±50g)
- **Affichage** : OLED 128×64
- **Connexion** : BLE + QR code

## 📊 **Base de Données**

### **Tables Principales**
```sql
-- Utilisateurs
users (id, name, phone, points, balance, location)

-- Déchets
waste_transactions (id, user_id, type, weight, amount, date)

-- Collecteurs
collectors (id, name, rating, location, availability)

-- Transactions
transactions (id, user_id, collector_id, amount, status, date)

-- Notations
ratings (id, user_id, collector_id, rating, comment, date)
```

## 🚀 **Installation et Démarrage**

### **Prérequis**
- Flutter SDK 3.8.1+
- Dart SDK
- Android Studio / VS Code
- Git

### **Installation**
```bash
# Cloner le projet
git clone https://github.com/votre-username/batte.git

# Aller dans le dossier
cd batte

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

### **Configuration**
1. **Variables d'environnement** : Créer `.env` avec vos clés API
2. **Supabase** : Configurer votre projet et mettre à jour les URLs
3. **Permissions** : Activer la géolocalisation et le Bluetooth

## 🧪 **Tests**

### **Tests Unitaires**
```bash
# Lancer tous les tests
flutter test

# Tests avec couverture
flutter test --coverage
```

### **Tests d'Intégration**
```bash
# Tests d'intégration
flutter drive --target=test_driver/app.dart
```

## 📱 **Permissions Requises**

### **Android**
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

### **iOS**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Batte a besoin de votre localisation pour localiser les collecteurs</string>
<key>NSCameraUsageDescription</key>
<string>Batte a besoin de votre caméra pour scanner les QR codes</string>
```

## 🔒 **Sécurité**

### **Mesures Implémentées**
- **HTTPS** obligatoire pour toutes les communications
- **Chiffrement AES-256** pour les données sensibles
- **Validation** côté client et serveur
- **Authentification OTP** sécurisée

## 📈 **Roadmap**

### **Phase 1 (Actuelle)**
- ✅ Architecture de base
- ✅ Interface utilisateur principale
- ✅ Système de monétisation
- ✅ Navigation et routing
- 🔄 Tests unitaires
- 🔄 Documentation

### **Phase 2**
- 🔄 Backend API
- 🔄 Base de données Supabase
- 🔄 Authentification OTP
- 🔄 Géolocalisation en temps réel
- 🔄 Notifications push

### **Phase 3**
- 🔄 Intégration poubelle intelligente
- 🔄 Application web admin
- 🔄 Dashboard entreprise
- 🔄 Système de paiement
- 🔄 Analytics et reporting

## 🤝 **Contribution**

### **Comment Contribuer**
1. **Fork** le projet
2. **Créer** une branche pour votre fonctionnalité
3. **Commiter** vos changements
4. **Pousser** vers la branche
5. **Ouvrir** une Pull Request

### **Standards de Code**
- **Nommage** : CamelCase pour les variables, PascalCase pour les classes
- **Documentation** : Commentaires en français
- **Tests** : Couverture minimale de 80%
- **Formatage** : `flutter format` automatique

## 📞 **Support et Contact**

### **Équipe de Développement**
- **Lead Developer** : [Votre Nom]
- **Email** : [votre-email@example.com]
- **GitHub** : [@votre-username]

### **Ressources**
- **Documentation API** : [Lien vers la doc]
- **Issues** : [GitHub Issues]
- **Discussions** : [GitHub Discussions]

## 📄 **Licence**

Ce projet est sous licence **MIT**. Voir le fichier `LICENSE` pour plus de détails.

## 🙏 **Remerciements**

- **Communauté Flutter** pour l'excellent framework
- **Équipe Supabase** pour la base de données
- **Tous les contributeurs** qui participent à ce projet

---

**Batte** - Transformons les déchets en opportunités ! 🌱♻️💰
