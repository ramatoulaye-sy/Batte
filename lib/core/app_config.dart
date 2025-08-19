/// Configuration de l'application Batte
class AppConfig {
  // Configuration Supabase
  static const String supabaseUrl = 'https://zhtnqugrcubrtjvpdzty.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpodG5xdWdyY3VicnRqdnBkenR5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyNTk4ODMsImV4cCI6MjA3MDgzNTg4M30.Ci7BHifhK098NZUwRphvRew5T_DCoA17leVg3Z1daaY';

  // Configuration de l'application
  static const String appName = 'Batte';
  static const String appVersion = '1.0.0';
  static const String environment = 'development';

  // Configuration des services
  static const int geolocationTimeout = 10000;
  static const int bluetoothScanTimeout = 30000;
  static const int qrScanTimeout = 10000;

  // Configuration des déchets
  static const double minWasteWeightForSale = 1.0; // kg minimum pour vendre
  static const double maxWasteWeightPerTransaction = 100.0; // kg maximum par transaction

  // Configuration des prix (GNF par kg)
  static const Map<String, double> wastePrices = {
    'plastic': 150.0,
    'organic': 100.0,
    'glass': 200.0,
    'metal': 300.0,
    'paper': 120.0,
    'electronics': 500.0,
    'textiles': 80.0,
  };

  // Configuration des points
  static const int basePointsPerKg = 1;
  static const Map<String, int> bonusPoints = {
    'electronics': 1,
    'metal': 1,
    'glass': 1,
    'plastic': 1,
  };

  // Configuration de la géolocalisation
  static const double defaultLatitude = 9.5370; // Conakry
  static const double defaultLongitude = -13.6785;
  static const String defaultCity = 'Conakry';
  static const String defaultCountry = 'Guinée';

  // Configuration des notifications
  static const int notificationTimeout = 5000; // ms
  static const int maxRetryAttempts = 3;

  // Configuration de la sécurité
  static const int sessionTimeout = 3600000; // 1 heure en ms
  static const int maxLoginAttempts = 5;
  static const int lockoutDuration = 900000; // 15 minutes en ms
}
