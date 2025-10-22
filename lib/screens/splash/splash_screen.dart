import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/batte_logo.dart';
import '../onboarding/onboarding_screen.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../collector/collector_main_screen.dart';

/// Écran de démarrage
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _controller.forward();
    _navigateToNextScreen();
  }
  
  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isFirstLaunch = StorageService.isFirstLaunch();
    
    Widget nextScreen;
    if (isFirstLaunch) {
      nextScreen = const OnboardingScreen();
    } else if (authProvider.isAuthenticated) {
      // Vérifier le profil de l'utilisateur et rediriger directement
      final profiles = await SupabaseService.getUserProfiles();
      
      if (profiles.contains('collector')) {
        nextScreen = const CollectorMainScreen();
      } else {
        nextScreen = const HomeScreen();
      }
    } else {
      nextScreen = const LoginScreen();
    }
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              BatteColors.primary,
              Color(0xFF2A5E15),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  children: [
                    // Logo Battè
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: BatteColors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: BatteLogoLarge(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Battè',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: BatteColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Transformez vos déchets en argent',
                      style: TextStyle(
                        fontSize: 16,
                        color: BatteColors.white,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(BatteColors.white),
            ),
          ],
        ),
      ),
    );
  }
}

