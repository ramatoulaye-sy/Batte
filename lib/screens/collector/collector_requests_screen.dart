import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/helpers.dart';

/// Écran des demandes de collecte pour les collecteurs
class CollectorRequestsScreen extends StatefulWidget {
  const CollectorRequestsScreen({super.key});

  @override
  State<CollectorRequestsScreen> createState() => _CollectorRequestsScreenState();
}

class _CollectorRequestsScreenState extends State<CollectorRequestsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = true;
  String _selectedFilter = 'Toutes';
  List<Map<String, dynamic>> _requests = [];
  
  final List<String> _filters = ['Toutes', 'En attente', 'Acceptées', 'En cours', 'Terminées'];

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
    
    _loadRequests();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    try {
      // Simuler le chargement des demandes
      await Future.delayed(const Duration(seconds: 1));
      
      final mockRequests = [
        {
          'id': 'REQ-001',
          'clientName': 'Fatoumata Diallo',
          'clientPhone': '+224 123 456 789',
          'clientLocation': 'Conakry, Kaloum',
          'wasteType': 'Plastique',
          'weight': 15.5,
          'estimatedPrice': 25000.0,
          'status': 'En attente',
          'requestDate': DateTime.now().subtract(const Duration(hours: 2)),
          'preferredTime': '14h-16h',
          'notes': 'Déchets triés et prêts pour collecte',
          'distance': 2.3,
        },
        {
          'id': 'REQ-002',
          'clientName': 'Mamadou Bah',
          'clientPhone': '+224 987 654 321',
          'clientLocation': 'Conakry, Dixinn',
          'wasteType': 'Métal',
          'weight': 8.2,
          'estimatedPrice': 15000.0,
          'status': 'Acceptée',
          'requestDate': DateTime.now().subtract(const Duration(hours: 4)),
          'preferredTime': '10h-12h',
          'notes': 'Urgent - déménagement',
          'distance': 1.8,
        },
        {
          'id': 'REQ-003',
          'clientName': 'Aminata Camara',
          'clientPhone': '+224 555 123 456',
          'clientLocation': 'Conakry, Ratoma',
          'wasteType': 'Papier',
          'weight': 22.0,
          'estimatedPrice': 35000.0,
          'status': 'En cours',
          'requestDate': DateTime.now().subtract(const Duration(hours: 6)),
          'preferredTime': '16h-18h',
          'notes': 'Grande quantité de cartons',
          'distance': 3.1,
        },
        {
          'id': 'REQ-004',
          'clientName': 'Ibrahima Sow',
          'clientPhone': '+224 777 888 999',
          'clientLocation': 'Conakry, Matam',
          'wasteType': 'Verre',
          'weight': 12.8,
          'estimatedPrice': 20000.0,
          'status': 'Terminée',
          'requestDate': DateTime.now().subtract(const Duration(days: 1)),
          'preferredTime': '9h-11h',
          'notes': 'Bouteilles en verre',
          'distance': 2.7,
        },
        {
          'id': 'REQ-005',
          'clientName': 'Mariama Barry',
          'clientPhone': '+224 333 444 555',
          'clientLocation': 'Conakry, Matoto',
          'wasteType': 'Mixte',
          'weight': 18.5,
          'estimatedPrice': 30000.0,
          'status': 'En attente',
          'requestDate': DateTime.now().subtract(const Duration(hours: 1)),
          'preferredTime': '15h-17h',
          'notes': 'Mélange de différents types',
          'distance': 4.2,
        },
      ];

      if (mounted) {
        setState(() {
          _requests = mockRequests;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement demandes: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredRequests() {
    if (_selectedFilter == 'Toutes') return _requests;
    return _requests.where((request) => request['status'] == _selectedFilter).toList();
  }

  Future<void> _acceptRequest(String requestId) async {
    try {
      // Simuler l'acceptation
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        final index = _requests.indexWhere((req) => req['id'] == requestId);
        if (index != -1) {
          _requests[index]['status'] = 'Acceptée';
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande acceptée avec succès !'),
            backgroundColor: BatteColors.success,
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur acceptation: $e');
    }
  }

  Future<void> _startCollection(String requestId) async {
    try {
      // Simuler le début de collecte
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        final index = _requests.indexWhere((req) => req['id'] == requestId);
        if (index != -1) {
          _requests[index]['status'] = 'En cours';
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Collecte démarrée !'),
            backgroundColor: BatteColors.primary,
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur démarrage: $e');
    }
  }

  Future<void> _completeCollection(String requestId) async {
    try {
      // Simuler la fin de collecte
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        final index = _requests.indexWhere((req) => req['id'] == requestId);
        if (index != -1) {
          _requests[index]['status'] = 'Terminée';
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Collecte terminée avec succès !'),
            backgroundColor: BatteColors.success,
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur completion: $e');
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
          'Demandes de collecte',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: BatteColors.foreground,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: BatteColors.primary),
            onPressed: _loadRequests,
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
            : Column(
                children: [
                  // Filtres
                  _buildFilters(),
                  
                  // Liste des demandes
                  Expanded(
                    child: _buildRequestsList(),
                  ),
                ],
              ),
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

  Widget _buildRequestsList() {
    final filteredRequests = _getFilteredRequests();

    if (filteredRequests.isEmpty) {
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
              Icons.inbox_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune demande trouvée',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les nouvelles demandes apparaîtront ici',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredRequests.length,
      itemBuilder: (context, index) {
        final request = filteredRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final status = request['status'];
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'En attente':
        statusColor = BatteColors.warning;
        statusIcon = Icons.schedule_rounded;
        break;
      case 'Acceptée':
        statusColor = BatteColors.info;
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'En cours':
        statusColor = BatteColors.primary;
        statusIcon = Icons.local_shipping_rounded;
        break;
      case 'Terminée':
        statusColor = BatteColors.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_rounded;
    }

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
          // Header avec statut
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
                    request['clientName'][0].toUpperCase(),
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
                      request['clientName'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: BatteColors.foreground,
                      ),
                    ),
                    Text(
                      request['clientLocation'],
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
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Détails de la demande
          Row(
            children: [
              Expanded(
                child: _buildRequestDetail(
                  icon: Icons.recycling_rounded,
                  title: 'Type',
                  value: request['wasteType'],
                ),
              ),
              Expanded(
                child: _buildRequestDetail(
                  icon: Icons.scale_rounded,
                  title: 'Poids',
                  value: Helpers.formatWeight(request['weight']),
                ),
              ),
              Expanded(
                child: _buildRequestDetail(
                  icon: Icons.monetization_on_rounded,
                  title: 'Prix',
                  value: '${request['estimatedPrice'].toStringAsFixed(0)} GNF',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildRequestDetail(
                  icon: Icons.location_on_rounded,
                  title: 'Distance',
                  value: '${request['distance']} km',
                ),
              ),
              Expanded(
                child: _buildRequestDetail(
                  icon: Icons.access_time_rounded,
                  title: 'Heure',
                  value: request['preferredTime'],
                ),
              ),
              Expanded(
                child: _buildRequestDetail(
                  icon: Icons.calendar_today_rounded,
                  title: 'Date',
                  value: Helpers.formatDate(request['requestDate']),
                ),
              ),
            ],
          ),
          
          if (request['notes'] != null && request['notes'].isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BatteColors.softGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.note_rounded,
                    color: BatteColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request['notes'],
                      style: TextStyle(
                        fontSize: 12,
                        color: BatteColors.foreground.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Actions selon le statut
          _buildActions(request),
        ],
      ),
    );
  }

  Widget _buildRequestDetail({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: BatteColors.primary, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: BatteColors.foreground,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: BatteColors.foreground.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(Map<String, dynamic> request) {
    final status = request['status'];
    
    switch (status) {
      case 'En attente':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Refuser la demande
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonction de refus bientôt disponible !'),
                      backgroundColor: BatteColors.primary,
                    ),
                  );
                },
                icon: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Refuser'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _acceptRequest(request['id']),
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Accepter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BatteColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
      case 'Acceptée':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _startCollection(request['id']),
            icon: const Icon(Icons.play_arrow_rounded, size: 16),
            label: const Text('Démarrer la collecte'),
            style: ElevatedButton.styleFrom(
              backgroundColor: BatteColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      case 'En cours':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _completeCollection(request['id']),
            icon: const Icon(Icons.check_circle_rounded, size: 16),
            label: const Text('Terminer la collecte'),
            style: ElevatedButton.styleFrom(
              backgroundColor: BatteColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      case 'Terminée':
        return Row(
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
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
