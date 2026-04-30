import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/habitsProvider.dart';
import 'StatCard.dart';

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
    final rate = todayTotal == 0 ? 0 : ((todayCompleted / todayTotal) * 100).toDouble();

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
          const Text("Resum",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          StatCard(
            title: "Habits",
            value: "$totalHabits",
          ),
          const SizedBox(height: 8),
          StatCard(
            title: "Avui",
            value: "$todayCompleted/$todayTotal",
          ),
          const SizedBox(height: 8),
          StatCard(
            title: "Ritme",
            value: "${rate.toStringAsFixed(0)}%",
          ),
          const SizedBox(height: 8),
          StatCard(
            title: "🔥 Streak",
            value: "$longestStreak",
          ),
        ],
      ),
    );
  }
}

