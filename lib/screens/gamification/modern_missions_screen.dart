import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/helpers.dart';
import '../../services/supabase_service.dart';

/// Écran des missions moderne avec design harmonisé
class ModernMissionsScreen extends StatefulWidget {
  const ModernMissionsScreen({Key? key}) : super(key: key);

  @override
  State<ModernMissionsScreen> createState() => _ModernMissionsScreenState();
}

class _ModernMissionsScreenState extends State<ModernMissionsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<Map<String, dynamic>> _dailyMissions = [];
  List<Map<String, dynamic>> _weeklyMissions = [];
  bool _isLoading = true;
  int _totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _loadMissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMissions() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      // Missions quotidiennes
      _dailyMissions = [
        {
          'id': '1',
          'title': 'Recycler 5 kg de déchets',
          'description': 'Recyclez au moins 5 kg aujourd\'hui',
          'reward': 5000.0,
          'points': 50,
          'progress': 0.4,
          'target': 5.0,
          'current': 2.0,
          'unit': 'kg',
          'icon': Icons.recycling_rounded,
          'gradient': const LinearGradient(
            colors: [Color(0xFF38761D), Color(0xFF4A8F2A)],
          ),
          'isCompleted': false,
        },
        {
          'id': '2',
          'title': 'Scanner 3 fois',
          'description': 'Utilisez le scanner Bluetooth 3 fois',
          'reward': 2000.0,
          'points': 30,
          'progress': 0.66,
          'target': 3.0,
          'current': 2.0,
          'unit': 'scans',
          'icon': Icons.qr_code_scanner_rounded,
          'gradient': const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          ),
          'isCompleted': false,
        },
        {
          'id': '3',
          'title': 'Appeler un collecteur',
          'description': 'Contactez un collecteur pour une collecte',
          'reward': 1000.0,
          'points': 20,
          'progress': 0.0,
          'target': 1.0,
          'current': 0.0,
          'unit': 'appel',
          'icon': Icons.phone_rounded,
          'gradient': BatteColors.goldGradient,
          'isCompleted': false,
        },
      ];

      // Missions hebdomadaires
      _weeklyMissions = [
        {
          'id': 'w1',
          'title': 'Recycler 20 kg cette semaine',
          'description': 'Objectif hebdomadaire de recyclage',
          'reward': 20000.0,
          'points': 200,
          'progress': 0.35,
          'target': 20.0,
          'current': 7.0,
          'unit': 'kg',
          'icon': Icons.trending_up_rounded,
          'gradient': const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          ),
          'isCompleted': false,
        },
        {
          'id': 'w2',
          'title': 'Recycler 5 types différents',
          'description': 'Variez vos déchets recyclés',
          'reward': 10000.0,
          'points': 100,
          'progress': 0.6,
          'target': 5.0,
          'current': 3.0,
          'unit': 'types',
          'icon': Icons.category_rounded,
          'gradient': const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          ),
          'isCompleted': false,
        },
        {
          'id': 'w3',
          'title': 'Atteindre 100 points Eco-Score',
          'description': 'Augmentez votre impact environnemental',
          'reward': 15000.0,
          'points': 150,
          'progress': 0.45,
          'target': 100.0,
          'current': 45.0,
          'unit': 'points',
          'icon': Icons.eco_rounded,
          'gradient': const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
          ),
          'isCompleted': false,
        },
      ];

      // Calculer les points totaux disponibles
      _totalPoints = _dailyMissions.fold(0, (sum, m) => sum + (m['points'] as int)) +
                      _weeklyMissions.fold(0, (sum, m) => sum + (m['points'] as int));

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
      backgroundColor: BatteColors.softGreen,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: BatteColors.primary.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(BatteColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chargement des missions...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: BatteColors.foreground,
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header moderne
                  SliverToBoxAdapter(
                    child: _buildModernHeader(),
                  ),

                  // Contenu
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 24),

                        // Carte de points totaux
                        _buildPointsCard(),

                        const SizedBox(height: 24),

                        // Onglets personnalisés
                        _buildCustomTabs(),

                        const SizedBox(height: 20),

                        // Liste des missions
                        _tabController.index == 0
                            ? _buildMissionsList(_dailyMissions, 'Quotidiennes')
                            : _buildMissionsList(_weeklyMissions, 'Hebdomadaires'),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildModernHeader() {
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
          // Bouton retour
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: BatteColors.lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: BatteColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Titre
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Missions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: BatteColors.foreground,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Gagnez des points et de l\'argent',
                  style: TextStyle(
                    fontSize: 13,
                    color: BatteColors.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Badge trophée
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: BatteColors.goldGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: BatteColors.gold.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: BatteColors.foreground,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
    final completedDaily = _dailyMissions.where((m) => m['isCompleted'] == true).length;
    final completedWeekly = _weeklyMissions.where((m) => m['isCompleted'] == true).length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: BatteColors.goldGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: BatteColors.gold.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: BatteColors.foreground.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: BatteColors.foreground,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Points disponibles',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: BatteColors.foreground,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Terminez toutes les missions',
                      style: TextStyle(
                        fontSize: 11,
                        color: BatteColors.mutedForeground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$_totalPoints pts',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: BatteColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  Icons.today_rounded,
                  'Quotidiennes',
                  '$completedDaily/${_dailyMissions.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStat(
                  Icons.calendar_month_rounded,
                  'Hebdomadaires',
                  '$completedWeekly/${_weeklyMissions.length}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: BatteColors.foreground, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: BatteColors.foreground,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: BatteColors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton(0, 'Quotidiennes', Icons.today_rounded),
            ),
            Expanded(
              child: _buildTabButton(1, 'Hebdomadaires', Icons.calendar_month_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _tabController.index == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.index = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? BatteColors.primaryGradient
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : BatteColors.mutedForeground,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : BatteColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionsList(List<Map<String, dynamic>> missions, String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Missions $type',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BatteColors.foreground,
            ),
          ),
          const SizedBox(height: 16),
          ...missions.map((mission) => _buildModernMissionCard(mission)).toList(),
        ],
      ),
    );
  }

  Widget _buildModernMissionCard(Map<String, dynamic> mission) {
    final progress = mission['progress'] as double;
    final isCompleted = mission['isCompleted'] as bool;
    final gradient = mission['gradient'] as Gradient;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          // Header avec gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    mission['icon'] as IconData,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mission['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Progression
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progression',
                      style: TextStyle(
                        fontSize: 12,
                        color: BatteColors.foreground.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${mission['current']} / ${mission['target']} ${mission['unit']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: BatteColors.foreground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: BatteColors.muted,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? BatteColors.success : BatteColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Récompenses
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: BatteColors.gold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.paid_rounded,
                              color: BatteColors.success,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              Helpers.formatCurrency(mission['reward']),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: BatteColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: BatteColors.lightGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            color: BatteColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+${mission['points']} pts',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: BatteColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (isCompleted) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _claimReward(mission),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BatteColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.redeem_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Récupérer la récompense',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _claimReward(Map<String, dynamic> mission) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '✨ +${Helpers.formatCurrency(mission['reward'])} et +${mission['points']} points gagnés !',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: BatteColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

