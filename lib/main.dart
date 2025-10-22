import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/supabase_service.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Charger les variables d'environnement
    await dotenv.load(fileName: ".env");
    print('✅ Fichier .env chargé avec succès');
    print('🔑 SUPABASE_URL: ${dotenv.env['SUPABASE_URL']}');
    print('🔑 SUPABASE_ANON_KEY présente: ${dotenv.env['SUPABASE_ANON_KEY'] != null && dotenv.env['SUPABASE_ANON_KEY']!.isNotEmpty}');
  } catch (e) {
    print('❌ Erreur de chargement du fichier .env: $e');
  }
  
  // Initialiser Supabase (remplace le backend Node.js)
  try {
    await SupabaseService.initialize();
    print('✅ Supabase initialisé');
  } catch (e) {
    print('❌ Erreur d\'initialisation de Supabase: $e');
  }
  
  // Initialiser Firebase (pour les notifications push)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialisé');
  } catch (e) {
    print('❌ Erreur d\'initialisation de Firebase: $e');
  }
  
  // Initialiser le stockage local
  await StorageService.init();
  print('✅ Storage local initialisé');
  
  // Initialiser les notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  print('✅ Notifications initialisées');
  
  runApp(const BatteApp());
}
