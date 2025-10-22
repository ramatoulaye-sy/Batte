import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/supabase_service.dart';
import '../home/home_screen.dart';
import '../collector/collector_main_screen.dart';
import 'collector_signup_screen.dart';

/// Écran de choix du profil (Utilisateur ou Collecteur)
/// Affiché après le login si l'utilisateur a plusieurs profils
class ProfileChoiceScreen extends StatefulWidget {
  const ProfileChoiceScreen({super.key});

  @override
  State<ProfileChoiceScreen> createState() => _ProfileChoiceScreenState();
}

class _ProfileChoiceScreenState extends State<ProfileChoiceScreen> {
  List<String> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profiles = await SupabaseService.getUserProfiles();
    
    if (mounted) {
      setState(() {
        _profiles = profiles;
        _isLoading = false;
      });

      // Si un seul profil, rediriger automatiquement
      if (_profiles.length == 1) {
        _navigateToProfile(_profiles.first);
      }
    }
  }

  void _navigateToProfile(String profileType) {
    if (profileType == 'user') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (profileType == 'collector') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CollectorMainScreen()),
      );
    }
  }

  Future<void> _createCollectorProfile() async {
    // Naviguer vers le formulaire d'inscription collecteur
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CollectorSignupScreen()),
    );

    if (result == true) {
      // Recharger les profils
      _loadProfiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(BatteColors.primary),
          ),
        ),
      );
    }

    // Si aucun profil, proposer de créer
    if (_profiles.isEmpty) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person_add,
                  size: 80,
                  color: BatteColors.primary,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Bienvenue sur Battè !',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Choisissez votre profil pour commencer',
                  style: TextStyle(
                    fontSize: 16,
                    color: BatteColors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                _buildProfileOption(
                  'Utilisateur',
                  'Je veux recycler mes déchets',
                  Icons.recycling,
                  () => _navigateToProfile('user'),
                ),
                const SizedBox(height: 16),
                _buildProfileOption(
                  'Collecteur',
                  'Je collecte les déchets',
                  Icons.local_shipping,
                  _createCollectorProfile,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Si plusieurs profils, choisir
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un profil'),
        backgroundColor: BatteColors.primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (_profiles.contains('user'))
                _buildProfileCard(
                  'Utilisateur',
                  'Accéder à mon compte utilisateur',
                  Icons.person,
                  () => _navigateToProfile('user'),
                ),
              if (_profiles.contains('user') && _profiles.contains('collector'))
                const SizedBox(height: 16),
              if (_profiles.contains('collector'))
                _buildProfileCard(
                  'Collecteur',
                  'Accéder à mon compte collecteur',
                  Icons.local_shipping,
                  () => _navigateToProfile('collector'),
                ),
              if (!_profiles.contains('collector')) ...[
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: _createCollectorProfile,
                  icon: const Icon(Icons.add),
                  label: const Text('Devenir collecteur'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BatteColors.primary,
                    side: const BorderSide(color: BatteColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: BatteColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BatteColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BatteColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: BatteColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: BatteColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: BatteColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: BatteColors.primary,
                child: Icon(
                  icon,
                  size: 32,
                  color: BatteColors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: BatteColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: BatteColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

