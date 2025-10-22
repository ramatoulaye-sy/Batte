import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/helpers.dart';
import '../../services/supabase_service.dart';

/// Écran de parrainage
class ReferralScreen extends StatefulWidget {
  const ReferralScreen({Key? key}) : super(key: key);

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  String _referralCode = '';
  int _referralCount = 0;
  double _referralEarnings = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    setState(() => _isLoading = true);
    
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return;

      // Générer ou récupérer le code de parrainage
      _referralCode = user.id.substring(0, 8).toUpperCase();

      // Compter les parrainages (TODO: requête réelle)
      _referralCount = 0;
      _referralEarnings = 0;

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parrainez vos amis'),
        backgroundColor: BatteColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Illustration
                  Icon(
                    Icons.people,
                    size: 80,
                    color: BatteColors.primary,
                  ),
                  const SizedBox(height: 24),

                  // Titre
                  const Text(
                    'Gagnez 5000 GNF par ami !',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Partagez votre code et gagnez des récompenses '
                    'quand vos amis s\'inscrivent et recyclent',
                    style: TextStyle(
                      fontSize: 14,
                      color: BatteColors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Code de parrainage
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [BatteColors.primary, BatteColors.success],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Votre code de parrainage',
                          style: TextStyle(
                            color: BatteColors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _referralCode,
                              style: const TextStyle(
                                color: BatteColors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: _copyCode,
                              icon: const Icon(Icons.copy, color: BatteColors.white),
                              tooltip: 'Copier',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Amis parrainés',
                          '$_referralCount',
                          Icons.people,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child:                         _buildStatCard(
                          'Gains totaux',
                          Helpers.formatCurrency(_referralEarnings),
                          Icons.payments_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Bouton partager
                  ElevatedButton.icon(
                    onPressed: _shareReferralCode,
                    icon: const Icon(Icons.share),
                    label: const Text('Partager mon code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BatteColors.secondary,
                      foregroundColor: BatteColors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Comment ça marche
                  const Text(
                    'Comment ça marche ?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildStep(1, 'Partagez votre code', Icons.share),
                  _buildStep(2, 'Votre ami s\'inscrit avec votre code', Icons.person_add),
                  _buildStep(3, 'Il recycle pour la première fois', Icons.recycling),
                  _buildStep(4, 'Vous gagnez tous les deux 5000 GNF !', Icons.celebration),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BatteColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BatteColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: BatteColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: BatteColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: BatteColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: BatteColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: BatteColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(icon, color: BatteColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: _referralCode));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Code copié !'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareReferralCode() async {
    final message = '🌱 Rejoins-moi sur Battè et gagne de l\'argent en recyclant ! '
        'Utilise mon code $_referralCode pour gagner 5000 GNF de bonus ! '
        '♻️ Télécharge l\'app : [lien]';
    
    // TODO: Implémenter partage avec share_plus
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Partage : $message')),
      );
    }
  }
}

