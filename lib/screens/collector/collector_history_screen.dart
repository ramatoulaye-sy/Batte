import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/supabase_service.dart';
import '../../core/utils/helpers.dart';

/// Écran d'historique des collectes pour les collecteurs
class CollectorHistoryScreen extends StatefulWidget {
  const CollectorHistoryScreen({super.key});

  @override
  State<CollectorHistoryScreen> createState() => _CollectorHistoryScreenState();
}

class _CollectorHistoryScreenState extends State<CollectorHistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  List<Map<String, dynamic>> _collections = [];
  bool _isLoading = true;
  String _selectedFilter = 'Tous';
  
  final List<String> _filters = ['Tous', 'Aujourd\'hui', 'Cette semaine', 'Ce mois'];

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
    
    _loadCollections();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadCollections() async {
    setState(() => _isLoading = true);

    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      // Simuler des données de collectes (à remplacer par l'appel Supabase réel)
      await Future.delayed(const Duration(seconds: 1));
      
      final mockCollections = [
        {
          'id': '1',
          'client_name': 'Fatoumata Diallo',
          'client_phone': '+224 123 456 789',
          'weight': 15.5,
          'price': 25000.0,
          'date': DateTime.now().subtract(const Duration(hours: 2)),
          'status': 'completed',
          'location': 'Conakry, Kaloum',
        },
        {
          'id': '2',
          'client_name': 'Mamadou Bah',
          'client_phone': '+224 987 654 321',
          'weight': 8.2,
          'price': 15000.0,
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'status': 'completed',
          'location': 'Conakry, Dixinn',
        },
        {
          'id': '3',
          'client_name': 'Aminata Camara',
          'client_phone': '+224 555 123 456',
          'weight': 22.0,
          'price': 35000.0,
          'date': DateTime.now().subtract(const Duration(days: 2)),
          'status': 'completed',
          'location': 'Conakry, Ratoma',
        },
        {
          'id': '4',
          'client_name': 'Ibrahima Sow',
          'client_phone': '+224 777 888 999',
          'weight': 12.8,
          'price': 20000.0,
          'date': DateTime.now().subtract(const Duration(days: 3)),
          'status': 'completed',
          'location': 'Conakry, Matam',
        },
        {
          'id': '5',
          'client_name': 'Mariama Barry',
          'client_phone': '+224 333 444 555',
          'weight': 18.5,
          'price': 30000.0,
          'date': DateTime.now().subtract(const Duration(days: 5)),
          'status': 'completed',
          'location': 'Conakry, Matoto',
        },
      ];

      if (mounted) {
        setState(() {
          _collections = mockCollections;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement collectes: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredCollections() {
    if (_selectedFilter == 'Tous') return _collections;
    
    final now = DateTime.now();
    return _collections.where((collection) {
      final date = collection['date'] as DateTime;
      
      switch (_selectedFilter) {
        case 'Aujourd\'hui':
          return date.day == now.day && date.month == now.month && date.year == now.year;
        case 'Cette semaine':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          return date.isAfter(weekStart);
        case 'Ce mois':
          return date.month == now.month && date.year == now.year;
        default:
          return true;
      }
    }).toList();
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
            
            // Filtres
            SliverToBoxAdapter(
              child: _buildFilters(),
            ),
            
            // Statistiques rapides
            SliverToBoxAdapter(
              child: _buildQuickStats(),
            ),
            
            // Liste des collectes
            SliverToBoxAdapter(
              child: _buildCollectionsList(),
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
              Icons.history_rounded,
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
                  'Historique',
                  style: TextStyle(
                    fontSize: 13,
                    color: BatteColors.foreground.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Mes collectes',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: BatteColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${_collections.length} collectes',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: BatteColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? BatteColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  filter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : BatteColors.foreground,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickStats() {
    final filteredCollections = _getFilteredCollections();
    final totalWeight = filteredCollections.fold<double>(
      0.0, 
      (sum, collection) => sum + (collection['weight'] as double),
    );
    final totalEarnings = filteredCollections.fold<double>(
      0.0, 
      (sum, collection) => sum + (collection['price'] as double),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.scale_rounded,
              title: 'Poids total',
              value: Helpers.formatWeight(totalWeight),
              color: BatteColors.primary,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[200],
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.monetization_on_rounded,
              title: 'Gains totaux',
              value: '${totalEarnings.toStringAsFixed(0)} GNF',
              color: BatteColors.gold,
            ),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: BatteColors.foreground,
          ),
        ),
        const SizedBox(height: 2),
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

  Widget _buildCollectionsList() {
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

    final filteredCollections = _getFilteredCollections();

    if (filteredCollections.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune collecte trouvée',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos collectes apparaîtront ici',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: filteredCollections.map((collection) {
          return _buildCollectionCard(collection);
        }).toList(),
      ),
    );
  }

  Widget _buildCollectionCard(Map<String, dynamic> collection) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: BatteColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    collection['client_name'][0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection['client_name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: BatteColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      collection['location'],
                      style: TextStyle(
                        fontSize: 12,
                        color: BatteColors.foreground.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: BatteColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Terminée',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: BatteColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCollectionDetail(
                  icon: Icons.scale_rounded,
                  title: 'Poids',
                  value: Helpers.formatWeight(collection['weight']),
                ),
              ),
              Expanded(
                child: _buildCollectionDetail(
                  icon: Icons.monetization_on_rounded,
                  title: 'Prix',
                  value: '${collection['price'].toStringAsFixed(0)} GNF',
                ),
              ),
              Expanded(
                child: _buildCollectionDetail(
                  icon: Icons.access_time_rounded,
                  title: 'Date',
                  value: Helpers.formatDate(collection['date']),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Appeler le client
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonction d\'appel bientôt disponible !'),
                        backgroundColor: BatteColors.primary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone_rounded, size: 16),
                  label: const Text('Appeler'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: BatteColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Voir les détails
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Détails bientôt disponibles !'),
                        backgroundColor: BatteColors.primary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility_rounded, size: 16),
                  label: const Text('Détails'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BatteColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionDetail({
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
}
