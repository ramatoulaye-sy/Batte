import 'package:firebase_messaging/firebase_messaging.dart';
import 'supabase_service.dart';

/// Service de gestion des notifications push
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  
  /// Initialise le service de notifications
  Future<void> initialize() async {
    try {
      // Demander la permission
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('Permission accordée pour les notifications');
        
        // Obtenir le token FCM
        _fcmToken = await _fcm.getToken();
        print('FCM Token: $_fcmToken');
        
        // Configurer les handlers
        _setupMessageHandlers();
      } else {
        print('Permission refusée pour les notifications');
      }
    } catch (e) {
      print('Erreur d\'initialisation des notifications: $e');
    }
  }
  
  /// Configure les gestionnaires de messages
  void _setupMessageHandlers() {
    // Message reçu en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message reçu en foreground: ${message.notification?.title}');
      _handleMessage(message);
    });
    
    // Message reçu en background (app en arrière-plan)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message ouvert depuis le background: ${message.notification?.title}');
      _handleMessage(message);
    });
    
    // Vérifier si l'app a été ouverte depuis une notification
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App ouverte depuis une notification: ${message.notification?.title}');
        _handleMessage(message);
      }
    });
    
    // Écouter les changements de token
    _fcm.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      print('Nouveau FCM Token: $newToken');
      // TODO: Envoyer le nouveau token au backend
    });
  }
  
  /// Gère un message reçu
  void _handleMessage(RemoteMessage message) {
    // Extraire les données
    final notification = message.notification;
    final data = message.data;
    
    if (notification != null) {
      // Afficher une notification locale (optionnel)
      _showLocalNotification(
        title: notification.title ?? 'Battè',
        body: notification.body ?? '',
        payload: data,
      );
    }
    
    // Gérer les actions selon le type de notification
    if (data['type'] != null) {
      _handleNotificationType(data['type'], data);
    }
  }
  
  /// Affiche une notification locale
  void _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) {
    // TODO: Implémenter avec flutter_local_notifications
    print('Notification: $title - $body');
  }

  /// Affiche une notification locale (méthode statique pour usage externe)
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    // TODO: Implémenter avec flutter_local_notifications
    print('📢 Notification: $title - $body');
    // Pour l'instant, on affiche juste dans la console
    // Quand flutter_local_notifications sera ajouté, on pourra afficher une vraie notification
  }
  
  /// Gère les différents types de notifications
  void _handleNotificationType(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'waste_collected':
        // Navigation vers l'historique de recyclage
        print('Déchet collecté: ${data['weight']}kg');
        break;
      case 'new_job':
        // Navigation vers les offres d'emploi
        print('Nouvelle offre d\'emploi disponible');
        break;
      case 'balance_updated':
        // Actualiser le solde
        print('Solde mis à jour: ${data['balance']} GNF');
        break;
      case 'education_new':
        // Navigation vers l'éducation
        print('Nouveau contenu éducatif disponible');
        break;
      default:
        print('Type de notification non géré: $type');
    }
  }
  
  /// S'abonne à un topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      print('Abonné au topic: $topic');
    } catch (e) {
      print('Erreur d\'abonnement au topic $topic: $e');
    }
  }
  
  /// Se désabonne d'un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      print('Désabonné du topic: $topic');
    } catch (e) {
      print('Erreur de désabonnement du topic $topic: $e');
    }
  }
  
  /// Récupère les notifications depuis l'API
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final notifications = await SupabaseService.getNotifications();
      return List<Map<String, dynamic>>.from(notifications);
    } catch (e) {
      print('Erreur de récupération des notifications: $e');
      return [];
    }
  }
  
  /// Marque une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      await SupabaseService.markNotificationAsRead(notificationId);
    } catch (e) {
      print('Erreur de marquage de la notification: $e');
    }
  }
}

/// Handler pour les messages en background (doit être top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Message reçu en background: ${message.notification?.title}');
}

