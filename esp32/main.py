# Script MicroPython pour ESP32 - Poubelle Intelligente Battè
# Simule l'envoi de données de poids et type de déchet via Bluetooth

import bluetooth
import time
import json
from machine import Pin, ADC
import random

# Configuration
BLE_NAME = "BATTE_BIN_001"
SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
CHAR_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8"

# Types de déchets
WASTE_TYPES = ['plastic', 'paper', 'metal', 'glass', 'organic']

class BatteBin:
    def __init__(self):
        self.ble = bluetooth.BLE()
        self.ble.active(True)
        self.connected = False
        
        # Simuler un capteur de poids (HX711)
        # En production, utiliser le vrai capteur
        self.weight_sensor = None
        
        # LED indicateur
        self.led = Pin(2, Pin.OUT)
        
        print("🚮 Poubelle Battè initialisée")
    
    def start_advertising(self):
        """Démarre l'annonce Bluetooth"""
        print(f"📡 Démarrage de l'annonce Bluetooth: {BLE_NAME}")
        
        # Configuration de l'annonce BLE
        self.ble.gap_advertise(
            100000,  # Intervalle en microsecondes
            adv_data=self._encode_name(BLE_NAME)
        )
        
        # Faire clignoter la LED pour indiquer qu'on est en attente
        self.blink_led(3)
    
    def _encode_name(self, name):
        """Encode le nom pour l'annonce BLE"""
        payload = bytearray()
        payload.append(len(name) + 1)
        payload.append(0x09)  # Type: nom complet
        payload.extend(name.encode())
        return bytes(payload)
    
    def read_weight(self):
        """Lit le poids depuis le capteur (simulé)"""
        # En production, lire depuis HX711
        # Pour le test, générer un poids aléatoire entre 0.1 et 5 kg
        weight = round(random.uniform(0.1, 5.0), 2)
        return weight
    
    def detect_waste_type(self):
        """Détecte le type de déchet (simulé)"""
        # En production, utiliser un capteur (caméra, capteur de matériaux, etc.)
        # Pour le test, choisir aléatoirement
        waste_type = random.choice(WASTE_TYPES)
        return waste_type
    
    def send_data(self, weight, waste_type):
        """Envoie les données via Bluetooth"""
        data = {
            "type": waste_type,
            "weight": weight,
            "timestamp": time.time(),
            "device_id": "BATTE_BIN_001"
        }
        
        json_data = json.dumps(data)
        print(f"📤 Envoi des données: {json_data}")
        
        # En production, envoyer via la caractéristique BLE
        # self.ble.gatts_write(char_handle, json_data.encode())
        
        # Faire clignoter la LED pour confirmer l'envoi
        self.blink_led(2)
        
        return data
    
    def blink_led(self, times):
        """Fait clignoter la LED"""
        for _ in range(times):
            self.led.on()
            time.sleep(0.2)
            self.led.off()
            time.sleep(0.2)
    
    def simulate_waste_deposit(self):
        """Simule le dépôt d'un déchet"""
        print("\n🚮 Nouveau déchet détecté!")
        
        # Attendre un peu (simuler le temps de dépôt)
        time.sleep(1)
        
        # Lire le poids
        weight = self.read_weight()
        print(f"⚖️  Poids: {weight} kg")
        
        # Détecter le type
        waste_type = self.detect_waste_type()
        print(f"🔍 Type: {waste_type}")
        
        # Envoyer les données
        data = self.send_data(weight, waste_type)
        
        return data

def main():
    """Fonction principale"""
    print("=" * 50)
    print("🌍 Battè - Poubelle Intelligente")
    print("🇬🇳 Guinée - Conakry")
    print("=" * 50)
    
    # Initialiser la poubelle
    bin = BatteBin()
    
    # Démarrer l'annonce Bluetooth
    bin.start_advertising()
    
    print("\n✅ Système prêt!")
    print("💡 La poubelle attend les dépôts de déchets...")
    print("\n(Appuyez sur Ctrl+C pour arrêter)\n")
    
    # Boucle principale
    try:
        while True:
            # Simuler un dépôt de déchet toutes les 10-30 secondes
            wait_time = random.randint(10, 30)
            print(f"⏳ Attente de {wait_time} secondes...")
            time.sleep(wait_time)
            
            # Simuler un dépôt
            bin.simulate_waste_deposit()
            
    except KeyboardInterrupt:
        print("\n\n🛑 Arrêt du système")
        bin.led.off()

# Point d'entrée
if __name__ == "__main__":
    main()

