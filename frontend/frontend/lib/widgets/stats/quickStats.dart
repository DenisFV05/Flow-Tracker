import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            "Resum",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          StatCard(
            icon: Icons.track_changes_rounded,
            title: "Hàbits",
            value: "$totalHabits",
            color: AppTheme.primary,
          ),
          const SizedBox(height: 12),
          StatCard(
            icon: Icons.today_rounded,
            title: "Avui",
            value: "$todayCompleted/$todayTotal",
            color: AppTheme.success,
          ),
          const SizedBox(height: 12),
          StatCard(
            icon: Icons.speed_rounded,
            title: "Ritme",
            value: "${rate.toStringAsFixed(0)}%",
            color: AppTheme.purple,
          ),
          const SizedBox(height: 12),
          StatCard(
            icon: Icons.local_fire_department_rounded,
            title: "Ratxa",
            value: "$longestStreak",
            color: AppTheme.warning,
          ),
        ],
      ),
    );
  }
}
