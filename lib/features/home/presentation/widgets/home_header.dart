import 'package:flutter/material.dart';
import 'package:batte/core/app_theme.dart';
import 'package:batte/services/test_service.dart';

class HomeHeader extends StatelessWidget {
  final double balance;
  final int points;
  final double monthlyWaste;
  final bool canSell;
  final VoidCallback? onSellPressed;
  final String userName;
  final String? avatarUrl;

  const HomeHeader({
    super.key,
    required this.balance,
    required this.points,
    required this.monthlyWaste,
    required this.canSell,
    this.onSellPressed,
    required this.userName,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec avatar et salutation
          Row(
            children: [
              // Avatar utilisateur
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.surfaceColor,
                backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: (avatarUrl == null || avatarUrl!.isEmpty)
                    ? Icon(
                        Icons.person,
                        color: AppTheme.primaryColor,
                        size: 24,
                      )
                    : null,
              ),
              
              const SizedBox(width: 12),
              
              // Salutation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour ' + userName + ' !',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.onPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Prête à valoriser vos déchets ?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onPrimaryColor.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bouton notifications
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    // Ouvrir les notifications
                  },
                  icon: const Icon(
                    Icons.notifications,
                    color: AppTheme.onPrimaryColor,
                    size: 22,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Bouton de test (à supprimer en production)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    _runTests(context);
                  },
                  icon: const Icon(
                    Icons.bug_report,
                    color: AppTheme.onPrimaryColor,
                    size: 20,
                  ),
                  tooltip: 'Tester les services',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Cartes d'information
          Row(
            children: [
              // Carte Solde
              Expanded(
                child: _buildInfoCard(
                  'Solde',
                  '${balance.toStringAsFixed(0)} GNF',
                  Icons.account_balance_wallet,
                  AppTheme.surfaceColor,
                  AppTheme.primaryColor,
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Carte Points
              Expanded(
                child: _buildInfoCard(
                  'Points',
                  '$points',
                  Icons.star,
                  AppTheme.secondaryColor,
                  AppTheme.onSecondaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Section poids mensuel et bouton vendre
          Row(
            children: [
              // Carte Poids mensuel
              Expanded(
                child: _buildInfoCard(
                  'Déchets ce mois',
                  '${monthlyWaste.toStringAsFixed(1)} kg',
                  Icons.recycling,
                  AppTheme.successColor,
                  AppTheme.onPrimaryColor,
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Bouton Vendre
              Expanded(
                child: _buildSellButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSellButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: canSell ? AppTheme.accentColor : AppTheme.disabledColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: canSell ? AppTheme.elevatedShadow : null,
        border: canSell 
            ? Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3), width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canSell ? onSellPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  canSell ? Icons.sell : Icons.block,
                  color: AppTheme.onPrimaryColor,
                  size: 18,
                ),
                const SizedBox(height: 2),
                Text(
                  canSell ? 'VENDRE' : 'Min 1kg',
                  style: TextStyle(
                    color: AppTheme.onPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
                if (canSell) ...[
                  const SizedBox(height: 1),
                  Text(
                    '${monthlyWaste.toStringAsFixed(1)}kg',
                    style: TextStyle(
                      color: AppTheme.onPrimaryColor.withValues(alpha: 0.8),
                      fontSize: 8,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: backgroundColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: textColor,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Lance les tests des services
  void _runTests(BuildContext context) async {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.floatingShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Test des services en cours...',
                style: TextStyle(
                  color: AppTheme.onSurfaceColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Lancer tous les tests
      final results = await TestService.instance.runAllTests();
      
      // Fermer l'indicateur de chargement
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      // Afficher les résultats
      if (context.mounted) {
        _showTestResults(context, results);
      }
      
    } catch (e) {
      // Fermer l'indicateur de chargement
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      // Afficher l'erreur
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors des tests: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  /// Affiche les résultats des tests
  void _showTestResults(BuildContext context, Map<String, dynamic> results) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.analytics,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Résultats des Tests'),
          ],
        ),
        content: Container(
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: results.entries.map((entry) {
                final serviceName = entry.key;
                final result = entry.value;
                
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (result['success'] == true 
                        ? AppTheme.successColor 
                        : AppTheme.errorColor).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (result['success'] == true 
                          ? AppTheme.successColor 
                          : AppTheme.errorColor).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        result['success'] == true 
                            ? Icons.check_circle 
                            : Icons.error,
                        color: result['success'] == true 
                            ? AppTheme.successColor 
                            : AppTheme.errorColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serviceName.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (result['message'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                result['message'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.onSurfaceColor.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: AppTheme.onPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Fermer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
