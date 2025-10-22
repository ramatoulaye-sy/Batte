import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/helpers.dart';
import '../../services/supabase_service.dart';

/// Écran du classement (leaderboard)
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _topRecyclers = [];
  List<Map<String, dynamic>> _topEarners = [];
  bool _isLoading = true;
  int? _myRank;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = SupabaseService.currentUser?.id;

      // Top par poids recyclé
      final recyclers = await SupabaseService.client
          .from('users')
          .select('id, name, total_weight, eco_score, avatar_url')
          .order('total_weight', ascending: false)
          .limit(50);

      // Top par gains
      final earners = await SupabaseService.client
          .from('users')
          .select('id, name, balance, level, avatar_url')
          .order('balance', ascending: false)
          .limit(50);

      if (mounted) {
        setState(() {
          _topRecyclers = List<Map<String, dynamic>>.from(recyclers);
          _topEarners = List<Map<String, dynamic>>.from(earners);
          
          // Trouver mon rang
          _myRank = _topRecyclers.indexWhere((u) => u['id'] == userId) + 1;
          if (_myRank == 0) _myRank = null;
          
          _isLoading = false;
        });
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
      appBar: AppBar(
        title: const Text('Classement'),
        backgroundColor: BatteColors.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: BatteColors.white,
          tabs: const [
            Tab(text: 'Top Recycleurs'),
            Tab(text: 'Top Gains'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Mon rang
                if (_myRank != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: BatteColors.secondary.withValues(alpha: 0.1),
                      border: Border(
                        bottom: BorderSide(color: BatteColors.border),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events, color: BatteColors.secondary),
                        const SizedBox(width: 8),
                        Text(
                          'Votre rang : #$_myRank',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: BatteColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Liste
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLeaderboardList(_topRecyclers, 'recycling'),
                      _buildLeaderboardList(_topEarners, 'earnings'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLeaderboardList(List<Map<String, dynamic>> users, String type) {
    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final rank = index + 1;
          return _buildLeaderboardCard(user, rank, type);
        },
      ),
    );
  }

  Widget _buildLeaderboardCard(Map<String, dynamic> user, int rank, String type) {
    final userId = SupabaseService.currentUser?.id;
    final isMe = user['id'] == userId;
    
    Color rankColor;
    if (rank == 1) {
      rankColor = Colors.amber;
    } else if (rank == 2) {
      rankColor = Colors.grey[400]!;
    } else if (rank == 3) {
      rankColor = Colors.brown[300]!;
    } else {
      rankColor = BatteColors.mutedForeground;
    }

    final value = type == 'recycling'
        ? Helpers.formatWeight(user['total_weight'] ?? 0)
        : Helpers.formatCurrency(user['balance'] ?? 0);

    final subtitle = type == 'recycling'
        ? 'Eco-Score: ${user['eco_score'] ?? 0}'
        : 'Niveau ${user['level'] ?? 1}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe ? BatteColors.primary.withValues(alpha: 0.05) : BatteColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? BatteColors.primary : BatteColors.border,
          width: isMe ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rang
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(Icons.emoji_events, color: rankColor, size: 24)
                  : Text(
                      '#$rank',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: rankColor,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 16),

          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: BatteColors.primary,
            child: Text(
              (user['name'] as String? ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                color: BatteColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? 'Anonyme',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: BatteColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),

          // Score
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isMe ? BatteColors.primary : BatteColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

