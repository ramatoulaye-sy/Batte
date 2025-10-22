import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

/// Carte de progression écologique gamifiée
class EcoProgressCard extends StatelessWidget {
  final int ecoScore;
  final VoidCallback? onTap;

  const EcoProgressCard({
    Key? key,
    required this.ecoScore,
    this.onTap,
  }) : super(key: key);

  /// Détermine le niveau en fonction du score
  Map<String, dynamic> _getLevelInfo() {
    if (ecoScore >= 1000) {
      return {
        'level': 'Légende',
        'emoji': '🏆',
        'color': const Color(0xFFFFD700),
        'nextLevel': 'Max',
        'current': ecoScore,
        'target': 1000,
        'progress': 1.0,
      };
    } else if (ecoScore >= 500) {
      return {
        'level': 'Or',
        'emoji': '🥇',
        'color': const Color(0xFFFFD700),
        'nextLevel': 'Légende',
        'current': ecoScore,
        'target': 1000,
        'progress': (ecoScore - 500) / 500,
      };
    } else if (ecoScore >= 200) {
      return {
        'level': 'Argent',
        'emoji': '🥈',
        'color': const Color(0xFFC0C0C0),
        'nextLevel': 'Or',
        'current': ecoScore,
        'target': 500,
        'progress': (ecoScore - 200) / 300,
      };
    } else if (ecoScore >= 100) {
      return {
        'level': 'Bronze',
        'emoji': '🥉',
        'color': const Color(0xFFCD7F32),
        'nextLevel': 'Argent',
        'current': ecoScore,
        'target': 200,
        'progress': (ecoScore - 100) / 100,
      };
    } else {
      return {
        'level': 'Débutant',
        'emoji': '🌱',
        'color': BatteColors.primary,
        'nextLevel': 'Bronze',
        'current': ecoScore,
        'target': 100,
        'progress': ecoScore / 100,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelInfo = _getLevelInfo();
    final progress = levelInfo['progress'] as double;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: BatteColors.ecoCardGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: BatteColors.lightGreen.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Niveau actuel',
                      style: TextStyle(
                        fontSize: 13,
                        color: BatteColors.foreground.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          levelInfo['emoji'],
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          levelInfo['level'],
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: BatteColors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Score badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
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
                    children: [
                      Text(
                        '$ecoScore',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: levelInfo['color'],
                        ),
                      ),
                      Text(
                        'pts',
                        style: TextStyle(
                          fontSize: 11,
                          color: BatteColors.foreground.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Barre de progression
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Prochain niveau: ${levelInfo['nextLevel']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: BatteColors.foreground.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${levelInfo['current']} / ${levelInfo['target']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: levelInfo['color'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      // Fond
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Progression
                      FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                levelInfo['color'],
                                levelInfo['color'].withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: levelInfo['color'].withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Message motivant
            if (progress < 1.0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: BatteColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getMotivationalMessage(progress),
                        style: const TextStyle(
                          fontSize: 11,
                          color: BatteColors.foreground,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getMotivationalMessage(double progress) {
    if (progress >= 0.75) {
      return 'Tu y es presque ! Continue comme ça ! 🔥';
    } else if (progress >= 0.5) {
      return 'Excellent progrès ! Garde le rythme ! 💪';
    } else if (progress >= 0.25) {
      return 'Bon début ! Chaque geste compte ! 🌍';
    } else {
      return 'Commence à recycler pour monter de niveau ! ♻️';
    }
  }
}

