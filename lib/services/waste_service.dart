import 'package:batte/services/supabase_service.dart';
import 'package:batte/core/app_config.dart';

class WasteService {
  static WasteService? _instance;
  static WasteService get instance => _instance ??= WasteService._internal();
  
  WasteService._internal();

  final SupabaseService _supabase = SupabaseService.instance;

  /// Récupère tous les types de déchets disponibles
  Future<List<Map<String, dynamic>>> getWasteTypes() async {
    try {
      return await _supabase.getWasteTypes();
    } catch (e) {
      print('❌ Erreur lors de la récupération des types de déchets: $e');
      return [];
    }
  }

  /// Récupère un type de déchet par ID
  Future<Map<String, dynamic>?> getWasteTypeById(String wasteTypeId) async {
    try {
      final response = await _supabase.client
          .from('waste_types')
          .select('*')
          .eq('id', wasteTypeId)
          .single();
      
      return response;
    } catch (e) {
      print('❌ Erreur lors de la récupération du type de déchet: $e');
      return null;
    }
  }

  /// Calcule le prix total pour un ensemble de déchets
  double calculateTotalPrice(Map<String, double> wasteQuantities) {
    double totalPrice = 0.0;
    
    // Prix par kg pour chaque type de déchet
    final pricesPerKg = {
      'plastic': 150.0,    // Plastique
      'organic': 100.0,    // Organique
      'glass': 200.0,      // Verre
      'metal': 300.0,      // Métal
      'paper': 120.0,      // Papier
      'electronics': 500.0, // Électronique
      'textiles': 80.0,    // Textiles
    };

    wasteQuantities.forEach((type, quantity) {
      final price = pricesPerKg[type] ?? 100.0; // Prix par défaut
      totalPrice += quantity * price;
    });

    return totalPrice;
  }

  /// Calcule les points gagnés pour un ensemble de déchets
  int calculatePoints(Map<String, double> wasteQuantities) {
    int totalPoints = 0;
    
    wasteQuantities.forEach((type, quantity) {
      // 1 point par kg de base
      int basePoints = quantity.floor();
      
      // Bonus selon le type de déchet
      switch (type) {
        case 'electronics':
        case 'metal':
          basePoints += 1; // Bonus pour les déchets précieux
          break;
        case 'glass':
          basePoints += 1; // Bonus pour le verre
          break;
        case 'plastic':
          basePoints += 1; // Bonus pour le plastique
          break;
      }
      
      totalPoints += basePoints;
    });

    return totalPoints;
  }

  /// Crée une nouvelle transaction de déchets
  Future<String?> createWasteTransaction({
    required String userId,
    required Map<String, double> wasteQuantities,
    String? notes,
  }) async {
    try {
      final totalWeight = wasteQuantities.values.reduce((a, b) => a + b);
      final totalPrice = calculateTotalPrice(wasteQuantities);
      final totalPoints = calculatePoints(wasteQuantities);

      // Créer la transaction principale
      final transactionData = {
        'user_id': userId,
        'waste_type_id': null, // Sera mis à jour pour chaque type
        'weight_kg': totalWeight,
        'amount_gnf': totalPrice,
        'points_earned': totalPoints,
        'status': 'pending',
        'notes': notes,
      };

      final transactionId = await _supabase.createWasteTransaction(transactionData);
      
      if (transactionId != null) {
        // Créer les détails pour chaque type de déchet
        await _createWasteTransactionDetails(transactionId, wasteQuantities);
        
        // Mettre à jour les points de l'utilisateur
        await _updateUserPoints(userId, totalPoints);
        
        print('✅ Transaction de déchets créée: $transactionId');
        return transactionId;
      }
      
      return null;
    } catch (e) {
      print('❌ Erreur lors de la création de la transaction: $e');
      return null;
    }
  }

  /// Crée les détails d'une transaction de déchets
  Future<void> _createWasteTransactionDetails(
    String transactionId,
    Map<String, double> wasteQuantities,
  ) async {
    try {
      for (final entry in wasteQuantities.entries) {
        final wasteType = entry.key;
        final quantity = entry.value;
        
        // Trouver l'ID du type de déchet
        final wasteTypeData = await _getWasteTypeByName(wasteType);
        if (wasteTypeData != null) {
          final detailData = {
            'transaction_id': transactionId,
            'waste_type_id': wasteTypeData['id'],
            'weight_kg': quantity,
            'amount_gnf': _calculatePriceForType(wasteType, quantity),
          };
          
          await _supabase.client
              .from('waste_transaction_details')
              .insert(detailData);
        }
      }
    } catch (e) {
      print('❌ Erreur lors de la création des détails: $e');
      rethrow;
    }
  }

