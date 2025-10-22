import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/constants/colors.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/waste_provider.dart';
import '../../services/supabase_service.dart';
import 'edit_profile_screen.dart';
import '../social/referral_screen.dart';
import 'change_password_screen.dart';

/// Écran de profil utilisateur complet
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    
    try {
      final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
      final wasteProvider = Provider.of<WasteProvider>(context, listen: false);
      
      // Charger les données locales d'abord pour éviter les erreurs de build
      await Future.wait([
        budgetProvider.loadLocalTransactions(),
        budgetProvider.fetchStats(),
        wasteProvider.loadLocalWastes(),
        wasteProvider.fetchStats(),
      ]);
      
      final totalWithdrawn = budgetProvider.transactions
          .where((t) => t.type == 'withdrawal')
          .fold<double>(0, (sum, t) => sum + t.amount.abs());
      
      final totalEarned = budgetProvider.transactions
          .where((t) => t.type == 'recycling')
          .fold<double>(0, (sum, t) => sum + t.amount);
      
      setState(() {
        _stats = {
          'totalWastes': wasteProvider.wastes.length,
          'totalWeight': wasteProvider.totalWeight,
          'totalEarned': totalEarned,
          'totalWithdrawn': totalWithdrawn,
          'transactionsCount': budgetProvider.transactions.length,
        };
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar avec photo de profil
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: BatteColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      BatteColors.primary,
                      BatteColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: BatteColors.white,
                          child: user?.avatarUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    user!.avatarUrl!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildInitialsAvatar(user.name ?? ''),
                                  ),
                                )
                              : _buildInitialsAvatar(user?.name ?? ''),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _changePhoto,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: BatteColors.secondary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: BatteColors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: BatteColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? 'Utilisateur',
                      style: const TextStyle(
                        color: BatteColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        color: BatteColors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [],
          ),

          // Statistiques
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mes Statistiques',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Grille de stats
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        'Déchets recyclés',
                        '${_stats['totalWastes'] ?? 0}',
                        Icons.recycling,
                        BatteColors.primary,
                      ),
                      _buildStatCard(
                        'Poids total',
                        Helpers.formatWeight(_stats['totalWeight'] ?? 0),
                        Icons.scale,
                        BatteColors.success,
                      ),
                      _buildStatCard(
                        'Gains totaux',
                        Helpers.formatCurrency(_stats['totalEarned'] ?? 0),
                        Icons.payments_rounded,
                        BatteColors.secondary,
                      ),
                      _buildStatCard(
                        'Retraits',
                        Helpers.formatCurrency(_stats['totalWithdrawn'] ?? 0),
                        Icons.account_balance_wallet,
                        BatteColors.purple,
                      ),
                      _buildStatCard(
                        'Eco-Score',
                        '${user?.ecoScore ?? 0}',
                        Icons.star,
                        Colors.amber,
                      ),
                      _buildStatCard(
                        'Niveau',
                        '${user?.level ?? 1}',
                        Icons.trending_up,
                        BatteColors.info,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Informations du compte
                  const Text(
                    'Informations du compte',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoTile(
                    Icons.person,
                    'Nom complet',
                    user?.name ?? 'Non renseigné',
                  ),
                  _buildInfoTile(
                    Icons.email,
                    'Email',
                    user?.email ?? 'Non renseigné',
                  ),
                  _buildInfoTile(
                    Icons.phone,
                    'Téléphone',
                    user?.phone ?? 'Non renseigné',
                  ),
                  _buildInfoTile(
                    Icons.location_on,
                    'Adresse',
                    user?.address ?? 'Non renseignée',
                  ),
                  _buildInfoTile(
                    Icons.edit_note,
                    'Bio',
                    user?.bio ?? 'Aucune bio',
                  ),

                  const SizedBox(height: 24),

                  // Actions
                  const Text(
                    'Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bouton d'édition professionnel
                  _buildProfessionalEditButton(),

                  const SizedBox(height: 12),

                  _buildActionButton(
                    Icons.share,
                    'Parrainer des amis',
                    BatteColors.success,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReferralScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildActionButton(
                    Icons.lock_outline,
                    'Changer mon mot de passe',
                    BatteColors.warning,
                    _changePassword,
                  ),

                  const SizedBox(height: 12),

                  _buildActionButton(
                    Icons.delete_outline,
                    'Supprimer mon compte',
                    BatteColors.destructive,
                    _deleteAccount,
                  ),

                  const SizedBox(height: 12),

                  _buildActionButton(
                    Icons.logout,
                    'Déconnexion',
                    BatteColors.mutedForeground,
                    _logout,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildInitialsAvatar(String name) {
    final initials = name.isNotEmpty
        ? name.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
        : 'U';
    
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: BatteColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: BatteColors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BatteColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: BatteColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: BatteColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePhoto() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(isCamera: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(isCamera: true);
              },
            ),
              if (Provider.of<AuthProvider>(context, listen: false).user?.avatarUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: BatteColors.destructive),
                title: const Text(
                  'Supprimer la photo',
                  style: TextStyle(color: BatteColors.destructive),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage({required bool isCamera}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadImage(File(image.path));
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
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Upload vers Supabase Storage
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'avatars/$fileName';
      
      final result = await SupabaseService.client.storage
          .from('avatars')
          .upload(filePath, imageFile);

      if (result.isNotEmpty) {
        // Obtenir l'URL publique
        final publicUrl = SupabaseService.client.storage
            .from('avatars')
            .getPublicUrl(filePath);

        // Mettre à jour le profil utilisateur
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.updateProfile(avatarUrl: publicUrl);

        if (mounted) {
          Navigator.pop(context); // Fermer le dialog de chargement
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Photo de profil mise à jour !'),
              backgroundColor: BatteColors.success,
            ),
          );
          _loadStats(); // Rafraîchir les données
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fermer le dialog de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur upload : ${e.toString()}'),
            backgroundColor: BatteColors.destructive,
          ),
        );
      }
    }
  }

  Future<void> _removePhoto() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la photo'),
        content: const Text('Êtes-vous sûr de vouloir supprimer votre photo de profil ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: BatteColors.destructive,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Mettre à jour le profil pour supprimer l'URL de l'avatar
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.updateProfile(avatarUrl: '');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Photo de profil supprimée !'),
              backgroundColor: BatteColors.success,
            ),
          );
          _loadStats(); // Rafraîchir les données
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
      }
    }
  }

  Future<void> _changePassword() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ChangePasswordScreen(),
      ),
    );
    
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Mot de passe modifié avec succès !'),
          backgroundColor: BatteColors.success,
        ),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer mon compte'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer votre compte ? '
          'Cette action est irréversible et toutes vos données seront perdues.\n\n'
          'Tapez "SUPPRIMER" pour confirmer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: BatteColors.destructive,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Demander confirmation finale avec saisie
      final finalConfirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          final controller = TextEditingController();
          return AlertDialog(
            title: const Text('Confirmation finale'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Tapez "SUPPRIMER" pour confirmer la suppression :'),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'SUPPRIMER',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.trim() == 'SUPPRIMER') {
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez taper "SUPPRIMER" exactement'),
                        backgroundColor: BatteColors.destructive,
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: BatteColors.destructive,
                ),
                child: const Text('Supprimer définitivement'),
              ),
            ],
          );
        },
      );

      if (finalConfirmed == true) {
        try {
          // Afficher un indicateur de chargement
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          // Supprimer le compte via Supabase
          await SupabaseService.client.auth.admin.deleteUser(
            SupabaseService.currentUser!.id,
          );

          if (mounted) {
            Navigator.pop(context); // Fermer le dialog de chargement
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Compte supprimé avec succès'),
                backgroundColor: BatteColors.success,
              ),
            );
            
            // Rediriger vers l'écran de connexion
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        } catch (e) {
          if (mounted) {
            Navigator.pop(context); // Fermer le dialog de chargement
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Erreur : ${e.toString()}'),
                backgroundColor: BatteColors.destructive,
              ),
            );
          }
        }
      }
    }
  }

  Widget _buildProfessionalEditButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: BatteColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: BatteColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _navigateToEdit,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Modifier mes informations',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );
    if (result == true) {
      // Rafraîchir le profil après modification
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshFromLocal(); // Recharger depuis le stockage local
      _loadStats();
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
}

