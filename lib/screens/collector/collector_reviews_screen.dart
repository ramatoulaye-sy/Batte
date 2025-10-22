import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/helpers.dart';

/// Écran des évaluations et avis pour les collecteurs
class CollectorReviewsScreen extends StatefulWidget {
  const CollectorReviewsScreen({super.key});

  @override
  State<CollectorReviewsScreen> createState() => _CollectorReviewsScreenState();
}

class _CollectorReviewsScreenState extends State<CollectorReviewsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = true;
  Map<String, dynamic> _reviewsData = {};

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
    
    _loadReviewsData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadReviewsData() async {
    setState(() => _isLoading = true);

    try {
      // Simuler le chargement des données d'évaluations
      await Future.delayed(const Duration(seconds: 1));
      
      final mockData = {
        'overallRating': 4.8,
        'totalReviews': 47,
        'ratingBreakdown': {
          '5': 35,
          '4': 8,
          '3': 3,
          '2': 1,
          '1': 0,
        },
        'recentReviews': [
          {
            'id': '1',
            'clientName': 'Fatoumata Diallo',
            'rating': 5,
            'comment': 'Service excellent ! Très ponctuel et professionnel. Je recommande vivement.',
            'date': DateTime.now().subtract(const Duration(days: 2)),
            'collectionId': 'COL-001',
          },
          {
            'id': '2',
            'clientName': 'Mamadou Bah',
            'rating': 4,
            'comment': 'Bon service, un peu en retard mais le travail était bien fait.',
            'date': DateTime.now().subtract(const Duration(days: 5)),
            'collectionId': 'COL-002',
          },
          {
            'id': '3',
            'clientName': 'Aminata Camara',
            'rating': 5,
            'comment': 'Parfait ! Très respectueux de l\'environnement et efficace.',
            'date': DateTime.now().subtract(const Duration(days: 8)),
            'collectionId': 'COL-003',
          },
          {
            'id': '4',
            'clientName': 'Ibrahima Sow',
            'rating': 5,
            'comment': 'Service impeccable, je ferai appel à nouveau.',
            'date': DateTime.now().subtract(const Duration(days: 12)),
            'collectionId': 'COL-004',
          },
          {
            'id': '5',
            'clientName': 'Mariama Barry',
            'rating': 4,
            'comment': 'Très bien, juste un petit retard mais acceptable.',
            'date': DateTime.now().subtract(const Duration(days: 15)),
            'collectionId': 'COL-005',
          },
        ],
        'averageResponseTime': '15 min',
        'completionRate': 98.5,
        'repeatCustomers': 23,
      };

      if (mounted) {
        setState(() {
          _reviewsData = mockData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement évaluations: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BatteColors.softGreen,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: BatteColors.foreground),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Mes évaluations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: BatteColors.foreground,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: BatteColors.primary,
                ),
              )
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Résumé des évaluations
                  SliverToBoxAdapter(
                    child: _buildRatingSummary(),
                  ),
                  
                  // Répartition des notes
                  SliverToBoxAdapter(
                    child: _buildRatingBreakdown(),
                  ),
                  
                  // Statistiques de performance
                  SliverToBoxAdapter(
                    child: _buildPerformanceStats(),
                  ),
                  
                  // Liste des avis récents
                  SliverToBoxAdapter(
                    child: _buildRecentReviews(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      margin: const EdgeInsets.all(20),
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
        children: [
          // Note globale
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: BatteColors.goldGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: BatteColors.gold.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _reviewsData['overallRating'].toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < _reviewsData['overallRating'].floor()
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: BatteColors.gold,
                          size: 24,
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_reviewsData['totalReviews']} avis clients',
                      style: TextStyle(
                        fontSize: 16,
                        color: BatteColors.foreground.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Excellent service',
                      style: TextStyle(
                        fontSize: 14,
                        color: BatteColors.foreground.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
          const Text(
            'Répartition des notes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BatteColors.foreground,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(5, (index) {
            final rating = 5 - index;
            final count = _reviewsData['ratingBreakdown'][rating.toString()] ?? 0;
            final percentage = _reviewsData['totalReviews'] > 0 
                ? (count / _reviewsData['totalReviews']) * 100 
                : 0.0;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(
                    '$rating',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: BatteColors.foreground,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.star_rounded,
                    color: BatteColors.gold,
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        BatteColors.gold.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 14,
                      color: BatteColors.foreground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPerformanceStats() {
    return Container(
      margin: const EdgeInsets.all(20),
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
          const Text(
            'Statistiques de performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BatteColors.foreground,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.timer_rounded,
                  title: 'Temps de réponse',
                  value: _reviewsData['averageResponseTime'],
                  color: BatteColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle_rounded,
                  title: 'Taux de réussite',
                  value: '${_reviewsData['completionRate']}%',
                  color: BatteColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.repeat_rounded,
                  title: 'Clients récurrents',
                  value: '${_reviewsData['repeatCustomers']}',
                  color: BatteColors.info,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.thumb_up_rounded,
                  title: 'Satisfaction',
                  value: '${(_reviewsData['overallRating'] * 20).toStringAsFixed(0)}%',
                  color: BatteColors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: BatteColors.foreground,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: BatteColors.foreground.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReviews() {
    return Container(
      margin: const EdgeInsets.all(20),
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
              const Text(
                'Avis récents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: BatteColors.foreground,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Voir tous les avis bientôt disponible !'),
                      backgroundColor: BatteColors.primary,
                    ),
                  );
                },
                child: const Text('Voir tout'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_reviewsData['recentReviews'] as List).map((review) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BatteColors.softGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: BatteColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            review['clientName'][0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['clientName'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: BatteColors.foreground,
                              ),
                            ),
                            Row(
                              children: [
                                ...List.generate(5, (index) {
                                  return Icon(
                                    index < review['rating']
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    color: BatteColors.gold,
                                    size: 16,
                                  );
                                }),
                                const SizedBox(width: 8),
                                Text(
                                  Helpers.formatDate(review['date']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: BatteColors.foreground.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    review['comment'],
                    style: TextStyle(
                      fontSize: 14,
                      color: BatteColors.foreground.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.recycling_rounded,
                        color: BatteColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        review['collectionId'],
                        style: TextStyle(
                          fontSize: 12,
                          color: BatteColors.foreground.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
