import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/utils/helpers.dart';

/// Carte de solde moderne avec design premium
class ModernBalanceCard extends StatelessWidget {
  final double balance;
  final double monthlyEarnings;
  final int ecoScore;
  final VoidCallback? onTap;

  const ModernBalanceCard({
    Key? key,
    required this.balance,
    required this.monthlyEarnings,
    required this.ecoScore,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: BatteColors.balanceCardGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: BatteColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Motif décoratif
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
            
            // Contenu
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: BatteColors.gold,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Solde total',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Montant principal
                  Text(
                    Helpers.formatCurrency(balance),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -1,
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Statistiques secondaires
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.arrow_upward_rounded,
                          label: 'Gains ce mois',
                          value: Helpers.formatCurrency(monthlyEarnings),
                          color: BatteColors.gold,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.eco_rounded,
                          label: 'Score écolo',
                          value: '$ecoScore pts',
                          color: BatteColors.gold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

