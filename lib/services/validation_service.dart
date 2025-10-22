import '../services/supabase_service.dart';

/// Service de validation pour les champs de formulaire
class ValidationService {
  /// Vérifie si un email est déjà utilisé
  /// Retourne un message d'erreur si l'email existe, null sinon
  static Future<String?> checkEmailAvailability(String email) async {
    try {
      // Normaliser l'email
      final normalizedEmail = email.trim().toLowerCase();
      
      // Vérifier le format
      if (!_isValidEmail(normalizedEmail)) {
        return 'Format d\'email invalide';
      }

      // Vérifier dans la base de données
      final response = await SupabaseService.client
          .from('users')
          .select('id')
          .eq('email', normalizedEmail)
          .maybeSingle();

      if (response != null) {
        return 'Cet email est déjà utilisé';
      }

      return null; // Email disponible
    } catch (e) {
      print('❌ Erreur vérification email: $e');
      return null; // En cas d'erreur, on laisse passer (validation côté serveur)
    }
  }

  /// Vérifie si un nom d'utilisateur est valide
  static String? validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return 'Le nom est requis';
    }

    final trimmed = username.trim();

    if (trimmed.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }

    if (trimmed.length > 50) {
      return 'Le nom est trop long (max 50 caractères)';
    }

    // Vérifier qu'il contient au moins une lettre
    if (!RegExp(r'[a-zA-ZÀ-ÿ]').hasMatch(trimmed)) {
      return 'Le nom doit contenir au moins une lettre';
    }

    return null;
  }

  /// Vérifie si un email est valide (format)
  static String? validateEmailFormat(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'L\'email est requis';
    }

    if (!_isValidEmail(email.trim())) {
      return 'Format d\'email invalide';
    }

    return null;
  }

  /// Vérifie si un mot de passe est valide
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Le mot de passe est requis';
    }

    if (password.length < 6) {
      return 'Minimum 6 caractères';
    }

    if (password.length > 50) {
      return 'Maximum 50 caractères';
    }

    return null;
  }

  /// Vérifie la force du mot de passe et retourne des suggestions
  static Map<String, dynamic> getPasswordStrength(String password) {
    int strength = 0;
    List<String> suggestions = [];

    if (password.isEmpty) {
      return {
        'strength': 0,
        'label': 'Très faible',
        'color': 'red',
        'suggestions': ['Le mot de passe est requis'],
      };
    }

    // Longueur
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (password.length < 8) {
      suggestions.add('Utilisez au moins 8 caractères');
    }

    // Majuscules
    if (RegExp(r'[A-Z]').hasMatch(password)) {
      strength++;
    } else {
      suggestions.add('Ajoutez une majuscule');
    }

    // Minuscules
    if (RegExp(r'[a-z]').hasMatch(password)) {
      strength++;
    } else {
      suggestions.add('Ajoutez une minuscule');
    }

    // Chiffres
    if (RegExp(r'[0-9]').hasMatch(password)) {
      strength++;
    } else {
      suggestions.add('Ajoutez un chiffre');
    }

    // Caractères spéciaux
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strength++;
    } else {
      suggestions.add('Ajoutez un caractère spécial (!@#\$...)');
    }

    String label;
    String color;

    if (strength <= 2) {
      label = 'Très faible';
      color = 'red';
    } else if (strength <= 3) {
      label = 'Faible';
      color = 'orange';
    } else if (strength <= 4) {
      label = 'Moyen';
      color = 'yellow';
    } else if (strength <= 5) {
      label = 'Fort';
      color = 'lightgreen';
    } else {
      label = 'Très fort';
      color = 'green';
    }

    return {
      'strength': strength,
      'label': label,
      'color': color,
      'suggestions': suggestions,
    };
  }

  /// Vérifie si un numéro de téléphone est valide (format Guinée)
  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return null; // Optionnel
    }

    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Format Guinée : +224 XXX XX XX XX ou 6XX XX XX XX
    if (!RegExp(r'^(\+224|00224|224)?[67]\d{8}$').hasMatch(cleaned)) {
      return 'Numéro invalide (ex: +224 620 00 00 00)';
    }

    return null;
  }

  /// Helper: Vérifie le format email
  static bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// Vérifie si un nom de business est valide
  static String? validateBusinessName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Le nom du business est requis';
    }

    if (name.trim().length < 3) {
      return 'Minimum 3 caractères';
    }

    if (name.trim().length > 100) {
      return 'Maximum 100 caractères';
    }

    return null;
  }

  /// Vérifie si un numéro de licence est valide
  static String? validateLicenseNumber(String? license) {
    if (license == null || license.trim().isEmpty) {
      return 'Le numéro de licence est requis';
    }

    if (license.trim().length < 5) {
      return 'Minimum 5 caractères';
    }

    return null;
  }
}