  /// Récupère un type de déchet par nom
  Future<Map<String, dynamic>?> _getWasteTypeByName(String wasteType) async {
    try {
      final response = await _supabase.client
          .from('waste_types')
          .select('*')
          .eq('category', wasteType)
          .eq('is_active', true)
          .single();
      
      return response;
    } catch (e) {
      print('❌ Erreur lors de la récupération du type de déchet: $e');
      return null;
    }
  }

  /// Calcule le prix pour un type spécifique de déchet
  double _calculatePriceForType(String wasteType, double quantity) {
    final pricesPerKg = {
      'plastic': 150.0,
      'organic': 100.0,
      'glass': 200.0,
      'metal': 300.0,
      'paper': 120.0,
      'electronics': 500.0,
      'textiles': 80.0,
    };

    final price = pricesPerKg[wasteType] ?? 100.0;
    return quantity * price;
  }

  /// Met à jour les points de l'utilisateur
  Future<void> _updateUserPoints(String userId, int pointsToAdd) async {
    try {
      // Récupérer les points actuels
      final currentProfile = await _supabase.getUserProfile(userId);
      if (currentProfile != null) {
        final currentPoints = currentProfile['points'] ?? 0;
        final newPoints = currentPoints + pointsToAdd;
        final newLevel = _calculateLevel(newPoints);
        
        // Mettre à jour les points et le niveau
        await _supabase.updateUserProfile(userId, {
          'points': newPoints,
          'level': newLevel,
        });
        
        print('✅ Points mis à jour: $currentPoints → $newPoints (Niveau $newLevel)');
      }
    } catch (e) {
      print('❌ Erreur lors de la mise à jour des points: $e');
    }
  }

  /// Calcule le niveau basé sur les points
  int _calculateLevel(int points) {
    if (points < 10) return 1;
    if (points < 25) return 2;
    if (points < 50) return 3;
    if (points < 100) return 4;
    if (points < 200) return 5;
    if (points < 400) return 6;
    if (points < 800) return 7;
    if (points < 1600) return 8;
    if (points < 3200) return 9;
    return 10;
  }

  /// Récupère l'historique des transactions d'un utilisateur
  Future<List<Map<String, dynamic>>> getUserTransactionHistory(String userId) async {
    try {
      return await _supabase.getUserTransactions(userId);
    } catch (e) {
      print('❌ Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }

  /// Récupère les statistiques de déchets d'un utilisateur
  Future<Map<String, dynamic>> getUserWasteStats(String userId) async {
    try {
      final transactions = await _supabase.getUserTransactions(userId);
      
      double totalWeight = 0.0;
      double totalEarnings = 0.0;
      int totalPoints = 0;
      Map<String, double> wasteByType = {};
      
      for (final transaction in transactions) {
        totalWeight += transaction['weight_kg'] ?? 0.0;
        totalEarnings += transaction['amount_gnf'] ?? 0.0;
        totalPoints += (transaction['points_earned'] ?? 0) as int;
        
        // Compter par type de déchet
        final wasteType = transaction['waste_types']?['category'] ?? 'unknown';
        wasteByType[wasteType] = (wasteByType[wasteType] ?? 0.0) + (transaction['weight_kg'] ?? 0.0);
      }
      
      return {
        'totalWeight': totalWeight,
        'totalEarnings': totalEarnings,
        'totalPoints': totalPoints,
        'wasteByType': wasteByType,
        'transactionCount': transactions.length,
      };
    } catch (e) {
      print('❌ Erreur lors de la récupération des statistiques: $e');
      return {};
    }
  }

  /// Vérifie si une quantité de déchets est suffisante pour la vente
  bool isWasteQuantitySufficient(Map<String, double> wasteQuantities) {
    final totalWeight = wasteQuantities.values.reduce((a, b) => a + b);
    return totalWeight >= AppConfig.minWasteWeightForSale;
  }

  /// Récupère les collecteurs disponibles dans une zone
  Future<List<Map<String, dynamic>>> getAvailableCollectors(
    double latitude,
    double longitude,
    int radiusKm,
  ) async {
    try {
      return await _supabase.getAvailableCollectors(latitude, longitude, radiusKm);
    } catch (e) {
      print('❌ Erreur lors de la récupération des collecteurs: $e');
      return [];
    }
  }

  /// Crée une demande de collecte
  Future<String?> createCollectionRequest({
    required String userId,
    required String transactionId,
    required String collectorId,
    String? notes,
  }) async {
    try {
      final collectionData = {
        'user_id': userId,
        'collector_id': collectorId,
        'waste_transaction_id': transactionId,
        'status': 'requested',
        'notes': notes,
      };

      final response = await _supabase.client
          .from('collections')
          .insert(collectionData)
          .select('id')
          .single();
      
      print('✅ Demande de collecte créée: ${response['id']}');
      return response['id'];
    } catch (e) {
      print('❌ Erreur lors de la création de la demande de collecte: $e');
      return null;
    }
  }
}
