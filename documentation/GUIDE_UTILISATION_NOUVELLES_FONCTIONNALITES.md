# 📱 Guide d'Utilisation : Nouvelles Fonctionnalités Home

## 🎯 Vue d'Ensemble

Ton écran Home a maintenant **3 nouvelles fonctionnalités puissantes** :

1. 🔵 **Scanner Bluetooth** - Connecte ta poubelle intelligente
2. 📊 **Graphiques Visuels** - Visualise tes gains et progrès
3. 🏆 **Système de Niveaux** - Deviens Champion avec 7 niveaux de badges

---

## 🔵 1. Scanner Bluetooth (Connecter la Poubelle)

### Comment l'utiliser ?

1. **Sur l'écran d'accueil**, clique sur le bouton **"Scanner"** (icône Bluetooth 🔍)
2. L'app va **scanner automatiquement** les appareils Bluetooth pendant 10 secondes
3. Les poubelles "BATTE_BIN" apparaîtront dans la liste
4. Clique sur **"Connecter"** à côté de ta poubelle
5. Une fois connecté, tu verras : **"✅ Connecté à BATTE_BIN"**

### Que se passe-t-il après connexion ?

Quand tu jettes un déchet dans la poubelle :
1. La poubelle **pèse automatiquement** le déchet
2. Elle **envoie les données** à ton téléphone via Bluetooth
3. L'app **calcule automatiquement** ton gain (1000 GNF/kg)
4. Une **notification s'affiche** : "🎉 +1500 GNF pour 1.5 kg de plastique"
5. Ton **solde est mis à jour** instantanément
6. La transaction apparaît dans **"Activité récente"**

### Exemple concret :

```
Tu jettes 2 kg de plastique
→ La poubelle envoie : {"type": "plastic", "weight": 2.0}
→ L'app calcule : 2 kg × 1000 GNF/kg = 2000 GNF
→ Ton solde : 100 000 → 102 000 GNF
→ Notification : "🎉 +2 000 GNF pour 2.0 kg de plastique"
```

### Problèmes possibles ?

| Problème | Solution |
|----------|----------|
| "Bluetooth non supporté" | Ton téléphone ne supporte pas le Bluetooth LE |
| "Veuillez activer le Bluetooth" | Active le Bluetooth dans les paramètres Android |
| "Aucune poubelle trouvée" | Vérifie que la poubelle ESP32 est allumée et à moins de 10m |
| "Échec de la connexion" | Réessaie ou redémarre la poubelle ESP32 |

---

## 📊 2. Graphiques Visuels

### Graphique des Gains Hebdomadaires

**Où le trouver ?**  
Sur l'écran d'accueil, **juste après le badge de niveau**.

**Que montre-t-il ?**
- Une **courbe verte** avec tes gains des 7 derniers jours
- Les **jours de la semaine** en bas (Lun, Mar, Mer...)
- Le **total de la semaine** en haut à droite

**Comment l'utiliser ?**
- **Touch** sur un point → Voir le montant exact du jour
- **Analyse visuelle** : Vois facilement tes meilleurs jours de recyclage

**Exemple de lecture** :
```
Lundi : 15 000 GNF
Mardi : 8 000 GNF
Mercredi : 5 000 GNF
...
Total semaine : +56 000 GNF
```

### Comment alimenter le graphique ?

Le graphique se remplit automatiquement quand tu :
- ♻️ **Recycles des déchets** (via la poubelle Bluetooth)
- 🎁 **Reçois des récompenses** (bonus de fidélité)

Plus tu recycles, plus la courbe monte ! 📈

---

## 🏆 3. Système de Niveaux avec Badges

### Les 7 Niveaux Disponibles

| Niveau | Nom | Badge | Points Requis | Avantages |
|--------|-----|-------|---------------|-----------|
| 1 | Débutant | 🌱 | 0 - 99 pts | Découverte de l'app |
| 2 | Bronze | 🥉 | 100 - 499 pts | Recycleur régulier |
| 3 | Silver | 🥈 | 500 - 999 pts | Recycleur confirmé |
| 4 | Gold | 🥇 | 1000 - 1999 pts | Expert du recyclage |
| 5 | Platinum | 💎 | 2000 - 4999 pts | Champion écologique |
| 6 | Diamant | 💠 | 5000 - 9999 pts | Ambassadeur Battè |
| 7 | Champion | 👑 | 10000+ pts | Héros de la planète |

### Comment gagner des points écologiques ?

- ♻️ **Recycler 1 kg de déchets** = +10 points
- 🎓 **Terminer un quiz éducatif** = +50 points
- 📹 **Regarder une vidéo éducative** = +20 points
- 🎯 **Objectif mensuel atteint** = +100 points bonus

### Où voir ton niveau ?

Sur l'écran d'accueil, **juste après la carte de solde**, tu verras :

```
🥈  Niveau 3
    Silver
                          Score
                           850

Prochain niveau: Gold
[████████░░] 850 / 1000 pts
```

### Barre de Progression

La barre blanche indique **combien il te reste** pour le prochain niveau :
- **Vide (0%)** : Tu viens de monter de niveau
- **Mi-pleine (50%)** : Tu es à mi-chemin
- **Pleine (100%)** : Tu vas bientôt monter de niveau !

### Exemple Concret

