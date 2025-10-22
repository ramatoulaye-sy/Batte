import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/connectivity_service.dart';
import '../services/outbox_service.dart';
import '../services/storage_service.dart';
import '../models/outbox_item.dart';
import '../services/outbox_types.dart';

/// Provider pour la gestion de l'authentification
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  
  AuthProvider() {
    _loadUser();
  }
  
  /// Charge l'utilisateur depuis le stockage local
  void _loadUser() {
    _user = _authService.getCurrentUser();
    notifyListeners();
  }
  
  /// Inscription d'un nouvel utilisateur avec email et mot de passe
  Future<bool> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final result = await _authService.signup(email: email, password: password, name: name);
    
    _isLoading = false;
    
    if (result['success']) {
      notifyListeners();
      return true;
    } else {
      _error = result['error'] ?? 'Erreur d\'inscription';
      notifyListeners();
      return false;
    }
  }
  
  /// Connexion d'un utilisateur avec email et mot de passe
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final result = await _authService.login(email, password);
    
    _isLoading = false;
    
    if (result['success']) {
      _user = _authService.getCurrentUser();
      notifyListeners();
      return true;
    } else {
      _error = result['error'] ?? 'Erreur de connexion';
      notifyListeners();
      return false;
    }
  }
  
  /// Vérification du code OTP (Email Auth)
  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final result = await _authService.verifyOtp(email: email, otp: otp);
    
    _isLoading = false;
    
    if (result['success']) {
      _user = _authService.getCurrentUser();
      notifyListeners();
      return true;
    } else {
      _error = result['error'] ?? 'Code OTP invalide';
      notifyListeners();
      return false;
    }
  }
  
  /// Renvoyer le lien magique par email
  Future<bool> resendOtp(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final result = await _authService.resendOtp(email);
    
    _isLoading = false;
    
    if (result['success']) {
      notifyListeners();
      return true;
    } else {
      _error = result['error'] ?? 'Erreur d\'envoi du lien';
      notifyListeners();
      return false;
    }
  }
  
  /// Rafraîchir le profil utilisateur
  Future<void> refreshProfile() async {
    // Essayer de récupérer depuis le serveur
    final result = await _authService.getUserProfile();
    if (result['success']) {
      _user = _authService.getCurrentUser();
      notifyListeners();
    } else {
      // Si échec serveur, recharger depuis le stockage local
      final localUser = StorageService.getUser();
      if (localUser != null) {
        _user = localUser;
        notifyListeners();
      }
    }
  }
  
  /// Recharger le profil depuis le stockage local uniquement
  Future<void> refreshFromLocal() async {
    print('🔄 refreshFromLocal appelé');
    final localUser = StorageService.getUser();
    print('💾 Utilisateur local récupéré: ${localUser?.name}, ${localUser?.phone}, ${localUser?.address}, ${localUser?.bio}');
    if (localUser != null) {
      _user = localUser;
      notifyListeners();
      print('✅ refreshFromLocal terminé - notifyListeners() appelé');
    } else {
      print('❌ Aucun utilisateur local trouvé');
    }
  }
  
  /// Mettre à jour le profil utilisateur
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? bio,
    String? avatarUrl,
  }) async {
    print('🔧 updateProfile appelé avec: name=$name, phone=$phone, address=$address, bio=$bio');
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (bio != null) data['bio'] = bio;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    
    print('📦 Données à sauvegarder: $data');
    
    // Offline-first: if offline, enqueue to outbox and update locally
    final connectivity = ConnectivityService();
    if (!connectivity.isOnline) {
      print('📱 Mode offline détecté');
      // Update local user immediately for UX
      if (_user != null) {
        print('👤 Utilisateur avant: ${_user!.name}, ${_user!.phone}, ${_user!.address}, ${_user!.bio}');
        _user = _user!.copyWith(
          name: name ?? _user!.name,
          phone: phone ?? _user!.phone,
          address: address ?? _user!.address,
          bio: bio ?? _user!.bio,
          avatarUrl: avatarUrl ?? _user!.avatarUrl,
        );
        print('👤 Utilisateur après: ${_user!.name}, ${_user!.phone}, ${_user!.address}, ${_user!.bio}');
        
        // Sauvegarder immédiatement en local
        await StorageService.saveUser(_user!);
        print('💾 Utilisateur sauvegardé en local');
        notifyListeners();
        print('🔄 notifyListeners() appelé');
      }

      // Enqueue outbox for later sync
      await OutboxService.enqueue(
        OutboxItem(
          id: 'profile_${DateTime.now().millisecondsSinceEpoch}',
          type: OutboxTypes.profileUpdate,
          payload: data,
        ),
      );

      _isLoading = false;
      notifyListeners();
      print('✅ updateProfile terminé (offline)');
      return true;
    }
    
    print('🌐 Mode online détecté');
    final result = await _authService.updateProfile(data);
    print('📡 Résultat serveur: $result');
    
    _isLoading = false;
    
    if (result['success']) {
      _user = _authService.getCurrentUser();
      print('👤 Utilisateur après serveur: ${_user?.name}, ${_user?.phone}, ${_user?.address}, ${_user?.bio}');
      
      // Sauvegarder en local après succès en ligne
      if (_user != null) {
        await StorageService.saveUser(_user!);
        print('💾 Utilisateur sauvegardé en local (online)');
      }
      
      notifyListeners();
      print('✅ updateProfile terminé (online)');
      return true;
    } else {
      _error = result['error'] ?? 'Erreur de mise à jour';
      notifyListeners();
      print('❌ Erreur updateProfile: $_error');
      return false;
    }
  }
  
  /// Déconnexion
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
  
  /// Nettoie l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

