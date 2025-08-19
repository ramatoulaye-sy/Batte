import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:batte/core/app_config.dart';

class SupabaseService {
	static SupabaseService? _instance;
	static SupabaseService get instance => _instance ??= SupabaseService._internal();
	
	SupabaseService._internal();

	late final SupabaseClient _client;

	// Getters pour accéder aux services
	SupabaseClient get client => _client;
	GoTrueClient get auth => _client.auth;
	SupabaseStorageClient get storage => _client.storage;

	/// Initialise la connexion Supabase
	Future<void> initialize() async {
		try {
			// Utiliser la configuration directe
			final url = AppConfig.supabaseUrl;
			final anonKey = AppConfig.supabaseAnonKey;
			// Initialiser Supabase
			await Supabase.initialize(
				url: url,
				anonKey: anonKey,
				debug: true, // À désactiver en production
			);
			_client = Supabase.instance.client;
			print('✅ Supabase initialisé avec succès');
			print('🔗 URL: $url');
		} catch (e) {
			print('❌ Erreur lors de l\'initialisation de Supabase: $e');
			rethrow;
		}
	}

	/// Vérifie si l'utilisateur est connecté
	bool get isAuthenticated => _client.auth.currentUser != null;

	/// Récupère l'utilisateur actuel
	User? get currentUser => _client.auth.currentUser;

	/// Récupère l'ID de l'utilisateur actuel
	String? get currentUserId => _client.auth.currentUser?.id;

	/// Déconnexion
	Future<void> signOut() async {
		try {
			await _client.auth.signOut();
			print('✅ Déconnexion réussie');
		} catch (e) {
			print('❌ Erreur lors de la déconnexion: $e');
			rethrow;
		}
	}

	/// Test de connexion à la base de données
	Future<bool> testConnection() async {
		try {
			// Test simple : récupérer les types de déchets
			final response = await _client
					.from('waste_types')
					.select('*')
					.limit(1);
			print('✅ Connexion à la base de données réussie');
			print('📊 Types de déchets trouvés: ${response.length}');
			return true;
		} catch (e) {
			print('❌ Erreur de connexion à la base de données: $e');
			return false;
		}
	}

	/// Récupère les informations de l'utilisateur
	Future<Map<String, dynamic>?> getUserProfile(String userId) async {
		try {
			final response = await _client
					.from('users')
					.select('*')
					.eq('id', userId)
					.single();
			return response;
		} catch (e) {
			print('❌ Erreur lors de la récupération du profil: $e');
			return null;
		}
	}

	/// Met à jour le profil utilisateur
	Future<bool> updateUserProfile(String userId, Map<String, dynamic> data) async {
		try {
			await _client
					.from('users')
					.update(data)
					.eq('id', userId);
			print('✅ Profil utilisateur mis à jour');
			return true;
		} catch (e) {
			print('❌ Erreur lors de la mise à jour du profil: $e');
			return false;
		}
	}

	/// Récupère les types de déchets
	Future<List<Map<String, dynamic>>> getWasteTypes() async {
		try {
			final response = await _client
					.from('waste_types')
					.select('*')
					.eq('is_active', true)
					.order('name');
			return List<Map<String, dynamic>>.from(response);
		} catch (e) {
			print('❌ Erreur lors de la récupération des types de déchets: $e');
			return [];
		}
	}

	/// Crée une nouvelle transaction de déchets
	Future<String?> createWasteTransaction(Map<String, dynamic> transactionData) async {
		try {
			final response = await _client
					.from('waste_transactions')
					.insert(transactionData)
					.select('id')
					.single();
			print('✅ Transaction de déchets créée: ${response['id']}');
			return response['id'];
		} catch (e) {
			print('❌ Erreur lors de la création de la transaction: $e');
			return null;
		}
	}

	/// Met à jour le statut d'une transaction
	Future<bool> updateTransactionStatus(String transactionId, String status) async {
		try {
			await _client
					.from('waste_transactions')
					.update({'status': status})
					.eq('id', transactionId);
			print('✅ Statut de transaction mis à jour: $transactionId -> $status');
			return true;
		} catch (e) {
			print('❌ Erreur lors de la mise à jour du statut: $e');
			return false;
		}
	}

	/// Assigne un collecteur à une transaction
	Future<bool> assignCollectorToTransaction(String transactionId, String collectorId) async {
		try {
			await _client
					.from('waste_transactions')
					.update({'collector_id': collectorId, 'status': 'assigned'})
					.eq('id', transactionId);
			print('✅ Collecteur assigné à la transaction: $transactionId -> $collectorId');
			return true;
		} catch (e) {
			print('❌ Erreur lors de l\'assignation du collecteur: $e');
			return false;
		}
	}

