import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:batte/services/supabase_service.dart';
import 'package:batte/core/app_config.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._internal();
  
  LocationService._internal();

  final SupabaseService _supabase = SupabaseService.instance;
  Position? _currentPosition;

  /// Vérifie et demande les permissions de localisation
  Future<bool> requestLocationPermission() async {
    try {
      // Vérifier le statut de la permission
      PermissionStatus status = await Permission.location.status;
      
      if (status.isDenied) {
        // Demander la permission
        status = await Permission.location.request();
      }
      
      if (status.isPermanentlyDenied) {
        // Ouvrir les paramètres de l'app
        await openAppSettings();
        return false;
      }
      
      return status.isGranted;
    } catch (e) {
      print('❌ Erreur lors de la demande de permission: $e');
      return false;
    }
  }

  /// Vérifie si la localisation est activée
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('❌ Erreur lors de la vérification du service de localisation: $e');
      return false;
    }
  }

  /// Obtient la position actuelle de l'utilisateur
  Future<Position?> getCurrentLocation() async {
    try {
      // Vérifier les permissions
      if (!await requestLocationPermission()) {
        print('❌ Permission de localisation refusée');
        return null;
      }

      // Vérifier si le service est activé
      if (!await isLocationServiceEnabled()) {
        print('❌ Service de localisation désactivé');
        return null;
      }

      // Obtenir la position actuelle
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print('✅ Position obtenue: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
      return _currentPosition;
      
    } catch (e) {
      print('❌ Erreur lors de l\'obtention de la position: $e');
      return null;
    }
  }

  /// Obtient la dernière position connue
  Future<Position?> getLastKnownLocation() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      print('❌ Erreur lors de la récupération de la dernière position: $e');
      return null;
    }
  }

  /// Calcule la distance entre deux points
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calcule la distance entre la position actuelle et un point
  double calculateDistanceFromCurrent(double endLatitude, double endLongitude) {
    if (_currentPosition == null) return double.infinity;
    
    return calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Récupère les collecteurs dans un rayon donné
  Future<List<Map<String, dynamic>>> getCollectorsInRadius(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      // Récupérer tous les collecteurs disponibles
      final collectors = await _supabase.getAvailableCollectors(latitude, longitude, radiusKm.round());
      
      // Filtrer par distance
      final nearbyCollectors = <Map<String, dynamic>>[];
      
      for (final collector in collectors) {
        final collectorLat = collector['current_location_lat'] ?? 0.0;
        final collectorLng = collector['current_location_lng'] ?? 0.0;
        
        if (collectorLat != 0.0 && collectorLng != 0.0) {
          final distance = calculateDistance(
            latitude,
            longitude,
            collectorLat,
            collectorLng,
          );
          
          // Convertir en km
          final distanceKm = distance / 1000;
          
          if (distanceKm <= radiusKm) {
            // Ajouter la distance au collecteur
            collector['distance_km'] = distanceKm;
            nearbyCollectors.add(collector);
          }
        }
      }
      
      // Trier par distance
      nearbyCollectors.sort((a, b) => (a['distance_km'] ?? 0.0).compareTo(b['distance_km'] ?? 0.0));
      
      print('✅ ${nearbyCollectors.length} collecteurs trouvés dans un rayon de ${radiusKm}km');
      return nearbyCollectors;
      
    } catch (e) {
      print('❌ Erreur lors de la récupération des collecteurs: $e');
      return [];
    }
  }

  /// Met à jour la position de l'utilisateur dans la base de données
  Future<bool> updateUserLocation(
    String userId,
    double latitude,
    double longitude,
  ) async {
    try {
      final success = await _supabase.updateUserProfile(userId, {
        'location_lat': latitude,
        'location_lng': longitude,
      });
      
      if (success) {
        print('✅ Position utilisateur mise à jour: $latitude, $longitude');
      }
      
      return success;
    } catch (e) {
      print('❌ Erreur lors de la mise à jour de la position: $e');
      return false;
    }
  }

  /// Obtient la position actuelle et la met à jour dans la base
  Future<bool> updateCurrentUserLocation(String userId) async {
    try {
      final position = await getCurrentLocation();
      
      if (position != null) {
        return await updateUserLocation(
          userId,
          position.latitude,
          position.longitude,
        );
      }
      
      return false;
    } catch (e) {
      print('❌ Erreur lors de la mise à jour de la position actuelle: $e');
      return false;
    }
  }

  /// Formate la distance pour l'affichage
  String formatDistance(double distanceMeters) {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()}m';
    } else {
      final km = distanceMeters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }

  /// Formate le temps de trajet estimé
  String formatEstimatedTime(double distanceKm) {
    // Estimation basique : 30 km/h en ville
    final estimatedMinutes = (distanceKm / 30) * 60;
    
    if (estimatedMinutes < 1) {
      return 'Moins d\'1 min';
    } else if (estimatedMinutes < 60) {
      return '${estimatedMinutes.round()} min';
    } else {
      final hours = estimatedMinutes / 60;
      return '${hours.toStringAsFixed(1)}h';
    }
  }

  /// Récupère la position actuelle ou la dernière connue
  Future<Position?> getLocation() async {
    try {
      // Essayer d'abord la position actuelle
      final currentPosition = await getCurrentLocation();
      if (currentPosition != null) return currentPosition;
      
      // Sinon, utiliser la dernière position connue
      return await getLastKnownLocation();
    } catch (e) {
      print('❌ Erreur lors de la récupération de la position: $e');
      return null;
    }
  }

  /// Vérifie si la position est dans une zone donnée
  bool isLocationInArea(
    double latitude,
    double longitude,
    double centerLat,
    double centerLng,
    double radiusKm,
  ) {
    final distance = calculateDistance(latitude, longitude, centerLat, centerLng);
    return (distance / 1000) <= radiusKm;
  }

  /// Obtient l'adresse à partir des coordonnées (placeholder)
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    // TODO: Implémenter avec un service de géocodage inverse
    // Pour l'instant, retourner les coordonnées
    return 'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}';
  }

  /// Obtient les coordonnées à partir d'une adresse (placeholder)
  Future<Position?> getCoordinatesFromAddress(String address) async {
    // TODO: Implémenter avec un service de géocodage
    // Pour l'instant, retourner Conakry par défaut
    return Position(
      latitude: AppConfig.defaultLatitude,
      longitude: AppConfig.defaultLongitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }
}
