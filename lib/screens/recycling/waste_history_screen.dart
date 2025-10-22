import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../providers/waste_provider.dart';
import '../../widgets/loading_widget.dart' as custom;

/// Écran d'historique complet des déchets recyclés avec filtres et recherche
class WasteHistoryScreen extends StatefulWidget {
  const WasteHistoryScreen({Key? key}) : super(key: key);

  @override
  State<WasteHistoryScreen> createState() => _WasteHistoryScreenState();
}

class _WasteHistoryScreenState extends State<WasteHistoryScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'all'; // 'all', 'plastic', 'paper', 'metal', etc.
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Déchets'),
        backgroundColor: BatteColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtres',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<WasteProvider>(
          builder: (context, wasteProvider, child) {
            if (wasteProvider.isLoading && wasteProvider.wastes.isEmpty) {
              return const custom.LoadingWidget(
                message: 'Chargement de l\'historique...',
              );
            }

            // Filtrer les déchets selon le filtre sélectionné et la recherche
            final filteredWastes = wasteProvider.wastes.where((waste) {
              // Filtre par type
              if (_selectedFilter != 'all' && waste.type != _selectedFilter) {
                return false;
              }

              // Filtre par recherche (nom du type ou description)
              if (_searchQuery.isNotEmpty) {
                final query = _searchQuery.toLowerCase();
                return waste.typeName.toLowerCase().contains(query) ||
                    (waste.notes?.toLowerCase().contains(query) ?? false);
              }

              return true;
            }).toList();

            return Column(
              children: [
                // Barre de recherche
                Container(
                  padding: const EdgeInsets.all(16),
                  color: BatteColors.muted,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un déchet...',
                      prefixIcon: const Icon(Icons.search, color: BatteColors.mutedForeground),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: BatteColors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                // Filtres rapides (chips horizontaux)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: BatteColors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Tout', 'all', Icons.all_inclusive),
                        const SizedBox(width: 8),
                        ...AppConstants.wasteTypes.map((type) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildFilterChip(
                              type['name'],
                              type['id'],
                              _getIconData(type['icon']),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),

                // Résumé des résultats
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: BatteColors.muted,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredWastes.length} résultat${filteredWastes.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: BatteColors.foreground,
                        ),
                      ),
                      if (filteredWastes.isNotEmpty)
                        Text(
                          'Total: ${Helpers.formatWeight(_getTotalWeight(filteredWastes))} - ${Helpers.formatCurrency(_getTotalValue(filteredWastes))}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: BatteColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),

                // Liste des déchets
                Expanded(
                  child: filteredWastes.isEmpty
                      ? custom.EmptyWidget(
                          message: _searchQuery.isNotEmpty
                              ? 'Aucun résultat pour "$_searchQuery"'
                              : 'Aucun déchet recyclé pour le moment',
                          icon: Icons.search_off,
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await Provider.of<WasteProvider>(context, listen: false).fetchWastes();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredWastes.length,
                            itemBuilder: (context, index) {
                              final waste = filteredWastes[index];
                              return _buildWasteCard(waste);
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData? icon) {
    final isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? BatteColors.primary : BatteColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? BatteColors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? BatteColors.white : BatteColors.foreground,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? BatteColors.white : BatteColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWasteCard(waste) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _showWasteDetails(waste),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône du type de déchet
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BatteColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  waste.typeIcon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(width: 16),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      waste.typeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Helpers.formatDateTime(waste.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: BatteColors.mutedForeground,
                      ),
                    ),
                    if (waste.notes != null && waste.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        waste.notes!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: BatteColors.mutedForeground,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Poids, valeur et bouton suppression
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: BatteColors.muted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      Helpers.formatWeight(waste.weight),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: BatteColors.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Helpers.formatCurrency(waste.value),
                    style: const TextStyle(
                      fontSize: 16,
                      color: BatteColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    onPressed: () => _showDeleteDialog(waste),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: BatteColors.destructive,
                      size: 20,
                    ),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(waste) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le déchet'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce déchet de ${Helpers.formatWeight(waste.weight)} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final wasteProvider = Provider.of<WasteProvider>(context, listen: false);
              final success = await wasteProvider.deleteWaste(waste.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Déchet supprimé avec succès'),
                    backgroundColor: BatteColors.success,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: BatteColors.destructive),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtrer par type',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedFilter = 'all';
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text('Réinitialiser'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterOption('Tout', 'all', setModalState),
                      ...AppConstants.wasteTypes.map((type) {
                        return _buildFilterOption(
                          type['name'],
                          type['id'],
                          setModalState,
                        );
                      }).toList(),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption(String label, String value, StateSetter setModalState) {
    final isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
        setModalState(() {});
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? BatteColors.primary : BatteColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? BatteColors.primary : BatteColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? BatteColors.white : BatteColors.foreground,
          ),
        ),
      ),
    );
  }

  void _showWasteDetails(waste) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Row(
                children: [
                  Text(
                    waste.typeIcon,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          waste.typeName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Helpers.formatDateTime(waste.date),
                          style: const TextStyle(
                            fontSize: 14,
                            color: BatteColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 32),

              // Détails
              _buildDetailRow('Poids', Helpers.formatWeight(waste.weight), Icons.scale),
              const SizedBox(height: 12),
              _buildDetailRow('Valeur', Helpers.formatCurrency(waste.value), Icons.payments_rounded),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Statut',
                waste.synced ? 'Synchronisé ✅' : 'En attente ⏳',
                Icons.cloud_done,
              ),

              if (waste.notes != null && waste.notes!.isNotEmpty) ...[
                const Divider(height: 32),
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  waste.notes!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: BatteColors.foreground,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Bouton fermer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BatteColors.primary,
                    foregroundColor: BatteColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: BatteColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 14,
            color: BatteColors.mutedForeground,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: BatteColors.foreground,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  double _getTotalWeight(List wastes) {
    return wastes.fold(0.0, (sum, w) => sum + w.weight);
  }

  double _getTotalValue(List wastes) {
    return wastes.fold(0.0, (sum, w) => sum + w.value);
  }

  IconData _getIconData(String iconText) {
    // Convertir le texte emoji en IconData (fallback sur recycling)
    return Icons.recycling;
  }
}

