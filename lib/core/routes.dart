import 'package:flutter/material.dart';
import 'package:batte/features/home/presentation/pages/home_page.dart';
import 'package:batte/features/monetization/presentation/pages/monetization_page.dart';
import 'package:batte/features/pour_moi/presentation/pages/pour_moi_page.dart';
import 'package:batte/features/budget/presentation/pages/budget_page.dart';
import 'package:batte/features/profile/presentation/pages/profile_page.dart';
import 'package:batte/features/profile/presentation/pages/settings_page.dart';
import 'package:batte/features/collector/presentation/pages/collector_page.dart';
import 'package:batte/features/auth/presentation/pages/login_page.dart';
import 'package:batte/features/auth/presentation/pages/register_page.dart';

class AppRoutes {
  // Routes principales
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String monetization = '/monetization';
  static const String pourMoi = '/pour-moi';
  static const String budget = '/budget';
  static const String profile = '/profile';
  static const String collector = '/collector';
  
  // Routes secondaires
  static const String wasteDetails = '/waste-details';
  static const String collectorSelection = '/collector-selection';
  static const String payment = '/payment';
  static const String chat = '/chat';
  static const String videoPlayer = '/video-player';
  static const String settings = '/settings';
  static const String help = '/help';

  // Générateur de routes
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );
      case monetization:
        return MaterialPageRoute(
          builder: (_) => const MonetizationPage(),
          settings: settings,
        );
      case pourMoi:
        return MaterialPageRoute(
          builder: (_) => const PourMoiPage(),
          settings: settings,
        );
      case budget:
        return MaterialPageRoute(
          builder: (_) => const BudgetPage(),
          settings: settings,
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
          settings: settings,
        );
      case collector:
        return MaterialPageRoute(
          builder: (_) => const CollectorPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page non trouvée'),
            ),
          ),
        );
    }
  }

  // Navigation avec nom de route
  static Future<dynamic> pushNamed(BuildContext context, String routeName, {Object? arguments}) {
    if (!context.mounted) return Future.value(null);
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  // Navigation avec remplacement
  static Future<dynamic> pushReplacementNamed(BuildContext context, String routeName, {Object? arguments}) {
    if (!context.mounted) return Future.value(null);
    return Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  // Navigation avec suppression de toutes les routes
  static Future<dynamic> pushNamedAndRemoveUntil(BuildContext context, String routeName, {Object? arguments}) {
    if (!context.mounted) return Future.value(null);
    return Navigator.pushNamedAndRemoveUntil(
      context, 
      routeName, 
      (route) => false,
      arguments: arguments,
    );
  }

  // Retour en arrière
  static void pop(BuildContext context, [dynamic result]) {
    if (!context.mounted) return;
    Navigator.pop(context, result);
  }
}
