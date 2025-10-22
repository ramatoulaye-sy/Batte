import 'dart:math';
import 'package:geolocator/geolocator.dart';

/// Service de géolocalisation pour calculer les distances
class GeolocationService {
  /// Obtient la position actuelle de l'utilisateur
  static Future<Position?> getCurrentPosition() async {
    try {
      // Vérifier si les services de localisation sont activés
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Services de localisation désactivés');
        return null;
      }

      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('⚠️ Permission de localisation refusée');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('⚠️ Permission de localisation refusée définitivement');
        return null;
      }

      // Obtenir la position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      print('✅ Position obtenue: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Erreur lors de l\'obtention de la position: $e');
      return null;
    }
  }

  /// Calcule la distance entre deux points géographiques
  /// Retourne la distance en kilomètres
  static double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ) / 1000; // Convertir en km
  }

  /// Calcule la distance en utilisant la formule de Haversine
  /// (Alternative plus précise pour de grandes distances)
  static double calculateDistanceHaversine({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadius = 6371; // Rayon de la Terre en km

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  /// Convertit des degrés en radians
  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  /// Formate une distance pour l'affichage
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)} m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceInKm.toStringAsFixed(0)} km';
    }
  }

  /// Trie une liste de collecteurs par distance
  static List<Map<String, dynamic>> sortCollectorsByDistance({
    required List<Map<String, dynamic>> collectors,
    required double userLatitude,
    required double userLongitude,
  }) {
    // Calculer la distance pour chaque collecteur
    for (var collector in collectors) {
      if (collector['latitude'] != null && collector['longitude'] != null) {
        final distance = calculateDistance(
          startLatitude: userLatitude,
          startLongitude: userLongitude,
          endLatitude: (collector['latitude'] as num).toDouble(),
          endLongitude: (collector['longitude'] as num).toDouble(),
        );
        collector['distance'] = distance;
        collector['formattedDistance'] = formatDistance(distance);
      }
    }

    // Trier par distance
    collectors.sort((a, b) {
      final distanceA = a['distance'] ?? double.infinity;
      final distanceB = b['distance'] ?? double.infinity;
      return distanceA.compareTo(distanceB);
    });

    return collectors;
  }

  /// Vérifie si un collecteur est dans un rayon donné
  static bool isWithinRadius({
    required double userLatitude,
    required double userLongitude,
    required double collectorLatitude,
    required double collectorLongitude,
    required double radiusInKm,
  }) {
    final distance = calculateDistance(
      startLatitude: userLatitude,
      startLongitude: userLongitude,
      endLatitude: collectorLatitude,
      endLongitude: collectorLongitude,
    );
    return distance <= radiusInKm;
  }

  /// Obtient les coordonnées par défaut (Conakry, Guinée)
  static Map<String, double> getDefaultCoordinates() {
    return {
      'latitude': 9.6412,  // Conakry
      'longitude': -13.5784,
    };
  }

  /// Simule des coordonnées de collecteurs pour les tests
  /// (À remplacer par de vraies données de Supabase)
  static List<Map<String, dynamic>> getTestCollectors() {
    final defaultCoords = getDefaultCoordinates();
    
    return [
      {
        'id': '1',
        'name': 'Mamadou Diallo',
        'phone': '+224622000001',
        'location': 'Kaloum, Conakry',
        'latitude': defaultCoords['latitude']! + 0.01,
        'longitude': defaultCoords['longitude']! - 0.01,
        'rating': 4.5,
        'availability': true,
      },
      {
        'id': '2',
        'name': 'Fatoumata Bah',
        'phone': '+224622000002',
        'location': 'Matam, Conakry',
        'latitude': defaultCoords['latitude']! + 0.02,
        'longitude': defaultCoords['longitude']! + 0.01,
        'rating': 5.0,
        'availability': true,
      },
      {
        'id': '3',
        'name': 'Ibrahima Camara',
        'phone': '+224622000003',
        'location': 'Ratoma, Conakry',
        'latitude': defaultCoords['latitude']! - 0.015,
        'longitude': defaultCoords['longitude']! + 0.02,
        'rating': 4.0,
        'availability': false,
      },
      {
        'id': '4',
        'name': 'Aissatou Sylla',
        'phone': '+224622000004',
        'location': 'Dixinn, Conakry',
        'latitude': defaultCoords['latitude']! + 0.03,
        'longitude': defaultCoords['longitude']! - 0.02,
        'rating': 4.8,
        'availability': true,
      },
      {
        'id': '5',
        'name': 'Ousmane Condé',
        'phone': '+224622000005',
        'location': 'Matoto, Conakry',
        'latitude': defaultCoords['latitude']! - 0.025,
        'longitude': defaultCoords['longitude']! - 0.015,
        'rating': 4.2,
        'availability': true,
      },
    ];
  }
}

