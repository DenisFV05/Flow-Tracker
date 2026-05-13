import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../config/app_theme.dart';
import '../providers/habitProvider.dart';
import '../widgets/stats/heatmap.dart';

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
      return Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    final overallRate = dashboardStats['overallCompletionRate'] ?? 0;
    final totalHabits = dashboardStats['totalHabits'] ?? 0;
    final longestStreak = dashboardStats['longestStreak'] ?? 0;
    final completedLogs = dashboardStats['completedLogs'] ?? 0;

    return Container(
      color: context.backgroundColor,
      child: habits.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.surfaceLightColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.analytics_outlined, size: 48, color: AppTheme.primary),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hi ha dades encara',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Crea hàbits i marca\'ls per veure estadístiques',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estadístiques',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 20),
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
                      SizedBox(width: 12),
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
                  SizedBox(height: 12),
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
                      SizedBox(width: 12),
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

                  SizedBox(height: 28),

                  Text(
                    'Progrés per hàbit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 16),

                  ...habits.map((habit) {
                    final stats = habitStats[habit['id'].toString()] as Map<String, dynamic>? ?? {};
                    final rate = stats['completionRate'] ?? 0.0;
                    final streak = stats['currentStreak'] ?? 0;
                    final completed = stats['completedDays'] ?? 0;
                    final total = stats['totalDays'] ?? 0;

                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color ?? Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.06),
                            blurRadius: 12,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit['name'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimaryColor,
                            ),
                          ),
                          if ((habit['description'] ?? '').isNotEmpty)
                            Text(
                              habit['description'],
                              style: TextStyle(fontSize: 13, color: context.textSecondaryColor),
                            ),
                          SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$rate% completat',
                                      style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimaryColor),
                                    ),
                                    SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: rate / 100,
                                        minHeight: 8,
                                        backgroundColor: AppTheme.primary.withOpacity(0.12),
                                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Column(
                                children: [
                                  Text(
                                    '$completed/$total',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimaryColor,
                                    ),
                                  ),
                                  Text(
                                    'dies',
                                    style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                                  ),
                                ],
                              ),
                              SizedBox(width: 16),
                              Column(
                                children: [
                                  Icon(
                                    Icons.local_fire_department_rounded,
                                    color: AppTheme.warning,
                                    size: 20,
                                  ),
                                  Text(
                                    '$streak',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimaryColor,
                                    ),
                                  ),
                                  Text(
                                    'ratxa',
                                    style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (provider.habitHeatmaps[habit['id'].toString()] != null) ...[
                            SizedBox(height: 16),
                            HabitHeatmap(
                              heatmapData: provider.habitHeatmaps[habit['id'].toString()]!,
                              year: DateTime.now().year,
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  SizedBox(height: 28),

                  Text(
                    'Comparativa de ratxes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 16),

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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: context.textPrimaryColor,
            ),
          ),
          SizedBox(height: 2),
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
      return Center(child: Text('No hi ha dades'));
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
                TextStyle(color: context.surfaceColor, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: '${rod.toY.toInt()} dies',
                    style: TextStyle(color: context.surfaceColor, fontSize: 12),
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
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      labels[index]!,
                      style: TextStyle(fontSize: 9, color: context.textSecondaryColor),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value == 0) return Text('0', style: TextStyle(fontSize: 10, color: context.textSecondaryColor));
                return Text('${value.toInt()}', style: TextStyle(fontSize: 10, color: context.textSecondaryColor));
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
