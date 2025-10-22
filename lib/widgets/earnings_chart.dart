import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/utils/helpers.dart';

/// Widget de graphique pour afficher l'évolution des gains
class EarningsChart extends StatelessWidget {
  final List<double> weeklyEarnings;
  
  const EarningsChart({
    Key? key,
    required this.weeklyEarnings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BatteColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gains cette semaine',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: BatteColors.foreground,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: BatteColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${Helpers.formatCurrency(_getTotalEarnings())}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: BatteColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxEarning() > 0 ? _getMaxEarning() / 4 : 1000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: BatteColors.mutedForeground.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[value.toInt()],
                              style: const TextStyle(
                                color: BatteColors.mutedForeground,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: _getMaxEarning() > 0 ? _getMaxEarning() / 3 : 1000,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('');
                        return Text(
                          '${(value / 1000).toStringAsFixed(0)}k',
                          style: const TextStyle(
                            color: BatteColors.mutedForeground,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: _getMaxEarning() > 0 ? _getMaxEarning() * 1.2 : 10000,
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateSpots(),
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [BatteColors.primary, BatteColors.secondary],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: BatteColors.white,
                          strokeWidth: 2,
                          strokeColor: BatteColors.primary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          BatteColors.primary.withOpacity(0.3),
                          BatteColors.primary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: BatteColors.foreground,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        return LineTooltipItem(
                          Helpers.formatCurrency(touchedSpot.y),
                          const TextStyle(
                            color: BatteColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    final spots = <FlSpot>[];
    for (int i = 0; i < weeklyEarnings.length && i < 7; i++) {
      spots.add(FlSpot(i.toDouble(), weeklyEarnings[i]));
    }
    // Remplir avec des zéros si moins de 7 jours
    while (spots.length < 7) {
      spots.add(FlSpot(spots.length.toDouble(), 0));
    }
    return spots;
  }

  double _getMaxEarning() {
    if (weeklyEarnings.isEmpty) return 0;
    return weeklyEarnings.reduce((a, b) => a > b ? a : b);
  }

  double _getTotalEarnings() {
    if (weeklyEarnings.isEmpty) return 0;
    return weeklyEarnings.reduce((a, b) => a + b);
  }
}

