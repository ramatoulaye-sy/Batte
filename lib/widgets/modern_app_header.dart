import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import 'user_avatar.dart';

/// Header moderne avec effet glassmorphism
class ModernAppHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingsTap;
  final int notificationCount;

  const ModernAppHeader({
    Key? key,
    required this.userName,
    this.onNotificationTap,
    this.onSettingsTap,
    this.notificationCount = 0,
  }) : super(key: key);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  String _getFirstName() {
    return userName.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 48,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo + Salutation + Avatar
          Expanded(
            child: Row(
              children: [
                // Logo Battè
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: BatteColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: BatteColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Salutation
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontSize: 13,
                          color: BatteColors.foreground.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getFirstName(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Force noir pour être sûr
                          letterSpacing: -0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Avatar utilisateur
                HeaderUserAvatar(
                  onTap: () {
                    // TODO: Navigation vers profil
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Notifications
          _buildIconButton(
            icon: Icons.notifications_outlined,
            onTap: onNotificationTap,
            badge: notificationCount,
          ),
          
          const SizedBox(width: 8),
          
          // Paramètres
          _buildIconButton(
            icon: Icons.settings_outlined,
            onTap: onSettingsTap,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onTap,
    int? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: BatteColors.lightGreen.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                color: BatteColors.primary,
                size: 22,
              ),
            ),
            if (badge != null && badge > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: BatteColors.destructive,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    badge > 9 ? '9+' : '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

