import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/education_provider.dart';
import 'quiz_screen.dart';

/// Écran Éducation moderne avec design harmonisé
class ModernEducationScreen extends StatefulWidget {
  const ModernEducationScreen({Key? key}) : super(key: key);
  
  @override
  State<ModernEducationScreen> createState() => _ModernEducationScreenState();
}

class _ModernEducationScreenState extends State<ModernEducationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
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
      final provider = Provider.of<EducationProvider>(context, listen: false);
      provider.fetchContent();
      provider.fetchProgress();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final provider = Provider.of<EducationProvider>(context, listen: false);
    await provider.fetchContent();
    await provider.fetchProgress();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BatteColors.softGreen,
      body: Consumer<EducationProvider>(
        builder: (context, educationProvider, child) {
          if (educationProvider.isLoading && educationProvider.contents.isEmpty) {
            return Center(
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
                    'Chargement du contenu éducatif...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: BatteColors.foreground,
                    ),
                  ),
                ],
              ),
            );
          }
          
          final contents = _selectedType == 'all'
              ? educationProvider.contents
              : educationProvider.getContentByType(_selectedType);
          
          return FadeTransition(
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
                  
                  // Contenu
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 24),

                        // Carte de progression moderne
                        _buildModernProgressCard(educationProvider),
                        
                        const SizedBox(height: 24),
                        
                        // Filtres modernes
                        _buildModernFilters(),
                        
                        const SizedBox(height: 24),
                        
                        // Liste de contenu
                        _buildContentSection(contents, educationProvider),
                        
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 48,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo éducation
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.school_rounded,
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
                  'Éducation',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: BatteColors.foreground,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Apprenez et progressez chaque jour',
                  style: TextStyle(
                    fontSize: 13,
                    color: BatteColors.mutedForeground,
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

  Widget _buildModernProgressCard(EducationProvider educationProvider) {
    final progress = educationProvider.progressPercentage / 100;
    
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Votre progression',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${educationProvider.progressPercentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.stars,
                      color: BatteColors.gold,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${educationProvider.totalPoints} points',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${educationProvider.contents.where((c) => c.completed).length} terminés',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
            gradient: BatteColors.primaryGradient,
          ),
          const SizedBox(width: 12),
          _buildModernFilterChip(
            label: 'Vidéos',
            icon: Icons.play_circle_rounded,
            type: 'video',
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
            ),
          ),
          const SizedBox(width: 12),
          _buildModernFilterChip(
            label: 'Audio',
            icon: Icons.headphones_rounded,
            type: 'audio',
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
            ),
          ),
          const SizedBox(width: 12),
          _buildModernFilterChip(
            label: 'Quiz',
            icon: Icons.quiz_rounded,
            type: 'quiz',
            gradient: BatteColors.goldGradient,
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
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.2 : 0.05),
              blurRadius: isSelected ? 15 : 10,
              offset: Offset(0, isSelected ? 8 : 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : BatteColors.foreground,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : BatteColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(List contents, EducationProvider educationProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BatteColors.lightGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: BatteColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Contenu disponible',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: BatteColors.foreground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (contents.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
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
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: BatteColors.lightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 40,
                    color: BatteColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aucun contenu disponible',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BatteColors.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Revenez plus tard pour du nouveau contenu',
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
          ...contents.map((content) {
            return GestureDetector(
              onTap: () {
                if (content.type == 'quiz') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(content: content),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lecture de contenu bientôt disponible'),
                      backgroundColor: BatteColors.primary,
                    ),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
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
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: _getContentGradient(content.type),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getContentIcon(content.type),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            content.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: BatteColors.foreground,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getContentColor(content.type).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.stars,
                                      size: 14,
                                      color: _getContentColor(content.type),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${content.points} pts',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _getContentColor(content.type),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (content.completed)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: BatteColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 14,
                                        color: BatteColors.success,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Terminé',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: BatteColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: BatteColors.mutedForeground,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  IconData _getContentIcon(String type) {
    switch (type) {
      case 'video':
        return Icons.play_circle_rounded;
      case 'audio':
        return Icons.headphones_rounded;
      case 'quiz':
        return Icons.quiz_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  Gradient _getContentGradient(String type) {
    switch (type) {
      case 'video':
        return const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        );
      case 'audio':
        return const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        );
      case 'quiz':
        return BatteColors.goldGradient;
      default:
        return BatteColors.primaryGradient;
    }
  }

  Color _getContentColor(String type) {
    switch (type) {
      case 'video':
        return const Color(0xFFEF4444);
      case 'audio':
        return const Color(0xFF3B82F6);
      case 'quiz':
        return const Color(0xFFF7E2AC);
      default:
        return BatteColors.primary;
    }
  }
}

