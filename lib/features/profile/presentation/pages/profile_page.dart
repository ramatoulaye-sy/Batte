import 'package:flutter/material.dart';
import 'package:batte/core/app_theme.dart';
import 'package:batte/core/routes.dart';
import 'package:batte/services/auth_service.dart';
import 'package:batte/services/supabase_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService.instance;
  final SupabaseService _supabase = SupabaseService.instance;
  
  Map<String, dynamic>? _currentUser;
  int _currentLevel = 1;
  int _currentPoints = 0;
  int _pointsToNextLevel = 0;
  double _levelProgress = 0.0;
  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic> _userStats = {
    'totalWaste': 0.0,
    'totalEarnings': 0.0,
    'totalSales': 0,
    'favoriteWasteType': '-',
    'totalCollectors': 0,
    'averageRating': null,
  };
  List<Map<String, dynamic>> _transactions = const [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (!mounted) return;
    
    if (!_supabase.isAuthenticated || _supabase.currentUserId == null) {
      // Utiliser un délai pour éviter les conflits de navigation
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          AppRoutes.pushNamedAndRemoveUntil(context, AppRoutes.login);
        }
      });
      return;
    }
    await _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await Future.wait([
        _loadProfile(),
        _loadStats(),
      ]);
    } catch (e) {
      _errorMessage = 'Impossible de charger le profil.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadProfile() async {
    final userId = _supabase.currentUserId!;
    final profile = await _authService.getProfile(userId);
    if (profile != null) {
      setState(() {
        _currentUser = profile;
        _currentPoints = (profile['points'] as int?) ?? 0;
        _currentLevel = (profile['level'] as int?) ?? 1;
      });
      _calculateLevelFromPoints(_currentPoints);
    }
  }

  Future<void> _loadStats() async {
    final userId = _supabase.currentUserId!;
    final transactions = await _supabase.getUserTransactions(userId);
    final collections = await _supabase.getUserCollections(userId);
    final ratings = await _supabase.getUserRatings(userId);

    final completedTx = transactions.where((t) => (t['status'] ?? 'completed') == 'completed').toList();

    final double totalWaste = completedTx.fold<double>(0.0, (sum, t) {
      final dynamic w = t['weight_kg'];
      return sum + (w is num ? w.toDouble() : double.tryParse('${t['weight_kg']}') ?? 0.0);
    });
    final double totalEarnings = completedTx.fold<double>(0.0, (sum, t) {
      final dynamic a = t['amount_gnf'];
      return sum + (a is num ? a.toDouble() : double.tryParse('${t['amount_gnf']}') ?? 0.0);
    });
    final int totalSales = completedTx.length;

    String favoriteWasteType = '-';
    if (transactions.isNotEmpty) {
      final Map<String, int> freq = {};
      for (final t in transactions) {
        final wt = t['waste_types'];
        final name = (wt is Map<String, dynamic>) ? (wt['name'] as String? ?? '-') : '-';
        if (name != '-') {
          freq[name] = (freq[name] ?? 0) + 1;
        }
      }
      if (freq.isNotEmpty) {
        favoriteWasteType = freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      }
    }

    final uniqueCollectors = <String>{};
    for (final c in collections) {
      final id = c['collector_id']?.toString();
      if (id != null) uniqueCollectors.add(id);
    }

    double? averageRating;
    if (ratings.isNotEmpty) {
      final total = ratings.fold<int>(0, (sum, r) => sum + ((r['rating'] as int?) ?? 0));
      averageRating = total / ratings.length;
    }

    setState(() {
      _userStats = {
        'totalWaste': totalWaste,
        'totalEarnings': totalEarnings,
        'totalSales': totalSales,
        'favoriteWasteType': favoriteWasteType,
        'totalCollectors': uniqueCollectors.length,
        'averageRating': averageRating,
      };
      _transactions = transactions;
    });
  }

  void _calculateLevelFromPoints(int points) {
    final List<int> thresholds = [0, 10, 25, 50, 100, 200, 400, 800, 1600, 3200];
    int level = 1;
    for (int i = 0; i < thresholds.length; i++) {
      if (points < thresholds[i]) {
        level = i;
        break;
      }
      if (i == thresholds.length - 1) {
        level = 10;
      }
    }
    if (points < thresholds[1]) level = 1;

    int currentStart = thresholds[(level - 1).clamp(0, thresholds.length - 1)];
    int nextThreshold = level < 10 ? thresholds[level] : thresholds.last;
    final int toNext = level < 10 ? (nextThreshold - points).clamp(0, 1 << 31) : 0;
    final double progress = level < 10
        ? ((points - currentStart) / (nextThreshold - currentStart)).clamp(0.0, 1.0)
        : 1.0;

    setState(() {
      _currentLevel = level;
      _pointsToNextLevel = toNext;
      _levelProgress = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profil',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppTheme.primaryColor,
            ),
            onPressed: _refresh,
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: AppTheme.primaryColor,
            ),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                // Utiliser un délai pour éviter les conflits de navigation
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) {
                    AppRoutes.pushNamedAndRemoveUntil(context, AppRoutes.login);
                  }
                });
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: 24),
                        _buildStatsCard(),
                        const SizedBox(height: 24),
                        _buildTransactionsCard(),
                        const SizedBox(height: 24),
                        _buildBadgesCard(),
                        const SizedBox(height: 24),
                        _buildActionsCard(),
                      ],
                    ),
                  ),
                )),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
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
                Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 3,
                        ),
                        image: (_currentUser?['avatar_url'] != null && (_currentUser!['avatar_url'] as String).isNotEmpty)
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(_currentUser!['avatar_url'] as String),
                              )
                            : null,
                      ),
                      child: (_currentUser?['avatar_url'] == null || (_currentUser!['avatar_url'] as String).isEmpty)
                          ? Center(
                              child: Text(
                                (_currentUser?['name'] as String?)?.substring(0, 1).toUpperCase() ?? 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (_currentUser?['name'] as String?) ?? 'Utilisateur',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        (_currentUser?['city'] as String?) ?? 'Ville',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Membre depuis 2024',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final result = await AppRoutes.pushNamed(context, AppRoutes.settings);
                    if (result == true) {
                      _refresh();
                    }
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Niveau $_currentLevel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$_currentPoints points',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _levelProgress,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.secondaryColor,
                    ),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _pointsToNextLevel > 0 
                      ? '$_pointsToNextLevel points pour le niveau suivant'
                      : 'Niveau maximum atteint !',
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
      ),
    );
  }

  Widget _buildStatsCard() {
    final userStats = _userStats;
    return Card(
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
            _buildStatRow('Déchets totaux', '${(userStats['totalWaste'] as double).toStringAsFixed(1)} kg'),
            _buildStatRow('Gains totaux', '${(userStats['totalEarnings'] as double).toStringAsFixed(0)} GNF'),
            _buildStatRow('Ventes effectuées', '${userStats['totalSales']}'),
            _buildStatRow('Type préféré', (userStats['favoriteWasteType'] as String)),
            _buildStatRow('Collecteurs', '${userStats['totalCollectors']}'),
            _buildStatRow('Note moyenne', userStats['averageRating'] == null ? 'N/A' : '${(userStats['averageRating'] as double).toStringAsFixed(1)}/5'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
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
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesCard() {
    final points = _currentPoints;
    final totalWaste = (_userStats['totalWaste'] as double?) ?? 0.0;
    final totalSales = (_userStats['totalSales'] as int?) ?? 0;
    final badges = [
      {'name': 'Premier Pas', 'unlocked': totalSales >= 1, 'color': AppTheme.warningColor},
      {'name': 'Guerrier Éco', 'unlocked': points >= 50, 'color': AppTheme.successColor},
      {'name': 'Broyeur de Plastique', 'unlocked': totalWaste >= 10, 'color': AppTheme.wastePlasticColor},
      {'name': 'Maître Organique', 'unlocked': points >= 200, 'color': AppTheme.wasteOrganicColor},
      {'name': 'Collecteur de Verre', 'unlocked': totalSales >= 10, 'color': AppTheme.wasteGlassColor},
      {'name': 'Chasseur de Métal', 'unlocked': points >= 400, 'color': AppTheme.wasteMetalColor},
    ];

    return Card(
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
                  Icons.emoji_events,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Badges',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${badges.where((b) => (b['unlocked'] as bool)).length}/${badges.length}',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                return _buildBadgeCard(badge);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsCard() {
    final items = _transactions;
    return Card(
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
                  'Historique',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (items.isNotEmpty)
                  TextButton(
                    onPressed: () => _showAllTransactions(),
                    child: const Text('Voir tout'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Text(
                'Aucune transaction pour le moment',
                style: TextStyle(
                  color: AppTheme.onBackgroundColor.withValues(alpha: 0.7),
                ),
              )
            else
              Column(
                children: items.take(5).map((tx) => _buildTxRow(tx)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTxRow(Map<String, dynamic> tx) {
    final waste = tx['waste_types'];
    final wasteName = (waste is Map<String, dynamic>) ? (waste['name'] as String? ?? 'Déchet') : 'Déchet';
    final weight = tx['weight_kg'];
    final amount = tx['amount_gnf'];
    final dateStr = (tx['created_at'] as String?) ?? '';
    DateTime? dt;
    try { dt = DateTime.tryParse(dateStr); } catch (_) {}
    final dateLabel = dt != null ? '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}' : '';

    final double weightVal = weight is num ? weight.toDouble() : double.tryParse('$weight') ?? 0.0;
    final double amountVal = amount is num ? amount.toDouble() : double.tryParse('$amount') ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.recycling, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wasteName,
                  style: TextStyle(
                    color: AppTheme.onBackgroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  dateLabel,
                  style: TextStyle(
                    color: AppTheme.onBackgroundColor.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${weightVal.toStringAsFixed(1)} kg',
                style: TextStyle(
                  color: AppTheme.onBackgroundColor.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              Text(
                '${amountVal.toStringAsFixed(0)} GNF',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAllTransactions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final items = _transactions;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long),
                    const SizedBox(width: 8),
                    const Text('Toutes les transactions', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            'Aucune transaction',
                            style: TextStyle(color: AppTheme.onBackgroundColor.withValues(alpha: 0.7)),
                          ),
                        )
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) => _buildTxRow(items[index]),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    final isUnlocked = badge['unlocked'];
    final color = badge['color'] as Color;
    
    return Container(
      decoration: BoxDecoration(
        color: isUnlocked 
          ? color.withValues(alpha: 0.1)
          : AppTheme.disabledColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked 
            ? color.withValues(alpha: 0.3)
            : AppTheme.disabledColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            color: isUnlocked ? color : AppTheme.disabledColor,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            badge['name'],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isUnlocked ? color : AppTheme.disabledColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          if (isUnlocked)
            Icon(
              Icons.check_circle,
              color: color,
              size: 16,
            ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
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
                  Icons.flash_on,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Actions Rapides',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Partager Profil',
                    Icons.share,
                    AppTheme.primaryColor,
                    () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    'Inviter Amis',
                    Icons.person_add,
                    AppTheme.successColor,
                    () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
