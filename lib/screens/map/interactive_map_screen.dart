import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/supabase_service.dart';

/// Écran de carte interactive avec points de collecte
class InteractiveMapScreen extends StatefulWidget {
  const InteractiveMapScreen({Key? key}) : super(key: key);

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  List<Map<String, dynamic>> _collectors = [];
  List<Map<String, dynamic>> _collectionPoints = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // all, collectors, points

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    setState(() => _isLoading = true);
    
    try {
      final collectors = await SupabaseService.getCollectors();
      
      // Points de collecte fixes (exemples)
      final points = [
        {
          'id': '1',
          'name': 'Centre de tri Kaloum',
          'address': 'Avenue de la République, Conakry',
          'latitude': 9.509,
          'longitude': -13.712,
          'types': ['Plastique', 'Papier', 'Verre'],
          'openHours': '8h - 18h',
        },
        {
          'id': '2',
          'name': 'Point vert Matam',
          'address': 'Quartier Matam, Conakry',
          'latitude': 9.537,
          'longitude': -13.678,
          'types': ['Électronique', 'Métal'],
          'openHours': '9h - 17h',
        },
      ];

      if (mounted) {
        setState(() {
          _collectors = collectors;
          _collectionPoints = points;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des collectes'),
        backgroundColor: BatteColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtres
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildFilterChip('Tout', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Collecteurs', 'collectors'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Points fixes', 'points'),
                    ],
                  ),
                ),

                // Carte placeholder + liste
                Expanded(
                  child: Stack(
                    children: [
                      // TODO: Intégrer Google Maps ou OpenStreetMap
                      Container(
                        color: BatteColors.muted,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map,
                                size: 80,
                                color: BatteColors.mutedForeground,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Carte interactive',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Intégration Google Maps à venir',
                                style: TextStyle(
                                  color: BatteColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Liste en bas
                      DraggableScrollableSheet(
                        initialChildSize: 0.3,
                        minChildSize: 0.1,
                        maxChildSize: 0.9,
                        builder: (context, scrollController) {
                          return Container(
                            decoration: BoxDecoration(
                              color: BatteColors.white,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Handle
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 12),
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: BatteColors.mutedForeground,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),

                                // Liste
                                Expanded(
                                  child: ListView(
                                    controller: scrollController,
                                    padding: const EdgeInsets.all(16),
                                    children: [
                                      if (_selectedFilter == 'all' || _selectedFilter == 'collectors')
                                        ..._buildCollectorsList(),
                                      if (_selectedFilter == 'all' || _selectedFilter == 'points')
                                        ..._buildPointsList(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = value),
      backgroundColor: BatteColors.muted,
      selectedColor: BatteColors.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? BatteColors.primary : BatteColors.foreground,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: BatteColors.primary,
    );
  }

  List<Widget> _buildCollectorsList() {
    return _collectors.map((collector) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: BatteColors.primary,
            child: Icon(Icons.local_shipping, color: BatteColors.white),
          ),
          title: Text(
            collector['name'] ?? 'Collecteur',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${collector['location'] ?? 'Conakry'} - ${collector['distance'] ?? '?'} km',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                (collector['rating'] ?? 0).toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildPointsList() {
    return _collectionPoints.map((point) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: BatteColors.success,
            child: const Icon(Icons.location_on, color: BatteColors.white),
          ),
          title: Text(
            point['name'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(point['address']),
              const SizedBox(height: 4),
              Text(
                'Horaires : ${point['openHours']}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Types acceptés : ${(point['types'] as List).join(', ')}',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          isThreeLine: true,
        ),
      );
    }).toList();
  }
}

