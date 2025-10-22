import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/helpers.dart';

/// Écran des détails des gains pour les collecteurs
class CollectorEarningsDetailsScreen extends StatefulWidget {
  const CollectorEarningsDetailsScreen({super.key});

  @override
  State<CollectorEarningsDetailsScreen> createState() => _CollectorEarningsDetailsScreenState();
}

class _CollectorEarningsDetailsScreenState extends State<CollectorEarningsDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = true;
  Map<String, dynamic> _earningsData = {};

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
    
    _loadEarningsData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadEarningsData() async {
    setState(() => _isLoading = true);

    try {
      // Simuler le chargement des données de gains
      await Future.delayed(const Duration(seconds: 1));
      
      final mockData = {
        'totalEarnings': 2500000.0,
        'monthlyEarnings': 450000.0,
        'weeklyEarnings': 125000.0,
        'dailyEarnings': 25000.0,
        'totalCollections': 156,
        'averagePerCollection': 16025.0,
        'topEarningDay': 'Jeudi',
        'topEarningMonth': 'Décembre',
        'withdrawals': [
          {'date': DateTime.now().subtract(const Duration(days: 5)), 'amount': 200000.0, 'method': 'Orange Money'},
          {'date': DateTime.now().subtract(const Duration(days: 15)), 'amount': 300000.0, 'method': 'MTN Money'},
          {'date': DateTime.now().subtract(const Duration(days: 25)), 'amount': 150000.0, 'method': 'Compte bancaire'},
        ],
        'monthlyBreakdown': [
          {'month': 'Janvier', 'earnings': 380000.0, 'collections': 45},
          {'month': 'Février', 'earnings': 420000.0, 'collections': 52},
          {'month': 'Mars', 'earnings': 450000.0, 'collections': 59},
        ],
      };

      if (mounted) {
        setState(() {
          _earningsData = mockData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement gains: $e');
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
          'Détails des gains',
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
                  // Résumé des gains
                  SliverToBoxAdapter(
                    child: _buildEarningsSummary(),
                  ),
                  
                  // Graphique des gains mensuels
                  SliverToBoxAdapter(
                    child: _buildMonthlyChart(),
                  ),
                  
                  // Détails par période
                  SliverToBoxAdapter(
                    child: _buildPeriodDetails(),
                  ),
                  
                  // Historique des retraits
                  SliverToBoxAdapter(
                    child: _buildWithdrawalsHistory(),
                  ),
                  
                  // Statistiques avancées
                  SliverToBoxAdapter(
                    child: _buildAdvancedStats(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEarningsSummary() {
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
            'Résumé des gains',
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
                child: _buildEarningsItem(
                  title: 'Total',
                  amount: _earningsData['totalEarnings'],
                  icon: Icons.account_balance_wallet_rounded,
                  color: BatteColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEarningsItem(
                  title: 'Ce mois',
                  amount: _earningsData['monthlyEarnings'],
                  icon: Icons.calendar_month_rounded,
                  color: BatteColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEarningsItem(
                  title: 'Cette semaine',
                  amount: _earningsData['weeklyEarnings'],
                  icon: Icons.date_range_rounded,
                  color: BatteColors.info,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEarningsItem(
                  title: 'Aujourd\'hui',
                  amount: _earningsData['dailyEarnings'],
                  icon: Icons.today_rounded,
                  color: BatteColors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsItem({
    required String title,
    required double amount,
    required IconData icon,
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
            '${amount.toStringAsFixed(0)} GNF',
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
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
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
            'Gains mensuels',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BatteColors.foreground,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _earningsData['monthlyBreakdown']?.length ?? 0,
              itemBuilder: (context, index) {
                final month = _earningsData['monthlyBreakdown'][index];
                final maxEarnings = _earningsData['monthlyBreakdown']
                    .map<double>((m) => m['earnings'] as double)
                    .reduce((a, b) => a > b ? a : b);
                final height = (month['earnings'] / maxEarnings) * 150;
                
                return Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: height,
                        width: 40,
                        decoration: BoxDecoration(
                          gradient: BatteColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        month['month'],
                        style: TextStyle(
                          fontSize: 12,
                          color: BatteColors.foreground.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        '${(month['earnings'] / 1000).toStringAsFixed(0)}k',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: BatteColors.foreground,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodDetails() {
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
            'Détails par période',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BatteColors.foreground,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailItem(
            icon: Icons.trending_up_rounded,
            title: 'Meilleur jour',
            value: _earningsData['topEarningDay'],
            subtitle: 'Généralement le plus rentable',
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            icon: Icons.calendar_today_rounded,
            title: 'Meilleur mois',
            value: _earningsData['topEarningMonth'],
            subtitle: 'Mois le plus rentable',
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            icon: Icons.analytics_rounded,
            title: 'Moyenne par collecte',
            value: '${_earningsData['averagePerCollection'].toStringAsFixed(0)} GNF',
            subtitle: 'Gain moyen par collecte',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
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
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: BatteColors.foreground,
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawalsHistory() {
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
                'Historique des retraits',
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
                      content: Text('Nouveau retrait bientôt disponible !'),
                      backgroundColor: BatteColors.primary,
                    ),
                  );
                },
                child: const Text('Nouveau retrait'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_earningsData['withdrawals'] as List).map((withdrawal) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BatteColors.softGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: BatteColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${withdrawal['amount'].toStringAsFixed(0)} GNF',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: BatteColors.foreground,
                          ),
                        ),
                        Text(
                          withdrawal['method'],
                          style: TextStyle(
                            fontSize: 12,
                            color: BatteColors.foreground.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    Helpers.formatDate(withdrawal['date']),
                    style: TextStyle(
                      fontSize: 12,
                      color: BatteColors.foreground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAdvancedStats() {
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
            'Statistiques avancées',
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
                  title: 'Total collectes',
                  value: '${_earningsData['totalCollections']}',
                  icon: Icons.recycling_rounded,
                  color: BatteColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  title: 'Gain moyen/jour',
                  value: '${(_earningsData['totalEarnings'] / 30).toStringAsFixed(0)} GNF',
                  icon: Icons.trending_up_rounded,
                  color: BatteColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
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
}
