# 💼 FAQ TECHNIQUE - QUESTIONS DES INVESTISSEURS

**Document de référence pour répondre aux questions techniques et de sécurité**

---

## 🔒 **QUESTIONS SUR LA SÉCURITÉ**

### **Q1: Comment garantissez-vous la sécurité des données utilisateurs ?**

**RÉPONSE:**
"Nous utilisons plusieurs couches de sécurité :

1. **Chiffrement en Transit** : Toutes les communications utilisent TLS 1.3 avec certificate pinning pour éviter les attaques MITM.

2. **Chiffrement au Repos** : Les données sensibles sont chiffrées avec AES-256 dans notre base locale Hive, et Supabase chiffre automatiquement toutes les données stockées.

3. **Authentification Multi-Factorielle** : JWT tokens avec expiration courte (1h) et refresh tokens rotatifs. Prévision d'un 2FA pour les transactions financières.

4. **Row Level Security (RLS)** : Chaque utilisateur ne peut voir QUE ses propres données. Les politiques RLS dans Supabase garantissent cette isolation au niveau de la base de données.

5. **Conformité RGPD** : Droit à l'oubli, export des données, consentement explicite, et minimisation des données collectées."

---

### **Q2: Comment prévenez-vous les intrusions et piratages ?**

**RÉPONSE:**
"Plusieurs mécanismes de protection :

1. **Firewall et Monitoring** : 
   - WAF (Web Application Firewall) pour bloquer les attaques connues
   - Détection d'anomalies en temps réel
   - Alertes automatiques pour activités suspectes
   - Logs d'audit complets pour traçabilité

2. **Prévention des Attaques** :
   - Protection SQL Injection via requêtes paramétrées
   - Validation XSS côté serveur
   - Tokens anti-CSRF
   - Rate limiting contre brute force
   - Protection DDoS via Cloudflare

3. **Sécurité des Paiements** :
   - Aucune donnée bancaire stockée localement
   - Intégration Stripe/Paystack (PCI-DSS compliant)
   - Tokenisation des paiements
   - 3D Secure activé
   - Validation multi-factor pour retraits

4. **Backup Sécurisé** : 
   - Backup automatique quotidien (3 copies cryptées)
   - Test de restauration mensuel
   - RPO 24h / RTO 4h garantis"

---

### **Q3: Comment sécurisez-vous les transactions financières ?**

**RÉPONSE:**
"Les transactions sont sécurisées à plusieurs niveaux :

1. **Validation Côté Serveur** : Tous les calculs de prix sont effectués côté serveur Supabase pour éviter la manipulation.

2. **Signature Cryptographique** : Chaque transaction est signée cryptographiquement et horodatée.

3. **Double-Entry Accounting** : Système de comptabilité à double entrée pour garantir l'intégrité financière.

4. **Audit Trail** : Historique complet de toutes les transactions avec IP, horodatage, et signature.

5. **Rollback Automatique** : En cas d'erreur, les transactions sont automatiquement annulées pour éviter toute perte.

6. **Seuils de Sécurité** : Alertes automatiques pour transactions suspectes (> seuil configuré)."

---

### **Q4: Comment garantissez-vous qu'un collecteur est légitime ?**

**RÉPONSE:**
"Système de vérification en 5 étapes :

1. **Documents Obligatoires** :
   - Permis de conduire (scanné + vérifié OCR)
   - Licence de collecte (numéro vérifié auprès des autorités)
   - Assurance responsabilité civile (valide)
   - Certificat de bonnes mœurs
   - Attestation de véhicule

2. **Vérification Manuelle** : Tous les documents sont vérifiés manuellement par notre équipe avant activation du compte collecteur.

3. **Système de Notation** :
   - Algorithme anti-manipulation
   - Détection d'abus et notes suspectes
   - Suspension automatique si score < 3/5
   - Modération manuelle en cas de litige

4. **Géolocalisation Active** : Les collecteurs doivent activer la géolocalisation pendant les collectes.

5. **Validité Limitée** : Les licences sont vérifiées annuellement avec alerte de renouvellement."

---

## 🏗️ **QUESTIONS SUR L'ARCHITECTURE**

### **Q5: Quelle est votre stack technologique et pourquoi ?**

**RÉPONSE:**
"Stack moderne et éprouvé :

1. **Flutter (Frontend)** :
   - Développement rapide (1 codebase pour iOS + Android)
   - Performance native
   - Large communauté
   - Support Google

2. **Supabase (Backend)** :
   - PostgreSQL open-source (fiabilité)
   - Authentification intégrée
   - Real-time subscriptions
   - Row Level Security native
   - Hébergé en Europe (RGPD)

