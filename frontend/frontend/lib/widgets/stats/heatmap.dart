import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:collection';

class HabitHeatmap extends StatelessWidget {
  final List<dynamic> heatmapData; // List of {date: 'YYYY-MM-DD', completed: bool}
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Heatmap $year',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildHeatmap(dataMap),
          const SizedBox(height: 12),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeatmap(HashMap<String, bool> dataMap) {
    // Group data by week
    final weeks = <List<_DayData>>[];
    var currentWeek = <_DayData>[];

    // Start from January 1st
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
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: day.completed
                      ? Colors.green
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        Container(width: 14, height: 14, color: Colors.green, margin: const EdgeInsets.only(right: 4)),
        const Text('Completed', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 16),
        Container(width: 14, height: 14, color: Colors.grey[200]!, margin: const EdgeInsets.only(right: 4)),
        const Text('No data', style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _DayData {
  final DateTime date;
  final bool completed;

  _DayData({required this.date, required this.completed});
}
