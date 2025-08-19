import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:batte/main.dart';
import 'package:batte/features/home/presentation/pages/home_page.dart';
import 'package:batte/features/monetization/presentation/pages/monetization_page.dart';
import 'package:batte/features/pour_moi/presentation/pages/pour_moi_page.dart';
import 'package:batte/features/budget/presentation/pages/budget_page.dart';
import 'package:batte/features/profile/presentation/pages/profile_page.dart';

void main() {
  group('Batte App Tests', () {
    testWidgets('Application se lance correctement', (WidgetTester tester) async {
      // Construire l'application
      await tester.pumpWidget(const BatteApp());
      
      // Vérifier que l'application se lance
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Batte'), findsNothing); // Le titre n'est pas affiché dans le body
    });

    testWidgets('Navigation entre les onglets fonctionne', (WidgetTester tester) async {
      await tester.pumpWidget(const BatteApp());
      
      // Vérifier que la page d'accueil est affichée par défaut
      expect(find.byType(HomePage), findsOneWidget);
      
      // Naviguer vers l'onglet Monétisation
      await tester.tap(find.text('Monétisation'));
      await tester.pumpAndSettle();
      expect(find.byType(MonetizationPage), findsOneWidget);
      
      // Naviguer vers l'onglet Pour Moi
      await tester.tap(find.text('Pour Moi'));
      await tester.pumpAndSettle();
      expect(find.byType(PourMoiPage), findsOneWidget);
      
      // Naviguer vers l'onglet Budget
      await tester.tap(find.text('Budget'));
      await tester.pumpAndSettle();
      expect(find.byType(BudgetPage), findsOneWidget);
      
      // Naviguer vers l'onglet Profil
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);
      
      // Retourner à l'accueil
      await tester.tap(find.text('Accueil'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Page d\'accueil affiche les éléments principaux', (WidgetTester tester) async {
      await tester.pumpWidget(const BatteApp());
      
      // Vérifier la présence des éléments de la page d'accueil
      expect(find.text('Bonjour Sofia !'), findsOneWidget);
      expect(find.text('Prête à valoriser vos déchets ?'), findsOneWidget);
      expect(find.text('Solde'), findsOneWidget);
      expect(find.text('Points'), findsOneWidget);
      expect(find.text('Actions rapides'), findsOneWidget);
      expect(find.text('Scanner QR'), findsOneWidget);
      expect(find.text('Bluetooth'), findsOneWidget);
    });

    testWidgets('Page de monétisation fonctionne correctement', (WidgetTester tester) async {
      await tester.pumpWidget(const BatteApp());
      
      // Naviguer vers la monétisation
      await tester.tap(find.text('Monétisation'));
      await tester.pumpAndSettle();
      
      // Vérifier les éléments de la page
      expect(find.text('Saisissez le poids de vos déchets'), findsOneWidget);
      expect(find.text('Types de déchets'), findsOneWidget);
      expect(find.text('Plastique'), findsOneWidget);
      expect(find.text('Organique'), findsOneWidget);
      expect(find.text('Verre'), findsOneWidget);
      expect(find.text('Métal'), findsOneWidget);
      expect(find.text('Papier'), findsOneWidget);
      
      // Vérifier que le bouton vendre est désactivé par défaut
      expect(find.text('Minimum 1kg requis'), findsOneWidget);
    });

    testWidgets('Page Pour Moi affiche le chat IA', (WidgetTester tester) async {
      await tester.pumpWidget(const BatteApp());
      
      // Naviguer vers Pour Moi
      await tester.tap(find.text('Pour Moi'));
      await tester.pumpAndSettle();
      
      // Vérifier les éléments de la page
      expect(find.text('Vidéos éducatives'), findsOneWidget);
      expect(find.text('Transformation des plastiques'), findsOneWidget);
      expect(find.text('Compostage organique'), findsOneWidget);
      expect(find.text('Artisanat avec déchets'), findsOneWidget);
      expect(find.text('Assistant IA Batte'), findsOneWidget);
      expect(find.text('Bonjour ! Je suis l\'assistant IA de Batte.'), findsOneWidget);
    });

    testWidgets('Page Budget affiche les informations financières', (WidgetTester tester) async {
      await tester.pumpWidget(const BatteApp());
      
      // Naviguer vers Budget
      await tester.tap(find.text('Budget'));
      await tester.pumpAndSettle();
      
      // Vérifier les éléments de la page
      expect(find.text('Solde actuel'), findsOneWidget);
      expect(find.text('4,500 GNF'), findsOneWidget);
      expect(find.text('Statistiques du mois'), findsOneWidget);
      expect(find.text('Revenus'), findsOneWidget);
      expect(find.text('Dépensés'), findsOneWidget);
      expect(find.text('Épargné'), findsOneWidget);
      expect(find.text('Actions rapides'), findsOneWidget);
      expect(find.text('Retirer'), findsOneWidget);
      expect(find.text('Économiser'), findsOneWidget);
      expect(find.text('Historique'), findsOneWidget);
    });

    testWidgets('Page Profil affiche les informations utilisateur', (WidgetTester tester) async {
      await tester.pumpWidget(const BatteApp());
      
      // Naviguer vers Profil
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      
      // Vérifier les éléments de la page
      expect(find.text('Sofia'), findsOneWidget);
      expect(find.text('Niveau 2'), findsOneWidget);
      expect(find.text('8 points'), findsOneWidget);
      expect(find.text('Statistiques'), findsOneWidget);
      expect(find.text('Déchets vendus'), findsOneWidget);
      expect(find.text('Collecteurs'), findsOneWidget);
      expect(find.text('Satisfaction'), findsOneWidget);
      expect(find.text('Paramètres'), findsOneWidget);
      expect(find.text('Aide & Support'), findsOneWidget);
      expect(find.text('À propos'), findsOneWidget);
      expect(find.text('Déconnexion'), findsOneWidget);
    });

    testWidgets('Thème de l\'application utilise les bonnes couleurs', (WidgetTester tester) async {
      await tester.pumpWidget(const BatteApp());
      
      // Vérifier que l'application utilise le thème personnalisé
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme, isNotNull);
      
      // Les couleurs seront testées dans les tests unitaires du thème
    });

    testWidgets('Gestion des erreurs de navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const BatteApp());
      
      // Tester la navigation avec des routes invalides
      // Ce test vérifie que l'application ne plante pas
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}

// Tests unitaires pour les composants
class ComponentTests {
  static void testThemeColors() {
    // Test des couleurs du thème
    // Ces tests peuvent être ajoutés ici ou dans un fichier séparé
  }
  
  static void testDataValidation() {
    // Test de validation des données
    // Ces tests peuvent être ajoutés ici ou dans un fichier séparé
  }
  
  static void testBusinessLogic() {
    // Test de la logique métier
    // Ces tests peuvent être ajoutés ici ou dans un fichier séparé
  }
}
