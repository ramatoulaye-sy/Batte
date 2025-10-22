import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service Supabase centralisé pour toute l'application
/// Remplace complètement le backend Node.js
class SupabaseService {
  static SupabaseClient? _client;
  
  /// Initialise Supabase (à appeler dans main.dart)
  static Future<void> initialize() async {
    try {
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      
      print('🔍 Tentative d\'initialisation Supabase...');
      print('📍 URL: $supabaseUrl');
      print('🔑 Key length: ${supabaseAnonKey.length} caractères');
      
      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw Exception('❌ SUPABASE_URL ou SUPABASE_ANON_KEY manquant dans .env');
      }
      
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      
      _client = Supabase.instance.client;
      print('✅ Supabase initialisé avec succès');
      print('✅ Client créé: ${_client != null}');
    } catch (e, stackTrace) {
      print('❌ Erreur détaillée initialisation Supabase: $e');
      print('📋 Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Client Supabase global
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('❌ Supabase non initialisé. Appelez SupabaseService.initialize() d\'abord.');
    }
    return _client!;
  }
  
  /// Utilisateur actuellement connecté
  static User? get currentUser => client.auth.currentUser;
  
  /// ID de l'utilisateur connecté
  static String? get currentUserId => currentUser?.id;
  
  /// Session actuelle
  static Session? get currentSession => client.auth.currentSession;
  
  /// Token d'accès JWT
  static String? get accessToken => currentSession?.accessToken;
  
  // ===== AUTHENTICATION =====
  
  /// Inscription avec email (envoie un lien magique)
  static Future<void> signUpWithEmail(String email, String password) async {
    try {
      await client.auth.signUp(
        email: email,
        password: password,
      );
      print('✅ Inscription réussie avec email: $email');
    } catch (e) {
      print('❌ Erreur signup: $e');
      rethrow;
    }
  }
  
