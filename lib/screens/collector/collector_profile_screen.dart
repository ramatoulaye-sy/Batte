import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/supabase_service.dart';

/// Écran de profil collecteur avec gestion des informations
class CollectorProfileScreen extends StatefulWidget {
  const CollectorProfileScreen({super.key});

  @override
  State<CollectorProfileScreen> createState() => _CollectorProfileScreenState();
}

class _CollectorProfileScreenState extends State<CollectorProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  Map<String, dynamic>? _collectorData;
  bool _isLoading = true;
  bool _isEditing = false;
  
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _licenseController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _radiusController = TextEditingController();

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
    
    _loadCollectorData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _businessNameController.dispose();
    _licenseController.dispose();
    _vehicleController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _loadCollectorData() async {
    setState(() => _isLoading = true);

    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      // Simuler des données collecteur (à remplacer par l'appel Supabase réel)
      await Future.delayed(const Duration(seconds: 1));
      
      final mockData = {
        'business_name': 'Collecte Pro Conakry',
        'license_number': 'CP-2024-001',
        'vehicle_type': 'Camionnette',
        'coverage_radius': 15,
        'is_available': true,
        'rating': 4.8,
        'total_collections': 156,
        'total_earnings': 2500000.0,
        'join_date': DateTime.now().subtract(const Duration(days: 180)),
      };

      if (mounted) {
        setState(() {
          _collectorData = mockData;
          _isLoading = false;
        });
        
        // Remplir les contrôleurs
        _businessNameController.text = mockData['business_name']?.toString() ?? '';
        _licenseController.text = mockData['license_number']?.toString() ?? '';
        _vehicleController.text = mockData['vehicle_type']?.toString() ?? '';
        _radiusController.text = mockData['coverage_radius']?.toString() ?? '15';
      }
    } catch (e) {
      print('❌ Erreur chargement profil: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Simuler la sauvegarde
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès !'),
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
    return Container(
      color: BatteColors.softGreen,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header moderne
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            
            // Contenu du profil
            SliverToBoxAdapter(
              child: _buildProfileContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 48,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: BatteColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profil',
                  style: TextStyle(
                    fontSize: 13,
                    color: BatteColors.foreground.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Mon compte',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: BatteColors.foreground,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          if (!_isEditing)
            GestureDetector(
              onTap: () {
                setState(() => _isEditing = true);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: BatteColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: BatteColors.primary,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: BatteColors.primary,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Carte d'informations principales
          _buildMainInfoCard(),
          
          const SizedBox(height: 20),
          
          // Formulaire d'édition
          if (_isEditing) _buildEditForm(),
          
          const SizedBox(height: 20),
          
          // Statistiques
          _buildStatsCard(),
          
          const SizedBox(height: 20),
          
          // Documents
          _buildDocumentsCard(),
          
          const SizedBox(height: 20),
          
          // Actions
          _buildActionsCard(),
        ],
      ),
    );
  }

  Widget _buildMainInfoCard() {
    return Container(
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
          // Avatar et nom
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
            _collectorData?['business_name'] ?? 'Nom d\'entreprise',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: BatteColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rounded,
                color: BatteColors.gold,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${_collectorData?['rating'] ?? 0.0}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: BatteColors.foreground,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${_collectorData?['total_collections'] ?? 0} collectes)',
                style: TextStyle(
                  fontSize: 14,
                  color: BatteColors.foreground.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Container(
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
              controller: _businessNameController,
              decoration: InputDecoration(
                labelText: 'Nom d\'entreprise',
                prefixIcon: Icon(Icons.business_rounded, color: BatteColors.primary),
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
                  return 'Veuillez saisir le nom d\'entreprise';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _licenseController,
              decoration: InputDecoration(
                labelText: 'Numéro de licence',
                prefixIcon: Icon(Icons.badge_rounded, color: BatteColors.primary),
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
                  return 'Veuillez saisir le numéro de licence';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _vehicleController,
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
              controller: _radiusController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Rayon de couverture (km)',
                prefixIcon: Icon(Icons.location_on_rounded, color: BatteColors.primary),
                suffixText: 'km',
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
                  return 'Veuillez saisir le rayon de couverture';
                }
                final radius = int.tryParse(value);
                if (radius == null || radius < 1 || radius > 50) {
                  return 'Rayon entre 1 et 50 km';
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
                    onPressed: _saveProfile,
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

  Widget _buildStatsCard() {
    return Container(
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
            'Statistiques',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BatteColors.foreground,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.recycling_rounded,
                  title: 'Collectes',
                  value: '${_collectorData?['total_collections'] ?? 0}',
                  color: BatteColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.monetization_on_rounded,
                  title: 'Gains totaux',
                  value: '${(_collectorData?['total_earnings'] ?? 0).toStringAsFixed(0)} GNF',
                  color: BatteColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.calendar_today_rounded,
                  title: 'Membre depuis',
                  value: '${DateTime.now().difference(_collectorData?['join_date'] ?? DateTime.now()).inDays ~/ 30} mois',
                  color: BatteColors.success,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.location_on_rounded,
                  title: 'Rayon',
                  value: '${_collectorData?['coverage_radius'] ?? 0} km',
                  color: BatteColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
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

  Widget _buildDocumentsCard() {
    return Container(
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
            'Documents',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BatteColors.foreground,
            ),
          ),
          const SizedBox(height: 16),
          _buildDocumentItem(
            icon: Icons.badge_rounded,
            title: 'Licence de collecte',
            status: 'Validée',
            statusColor: BatteColors.success,
          ),
          const SizedBox(height: 12),
          _buildDocumentItem(
            icon: Icons.local_shipping_rounded,
            title: 'Assurance véhicule',
            status: 'En cours',
            statusColor: BatteColors.warning,
          ),
          const SizedBox(height: 12),
          _buildDocumentItem(
            icon: Icons.description_rounded,
            title: 'Certificat environnemental',
            status: 'Validée',
            statusColor: BatteColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem({
    required IconData icon,
    required String title,
    required String status,
    required Color statusColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: BatteColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: BatteColors.foreground,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsCard() {
    return Container(
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
            'Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BatteColors.foreground,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionItem(
            icon: Icons.download_rounded,
            title: 'Télécharger les documents',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Téléchargement bientôt disponible !'),
                  backgroundColor: BatteColors.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            icon: Icons.help_rounded,
            title: 'Centre d\'aide',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Centre d\'aide bientôt disponible !'),
                  backgroundColor: BatteColors.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            icon: Icons.logout_rounded,
            title: 'Se déconnecter',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Déconnexion bientôt disponible !'),
                  backgroundColor: BatteColors.primary,
                ),
              );
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : BatteColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : BatteColors.foreground,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDestructive ? Colors.red : Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
