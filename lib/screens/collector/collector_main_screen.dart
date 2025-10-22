import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import 'modern_collector_dashboard.dart';
import 'collector_history_screen.dart';
import 'collector_profile_screen.dart';
import 'collector_settings_screen.dart';

/// Navigation principale pour les collecteurs avec bottom bar moderne
class CollectorMainScreen extends StatefulWidget {
  const CollectorMainScreen({super.key});

  @override
  State<CollectorMainScreen> createState() => _CollectorMainScreenState();
}

class _CollectorMainScreenState extends State<CollectorMainScreen> {
  int _currentIndex = 0;
  
  // Créer les écrans de manière dynamique pour éviter les problèmes d'initialisation
  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const ModernCollectorDashboard();
      case 1:
        return const CollectorHistoryScreen();
      case 2:
        return const CollectorProfileScreen();
      case 3:
        return const CollectorSettingsScreen();
      default:
        return const ModernCollectorDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Accueil',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.history_rounded,
                  label: 'Collectes',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profil',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.settings_rounded,
                  label: 'Paramètres',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? BatteColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? BatteColors.primary : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? BatteColors.primary : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
