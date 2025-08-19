import 'package:flutter/material.dart';

/// Service d'authentification temporaire pour les tests
/// À remplacer par le vrai service Supabase une fois configuré
class MockAuthService {
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;
  MockAuthService._internal();

  // Utilisateurs simulés
  final Map<String, Map<String, dynamic>> _mockUsers = {
    '+22412345678': {
      'phone': '+22412345678',
      'name': 'Sofia Diallo',
      'email': 'sofia@example.com',
      'city': 'Conakry',
      'country': 'Guinée',
      'userType': 'user',
      'points': 9,
      'balance': 4500.0,
      'monthlyWaste': 6.0,
    },
    '+22487654321': {
      'phone': '+22487654321',
      'name': 'Anabelle Camara',
      'email': 'anabelle@example.com',
      'city': 'Conakry',
      'country': 'Guinée',
      'userType': 'user',
      'points': 5,
      'balance': 2500.0,
      'monthlyWaste': 0.25,
    },
    '+22411223344': {
      'phone': '+22411223344',
      'name': 'Victoria Barry',
      'email': 'victoria@example.com',
      'city': 'Conakry',
      'country': 'Guinée',
      'userType': 'user',
      'points': 3,
      'balance': 1500.0,
      'monthlyWaste': 12.0,
    },
  };

  // OTP simulés (en production, ce serait envoyé par SMS)
  final Map<String, String> _mockOTPs = {
    '+22412345678': '123456',
    '+22487654321': '654321',
    '+22411223344': '112233',
  };

  // Utilisateur connecté actuellement
  Map<String, dynamic>? _currentUser;

  /// Vérifie si un numéro de téléphone existe
  Future<bool> checkPhoneExists(String phone) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulation délai réseau
    return _mockUsers.containsKey(phone);
  }

  /// Envoie un OTP (simulé)
  Future<bool> sendOTP(String phone) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulation délai réseau
    
    if (_mockUsers.containsKey(phone)) {
      // En production, l'OTP serait envoyé par SMS
      print('📱 OTP envoyé à $phone: ${_mockOTPs[phone]}');
      return true;
    }
    return false;
  }

  /// Vérifie l'OTP
  Future<Map<String, dynamic>?> verifyOTP(String phone, String otp) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulation délai réseau
    
    if (_mockOTPs[phone] == otp) {
      _currentUser = _mockUsers[phone];
      return _currentUser;
    }
    return null;
  }

  /// Crée un nouvel utilisateur
  Future<Map<String, dynamic>?> createUser({
    required String phone,
    required String name,
    String? email,
    String? city,
    String? country,
    String? userType,
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulation délai réseau
    
    // Vérifier si l'utilisateur existe déjà
    if (_mockUsers.containsKey(phone)) {
      throw Exception('Un utilisateur avec ce numéro existe déjà');
    }

    // Créer le nouvel utilisateur
    final newUser = {
      'phone': phone,
      'name': name,
      'email': email,
      'city': city ?? 'Conakry',
      'country': country ?? 'Guinée',
      'userType': userType ?? 'user',
      'points': 0,
      'balance': 0.0,
      'monthlyWaste': 0.0,
    };

    _mockUsers[phone] = newUser;
    _mockOTPs[phone] = '123456'; // OTP par défaut pour les nouveaux utilisateurs
    
    print('✅ Nouvel utilisateur créé: $name ($phone)');
    return newUser;
  }

  /// Récupère l'utilisateur connecté
  Map<String, dynamic>? get currentUser => _currentUser;

  /// Déconnecte l'utilisateur
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  /// Met à jour le profil utilisateur
  Future<bool> updateUserProfile({
    String? name,
    String? email,
    String? city,
    String? country,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (_currentUser != null) {
      if (name != null) _currentUser!['name'] = name;
      if (email != null) _currentUser!['email'] = email;
      if (city != null) _currentUser!['city'] = city;
      if (country != null) _currentUser!['country'] = country;
      
      // Mettre à jour dans la liste des utilisateurs
      _mockUsers[_currentUser!['phone']] = _currentUser!;
      return true;
    }
    return false;
  }

  /// Met à jour les points et le solde
  Future<bool> updateUserStats({
    int? points,
    double? balance,
    double? monthlyWaste,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_currentUser != null) {
      if (points != null) _currentUser!['points'] = points;
      if (balance != null) _currentUser!['balance'] = balance;
      if (monthlyWaste != null) _currentUser!['monthlyWaste'] = monthlyWaste;
      
      // Mettre à jour dans la liste des utilisateurs
      _mockUsers[_currentUser!['phone']] = _currentUser!;
      return true;
    }
    return false;
  }

  /// Récupère tous les utilisateurs (pour les tests)
  List<Map<String, dynamic>> getAllUsers() {
    return _mockUsers.values.toList();
  }

  /// Récupère les statistiques de l'utilisateur connecté
  Map<String, dynamic> getUserStats() {
    if (_currentUser == null) {
      return {
        'points': 0,
        'balance': 0.0,
        'monthlyWaste': 0.0,
      };
    }
    
    return {
      'points': _currentUser!['points'] ?? 0,
      'balance': _currentUser!['balance'] ?? 0.0,
      'monthlyWaste': _currentUser!['monthlyWaste'] ?? 0.0,
    };
  }
}
