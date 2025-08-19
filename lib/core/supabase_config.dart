class SupabaseConfig {
  // Configuration Supabase
  static const String supabaseUrl = 'https://zhtnqugrcubrtjvpdzty.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpodG5xdWdyY3VicnRqdnBkenR5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUyNTk4ODMsImV4cCI6MjA3MDgzNTg4M30.Ci7BHifhK098NZUwRphvRew5T_DCoA17leVg3Z1daaY';
  
  // Tables de la base de données
  static const String usersTable = 'users';
  static const String wasteTransactionsTable = 'waste_transactions';
  static const String collectorsTable = 'collectors';
  static const String transactionsTable = 'transactions';
  static const String ratingsTable = 'ratings';
  static const String stocksTable = 'stocks';
  
  // Endpoints API
  static const String authEndpoint = '/auth/v1';
  static const String restEndpoint = '/rest/v1';
  
  // Configuration des buckets de stockage
  static const String avatarsBucket = 'avatars';
  static const String documentsBucket = 'documents';
  
  // Limites et constantes
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Configuration des notifications
  static const String notificationsTable = 'notifications';
  static const String fcmTokensTable = 'fcm_tokens';
  
  // Configuration de la géolocalisation
  static const double defaultLatitude = 9.5370; // Conakry, Guinée
  static const double defaultLongitude = -13.6785;
  static const double maxDistanceKm = 50.0; // Distance maximale pour les collecteurs
  
  // Configuration des prix (en GNF par kg)
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
  static const int pointsPerKg = 1;
  static const int bonusPointsForRating = 1;
  static const int pointsForReferral = 5;
  
  // Configuration des niveaux
  static const Map<int, int> levelRequirements = {
    1: 0,
    2: 10,
    3: 25,
    4: 50,
    5: 100,
    6: 200,
    7: 400,
    8: 800,
    9: 1600,
    10: 3200,
  };
  
  // Configuration des paiements
  static const List<String> paymentMethods = [
    'orange_money',
    'mtn_money',
    'moov_money',
    'bank_transfer',
    'credit_phone',
  ];
  
  // Configuration des collecteurs
  static const double minCollectorRating = 3.0;
  static const int maxCollectorDistance = 20; // km
  static const int maxCollectorResponseTime = 30; // minutes
  
  // Configuration des entreprises
  static const List<String> wasteTypes = [
    'plastic',
    'organic',
    'glass',
    'metal',
    'paper',
    'electronics',
    'textiles',
    'construction',
  ];
  
  // Configuration des notifications
  static const Map<String, String> notificationTypes = {
    'collector_assigned': 'Collecteur assigné',
    'payment_received': 'Paiement reçu',
    'rating_received': 'Note reçue',
    'level_up': 'Niveau supérieur',
    'new_collection_request': 'Nouvelle demande de collecte',
    'stock_available': 'Stock disponible',
    'order_confirmed': 'Commande confirmée',
  };
  
  // Configuration des erreurs
  static const Map<String, String> errorMessages = {
    'insufficient_balance': 'Solde insuffisant',
    'invalid_location': 'Localisation invalide',
    'collector_unavailable': 'Collecteur indisponible',
    'invalid_waste_type': 'Type de déchet invalide',
    'insufficient_weight': 'Poids insuffisant (minimum 1kg)',
    'payment_failed': 'Échec du paiement',
    'network_error': 'Erreur de connexion',
  };
  
  // Configuration des succès
  static const Map<String, String> successMessages = {
    'waste_sold': 'Déchets vendus avec succès',
    'payment_sent': 'Paiement envoyé',
    'rating_submitted': 'Note soumise',
    'profile_updated': 'Profil mis à jour',
    'collector_selected': 'Collecteur sélectionné',
    'stock_published': 'Stock publié',
    'order_placed': 'Commande passée',
  };
}
