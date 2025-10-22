import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/waste_provider.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/batte_logo.dart';
import '../../widgets/level_badge.dart';
import '../../widgets/earnings_chart.dart';
import '../../services/voice_service.dart';
import '../../services/storage_service.dart';
import '../../services/supabase_service.dart';
import '../recycling/modern_recycling_screen.dart';
import '../recycling/bluetooth_scan_screen.dart';
import '../budget/modern_budget_screen.dart';
import '../education/modern_education_screen.dart';
import '../services/modern_services_screen.dart';
import '../settings/settings_screen.dart';
import '../notifications/notifications_screen.dart';
import '../map/interactive_map_screen.dart';
import 'modern_dashboard_tab.dart';

/// Écran d'accueil principal avec dashboard
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _voiceService = VoiceService();
  
  final List<Widget> _screens = [
    const ModernDashboardTab(), // 🎨 Nouveau Dashboard moderne !
    const ModernRecyclingScreen(), // 🎨 Nouveau Recyclage moderne !
    const ModernBudgetScreen(), // 🎨 Nouveau Budget moderne !
    const ModernEducationScreen(), // 🎨 Nouveau Éducation moderne !
    const ModernServicesScreen(), // 🎨 Nouveau Services moderne !
  ];
  
  @override
  void initState() {
    super.initState();
    _voiceService.initialize();
    // Déclencher le chargement APRÈS le premier build pour éviter
    // "setState() or markNeedsBuild() called during build"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserProfileAndLoadData();
    });
    
    // Lire un message de bienvenue si la voix est activée
    if (StorageService.getVoiceEnabled()) {
      _voiceService.speak('Bienvenue sur Battè');
    }
  }
  
  /// Vérifier que l'utilisateur a le bon profil (utilisateur, pas collecteur)
  Future<void> _checkUserProfileAndLoadData() async {
    final profiles = await SupabaseService.getUserProfiles();
    
    // Si c'est un collecteur uniquement (pas d'utilisateur), rediriger
    if (profiles.contains('collector') && !profiles.contains('user')) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/collector-dashboard');
      }
      return;
    }
    
    // Sinon charger les données normalement
    _loadData();
  }
  
  Future<void> _loadData() async {
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

  // (dialog de retrait géré directement dans DashboardTab)
  
  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          // Lire le nom de l'onglet si la voix est activée
          if (StorageService.getVoiceEnabled()) {
            final tabs = ['Accueil', 'Recyclage', 'Budget', 'Éducation', 'Services'];
            _voiceService.speak(tabs[index]);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: BatteColors.primary,
        unselectedItemColor: BatteColors.mutedForeground,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recycling_outlined),
            activeIcon: Icon(Icons.recycling),
            label: 'Recyclage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Éducation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Services',
          ),
        ],
      ),
    );
  }
}

