import 'package:flutter/material.dart';
import '../models/waste_model.dart';
import '../models/transaction_model.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';
import '../core/utils/helpers.dart';

/// Provider pour la gestion des déchets
class WasteProvider with ChangeNotifier {
  List<WasteModel> _wastes = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _stats;
  
  List<WasteModel> get wastes => _wastes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get stats => _stats;
  
  /// Récupère l'historique des déchets
  Future<void> fetchWastes({int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // 1. Charger d'abord depuis le stockage local pour affichage immédiat
      _wastes = StorageService.getWastes();
      notifyListeners(); // Afficher immédiatement les données locales
      
      // 2. Ensuite essayer de synchroniser avec le serveur (en arrière-plan)
      try {
        final data = await SupabaseService.getWastesHistory(page: page);
        final serverWastes = data.map((json) => WasteModel.fromJson(json)).toList();
        
        // Fusionner les données locales et serveur (priorité aux locales)
        final Map<String, WasteModel> localWastesMap = {};
        for (var waste in _wastes) {
          localWastesMap[waste.id] = waste;
        }
        
        // Ajouter les données serveur qui ne sont pas déjà locales
        for (var serverWaste in serverWastes) {
          if (!localWastesMap.containsKey(serverWaste.id)) {
            localWastesMap[serverWaste.id] = serverWaste.copyWith(synced: true);
            await StorageService.saveWaste(serverWaste.copyWith(synced: true));
          }
        }
        
        // Mettre à jour la liste avec les données fusionnées
        _wastes = localWastesMap.values.toList();
        _wastes.sort((a, b) => b.date.compareTo(a.date)); // Trier par date
      } catch (serverError) {
        print('Erreur de synchronisation serveur: $serverError');
        // Garder les données locales en cas d'erreur serveur
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // En cas d'erreur générale, garder les données locales
      _error = 'Mode hors ligne - Données locales';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Charge uniquement les données locales
  Future<void> loadLocalWastes() async {
    _wastes = StorageService.getWastes();
    // Ne pas appeler notifyListeners() ici pour éviter les erreurs de build
    // notifyListeners() sera appelé par fetchWastes() si nécessaire
  }
  
  /// Récupère les statistiques
  Future<void> fetchStats() async {
    try {
      _stats = await SupabaseService.getWastesStats();
      notifyListeners();
    } catch (e) {
      print('Erreur de chargement des statistiques: $e');
    }
  }
  
  /// Ajoute un nouveau déchet
  Future<bool> addWaste({
    required String type,
    required double weight,
    String? binDeviceId,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Calculer la valeur
      final value = Helpers.calculateWasteValue(type, weight);
      
      // Créer le déchet localement d'abord
      final waste = WasteModel(
        id: Helpers.generateUniqueId(),
        userId: StorageService.getUser()?.id ?? '',
        type: type,
        weight: weight,
        value: value,
        binDeviceId: binDeviceId,
        synced: false,
        notes: notes,
      );
      
      // Ajouter immédiatement à la liste locale
      _wastes.insert(0, waste);
      await StorageService.saveWaste(waste);
      
      // Créer une transaction pour le budget
      await _createTransactionForWaste(waste);
      
      _isLoading = false;
      notifyListeners(); // Afficher immédiatement
      
      // Synchroniser en arrière-plan
      _syncWasteInBackground(waste);
      
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout du déchet';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Synchronise un déchet en arrière-plan
  Future<void> _syncWasteInBackground(WasteModel waste) async {
    try {
      // Trouver l'ID du type de déchet depuis la base
      final wasteTypes = await SupabaseService.getWasteTypes();
      final wasteType = wasteTypes.firstWhere(
        (wt) => wt['name'].toString().toLowerCase() == waste.type.toLowerCase(),
        orElse: () => wasteTypes.isNotEmpty ? wasteTypes.first : {'id': 'default', 'name': waste.type},
      );
      
      final result = await SupabaseService.createWasteTransaction(
        wasteTypeId: wasteType['id'],
        weightKg: waste.weight,
        amountGnf: waste.value,
        notes: waste.notes,
      );
      
      // Marquer comme synchronisé
      final syncedWaste = waste.copyWith(
        id: result['id'],
        synced: true,
      );
      
      // Mettre à jour dans la liste
      final index = _wastes.indexWhere((w) => w.id == waste.id);
      if (index != -1) {
        _wastes[index] = syncedWaste;
        await StorageService.saveWaste(syncedWaste);
        notifyListeners();
      }
      
      // Rafraîchir les statistiques
      fetchStats();
    } catch (e) {
      print('Erreur de synchronisation du déchet: $e');
      // Le déchet reste en local avec synced: false
    }
  }
  
  /// Synchronise les déchets non synchronisés
  Future<void> syncUnsyncedWastes() async {
    final unsyncedWastes = StorageService.getUnsyncedWastes();
    
    for (var wasteItem in unsyncedWastes) {
      try {
        final wasteTypes = await SupabaseService.getWasteTypes();
        final wasteType = wasteTypes.firstWhere(
          (wt) => wt['name'].toString().toLowerCase() == wasteItem.type.toLowerCase(),
          orElse: () => wasteTypes.isNotEmpty ? wasteTypes.first : {'id': 'default', 'name': wasteItem.type},
        );
        
        await SupabaseService.createWasteTransaction(
          wasteTypeId: wasteType['id'],
          weightKg: wasteItem.weight,
          amountGnf: wasteItem.value,
          notes: wasteItem.notes,
        );
        
        await StorageService.saveWaste(wasteItem.copyWith(synced: true));
      } catch (e) {
        print('Erreur de synchronisation pour ${wasteItem.id}: $e');
      }
    }
    
    fetchWastes();
  }
  
  /// Obtient le total du poids recyclé
  double get totalWeight {
    return _wastes.fold(0, (sum, waste) => sum + waste.weight);
  }
  
  /// Obtient la valeur totale gagnée
  double get totalValue {
    return _wastes.fold(0, (sum, waste) => sum + waste.value);
  }
  
  /// Obtient les déchets groupés par type
  Map<String, List<WasteModel>> get wastesByType {
    final Map<String, List<WasteModel>> grouped = {};
    
    for (var waste in _wastes) {
      if (!grouped.containsKey(waste.type)) {
        grouped[waste.type] = [];
      }
      grouped[waste.type]!.add(waste);
    }
    
    return grouped;
  }
  
  /// Crée une transaction pour un déchet recyclé
  Future<void> _createTransactionForWaste(WasteModel waste) async {
    try {
      final transaction = TransactionModel(
        id: 'waste_${waste.id}',
        userId: waste.userId,
        amount: waste.value,
        type: 'recycling',
        description: 'Recyclage: ${waste.type} (${waste.weight}kg)',
        wasteId: waste.id,
        status: 'completed',
        date: waste.date,
      );
      
      await StorageService.saveTransaction(transaction);
    } catch (e) {
      print('Erreur création transaction: $e');
    }
  }

  /// Supprime un déchet
  Future<bool> deleteWaste(String wasteId) async {
    try {
      // Supprimer de la liste locale
      _wastes.removeWhere((waste) => waste.id == wasteId);
      
      // Supprimer du stockage local
      await StorageService.deleteWaste(wasteId);
      
      // Supprimer la transaction associée
      await StorageService.deleteTransaction('waste_$wasteId');
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression: $e');
      return false;
    }
  }

  /// Nettoie l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

