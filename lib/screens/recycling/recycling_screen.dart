import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../providers/waste_provider.dart';
import '../../widgets/loading_widget.dart' as custom;
import '../../widgets/waste_pie_chart.dart';
import 'bluetooth_scan_screen.dart';
import 'collectors_screen.dart';
import 'waste_history_screen.dart';

/// Écran du module Recyclage
class RecyclingScreen extends StatefulWidget {
  const RecyclingScreen({Key? key}) : super(key: key);
  
  @override
  State<RecyclingScreen> createState() => _RecyclingScreenState();
}

class _RecyclingScreenState extends State<RecyclingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WasteProvider>(context, listen: false).fetchWastes();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<WasteProvider>(
          builder: (context, wasteProvider, child) {
            if (wasteProvider.isLoading && wasteProvider.wastes.isEmpty) {
              return const custom.LoadingWidget(
                message: 'Chargement des données...',
              );
            }
            
            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: BatteColors.primary,
                  title: const Text('Recyclage'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.location_on_outlined),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CollectorsScreen(),
                          ),
                        );
                      },
                      tooltip: 'Collecteurs proches',
                    ),
                  ],
                ),
                
                // Contenu
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Bouton Scanner Bluetooth
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const BluetoothScanScreen(),
                            ),
                          );
                          
                          // Rafraîchir les données si connexion réussie
                          if (result == true && context.mounted) {
                            Provider.of<WasteProvider>(context, listen: false).fetchWastes();
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
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: BatteColors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.bluetooth_searching,
                                  size: 40,
                                  color: BatteColors.white,
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
                                        color: BatteColors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Connectez-vous à votre poubelle intelligente',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: BatteColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: BatteColors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Statistiques
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Poids total',
                              Helpers.formatWeight(wasteProvider.totalWeight),
                              Icons.scale,
                              BatteColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Valeur totale',
                              Helpers.formatCurrency(wasteProvider.totalValue),
                              Icons.payments_rounded,
                              BatteColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Graphique de répartition par type (AMÉLIORÉ)
                      WastePieChart(
                        wasteData: _getWasteDataForChart(wasteProvider),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Types de déchets
                      const Text(
                        'Types de déchets',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ...AppConstants.wasteTypes.map((type) {
                        final typeWastes = wasteProvider.wastesByType[type['id']] ?? [];
                        final totalWeight = typeWastes.fold(0.0, (sum, w) => sum + w.weight);
                        final totalValue = typeWastes.fold(0.0, (sum, w) => sum + w.value);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: BatteColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                type['icon'],
                                style: const TextStyle(fontSize: 32),
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
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${type['pricePerKg']} GNF/kg',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: BatteColors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    Helpers.formatWeight(totalWeight),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    Helpers.formatCurrency(totalValue),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: BatteColors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      
                      const SizedBox(height: 24),
                      
                      // Historique
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Historique',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
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
                            child: const Text('Voir tout'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (wasteProvider.wastes.isEmpty)
                        const custom.EmptyWidget(
                          message: 'Aucun déchet recyclé pour le moment',
                          icon: Icons.recycling,
                        )
                      else
                        ...wasteProvider.wastes.take(10).map((waste) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: BatteColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  waste.typeIcon,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        waste.typeName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        Helpers.formatRelativeDate(waste.date),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: BatteColors.mutedForeground,
                                        ),
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
                                      ),
                                    ),
                                    Text(
                                      Helpers.formatCurrency(waste.value),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: BatteColors.success,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
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
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
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
  
  /// Prépare les données pour le graphique circulaire
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

