import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/storage_service.dart';
import '../auth/login_screen.dart';
import '../../widgets/custom_button.dart';

/// Écran d'onboarding
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);
  
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Recyclez et Gagnez',
      description: 'Transformez vos déchets en argent grâce à notre poubelle intelligente connectée',
      icon: '♻️',
      color: BatteColors.primary,
    ),
    OnboardingPage(
      title: 'Suivez vos Gains',
      description: 'Visualisez vos revenus et gérez votre budget facilement',
      icon: '💰',
      color: BatteColors.secondary,
    ),
    OnboardingPage(
      title: 'Apprenez et Progressez',
      description: 'Accédez à du contenu éducatif et développez vos compétences',
      icon: '🎓',
      color: BatteColors.purple,
    ),
    OnboardingPage(
      title: 'Trouvez des Opportunités',
      description: 'Découvrez des offres d\'emploi et proposez vos services',
      icon: '👩🏽‍🔧',
      color: BatteColors.chart1,
    ),
  ];
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }
  
  void _skip() {
    _finish();
  }
  
  Future<void> _finish() async {
    await StorageService.setFirstLaunch(false);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _skip,
                      child: const Text(
                        'Passer',
                        style: TextStyle(
                          color: BatteColors.mutedForeground,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Indicateurs de page
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildPageIndicator(index),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Bouton suivant
                  CustomButton(
                    text: _currentPage == _pages.length - 1
                        ? 'Commencer'
                        : 'Suivant',
                    onPressed: _nextPage,
                    backgroundColor: _pages[_currentPage].color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                page.icon,
                style: const TextStyle(fontSize: 100),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: page.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: BatteColors.mutedForeground,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPageIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? _pages[_currentPage].color
            : BatteColors.muted,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String icon;
  final Color color;
  
  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

