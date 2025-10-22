/// Constantes générales de l'application
class AppConstants {
  // App Info
  static const String appName = 'Battè';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Transformez vos déchets en argent';
  
  // Supported Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'fr', 'name': 'Français', 'nativeName': 'Français'},
    {'code': 'sus', 'name': 'Soussou', 'nativeName': 'Sɔsɔɛ'},
    {'code': 'ff', 'name': 'Peulh', 'nativeName': 'Fulfulde'},
    {'code': 'man', 'name': 'Malinké', 'nativeName': 'Maninka'},
  ];
  
  // Currency
  static const String currency = 'GNF';
  static const String currencySymbol = 'GNF';
  
  // Waste Types
  static const List<Map<String, dynamic>> wasteTypes = [
    {
      'id': 'plastic',
      'name': 'Plastique',
      'icon': '♻️',
      'pricePerKg': 1500, // GNF
      'color': '#3498DB',
    },
    {
      'id': 'paper',
      'name': 'Papier',
      'icon': '📄',
      'pricePerKg': 800,
      'color': '#E67E22',
    },
    {
      'id': 'metal',
      'name': 'Métal',
      'icon': '🔩',
      'pricePerKg': 2000,
      'color': '#95A5A6',
    },
    {
      'id': 'glass',
      'name': 'Verre',
      'icon': '🍾',
      'pricePerKg': 500,
      'color': '#1ABC9C',
    },
    {
      'id': 'organic',
      'name': 'Organique',
      'icon': '🍂',
      'pricePerKg': 300,
      'color': '#27AE60',
    },
  ];
  
  // Local Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserData = 'user_data';
  static const String keyLanguage = 'language';
  static const String keyVoiceEnabled = 'voice_enabled';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyBinDeviceId = 'bin_device_id';
  
  // Bluetooth
  static const String binServiceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String binCharacteristicUuid = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Points System
  static const int pointsPerKg = 10;
  static const int pointsPerQuiz = 50;
  static const int pointsPerVideo = 25;
  
  // Education Content Types
  static const String contentTypeVideo = 'video';
  static const String contentTypeAudio = 'audio';
  static const String contentTypeQuiz = 'quiz';
  
  // Transaction Types
  static const String transactionTypeRecycling = 'recycling';
  static const String transactionTypeWithdrawal = 'withdrawal';
  static const String transactionTypeSavings = 'savings';
  static const String transactionTypeReward = 'reward';
}

