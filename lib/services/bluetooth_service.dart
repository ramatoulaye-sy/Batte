import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../core/constants/app_constants.dart';
import 'storage_service.dart';

/// Service Bluetooth pour la communication avec la poubelle intelligente
class BluetoothService {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _dataCharacteristic;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  
  final _dataStreamController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;
  
  bool get isConnected => _connectedDevice != null;
  
  /// Démarre le scan Bluetooth pour trouver la poubelle
  Future<List<BluetoothDevice>> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    final devices = <BluetoothDevice>[];
    
    // Vérifier si le Bluetooth est disponible
    if (await FlutterBluePlus.isSupported == false) {
      throw Exception('Bluetooth non supporté sur cet appareil');
    }
    
    // Vérifier si le Bluetooth est activé
    final state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      throw Exception('Veuillez activer le Bluetooth');
    }
    
    // Démarrer le scan
    await FlutterBluePlus.startScan(timeout: timeout);
    
    // Écouter les résultats du scan
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        // Filtrer par nom du dispositif (BATTE_BIN)
        if (result.device.platformName.contains('BATTE') ||
            result.device.platformName.contains('BIN')) {
          if (!devices.contains(result.device)) {
            devices.add(result.device);
          }
        }
      }
    });
    
    // Attendre la fin du scan
    await Future.delayed(timeout);
    await FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    
    return devices;
  }
  
  /// Arrête le scan Bluetooth
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
  }
  
  /// Se connecte à un dispositif Bluetooth
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      // Se connecter au dispositif
      await device.connect(timeout: const Duration(seconds: 15));
      _connectedDevice = device;
      
      // Sauvegarder l'ID du dispositif
      await StorageService.saveBinDeviceId(device.remoteId.str);
      
      // Découvrir les services
      await _discoverServices();
      
      // Écouter les déconnexions
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnection();
        }
      });
      
      return true;
    } catch (e) {
      print('Erreur de connexion: $e');
      return false;
    }
  }
  
  /// Découvre les services et caractéristiques
  Future<void> _discoverServices() async {
    if (_connectedDevice == null) return;
    
    final services = await _connectedDevice!.discoverServices();
    
    // Chercher le service et la caractéristique de données
    for (var service in services) {
      if (service.uuid.toString().contains(AppConstants.binServiceUuid)) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString().contains(AppConstants.binCharacteristicUuid)) {
            _dataCharacteristic = characteristic;
            
            // S'abonner aux notifications
            if (characteristic.properties.notify) {
              await characteristic.setNotifyValue(true);
              characteristic.lastValueStream.listen(_handleIncomingData);
            }
            
            break;
          }
        }
      }
    }
  }
  
  /// Gère les données entrantes
  void _handleIncomingData(List<int> data) {
    try {
      final jsonString = utf8.decode(data);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      
      // Émettre les données dans le stream
      _dataStreamController.add(jsonData);
    } catch (e) {
      print('Erreur de parsing des données: $e');
    }
  }
  
  /// Envoie des données à la poubelle
  Future<bool> sendData(Map<String, dynamic> data) async {
    if (_dataCharacteristic == null) return false;
    
    try {
      final jsonString = json.encode(data);
      final bytes = utf8.encode(jsonString);
      
      await _dataCharacteristic!.write(bytes);
      return true;
    } catch (e) {
      print('Erreur d\'envoi des données: $e');
      return false;
    }
  }
  
  /// Se déconnecte du dispositif
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _handleDisconnection();
    }
  }
  
  /// Gère la déconnexion
  void _handleDisconnection() {
    _connectedDevice = null;
    _dataCharacteristic = null;
    _connectionSubscription?.cancel();
  }
  
  /// Nettoie les ressources
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _dataStreamController.close();
    disconnect();
  }
}

