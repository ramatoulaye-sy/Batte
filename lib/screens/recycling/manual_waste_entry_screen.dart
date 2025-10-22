import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../providers/waste_provider.dart';
import '../../services/notification_service.dart';

/// Écran de saisie manuelle de déchets multiples
/// Permet d'ajouter plusieurs types de déchets en une seule fois
class ManualWasteEntryScreen extends StatefulWidget {
  const ManualWasteEntryScreen({Key? key}) : super(key: key);

  @override
  State<ManualWasteEntryScreen> createState() => _ManualWasteEntryScreenState();
}

class _ManualWasteEntryScreenState extends State<ManualWasteEntryScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  List<WasteEntry> _wasteEntries = [];
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
    
    // Ajouter une entrée par défaut
    _addWasteEntry();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _animationController.dispose();
    for (var entry in _wasteEntries) {
      entry.weightController.dispose();
    }
    super.dispose();
  }

  void _addWasteEntry() {
    setState(() {
      _wasteEntries.add(WasteEntry());
    });
  }

  void _removeWasteEntry(int index) {
    if (_wasteEntries.length > 1) {
      setState(() {
        _wasteEntries[index].weightController.dispose();
        _wasteEntries.removeAt(index);
      });
    }
  }

  Future<void> _submitWastes() async {
    // Valider tous les champs
    bool isValid = true;
    for (var entry in _wasteEntries) {
      if (entry.selectedWasteType == null || entry.weightController.text.trim().isEmpty) {
        isValid = false;
        break;
      }
    }

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs requis'),
          backgroundColor: BatteColors.destructive,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final wasteProvider = Provider.of<WasteProvider>(context, listen: false);
      double totalValue = 0;
      int successCount = 0;

      // Ajouter chaque déchet
      for (var entry in _wasteEntries) {
        final weight = double.parse(entry.weightController.text.trim());
        final value = Helpers.calculateWasteValue(entry.selectedWasteType!, weight);
        
        final success = await wasteProvider.addWaste(
          type: entry.selectedWasteType!,
          weight: weight,
          notes: _notesController.text.trim().isNotEmpty 
              ? _notesController.text.trim() 
              : null,
        );

        if (success) {
          totalValue += value;
          successCount++;
        }
      }

      if (successCount > 0 && mounted) {
        // Afficher notification de succès
        await NotificationService.showLocalNotification(
          title: '🎉 Recyclage réussi !',
          body: 'Vous avez ajouté $successCount déchet(s) pour ${Helpers.formatCurrency(totalValue)}. Merci ! 🌍',
        );

        // Afficher message de succès avec animation
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => _buildSuccessDialog(totalValue, successCount),
          );
        }

        // Fermer après 2 secondes
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop(); // Fermer dialog
          Navigator.of(context).pop(true); // Retourner avec succès
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: BatteColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildSuccessDialog(double totalValue, int count) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: BatteColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: BatteColors.primary.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recyclage réussi !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$count déchet(s) ajouté(s)',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Valeur totale: ${Helpers.formatCurrency(totalValue)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: BatteColors.gold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Merci pour votre contribution écologique ! 🌍',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BatteColors.softGreen,
      appBar: AppBar(
        backgroundColor: BatteColors.primary,
        elevation: 0,
        title: const Text(
          'Ajouter des déchets',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ScaleTransition(
        scale: _scaleAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: BatteColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: BatteColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Saisie manuelle',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ajoutez plusieurs types de déchets',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Liste des déchets
                ...List.generate(_wasteEntries.length, (index) {
                  return _buildWasteEntryCard(index);
                }),
                
                const SizedBox(height: 16),
                
                // Bouton ajouter un déchet
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _addWasteEntry,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un autre déchet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BatteColors.lightGreen,
                      foregroundColor: BatteColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Notes
                Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes (optionnel)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: BatteColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Ajoutez des commentaires...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: BatteColors.primary.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: BatteColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Bouton de soumission
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitWastes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BatteColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Valider tous les déchets',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    ),
                  ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWasteEntryCard(int index) {
    final entry = _wasteEntries[index];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la carte
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: BatteColors.lightGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: BatteColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Déchet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BatteColors.foreground,
                  ),
                ),
              ),
              if (_wasteEntries.length > 1)
                IconButton(
                  onPressed: () => _removeWasteEntry(index),
                  icon: const Icon(
                    Icons.remove_circle,
                    color: BatteColors.destructive,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Sélection du type de déchet
          const Text(
            'Type de déchet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: BatteColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: entry.selectedWasteType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: BatteColors.primary.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: BatteColors.primary,
                  width: 2,
                ),
              ),
            ),
            hint: const Text('Sélectionnez un type'),
            items: AppConstants.wasteTypes.map((wasteType) {
              return DropdownMenuItem<String>(
                value: wasteType['id'],
                child: Row(
                  children: [
                    Text(
                      wasteType['icon'],
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(wasteType['name']),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                entry.selectedWasteType = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Veuillez sélectionner un type';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Saisie du poids
          const Text(
            'Poids (kg)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: BatteColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: entry.weightController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Ex: 2.5',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: BatteColors.primary.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: BatteColors.primary,
                  width: 2,
                ),
              ),
              suffixText: 'kg',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Veuillez saisir le poids';
              }
              final weight = double.tryParse(value.trim());
              if (weight == null || weight <= 0) {
                return 'Poids invalide';
              }
              return null;
            },
          ),
          
          // Affichage de la valeur calculée
          if (entry.selectedWasteType != null && entry.weightController.text.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BatteColors.lightGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: BatteColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.payments_rounded,
                    color: BatteColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Valeur estimée: ${Helpers.formatCurrency(
                      Helpers.calculateWasteValue(
                        entry.selectedWasteType!,
                        double.tryParse(entry.weightController.text.trim()) ?? 0,
                      ),
                    )}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: BatteColors.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Classe pour représenter une entrée de déchet
class WasteEntry {
  String? selectedWasteType;
  final TextEditingController weightController = TextEditingController();
  
  WasteEntry();
}