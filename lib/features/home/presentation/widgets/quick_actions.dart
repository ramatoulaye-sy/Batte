import 'package:flutter/material.dart';
import 'package:batte/core/app_theme.dart';

class QuickActions extends StatelessWidget {
  final bool canSell;
  final VoidCallback? onSellPressed;

  const QuickActions({
    super.key,
    required this.canSell,
    this.onSellPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions rapides',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              // Scanner QR Code
              Expanded(
                child: _buildActionButton(
                  context,
                  'Scanner QR',
                  Icons.qr_code_scanner,
                  AppTheme.primaryColor,
                  () => _scanQRCode(context),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Connecter Bluetooth
              Expanded(
                child: _buildActionButton(
                  context,
                  'Bluetooth',
                  Icons.bluetooth,
                  AppTheme.accentColor,
                  () => _connectBluetooth(context),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              // Saisie manuelle
              Expanded(
                child: _buildActionButton(
                  context,
                  'Saisie manuelle',
                  Icons.edit,
                  AppTheme.secondaryColor,
                  () => _manualEntry(context),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Voir l'historique
              Expanded(
                child: _buildActionButton(
                  context,
                  'Historique',
                  Icons.history,
                  AppTheme.warningColor,
                  () => _viewHistory(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _scanQRCode(BuildContext context) {
    // TODO: Implémenter le scan QR
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de scan QR à implémenter'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _connectBluetooth(BuildContext context) {
    // TODO: Implémenter la connexion Bluetooth
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité Bluetooth à implémenter'),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  void _manualEntry(BuildContext context) {
    // TODO: Naviguer vers la page de saisie manuelle
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Page de saisie manuelle à implémenter'),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  void _viewHistory(BuildContext context) {
    // TODO: Naviguer vers l'historique
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Page d\'historique à implémenter'),
        backgroundColor: AppTheme.warningColor,
      ),
    );
  }
}
