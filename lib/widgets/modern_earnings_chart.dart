import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/constants/colors.dart';
import '../core/utils/helpers.dart';

/// Graphique moderne des gains hebdomadaires avec animations
class ModernEarningsChart extends StatefulWidget {
  final List<double> weeklyEarnings;

  const ModernEarningsChart({
    Key? key,
    required this.weeklyEarnings,
  }) : super(key: key);

  @override
  State<ModernEarningsChart> createState() => _ModernEarningsChartState();
}

class _ModernEarningsChartState extends State<ModernEarningsChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalWeekly = widget.weeklyEarnings.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    final maxValue = widget.weeklyEarnings.isEmpty
        ? 10000.0
        : widget.weeklyEarnings.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
                    'Gains cette semaine',
                    style: TextStyle(
                      fontSize: 14,
                      color: BatteColors.foreground.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
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
                          color: totalWeekly > 0
                              ? BatteColors.success.withOpacity(0.1)
                              : BatteColors.mutedForeground.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              totalWeekly > 0
                                  ? Icons.trending_up
                                  : Icons.trending_flat,
                              size: 14,
                              color: totalWeekly > 0
                                  ? BatteColors.success
                                  : BatteColors.mutedForeground,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              totalWeekly > 0 ? '+${Helpers.formatCurrency(totalWeekly)}' : '0 GNF',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: totalWeekly > 0
                                    ? BatteColors.success
                                    : BatteColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Légende
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: BatteColors.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: BatteColors.goldGradient,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Gains',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: BatteColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Graphique
          SizedBox(
            height: 180,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxValue > 0 ? maxValue * 1.2 : 10000,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: BatteColors.foreground,
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            Helpers.formatCurrency(rod.toY),
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                            if (value.toInt() >= 0 && value.toInt() < days.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  days[value.toInt()],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: BatteColors.foreground.withOpacity(0.6),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxValue > 0 ? maxValue / 4 : 2500,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: BatteColors.muted.withOpacity(0.5),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                      widget.weeklyEarnings.length,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: widget.weeklyEarnings[index] * _animation.value,
                            gradient: BatteColors.goldGradient,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: maxValue > 0 ? maxValue * 1.2 : 10000,
                              color: BatteColors.softGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 800),
                  swapAnimationCurve: Curves.easeInOutCubic,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

