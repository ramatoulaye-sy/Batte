import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Écran de paramètres pour les collecteurs
class CollectorSettingsScreen extends StatefulWidget {
  const CollectorSettingsScreen({super.key});

  @override
  State<CollectorSettingsScreen> createState() => _CollectorSettingsScreenState();
}

class _CollectorSettingsScreenState extends State<CollectorSettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  bool _isAvailable = true;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  double _coverageRadius = 15.0;
  String _workingHours = '8h-18h';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
    
    _loadSettings();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    // Simuler le chargement des paramètres
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _isAvailable = true;
        _notificationsEnabled = true;
        _locationEnabled = true;
        _coverageRadius = 15.0;
        _workingHours = '8h-18h';
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    
    try {
      // Simuler la sauvegarde
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paramètres sauvegardés avec succès !'),
            backgroundColor: BatteColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la sauvegarde'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BatteColors.softGreen,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header moderne
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            
            // Contenu des paramètres
            SliverToBoxAdapter(
              child: _buildSettingsContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: BatteColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paramètres',
                  style: TextStyle(
                    fontSize: 13,
                    color: BatteColors.foreground.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Configuration',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: BatteColors.foreground,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isAvailable 
                  ? BatteColors.success.withOpacity(0.1)
                  : BatteColors.muted.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _isAvailable ? 'Disponible' : 'Indisponible',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _isAvailable ? BatteColors.success : BatteColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Statut de disponibilité
          _buildAvailabilityCard(),
          
          const SizedBox(height: 20),
          
          // Paramètres de travail
          _buildWorkSettingsCard(),
          
          const SizedBox(height: 20),
          
          // Paramètres de notifications
          _buildNotificationsCard(),
          
          const SizedBox(height: 20),
          
          // Paramètres de localisation
          _buildLocationCard(),
          
          const SizedBox(height: 20),
          
          // Paramètres avancés
          _buildAdvancedCard(),
          
          const SizedBox(height: 20),
          
          // Bouton de sauvegarde
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.toggle_on_rounded,
                color: BatteColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Disponibilité',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: BatteColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Activer votre disponibilité pour recevoir des demandes de collecte',
                  style: TextStyle(
                    fontSize: 14,
                    color: BatteColors.foreground.withOpacity(0.7),
                  ),
                ),
              ),
              Switch(
                value: _isAvailable,
                onChanged: (value) {
                  setState(() {
                    _isAvailable = value;
                  });
                },
                activeColor: BatteColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.work_rounded,
                color: BatteColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Paramètres de travail',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: BatteColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Rayon de couverture
          _buildSettingItem(
            icon: Icons.location_on_rounded,
            title: 'Rayon de couverture',
            subtitle: '${_coverageRadius.toInt()} km',
            child: Slider(
              value: _coverageRadius,
              min: 5.0,
              max: 50.0,
              divisions: 9,
              activeColor: BatteColors.primary,
              onChanged: (value) {
                setState(() {
                  _coverageRadius = value;
                });
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Heures de travail
          _buildSettingItem(
            icon: Icons.access_time_rounded,
            title: 'Heures de travail',
            subtitle: _workingHours,
            child: DropdownButton<String>(
              value: _workingHours,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: '6h-14h', child: Text('6h-14h')),
                DropdownMenuItem(value: '8h-16h', child: Text('8h-16h')),
                DropdownMenuItem(value: '8h-18h', child: Text('8h-18h')),
                DropdownMenuItem(value: '10h-20h', child: Text('10h-20h')),
                DropdownMenuItem(value: '24h/24', child: Text('24h/24')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _workingHours = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_rounded,
                color: BatteColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: BatteColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildNotificationItem(
            title: 'Nouvelles demandes',
            subtitle: 'Recevoir des notifications pour les nouvelles demandes',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildNotificationItem(
            title: 'Rappels de disponibilité',
            subtitle: 'Rappels pour activer votre disponibilité',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildNotificationItem(
            title: 'Paiements reçus',
            subtitle: 'Notifications lors de la réception de paiements',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: BatteColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Localisation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: BatteColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Text(
                  'Partager votre localisation pour être trouvé par les clients',
                  style: TextStyle(
                    fontSize: 14,
                    color: BatteColors.foreground.withOpacity(0.7),
                  ),
                ),
              ),
              Switch(
                value: _locationEnabled,
                onChanged: (value) {
                  setState(() {
                    _locationEnabled = value;
                  });
                },
                activeColor: BatteColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune_rounded,
                color: BatteColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Paramètres avancés',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: BatteColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildActionItem(
            icon: Icons.privacy_tip_rounded,
            title: 'Politique de confidentialité',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Politique de confidentialité bientôt disponible !'),
                  backgroundColor: BatteColors.primary,
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          _buildActionItem(
            icon: Icons.help_rounded,
            title: 'Centre d\'aide',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Centre d\'aide bientôt disponible !'),
                  backgroundColor: BatteColors.primary,
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          _buildActionItem(
            icon: Icons.info_rounded,
            title: 'À propos',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('À propos bientôt disponible !'),
                  backgroundColor: BatteColors.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Row(
      children: [
        Icon(icon, color: BatteColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: BatteColors.foreground,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: BatteColors.foreground.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(width: 120, child: child),
      ],
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: BatteColors.foreground,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: BatteColors.foreground.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: BatteColors.success,
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: BatteColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: BatteColors.foreground,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: BatteColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Sauvegarder les paramètres',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
