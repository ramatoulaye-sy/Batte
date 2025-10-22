import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/helpers.dart';
import '../../providers/budget_provider.dart';
import 'enhanced_transactions_screen.dart';
import 'withdrawal_methods_screen.dart';

/// Écran Budget moderne avec design harmonisé
class ModernBudgetScreen extends StatefulWidget {
  const ModernBudgetScreen({Key? key}) : super(key: key);
  
  @override
  State<ModernBudgetScreen> createState() => _ModernBudgetScreenState();
}

class _ModernBudgetScreenState extends State<ModernBudgetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
      
      // 1. Charger d'abord les données locales pour affichage immédiat
      budgetProvider.loadLocalTransactions();
      
      // 2. Ensuite essayer de synchroniser avec le serveur
      budgetProvider.fetchTransactions();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    
    // 1. Charger d'abord les données locales
    await budgetProvider.loadLocalTransactions();
    
    // 2. Ensuite synchroniser avec le serveur
    await budgetProvider.fetchTransactions();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BatteColors.softGreen,
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          if (budgetProvider.isLoading && budgetProvider.transactions.isEmpty) {
            return Center(
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
                    'Chargement de votre budget...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: BatteColors.foreground,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: _refreshData,
              color: BatteColors.primary,
              backgroundColor: Colors.white,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header moderne
                  SliverToBoxAdapter(
                    child: _buildModernHeader(),
                  ),
                  
                  // Contenu
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 24),

                        // Carte de solde moderne
                        _buildModernBalanceCard(budgetProvider),
                        
                        const SizedBox(height: 20),
                        
                        // Boutons d'action rapide
                        _buildQuickActions(),
                        
                        const SizedBox(height: 24),
                        
                        // Statistiques revenus/dépenses
                        _buildModernStats(budgetProvider),
                        
                        const SizedBox(height: 24),
                        
                        // Graphique d'évolution
                        _buildModernChart(budgetProvider),
                        
                        const SizedBox(height: 32),
                        
                        // Transactions récentes
                        _buildRecentTransactions(budgetProvider),
                        
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
          // Logo budget
          Container(
            width: 44,
            height: 44,
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
              Icons.account_balance_wallet_rounded,
              color: BatteColors.foreground,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // Titre
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Budget',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: BatteColors.foreground,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Gérez vos finances intelligemment',
                  style: TextStyle(
                    fontSize: 13,
                    color: BatteColors.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBalanceCard(BudgetProvider budgetProvider) {
    return Container(
      padding: const EdgeInsets.all(28),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Icons.account_balance_wallet,
                      color: BatteColors.foreground,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Solde disponible',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: BatteColors.foreground,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: BatteColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 14,
                      color: BatteColors.success.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Actif',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: BatteColors.success.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            Helpers.formatCurrency(budgetProvider.balance),
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: BatteColors.foreground,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 14,
                color: BatteColors.mutedForeground,
              ),
              const SizedBox(width: 6),
              Text(
                'Mis à jour en temps réel',
                style: TextStyle(
                  fontSize: 12,
                  color: BatteColors.foreground.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.arrow_circle_down,
            label: 'Retirer',
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WithdrawalMethodsScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.history_rounded,
            label: 'Historique',
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EnhancedTransactionsScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStats(BudgetProvider budgetProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildModernStatCard(
            icon: Icons.arrow_upward_rounded,
            title: 'Revenus',
            value: Helpers.formatCurrency(budgetProvider.totalIncome),
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildModernStatCard(
            icon: Icons.arrow_downward_rounded,
            title: 'Dépenses',
            value: Helpers.formatCurrency(budgetProvider.totalExpenses),
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernChart(BudgetProvider budgetProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: BatteColors.lightGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: BatteColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Évolution mensuelle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: BatteColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _buildLineChart(budgetProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(BudgetProvider budgetProvider) {
    // Données simulées pour le graphique
    final spots = List.generate(7, (index) {
      return FlSpot(
        index.toDouble(),
        (budgetProvider.balance / 7) + (index * 1000),
      );
    });

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: BatteColors.muted.withOpacity(0.3),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[value.toInt()],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: BatteColors.foreground.withOpacity(0.6),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [Color(0xFF38761D), Color(0xFF4A8F2A)],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: BatteColors.primary,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  BatteColors.primary.withOpacity(0.2),
                  BatteColors.primary.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BudgetProvider budgetProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: BatteColors.lightGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: BatteColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Transactions récentes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: BatteColors.foreground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const EnhancedTransactionsScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: BatteColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Voir tout',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (budgetProvider.transactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: BatteColors.lightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    size: 40,
                    color: BatteColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aucune transaction',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BatteColors.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vos transactions apparaîtront ici',
                  style: TextStyle(
                    fontSize: 14,
                    color: BatteColors.foreground.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...budgetProvider.transactions.take(5).map((transaction) {
            final isIncome = transaction.type == 'recycling' || transaction.type == 'income';
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isIncome
                          ? BatteColors.success.withOpacity(0.1)
                          : BatteColors.destructive.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isIncome ? BatteColors.success : BatteColors.destructive,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.description ?? 'Transaction',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: BatteColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: BatteColors.foreground.withOpacity(0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              Helpers.formatRelativeDate(transaction.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: BatteColors.foreground.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isIncome
                          ? BatteColors.success.withOpacity(0.1)
                          : BatteColors.destructive.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${isIncome ? '+' : '-'}${Helpers.formatCurrency(transaction.amount)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isIncome ? BatteColors.success : BatteColors.destructive,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }
}

