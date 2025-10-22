/// Validateurs pour les formulaires
class Validators {
  /// Valide un numéro de téléphone guinéen
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est requis';
    }
    
    // Format guinéen: +224 6XX XX XX XX ou 6XX XX XX XX
    final phoneRegex = RegExp(r'^(\+224)?[0-9]{9}$');
    final cleanedPhone = value.replaceAll(' ', '').replaceAll('-', '');
    
    if (!phoneRegex.hasMatch(cleanedPhone)) {
      return 'Numéro de téléphone invalide';
    }
    
    return null;
  }
  
  /// Valide un code OTP
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le code OTP est requis';
    }
    
    if (value.length != 6) {
      return 'Le code OTP doit contenir 6 chiffres';
    }
    
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
      return 'Le code OTP doit contenir uniquement des chiffres';
    }
    
    return null;
  }
  
  /// Valide un nom
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom est requis';
    }
    
    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    
    return null;
  }
  
  /// Valide un email (optionnel)
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email optionnel
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    
    return null;
  }
  
  /// Valide un montant
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le montant est requis';
    }
    
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Montant invalide';
    }
    
    return null;
  }
}