/// Onglet Dashboard
class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    // Marquer que le premier chargement est terminé après un court délai
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isFirstLoad = false;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final user = authProvider.user;
    
    // Afficher un loader pendant le premier chargement
    if (_isFirstLoad && user == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(BatteColors.primary),
              ),
              SizedBox(height: 24),
              Text(
                'Chargement de vos données...',
                style: TextStyle(
                  fontSize: 16,
                  color: BatteColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refreshData(context),
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: BatteColors.primary,
                elevation: 0,
                title: Row(
                  children: [
                    const BatteLogoSmall(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bonjour,',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Text(
                            user?.name ?? 'Utilisateur',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
              
              // Contenu
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Carte de solde principale
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: BatteColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: BatteColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Solde total',
                            style: TextStyle(
                              fontSize: 14,
                              color: BatteColors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            Helpers.formatCurrency(user?.balance ?? 0),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: BatteColors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildBalanceInfo(
                                'Gains ce mois',
                                Helpers.formatCurrency(
                                  budgetProvider.totalIncome,
                                ),
                                Icons.arrow_upward,
                              ),
                              _buildBalanceInfo(
                                'Score écolo',
                                '${user?.ecoScore ?? 0} pts',
                                Icons.eco,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Badge de niveau
                    LevelBadge(ecoScore: user?.ecoScore ?? 0),
                    
                    const SizedBox(height: 24),
                    
                    // Graphique des gains hebdomadaires
                    EarningsChart(
                      weeklyEarnings: _getWeeklyEarnings(budgetProvider),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Statistiques principales
                    const Text(
                      'Statistiques',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: BatteColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      // Légèrement plus carré pour éviter les overflows sur petits écrans
                      childAspectRatio: 1.05,
                      children: [
                        StatCard(
                          title: 'Poids recyclé',
                          value: Helpers.formatWeight(user?.totalWeight ?? 0),
                          icon: Icons.recycling,
                          color: BatteColors.primary,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ModernRecyclingScreen(),
                              ),
                            );
                          },
                        ),
                        StatCard(
                          title: 'Transactions',
                          value: '${budgetProvider.transactions.length}',
                          icon: Icons.receipt_long,
                          color: BatteColors.secondary,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ModernBudgetScreen(),
                              ),
                            );
                          },
                        ),
                        StatCard(
                          title: 'Carte interactive',
                          value: 'Voir',
                          icon: Icons.map,
                          color: BatteColors.chart1,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const InteractiveMapScreen(),
                              ),
                            );
                          },
                        ),
                        StatCard(
                          title: 'Points fidélité',
                          value: '${user?.ecoScore ?? 0}',
                          icon: Icons.stars,
                          color: BatteColors.purple,
                        ),
                        StatCard(
                          title: 'Économie CO₂',
                          value: '${((user?.totalWeight ?? 0) * 0.5).toStringAsFixed(1)} kg',
                          icon: Icons.cloud_outlined,
                          color: BatteColors.chart1,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Actions rapides
                    const Text(
                      'Actions rapides',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: BatteColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(
                            context,
                            'Scanner',
                            Icons.bluetooth_searching,
                            BatteColors.primary,
                            () async {
                              // Ouvrir le scanner Bluetooth
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const BluetoothScanScreen(),
                                ),
                              );
                              
                              // Si connexion réussie, rafraîchir les données
                              if (result == true && context.mounted) {
                                await _refreshData(context);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickAction(
                            context,
                            'Retirer',
                            Icons.payments,
                            BatteColors.secondary,
                          () {
                            final controller = TextEditingController();
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: const Text('Retirer des gains'),
                                  content: TextField(
                                    controller: controller,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Montant en GNF',
                                      hintText: 'Ex: 50000',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Annuler'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        Navigator.of(ctx).pop(); // Fermer le dialogue immédiatement
                                        
                                        final raw = controller.text.trim();
                                        final amount = double.tryParse(raw.replaceAll(',', '.'));
                                        
                                        if (amount == null || amount <= 0) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('⚠️ Montant invalide'),
                                                backgroundColor: BatteColors.destructive,
                                              ),
                                            );
                                          }
                                          return;
                                        }
                                        
                                        // Afficher un loader
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                    ),
                                                  ),
                                                  SizedBox(width: 16),
                                                  Text('Traitement du retrait en cours...'),
                                                ],
                                              ),
                                              duration: Duration(seconds: 3),
                                            ),
                                          );
                                        }
                                        
                                        try {
                                          // Utiliser la nouvelle méthode qui gère le solde automatiquement
                                          final result = await SupabaseService.processWithdrawal(
                                            amount: amount,
                                            description: 'Retrait depuis le dashboard',
                                          );
                                          
                                          if (context.mounted) {
                                            // Rafraîchir les données pour afficher le nouveau solde
                                            await _refreshData(context);
                                            
                                            // Afficher un message de succès avec le nouveau solde
                                            final newBalance = result['new_balance'] ?? 0;
                                            ScaffoldMessenger.of(context).clearSnackBars();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '✅ Retrait de ${Helpers.formatCurrency(amount)} effectué !\n'
                                                  'Nouveau solde: ${Helpers.formatCurrency(newBalance)}',
                                                ),
                                                backgroundColor: BatteColors.success,
                                                duration: const Duration(seconds: 4),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).clearSnackBars();
                                            
                                            // Message d'erreur plus détaillé
                                            String errorMsg = 'Erreur lors du retrait';
                                            if (e.toString().contains('Solde insuffisant')) {
                                              errorMsg = '❌ Solde insuffisant pour ce retrait';
                                            } else if (e.toString().contains('process_withdrawal')) {
                                              errorMsg = '⚠️ Fonction de retrait non configurée dans Supabase.\n'
                                                  'Veuillez exécuter le script SQL fourni.';
                                            } else {
                                              errorMsg = '❌ Erreur: ${e.toString()}';
                                            }
                                            
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(errorMsg),
                                                backgroundColor: BatteColors.destructive,
                                                duration: const Duration(seconds: 5),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: const Text('Confirmer'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Activité récente
                    const Text(
                      'Activité récente',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: BatteColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Liste des dernières transactions
                    if (budgetProvider.transactions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: BatteColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: BatteColors.mutedForeground.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Aucune transaction pour le moment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: BatteColors.foreground,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Commence à recycler ou effectue un retrait\npour voir tes transactions ici',
                              style: TextStyle(
                                fontSize: 14,
                                color: BatteColors.mutedForeground,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ...budgetProvider.transactions.take(5).map((transaction) {
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
                    
                    const SizedBox(height: 24),
                    // Espace de sécurité pour la barre de navigation inférieure
                    SizedBox(height: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBalanceInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: BatteColors.white, size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: BatteColors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: BatteColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _refreshData(BuildContext context) async {
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
  
  /// Calcule les gains pour chaque jour de la semaine
  List<double> _getWeeklyEarnings(BudgetProvider budgetProvider) {
    final now = DateTime.now();
    final weeklyEarnings = List<double>.filled(7, 0.0);
    
    // Calculer le jour de la semaine (0 = Lundi, 6 = Dimanche)
    final today = now.weekday - 1; // weekday retourne 1-7, on veut 0-6
    
    // Parcourir les transactions des 7 derniers jours
    for (var transaction in budgetProvider.transactions) {
      if (transaction.type == 'recycling' || transaction.type == 'reward') {
        final daysDiff = now.difference(transaction.date).inDays;
        
        if (daysDiff >= 0 && daysDiff < 7) {
          // Calculer l'index dans le tableau (0 = Lun, 1 = Mar, etc.)
          final dayIndex = (today - daysDiff) % 7;
          if (dayIndex >= 0 && dayIndex < 7) {
            weeklyEarnings[dayIndex] += transaction.amount;
          }
        }
      }
    }
    
    return weeklyEarnings;
  }
}

