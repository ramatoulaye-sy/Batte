import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:batte/core/app_theme.dart';
import 'package:batte/services/auth_service.dart';
import 'package:batte/services/supabase_service.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService.instance;
  final SupabaseService _supabase = SupabaseService.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _avatarUrl;
  XFile? _pickedImage;
  Uint8List? _avatarPreviewBytes;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Widget _buildAvatarPicker() {
    final double size = 96;
    ImageProvider? provider;
    if (_avatarPreviewBytes != null) {
      provider = MemoryImage(_avatarPreviewBytes!);
    } else if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      provider = NetworkImage(_avatarUrl!);
    }

    return Row(
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundColor: AppTheme.dividerColor,
          backgroundImage: provider,
          child: provider == null
              ? Icon(Icons.person, size: 48, color: AppTheme.disabledColor)
              : null,
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: _isSaving
              ? null
              : () async {
                  final picker = ImagePicker();
                  final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                  if (img != null) {
                    final bytes = await img.readAsBytes();
                    setState(() {
                      _pickedImage = img;
                      _avatarPreviewBytes = bytes;
                    });
                  }
                },
          icon: const Icon(Icons.photo),
          label: const Text('Changer l\'avatar'),
        ),
      ],
    );
  }

  Future<void> _loadProfile() async {
    try {
      final userId = _supabase.currentUserId;
      if (userId == null) {
        setState(() {
          _errorMessage = 'Utilisateur non connecté';
        });
        return;
      }
      final profile = await _authService.getProfile(userId);
      if (profile != null) {
        _nameController.text = (profile['name'] as String?) ?? '';
        _emailController.text = (profile['email'] as String?) ?? '';
        _cityController.text = (profile['city'] as String?) ?? '';
        _addressController.text = (profile['address'] as String?) ?? '';
        _avatarUrl = (profile['avatar_url'] as String?);
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement du profil';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = _supabase.currentUserId;
    if (userId == null) return;
    setState(() {
      _isSaving = true;
    });
    // Upload avatar si présent
    if (_pickedImage != null) {
      try {
        final bytes = await _pickedImage!.readAsBytes();
        final ext = _pickedImage!.name.split('.').last.toLowerCase();
        final url = await _supabase.uploadUserAvatar(
          userId: userId,
          bytes: bytes,
          fileExtension: ext,
        );
        if (url != null) {
          _avatarUrl = url;
          await _supabase.updateUserProfile(userId, {'avatar_url': _avatarUrl});
        }
      } catch (_) {}
    }
    final success = await _authService.updateProfile(
      userId: userId,
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      // avatar_url sera mis à jour en dehors de updateProfile si upload effectué
    );
    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour')), 
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Échec de la mise à jour')), 
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Paramètres du profil',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enregistrer'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_errorMessage != null
              ? Center(child: Text(_errorMessage!, style: TextStyle(color: AppTheme.errorColor)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAvatarPicker(),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nom complet',
                          icon: Icons.person,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Le nom est requis' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email (optionnel)',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                            return pattern.hasMatch(v.trim()) ? null : 'Email invalide';
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _cityController,
                          label: 'Ville',
                          icon: Icons.location_city,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _addressController,
                          label: 'Adresse',
                          icon: Icons.home,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                )),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
      ),
    );
  }
}


