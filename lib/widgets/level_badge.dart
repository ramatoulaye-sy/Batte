import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

/// Widget affichant le niveau et badge de l'utilisateur
class LevelBadge extends StatelessWidget {
  final int ecoScore;
  
  const LevelBadge({
    Key? key,
    required this.ecoScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final levelData = _getLevelData();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            levelData['color']! as Color,
            (levelData['color']! as Color).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (levelData['color']! as Color).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BatteColors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  levelData['badge']! as String,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
              const SizedBox(width: 16),
              // Info niveau
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Niveau ${levelData['level']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: BatteColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      levelData['name']! as String,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: BatteColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Score actuel
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Score',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: BatteColors.white,
                    ),
                  ),
                  Text(
                    '$ecoScore',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: BatteColors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Barre de progression vers le prochain niveau
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Prochain niveau: ${levelData['nextName']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: BatteColors.white,
                    ),
                  ),
                  Text(
                    '$ecoScore / ${levelData['nextThreshold']} pts',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: BatteColors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _getProgress(),
                  minHeight: 10,
                  backgroundColor: BatteColors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(BatteColors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getLevelData() {
    // Niveaux avec seuils de points
    final levels = [
      {'threshold': 0, 'level': 1, 'name': 'Débutant', 'badge': '🌱', 'color': BatteColors.chart1},
      {'threshold': 100, 'level': 2, 'name': 'Bronze', 'badge': '🥉', 'color': const Color(0xFFCD7F32)},
      {'threshold': 500, 'level': 3, 'name': 'Silver', 'badge': '🥈', 'color': const Color(0xFFC0C0C0)},
      {'threshold': 1000, 'level': 4, 'name': 'Gold', 'badge': '🥇', 'color': const Color(0xFFFFD700)},
      {'threshold': 2000, 'level': 5, 'name': 'Platinum', 'badge': '💎', 'color': const Color(0xFFE5E4E2)},
      {'threshold': 5000, 'level': 6, 'name': 'Diamant', 'badge': '💠', 'color': BatteColors.primary},
      {'threshold': 10000, 'level': 7, 'name': 'Champion', 'badge': '👑', 'color': BatteColors.purple},
    ];

    // Trouver le niveau actuel
    Map<String, dynamic>? currentLevel;
    Map<String, dynamic>? nextLevel;

    for (int i = 0; i < levels.length; i++) {
      final threshold = levels[i]['threshold'] as int;
      if (ecoScore >= threshold) {
        currentLevel = levels[i];
        if (i + 1 < levels.length) {
          nextLevel = levels[i + 1];
        }
      } else {
        break;
      }
    }

    currentLevel ??= levels[0];
    nextLevel ??= currentLevel;

    return {
      'level': currentLevel['level'],
      'name': currentLevel['name'],
      'badge': currentLevel['badge'],
      'color': currentLevel['color'],
      'threshold': currentLevel['threshold'],
      'nextName': nextLevel['name'],
      'nextThreshold': nextLevel['threshold'],
    };
  }

  double _getProgress() {
    final levelData = _getLevelData();
    final currentThreshold = (levelData['threshold'] as num).toInt();
    final nextThreshold = (levelData['nextThreshold'] as num).toInt();

    if (nextThreshold == currentThreshold) return 1.0;

    final progress = (ecoScore - currentThreshold) / (nextThreshold - currentThreshold);
    return progress.clamp(0.0, 1.0);
  }
}

