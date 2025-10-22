import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/waste_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/education_provider.dart';
import 'providers/services_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/collector/collector_main_screen.dart';

/// Widget principal de l'application Battè
class BatteApp extends StatelessWidget {
  const BatteApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WasteProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => EducationProvider()),
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
      ],
      child: MaterialApp(
        title: 'Battè',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/collector-dashboard': (context) => const CollectorMainScreen(),
        },
      ),
    );
  }
}

