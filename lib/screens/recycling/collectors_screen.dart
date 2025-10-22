import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/colors.dart';
import '../../services/supabase_service.dart';
import '../../services/geolocation_service.dart';
import '../../widgets/loading_widget.dart' as custom;

/// Écran des collecteurs de déchets proches
class CollectorsScreen extends StatefulWidget {
  const CollectorsScreen({Key? key}) : super(key: key);
  
  @override
  State<CollectorsScreen> createState() => _CollectorsScreenState();
}

class _CollectorsScreenState extends State<CollectorsScreen> {
  List<Map<String, dynamic>> _collectors = [];
  bool _isLoading = false;
  Position? _userPosition;
  bool _locationEnabled = false;
  
  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }
  
  Future<void> _initializeLocation() async {
    setState(() => _isLoading = true);
    
    // Obtenir la position de l'utilisateur
    final position = await GeolocationService.getCurrentPosition();
    
    if (mounted) {
      setState(() {
        _userPosition = position;
        _locationEnabled = position != null;
      });
      
      if (!_locationEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Localisation désactivée. Les distances ne seront pas calculées.'),
            backgroundColor: BatteColors.muted,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
    
    await _loadCollectors();
  }
  
  Future<void> _loadCollectors() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      List<Map<String, dynamic>> data;
      
      // Essayer de charger depuis Supabase
      try {
        data = List<Map<String, dynamic>>.from(await SupabaseService.getCollectors());
      } catch (e) {
        print('⚠️ Impossible de charger depuis Supabase, utilisation de données de test');
        // Utiliser des données de test si Supabase échoue
        data = GeolocationService.getTestCollectors();
      }
      
      // Calculer les distances si la position est disponible
      if (_userPosition != null && data.isNotEmpty) {
        data = GeolocationService.sortCollectorsByDistance(
          collectors: data,
          userLatitude: _userPosition!.latitude,
          userLongitude: _userPosition!.longitude,
        );
      }
      
      if (!mounted) return;
      setState(() {
        _collectors = data;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur chargement collecteurs: $e');
      if (!mounted) return;
      setState(() {
        _collectors = GeolocationService.getTestCollectors();
        _isLoading = false;
      });
      
      // Afficher un message d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chargement des collecteurs de test'),
            backgroundColor: BatteColors.muted,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collecteurs proches'),
        backgroundColor: BatteColors.primary,
        actions: [
          if (_locationEnabled)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.location_on, size: 16),
                      SizedBox(width: 4),
                      Text('GPS activé', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeLocation,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const custom.LoadingWidget(message: 'Recherche de collecteurs...')
            : _collectors.isEmpty
                ? const custom.EmptyWidget(
                    message: 'Aucun collecteur trouvé à proximité.\nLes collecteurs apparaîtront ici quand ils seront disponibles.',
                    icon: Icons.person_search,
                  )
                : RefreshIndicator(
                    onRefresh: _loadCollectors,
                    child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _collectors.length,
                    itemBuilder: (context, index) {
                      final collector = _collectors[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: BatteColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: BatteColors.primary,
                                  child: Text(
                                    (collector['name'] ?? 'C')[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: BatteColors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        collector['name'] ?? 'Collecteur',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        collector['location'] ?? 'Conakry',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: BatteColors.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 16,
                                  color: BatteColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  collector['phone'] ?? '+224...',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            if (collector['formattedDistance'] != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: BatteColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    collector['formattedDistance'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ] else if (!_locationEnabled) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    size: 16,
                                    color: BatteColors.mutedForeground,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Distance non disponible',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: BatteColors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            // Boutons d'action
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _callCollector(collector['phone']),
                                    icon: const Icon(Icons.phone, size: 18),
                                    label: const Text('Appeler'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: BatteColors.primary,
                                      foregroundColor: BatteColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showCollectorDetails(collector),
                                    icon: const Icon(Icons.info_outline, size: 18),
                                    label: const Text('Détails'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: BatteColors.primary,
                                      side: const BorderSide(color: BatteColors.primary),
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
                    },
                                    ),
                  ),
      ),
    );
  }

  Future<void> _callCollector(String? phone) async {
    if (phone == null || phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Numéro de téléphone non disponible'),
            backgroundColor: BatteColors.destructive,
          ),
        );
      }
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir l\'application téléphone'),
            backgroundColor: BatteColors.destructive,
          ),
        );
      }
    }
  }

  void _showCollectorDetails(Map<String, dynamic> collector) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: BatteColors.primary,
                    child: Text(
                      (collector['name'] ?? 'C')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: BatteColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collector['name'] ?? 'Collecteur',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (index) => Icon(
                                index < (collector['rating'] ?? 0)
                                    ? Icons.star
                                    : Icons.star_border,
                                color: BatteColors.secondary,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${collector['rating'] ?? 0}/5',
                              style: const TextStyle(
                                fontSize: 14,
                                color: BatteColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 32),

              // Détails
              _buildDetailRow(
                'Localisation',
                collector['location'] ?? 'Non spécifiée',
                Icons.location_on,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Téléphone',
                collector['phone'] ?? 'Non disponible',
                Icons.phone,
              ),
              if (collector['formattedDistance'] != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Distance',
                  collector['formattedDistance'],
                  Icons.directions_walk,
                ),
              ],
              if (collector['availability'] != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Disponibilité',
                  collector['availability'] ? 'Disponible ✅' : 'Indisponible ❌',
                  Icons.access_time,
                ),
              ],

              const SizedBox(height: 24),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _callCollector(collector['phone']);
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Appeler'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BatteColors.primary,
                        foregroundColor: BatteColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: BatteColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 14,
            color: BatteColors.mutedForeground,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: BatteColors.foreground,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

