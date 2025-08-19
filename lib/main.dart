import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:batte/core/app_theme.dart';
import 'package:batte/features/auth/presentation/pages/user_type_selection_page.dart';
import 'package:batte/services/supabase_service.dart';
import 'package:batte/core/routes.dart';
import 'package:batte/features/profile/presentation/pages/profile_page.dart';
import 'package:batte/features/monetization/presentation/pages/monetization_page.dart';
import 'package:batte/features/pour_moi/presentation/pages/pour_moi_page.dart';
import 'package:batte/features/budget/presentation/pages/budget_page.dart';
import 'package:batte/features/profile/presentation/pages/settings_page.dart';
import 'package:batte/features/auth/presentation/pages/login_page.dart';
import 'package:batte/features/auth/presentation/pages/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuration de l'orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialisation de Supabase
  try {
    await SupabaseService.instance.initialize();
    print('🚀 Application Batte initialisée avec Supabase');
  } catch (e) {
    print('❌ Erreur lors de l\'initialisation de Supabase: $e');
    // Continuer même si Supabase échoue
  }
  
  runApp(const BatteApp());
}

class BatteApp extends StatelessWidget {
  const BatteApp({super.key});
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Batte',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      routes: {
        // Removed AppRoutes.home ('/') to avoid conflict with 'home:' property
        AppRoutes.profile: (_) => const ProfilePage(),
        AppRoutes.monetization: (_) => const MonetizationPage(),
        AppRoutes.pourMoi: (_) => const PourMoiPage(),
        AppRoutes.budget: (_) => const BudgetPage(),
        AppRoutes.settings: (_) => const SettingsPage(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),
      },
      home: const UserTypeSelectionPage(),
    );
  }
}
