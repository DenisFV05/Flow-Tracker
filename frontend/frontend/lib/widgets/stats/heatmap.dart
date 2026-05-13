import 'package:flutter/material.dart';
import 'dart:collection';
import '../../config/app_theme.dart';

class HabitHeatmap extends StatelessWidget {
  final List<dynamic> heatmapData;
  final int year;

  const HabitHeatmap({
    super.key,
    required this.heatmapData,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    final dataMap = HashMap<String, bool>.fromEntries(
      heatmapData.map((item) => MapEntry(item['date'] as String, item['completed'] as bool)),
    );

    return Container(
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
            'Heatmap $year',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.textPrimaryColor),
          ),
          SizedBox(height: 12),
          _buildHeatmap(context, dataMap),
          SizedBox(height: 12),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildHeatmap(BuildContext context, HashMap<String, bool> dataMap) {
    final weeks = <List<_DayData>>[];
    var currentWeek = <_DayData>[];

    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);

    // Padding for the first week to start on Monday
    final firstDayWeekday = startDate.weekday;
    for (int i = 1; i < firstDayWeekday; i++) {
      currentWeek.add(_DayData(date: startDate.subtract(Duration(days: firstDayWeekday - i)), completed: false, isPadding: true));
    }

    for (var date = startDate; date.isBefore(endDate) || date.isAtSameMomentAs(endDate); date = date.add(const Duration(days: 1))) {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final completed = dataMap[dateStr] ?? false;

      currentWeek.add(_DayData(date: date, completed: completed));

      if (date.weekday == DateTime.sunday) {
        weeks.add(currentWeek);
        currentWeek = <_DayData>[];
      }
    }

    if (currentWeek.isNotEmpty) {
      // Pad last week to 7 days
      while (currentWeek.length < 7) {
        currentWeek.add(_DayData(date: currentWeek.last.date.add(const Duration(days: 1)), completed: false, isPadding: true));
      }
      weeks.add(currentWeek);
    }

    final monthLabels = ['Gen', 'Feb', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Oct', 'Nov', 'Des'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day labels
        Column(
          children: [
            SizedBox(height: 20), // Top padding for month labels
            ...['Dl', '', 'Dc', '', 'Dv', '', 'Dg'].map((day) => Container(
              height: 18,
              alignment: Alignment.center,
              child: Text(day, style: TextStyle(fontSize: 10, color: context.textSecondaryColor)),
            )),
          ],
        ),
        SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month labels
                Row(
                  children: weeks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final week = entry.value;
                    final firstDay = week.firstWhere((d) => !d.isPadding, orElse: () => week.first);
                    
                    // Show month label if it's the first week of the month
                    bool showLabel = false;
                    if (index == 0) {
                      showLabel = true;
                    } else {
                      final prevWeek = weeks[index - 1];
                      final prevFirstDay = prevWeek.firstWhere((d) => !d.isPadding, orElse: () => prevWeek.first);
                      if (firstDay.date.month != prevFirstDay.date.month) {
                        showLabel = true;
                      }
                    }

                    return Container(
                      width: 18, // 14 + 4 margin
                      height: 20,
                      child: showLabel 
                        ? Text(monthLabels[firstDay.date.month - 1], style: TextStyle(fontSize: 10, color: context.textSecondaryColor))
                        : null,
                    );
                  }).toList(),
                ),
                // Heatmap grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: weeks.map((week) {
                    return Column(
                      children: week.map((day) {
                        return Container(
                          width: 14,
                          height: 14,
                          margin: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: day.isPadding 
                              ? Colors.transparent 
                              : (day.completed ? AppTheme.primary : Colors.grey[200]),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, color: AppTheme.primary, margin: EdgeInsets.only(right: 4)),
        Text('Completat', style: TextStyle(fontSize: 12, color: context.textSecondaryColor)),
        SizedBox(width: 16),
        Container(width: 14, height: 14, color: Colors.grey[200]!, margin: EdgeInsets.only(right: 4)),
        Text('No completat', style: TextStyle(fontSize: 12, color: context.textSecondaryColor)),
      ],
    );
  }
}

class _DayData {
  final DateTime date;
  final bool completed;
  final bool isPadding;

  _DayData({required this.date, required this.completed, this.isPadding = false});
}
