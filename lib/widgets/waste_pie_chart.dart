import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

/// Widget de graphique circulaire pour les types de déchets
class WastePieChart extends StatelessWidget {
  final Map<String, double> wasteData; // {type: weight}
  
  const WastePieChart({
    Key? key,
    required this.wasteData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (wasteData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: BatteColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 64,
                color: BatteColors.mutedForeground,
              ),
              SizedBox(height: 16),
              Text(
                'Aucune donnée disponible',
                style: TextStyle(
                  fontSize: 14,
                  color: BatteColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BatteColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Types de déchets recyclés',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: BatteColors.foreground,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Graphique circulaire
              Expanded(
                flex: 3,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _generateSections(),
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Légende
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: _buildLegend(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generateSections() {
    final total = wasteData.values.fold(0.0, (sum, value) => sum + value);
    final colors = [
      BatteColors.primary,
      BatteColors.secondary,
      BatteColors.chart1,
      BatteColors.chart2,
      BatteColors.purple,
    ];

    final List<PieChartSectionData> sections = [];
    int colorIndex = 0;

    wasteData.forEach((type, weight) {
      final percentage = (weight / total * 100).toStringAsFixed(1);
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: weight,
          title: '$percentage%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: BatteColors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return sections;
  }

  List<Widget> _buildLegend() {
    final colors = [
      BatteColors.primary,
      BatteColors.secondary,
      BatteColors.chart1,
      BatteColors.chart2,
      BatteColors.purple,
    ];

    final List<Widget> legend = [];
    int colorIndex = 0;

    // Map des icônes par type de déchet
    final typeIcons = {
      'plastic': '🥤',
      'paper': '📄',
      'metal': '🥫',
      'glass': '🍾',
      'organic': '🍎',
      'electronic': '📱',
    };

    wasteData.forEach((type, weight) {
      final icon = typeIcons[type.toLowerCase()] ?? '♻️';
      final typeName = _getTypeName(type);
      
      legend.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors[colorIndex % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                icon,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  typeName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: BatteColors.foreground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
      colorIndex++;
    });

    return legend;
  }

  String _getTypeName(String type) {
    final names = {
      'plastic': 'Plastique',
      'paper': 'Papier',
      'metal': 'Métal',
      'glass': 'Verre',
      'organic': 'Organique',
      'electronic': 'Électronique',
    };
    return names[type.toLowerCase()] ?? type;
  }
}

