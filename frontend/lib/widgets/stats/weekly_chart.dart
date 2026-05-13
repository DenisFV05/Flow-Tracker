import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_theme.dart';

class WeeklyChart extends StatelessWidget {
  final List<dynamic> days;

  const WeeklyChart({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
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
            'Aquesta setmana',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.textPrimaryColor),
          ),
          SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < days.length) {
                          final date = DateTime.parse(days[index]['date']);
                          return Text(
                            ['Dl', 'Dt', 'Dc', 'Dj', 'Dv', 'Ds', 'Dg'][date.weekday - 1],
                            style: TextStyle(fontSize: 10, color: context.textSecondaryColor),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: days.asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: day['completed'] ? 1.0 : 0.0,
                        gradient: day['completed']
                            ? const LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primaryDark],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              )
                            : null,
                        color: day['completed'] ? null : Colors.grey[300],
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MonthlyChart extends StatelessWidget {
  final List<dynamic> days;

  const MonthlyChart({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
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
            'Aquest mes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.textPrimaryColor),
          ),
          SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < days.length && index % 5 == 0) {
                          final date = DateTime.parse(days[index]['date']);
                          return Text(
                            '${date.day}',
                            style: TextStyle(fontSize: 10, color: context.textSecondaryColor),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: days.asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: day['completed'] ? 1.0 : 0.0,
                        color: day['completed'] ? AppTheme.primary : Colors.grey[300],
                        width: 8,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
