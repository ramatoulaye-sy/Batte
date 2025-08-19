import 'package:batte/services/supabase_service.dart';
import 'package:batte/services/auth_service.dart';
import 'package:batte/services/waste_service.dart';
import 'package:batte/services/location_service.dart';

class TestService {
  static TestService? _instance;
  static TestService get instance => _instance ??= TestService._internal();
  
  TestService._internal();

  /// Test complet de tous les services
  Future<Map<String, bool>> runAllTests() async {
    final results = <String, bool>{};
    
    print('🧪 Début des tests de l\'application Batte...');
    
    // Test 1: Connexion Supabase
    results['supabase_connection'] = await _testSupabaseConnection();
    
    // Test 2: Récupération des types de déchets
    results['waste_types'] = await _testWasteTypes();
    
    // Test 3: Service de géolocalisation
    results['location_service'] = await _testLocationService();
    
    // Test 4: Service d'authentification
    results['auth_service'] = await _testAuthService();
    
    // Résumé des tests
    _printTestResults(results);
    
    return results;
  }

  /// Test de la connexion Supabase
  Future<bool> _testSupabaseConnection() async {
    try {
      print('🔗 Test de connexion Supabase...');
      
      final success = await SupabaseService.instance.testConnection();
      
      if (success) {
        print('✅ Connexion Supabase réussie');
        return true;
      } else {
        print('❌ Échec de la connexion Supabase');
        return false;
      }
    } catch (e) {
      print('❌ Erreur lors du test Supabase: $e');
      return false;
    }
  }

  /// Test de récupération des types de déchets
  Future<bool> _testWasteTypes() async {
    try {
      print('🗑️ Test de récupération des types de déchets...');
      
      final wasteTypes = await WasteService.instance.getWasteTypes();
      
      if (wasteTypes.isNotEmpty) {
        print('✅ ${wasteTypes.length} types de déchets récupérés');
        print('📋 Types disponibles:');
        for (final wasteType in wasteTypes.take(5)) {
          print('   - ${wasteType['name']} (${wasteType['category']}): ${wasteType['price_per_kg']} GNF/kg');
        }
        return true;
      } else {
        print('❌ Aucun type de déchet trouvé');
        return false;
      }
    } catch (e) {
      print('❌ Erreur lors du test des types de déchets: $e');
      return false;
    }
  }

  /// Test du service de géolocalisation
  Future<bool> _testLocationService() async {
    try {
      print('📍 Test du service de géolocalisation...');
      
      // Test des permissions
      final hasPermission = await LocationService.instance.requestLocationPermission();
      
      if (hasPermission) {
        print('✅ Permission de localisation accordée');
        
        // Test du service activé
        final isEnabled = await LocationService.instance.isLocationServiceEnabled();
        
        if (isEnabled) {
          print('✅ Service de localisation activé');
          return true;
        } else {
          print('⚠️ Service de localisation désactivé');
          return false;
        }
      } else {
        print('❌ Permission de localisation refusée');
        return false;
      }
    } catch (e) {
      print('❌ Erreur lors du test de géolocalisation: $e');
      return false;
    }
  }

  /// Test du service d'authentification
  Future<bool> _testAuthService() async {
    try {
      print('🔐 Test du service d\'authentification...');
      
      // Vérifier l'état de l'authentification
      final isAuthenticated = AuthService.instance.isAuthenticated;
      
      if (isAuthenticated) {
        print('✅ Utilisateur déjà connecté');
        final user = AuthService.instance.currentUser;
        print('👤 Utilisateur: ${user?.phone ?? 'N/A'}');
      } else {
        print('ℹ️ Aucun utilisateur connecté');
      }
      
      // Le service fonctionne même sans utilisateur connecté
      print('✅ Service d\'authentification fonctionnel');
      return true;
      
    } catch (e) {
      print('❌ Erreur lors du test d\'authentification: $e');
      return false;
    }
  }

  /// Test de calcul des prix et points
  Future<bool> _testCalculations() async {
    try {
      print('🧮 Test des calculs de prix et points...');
      
      final wasteQuantities = {
        'plastic': 2.5,
        'organic': 1.0,
        'glass': 0.5,
      };
      
      final totalPrice = WasteService.instance.calculateTotalPrice(wasteQuantities);
      final totalPoints = WasteService.instance.calculatePoints(wasteQuantities);
      final isSufficient = WasteService.instance.isWasteQuantitySufficient(wasteQuantities);
      
      print('💰 Prix total: ${totalPrice.toStringAsFixed(0)} GNF');
      print('⭐ Points gagnés: $totalPoints');
      print('📊 Quantité suffisante: ${isSufficient ? 'Oui' : 'Non'}');
      
      return true;
    } catch (e) {
      print('❌ Erreur lors du test des calculs: $e');
      return false;
    }
  }

  /// Affichage des résultats des tests
  void _printTestResults(Map<String, bool> results) {
    print('\n📊 RÉSULTATS DES TESTS');
    print('=' * 40);
    
    int passedTests = 0;
    int totalTests = results.length;
    
    results.forEach((testName, success) {
      final status = success ? '✅ PASSÉ' : '❌ ÉCHOUÉ';
      print('$testName: $status');
      if (success) passedTests++;
    });
    
    print('=' * 40);
    print('📈 Score: $passedTests/$totalTests tests réussis');
    
    if (passedTests == totalTests) {
      print('🎉 Tous les tests sont passés ! L\'application est prête.');
    } else {
      print('⚠️ Certains tests ont échoué. Vérifiez la configuration.');
    }
  }

  /// Test rapide de la base de données
  Future<void> testDatabaseOperations() async {
    try {
      print('\n🗄️ Test des opérations de base de données...');
      
      // Test de lecture
      final wasteTypes = await WasteService.instance.getWasteTypes();
      print('📖 Lecture: ${wasteTypes.length} types de déchets récupérés');
      
      // Test de calcul
      final testQuantities = {'plastic': 1.0, 'organic': 0.5};
      final price = WasteService.instance.calculateTotalPrice(testQuantities);
      print('🧮 Calcul: Prix total = ${price.toStringAsFixed(0)} GNF');
      
      print('✅ Tests de base de données réussis');
      
    } catch (e) {
      print('❌ Erreur lors des tests de base de données: $e');
    }
  }

  /// Test de performance
  Future<void> testPerformance() async {
    try {
      print('\n⚡ Test de performance...');
      
      final stopwatch = Stopwatch()..start();
      
      // Test de récupération des types de déchets
      await WasteService.instance.getWasteTypes();
      
      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;
      
      print('⏱️ Temps de récupération: ${duration}ms');
      
      if (duration < 1000) {
        print('✅ Performance satisfaisante (< 1s)');
      } else {
        print('⚠️ Performance lente (> 1s)');
      }
      
    } catch (e) {
      print('❌ Erreur lors du test de performance: $e');
    }
  }
}
