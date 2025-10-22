import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/helpers.dart';
import '../../services/supabase_service.dart';
import '../../services/connectivity_service.dart';
import '../../services/outbox_service.dart';
import '../../models/outbox_item.dart';
import '../../services/outbox_types.dart';

/// Écran des missions quotidiennes et hebdomadaires
class MissionsScreen extends StatefulWidget {
  const MissionsScreen({Key? key}) : super(key: key);

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _dailyMissions = [];
  List<Map<String, dynamic>> _weeklyMissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMissions() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      // Missions quotidiennes
      _dailyMissions = [
        {
          'id': '1',
          'title': 'Recycler 5 kg de déchets',
          'description': 'Recyclez au moins 5 kg aujourd\'hui',
          'reward': 5000,
          'progress': 0.4, // 40%
          'target': 5.0,
          'current': 2.0,
          'unit': 'kg',
          'icon': Icons.recycling,
          'isCompleted': false,
        },
        {
          'id': '2',
          'title': 'Scanner 3 fois',
          'description': 'Utilisez le scanner Bluetooth 3 fois',
          'reward': 2000,
          'progress': 0.66, // 2/3
          'target': 3,
          'current': 2,
          'unit': 'scans',
          'icon': Icons.qr_code_scanner,
          'isCompleted': false,
        },
        {
          'id': '3',
          'title': 'Appeler un collecteur',
          'description': 'Contactez un collecteur pour une collecte',
          'reward': 1000,
          'progress': 0.0,
          'target': 1,
          'current': 0,
          'unit': 'appels',
          'icon': Icons.phone,
          'isCompleted': false,
        },
      ];

      // Missions hebdomadaires
      _weeklyMissions = [
        {
          'id': 'w1',
          'title': 'Recycler 20 kg cette semaine',
          'description': 'Objectif hebdomadaire de recyclage',
          'reward': 20000,
          'progress': 0.35, // 35%
          'target': 20.0,
          'current': 7.0,
          'unit': 'kg',
          'icon': Icons.trending_up,
          'isCompleted': false,
        },
        {
          'id': 'w2',
          'title': 'Recycler 5 types différents',
          'description': 'Variez vos déchets recyclés',
          'reward': 10000,
          'progress': 0.6, // 3/5
          'target': 5,
          'current': 3,
          'unit': 'types',
          'icon': Icons.category,
          'isCompleted': false,
        },
        {
          'id': 'w3',
          'title': 'Atteindre 100 points Eco-Score',
          'description': 'Augmentez votre impact environnemental',
          'reward': 15000,
          'progress': 0.0,
          'target': 100,
          'current': 0,
          'unit': 'points',
          'icon': Icons.eco,
          'isCompleted': false,
        },
      ];

      if (mounted) {
        setState(() => _isLoading = false);
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
        title: const Text('Missions'),
        backgroundColor: BatteColors.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: BatteColors.white,
          tabs: const [
            Tab(text: 'Quotidiennes'),
            Tab(text: 'Hebdomadaires'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMissionsList(_dailyMissions, 'quotidiennes'),
                _buildMissionsList(_weeklyMissions, 'hebdomadaires'),
              ],
            ),
    );
  }

  Widget _buildMissionsList(List<Map<String, dynamic>> missions, String type) {
    return RefreshIndicator(
      onRefresh: _loadMissions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: missions.length,
        itemBuilder: (context, index) {
          return _buildMissionCard(missions[index]);
        },
      ),
    );
  }

  Widget _buildMissionCard(Map<String, dynamic> mission) {
    final progress = mission['progress'] as double;
    final isCompleted = mission['isCompleted'] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? BatteColors.success.withValues(alpha: 0.1)
                        : BatteColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    mission['icon'] as IconData,
                    color: isCompleted ? BatteColors.success : BatteColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mission['description'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: BatteColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle, color: BatteColors.success),
              ],
            ),

            const SizedBox(height: 16),

            // Barre de progression
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${mission['current']} / ${mission['target']} ${mission['unit']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '+${Helpers.formatCurrency(mission['reward'])}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: BatteColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: BatteColors.muted,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? BatteColors.success : BatteColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            if (isCompleted) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _claimReward(mission),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BatteColors.success,
                  foregroundColor: BatteColors.white,
                ),
                child: const Text('Récupérer la récompense'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _claimReward(Map<String, dynamic> mission) async {
    // Offline-first: if offline, enqueue to outbox
    final connectivity = ConnectivityService();
    if (!connectivity.isOnline) {
      await OutboxService.enqueue(
        OutboxItem(
          id: 'mission_claim_${mission['id']}_${DateTime.now().millisecondsSinceEpoch}',
          type: OutboxTypes.missionClaimReward,
          payload: {
            'mission_id': mission['id'],
            'reward': mission['reward'],
            'title': mission['title'],
          },
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ +${Helpers.formatCurrency(mission['reward'])} sera ajouté à votre compte dès la reconnexion !'),
          backgroundColor: BatteColors.secondary,
        ),
      );
      return;
    }

    // TODO: Implémenter réclamation de récompense
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ +${Helpers.formatCurrency(mission['reward'])} gagnés !'),
        backgroundColor: BatteColors.success,
      ),
    );
  }
}

