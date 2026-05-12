import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class TodayProgress extends StatelessWidget {
  final List<dynamic> habits;
  final Map<String, dynamic> habitStats;
  final List<dynamic>? todayCompletedHabitIds;

  const TodayProgress({
    super.key,
    required this.habits,
    required this.habitStats,
    this.todayCompletedHabitIds,
    this.onToggle,
  });

  final Function(String habitId, bool completed)? onToggle;

  @override
  Widget build(BuildContext context) {
    final doneCount = habits.where((h) {
      final id = h['id']?.toString();
      if (todayCompletedHabitIds != null) {
        return todayCompletedHabitIds!.contains(id) || todayCompletedHabitIds!.contains(h['id']);
      }
      final stats = habitStats[h['id']] as Map<String, dynamic>?;
      return stats?['completedToday'] == true;
    }).length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progrés d\'avui',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimaryColor,
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
          SizedBox(height: 14),
          if (habits.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Crea un hàbit per començar',
                style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              ),
            )
          else
            ...habits.map((habit) {
              final id = habit['id']?.toString();
              final stats = habitStats[habit['id']] as Map<String, dynamic>?;
              bool doneToday;
              if (todayCompletedHabitIds != null) {
                doneToday = todayCompletedHabitIds!.contains(id) || todayCompletedHabitIds!.contains(habit['id']);
              } else {
                doneToday = stats?['completedToday'] == true;
              }
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: onToggle != null
                      ? () => onToggle!(habit['id'].toString(), !doneToday)
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.all(4),
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
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            habit['name'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: doneToday
                                  ? context.textPrimaryColor
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
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
