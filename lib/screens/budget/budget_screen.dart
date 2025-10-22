import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/helpers.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/loading_widget.dart' as custom;
import 'enhanced_transactions_screen.dart';
import 'withdrawal_methods_screen.dart';

/// Écran du module Budget
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);
  
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BudgetProvider>(context, listen: false).fetchTransactions();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<BudgetProvider>(
          builder: (context, budgetProvider, child) {
            if (budgetProvider.isLoading && budgetProvider.transactions.isEmpty) {
              return const custom.LoadingWidget(message: 'Chargement...');
            }
            
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: BatteColors.secondary,
                  title: const Text('Budget'),
                ),
                
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Carte de solde
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: BatteColors.goldGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Solde disponible',
                              style: TextStyle(
                                fontSize: 14,
                                color: BatteColors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              Helpers.formatCurrency(budgetProvider.balance),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: BatteColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Boutons d'action rapide
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const WithdrawalMethodsScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.account_balance_wallet),
                              label: const Text('Retirer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: BatteColors.success,
                                foregroundColor: BatteColors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const EnhancedTransactionsScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.history),
                              label: const Text('Historique'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: BatteColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Statistiques
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Revenus',
                              Helpers.formatCurrency(budgetProvider.totalIncome),
                              Icons.arrow_upward,
                              BatteColors.success,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Dépenses',
                              Helpers.formatCurrency(budgetProvider.totalExpenses),
                              Icons.arrow_downward,
                              BatteColors.destructive,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Graphique
                      const Text(
                        'Évolution mensuelle',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: BatteColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildLineChart(budgetProvider),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Liste des transactions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Transactions récentes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Voir tout'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (budgetProvider.transactions.isEmpty)
                        const custom.EmptyWidget(
                          message: 'Aucune transaction',
                          icon: Icons.receipt_long,
                        )
                      else
                        ...budgetProvider.transactions.map((transaction) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: BatteColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: BatteColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    transaction.typeIcon,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transaction.typeName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        Helpers.formatRelativeDate(transaction.date),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: BatteColors.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${transaction.isCredit ? '+' : '-'} ${Helpers.formatCurrency(transaction.amount)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: transaction.isCredit
                                        ? BatteColors.success
                                        : BatteColors.destructive,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Ouvrir dialogue de retrait
        },
        backgroundColor: BatteColors.secondary,
        icon: const Icon(Icons.payments),
        label: const Text('Retirer'),
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLineChart(BudgetProvider provider) {
    if (provider.transactions.isEmpty) {
      return const Center(
        child: Text(
          'Pas encore de données',
          style: TextStyle(color: BatteColors.mutedForeground),
        ),
      );
    }
    
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 1),
              FlSpot(1, 3),
              FlSpot(2, 2),
              FlSpot(3, 5),
              FlSpot(4, 3),
              FlSpot(5, 4),
            ],
            isCurved: true,
            color: BatteColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

