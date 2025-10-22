import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/education_provider.dart';
import '../../widgets/loading_widget.dart' as custom;
import 'quiz_screen.dart';

/// Écran du module Éducation
class EducationScreen extends StatefulWidget {
  const EducationScreen({Key? key}) : super(key: key);
  
  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String _selectedType = 'all';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EducationProvider>(context, listen: false);
      provider.fetchContent();
      provider.fetchProgress();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<EducationProvider>(
          builder: (context, educationProvider, child) {
            if (educationProvider.isLoading && educationProvider.contents.isEmpty) {
              return const custom.LoadingWidget(message: 'Chargement...');
            }
            
            final contents = _selectedType == 'all'
                ? educationProvider.contents
                : educationProvider.getContentByType(_selectedType);
            
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: BatteColors.purple,
                  title: const Text('Éducation'),
                ),
                
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Carte de progression
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [BatteColors.purple, Color(0xFF6B3FA0)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Votre progression',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: BatteColors.white,
                                  ),
                                ),
                                Text(
                                  '${educationProvider.progressPercentage.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: BatteColors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: educationProvider.progressPercentage / 100,
                              backgroundColor: BatteColors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                BatteColors.white,
                              ),
                              minHeight: 8,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.stars,
                                  color: BatteColors.secondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${educationProvider.totalPoints} points',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: BatteColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Filtres
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('Tout', 'all'),
                            const SizedBox(width: 8),
                            _buildFilterChip('🎥 Vidéos', 'video'),
                            const SizedBox(width: 8),
                            _buildFilterChip('🎧 Audio', 'audio'),
                            const SizedBox(width: 8),
                            _buildFilterChip('📝 Quiz', 'quiz'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Liste de contenu
                      if (contents.isEmpty)
                        const custom.EmptyWidget(
                          message: 'Aucun contenu disponible',
                          icon: Icons.school,
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
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: BatteColors.cardBackground,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image/Thumbnail
                                  Container(
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: BatteColors.purple.withOpacity(0.2),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        content.typeIcon,
                                        style: const TextStyle(fontSize: 48),
                                      ),
                                    ),
                                  ),
                                  
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                content.title,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            if (content.completed)
                                              const Icon(
                                                Icons.check_circle,
                                                color: BatteColors.success,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          content.description,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: BatteColors.mutedForeground,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.timer_outlined,
                                              size: 16,
                                              color: BatteColors.mutedForeground,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              content.formattedDuration,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: BatteColors.mutedForeground,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            const Icon(
                                              Icons.stars,
                                              size: 16,
                                              color: BatteColors.secondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${content.points} pts',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: BatteColors.secondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    ]),
                  ),
                ),
              ],
            );
          },
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
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? BatteColors.purple : BatteColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? BatteColors.purple : Colors.transparent,
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

