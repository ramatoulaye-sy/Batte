import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/storage_service.dart';
import '../services/connectivity_service.dart';
import '../services/outbox_service.dart';
import '../models/outbox_item.dart';
import '../services/outbox_types.dart';

/// Provider pour la gestion du budget
class BudgetProvider with ChangeNotifier {
  
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _stats;
  
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get stats => _stats;
  
  /// Calcule le solde total depuis les transactions
  double get totalBalance {
    return _transactions.fold(0.0, (sum, transaction) {
      if (transaction.type == 'recycling') {
        return sum + transaction.amount; // Ajouter les gains
      } else if (transaction.type == 'withdrawal') {
        return sum - transaction.amount; // Soustraire les retraits
      }
      return sum;
    });
  }
  
  /// Récupère l'historique des transactions
  Future<void> fetchTransactions({int page = 1}) async {
    _isLoading = true;
    _error = null;
    
    try {
      // 1. Charger d'abord depuis le stockage local pour affichage immédiat
      _transactions = StorageService.getTransactions();
      
      // 2. TODO: Synchroniser avec le serveur quand l'API sera disponible
      // final data = await SupabaseService.getTransactionsHistory(page: page);
      // _transactions = data.map((json) => TransactionModel.fromJson(json)).toList();
      
      // 3. Sauvegarder les données serveur (quand disponible)
      // for (var transaction in _transactions) {
      //   await StorageService.saveTransaction(transaction);
      // }
      
      _isLoading = false;
    } catch (e) {
      // En cas d'erreur, garder les données locales
      _error = 'Mode hors ligne - Données locales';
      _isLoading = false;
    }
    
    // Notifier une seule fois à la fin
    notifyListeners();
  }
  
  /// Charge uniquement les données locales
  Future<void> loadLocalTransactions() async {
    _transactions = StorageService.getTransactions();
    // Ne pas appeler notifyListeners() ici pour éviter les erreurs de build
    // notifyListeners() sera appelé par fetchTransactions() si nécessaire
  }
  
  /// Récupère les statistiques
  Future<void> fetchStats() async {
    try {
      // TODO: Implémenter getTransactionsStats dans SupabaseService
      _stats = {};
      notifyListeners();
    } catch (e) {
      print('Erreur de chargement des statistiques: $e');
    }
  }
  
  /// Crée une nouvelle transaction
  Future<bool> createTransaction({
    required double amount,
    required String type,
    String? description,
    String? wasteId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Offline-first: if offline, enqueue to outbox and persist locally
      final connectivity = ConnectivityService();
      if (!connectivity.isOnline) {
        final tempId = 'tx_${DateTime.now().millisecondsSinceEpoch}';
        final userId = StorageService.getUser()?.id ?? 'local';
        final localTx = TransactionModel(
          id: tempId,
          userId: userId,
          amount: amount,
          type: type,
          description: description,
          wasteId: wasteId,
          status: 'pending',
        );

        // Add locally for immediate UX
        _transactions.insert(0, localTx);
        await StorageService.saveTransaction(localTx);
        notifyListeners();

        // Enqueue outbox for later sync
        await OutboxService.enqueue(
          OutboxItem(
            id: 'outbox_${DateTime.now().millisecondsSinceEpoch}',
            type: OutboxTypes.transactionCreate,
            payload: {
              'id': tempId,
              'user_id': userId,
              'amount': amount,
              'type': type,
              'description': description,
              'waste_id': wasteId,
              'date': DateTime.now().toIso8601String(),
            },
          ),
        );

        _isLoading = false;
        notifyListeners();
        // Stats may change locally
        fetchStats();
        return true;
      }

      // TODO: Adapter createTransaction pour Supabase
      final result = {};
      final transaction = TransactionModel.fromJson(result as Map<String, dynamic>);
      
      // Ajouter à la liste
      _transactions.insert(0, transaction);
      
      // Sauvegarder localement
      await StorageService.saveTransaction(transaction);
      
      _isLoading = false;
      notifyListeners();
      
      // Rafraîchir les statistiques
      fetchStats();
      
      return true;
    } catch (e) {
      _error = 'Erreur de création de la transaction';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Obtient le total des revenus
  double get totalIncome {
    return _transactions
        .where((t) => t.isCredit)
        .fold(0, (sum, t) => sum + t.amount);
  }
  
  /// Obtient le total des dépenses
  double get totalExpenses {
    return _transactions
        .where((t) => t.isDebit)
        .fold(0, (sum, t) => sum + t.amount);
  }
  
  /// Obtient les gains du mois en cours (recyclage uniquement)
  double get monthlyEarnings {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;
    
    return _transactions
        .where((t) => 
          t.type == 'recycling' && 
          t.date.month == currentMonth && 
          t.date.year == currentYear
        )
        .fold(0, (sum, t) => sum + t.amount);
  }
  
  /// Obtient le solde
  double get balance {
    return totalIncome - totalExpenses;
  }
  
  /// Obtient les transactions groupées par type
  Map<String, List<TransactionModel>> get transactionsByType {
    final Map<String, List<TransactionModel>> grouped = {};
    
    for (var transaction in _transactions) {
      if (!grouped.containsKey(transaction.type)) {
        grouped[transaction.type] = [];
      }
      grouped[transaction.type]!.add(transaction);
    }
    
    return grouped;
  }
  
  /// Obtient les transactions groupées par mois
  Map<String, List<TransactionModel>> get transactionsByMonth {
    final Map<String, List<TransactionModel>> grouped = {};
    
    for (var transaction in _transactions) {
      final monthKey = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
      
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(transaction);
    }
    
    return grouped;
  }
  
  /// Nettoie l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

