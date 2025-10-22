import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../services/bluetooth_service.dart' as batte_bluetooth;
import '../../providers/waste_provider.dart';
import '../../widgets/custom_button.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Écran de scan de la poubelle intelligente
class ScanBinScreen extends StatefulWidget {
  const ScanBinScreen({Key? key}) : super(key: key);
  
  @override
  State<ScanBinScreen> createState() => _ScanBinScreenState();
}

class _ScanBinScreenState extends State<ScanBinScreen> {
  final batte_bluetooth.BluetoothService _bluetoothService = batte_bluetooth.BluetoothService();
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _startScan();
    
    // Écouter les données de la poubelle
    _bluetoothService.dataStream.listen((data) {
      _handleBinData(data);
    });
  }
  
  @override
  void dispose() {
    _bluetoothService.dispose();
    super.dispose();
  }
  
  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _error = null;
    });
    
    try {
      final devices = await _bluetoothService.startScan();
      setState(() {
        _devices = devices;
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isScanning = false;
      });
    }
  }
  
  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _isConnecting = true;
      _error = null;
    });
    
    final success = await _bluetoothService.connectToDevice(device);
    
    setState(() {
      _isConnecting = false;
    });
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connecté avec succès'),
          backgroundColor: BatteColors.success,
        ),
      );
    } else {
      setState(() {
        _error = 'Échec de la connexion';
      });
    }
  }
  
  void _handleBinData(Map<String, dynamic> data) {
    // Format attendu : { "type": "plastic", "weight": 1.5 }
    final type = data['type'] as String?;
    final weight = (data['weight'] as num?)?.toDouble();
    
    if (type != null && weight != null) {
      final wasteProvider = Provider.of<WasteProvider>(context, listen: false);
      wasteProvider.addWaste(
        type: type,
        weight: weight,
        binDeviceId: _bluetoothService.isConnected ? 'bin_1' : null,
      );
      
      // Afficher une notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nouveau déchet enregistré : $weight kg de $type'),
            backgroundColor: BatteColors.success,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner ma poubelle'),
        backgroundColor: BatteColors.primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Illustration
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: BatteColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bluetooth_searching,
                        size: 80,
                        color: BatteColors.primary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Recherche de dispositifs...',
                        style: TextStyle(
                          fontSize: 16,
                          color: BatteColors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // État de la connexion
              if (_bluetoothService.isConnected)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BatteColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BatteColors.success),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: BatteColors.success),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Connecté à votre poubelle',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: BatteColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Erreur
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BatteColors.destructive.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BatteColors.destructive),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: BatteColors.destructive),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: BatteColors.destructive,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Liste des dispositifs
              const Text(
                'Dispositifs trouvés',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: _isScanning
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: BatteColors.primary,
                        ),
                      )
                    : _devices.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucun dispositif trouvé',
                              style: TextStyle(
                                color: BatteColors.mutedForeground,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _devices.length,
                            itemBuilder: (context, index) {
                              final device = _devices[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: BatteColors.cardBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.bluetooth,
                                    color: BatteColors.primary,
                                  ),
                                  title: Text(
                                    device.platformName.isNotEmpty
                                        ? device.platformName
                                        : 'Dispositif inconnu',
                                  ),
                                  subtitle: Text(device.remoteId.str),
                                  trailing: _isConnecting
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.arrow_forward_ios),
                                  onTap: () => _connectToDevice(device),
                                ),
                              );
                            },
                          ),
              ),
              
              const SizedBox(height: 16),
              
              // Boutons
              CustomButton(
                text: 'Actualiser',
                onPressed: _startScan,
                isLoading: _isScanning,
                isOutlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

