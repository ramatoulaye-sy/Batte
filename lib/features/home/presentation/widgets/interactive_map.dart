import 'package:flutter/material.dart';
import 'package:batte/core/app_theme.dart';
import 'package:batte/services/location_service.dart';

class InteractiveMap extends StatefulWidget {
  final bool isLocationActive;
  final String userName;
  final double monthlyWaste;
  final Function(Map<String, dynamic>)? onCollectorSelected;
  final bool showRealCollectors;

  const InteractiveMap({
    super.key,
    this.isLocationActive = false,
    this.userName = 'Utilisateur',
    this.monthlyWaste = 0.0,
    this.onCollectorSelected,
    this.showRealCollectors = false,
  });

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  final LocationService _locationService = LocationService.instance;
  
  List<Map<String, dynamic>> _collectors = [];
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _selectedCollector;

  @override
  void initState() {
    super.initState();
    if (widget.showRealCollectors) {
      _loadRealCollectors();
    }
    _loadMockData();
  }

  Future<void> _loadRealCollectors() async {
    setState(() => _isLoading = true);
    try {
      final position = await _locationService.getLocation();
      if (position != null) {
        final collectors = await _locationService.getCollectorsInRadius(
          position.latitude, 
          position.longitude, 
          10 // 10km radius
        );
        if (mounted) {
          setState(() {
            _collectors = collectors.map((c) {
              final user = c['users'] ?? {};
              return {
                'id': c['id'].toString(),
                'name': user['full_name'] ?? user['name'] ?? 'Collecteur',
                'points': c['rating'] ?? 0,
                'distance': c['distance_km'] ?? 0.0,
                'eta': _calculateETA(c['distance_km'] ?? 0.0),
                'location': _calculateMapPosition(c['distance_km'] ?? 0.0),
                'rating': c['rating'] ?? 0.0,
                'is_available': c['is_available'] ?? false,
                'specialization': c['specialization'] ?? 'Général',
                'phone': user['phone'] ?? '',
                'avatar_url': user['avatar_url'],
              };
            }).toList();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Erreur de chargement: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loadMockData() {
    // Données simulées des utilisateurs (pour démonstration)
    _users = [
      {
        'id': '1',
        'name': widget.userName,
        'waste': widget.monthlyWaste,
        'location': const Offset(0.5, 0.5),
        'status': 'active',
      },
      {
        'id': '2',
        'name': 'Victoria',
        'waste': 12.0,
        'location': const Offset(0.2, 0.3),
        'status': 'active',
      },
    ];

    // Si pas de collecteurs réels, utiliser les données simulées
    if (_collectors.isEmpty) {
      _collectors = [
    {
      'id': '1',
      'name': 'Mamadou',
      'points': 8,
      'distance': 0.8,
      'eta': '12:30',
      'location': const Offset(0.7, 0.3),
      'rating': 4.8,
          'is_available': true,
          'specialization': 'Plastique & Métal',
          'phone': '+224 123 456 789',
    },
    {
      'id': '2',
      'name': 'Fatou',
      'points': 6,
      'distance': 1.2,
      'eta': '13:15',
      'location': const Offset(0.3, 0.7),
      'rating': 4.5,
          'is_available': true,
          'specialization': 'Organique & Verre',
          'phone': '+224 987 654 321',
    },
    {
      'id': '3',
      'name': 'Ibrahima',
      'points': 4,
      'distance': 1.5,
      'eta': '13:45',
      'location': const Offset(0.8, 0.8),
      'rating': 4.2,
          'is_available': false,
          'specialization': 'Papier & Carton',
          'phone': '+224 555 123 456',
        },
      ];
    }
  }

  Offset _calculateMapPosition(double distanceKm) {
    // Convertir la distance en position sur la carte
    // Plus la distance est grande, plus le collecteur est loin du centre
    
    // Position aléatoire mais cohérente basée sur l'ID
    final random = (distanceKm * 1000).round();
    final x = 0.1 + (random % 80) / 100.0;
    final y = 0.1 + ((random * 2) % 80) / 100.0;
    
    return Offset(x, y);
  }

  String _calculateETA(double distanceKm) {
    // Calculer le temps d'arrivée estimé
    final avgSpeed = 20.0; // km/h en ville
    final timeHours = distanceKm / avgSpeed;
    final timeMinutes = (timeHours * 60).round();
    
    if (timeMinutes < 60) {
      return '${timeMinutes}min';
    } else {
      final hours = (timeMinutes / 60).floor();
      final minutes = timeMinutes % 60;
      return '${hours}h${minutes > 0 ? '${minutes}min' : ''}';
    }
  }

  void _onCollectorTapped(Map<String, dynamic> collector) {
    setState(() => _selectedCollector = collector);
    widget.onCollectorSelected?.call(collector);
    
    // Afficher les détails du collecteur
    _showCollectorDetails(collector);
  }

  void _showCollectorDetails(Map<String, dynamic> collector) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: Icon(
                      Icons.local_shipping,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collector['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          collector['specialization'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Distance', '${collector['distance'].toStringAsFixed(1)} km'),
                    _buildDetailRow('Temps d\'arrivée', collector['eta']),
                    _buildDetailRow('Note', '${collector['rating'].toStringAsFixed(1)}/5'),
                    _buildDetailRow('Disponibilité', 
                      collector['is_available'] ? 'Disponible' : 'Occupé',
                      color: collector['is_available'] ? Colors.green : Colors.orange
                    ),
                    if (collector['phone'] != null && collector['phone'].isNotEmpty)
                      _buildDetailRow('Téléphone', collector['phone']),
                    
                    const SizedBox(height: 16),
                    
                    if (collector['is_available'])
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onCollectorSelected?.call(collector);
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Sélectionner ce collecteur'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? AppTheme.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        const double collectorMarkerW = 56;
        const double collectorMarkerH = 32;
        const double userMarkerW = 56;
        const double userMarkerH = 32;
        
    return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          // Carte de base (placeholder)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              painter: MapPainter(),
                ),
              ),
              
              // Indicateur de chargement
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              
              // Message d'erreur
              if (_errorMessage != null)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          
          // Collecteurs
              ..._collectors.map((collector) => _buildCollectorMarker(
                    collector,
                    width,
                    height,
                    collectorMarkerW,
                    collectorMarkerH,
                  )),
          
          // Utilisateurs
              ..._users.map((user) => _buildUserMarker(
                    user,
                    width,
                    height,
                    userMarkerW,
                    userMarkerH,
                  )),
          
          // Légende
          Positioned(
            top: 16,
            right: 16,
            child: _buildLegend(),
          ),
        ],
      ),
        );
      },
    );
  }

  Widget _buildCollectorMarker(
    Map<String, dynamic> collector,
    double width,
    double height,
    double markerW,
    double markerH,
  ) {
    final isAvailable = collector['is_available'] ?? true;
    final isSelected = _selectedCollector?['id'] == collector['id'];
    
    return Positioned(
      left: (collector['location'].dx * width).clamp(8.0, width - markerW - 8.0),
      top: (collector['location'].dy * height).clamp(8.0, height - markerH - 8.0),
      child: GestureDetector(
        onTap: () => _onCollectorTapped(collector),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.accentColor 
                : (isAvailable ? AppTheme.primaryColor : Colors.grey),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isAvailable ? AppTheme.primaryColor : Colors.grey).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: isSelected 
                ? Border.all(color: AppTheme.accentColor, width: 2)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAvailable ? Icons.local_shipping : Icons.block,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${collector['points']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserMarker(
    Map<String, dynamic> user,
    double width,
    double height,
    double markerW,
    double markerH,
  ) {
    final isActive = user['status'] == 'active';
    
    return Positioned(
      left: (user['location'].dx * width).clamp(8.0, width - markerW - 8.0),
      top: (user['location'].dy * height).clamp(8.0, height - markerH - 8.0),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.secondaryColor : Colors.grey,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isActive ? AppTheme.secondaryColor : Colors.grey).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${user['waste']}kg',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendItem(
            'Collecteurs',
            AppTheme.primaryColor,
            Icons.local_shipping,
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            'Collecteurs occupés',
            Colors.grey,
            Icons.block,
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            'Utilisateurs',
            AppTheme.secondaryColor,
            Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 12,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Peintre personnalisé pour la carte
class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Dessiner des routes simples
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      paint,
    );
    
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
