import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/supabase_service.dart';
import '../collector/collector_main_screen.dart';

/// Formulaire d'inscription en tant que collecteur
class CollectorSignupScreen extends StatefulWidget {
  final bool isFromSignup; // true si vient de l'inscription, false si vient de ProfileChoice
  
  const CollectorSignupScreen({
    super.key,
    this.isFromSignup = false,
  });

  @override
  State<CollectorSignupScreen> createState() => _CollectorSignupScreenState();
}

class _CollectorSignupScreenState extends State<CollectorSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _licenseController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _radiusController = TextEditingController(text: '10');
  
  bool _isLoading = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _licenseController.dispose();
    _vehicleController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) throw Exception('Non connecté');

      // 1. Créer le profil collecteur
      await SupabaseService.createProfile('collector');

      // 2. Créer l'entrée collector
      await SupabaseService.client.from('collectors').insert({
        'user_id': userId,
        'business_name': _businessNameController.text.trim(),
        'license_number': _licenseController.text.trim(),
        'vehicle_info': _vehicleController.text.trim(),
        'service_area_radius': int.parse(_radiusController.text),
        'is_available': true,
        'rating': 0,
        'total_collections': 0,
        'total_earnings': 0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profil collecteur créé avec succès !'),
            backgroundColor: BatteColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Attendre un peu pour que le message soit visible
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted) {
          if (widget.isFromSignup) {
            // Vient de l'inscription → Rediriger vers le dashboard collecteur
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const CollectorMainScreen(),
              ),
            );
          } else {
            // Vient de ProfileChoice → Retourner avec succès
            Navigator.of(context).pop(true);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur : ${e.toString()}'),
            backgroundColor: BatteColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devenir Collecteur'),
        backgroundColor: BatteColors.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.local_shipping,
                  size: 80,
                  color: BatteColors.primary,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Inscription Collecteur',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Remplissez les informations pour devenir collecteur',
                  style: TextStyle(
                    fontSize: 14,
                    color: BatteColors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Nom du business
                TextFormField(
                  controller: _businessNameController,
                  decoration: InputDecoration(
                    labelText: 'Nom du business',
                    hintText: 'Ex: Recyclage Conakry',
                    prefixIcon: const Icon(Icons.business),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nom du business requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Numéro de licence
                TextFormField(
                  controller: _licenseController,
                  decoration: InputDecoration(
                    labelText: 'Numéro de licence',
                    hintText: 'Ex: RC-GN-2024-001',
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Numéro de licence requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Informations véhicule
                TextFormField(
                  controller: _vehicleController,
                  decoration: InputDecoration(
                    labelText: 'Informations véhicule',
                    hintText: 'Ex: Camion Mercedes - GN-123-ABC',
                    prefixIcon: const Icon(Icons.local_shipping),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informations véhicule requises';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Rayon de service
                TextFormField(
                  controller: _radiusController,
                  decoration: InputDecoration(
                    labelText: 'Rayon de service (km)',
                    hintText: 'Ex: 10',
                    prefixIcon: const Icon(Icons.map),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Rayon de service requis';
                    }
                    final radius = int.tryParse(value);
                    if (radius == null || radius < 1 || radius > 50) {
                      return 'Rayon entre 1 et 50 km';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Bouton de soumission
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BatteColors.primary,
                    foregroundColor: BatteColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              BatteColors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Créer mon profil collecteur',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // Note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BatteColors.muted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: BatteColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Votre profil sera vérifié avant activation. Vous recevrez une notification une fois approuvé.',
                          style: TextStyle(
                            fontSize: 12,
                            color: BatteColors.mutedForeground,
                          ),
                        ),
                      ),
                    ],
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

