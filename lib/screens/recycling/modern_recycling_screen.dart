import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../providers/waste_provider.dart';
import '../../widgets/waste_pie_chart.dart';
import 'bluetooth_scan_screen.dart';
import 'collectors_screen.dart';
import 'waste_history_screen.dart';
import 'manual_waste_entry_screen.dart';
import '../../widgets/offline_badge.dart';

/// Écran Recyclage moderne avec design harmonisé
class ModernRecyclingScreen extends StatefulWidget {
  const ModernRecyclingScreen({Key? key}) : super(key: key);
  
  @override
  State<ModernRecyclingScreen> createState() => _ModernRecyclingScreenState();
}

class _ModernRecyclingScreenState extends State<ModernRecyclingScreen>
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
      final wasteProvider = Provider.of<WasteProvider>(context, listen: false);
      
      // Charger les données et déclencher le rafraîchissement de l'UI
      wasteProvider.fetchWastes();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final wasteProvider = Provider.of<WasteProvider>(context, listen: false);
    
    // Charger les données et déclencher le rafraîchissement de l'UI
    await wasteProvider.fetchWastes();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BatteColors.softGreen,
      body: Consumer<WasteProvider>(
        builder: (context, wasteProvider, child) {
          if (wasteProvider.isLoading && wasteProvider.wastes.isEmpty) {
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
                    'Chargement de vos déchets...',
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
                  // Header moderne fixe
                  SliverToBoxAdapter(
                    child: _buildModernHeader(),
                  ),
                  
                  // Contenu
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 24),

                        // Bouton Scanner avec design moderne
                        _buildModernScanButton(wasteProvider),
                        
                        const SizedBox(height: 12),
                        
                        // Bouton ajout manuel
                        _buildManualEntryButton(),
                        
                        const SizedBox(height: 24),
                        
                        // Statistiques modernes
                        _buildModernStats(wasteProvider),
                        
                        const SizedBox(height: 24),
                        
                        // Graphique de répartition
                        _buildModernChart(wasteProvider),
                        
                        const SizedBox(height: 32),
                        
                        // Types de déchets avec design moderne
                        _buildWasteTypesSection(wasteProvider),
                        
                        const SizedBox(height: 32),
                        
                        // Historique récent
                        _buildRecentHistorySection(wasteProvider),
                        
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
          // Logo recyclage
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
              Icons.recycling,
              color: Colors.white,
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
                  'Recyclage',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: BatteColors.foreground,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Gérez vos déchets intelligemment',
                  style: TextStyle(
                    fontSize: 13,
                    color: BatteColors.mutedForeground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          const OfflineBadge(),
          const SizedBox(width: 8),
          
          // Bouton collecteurs
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CollectorsScreen(),
                ),
              );
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: BatteColors.lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: BatteColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualEntryButton() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ManualWasteEntryScreen(),
          ),
        );
        
        if (result == true && context.mounted) {
          Provider.of<WasteProvider>(context, listen: false).fetchWastes();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: BatteColors.primary.withOpacity(0.3),
            width: 2,
          ),
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
                color: BatteColors.lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                size: 28,
                color: BatteColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ajouter manuellement',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: BatteColors.foreground,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sans poubelle Bluetooth',
                    style: TextStyle(
                      fontSize: 13,
                      color: BatteColors.mutedForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: BatteColors.primary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernScanButton(WasteProvider wasteProvider) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const BluetoothScanScreen(),
          ),
        );
        
        if (result == true && context.mounted) {
          wasteProvider.fetchWastes();
        }
      },
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.bluetooth_searching,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scanner ma poubelle',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Connectez-vous à votre poubelle intelligente',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStats(WasteProvider wasteProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildModernStatCard(
            icon: Icons.scale_rounded,
            title: 'Poids total',
            value: Helpers.formatWeight(wasteProvider.totalWeight),
            gradient: const LinearGradient(
              colors: [Color(0xFF38761D), Color(0xFF4A8F2A)],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildModernStatCard(
            icon: Icons.payments_rounded,
            title: 'Valeur totale',
            value: Helpers.formatCurrency(wasteProvider.totalValue),
            gradient: BatteColors.goldGradient,
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
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernChart(WasteProvider wasteProvider) {
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
                  Icons.pie_chart_rounded,
                  color: BatteColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Répartition par type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: BatteColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          WastePieChart(
            wasteData: _getWasteDataForChart(wasteProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteTypesSection(WasteProvider wasteProvider) {
    return Column(
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
                Icons.category_rounded,
                color: BatteColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Types de déchets',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: BatteColors.foreground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...AppConstants.wasteTypes.map((type) {
          final typeWastes = wasteProvider.wastesByType[type['id']] ?? [];
          final totalWeight = typeWastes.fold(0.0, (sum, w) => sum + w.weight);
          final totalValue = typeWastes.fold(0.0, (sum, w) => sum + w.value);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
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
                    color: BatteColors.lightGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      type['icon'],
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: BatteColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${type['pricePerKg']} GNF/kg',
                        style: TextStyle(
                          fontSize: 12,
                          color: BatteColors.foreground.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: BatteColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        Helpers.formatCurrency(totalValue),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: BatteColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Helpers.formatWeight(totalWeight),
                      style: TextStyle(
                        fontSize: 12,
                        color: BatteColors.foreground.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRecentHistorySection(WasteProvider wasteProvider) {
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
                      Icons.history_rounded,
                      color: BatteColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Historique récent',
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
                    builder: (_) => const WasteHistoryScreen(),
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
        
        if (wasteProvider.wastes.isEmpty)
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
                    Icons.recycling,
                    size: 40,
                    color: BatteColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aucun déchet recyclé',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BatteColors.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scannez votre poubelle pour commencer',
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
          ...wasteProvider.wastes.take(5).map((waste) {
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
                      color: BatteColors.lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        waste.typeIcon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          waste.typeName,
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
                              Helpers.formatRelativeDate(waste.date),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Helpers.formatWeight(waste.weight),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: BatteColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: BatteColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          Helpers.formatCurrency(waste.value),
                          style: const TextStyle(
                            fontSize: 12,
                            color: BatteColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }
  
  Map<String, double> _getWasteDataForChart(WasteProvider wasteProvider) {
    final Map<String, double> data = {};
    
    wasteProvider.wastesByType.forEach((typeId, wastes) {
      final typeData = AppConstants.wasteTypes.firstWhere(
        (t) => t['id'] == typeId,
        orElse: () => {'name': typeId},
      );
      
      final totalWeight = (wastes as List).fold(0.0, (sum, w) => sum + w.weight);
      
      if (totalWeight > 0) {
        data[typeData['name'] ?? typeId] = totalWeight;
      }
    });
    
    return data;
  }
}

