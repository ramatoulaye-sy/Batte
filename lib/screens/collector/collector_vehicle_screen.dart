import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/helpers.dart';

/// Écran de gestion du véhicule pour les collecteurs
class CollectorVehicleScreen extends StatefulWidget {
  const CollectorVehicleScreen({super.key});

  @override
  State<CollectorVehicleScreen> createState() => _CollectorVehicleScreenState();
}

class _CollectorVehicleScreenState extends State<CollectorVehicleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = true;
  bool _isEditing = false;
  Map<String, dynamic> _vehicleData = {};
  
  final _formKey = GlobalKey<FormState>();
  final _vehicleTypeController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _capacityController = TextEditingController();
  final _yearController = TextEditingController();
  final _insuranceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
    
    _loadVehicleData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _vehicleTypeController.dispose();
    _licensePlateController.dispose();
    _capacityController.dispose();
    _yearController.dispose();
    _insuranceController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicleData() async {
    setState(() => _isLoading = true);

    try {
      // Simuler le chargement des données du véhicule
      await Future.delayed(const Duration(seconds: 1));
      
      final mockData = {
        'vehicleType': 'Camionnette',
        'licensePlate': 'GN-1234-AB',
        'capacity': '2.5',
        'year': '2020',
        'insuranceNumber': 'ASS-2024-001',
        'insuranceExpiry': DateTime.now().add(const Duration(days: 90)),
        'lastMaintenance': DateTime.now().subtract(const Duration(days: 30)),
        'nextMaintenance': DateTime.now().add(const Duration(days: 30)),
        'mileage': 45000,
        'fuelType': 'Diesel',
        'status': 'En service',
        'photos': [
          'https://example.com/vehicle1.jpg',
          'https://example.com/vehicle2.jpg',
        ],
        'documents': [
          {'name': 'Carte grise', 'status': 'Validée', 'expiry': null},
          {'name': 'Assurance', 'status': 'Valide', 'expiry': DateTime.now().add(const Duration(days: 90))},
          {'name': 'Contrôle technique', 'status': 'Valide', 'expiry': DateTime.now().add(const Duration(days: 180))},
        ],
      };

      if (mounted) {
        setState(() {
          _vehicleData = mockData;
          _isLoading = false;
        });
        
        // Remplir les contrôleurs
        _vehicleTypeController.text = mockData['vehicleType']?.toString() ?? '';
        _licensePlateController.text = mockData['licensePlate']?.toString() ?? '';
        _capacityController.text = mockData['capacity']?.toString() ?? '';
        _yearController.text = mockData['year']?.toString() ?? '';
        _insuranceController.text = mockData['insuranceNumber']?.toString() ?? '';
      }
    } catch (e) {
      print('❌ Erreur chargement véhicule: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveVehicleData() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Simuler la sauvegarde
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informations véhicule mises à jour !'),
            backgroundColor: BatteColors.success,
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur sauvegarde: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la sauvegarde'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BatteColors.softGreen,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: BatteColors.foreground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Mon véhicule',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: BatteColors.foreground,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit_rounded, color: BatteColors.primary),
              onPressed: () {
                setState(() => _isEditing = true);
              },
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: BatteColors.primary,
                ),
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Informations principales du véhicule
                  SliverToBoxAdapter(
                    child: _buildVehicleInfo(),
                  ),
                  
                  // Formulaire d'édition
                  if (_isEditing)
                    SliverToBoxAdapter(
                      child: _buildEditForm(),
                    ),
                  
                  // Statut et maintenance
                  SliverToBoxAdapter(
                    child: _buildStatusAndMaintenance(),
                  ),
                  
                  // Documents
                  SliverToBoxAdapter(
                    child: _buildDocuments(),
                  ),
                  
                  // Photos du véhicule
                  SliverToBoxAdapter(
                    child: _buildVehiclePhotos(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildVehicleInfo() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icône du véhicule
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: BatteColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: BatteColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _vehicleData['vehicleType'] ?? 'Type de véhicule',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: BatteColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _vehicleData['licensePlate'] ?? 'Plaque d\'immatriculation',
            style: TextStyle(
              fontSize: 16,
              color: BatteColors.foreground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.straighten_rounded,
                  title: 'Capacité',
                  value: '${_vehicleData['capacity'] ?? 0} tonnes',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.calendar_today_rounded,
                  title: 'Année',
                  value: _vehicleData['year'] ?? 'N/A',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.local_gas_station_rounded,
                  title: 'Carburant',
                  value: _vehicleData['fuelType'] ?? 'N/A',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.speed_rounded,
                  title: 'Kilométrage',
                  value: '${_vehicleData['mileage'] ?? 0} km',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: BatteColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: BatteColors.foreground,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: BatteColors.foreground.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Modifier les informations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: BatteColors.foreground,
              ),
            ),
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _vehicleTypeController,
              decoration: InputDecoration(
                labelText: 'Type de véhicule',
                prefixIcon: Icon(Icons.local_shipping_rounded, color: BatteColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: BatteColors.primary),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez saisir le type de véhicule';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _licensePlateController,
              decoration: InputDecoration(
                labelText: 'Plaque d\'immatriculation',
                prefixIcon: Icon(Icons.directions_car_rounded, color: BatteColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: BatteColors.primary),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez saisir la plaque d\'immatriculation';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Capacité (tonnes)',
                      prefixIcon: Icon(Icons.straighten_rounded, color: BatteColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: BatteColors.primary),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Capacité requise';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Année',
                      prefixIcon: Icon(Icons.calendar_today_rounded, color: BatteColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: BatteColors.primary),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Année requise';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _insuranceController,
              decoration: InputDecoration(
                labelText: 'Numéro d\'assurance',
                prefixIcon: Icon(Icons.security_rounded, color: BatteColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: BatteColors.primary),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez saisir le numéro d\'assurance';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _isEditing = false);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveVehicleData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BatteColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Sauvegarder'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusAndMaintenance() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statut et maintenance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BatteColors.foreground,
            ),
          ),
          const SizedBox(height: 20),
          
          // Statut du véhicule
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BatteColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: BatteColors.success,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statut',
                        style: TextStyle(
                          fontSize: 12,
                          color: BatteColors.foreground.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        _vehicleData['status'] ?? 'En service',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: BatteColors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Dernière maintenance
          _buildMaintenanceItem(
            icon: Icons.build_rounded,
            title: 'Dernière maintenance',
            date: _vehicleData['lastMaintenance'],
            color: BatteColors.info,
          ),
          
          const SizedBox(height: 12),
          
          // Prochaine maintenance
          _buildMaintenanceItem(
            icon: Icons.schedule_rounded,
            title: 'Prochaine maintenance',
            date: _vehicleData['nextMaintenance'],
            color: BatteColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceItem({
    required IconData icon,
    required String title,
    required DateTime? date,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: BatteColors.foreground.withOpacity(0.6),
                  ),
                ),
                Text(
                  date != null ? Helpers.formatDate(date) : 'Non programmée',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: BatteColors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocuments() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Documents du véhicule',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BatteColors.foreground,
            ),
          ),
          const SizedBox(height: 16),
          ...(_vehicleData['documents'] as List).map((doc) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BatteColors.softGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description_rounded,
                    color: BatteColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: BatteColors.foreground,
                          ),
                        ),
                        Text(
                          doc['status'],
                          style: TextStyle(
                            fontSize: 12,
                            color: BatteColors.foreground.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (doc['expiry'] != null)
                    Text(
                      'Expire: ${Helpers.formatDate(doc['expiry'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: BatteColors.foreground.withOpacity(0.6),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildVehiclePhotos() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Photos du véhicule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: BatteColors.foreground,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ajouter des photos bientôt disponible !'),
                      backgroundColor: BatteColors.primary,
                    ),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Ajouter'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: (_vehicleData['photos'] as List).length + 1,
              itemBuilder: (context, index) {
                if (index == (_vehicleData['photos'] as List).length) {
                  // Bouton d'ajout
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: BatteColors.softGreen.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: BatteColors.primary.withOpacity(0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_rounded,
                            color: BatteColors.primary,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ajouter',
                            style: TextStyle(
                              fontSize: 12,
                              color: BatteColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                // Photo existante
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: BatteColors.softGreen.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: BatteColors.primary,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
