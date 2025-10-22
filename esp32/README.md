# ESP32 - Poubelle Intelligente Battè

## Description

Script MicroPython pour l'ESP32 qui simule une poubelle intelligente connectée. Le système détecte les déchets déposés, mesure leur poids, identifie leur type et envoie les données via Bluetooth à l'application mobile.

## Matériel requis

- **ESP32** (Dev Kit V1 ou similaire)
- **Capteur de poids HX711** + cellule de charge
- **Capteur ultrason HC-SR04** (niveau de remplissage)
- **Module GSM SIM800L** (optionnel, pour connexion réseau)
- **LED RGB** (indicateur d'état)
- **Alimentation 5V**

## Installation

### 1. Installer MicroPython sur ESP32

```bash
# Télécharger le firmware MicroPython
wget https://micropython.org/resources/firmware/esp32-20230426-v1.20.0.bin

# Effacer le flash de l'ESP32
esptool.py --chip esp32 --port /dev/ttyUSB0 erase_flash

# Flash le firmware
esptool.py --chip esp32 --port /dev/ttyUSB0 write_flash -z 0x1000 esp32-20230426-v1.20.0.bin
```

### 2. Installer les dépendances

Les bibliothèques suivantes sont incluses dans MicroPython :
- `bluetooth` - Communication Bluetooth Low Energy
- `machine` - Contrôle des GPIO et capteurs
- `json` - Sérialisation des données
- `time` - Gestion du temps

### 3. Téléverser le script

```bash
# Utiliser ampy pour téléverser
pip install adafruit-ampy

# Téléverser le script principal
ampy --port /dev/ttyUSB0 put main.py

# Redémarrer l'ESP32
```

## Configuration matérielle

### Connexions

```
ESP32          →  Capteur
----------------------------
GPIO 18        →  HX711 DT (Data)
GPIO 19        →  HX711 SCK (Clock)
GPIO 5         →  HC-SR04 Trigger
GPIO 4         →  HC-SR04 Echo
GPIO 2         →  LED indicateur
```

## Utilisation

### Mode Test (Simulation)

Le script actuel fonctionne en mode simulation sans capteurs réels :

```python
# Exécuter le script
python main.py
```

Le système va :
1. Démarrer l'annonce Bluetooth avec le nom "BATTE_BIN_001"
2. Simuler des dépôts de déchets toutes les 10-30 secondes
3. Générer des poids et types aléatoires
4. Envoyer les données en JSON via Bluetooth

### Mode Production (Capteurs réels)

Pour utiliser avec de vrais capteurs, modifier les fonctions :

```python
def read_weight(self):
    # Implémenter la lecture HX711
    from hx711 import HX711
    hx = HX711(18, 19)  # DT, SCK
    weight = hx.read() / 1000  # Convertir en kg
    return weight

def detect_waste_type(self):
    # Implémenter la détection (caméra, capteur, etc.)
    # Pour l'instant, demander à l'utilisateur via boutons
    pass
```

## Format des données

Les données envoyées via Bluetooth sont au format JSON :

```json
{
  "type": "plastic",
  "weight": 1.25,
  "timestamp": 1699876543,
  "device_id": "BATTE_BIN_001"
}
```

### Types de déchets supportés

- `plastic` - Plastique (1500 GNF/kg)
- `paper` - Papier (800 GNF/kg)
- `metal` - Métal (2000 GNF/kg)
- `glass` - Verre (500 GNF/kg)
- `organic` - Organique (300 GNF/kg)

## Test de connexion

Pour tester la connexion avec l'application Flutter :

1. Démarrer le script ESP32
2. Ouvrir l'application Battè sur votre téléphone
3. Aller dans "Recyclage" → "Scanner ma poubelle"
4. L'appareil "BATTE_BIN_001" devrait apparaître
5. Se connecter et observer les données reçues

## Dépannage

### L'ESP32 ne se connecte pas

- Vérifier que le Bluetooth est activé sur le téléphone
- S'assurer que l'ESP32 est bien alimenté (LED allumée)
- Redémarrer l'ESP32 et l'application

### Les données ne sont pas reçues

- Vérifier les UUIDs de service et caractéristique
- S'assurer que la connexion est établie (LED clignote)
- Consulter les logs du téléphone

### Erreur de capteur

- Vérifier les connexions GPIO
- Tester chaque capteur individuellement
- Calibrer le capteur de poids

## Améliora tions futures

- [ ] Ajout d'un écran LCD pour affichage local
- [ ] Détection automatique du type de déchet (caméra + IA)
- [ ] Connexion WiFi/GSM pour synchronisation directe
- [ ] Batterie rechargeable + panneau solaire
- [ ] Mode hors-ligne avec stockage local

## Support

Pour toute question ou problème :
- Email: support@batte.gn
- GitHub Issues: [lien vers repo]

## Licence

MIT License - Battè Team © 2024