3. **Firebase (Notifications)** :
   - Push notifications cross-platform
   - Analytics intégré
   - Crashlytics

4. **Hive (Local)** :
   - Base de données locale ultra-rapide
   - Support offline complet
   - Chiffrement AES-256 intégré

**Pourquoi cette stack ?**
- **Fiabilité** : Technologies éprouvées en production
- **Performance** : Optimisé pour mobile
- **Sécurité** : Conformité RGPD native
- **Coût** : Pricing transparent et prévisible"

---

### **Q6: Comment gérer la montée en charge ?**

**RÉPONSE:**
"Architecture scalable dès le départ :

1. **Capacité Actuelle** :
   - 10,000 utilisateurs simultanés
   - 100,000 transactions/jour
   - Temps de réponse < 200ms

2. **Scalabilité Horizontale** :
   - Auto-scaling selon la charge
   - Load balancing automatique
   - Cache Redis pour performance
   - CDN global pour assets

3. **Optimisations** :
   - Pagination de toutes les listes
   - Lazy loading des images
   - Cache local intelligent
   - Compression des données

4. **Roadmap** :
   - Database sharding à 1M utilisateurs
   - Microservices si nécessaire
   - Kubernetes pour orchestration

Notre infrastructure peut supporter 10x la croissance avec coûts linéaires."

---

### **Q7: Comment fonctionne le mode offline-first ?**

**RÉPONSE:**
"L'application fonctionne 100% offline grâce à :

1. **Stockage Local Hive** :
   - Toutes les données sont mises en cache localement
   - Synchronisation en arrière-plan quand connexion disponible
   - Conflict resolution automatique

2. **Système d'Outbox** :
   - Toutes les actions offline sont stockées dans une 'outbox'
   - Synchronisation automatique dès reconnexion
   - Ordre des transactions préservé

3. **Tolérance au Délai** :
   - Les utilisateurs peuvent utiliser l'app sans internet
   - Les données sont synchronisées en arrière-plan
   - Pas de perte de données

4. **Gestion des Conflits** :
   - Algorithme "last-write-wins" avec notification
   - Historique complet des modifications
   - Possibilité de restaurer manuellement"

---

## 💰 **QUESTIONS SUR LE BUSINESS MODEL**

### **Q8: Quel est votre modèle économique ?**

**RÉPONSE:**
"5 sources de revenus :

1. **Commission de Transaction (5%)** :
   - Prélèvement transparent
   - Visible par l'utilisateur
   - Prix du déchet négocié avec le collecteur

2. **Abonnements Collecteurs (GNF 50,000/mois)** :
   - Accès à la plateforme
   - Analytics détaillées
   - Support prioritaire
   - Badges de certification

3. **Partenariats Publicitaires** :
   - Publicité ciblée entreprises vertes
   - Bannières non-intrusives
   - Sponsored content

4. **Données Anonymisées** :
   - Analytics écologiques (Big Data)
   - Rapports environnementaux
   - Études de marché

5. **API Premium** :
   - Accès développeurs tiers
   - Intégrations entreprises
   - White-label disponible

**Projections** : 2.5M GNF/mois (Année 1) → 25M GNF/mois (Année 3)"

---

### **Q9: Quelle est votre stratégie de croissance ?**

**RÉPONSE:**
"3 phases de croissance :

**Phase 1 (Q1 2025) - Pilotage** :
- Lancement Conakry
- 10,000 utilisateurs pilotes
- 3 zones de collecte
- Partenariat 50 poubelles IoT

**Phase 2 (Q2 2025) - Expansion** :
- Extension vers 5 grandes villes
- 50,000 utilisateurs
- Support iOS
- Marketplace écologique

**Phase 3 (Q3 2025) - National** :
- Couverture nationale
- 200,000 utilisateurs
- Intelligence Artificielle
- Programme de fidélité

**Stratégies** :
- Marketing viral (récompenses parrainage)
- Partenariats écoles/universités
- Influenceurs environnementaux
- Incitations financières"

---

## 🔧 **QUESTIONS TECHNIQUES**

### **Q10: Comment garantissez-vous la qualité du code ?**

**RÉPONSE:**
"Standards de qualité élevés :

1. **Tests Automatisés** :
   - Couverture de tests : 85%
   - Tests unitaires
   - Tests d'intégration
   - Tests E2E

2. **Code Review** :
   - Peer review obligatoire
   - Standards de codage strictes
   - Documentation complète

3. **CI/CD** :
   - Automatisation builds
   - Tests avant déploiement
   - Détection de bugs automatique

