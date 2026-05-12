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
          _buildHeatmap(dataMap),
          SizedBox(height: 12),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildHeatmap(HashMap<String, bool> dataMap) {
    final weeks = <List<_DayData>>[];
    var currentWeek = <_DayData>[];

    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);

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
      weeks.add(currentWeek);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: weeks.map((week) {
          return Column(
            children: week.map((day) {
              return Container(
                width: 14,
                height: 14,
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: day.completed ? AppTheme.primary : Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
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

  _DayData({required this.date, required this.completed});
}
