import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/job_model.dart';
import '../../providers/services_provider.dart';
import '../../providers/auth_provider.dart';
import '../profile/profile_screen.dart';

/// Écran Services moderne avec design harmonisé
class ModernServicesScreen extends StatefulWidget {
  const ModernServicesScreen({super.key});
  
  @override
  State<ModernServicesScreen> createState() => _ModernServicesScreenState();
}

class _ModernServicesScreenState extends State<ModernServicesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<JobModel> _jobs = [];
  bool _isLoading = false;
  String _selectedType = 'all';
  
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
      Provider.of<ServicesProvider>(context, listen: false).loadJobs();
      _loadJobs();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadJobs() async {
    if (!mounted) return;
    
    setState(() { _isLoading = true; });
    
    try {
      final servicesProvider = Provider.of<ServicesProvider>(context, listen: false);
      await servicesProvider.loadJobs();
      
      if (mounted) {
        setState(() {
          _jobs = servicesProvider.jobs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadJobs();
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        gradient: BatteColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
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
          // Logo services
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.work_rounded,
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
                  'Services',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Trouvez et proposez des services',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Bouton profil
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildModernActionButton(
            icon: Icons.search_rounded,
            label: 'Je cherche',
            gradient: BatteColors.primaryGradient,
            onTap: () {
              _showCreateRequestForm();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildModernActionButton(
            icon: Icons.add_business_rounded,
            label: 'Je propose',
            gradient: BatteColors.goldGradient,
            onTap: () {
              _showCreateOfferForm();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernActionButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
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
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildModernFilterChip(
            label: 'Tout',
            icon: Icons.grid_view_rounded,
            type: 'all',
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
            ),
          ),
          const SizedBox(width: 12),
          _buildModernFilterChip(
            label: 'Demandes',
            icon: Icons.search_rounded,
            type: 'request',
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
            ),
          ),
          const SizedBox(width: 12),
          _buildModernFilterChip(
            label: 'Offres',
            icon: Icons.work_outline_rounded,
            type: 'offer',
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterChip({
    required String label,
    required IconData icon,
    required String type,
    required Gradient gradient,
  }) {
    final isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
        _loadJobs();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.15 : 0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : BatteColors.mutedForeground,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : BatteColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsList() {
    final filteredJobs = _jobs.where((job) {
      if (_selectedType == 'all') return true;
      return job.type == _selectedType;
    }).toList();

    return Column(
      children: [
        if (filteredJobs.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: BatteColors.lightGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _selectedType == 'offer' 
                        ? Icons.work_outline_rounded
                        : _selectedType == 'request'
                            ? Icons.search_off_rounded
                            : Icons.inbox_rounded,
                    size: 40,
                    color: BatteColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aucun service disponible',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BatteColors.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Revenez plus tard ou proposez un service',
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
          ...filteredJobs.map((job) => _buildModernJobCard(job)),
      ],
    );
  }

  Widget _buildModernJobCard(JobModel job) {
    final isOffer = job.type == 'offer';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header avec utilisateur
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: BatteColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      job.userName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.userName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: BatteColors.foreground,
                        ),
                      ),
                      if (job.location != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: BatteColors.foreground.withOpacity(0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              job.location!,
                              style: TextStyle(
                                fontSize: 12,
                                color: BatteColors.foreground.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isOffer
                        ? BatteColors.success.withOpacity(0.1)
                        : const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isOffer ? 'Offre' : 'Demande',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isOffer ? BatteColors.success : const Color(0xFF8B5CF6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: BatteColors.lightGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        job.categoryIcon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: BatteColors.foreground,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  job.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: BatteColors.foreground.withOpacity(0.7),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Compétences
          if (job.skills != null && job.skills!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.skills!.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: BatteColors.muted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: BatteColors.foreground.withOpacity(0.7),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          
          // Footer avec prix et action
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (job.salary != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: BatteColors.gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.payments_rounded,
                          size: 20,
                          color: BatteColors.foreground,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${job.salary!.toStringAsFixed(0)} GNF',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: BatteColors.foreground,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Messagerie bientôt disponible !'),
                          backgroundColor: BatteColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_rounded, size: 18),
                    label: const Text('Contacter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BatteColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateOfferForm() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    final locationController = TextEditingController();
    String category = 'Ménage';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: BatteColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add_business,
                          color: BatteColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Proposer un service',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: BatteColors.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Titre du service',
                      hintText: 'Ex: Nettoyage de maison',
                      labelStyle: TextStyle(color: BatteColors.primary),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: BatteColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description détaillée',
                      hintText: 'Décrivez votre service en détail...',
                      labelStyle: TextStyle(color: BatteColors.primary),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: BatteColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: InputDecoration(
                      labelText: 'Catégorie',
                      labelStyle: TextStyle(color: BatteColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: BatteColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      prefixIcon: Icon(Icons.category, color: BatteColors.primary),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Ménage', child: Text('Ménage')),
                      DropdownMenuItem(value: 'Jardinage', child: Text('Jardinage')),
                      DropdownMenuItem(value: 'Bricolage', child: Text('Bricolage')),
                      DropdownMenuItem(value: 'Cours', child: Text('Cours')),
                      DropdownMenuItem(value: 'Autre', child: Text('Autre')),
                    ],
                    onChanged: (value) => category = value ?? 'Ménage',
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: durationController,
                    decoration: InputDecoration(
                      labelText: 'Durée estimée',
                      hintText: 'Ex: 2 heures, 1 jour, 3 jours',
                      labelStyle: TextStyle(color: BatteColors.primary),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: BatteColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      prefixIcon: Icon(Icons.access_time, color: BatteColors.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Tarif (GNF)',
                      hintText: 'Ex: 50000',
                      labelStyle: TextStyle(color: BatteColors.primary),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: BatteColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      prefixIcon: Icon(Icons.monetization_on, color: BatteColors.primary),
                      suffixText: 'GNF',
                      suffixStyle: TextStyle(color: BatteColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: 'Adresse',
                      hintText: 'Ex: Conakry, Kaloum',
                      labelStyle: TextStyle(color: BatteColors.primary),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: BatteColors.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      prefixIcon: Icon(Icons.location_on, color: BatteColors.primary),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Annuler',
                            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final auth = Provider.of<AuthProvider>(context, listen: false);
                            final services = Provider.of<ServicesProvider>(context, listen: false);
                            final user = auth.user;
                            if (titleController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Veuillez renseigner au moins un titre et une description.'),
                                  backgroundColor: BatteColors.primary,
                                ),
                              );
                              return;
                            }
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Veuillez vous connecter pour publier une offre.'),
                                  backgroundColor: BatteColors.primary,
                                ),
                              );
                              return;
                            }
                            final ok = await services.createOffer(
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              category: category,
                              price: double.tryParse(priceController.text.trim()),
                              location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
                              skills: null,
                              userId: user.id,
                              userName: user.name ?? 'Utilisateur',
                              userPhone: user.phone,
                            );
                        if (!mounted) return;
                        if (ok) {
                          Navigator.of(context).pop();
                          setState(() { _selectedType = 'offer'; });
                          await _loadJobs();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Offre créée'), backgroundColor: BatteColors.primary),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Échec de création de l\'offre. Réessayez.'),
                                backgroundColor: BatteColors.primary,
                              ),
                            );
                          }
                        }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BatteColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 2,
                          ),
                          child: const Text('Publier', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateRequestForm() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final budgetController = TextEditingController();
    final durationController = TextEditingController();
    final locationController = TextEditingController();
    final requirementsController = TextEditingController();
    String category = 'Ménage';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.search,
                          color: Color(0xFF8B5CF6),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Demander un service',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8B5CF6),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Titre de la demande',
                      hintText: 'Ex: Besoin de nettoyage',
                      labelStyle: const TextStyle(color: Color(0xFF8B5CF6)),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description détaillée',
                      hintText: 'Décrivez ce dont vous avez besoin...',
                      labelStyle: const TextStyle(color: Color(0xFF8B5CF6)),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: durationController,
                    decoration: InputDecoration(
                      labelText: 'Durée souhaitée',
                      hintText: 'Ex: 2 heures, 1 jour, 3 jours',
                      labelStyle: const TextStyle(color: Color(0xFF8B5CF6)),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      prefixIcon: const Icon(Icons.access_time, color: Color(0xFF8B5CF6)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: budgetController,
                    decoration: InputDecoration(
                      labelText: 'Budget maximum (GNF)',
                      hintText: 'Ex: 100000',
                      labelStyle: const TextStyle(color: Color(0xFF8B5CF6)),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      prefixIcon: const Icon(Icons.monetization_on, color: Color(0xFF8B5CF6)),
                      suffixText: 'GNF',
                      suffixStyle: const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: InputDecoration(
                      labelText: 'Catégorie',
                      labelStyle: const TextStyle(color: Color(0xFF8B5CF6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      prefixIcon: const Icon(Icons.category, color: Color(0xFF8B5CF6)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Ménage', child: Text('Ménage')),
                      DropdownMenuItem(value: 'Jardinage', child: Text('Jardinage')),
                      DropdownMenuItem(value: 'Bricolage', child: Text('Bricolage')),
                      DropdownMenuItem(value: 'Cours', child: Text('Cours')),
                      DropdownMenuItem(value: 'Autre', child: Text('Autre')),
                    ],
                    onChanged: (value) => category = value ?? 'Ménage',
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: 'Adresse',
                      hintText: 'Ex: Conakry, Kaloum',
                      labelStyle: const TextStyle(color: Color(0xFF8B5CF6)),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      prefixIcon: const Icon(Icons.location_on, color: Color(0xFF8B5CF6)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: requirementsController,
                    decoration: InputDecoration(
                      labelText: 'Exigences particulières (optionnel)',
                      hintText: 'Ex: Disponible le weekend',
                      labelStyle: const TextStyle(color: Color(0xFF8B5CF6)),
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Annuler',
                            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final auth = Provider.of<AuthProvider>(context, listen: false);
                            final services = Provider.of<ServicesProvider>(context, listen: false);
                            final user = auth.user;
                            if (titleController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Veuillez renseigner au moins un titre et une description.'),
                                  backgroundColor: Color(0xFF8B5CF6),
                                ),
                              );
                              return;
                            }
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Veuillez vous connecter pour publier une demande.'),
                                  backgroundColor: Color(0xFF8B5CF6),
                                ),
                              );
                              return;
                            }
                            final ok = await services.createRequest(
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              category: category,
                              budget: double.tryParse(budgetController.text.trim()),
                              location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
                              requirements: requirementsController.text.trim().isEmpty ? null : [requirementsController.text.trim()],
                              userId: user.id,
                              userName: user.name ?? 'Utilisateur',
                              userPhone: user.phone,
                            );
                        if (!mounted) return;
                        if (ok) {
                          Navigator.of(context).pop();
                          setState(() { _selectedType = 'request'; });
                          await _loadJobs();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Demande créée'), backgroundColor: Color(0xFF8B5CF6)),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Échec de création de la demande. Réessayez.'),
                                backgroundColor: Color(0xFF8B5CF6),
                              ),
                            );
                          }
                        }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 2,
                          ),
                          child: const Text('Publier', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BatteColors.softGreen,
      body: _isLoading && _jobs.isEmpty
          ? Center(
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
                    'Chargement des services...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: BatteColors.foreground,
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: _refreshData,
                color: BatteColors.primary,
                backgroundColor: Colors.white,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header moderne
                    SliverToBoxAdapter(
                      child: _buildModernHeader(),
                    ),
                    
                    // Actions rapides
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: _buildQuickActions(),
                      ),
                    ),
                    
                    // Filtres
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: _buildModernFilters(),
                      ),
                    ),
                    
                    // Liste des jobs
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                        child: _buildJobsList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}