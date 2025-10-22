import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
import '../../services/voice_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/user_avatar.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';
import '../support/faq_screen.dart';
import '../notifications/notifications_list_screen.dart';
import '../gamification/missions_screen.dart';
import '../gamification/leaderboard_screen.dart';

/// Écran des paramètres
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final VoiceService _voiceService = VoiceService();
  String _selectedLanguage = 'fr';
  bool _voiceEnabled = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  void _loadSettings() {
    setState(() {
      _selectedLanguage = StorageService.getLanguage();
      _voiceEnabled = StorageService.getVoiceEnabled();
    });
  }
  
  Future<void> _changeLanguage(String languageCode) async {
    await StorageService.saveLanguage(languageCode);
    await _voiceService.setLanguage(languageCode);
    setState(() {
      _selectedLanguage = languageCode;
    });
  }
  
  Future<void> _toggleVoice(bool value) async {
    await StorageService.saveVoiceEnabled(value);
    setState(() {
      _voiceEnabled = value;
    });
    
    if (value) {
      _voiceService.speak('Assistance vocale activée');
    }
  }
  
  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: BatteColors.primary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profil
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BatteColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  UserAvatar(
                    radius: 32,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Utilisateur',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.phone ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: BatteColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Langue
            const Text(
              'Langue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ...AppConstants.supportedLanguages.map((lang) {
              final isSelected = _selectedLanguage == lang['code'];
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? BatteColors.primary.withOpacity(0.1)
                      : BatteColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? BatteColors.primary
                        : Colors.transparent,
                  ),
                ),
                child: RadioListTile<String>(
                  title: Text(lang['nativeName']!),
                  subtitle: Text(lang['name']!),
                  value: lang['code']!,
                  groupValue: _selectedLanguage,
                  activeColor: BatteColors.primary,
                  onChanged: (value) {
                    if (value != null) {
                      _changeLanguage(value);
                    }
                  },
                ),
              );
            }).toList(),
            
            const SizedBox(height: 24),
            
            // Accessibilité
            const Text(
              'Accessibilité',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              decoration: BoxDecoration(
                color: BatteColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text('Assistance vocale'),
                subtitle: const Text('Navigation par commande vocale'),
                value: _voiceEnabled,
                activeColor: BatteColors.primary,
                onChanged: _toggleVoice,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // À propos
            const Text(
              'À propos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              decoration: BoxDecoration(
                color: BatteColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Version'),
                    trailing: const Text(AppConstants.appVersion),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('Conditions d\'utilisation'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Politique de confidentialité'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Aide et support'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FAQScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Fonctionnalités
            const Text(
              'Fonctionnalités',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Container(
              decoration: BoxDecoration(
                color: BatteColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined, color: BatteColors.primary),
                    title: const Text('Notifications'),
                    subtitle: const Text('Voir toutes les notifications'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotificationsListScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.emoji_events_outlined, color: BatteColors.secondary),
                    title: const Text('Missions quotidiennes'),
                    subtitle: const Text('Gagnez des points et badges'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MissionsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.leaderboard_outlined, color: BatteColors.chart1),
                    title: const Text('Classement'),
                    subtitle: const Text('Voir le leaderboard'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Déconnexion
            CustomButton(
              text: 'Se déconnecter',
              onPressed: _logout,
              backgroundColor: BatteColors.destructive,
              icon: Icons.logout,
            ),
            
            const SizedBox(height: 16),
            
            Center(
              child: Text(
                '© 2024 Battè - Guinée',
                style: const TextStyle(
                  fontSize: 12,
                  color: BatteColors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

