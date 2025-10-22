import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/supabase_service.dart';
import '../../widgets/modern_balance_card.dart';
import '../../widgets/modern_earnings_chart.dart';
import 'collector_history_screen.dart';
import 'collector_settings_screen.dart';
import 'collector_earnings_details_screen.dart';
import 'collector_reviews_screen.dart';
import 'collector_vehicle_screen.dart';
import 'collector_requests_screen.dart';

/// Dashboard moderne pour les collecteurs avec design gamifié
class ModernCollectorDashboard extends StatefulWidget {
  const ModernCollectorDashboard({super.key});

  @override
  State<ModernCollectorDashboard> createState() => _ModernCollectorDashboardState();
}

class _ModernCollectorDashboardState extends State<ModernCollectorDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  Map<String, dynamic>? _collectorData;
  bool _isLoading = true;
  bool _isAvailable = true;
  List<double> _weeklyEarnings = List.filled(7, 0.0);

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
    
    _checkProfileAndLoadData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkProfileAndLoadData() async {
    final profiles = await SupabaseService.getUserProfiles();
    
    if (profiles.contains('user') && !profiles.contains('collector')) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
      return;
    }
    
    _loadCollectorData();
  }

  Future<void> _loadCollectorData() async {
    setState(() => _isLoading = true);

    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      final response = await SupabaseService.client
          .from('collectors')
          .select()
          .eq('user_id', userId)
          .single();

      if (mounted) {
        setState(() {
          _collectorData = response;
          _isAvailable = response['is_available'] ?? true;
          _isLoading = false;
        });
        
        // Simuler des gains hebdomadaires
        _generateWeeklyEarnings();
      }
    } catch (e) {
      print('❌ Erreur chargement collecteur: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _generateWeeklyEarnings() {
    // Simuler des gains hebdomadaires basés sur les collectes
    final totalEarnings = (_collectorData?['total_earnings'] ?? 0).toDouble();
    final monthlyEarnings = totalEarnings * 0.3; // 30% du total
    
    _weeklyEarnings = [
      monthlyEarnings * 0.15, // Lundi
      monthlyEarnings * 0.20, // Mardi
      monthlyEarnings * 0.10, // Mercredi
      monthlyEarnings * 0.25, // Jeudi
      monthlyEarnings * 0.15, // Vendredi
      monthlyEarnings * 0.10, // Samedi
      monthlyEarnings * 0.05, // Dimanche
    ];
  }

  Future<void> _toggleAvailability() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      final newStatus = !_isAvailable;

      await SupabaseService.client
          .from('collectors')
          .update({'is_available': newStatus})
          .eq('user_id', userId);

      setState(() => _isAvailable = newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                  ? '✅ Vous êtes maintenant disponible'
                  : '⏸️ Vous êtes maintenant indisponible',
            ),
            backgroundColor: BatteColors.success,
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur toggle: $e');
    }
  }

  Future<void> _refreshData() async {
    await _loadCollectorData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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

    if (_collectorData == null) {
      return Scaffold(
        backgroundColor: BatteColors.softGreen,
        body: const Center(
          child: Text('Aucune donnée collecteur'),
        ),
      );
    }

    final businessName = _collectorData!['business_name'] ?? 'Mon Business';
    final rating = (_collectorData!['rating'] ?? 0.0).toDouble();
    final totalCollections = _collectorData!['total_collections'] ?? 0;
    final totalEarnings = (_collectorData!['total_earnings'] ?? 0).toDouble();
    final monthlyEarnings = totalEarnings * 0.3;
    final collectorLevel = _calculateCollectorLevel(totalCollections);

    return Container(
      color: BatteColors.softGreen,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: BatteColors.primary,
          backgroundColor: Colors.white,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header moderne pour collecteur
              SliverToBoxAdapter(
                child: _buildCollectorHeader(businessName, rating),
              ),

              // Contenu scrollable
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Carte de gains moderne
                    ModernBalanceCard(
                      balance: totalEarnings,
                      monthlyEarnings: monthlyEarnings,
                      ecoScore: totalCollections, // Utiliser les collectes comme "score"
                      onTap: () {
                        // Navigation vers détails des gains
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CollectorEarningsDetailsScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Carte de progression collecteur
                    _buildCollectorProgressCard(collectorLevel, totalCollections),

                    const SizedBox(height: 20),

                    // Graphique des gains hebdomadaires
                    ModernEarningsChart(
                      weeklyEarnings: _weeklyEarnings,
                    ),

                    const SizedBox(height: 32),

                    // Section Statistiques collecteur
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
                            Icons.local_shipping,
                            color: BatteColors.primary,
                            size: 28,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Grille de statistiques collecteur
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
                            title: 'Collectes',
                            value: '$totalCollections',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF38761D), Color(0xFF4A8F2A)],
                            ),
                            onTap: () {
                              // Navigation vers historique des collectes
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const CollectorHistoryScreen(),
                                ),
                              );
                            },
                          ),
                          _buildModernStatCard(
                            icon: Icons.star_rounded,
                            title: 'Note',
                            value: rating.toStringAsFixed(1),
                            gradient: BatteColors.goldGradient,
                            onTap: () {
                              // Navigation vers détails des évaluations
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const CollectorReviewsScreen(),
                                ),
                              );
                            },
                          ),
                          _buildModernStatCard(
                            icon: Icons.map_rounded,
                            title: 'Rayon',
                            value: '${_collectorData!['service_area_radius'] ?? 0} km',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3498DB), Color(0xFF5DADE2)],
                            ),
                            onTap: () {
                              // Navigation vers paramètres pour modifier le rayon
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const CollectorSettingsScreen(),
                                ),
                              );
                            },
                          ),
                          _buildModernStatCard(
                            icon: Icons.local_shipping_rounded,
                            title: 'Véhicule',
                            value: 'Voir',
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                            ),
                            onTap: () {
                              // Navigation vers gestion véhicule
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const CollectorVehicleScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Section Actions rapides collecteur
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
                            icon: Icons.notifications_active,
                            title: 'Nouvelles demandes',
                            subtitle: 'Voir les demandes de collecte',
                            color: BatteColors.primary,
                            onTap: () {
                              // Navigation vers demandes de collecte
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const CollectorRequestsScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildQuickAction(
                            icon: Icons.history,
                            title: 'Historique',
                            subtitle: 'Voir vos collectes passées',
                            color: const Color(0xFFF7E2AC),
                            onTap: () {
                              // Navigation vers historique
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const CollectorHistoryScreen(),
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

  Widget _buildCollectorHeader(String businessName, double rating) {
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
          // Logo collecteur
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: BatteColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: BatteColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_shipping,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // Infos collecteur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour',
                  style: TextStyle(
                    fontSize: 13,
                    color: BatteColors.foreground.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  businessName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: BatteColors.foreground,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Statut disponibilité
          GestureDetector(
            onTap: _toggleAvailability,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isAvailable 
                    ? BatteColors.success.withOpacity(0.2)
                    : BatteColors.destructive.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isAvailable ? Icons.toggle_on : Icons.toggle_off,
                color: _isAvailable ? BatteColors.success : BatteColors.destructive,
                size: 22,
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Note
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: BatteColors.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: BatteColors.foreground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectorProgressCard(Map<String, dynamic> levelInfo, int totalCollections) {
    final progress = levelInfo['progress'] as double;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: BatteColors.ecoCardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: BatteColors.lightGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Niveau collecteur',
                    style: TextStyle(
                      fontSize: 13,
                      color: BatteColors.foreground.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        levelInfo['emoji'],
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        levelInfo['level'],
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: BatteColors.foreground,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
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
                child: Column(
                  children: [
                    Text(
                      '$totalCollections',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: levelInfo['color'],
                      ),
                    ),
                    Text(
                      'collectes',
                      style: TextStyle(
                        fontSize: 11,
                        color: BatteColors.foreground.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prochain niveau: ${levelInfo['nextLevel']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: BatteColors.foreground.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${totalCollections} / ${levelInfo['target']}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: levelInfo['color'],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              levelInfo['color'],
                              levelInfo['color'].withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: levelInfo['color'].withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (progress < 1.0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_shipping,
                    size: 16,
                    color: BatteColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getCollectorMotivationalMessage(progress),
                      style: const TextStyle(
                        fontSize: 11,
                        color: BatteColors.foreground,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateCollectorLevel(int totalCollections) {
    if (totalCollections >= 1000) {
      return {
        'level': 'Légende',
        'emoji': '🏆',
        'color': const Color(0xFFFFD700),
        'nextLevel': 'Max',
        'current': totalCollections,
        'target': 1000,
        'progress': 1.0,
      };
    } else if (totalCollections >= 500) {
      return {
        'level': 'Expert',
        'emoji': '🥇',
        'color': const Color(0xFFFFD700),
        'nextLevel': 'Légende',
        'current': totalCollections,
        'target': 1000,
        'progress': (totalCollections - 500) / 500,
      };
    } else if (totalCollections >= 200) {
      return {
        'level': 'Professionnel',
        'emoji': '🥈',
        'color': const Color(0xFFC0C0C0),
        'nextLevel': 'Expert',
        'current': totalCollections,
        'target': 500,
        'progress': (totalCollections - 200) / 300,
      };
    } else if (totalCollections >= 50) {
      return {
        'level': 'Confirmé',
        'emoji': '🥉',
        'color': const Color(0xFFCD7F32),
        'nextLevel': 'Professionnel',
        'current': totalCollections,
        'target': 200,
        'progress': (totalCollections - 50) / 150,
      };
    } else {
      return {
        'level': 'Débutant',
        'emoji': '🚛',
        'color': BatteColors.primary,
        'nextLevel': 'Confirmé',
        'current': totalCollections,
        'target': 50,
        'progress': totalCollections / 50,
      };
    }
  }

  String _getCollectorMotivationalMessage(double progress) {
    if (progress >= 0.75) {
      return 'Tu es un collecteur exceptionnel ! Continue ! 🚛';
    } else if (progress >= 0.5) {
      return 'Excellent travail ! Garde le rythme ! 💪';
    } else if (progress >= 0.25) {
      return 'Bon début ! Chaque collecte compte ! 🌍';
    } else {
      return 'Commence à collecter pour monter de niveau ! ♻️';
    }
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
}

