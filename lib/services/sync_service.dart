import 'dart:async';
import '../providers/waste_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/auth_provider.dart';
import 'connectivity_service.dart';
import 'outbox_service.dart';
import '../models/outbox_item.dart';
import 'outbox_types.dart';
import 'supabase_service.dart';
import 'storage_service.dart';
import '../models/user_model.dart';

/// Service de synchronisation globale
class SyncService {
  SyncService._internal();
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;

  final ConnectivityService _connectivity = ConnectivityService();
  StreamSubscription<bool>? _sub;

  WasteProvider? _wasteProvider;
  BudgetProvider? _budgetProvider;
  AuthProvider? _authProvider;

  final Map<String, Future<void> Function(OutboxItem)> _handlers = {};

  void registerProviders({
    WasteProvider? wasteProvider,
    BudgetProvider? budgetProvider,
    AuthProvider? authProvider,
  }) {
    _wasteProvider = wasteProvider ?? _wasteProvider;
    _budgetProvider = budgetProvider ?? _budgetProvider;
    _authProvider = authProvider ?? _authProvider;
  }

  void registerHandler(String type, Future<void> Function(OutboxItem) handler) {
    _handlers[type] = handler;
  }

  Future<void> initialize() async {
    await _connectivity.initialize();
    await OutboxService.init();
    
    // Register concrete handlers
    registerHandler(OutboxTypes.transactionCreate, _handleTransactionCreate);
    registerHandler(OutboxTypes.profileUpdate, _handleProfileUpdate);
    registerHandler(OutboxTypes.missionClaimReward, _handleMissionClaimReward);
    
    _sub?.cancel();
    _sub = _connectivity.onStatusChange.listen((online) async {
      if (online) {
        await _syncAll();
      }
    });
  }

  Future<void> _syncAll() async {
    // Sync déchets non synchronisés via provider existant
    if (_wasteProvider != null) {
      await _wasteProvider!.syncUnsyncedWastes();
    }

    // Traiter la outbox générique
    final items = OutboxService.getAll();
    for (final item in items) {
      final handler = _handlers[item.type];
      if (handler != null) {
        try {
          await handler(item);
          await OutboxService.remove(item.id);
        } catch (e) {
          // augmenter le compteur de retries et conserver
          await OutboxService.update(item.copyWith(retries: item.retries + 1));
        }
      } else {
        // pas de handler -> on ignore pour le moment
      }
    }
  }

  // Concrete handlers for outbox items
  Future<void> _handleTransactionCreate(OutboxItem item) async {
    try {
      // TODO: Call Supabase API to create transaction
      // For now, just mark as synced locally
      final transactionId = item.payload['id'] as String;
      final transactions = StorageService.getTransactions();
      final transactionIndex = transactions.indexWhere((t) => t.id == transactionId);
      
      if (transactionIndex != -1) {
        final updatedTransaction = transactions[transactionIndex].copyWith(status: 'completed');
        await StorageService.saveTransaction(updatedTransaction);
        
        // Update provider if available
        if (_budgetProvider != null) {
          // Force refresh from storage
          await _budgetProvider!.fetchTransactions();
        }
      }
    } catch (e) {
      print('❌ Erreur sync transaction: $e');
      rethrow;
    }
  }

  Future<void> _handleProfileUpdate(OutboxItem item) async {
    try {
      // TODO: Call Supabase API to update profile
      // For now, just mark as synced locally
      final result = await SupabaseService.upsertUserProfile(
        name: item.payload['name'] ?? '',
        email: item.payload['email'],
        avatarUrl: item.payload['avatar_url'],
        address: item.payload['address'],
      );
      
      // Update local storage
      final user = UserModel.fromJson({
        'id': result['id'],
        'phone': result['phone'],
        'name': result['name'],
        'email': result['email'],
        'balance': result['balance'] ?? 0.0,
        'eco_score': result['eco_score'] ?? 0,
        'level': result['level'] ?? 1,
        'avatar_url': result['avatar_url'],
        'address': result['address'],
        'city': result['city'],
      });
      
      await StorageService.saveUser(user);
      
      // Update provider if available
      if (_authProvider != null) {
        // Force refresh from storage
        _authProvider!.refreshProfile();
      }
    } catch (e) {
      print('❌ Erreur sync profile: $e');
      rethrow;
    }
  }

  Future<void> _handleMissionClaimReward(OutboxItem item) async {
    try {
      // TODO: Call Supabase API to claim mission reward
      // For now, just add to user balance locally
      final reward = item.payload['reward'] as int;
      final currentUser = StorageService.getUser();
      
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          balance: currentUser.balance + reward,
          ecoScore: currentUser.ecoScore + (reward ~/ 100), // 1 eco point per 100 GNF
        );
        
        await StorageService.saveUser(updatedUser);
        
        // Update provider if available
        if (_authProvider != null) {
          // Force refresh from storage
          _authProvider!.refreshProfile();
        }
      }
    } catch (e) {
      print('❌ Erreur sync mission reward: $e');
      rethrow;
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