	/// Récupère l'historique des transactions d'un utilisateur
	Future<List<Map<String, dynamic>>> getUserTransactions(String userId) async {
		try {
			final response = await _client
					.from('waste_transactions')
					.select('*, waste_types(*)')
					.eq('user_id', userId)
					.order('created_at', ascending: false);
			return List<Map<String, dynamic>>.from(response);
		} catch (e) {
			print('❌ Erreur lors de la récupération des transactions: $e');
			return [];
		}
	}

	/// Récupère les N dernières transactions d'un utilisateur
	Future<List<Map<String, dynamic>>> getRecentUserTransactions(String userId, {int limit = 10}) async {
		try {
			final response = await _client
					.from('waste_transactions')
					.select('*, waste_types(*)')
					.eq('user_id', userId)
					.order('created_at', ascending: false)
					.limit(limit);
			return List<Map<String, dynamic>>.from(response);
		} catch (e) {
			print('❌ Erreur lors de la récupération des transactions récentes: $e');
			return [];
		}
	}

	/// Récupère les collecteurs disponibles dans une zone
	Future<List<Map<String, dynamic>>> getAvailableCollectors(
		double lat, 
		double lng, 
		int radiusKm
	) async {
		try {
			// Requête simplifiée - à améliorer avec une vraie géolocalisation
			final response = await _client
					.from('collectors')
					.select('*, users(*)')
					.eq('is_available', true)
					.limit(10);
			return List<Map<String, dynamic>>.from(response);
		} catch (e) {
			print('❌ Erreur lors de la récupération des collecteurs: $e');
			return [];
		}
	}

	/// Récupère les collectes d'un utilisateur
	Future<List<Map<String, dynamic>>> getUserCollections(String userId) async {
		try {
			final response = await _client
					.from('collections')
					.select('collector_id')
					.eq('user_id', userId);
			return List<Map<String, dynamic>>.from(response);
		} catch (e) {
			print('❌ Erreur lors de la récupération des collectes utilisateur: $e');
			return [];
		}
	}

	/// Récupère les notes attribuées par un utilisateur
	Future<List<Map<String, dynamic>>> getUserRatings(String userId) async {
		try {
			final response = await _client
					.from('ratings')
					.select('rating')
					.eq('user_id', userId);
			return List<Map<String, dynamic>>.from(response);
		} catch (e) {
			print('❌ Erreur lors de la récupération des notations utilisateur: $e');
			return [];
		}
	}

	/// Upload un avatar utilisateur vers le bucket 'avatars' et retourne l'URL publique
	Future<String?> uploadUserAvatar({
		required String userId,
		required Uint8List bytes,
		required String fileExtension,
	}) async {
		try {
			final String path = 'users/$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
			await storage.from('avatars').uploadBinary(
					path,
					bytes,
					fileOptions: const FileOptions(
						upsert: true,
						contentType: 'image/*',
					),
				);
			final String publicUrl = storage.from('avatars').getPublicUrl(path);
			return publicUrl;
		} catch (e) {
			print('❌ Erreur lors de l\'upload de l\'avatar: $e');
			return null;
		}
	}

	/// Crée une transaction de retrait
	Future<String?> createWithdrawalTransaction(Map<String, dynamic> data) async {
		try {
			final response = await _client
					.from('withdrawal_transactions')
					.insert(data)
					.select('id')
					.single();
			print('✅ Transaction de retrait créée: ${response['id']}');
			return response['id'] as String;
		} catch (e) {
			print('❌ Erreur lors de la création de la transaction de retrait: $e');
			return null;
		}
	}

	/// Crée une transaction d'épargne
	Future<String?> createSavingTransaction(Map<String, dynamic> data) async {
		try {
			final response = await _client
					.from('saving_transactions')
					.insert(data)
					.select('id')
					.single();
			print('✅ Transaction d\'épargne créée: ${response['id']}');
			return response['id'] as String;
		} catch (e) {
			print('❌ Erreur lors de la création de la transaction d\'épargne: $e');
			return null;
		}
	}

	/// Met à jour le solde d'un utilisateur
	Future<bool> updateUserBalance(String userId, double newBalance) async {
		try {
			await _client
					.from('users')
					.update({'balance': newBalance})
					.eq('id', userId);
			print('✅ Solde utilisateur mis à jour: $newBalance GNF');
			return true;
		} catch (e) {
			print('❌ Erreur lors de la mise à jour du solde: $e');
			return false;
		}
	}
}
