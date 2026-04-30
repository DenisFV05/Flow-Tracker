import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habitsProvider.dart';

class QuickStats extends StatelessWidget {
  const QuickStats({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final stats = provider.dashboardStats;

    final totalHabits = stats['totalHabits'] ?? 0;
    final todayCompleted = stats['todayCompleted'] ?? 0;
    final todayTotal = stats['todayTotal'] ?? 0;
    final longestStreak = stats['longestStreak'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Habits totals rastrejats: ",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text("$totalHabits", style: const TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          const Text("Completats avui: ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              )),
          Text("$todayCompleted/$todayTotal",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              )),

          const SizedBox(height: 10),

          const Text("Aquesta setmana: ",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text("${(todayTotal == 0 ? 0 : ((todayCompleted / todayTotal) * 100).toStringAsFixed(0)}%",
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
}
