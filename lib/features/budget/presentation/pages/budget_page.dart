import 'package:flutter/material.dart';
import 'package:batte/core/app_theme.dart';
import 'package:batte/services/supabase_service.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final SupabaseService _supabase = SupabaseService.instance;
  
  double _currentBalance = 0.0;
  int _currentPoints = 0;
  double _monthlyWaste = 0.0;
  double _totalEarnings = 0.0;
  double _savedAmount = 0.0;
  double _withdrawnAmount = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  // Données dynamiques pour les graphiques
  List<Map<String, dynamic>> _monthlyData = [];
  List<Map<String, dynamic>> _wasteDistribution = [];
  List<Map<String, dynamic>> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadFromTransactions();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) throw Exception('Utilisateur non connecté');
      
      // Charger le profil utilisateur pour balance et points
      final profile = await _supabase.getUserProfile(userId);
      if (profile != null) {
    setState(() {
          _currentBalance = (profile['balance'] ?? 0.0) as double;
          _currentPoints = (profile['points'] ?? 0) as int;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = '$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFromTransactions() async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) return;
      
      final txs = await _supabase.getUserTransactions(userId);
      if (!mounted) return;

      // Calculer les statistiques
      double totalEarnings = 0.0;
      double monthlyWaste = 0.0;
      Map<String, double> wasteTypeCounts = {};
      
      // Grouper par mois pour le graphique
      Map<String, Map<String, double>> monthlyStats = {};
      
      for (final tx in txs) {
        final created = tx['created_at'] as String?;
        DateTime? dt;
        try { 
          dt = created != null ? DateTime.tryParse(created) : null; 
        } catch (_) {}
        
        if (dt != null) {
          final monthKey = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
          
          if (!monthlyStats.containsKey(monthKey)) {
            monthlyStats[monthKey] = {'earnings': 0.0, 'waste': 0.0};
          }
          
          final amount = tx['amount_gnf'];
          final weight = tx['weight_kg'];
          final double amountVal = amount is num ? amount.toDouble() : double.tryParse('$amount') ?? 0.0;
          final double weightVal = weight is num ? weight.toDouble() : double.tryParse('$weight') ?? 0.0;
          
          totalEarnings += amountVal;
          monthlyStats[monthKey]!['earnings'] = (monthlyStats[monthKey]!['earnings'] ?? 0.0) + amountVal;
          monthlyStats[monthKey]!['waste'] = (monthlyStats[monthKey]!['waste'] ?? 0.0) + weightVal;
          
          // Vérifier si c'est ce mois
          final isThisMonth = dt.year == DateTime.now().year && dt.month == DateTime.now().month;
          if (isThisMonth) monthlyWaste += weightVal;
          
          // Compter les types de déchets
          final wasteType = tx['waste_types']?['name'] ?? 'Autre';
          wasteTypeCounts[wasteType] = (wasteTypeCounts[wasteType] ?? 0.0) + weightVal;
        }
      }
      
      // Créer les données mensuelles pour le graphique
      final sortedMonths = monthlyStats.keys.toList()..sort();
      final last6Months = sortedMonths.take(6).toList();
      
      _monthlyData = last6Months.map((monthKey) {
        final stats = monthlyStats[monthKey]!;
        final month = monthKey.split('-')[1];
        return {
          'month': _getMonthName(int.parse(month)),
          'earnings': stats['earnings'] ?? 0.0,
          'waste': stats['waste'] ?? 0.0,
        };
      }).toList();
      
      // Créer la répartition des déchets
      final totalWaste = wasteTypeCounts.values.fold(0.0, (sum, weight) => sum + weight);
      _wasteDistribution = wasteTypeCounts.entries.map((entry) {
        final percentage = totalWaste > 0 ? (entry.value / totalWaste) * 100 : 0.0;
        return {
          'type': entry.key,
          'percentage': percentage,
          'color': _getWasteTypeColor(entry.key),
          'weight': entry.value,
        };
      }).toList();
      
      // Trier par pourcentage décroissant
      _wasteDistribution.sort((a, b) => (b['percentage'] as double).compareTo(a['percentage'] as double));
      
      // Garder les 5 premiers types
      if (_wasteDistribution.length > 5) {
        final others = _wasteDistribution.skip(5).fold(0.0, (sum, item) => sum + (item['percentage'] as double));
        _wasteDistribution = _wasteDistribution.take(5).toList();
        if (others > 0) {
          _wasteDistribution.add({
            'type': 'Autres',
            'percentage': others,
            'color': AppTheme.secondaryColor,
            'weight': 0.0,
          });
        }
      }
      
      // Charger les transactions récentes
      _recentTransactions = txs.take(5).toList();
      
      if (mounted) {
        setState(() {
          _totalEarnings = totalEarnings;
          _monthlyWaste = monthlyWaste;
          _savedAmount = totalEarnings * 0.3; // 30% épargnés (simulation)
          _withdrawnAmount = totalEarnings - _savedAmount - _currentBalance;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = '$e');
      }
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return months[month - 1];
  }

  Color _getWasteTypeColor(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('plast')) return AppTheme.wastePlasticColor;
    if (lower.contains('organ')) return AppTheme.wasteOrganicColor;
    if (lower.contains('verre') || lower.contains('glass')) return AppTheme.wasteGlassColor;
    if (lower.contains('métal') || lower.contains('metal')) return AppTheme.wasteMetalColor;
    if (lower.contains('papier') || lower.contains('paper')) return AppTheme.wastePaperColor;
    return AppTheme.primaryColor;
  }

  Future<void> _processWithdrawal(String method, double amount) async {
    setState(() => _isLoading = true);
    
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) throw Exception('Utilisateur non connecté');
      
      // Créer une transaction de retrait
      final withdrawalId = await _supabase.createWithdrawalTransaction({
        'user_id': userId,
        'amount_gnf': amount,
        'method': method,
        'status': 'pending',
      });
      
      if (withdrawalId != null) {
        // Mettre à jour le solde utilisateur
        final success = await _supabase.updateUserBalance(userId, _currentBalance - amount);
        
        if (success && mounted) {
          setState(() {
            _withdrawnAmount += amount;
            _currentBalance = 0.0;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Retrait de ${amount.toStringAsFixed(0)} GNF via $method en cours de traitement...'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } else {
        throw Exception('Échec de la création de la transaction de retrait');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du retrait: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _processSaving(String goal, double amount) async {
    setState(() => _isLoading = true);
    
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) throw Exception('Utilisateur non connecté');
      
      // Créer une transaction d'épargne
      final savingId = await _supabase.createSavingTransaction({
        'user_id': userId,
        'amount_gnf': amount,
        'goal': goal,
        'status': 'active',
      });
      
      if (savingId != null) {
        // Mettre à jour le solde utilisateur
        final success = await _supabase.updateUserBalance(userId, _currentBalance - amount);
        
        if (success && mounted) {
          setState(() {
            _savedAmount += amount;
            _currentBalance = 0.0;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${amount.toStringAsFixed(0)} GNF épargnés vers $goal !'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } else {
        throw Exception('Échec de la création de la transaction d\'épargne');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'épargne: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Retrait d\'argent'),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Solde disponible : ${_currentBalance.toStringAsFixed(0)} GNF',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Choisissez votre méthode de retrait :',
                style: TextStyle(
                  color: AppTheme.onBackgroundColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _buildWithdrawOption('Orange Money', Icons.phone_android, AppTheme.primaryColor, _currentBalance),
              const SizedBox(height: 12),
              _buildWithdrawOption('MTN Mobile Money', Icons.phone_iphone, AppTheme.accentColor, _currentBalance),
              const SizedBox(height: 12),
              _buildWithdrawOption('Crédit téléphonique', Icons.credit_card, AppTheme.secondaryColor, _currentBalance),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: AppTheme.onBackgroundColor.withValues(alpha: 0.7)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawOption(String title, IconData icon, Color color, double amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          _processWithdrawal(title, amount);
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withValues(alpha: 0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.savings,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Épargner'),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Solde disponible : ${_currentBalance.toStringAsFixed(0)} GNF',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Définissez un objectif d\'épargne :',
                style: TextStyle(
                  color: AppTheme.onBackgroundColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _buildSaveOption('Objectif Court Terme', '3 mois', '5% d\'intérêt', _currentBalance),
              const SizedBox(height: 12),
              _buildSaveOption('Objectif Moyen Terme', '6 mois', '8% d\'intérêt', _currentBalance),
              const SizedBox(height: 12),
              _buildSaveOption('Objectif Long Terme', '12 mois', '12% d\'intérêt', _currentBalance),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: AppTheme.onBackgroundColor.withValues(alpha: 0.7)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveOption(String title, String duration, String interest, double amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          _processSaving(title, amount);
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(
              Icons.savings,
              color: AppTheme.successColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$duration • $interest',
                    style: TextStyle(
                      color: AppTheme.successColor.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.successColor.withValues(alpha: 0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Budget',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.analytics,
              color: AppTheme.primaryColor,
            ),
            onPressed: () {
              // Afficher les statistiques détaillées
              _showDetailedStats();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicateur de chargement
            if (_isLoading)
              Container(
                padding: const EdgeInsets.all(20),
                child: const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Chargement des données...'),
                    ],
                  ),
                ),
              ),

            // Message d'erreur
            if (_errorMessage != null && !_isLoading)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: AppTheme.errorColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => _errorMessage = null);
                        _loadUserData();
                        _loadFromTransactions();
                      },
                      icon: Icon(Icons.refresh, color: AppTheme.errorColor),
                    ),
                  ],
                ),
              ),

            // Portefeuille principal
            if (!_isLoading)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: AppTheme.primaryGradient,
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Portefeuille',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${_currentBalance.toStringAsFixed(0)} GNF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                  '$_currentPoints',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Points',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                  _monthlyWaste.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'kg ce mois',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Actions rapides
            if (!_isLoading)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentBalance > 0 ? _showWithdrawDialog : null,
                    icon: const Icon(Icons.account_balance_wallet),
                    label: const Text('Retirer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.onPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentBalance > 0 ? _showSaveDialog : null,
                    icon: const Icon(Icons.savings),
                    label: const Text('Épargner'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: AppTheme.onPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Statistiques
            if (!_isLoading)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          color: AppTheme.primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Statistiques',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildStatRow('Gains totaux', '${_totalEarnings.toStringAsFixed(0)} GNF', AppTheme.primaryColor),
                    _buildStatRow('Épargné', '${_savedAmount.toStringAsFixed(0)} GNF', AppTheme.successColor),
                    _buildStatRow('Retiré', '${_withdrawnAmount.toStringAsFixed(0)} GNF', AppTheme.accentColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Graphique d'évolution mensuelle
            if (!_isLoading && _monthlyData.isNotEmpty)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: AppTheme.primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Évolution Mensuelle',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: _buildMonthlyChart(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Répartition des déchets
            if (!_isLoading && _wasteDistribution.isNotEmpty)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.pie_chart,
                          color: AppTheme.primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Répartition des Déchets',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildWasteDistributionChart(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Conseils d'épargne
            if (!_isLoading)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: AppTheme.warningColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Conseils d\'Épargne',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.warningColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSavingTip(
                      'Avec ${_currentBalance.toStringAsFixed(0)} GNF, vous pouvez :',
                      [
                        '• Acheter des produits locaux',
                        '• Investir dans un petit commerce',
                        '• Participer à une tontine',
                        '• Épargner pour un projet futur',
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Transactions récentes
            if (!_isLoading && _recentTransactions.isNotEmpty)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            color: AppTheme.primaryColor,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Transactions Récentes',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ..._recentTransactions.map((tx) => _buildTransactionItem(tx)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: MonthlyChartPainter(_monthlyData),
    );
  }

  Widget _buildWasteDistributionChart() {
    return Column(
      children: _wasteDistribution.map((waste) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: waste['color'],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  waste['type'],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Text(
                '${waste['percentage'].toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: waste['color'],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSavingTip(String title, List<String> tips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppTheme.warningColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            tip,
            style: TextStyle(
              color: AppTheme.onBackgroundColor.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        )),
      ],
    );
  }

  void _showDetailedStats() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Statistiques Détaillées',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historique des 6 derniers mois',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _monthlyData.length,
                        itemBuilder: (context, index) {
                          final data = _monthlyData[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      data['month'],
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Gains: ${data['earnings'].toStringAsFixed(0)} GNF',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Déchets: ${data['waste'].toStringAsFixed(1)} kg',
                                        style: TextStyle(
                                          color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.trending_up,
                                  color: AppTheme.successColor,
                                  size: 24,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final wasteType = tx['waste_types']?['name'] ?? 'Déchet';
    final amount = (tx['amount_gnf'] ?? 0).toString();
    final weight = (tx['weight_kg'] ?? 0).toString();
    final status = (tx['status'] ?? 'pending').toString();
    final created = tx['created_at'] as String?;
    
    DateTime? date;
    try {
      date = created != null ? DateTime.tryParse(created) : null;
    } catch (_) {}
    
    final dateStr = date != null 
        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}'
        : '--/--';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.recycling,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wasteType,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$weight kg • $amount GNF',
                  style: TextStyle(
                    color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Date: $dateStr',
                  style: TextStyle(
                    color: AppTheme.onBackgroundColor.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusChip(status),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'completed':
        color = AppTheme.successColor;
        label = 'Terminé';
        break;
      case 'assigned':
        color = AppTheme.accentColor;
        label = 'Assigné';
        break;
      case 'cancelled':
        color = AppTheme.errorColor;
        label = 'Annulé';
        break;
      default:
        color = AppTheme.warningColor;
        label = 'En attente';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Peintre personnalisé pour le graphique mensuel
class MonthlyChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  MonthlyChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final maxEarnings = data.fold(0.0, (max, item) => 
      item['earnings'] > max ? item['earnings'] : max);

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (item['earnings'] / maxEarnings) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Points sur la ligne
    final pointPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (item['earnings'] / maxEarnings) * size.height;

      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
