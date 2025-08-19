import 'package:flutter/material.dart';
import 'package:batte/core/app_theme.dart';
import 'package:batte/services/mock_auth_service.dart';
import 'package:batte/services/supabase_service.dart';
import 'package:batte/services/location_service.dart';
// import 'package:batte/services/auth_service.dart';

class MonetizationPage extends StatefulWidget {
  const MonetizationPage({super.key});

  @override
  State<MonetizationPage> createState() => _MonetizationPageState();
}

class _MonetizationPageState extends State<MonetizationPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _mockAuthService = MockAuthService();
  final SupabaseService _supabase = SupabaseService.instance;
  // final AuthService _auth = AuthService.instance; // réservé pour étapes suivantes
  
  String _selectedWasteType = 'plastic';
  double _currentWeight = 0.0;
  double _currentValue = 0.0;
  bool _canSell = false;
  bool _isLoading = false;

  // Types de déchets (chargés depuis Supabase)
  List<Map<String, dynamic>> _wasteTypes = [];
  // Transactions réelles
  List<Map<String, dynamic>> _transactions = [];
  bool _isHistoryLoading = false;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _weightController.addListener(_calculateValue);
    _loadWasteTypes();
    _loadTransactions();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final userStats = _mockAuthService.getUserStats();
    setState(() {
      _currentWeight = userStats['monthlyWaste'] ?? 0.0;
      _canSell = _currentWeight >= 1.0;
    });
  }

  Future<void> _loadWasteTypes() async {
    setState(() => _isLoading = true);
    try {
      final types = await _supabase.getWasteTypes();
      if (types.isNotEmpty) {
        _wasteTypes = types;
        _selectedWasteType = types.first['id'] as String;
        _calculateValue();
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isHistoryLoading = true;
      _historyError = null;
    });
    try {
      final uid = _supabase.currentUserId;
      if (uid == null) throw Exception('Utilisateur non connecté');
      final data = await _supabase.getRecentUserTransactions(uid, limit: 15);
      if (!mounted) return;
      setState(() {
        _transactions = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _historyError = '$e';
      });
    } finally {
      if (mounted) setState(() => _isHistoryLoading = false);
    }
  }

  void _calculateValue() {
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    double price = 0.0;
    if (_wasteTypes.isNotEmpty) {
      final found = _wasteTypes.firstWhere(
        (t) => (t['id'] as String) == _selectedWasteType,
        orElse: () => <String, dynamic>{},
      );
      if (found.isNotEmpty) {
        final p = found['price_per_kg'];
        price = p is num ? p.toDouble() : double.tryParse('$p') ?? 0.0;
      }
    }
    
    setState(() {
      _currentWeight = weight;
      _currentValue = weight * price;
      _canSell = weight >= 1.0;
    });
  }

  void _onWasteTypeChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedWasteType = value;
        _calculateValue();
      });
    }
  }

  void _scanQRCode() {
    // Simulation du scan QR
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Simuler des données de la poubelle
          _selectedWasteType = 'plastic';
          _weightController.text = '2.5';
          _calculateValue();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Données importées depuis la poubelle !'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    });
  }

  void _connectBluetooth() {
    // Simulation de la connexion Bluetooth
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Simuler des données Bluetooth
          _selectedWasteType = 'organic';
          _weightController.text = '1.8';
          _calculateValue();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Connexion Bluetooth établie !'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    });
  }

  Future<void> _sellWaste() async {
    if (!_canSell) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.sell,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Confirmer la vente'),
          ],
        ),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Résumé de votre vente :',
                  style: TextStyle(
                    color: AppTheme.onBackgroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow('Type', (() {
                  final found = _wasteTypes.firstWhere(
                    (t) => (t['id'] as String) == _selectedWasteType,
                    orElse: () => {'name': 'Déchet'},
                  );
                  return (found['name'] as String);
                })()),
                _buildSummaryRow('Poids', '$_currentWeight kg'),
                _buildSummaryRow('Valeur', '${_currentValue.toStringAsFixed(0)} GNF'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.successColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.successColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Vous serez redirigé vers la carte pour sélectionner un collecteur',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: AppTheme.onBackgroundColor.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              
              // Store context reference before async operations
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              try {
                final userId = _supabase.currentUserId;
                if (userId == null) throw Exception('Utilisateur non connecté');
                final amount = _currentValue;
                final txId = await _supabase.createWasteTransaction({
                  'user_id': userId,
                  'waste_type_id': _selectedWasteType,
                  'weight_kg': _currentWeight,
                  'amount_gnf': amount,
                  'points_earned': _currentWeight.floor(),
                  'status': 'pending',
                });
                
                if (!mounted) return;
                
                if (txId != null) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Transaction créée (#$txId). Sélectionnez un collecteur sur la carte.'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                  await _loadTransactions();
                  if (mounted) {
                    await _selectCollector(txId);
                  }
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: const Text('Échec de la création de la transaction'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.onPrimaryColor,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectCollector(String transactionId) async {
    final locationService = LocationService.instance;
    final pos = await locationService.getLocation();
    if (pos == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Impossible d\'obtenir votre position'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final collectors = await locationService.getCollectorsInRadius(pos.latitude, pos.longitude, 10);
    if (!mounted) return;

    if (collectors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Aucun collecteur disponible à proximité'),
          backgroundColor: AppTheme.infoColor,
        ),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.group, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'Sélectionner un collecteur',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: collectors.length,
                  itemBuilder: (context, index) {
                    final c = collectors[index];
                    final user = c['users'] ?? {};
                    final fullName = (user['full_name'] ?? user['name'] ?? 'Collecteur');
                    final distanceKm = (c['distance_km'] ?? 0.0) as double;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          child: const Icon(Icons.person),
                        ),
                        title: Text('$fullName'),
                        subtitle: Text('${distanceKm.toStringAsFixed(1)} km'),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            
                            // Store context reference before async operations
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            
                            final ok = await _supabase.assignCollectorToTransaction(transactionId, c['id'].toString());
                            if (!mounted) return;
                            
                            if (ok) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: const Text('Collecteur assigné. En attente de collecte...'),
                                  backgroundColor: AppTheme.successColor,
                                ),
                              );
                              await _loadTransactions();
                            } else {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: const Text('Échec de l\'assignation du collecteur'),
                                  backgroundColor: AppTheme.errorColor,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: AppTheme.onPrimaryColor,
                          ),
                          child: const Text('Choisir'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.onBackgroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Monétisation',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.history,
              color: AppTheme.primaryColor,
            ),
            onPressed: () {
              // Afficher l'historique complet
              _showFullHistory();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Convertisseur KG→GNF
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.currency_exchange,
                            color: AppTheme.primaryColor,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Convertisseur KG → GNF',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Sélection du type de déchet
                      DropdownButtonFormField<String>(
                        value: _wasteTypes.isEmpty ? null : _selectedWasteType,
                        decoration: InputDecoration(
                          labelText: 'Type de déchet',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _wasteTypes.map((t) {
                          return DropdownMenuItem<String>(
                            value: t['id'] as String,
                            child: Text(t['name'] as String),
                          );
                        }).toList(),
                        onChanged: _onWasteTypeChanged,
                      ),
                      const SizedBox(height: 16),

                      // Champ de poids
                      TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Poids (kg)',
                          prefixIcon: const Icon(Icons.scale),
                          suffixText: 'kg',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le poids';
                          }
                          final weight = double.tryParse(value);
                          if (weight == null || weight <= 0) {
                            return 'Poids invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Résultat de la conversion
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Valeur estimée :',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${_currentValue.toStringAsFixed(0)} GNF',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Boutons d'import
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _scanQRCode,
                              icon: const Icon(Icons.qr_code_scanner),
                              label: const Text('Scanner QR'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: BorderSide(color: AppTheme.primaryColor),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _connectBluetooth,
                              icon: const Icon(Icons.bluetooth),
                              label: const Text('Bluetooth'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: BorderSide(color: AppTheme.primaryColor),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Bouton Vendre
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _canSell ? _sellWaste : null,
                          icon: const Icon(Icons.sell),
                          label: Text(
                            _canSell ? 'VENDRE (${_currentWeight.toStringAsFixed(1)} kg)' : 'Minimum 1 kg requis',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canSell ? AppTheme.successColor : AppTheme.disabledColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: _canSell ? 4 : 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Historique des ventes
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: AppTheme.primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Historique des Ventes',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_isHistoryLoading)
                      const Center(child: CircularProgressIndicator()),
                    if (_historyError != null)
                      Text(
                        _historyError!,
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                    if (!_isHistoryLoading && _historyError == null && _transactions.isEmpty)
                      Text(
                        'Aucune transaction pour le moment',
                        style: TextStyle(color: AppTheme.onBackgroundColor.withValues(alpha: 0.7)),
                      ),

                    // Liste des ventes récentes (réelles)
                    ..._transactions.take(3).map((tx) => _buildTransactionItem(tx)),
                    
                    if (_transactions.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Center(
                          child: TextButton(
                            onPressed: _showFullHistory,
                            child: Text(
                              'Voir tout l\'historique (${_transactions.length} ventes)',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    String name = (tx['waste_types'] != null ? (tx['waste_types']['name'] ?? 'Déchet') : 'Déchet').toString();
    final status = (tx['status'] ?? 'pending').toString();
    final weight = (tx['weight_kg'] ?? 0).toString();
    final amount = (tx['amount_gnf'] ?? 0).toString();

    // Couleurs/icônes selon le type
    final lower = name.toLowerCase();
    Color color;
    IconData icon;
    if (lower.contains('plast')) { color = AppTheme.wastePlasticColor; icon = Icons.local_drink; }
    else if (lower.contains('organ')) { color = AppTheme.wasteOrganicColor; icon = Icons.eco; }
    else if (lower.contains('verre') || lower.contains('glass')) { color = AppTheme.wasteGlassColor; icon = Icons.wine_bar; }
    else if (lower.contains('métal') || lower.contains('metal')) { color = AppTheme.wasteMetalColor; icon = Icons.hardware; }
    else if (lower.contains('papier') || lower.contains('paper')) { color = AppTheme.wastePaperColor; icon = Icons.description; }
    else { color = AppTheme.primaryColor; icon = Icons.recycling; }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildStatusChip(status),
                  ],
                ),
                Text(
                  '$weight kg • $amount GNF',
                  style: TextStyle(
                    color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildTxAction(tx),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color c;
    switch (status) {
      case 'completed': c = AppTheme.successColor; break;
      case 'assigned': c = AppTheme.accentColor; break;
      case 'cancelled': c = AppTheme.errorColor; break;
      default: c = AppTheme.warningColor; // pending
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTxAction(Map<String, dynamic> tx) {
    final status = (tx['status'] ?? 'pending').toString();
    final txId = tx['id'].toString();

    if (status == 'pending') {
      return TextButton(
        onPressed: () => _selectCollector(txId),
        child: const Text('Assigner'),
      );
    } else if (status == 'assigned') {
      return TextButton(
        onPressed: () async {
          // Store context reference before async operations
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          
          final ok = await _supabase.updateTransactionStatus(txId, 'completed');
          if (!mounted) return;
          
          if (ok) {
            await _loadTransactions();
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: const Text('Transaction marquée terminée'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            }
          }
        },
        child: const Text('Terminer'),
      );
    } else {
      return const Icon(Icons.check_circle, color: Colors.green, size: 24);
    }
  }

  void _showFullHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Historique Complet des Ventes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isHistoryLoading
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                    top: false,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        return _buildTransactionItem(_transactions[index]);
                      },
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
