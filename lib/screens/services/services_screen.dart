import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/supabase_service.dart';
import '../../models/job_model.dart';
import '../../widgets/loading_widget.dart' as custom;
import '../profile/profile_screen.dart';

/// Écran du module Services
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);
  
  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<JobModel> _jobs = [];
  bool _isLoading = false;
  String _selectedType = 'all';
  
  @override
  void initState() {
    super.initState();
    _loadJobs();
  }
  
  Future<void> _loadJobs() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final data = await SupabaseService.getJobs(
        type: _selectedType == 'all' ? null : _selectedType,
      );
      if (!mounted) return;
      setState(() {
        _jobs = data.map((json) => JobModel.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: BatteColors.chart1,
              title: const Text('Services'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  tooltip: 'Mon profil',
                ),
              ],
            ),
            
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Je cherche',
                          Icons.search,
                          BatteColors.primary,
                          () {
                            setState(() => _selectedType = 'request');
                            _loadJobs();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionButton(
                          'Je propose',
                          Icons.work_outline,
                          BatteColors.secondary,
                          () {
                            // TODO: Ouvrir formulaire de création d'offre
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Filtres
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Tout', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Demandes', 'request'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Offres', 'offer'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Liste des services
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_jobs.isEmpty)
                    const custom.EmptyWidget(
                      message: 'Aucun service disponible',
                      icon: Icons.work_off,
                    )
                  else
                    ..._jobs.map((job) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: BatteColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: BatteColors.primary,
                                    child: Text(
                                      job.userName[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: BatteColors.white,
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
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (job.location != null)
                                          Text(
                                            job.location!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: BatteColors.mutedForeground,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: job.type == 'offer'
                                          ? BatteColors.success.withOpacity(0.1)
                                          : BatteColors.purple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      job.type == 'offer' ? 'Offre' : 'Demande',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: job.type == 'offer'
                                            ? BatteColors.success
                                            : BatteColors.purple,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        job.categoryIcon,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          job.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    job.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: BatteColors.foreground,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            
                            if (job.skills != null && job.skills!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16),
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
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        skill,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: BatteColors.foreground,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                if (job.salary != null) ...[
                                  const Icon(
                                    Icons.payments_rounded,
                                    size: 16,
                                    color: BatteColors.secondary,
                                  ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${job.salary!.toStringAsFixed(0)} GNF',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: BatteColors.secondary,
                                      ),
                                    ),
                                    const Spacer(),
                                  ],
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO: Postuler ou contacter
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: BatteColors.primary,
                                      foregroundColor: BatteColors.white,
                                    ),
                                    child: const Text('Contacter'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String type) {
    final isSelected = _selectedType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
        _loadJobs();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? BatteColors.chart1 : BatteColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? BatteColors.chart1 : Colors.transparent,
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
}