  /// Connexion avec email et mot de passe
  static Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('✅ Connexion réussie avec email: $email');
      return response;
    } catch (e) {
      print('❌ Erreur login: $e');
      rethrow;
    }
  }
  
  /// Envoyer un lien magique de connexion par email (sans mot de passe)
  static Future<void> signInWithOtp(String email) async {
    try {
      await client.auth.signInWithOtp(
        email: email,
      );
      print('✅ Lien magique envoyé à: $email');
    } catch (e) {
      print('❌ Erreur envoi lien magique: $e');
      rethrow;
    }
  }
  
  /// Vérifier le code OTP reçu par email
  static Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    try {
      return await client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );
    } catch (e) {
      print('❌ Erreur vérification OTP: $e');
      rethrow;
    }
  }
  
  /// Déconnexion
  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
      print('✅ Déconnexion réussie');
    } catch (e) {
      print('❌ Erreur déconnexion: $e');
      rethrow;
    }
  }
  
  // ===== USER PROFILE =====
  
  /// Créer ou mettre à jour le profil utilisateur dans la table "users"
  static Future<Map<String, dynamic>> upsertUserProfile({
    required String name,
    String? phone,
    String? email,
    String? avatarUrl,
    double? locationLat,
    double? locationLng,
    String? address,
    String? city,
    String? bio,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('Utilisateur non connecté');
      
      final data = {
        'id': userId,
        'name': name,
        if (email != null) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        if (locationLat != null) 'location_lat': locationLat,
        if (locationLng != null) 'location_lng': locationLng,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (bio != null) 'bio': bio,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      final response = await client
          .from('users')
          .upsert(
            data,
            onConflict: 'id',
          )
          .select()
          .single();
      
      return response;
    } catch (e) {
      print('❌ Erreur upsert user profile: $e');
      rethrow;
    }
  }
  
  /// Récupérer le profil utilisateur
  static Future<Map<String, dynamic>?> getUserProfile([String? userId]) async {
    try {
      final id = userId ?? currentUserId;
      if (id == null) return null;
      
      final response = await client
          .from('users')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      return response;
    } catch (e) {
      print('❌ Erreur get user profile: $e');
      return null;
    }
  }
  
  /// Récupérer le solde de l'utilisateur
  static Future<double> getUserBalance([String? userId]) async {
    try {
      final profile = await getUserProfile(userId);
      return (profile?['balance'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      print('❌ Erreur get user balance: $e');
      return 0.0;
    }
  }
  
  // ===== WASTE TRANSACTIONS =====
  
  /// Créer une transaction de déchets
  static Future<Map<String, dynamic>> createWasteTransaction({
    required String wasteTypeId,
    required double weightKg,
    required double amountGnf,
    int pointsEarned = 0,
    String status = 'completed',
    String? notes,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('Utilisateur non connecté');
      
      final data = {
        'user_id': userId,
        'waste_type_id': wasteTypeId,
        'weight_kg': weightKg,
        'amount_gnf': amountGnf,
        'points_earned': pointsEarned,
        'status': status,
        if (notes != null) 'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final response = await client
          .from('waste_transactions')
          .insert(data)
          .select()
          .single();
      
      // Mettre à jour le solde et les points de l'utilisateur
      await client.rpc('update_user_balance_and_points', params: {
        'user_id': userId,
        'amount': amountGnf,
        'points': pointsEarned,
      });
      
      return response;
    } catch (e) {
      print('❌ Erreur create waste transaction: $e');
      rethrow;
    }
  }
  
  /// Récupérer l'historique des déchets
  static Future<List<Map<String, dynamic>>> getWastesHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) return [];
      
      final response = await client
          .from('waste_transactions')
          .select('*, waste_types(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur get wastes history: $e');
      return [];
    }
  }
  
  /// Récupérer les statistiques des déchets
  static Future<Map<String, dynamic>> getWastesStats() async {
    try {
      final userId = currentUserId;
      if (userId == null) return {};
      
      final response = await client.rpc('get_waste_stats', params: {
        'p_user_id': userId,
      });
      
      return response as Map<String, dynamic>;
    } catch (e) {
      print('❌ Erreur get wastes stats: $e');
      return {
        'total_weight_kg': 0,
        'total_amount_gnf': 0,
        'total_transactions': 0,
      };
    }
  }
  
  /// Récupérer les types de déchets disponibles
  static Future<List<Map<String, dynamic>>> getWasteTypes() async {
    try {
      final response = await client
          .from('waste_types')
          .select()
          .eq('is_active', true)
          .order('name');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur get waste types: $e');
      return [];
    }
  }
  
  // ===== EDUCATION =====
  
  /// Récupérer le contenu éducatif
  static Future<List<Map<String, dynamic>>> getEducationContent({
    String? type,
    String? language,
  }) async {
    try {
      var query = client.from('education_content').select();
      
      if (type != null) query = query.eq('type', type);
      if (language != null) query = query.eq('language', language);
      
      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur get education content: $e');
      return [];
    }
  }
  
  // ===== TRANSACTIONS (Budget) =====

  /// Traiter un retrait avec déduction automatique du solde
  /// Cette fonction appelle une fonction PostgreSQL qui:
  /// 1. Vérifie que le solde est suffisant
  /// 2. Crée la transaction
  /// 3. Déduit le montant du solde
  static Future<Map<String, dynamic>> processWithdrawal({
    required double amount,
    String? description,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('Utilisateur non connecté');
      
      print('🔄 Traitement du retrait: $amount GNF pour user $userId');
      
      // Appeler la fonction PostgreSQL qui gère tout automatiquement
      final response = await client.rpc('process_withdrawal', params: {
        'p_user_id': userId,
        'p_amount': amount,
        'p_description': description ?? 'Retrait de gains',
      });
      
      print('✅ Retrait traité avec succès: $response');
      
      // Retourner le résultat sous forme de Map
      if (response is Map) {
        return Map<String, dynamic>.from(response);
      } else {
        return {'success': true, 'data': response};
      }
    } catch (e) {
      print('❌ Erreur process withdrawal: $e');
      rethrow;
    }
  }

  /// Créer une transaction générique (ex: withdrawal, savings, reward)
  /// ⚠️ Cette méthode ne met PAS à jour le solde automatiquement
  /// Pour un retrait, utilisez plutôt processWithdrawal()
  static Future<Map<String, dynamic>> createTransaction({
    required double amount,
    required String type, // 'withdrawal' | 'savings' | 'reward' | 'recycling'
    String? description,
    String status = 'completed',
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('Utilisateur non connecté');

      final payload = {
        'user_id': userId,
        'amount': amount,
        'type': type,
        if (description != null) 'description': description,
        'status': status,
        'date': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('transactions')
          .insert(payload)
          .select()
          .single();

      return response;
    } catch (e) {
      print('❌ Erreur create transaction: $e');
      rethrow;
    }
  }

  /// Enregistrer la progression éducative
  static Future<void> saveEducationProgress({
    required String contentId,
    required bool completed,
    int? score,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) return;
      
      await client.from('user_education_progress').upsert({
        'user_id': userId,
        'content_id': contentId,
        'completed': completed,
        'score': score,
        'completed_at': completed ? DateTime.now().toIso8601String() : null,
      });
    } catch (e) {
      print('❌ Erreur save education progress: $e');
    }
  }
  
  // ===== JOBS =====
  
  /// Récupérer les offres d'emploi
  static Future<List<Map<String, dynamic>>> getJobs({
    String? type,
    String? category,
  }) async {
    try {
      var query = client.from('jobs').select();
      
      if (type != null) query = query.eq('type', type);
      if (category != null) query = query.eq('category', category);
      
      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur get jobs: $e');
      return [];
    }
  }
  
  /// Créer une offre d'emploi ou de service
  static Future<Map<String, dynamic>> createJob({
    required String title,
    required String description,
    String? location,
    String? type,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('Utilisateur non connecté');
      
      final data = {
        'user_id': userId,
        'title': title,
        'description': description,
        if (location != null) 'location': location,
        if (type != null) 'type': type,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final response = await client
          .from('jobs')
          .insert(data)
          .select()
          .single();
      
      return response;
    } catch (e) {
      print('❌ Erreur create job: $e');
      rethrow;
    }
  }
  
  // ===== USER PROFILES =====
  
  /// Vérifier si l'utilisateur a un profil spécifique
  static Future<bool> hasProfile(String profileType) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return false;
      
      final response = await client.rpc('user_has_profile', params: {
        'p_user_id': userId,
        'p_profile_type': profileType,
      });
      
      return response == true;
    } catch (e) {
      print('❌ Erreur check profile: $e');
      return false;
    }
  }
  
  /// Obtenir tous les profils de l'utilisateur
  static Future<List<String>> getUserProfiles() async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return [];
      
      final response = await client.rpc('get_user_profiles', params: {
        'p_user_id': userId,
      });
      
      if (response is List && response.isNotEmpty) {
        return response
            .map((p) => p['profile_type'] as String)
            .toList();
      }
      
      return [];
    } catch (e) {
      print('❌ Erreur get profiles: $e');
      return [];
    }
  }
  
  /// Créer un profil pour l'utilisateur
  static Future<bool> createProfile(String profileType) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw Exception('Non connecté');
      
      await client.from('user_profiles').insert({
        'user_id': userId,
        'profile_type': profileType,
        'is_active': true,
      });
      
      return true;
    } catch (e) {
      print('❌ Erreur create profile: $e');
      return false;
    }
  }
  
  // ===== COLLECTORS =====
  
  /// Récupérer les collecteurs disponibles
  static Future<List<Map<String, dynamic>>> getCollectors() async {
    try {
      // Appel de la fonction RPC qui retourne les collecteurs disponibles
      final response = await client.rpc('get_collectors');
      
      // La fonction retourne un JSON array
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      
      return [];
    } catch (e) {
      print('❌ Erreur get collectors: $e');
      return [];
    }
  }
  
  /// Récupérer les collecteurs à proximité
  static Future<List<Map<String, dynamic>>> getNearbyCollectors({
    required double lat,
    required double lng,
    double radiusKm = 10.0,
  }) async {
    try {
      final response = await client.rpc('get_nearby_collectors', params: {
        'user_lat': lat,
        'user_lng': lng,
        'radius_km': radiusKm,
      });
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur get nearby collectors: $e');
      return [];
    }
  }
  
  // ===== NOTIFICATIONS =====
  
  /// Récupérer les notifications
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final userId = currentUserId;
      if (userId == null) return [];
      
      final response = await client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur get notifications: $e');
      return [];
    }
  }
  
  /// Marquer une notification comme lue
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      print('❌ Erreur mark notification as read: $e');
    }
  }
  
  // ===== STORAGE (pour fichiers/images) =====
  
  /// Uploader un fichier (image, audio, vidéo)
  static Future<String?> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
  }) async {
    try {
      await client.storage.from(bucket).uploadBinary(path, fileBytes);
      
      final publicUrl = client.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('❌ Erreur upload file: $e');
      return null;
    }
  }
  
  /// Supprimer un fichier
  static Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await client.storage.from(bucket).remove([path]);
    } catch (e) {
      print('❌ Erreur delete file: $e');
    }
  }

  // ===== SERVICES MODULE =====

  /// Créer un profil prestataire
  static Future<Map<String, dynamic>> createServiceProvider({
    String? bio,
    List<String>? skills,
    List<String>? zones,
    List<String>? languages,
  }) async {
    try {
      final response = await client.rpc('create_service_provider', params: {
        'p_bio': bio,
        'p_skills': skills,
        'p_zones': zones,
        'p_languages': languages ?? ['fr'],
      });
      
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('❌ Erreur create service provider: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Créer une offre de service
  static Future<Map<String, dynamic>> createServiceOffer({
    required String title,
    required String description,
    required String category,
    double? price,
    String priceUnit = 'fixed',
    String? location,
    int coverageRadiusKm = 5,
    Map<String, dynamic>? availabilityRules,
    List<String>? photos,
    DateTime? expiresAt,
  }) async {
    try {
      final response = await client.rpc('create_service_offer', params: {
        'p_title': title,
        'p_description': description,
        'p_category': category,
        'p_price': price,
        'p_price_unit': priceUnit,
        'p_location': location,
        'p_coverage_radius_km': coverageRadiusKm,
        'p_availability_rules': availabilityRules,
        'p_photos': photos,
        'p_expires_at': expiresAt?.toIso8601String(),
      });
      
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('❌ Erreur create service offer: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Créer une demande de service
  static Future<Map<String, dynamic>> createServiceRequest({
    required String title,
    required String description,
    required String category,
    double? budget,
    String? location,
    List<String>? requirements,
    String? offerId,
    DateTime? scheduledAt,
  }) async {
    try {
      final response = await client.rpc('create_service_request', params: {
        'p_title': title,
        'p_description': description,
        'p_category': category,
        'p_budget': budget,
        'p_location': location,
        'p_requirements': requirements,
        'p_offer_id': offerId,
        'p_scheduled_at': scheduledAt?.toIso8601String(),
      });
      
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('❌ Erreur create service request: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Rechercher des services
  static Future<List<Map<String, dynamic>>> searchServices({
    String? query,
    String? category,
    String? location,
    double? maxPrice,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await client.rpc('search_services', params: {
        'p_query': query,
        'p_category': category,
        'p_location': location,
        'p_max_price': maxPrice,
        'p_limit': limit,
        'p_offset': offset,
      });
      
      final result = Map<String, dynamic>.from(response);
      if (result['success'] == true) {
        return List<Map<String, dynamic>>.from(result['services'] ?? []);
      }
      return [];
    } catch (e) {
      print('❌ Erreur search services: $e');
      return [];
    }
  }

  /// Accepter une demande de service
  static Future<Map<String, dynamic>> acceptServiceRequest(String requestId) async {
    try {
      final response = await client.rpc('accept_service_request', params: {
        'p_request_id': requestId,
      });
      
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('❌ Erreur accept service request: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Marquer un service comme terminé
  static Future<Map<String, dynamic>> completeServiceRequest(String requestId) async {
    try {
      final response = await client.rpc('complete_service_request', params: {
        'p_request_id': requestId,
      });
      
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('❌ Erreur complete service request: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Envoyer un message dans une demande
  static Future<Map<String, dynamic>> sendServiceMessage({
    required String requestId,
    required String content,
    List<String>? attachments,
  }) async {
    try {
      final response = await client.rpc('send_service_message', params: {
        'p_request_id': requestId,
        'p_content': content,
        'p_attachments': attachments,
      });
      
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('❌ Erreur send service message: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Noter un service
  static Future<Map<String, dynamic>> rateService({
    required String requestId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await client.rpc('rate_service', params: {
        'p_request_id': requestId,
        'p_rating': rating,
        'p_comment': comment,
      });
      
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('❌ Erreur rate service: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Récupérer les offres d'un prestataire
  static Future<List<Map<String, dynamic>>> getProviderOffers() async {
    try {
      final response = await client
          .from('service_offers_with_provider')
          .select('*')
          .eq('provider_user_id', currentUser?.id ?? '')
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur get provider offers: $e');
      return [];
    }
  }

  /// Récupérer les demandes d'un client
  static Future<List<Map<String, dynamic>>> getClientRequests() async {
    try {
      final response = await client
          .from('service_requests_with_client')
          .select('*')
          .eq('client_id', currentUser?.id ?? '')
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur get client requests: $e');
      return [];
    }
  }

  /// Récupérer les messages d'une demande
  static Future<List<Map<String, dynamic>>> getRequestMessages(String requestId) async {
    try {
      final response = await client
          .from('service_messages')
          .select('*')
          .eq('request_id', requestId)
          .order('created_at', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur get request messages: $e');
      return [];
    }
  }
}

