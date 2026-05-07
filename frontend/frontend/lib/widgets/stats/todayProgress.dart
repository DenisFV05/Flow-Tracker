import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class TodayProgress extends StatelessWidget {
  final List<dynamic> habits;
  final Map<String, dynamic> habitStats;

  const TodayProgress({
    super.key,
    required this.habits,
    required this.habitStats,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toIso8601String().split('T').first;
    final doneCount = habits.where((h) {
      final stats = habitStats[h['id']] as Map<String, dynamic>?;
      return stats?['lastCompletedDate'] == today;
    }).length;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progrés d\'avui',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '$doneCount/${habits.length}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (habits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Crea un hàbit per començar',
                style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              ),
            )
          else
            ...habits.map((habit) {
              final stats = habitStats[habit['id']] as Map<String, dynamic>?;
              final doneToday = stats?['lastCompletedDate'] == today;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: doneToday
                            ? AppTheme.successBg
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        doneToday
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 20,
                        color: doneToday ? AppTheme.success : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        habit['name'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: doneToday
                              ? AppTheme.textPrimary
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                    if (stats != null)
                      Text(
                        '${stats['currentStreak'] ?? 0} dies',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
