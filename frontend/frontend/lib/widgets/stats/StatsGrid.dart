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
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: "Habits",
            value: "$totalHabits",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            title: "Avui",
            value: "$todayCompleted/$totalToday",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            title: "Ritme",
            value: "${totalToday == 0 ? 0 : ((todayCompleted / totalToday) * 100).toStringAsFixed(0)}%",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatCard(
            title: "🔥 Streak",
            value: "$longestStreak",
          ),
        ),
      ],
    );
  }
}
