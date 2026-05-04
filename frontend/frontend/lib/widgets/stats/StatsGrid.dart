import 'package:flutter/material.dart';
import 'StatCard.dart';

class StatsGrid extends StatelessWidget {
  final int totalHabits;
  final int todayCompleted;
  final int totalToday;
  final int longestStreak;

  const StatsGrid({
    super.key,
    required this.totalHabits,
    required this.todayCompleted,
    required this.totalToday,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final rate = totalToday == 0 ? 0 : ((todayCompleted / totalToday) * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.track_changes_rounded,
              title: "Hàbits",
              value: "$totalHabits",
              color: const Color(0xFF1E88E5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              icon: Icons.today_rounded,
              title: "Avui",
              value: "$todayCompleted/$totalToday",
              color: const Color(0xFF43A047),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              icon: Icons.speed_rounded,
              title: "Ritme",
              value: "$rate%",
              color: const Color(0xFFAB47BC),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              icon: Icons.local_fire_department_rounded,
              title: "Ratxa",
              value: "$longestStreak",
              color: const Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }
}