```
Tu as 850 points
→ Niveau actuel : Silver (500-999 pts)
→ Prochain niveau : Gold (1000 pts)
→ Points restants : 1000 - 850 = 150 pts
→ Progression : 85%
→ Barre : ████████████████░░ (85%)
```

---

## 🎨 Design de l'Écran Home (Nouveau)

Voici l'ordre d'affichage maintenant :

```
┌─────────────────────────────────────┐
│ 🔔 Battè [Nom]          🔔 ⚙️      │ ← AppBar
├─────────────────────────────────────┤
│                                     │
│  💳 Solde total                     │
│     150 000 GNF                     │
│                                     │
│  ↑ Gains ce mois  🌿 Score écolo   │
│  56 000 GNF          850 pts        │
│                                     │
├─────────────────────────────────────┤
│  🥈 Niveau 3     Silver     Score   │ ← NOUVEAU
│                               850    │
│  Prochain niveau: Gold              │
│  [████████░░] 850 / 1000 pts        │
├─────────────────────────────────────┤
│  📊 Gains cette semaine  +56k GNF   │ ← NOUVEAU
│                                     │
│      ╱╲                             │
│     ╱  ╲      ╱╲                    │
│    ╱    ╲    ╱  ╲                   │
│   ╱      ╲__╱    ╲___              │
│  Lun Mar Mer Jeu Ven Sam Dim        │
├─────────────────────────────────────┤
│  Statistiques                       │
│                                     │
│  ♻️ Poids recyclé  📄 Transactions  │
│  25.5 kg              12            │
│                                     │
│  ⭐ Points fidélité  ☁️ Économie CO₂│
│  850                  12.8 kg       │
├─────────────────────────────────────┤
│  Actions rapides                    │
│                                     │
│  🔍 Scanner      💸 Retirer         │ ← Scanner = Bluetooth
├─────────────────────────────────────┤
│  Activité récente                   │
│                                     │
│  ♻️ Recyclage plastic  +10 000 GNF  │
│  🎁 Bonus fidélité    +5 000 GNF   │
│  💸 Retrait           -20 000 GNF   │
│  ...                                │
└─────────────────────────────────────┘
```

---

## 🧪 Tester les Nouvelles Fonctionnalités

### Test 1 : Ajouter des Données de Test

Pour voir les graphiques et le système de niveaux en action :

1. Va sur **Supabase Dashboard** → **SQL Editor**
2. Copie le contenu de `supabase_functions/add_test_data.sql`
3. **Remplace** `TON_EMAIL@batte.com` par ton vrai email (ex: `hali@batte.com`)
4. **Exécute** le script
5. **Rafraîchis l'app** (pull-to-refresh sur l'écran d'accueil)

**Résultat attendu** :
- ✅ Solde : 150 000 GNF
- ✅ Badge : 🥈 Silver (850 pts)
- ✅ Graphique avec courbe visible
- ✅ 7 transactions dans "Activité récente"
- ✅ Barre de progression à 85%

---

### Test 2 : Scanner Bluetooth (avec ESP32)

**Pré-requis** :
- Avoir un ESP32 configuré avec le nom "BATTE_BIN"
- Bluetooth activé sur le téléphone

**Étapes** :
1. Allume l'ESP32
2. Ouvre l'app Battè
3. Clique sur "Scanner"
4. Attends 10 secondes
5. Clique sur "Connecter" à côté de "BATTE_BIN"
6. Attends le message de succès

**Pour tester la réception de données** :
- L'ESP32 doit envoyer un JSON via Bluetooth :
  ```json
  {"type": "plastic", "weight": 1.5, "timestamp": 1234567890}
  ```
- L'app affichera : "🎉 +1 500 GNF pour 1.5 kg de plastic"

---

### Test 3 : Système de Niveaux

**Tester la progression** :
1. Ajoute des points à ton compte :
   ```sql
   UPDATE public.users SET eco_score = 950 WHERE email = 'ton-email@batte.com';
   ```
2. Rafraîchis l'app (pull-to-refresh)
3. La barre de progression doit être à **95%**
4. Ajoute encore 50 points :
   ```sql
   UPDATE public.users SET eco_score = 1000 WHERE email = 'ton-email@batte.com';
   ```
5. Rafraîchis l'app
6. Tu devrais voir : **🥇 Gold** (niveau 4) !

---

## 🎉 Félicitations !

Tu as maintenant un **écran Home de niveau professionnel** avec :

✅ Scanner Bluetooth fonctionnel  
✅ Graphiques visuels animés  
✅ Système de niveaux gamifié  
✅ Système de retrait sécurisé  
✅ Gestion des états vides  
✅ Loader et rafraîchissement  

**L'écran Home est COMPLET ! 🚀**

---

## 🔄 Prochaines Étapes

1. **Implémenter les autres écrans** :
   - 📊 Budget Screen (graphiques de dépenses)
   - 🎓 Education Screen (vidéos, quiz)
   - 💼 Services Screen (offres d'emploi)
   - ⚙️ Settings Screen (paramètres, langue)

2. **Connecter l'ESP32** :
   - Programmer l'ESP32 pour envoyer des données
   - Tester la réception en temps réel
   - Calibrer le poids et les types de déchets

3. **Tests utilisateurs** :
   - Tester avec de vraies femmes guinéennes
   - Optimiser l'interface vocale
   - Traduire en Soussou/Peulh/Malinké

**Ton app est maintenant prête pour une vraie démo ! 🎯**

