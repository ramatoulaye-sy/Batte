import 'package:flutter/material.dart';
import 'package:batte/core/app_theme.dart';
import 'package:batte/features/auth/presentation/pages/login_page.dart';

class UserTypeSelectionPage extends StatelessWidget {
  const UserTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo et titre
              Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.recycling,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'BIENVENUE SUR "BATTE"',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Et si vos déchets devenaient votre richesse ?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.onBackgroundColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Gagnez de l\'argent tout en préservant la planète !',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.onBackgroundColor.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Sélection du type d'utilisateur
              Text(
                'Choisissez votre profil :',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Option 1: Utilisateur simple
              _buildUserTypeCard(
                context: context,
                icon: Icons.person,
                title: 'UTILISATEUR SIMPLE',
                subtitle: 'Vendez vos déchets et gagnez de l\'argent',
                color: AppTheme.primaryColor,
                onTap: () => _navigateToAuth(context, 'user'),
              ),
              
              const SizedBox(height: 12),
              
              // Option 2: Collecteur
              _buildUserTypeCard(
                context: context,
                icon: Icons.local_shipping,
                title: 'JE SUIS UN COLLECTEUR',
                subtitle: 'Collectez les déchets et développez votre activité',
                color: AppTheme.accentColor,
                onTap: () => _navigateToAuth(context, 'collector'),
              ),
              
              const SizedBox(height: 12),
              
              // Option 3: Entreprise
              _buildUserTypeCard(
                context: context,
                icon: Icons.business,
                title: 'JE SUIS UNE ENTREPRISE',
                subtitle: 'Achetez des déchets recyclés pour votre production',
                color: AppTheme.warningColor,
                onTap: () => _navigateToAuth(context, 'enterprise'),
              ),
              
              const SizedBox(height: 24),
              
              // Informations supplémentaires
              Text(
                'Rejoignez l\'écosystème Batte et contribuez à un avenir durable',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onBackgroundColor.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 25,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color.withValues(alpha: 0.6),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAuth(BuildContext context, String userType) {
    // Naviguer vers la page de connexion avec le type d'utilisateur
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(userType: userType),
      ),
    );
  }
}