4. **Monitoring** :
   - Crashlytics intégré
   - Performance monitoring
   - Alertes automatiques

5. **Documentation** :
   - README complet
   - Code commenté
   - Architecture détaillée"

---

### **Q11: Comment gérez-vous la conformité RGPD ?**

**RÉPONSE:**
"Conformité totale RGPD :

1. **Consentement Explicite** :
   - Double opt-in pour inscription
   - Consentement pour chaque donnée
   - Possibilité de retirer

2. **Droits Utilisateurs** :
   - Droit à l'oubli (suppression complète)
   - Export des données (JSON)
   - Portabilité des données
   - Rectification des données

3. **Minimisation** :
   - Collecte minimale nécessaire
   - Pas de données superflues
   - Anonymisation automatique

4. **Notification de Brèches** :
   - Détection automatique
   - Notification 72h si brèche
   - Plan de communication

5. **DPO Désigné** : Contact dédié pour protection des données"

---

### **Q12: Quelle est votre politique de backup et récupération ?**

**RÉPONSE:**
"Backup complet et automatisé :

1. **Backup Automatique** :
   - Quotidien (3 copies cryptées)
   - Stockage géo-répliqué
   - Rétention 90 jours

2. **Test de Restauration** :
   - Mensuel
   - Documenté
   - Amélioration continue

3. **Capacités de Récupération** :
   - RPO (Recovery Point Objective) : 24h
   - RTO (Recovery Time Objective) : 4h
   - Disaster Recovery Plan documenté

4. **Sécurité** :
   - Chiffrement AES-256
   - Accès restreint
   - Audit des accès"

---

## 📊 **QUESTIONS SUR LES MÉTRIQUES**

### **Q13: Quelles sont vos métriques de performance ?**

**RÉPONSE:**
"Métriques KPI principales :

**Performance Technique** :
- Temps de lancement : < 5 secondes
- Temps de réponse API : < 200ms
- Uptime : 99.9% garanti
- Crash rate : < 0.1%

**Performance Business** :
- Taux d'activation : 85%
- Taux de rétention : 70%
- Temps moyen par session : 8 min
- Transactions réussies : 98%

**Sécurité** :
- Tentatives d'intrusion bloquées : 100%
- Données chiffrées : 100%
- Conformité RGPD : 100%"

---

### **Q14: Comment mesurez-vous le succès de l'application ?**

**RÉPONSE:**
"KPIs de succès mesurables :

1. **Adoption** :
   - Nombre d'utilisateurs actifs
   - Taux de croissance mensuel
   - Taux de rétention

2. **Engagement** :
   - Sessions par utilisateur
   - Transactions par utilisateur
   - Temps passé dans l'app

3. **Impact Environnemental** :
   - Tonnes de déchets recyclés
   - Réduction CO2
   - Détournement décharge

4. **Finance** :
   - Revenus mensuels
   - Croissance MRR
   - Lifetime Value (LTV)

5. **Satisfaction** :
   - NPS (Net Promoter Score)
   - Taux de churn
   - Reviews étoiles"

---

## 🎯 **QUESTIONS STRATÉGIQUES**

### **Q15: Comment vous différenciez-vous de la concurrence ?**

**RÉPONSE:**
"4 avantages compétitifs uniques :

1. **IoT Intégré** :
   - Seule app avec poubelles connectées Bluetooth
   - Pesée automatique
   - Données précises en temps réel

2. **Rémunération Transparente** :
   - Prix fixe par type de déchet
   - Calcul instantané
   - Paiement rapide

3. **Gamification Avancée** :
   - Système de points et badges
   - Défis quotidiens
   - Leaderboard

4. **Communauté Active** :
   - Services entre utilisateurs
   - Education environnementale
   - Marketplace écologique

**Barrière à l'entrée** : Rôle de plateforme avec effet de réseau"

---

### **Q16: Quels sont vos risques principaux ?**

**RÉPONSE:**
"Risques identifiés et mitigés :

1. **Concurrence** :
   - Mitigation : First mover advantage, effet de réseau
   
2. **Technologie** :
   - Mitigation : Stack moderne, scalabilité

3. **Réglementaire** :
   - Mitigation : Conformité RGPD, partenariat autorités

4. **Opérationnel** :
   - Mitigation : Backup complet, monitoring

5. **Finance** :
   - Mitigation : Multiple sources de revenus

**Plan d'urgence documenté pour chaque risque.**"

---

## 📞 **CONCLUSION**

Ces réponses vous permettront de démontrer votre expertise technique et votre vision stratégique lors de la présentation. N'hésitez pas à personnaliser selon votre contexte.

**Bon courage pour votre présentation ! 🚀**
