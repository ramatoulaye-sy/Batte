import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/colors.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Écran de changement de mot de passe
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Vérifier le mot de passe actuel
      final currentUser = SupabaseService.currentUser;
      if (currentUser?.email == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Tenter de se reconnecter avec le mot de passe actuel pour vérifier
      await SupabaseService.client.auth.signInWithPassword(
        email: currentUser!.email!,
        password: _currentPasswordController.text.trim(),
      );

      // Si la connexion réussit, changer le mot de passe
      await SupabaseService.client.auth.updateUser(
        UserAttributes(password: _newPasswordController.text.trim()),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Mot de passe modifié avec succès !'),
            backgroundColor: BatteColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Erreur lors du changement de mot de passe';
        
        if (e.toString().contains('Invalid login credentials')) {
          errorMessage = 'Mot de passe actuel incorrect';
        } else if (e.toString().contains('Password should be at least')) {
          errorMessage = 'Le nouveau mot de passe doit contenir au moins 6 caractères';
        } else if (e.toString().contains('same as the old password')) {
          errorMessage = 'Le nouveau mot de passe doit être différent de l\'ancien';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMessage'),
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
        title: const Text('Changer mon mot de passe'),
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
                // Icône et titre
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: BatteColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 64,
                        color: BatteColors.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Sécurité du compte',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choisissez un mot de passe fort pour protéger votre compte',
                        style: TextStyle(
                          color: BatteColors.mutedForeground,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Mot de passe actuel
                CustomTextField(
                  label: 'Mot de passe actuel',
                  hint: 'Entrez votre mot de passe actuel',
                  controller: _currentPasswordController,
                  prefixIcon: Icons.lock,
                  obscureText: _obscureCurrentPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mot de passe actuel requis';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Nouveau mot de passe
                CustomTextField(
                  label: 'Nouveau mot de passe',
                  hint: 'Entrez votre nouveau mot de passe',
                  controller: _newPasswordController,
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureNewPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nouveau mot de passe requis';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Confirmation du nouveau mot de passe
                CustomTextField(
                  label: 'Confirmer le nouveau mot de passe',
                  hint: 'Confirmez votre nouveau mot de passe',
                  controller: _confirmPasswordController,
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirmation requise';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Conseils de sécurité
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BatteColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: BatteColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: BatteColors.info,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Conseils pour un mot de passe sécurisé',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: BatteColors.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Au moins 8 caractères\n'
                        '• Mélange de lettres majuscules et minuscules\n'
                        '• Au moins un chiffre\n'
                        '• Au moins un caractère spécial (!@#\$%^&*)',
                        style: TextStyle(
                          fontSize: 12,
                          color: BatteColors.info,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Bouton de soumission
                CustomButton(
                  text: 'Modifier le mot de passe',
                  onPressed: _submit,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
