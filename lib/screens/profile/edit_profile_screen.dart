import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Écran de modification du profil
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      await authProvider.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profil mis à jour avec succès !'),
            backgroundColor: BatteColors.success,
          ),
        );
        Navigator.pop(context, true);
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
        title: const Text('Modifier mon profil'),
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
                CustomTextField(
                  label: 'Nom complet',
                  hint: 'Votre nom',
                  controller: _nameController,
                  prefixIcon: Icons.person,
                  validator: Validators.validateName,
                ),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Téléphone',
                  hint: '+224 XXX XX XX XX',
                  controller: _phoneController,
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Adresse',
                  hint: 'Votre adresse',
                  controller: _addressController,
                  prefixIcon: Icons.location_on,
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: InputDecoration(
                    labelText: 'Bio',
                    hintText: 'Parlez de vous...',
                    prefixIcon: const Icon(Icons.edit_note, color: BatteColors.primary),
                    filled: true,
                    fillColor: BatteColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                CustomButton(
                  text: 'Enregistrer les modifications',
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

