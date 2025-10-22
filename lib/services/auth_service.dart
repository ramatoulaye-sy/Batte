import '../models/user_model.dart';
import 'supabase_service.dart';
import 'storage_service.dart';

/// Service d'authentification utilisant Supabase
class AuthService {
  
  /// Inscription d'un nouvel utilisateur avec email et mot de passe
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Étape 1: S'inscrire avec email et mot de passe
      await SupabaseService.signUpWithEmail(email, password);
      
      // Étape 2: Sauvegarder le nom pour l'utiliser après connexion
      await StorageService.savePendingUserName(name);
      await StorageService.savePendingUserPhone(email); // Réutiliser pour stocker l'email
      
      return {
        'success': true,
        'message': 'Inscription réussie ! Vérifie ton email pour confirmer ton compte.',
      };
    } catch (e) {
      print('❌ Erreur signup: $e');
      return {
        'success': false,
        'error': e.toString().replaceAll('Exception: ', '').replaceAll('AuthApiException: ', ''),
      };
    }
  }
  
  /// Connexion d'un utilisateur existant avec email et mot de passe
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Connexion avec email et mot de passe
      final authResponse = await SupabaseService.signInWithEmail(email, password);
      
      if (authResponse.session == null) {
        throw Exception('Session invalide après connexion');
      }
      
      // Sauvegarder les tokens
      await StorageService.saveAccessToken(authResponse.session!.accessToken);
      await StorageService.saveRefreshToken(authResponse.session!.refreshToken ?? '');
      
      // Récupérer ou créer le profil utilisateur
      var userProfile = await SupabaseService.getUserProfile();
      
      if (userProfile == null) {
        final pendingName = await StorageService.getPendingUserName();
        userProfile = await SupabaseService.upsertUserProfile(
          name: pendingName ?? 'Utilisateur',
          email: email,
        );
        await StorageService.clearPendingUserData();
      }
      
      // Convertir en UserModel et sauvegarder
      final user = UserModel.fromJson({
        'id': userProfile['id'],
        'phone': userProfile['phone'] ?? email,
        'name': userProfile['name'],
        'email': userProfile['email'],
        'balance': userProfile['balance'] ?? 0.0,
        'points': userProfile['points'] ?? 0,
        'level': userProfile['level'] ?? 1,
        'avatar_url': userProfile['avatar_url'],
        'is_verified': userProfile['is_verified'] ?? false,
      });
      
      await StorageService.saveUser(user);
      
      return {
        'success': true,
        'user': user.toJson(),
        'access_token': authResponse.session!.accessToken,
      };
    } catch (e) {
      print('❌ Erreur login: $e');
      return {
        'success': false,
        'error': e.toString().replaceAll('Exception: ', '').replaceAll('AuthApiException: ', ''),
      };
    }
  }
  
  /// Vérification du code OTP (pour Email Auth avec lien magique)
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      // Vérifier l'OTP avec Supabase
      final authResponse = await SupabaseService.verifyOtp(
        email: email,
        token: otp,
      );
      
      if (authResponse.session == null) {
        throw Exception('Session invalide après vérification OTP');
      }
      
      // Sauvegarder les tokens
      await StorageService.saveAccessToken(authResponse.session!.accessToken);
      await StorageService.saveRefreshToken(authResponse.session!.refreshToken ?? '');
      
      // Récupérer ou créer le profil utilisateur dans la table "users"
      var userProfile = await SupabaseService.getUserProfile();
      
      if (userProfile == null) {
        // Créer le profil pour un nouvel utilisateur
        final pendingName = await StorageService.getPendingUserName();
        
        userProfile = await SupabaseService.upsertUserProfile(
          name: pendingName ?? 'Utilisateur',
          email: email,
        );
        
        // Nettoyer les données temporaires
        await StorageService.clearPendingUserData();
      }
      
      // Convertir en UserModel et sauvegarder
      final user = UserModel.fromJson({
        'id': userProfile['id'],
        'phone': userProfile['phone'],
        'name': userProfile['name'],
        'email': userProfile['email'],
        'balance': userProfile['balance'] ?? 0.0,
        'points': userProfile['points'] ?? 0,
        'level': userProfile['level'] ?? 1,
        'avatar_url': userProfile['avatar_url'],
        'is_verified': userProfile['is_verified'] ?? false,
      });
      
      await StorageService.saveUser(user);
      
      return {
        'success': true,
        'user': user.toJson(),
        'access_token': authResponse.session!.accessToken,
      };
    } catch (e) {
      print('❌ Erreur verify OTP: $e');
      return {
        'success': false,
        'error': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }
  
  /// Renvoyer le lien magique par email
  Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      await SupabaseService.signInWithOtp(email);
      
      return {
        'success': true,
        'message': 'Lien magique renvoyé à $email',
      };
    } catch (e) {
      print('❌ Erreur resend OTP: $e');
      return {
        'success': false,
        'error': e.toString().replaceAll('Exception: ', '').replaceAll('AuthApiException: ', ''),
      };
    }
  }
  
  /// Déconnexion
  Future<void> logout() async {
    try {
      await SupabaseService.signOut();
    } catch (e) {
      print('❌ Erreur logout: $e');
    } finally {
      // Toujours nettoyer les données locales
      await StorageService.clearAll();
    }
  }
  
  /// Vérifie si l'utilisateur est connecté
  bool isLoggedIn() {
    return SupabaseService.currentUser != null;
  }
  
  /// Récupère l'utilisateur actuel depuis le stockage local
  UserModel? getCurrentUser() {
    return StorageService.getUser();
  }
  
  /// Récupère le profil utilisateur depuis Supabase
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final userProfile = await SupabaseService.getUserProfile();
      
      if (userProfile == null) {
        throw Exception('Profil utilisateur introuvable');
      }
      
      // Mettre à jour le stockage local
      final user = UserModel.fromJson({
        'id': userProfile['id'],
        'phone': userProfile['phone'],
        'name': userProfile['name'],
        'email': userProfile['email'],
        'balance': userProfile['balance'] ?? 0.0,
        'points': userProfile['points'] ?? 0,
        'level': userProfile['level'] ?? 1,
        'avatar_url': userProfile['avatar_url'],
        'is_verified': userProfile['is_verified'] ?? false,
      });
      
      await StorageService.saveUser(user);
      
      return {
        'success': true,
        'user': user.toJson(),
      };
    } catch (e) {
      print('❌ Erreur get user profile: $e');
      return {
        'success': false,
        'error': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }
  
  /// Met à jour le profil utilisateur
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final userProfile = await SupabaseService.upsertUserProfile(
        name: data['name'] ?? '',
        email: data['email'],
        phone: data['phone'],
        avatarUrl: data['avatar_url'],
        locationLat: data['location_lat'],
        locationLng: data['location_lng'],
        address: data['address'],
        city: data['city'],
        bio: data['bio'],
      );
      
      // Mettre à jour le stockage local
      final user = UserModel.fromJson({
        'id': userProfile['id'],
        'phone': userProfile['phone'],
        'name': userProfile['name'],
        'email': userProfile['email'],
        'balance': userProfile['balance'] ?? 0.0,
        'points': userProfile['points'] ?? 0,
        'level': userProfile['level'] ?? 1,
        'avatar_url': userProfile['avatar_url'],
        'address': userProfile['address'],
        'bio': userProfile['bio'],
        'is_verified': userProfile['is_verified'] ?? false,
      });
      
      await StorageService.saveUser(user);
      
      return {
        'success': true,
        'user': user.toJson(),
      };
    } catch (e) {
      print('❌ Erreur update profile: $e');
      return {
        'success': false,
        'error': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }
}
