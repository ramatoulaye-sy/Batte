import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../core/constants/colors.dart';
import '../../services/bluetooth_service.dart' as batte_bt;
import '../../services/supabase_service.dart';
import '../../core/utils/helpers.dart';

/// Écran de scan et connexion Bluetooth à la poubelle intelligente
class BluetoothScanScreen extends StatefulWidget {
  const BluetoothScanScreen({Key? key}) : super(key: key);

  @override
  State<BluetoothScanScreen> createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
  final _bluetoothService = batte_bt.BluetoothService();
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
      _devices.clear();
    });

    try {
      final devices = await _bluetoothService.startScan(
        timeout: const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _devices = devices;
          _isScanning = false;
        });

        if (_devices.isEmpty) {
          setState(() {
            _errorMessage = 'Aucune poubelle trouvée à proximité.\n'
                'Assurez-vous que la poubelle est allumée et à proximité.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      final success = await _bluetoothService.connectToDevice(device);

      if (!mounted) return;

      if (success) {
        // Écouter les données de la poubelle
        _bluetoothService.dataStream.listen((data) {
          _handleWasteData(data);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Connecté à ${device.platformName}'),
            backgroundColor: BatteColors.success,
          ),
        );

        // Retourner à l'écran précédent
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorMessage = 'Échec de la connexion. Veuillez réessayer.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  Future<void> _handleWasteData(Map<String, dynamic> data) async {
    try {
      // Données attendues de l'ESP32:
      // {
      //   "type": "plastic",
      //   "weight": 1.5,
      //   "timestamp": 1234567890
      // }

      final wasteType = data['type'] as String?;
      final weight = (data['weight'] as num?)?.toDouble();

      if (wasteType == null || weight == null) {
        print('❌ Données invalides reçues: $data');
        return;
      }

      // Calculer le montant gagné (exemple: 1000 GNF par kg)
      final amountPerKg = 1000.0;
      final amount = weight * amountPerKg;

      // Créer la transaction de recyclage
      await SupabaseService.createTransaction(
        amount: amount,
        type: 'recycling',
        description: 'Recyclage de $wasteType - ${Helpers.formatWeight(weight)}',
        status: 'completed',
      );

      // Afficher une notification de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎉 +${Helpers.formatCurrency(amount)} pour ${Helpers.formatWeight(weight)} de $wasteType',
            ),
            backgroundColor: BatteColors.success,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur traitement données: $e');
    }
  }

  @override
  void dispose() {
    _bluetoothService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Bluetooth'),
        backgroundColor: BatteColors.primary,
        actions: [
          if (!_isScanning && !_isConnecting)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _startScan,
              tooltip: 'Réactualiser',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // En-tête avec instructions
            Container(
              padding: const EdgeInsets.all(20),
              color: BatteColors.primary.withOpacity(0.1),
              child: Column(
                children: [
                  Icon(
                    Icons.bluetooth_searching,
                    size: 64,
                    color: _isScanning ? BatteColors.primary : BatteColors.mutedForeground,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isScanning
                        ? 'Recherche de poubelles intelligentes...'
                        : 'Poubelles trouvées',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: BatteColors.foreground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Assurez-vous que la poubelle est allumée\net à moins de 10 mètres.',
                    style: TextStyle(
                      fontSize: 14,
                      color: BatteColors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Message d'erreur
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BatteColors.destructive.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BatteColors.destructive),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: BatteColors.destructive,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: BatteColors.destructive,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Liste des appareils trouvés
            Expanded(
              child: _isScanning
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(BatteColors.primary),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Scan en cours...',
                            style: TextStyle(
                              fontSize: 16,
                              color: BatteColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _devices.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bluetooth_disabled,
                                size: 80,
                                color: BatteColors.mutedForeground.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Aucune poubelle trouvée',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: BatteColors.foreground,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Appuyez sur le bouton ↻ pour réessayer',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: BatteColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _devices.length,
                          itemBuilder: (context, index) {
                            final device = _devices[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: BatteColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: BatteColors.primary,
                                    size: 32,
                                  ),
                                ),
                                title: Text(
                                  device.platformName.isNotEmpty
                                      ? device.platformName
                                      : 'Poubelle Battè',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  device.remoteId.str,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: BatteColors.mutedForeground,
                                  ),
                                ),
                                trailing: _isConnecting
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            BatteColors.primary,
                                          ),
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: () => _connectToDevice(device),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: BatteColors.primary,
                                          foregroundColor: BatteColors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('Connecter'),
                                      ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

