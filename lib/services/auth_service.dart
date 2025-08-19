import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:batte/services/supabase_service.dart';
import 'package:batte/core/app_config.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._internal();
  
  AuthService._internal();

  final SupabaseService _supabase = SupabaseService.instance;

  /// Inscription avec numéro de téléphone
  Future<AuthResponse?> signUpWithPhone({
    required String phone,
    required String name,
    String? email,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
  }) async {
    try {
      // Créer l'utilisateur dans Supabase Auth
      final response = await _supabase.auth.signUp(
        phone: phone,
        password: _generatePassword(phone), // Mot de passe temporaire
      );

      if (response.user != null) {
        // Créer le profil utilisateur dans la table users
        await _createUserProfile(
          userId: response.user!.id,
          phone: phone,
          name: name,
          email: email,
          latitude: latitude,
          longitude: longitude,
          address: address,
          city: city,
        );

        print('✅ Inscription réussie pour: $phone');
      }

      return response;
    } catch (e) {
      print('❌ Erreur lors de l\'inscription: $e');
      rethrow;
    }
  }

  /// Connexion avec numéro de téléphone
  Future<AuthResponse?> signInWithPhone({
    required String phone,
    required String otp,
  }) async {
    try {
      // Vérifier l'OTP
      final response = await _supabase.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );

      if (response.user != null) {
        print('✅ Connexion réussie pour: $phone');
      }

      return response;
    } catch (e) {
      print('❌ Erreur lors de la connexion: $e');
      rethrow;
    }
  }

  /// Envoi d'OTP par SMS
  Future<void> sendOTP(String phone) async {
    try {
      await _supabase.auth.signInWithOtp(
        phone: phone,
      );
      print('✅ OTP envoyé à: $phone');
    } catch (e) {
      print('❌ Erreur lors de l\'envoi de l\'OTP: $e');
      rethrow;
    }
  }

  /// Inscription avec email et mot de passe personnalisé
  Future<AuthResponse?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? city,
    String? address,
  }) async {
    try {
      // Attendre un peu pour éviter le rate limiting
      await Future.delayed(const Duration(seconds: 2));
      
      // Créer l'utilisateur dans Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Créer le profil utilisateur dans la table users
        await _createUserProfile(
          userId: response.user!.id,
          phone: null, // Pas de téléphone pour l'instant
          name: name,
          email: email,
          latitude: null,
          longitude: null,
          address: address,
          city: city,
        );

        print('✅ Inscription réussie pour: $email');
      }

      return response;
    } catch (e) {
      print('❌ Erreur lors de l\'inscription: $e');
      rethrow;
    }
  }

  /// Connexion avec email
  Future<AuthResponse?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ Connexion réussie pour: $email');
      }

      return response;
    } catch (e) {
      print('❌ Erreur lors de la connexion: $e');
      rethrow;
    }
  }

  /// Création du profil utilisateur dans la table users
  Future<void> _createUserProfile({
    required String userId,
    String? phone,
    required String name,
    String? email,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
  }) async {
    try {
      final userData = {
        'id': userId,
        'phone': phone,
        'name': name,
        'email': email,
        'location_lat': latitude ?? AppConfig.defaultLatitude,
        'location_lng': longitude ?? AppConfig.defaultLongitude,
        'address': address,
        'city': city ?? AppConfig.defaultCity,
        'country': AppConfig.defaultCountry,
        'points': 0,
        'level': 1,
        'balance': 0.00,
        'is_active': true,
        'is_verified': false,
      };

      await _supabase.client
          .from('users')
          .insert(userData);

      print('✅ Profil utilisateur créé pour: $userId');
    } catch (e) {
      print('❌ Erreur lors de la création du profil: $e');
      rethrow;
    }
  }

  /// Génération d'un mot de passe temporaire basé sur le téléphone
  String _generatePassword(String phone) {
    // Utilise les 6 derniers chiffres du téléphone + "Batte2024"
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    final lastDigits = digits.length > 6 ? digits.substring(digits.length - 6) : digits;
    return 'Batte$lastDigits';
  }

  /// Génération d'un mot de passe temporaire basé sur l'email
  String generatePasswordFromEmail(String email) {
    // Utilise les 6 premiers caractères de l'email + "Batte2024"
    final emailPrefix = email.split('@')[0];
    final prefix = emailPrefix.length > 6 ? emailPrefix.substring(0, 6) : emailPrefix;
    return 'Batte$prefix';
  }

  /// Vérification de l'état de l'authentification
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Récupération de la session actuelle
  Session? get currentSession => _supabase.auth.currentSession;

  /// Vérification si l'utilisateur est connecté
  bool get isAuthenticated => _supabase.isAuthenticated;

  /// Récupération de l'utilisateur actuel
  User? get currentUser => _supabase.currentUser;

  /// Déconnexion
  Future<void> signOut() async {
    try {
      await _supabase.signOut();
      print('✅ Déconnexion réussie');
    } catch (e) {
      print('❌ Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  /// Mise à jour du profil utilisateur
  Future<bool> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (address != null) updateData['address'] = address;
      if (city != null) updateData['city'] = city;
      if (latitude != null) updateData['location_lat'] = latitude;
      if (longitude != null) updateData['location_lng'] = longitude;

      if (updateData.isNotEmpty) {
        await _supabase.updateUserProfile(userId, updateData);
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du profil: $e');
      return false;
    }
  }

  /// Récupération du profil utilisateur
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      return await _supabase.getUserProfile(userId);
    } catch (e) {
      print('❌ Erreur lors de la récupération du profil: $e');
      return null;
    }
  }

  /// Vérification de l'existence d'un numéro de téléphone
  Future<bool> isPhoneNumberExists(String phone) async {
    try {
      final response = await _supabase.client
          .from('users')
          .select('id')
          .eq('phone', phone)
          .limit(1);
      
      return response.isNotEmpty;
    } catch (e) {
      print('❌ Erreur lors de la vérification du téléphone: $e');
      return false;
    }
  }

  /// Réinitialisation du mot de passe
  Future<void> resetPassword(String phone) async {
    try {
      await _supabase.auth.resetPasswordForEmail(phone);
      print('✅ Instructions de réinitialisation envoyées à: $phone');
    } catch (e) {
      print('❌ Erreur lors de la réinitialisation du mot de passe: $e');
      rethrow;
    }
  }
}
