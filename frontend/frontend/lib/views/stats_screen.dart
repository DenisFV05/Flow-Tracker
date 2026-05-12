import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../config/app_theme.dart';
//import '../models/habitsProvider.dart';
import '../providers/habitProvider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final loading = provider.loading;
    final habits = provider.habits;
    final habitStats = provider.habitStats;
    final dashboardStats = provider.dashboardStats;

    if (loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    final overallRate = dashboardStats['overallCompletionRate'] ?? 0;
    final totalHabits = dashboardStats['totalHabits'] ?? 0;
    final longestStreak = dashboardStats['longestStreak'] ?? 0;
    final completedLogs = dashboardStats['completedLogs'] ?? 0;

    return Container(
      color: AppTheme.background,
      child: habits.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.analytics_outlined, size: 48, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hi ha dades encara',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crea hàbits i marca\'ls per veure estadístiques',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estadístiques',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          'Percentatge global',
                          '${overallRate.toStringAsFixed(1)}%',
                          Icons.percent_rounded,
                          AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          'Hàbits totals',
                          '$totalHabits',
                          Icons.track_changes_rounded,
                          AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          'Ratxa màxima',
                          '$longestStreak dies',
                          Icons.local_fire_department_rounded,
                          AppTheme.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          'Dies completats',
                          '$completedLogs',
                          Icons.check_circle_rounded,
                          AppTheme.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Progrés per hàbit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...habits.map((habit) {
                    final stats = habitStats[habit['id']] as Map<String, dynamic>? ?? {};
                    final rate = stats['completionRate'] ?? 0.0;
                    final streak = stats['currentStreak'] ?? 0;
                    final completed = stats['completedDays'] ?? 0;
                    final total = stats['totalDays'] ?? 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if ((habit['description'] ?? '').isNotEmpty)
                            Text(
                              habit['description'],
                              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                            ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$rate% completat',
                                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: rate / 100,
                                        minHeight: 8,
                                        backgroundColor: AppTheme.primary.withOpacity(0.12),
                                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                children: [
                                  Text(
                                    '$completed/$total',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const Text(
                                    'dies',
                                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Column(
                                children: [
                                  const Icon(
                                    Icons.local_fire_department_rounded,
                                    color: AppTheme.warning,
                                    size: 20,
                                  ),
                                  Text(
                                    '$streak',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const Text(
                                    'ratxa',
                                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 28),

                  const Text(
                    'Comparativa de ratxes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 250,
                    child: _buildStreaksBarChart(habits, habitStats),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreaksBarChart(List<dynamic> habits, Map<String, dynamic> habitStats) {
    if (habits.isEmpty) {
      return const Center(child: Text('No hi ha dades'));
    }

    final spots = <FlSpot>[];
    final labels = <int, String>{};

    for (int i = 0; i < habits.length; i++) {
      final habit = habits[i];
      final stats = habitStats[habit['id']] as Map<String, dynamic>? ?? {};
      final streak = stats['currentStreak'] ?? 0;
      spots.add(FlSpot(i.toDouble(), streak.toDouble()));
      final name = habit['name'] ?? '';
      labels[i] = name.length > 6 ? '${name.substring(0, 6)}...' : name;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 1).toDouble(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${habits[group.x.toInt()]['name']}\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: '${rod.toY.toInt()} dies',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
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
                final index = value.toInt();
                if (labels.containsKey(index)) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      labels[index]!,
                      style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
                      textAlign: TextAlign.center,
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
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('0', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary));
                return Text('${value.toInt()}', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.primary.withOpacity(0.08),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: spots.map((spot) {
          return BarChartGroupData(
            x: spot.x.toInt(),
            barRods: [
              BarChartRodData(
                toY: spot.y,
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
