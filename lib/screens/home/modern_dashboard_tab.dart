import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/waste_provider.dart';
import '../../widgets/modern_app_header.dart';
import '../../widgets/modern_balance_card.dart';
import '../../widgets/eco_progress_card.dart';
import '../../widgets/modern_earnings_chart.dart';
import '../recycling/modern_recycling_screen.dart';
import '../budget/modern_budget_screen.dart';
import '../education/modern_education_screen.dart';
import '../gamification/modern_missions_screen.dart';
import '../notifications/notifications_screen.dart';
import '../settings/settings_screen.dart';
import '../map/interactive_map_screen.dart';

/// Dashboard moderne avec UI/UX gamifiée
class ModernDashboardTab extends StatefulWidget {
  const ModernDashboardTab({Key? key}) : super(key: key);

  @override
  State<ModernDashboardTab> createState() => _ModernDashboardTabState();
}

class _ModernDashboardTabState extends State<ModernDashboardTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    // Marquer que le premier chargement est terminé
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isFirstLoad = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final wasteProvider = Provider.of<WasteProvider>(context, listen: false);
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await Future.wait([
      wasteProvider.fetchWastes(),
      wasteProvider.fetchStats(),
      budgetProvider.fetchTransactions(),
      budgetProvider.fetchStats(),
      authProvider.refreshProfile(),
    ]);
  }

  List<double> _getWeeklyEarnings(BudgetProvider provider) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    final earnings = List<double>.filled(7, 0.0);

    for (var transaction in provider.transactions) {
      if (transaction.type == 'recycling') {
        final daysDiff = transaction.date.difference(weekStart).inDays;
        if (daysDiff >= 0 && daysDiff < 7) {
          earnings[daysDiff] += transaction.amount;
        }
      }
    }

    return earnings;
  }

  /// Calcule le score écologique basé sur les déchets recyclés
  int _calculateEcoScore(BudgetProvider budgetProvider) {
    // 1 point écologique pour chaque 1000 GNF gagnés
    final totalEarnings = budgetProvider.transactions
        .where((t) => t.type == 'recycling')
        .fold(0.0, (sum, t) => sum + t.amount);
    
    return (totalEarnings / 1000).round();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final wasteProvider = Provider.of<WasteProvider>(context);
    final user = authProvider.user;

    // Loader pendant le premier chargement
    if (_isFirstLoad && user == null) {
      return Scaffold(
        backgroundColor: BatteColors.softGreen,
        body: Center(
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
                'Chargement de vos données...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: BatteColors.foreground,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: BatteColors.softGreen,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: BatteColors.primary,
          backgroundColor: Colors.white,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header fixe moderne
              SliverToBoxAdapter(
                child: ModernAppHeader(
                  userName: user?.name ?? 'Utilisateur',
                  notificationCount: 0, // À connecter avec le vrai compteur
                  onNotificationTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                  onSettingsTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ),

              // Contenu scrollable
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Carte de solde moderne
                    ModernBalanceCard(
                      balance: budgetProvider.totalBalance, // ✅ Solde calculé depuis les transactions
                      monthlyEarnings: budgetProvider.monthlyEarnings, // ✅ Gains réels du mois
                      ecoScore: _calculateEcoScore(budgetProvider), // ✅ Score calculé depuis les déchets
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ModernBudgetScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Carte de progression écologique
                    EcoProgressCard(
                      ecoScore: _calculateEcoScore(budgetProvider),
                      onTap: () {
                        // Afficher plus de détails sur les niveaux
                        _showLevelsInfo(context);
                      },
                    ),

                    const SizedBox(height: 20),

                    // Graphique des gains hebdomadaires
                    ModernEarningsChart(
                      weeklyEarnings: _getWeeklyEarnings(budgetProvider),
                    ),

                    const SizedBox(height: 20),

                    // Carte des collecteurs proches
                    _buildCollectorsMapCard(context),

                    const SizedBox(height: 32),

                    // Section Statistiques
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Vos statistiques',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: BatteColors.foreground,
                            ),
                          ),
                          Icon(
                            Icons.bar_chart_rounded,
                            color: BatteColors.primary,
                            size: 28,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Grille de statistiques
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.1,
                        children: [
                          _buildModernStatCard(
                            icon: Icons.recycling_rounded,
                            title: 'Poids recyclé',
                            value: Helpers.formatWeight(wasteProvider.totalWeight),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF38761D), Color(0xFF4A8F2A)],
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ModernRecyclingScreen(),
                                ),
                              );
                            },
                          ),
                          _buildModernStatCard(
                            icon: Icons.account_balance_wallet_rounded,
                            title: 'Transactions',
                            value: '${budgetProvider.transactions.length}',
                            gradient: BatteColors.goldGradient,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ModernBudgetScreen(),
                                ),
                              );
                            },
                          ),
                          _buildModernStatCard(
                            icon: Icons.map_rounded,
                            title: 'Carte',
                            value: 'Explorer',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3498DB), Color(0xFF5DADE2)],
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const InteractiveMapScreen(),
                                ),
                              );
                            },
                          ),
                          _buildModernStatCard(
                            icon: Icons.school_rounded,
                            title: 'Éducation',
                            value: 'Apprendre',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ModernEducationScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Section Actions rapides
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Actions rapides',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: BatteColors.foreground,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildQuickAction(
                            icon: Icons.recycling,
                            title: 'Recycler maintenant',
                            subtitle: 'Scanner un déchet',
                            color: BatteColors.primary,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ModernRecyclingScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildQuickAction(
                            icon: Icons.emoji_events,
                            title: 'Missions du jour',
                            subtitle: 'Gagnez des points',
                            color: const Color(0xFFF7E2AC),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ModernMissionsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100), // Espace pour la barre de navigation
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Gradient gradient,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: color == const Color(0xFFF7E2AC)
                    ? BatteColors.foreground
                    : color,
                size: 28,
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: BatteColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: BatteColors.foreground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: BatteColors.foreground.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  void _showLevelsInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Niveaux écologiques',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: BatteColors.foreground,
                ),
              ),
              const SizedBox(height: 20),
              _buildLevelItem('🌱 Débutant', '0 - 99 pts'),
              _buildLevelItem('🥉 Bronze', '100 - 199 pts'),
              _buildLevelItem('🥈 Argent', '200 - 499 pts'),
              _buildLevelItem('🥇 Or', '500 - 999 pts'),
              _buildLevelItem('🏆 Légende', '1000+ pts'),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevelItem(String level, String points) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            level,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: BatteColors.foreground,
            ),
          ),
          Text(
            points,
            style: TextStyle(
              fontSize: 14,
              color: BatteColors.foreground.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectorsMapCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF5DADE2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3498DB).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const InteractiveMapScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.map_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Collecteurs Proches',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Trouvez les collecteurs près de vous',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Illustration carte avec points
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Simuler une carte avec des points
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMapPin(Icons.location_on, '2.5 km', Colors.white),
                            _buildMapPin(Icons.local_shipping, '3.8 km', const Color(0xFFF7E2AC)),
                            _buildMapPin(Icons.location_on, '5.1 km', Colors.white),
                          ],
                        ),
                      ),
                      // Overlay "Voir la carte"
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.explore,
                                size: 16,
                                color: Color(0xFF3498DB),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Voir la carte',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3498DB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildCollectorInfo(
                        Icons.people_rounded,
                        'Collecteurs',
                        '8 disponibles',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCollectorInfo(
                        Icons.location_city_rounded,
                        'Points fixes',
                        '3 centres',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapPin(IconData icon, String distance, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: color,
          size: 32,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            distance,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3498DB),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollectorInfo(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

