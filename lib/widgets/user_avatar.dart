import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../providers/auth_provider.dart';

/// Widget réutilisable pour afficher l'avatar utilisateur
class UserAvatar extends StatelessWidget {
  final double radius;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final String? userId; // Pour afficher l'avatar d'un autre utilisateur
  final String? avatarUrl; // URL directe de l'avatar
  final String? userName; // Nom pour les initiales

  const UserAvatar({
    Key? key,
    this.radius = 24,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
    this.onTap,
    this.userId,
    this.avatarUrl,
    this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Déterminer l'utilisateur à afficher
        final user = userId != null 
            ? null // TODO: Récupérer l'utilisateur par ID
            : authProvider.user;
        
        final displayAvatarUrl = avatarUrl ?? user?.avatarUrl;
        final displayName = userName ?? user?.name ?? '';

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: showBorder
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor ?? BatteColors.primary,
                      width: borderWidth,
                    ),
                  )
                : null,
            child: CircleAvatar(
              radius: radius,
              backgroundColor: BatteColors.primary,
              child: displayAvatarUrl != null && displayAvatarUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        displayAvatarUrl,
                        width: radius * 2,
                        height: radius * 2,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildInitialsAvatar(displayName),
                      ),
                    )
                  : _buildInitialsAvatar(displayName),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInitialsAvatar(String name) {
    final initials = name.isNotEmpty
        ? name.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
        : 'U';
    
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: BatteColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: BatteColors.white,
            fontSize: radius * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Widget spécialisé pour l'avatar dans le header
class HeaderUserAvatar extends StatelessWidget {
  final VoidCallback? onTap;

  const HeaderUserAvatar({
    Key? key,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserAvatar(
      radius: 18,
      showBorder: true,
      borderColor: BatteColors.white,
      borderWidth: 2,
      onTap: onTap,
    );
  }
}

/// Widget spécialisé pour l'avatar dans les listes
class ListUserAvatar extends StatelessWidget {
  final String? userId;
  final String? avatarUrl;
  final String? userName;

  const ListUserAvatar({
    Key? key,
    this.userId,
    this.avatarUrl,
    this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserAvatar(
      radius: 20,
      userId: userId,
      avatarUrl: avatarUrl,
      userName: userName,
    );
  }
}

/// Widget spécialisé pour l'avatar dans les cartes
class CardUserAvatar extends StatelessWidget {
  final String? userId;
  final String? avatarUrl;
  final String? userName;

  const CardUserAvatar({
    Key? key,
    this.userId,
    this.avatarUrl,
    this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserAvatar(
      radius: 24,
      userId: userId,
      avatarUrl: avatarUrl,
      userName: userName,
    );
  }
}
