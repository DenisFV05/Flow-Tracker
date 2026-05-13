import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class HabitCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final int streak;
  final List<dynamic> tags;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool completedToday;
  final Function(bool)? onToggle;

  const HabitCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.streak,
    required this.tags,
    required this.color,
    this.completedToday = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: context.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                        Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                // Quick toggle button
                GestureDetector(
                  onTap: onToggle != null ? () => onToggle!(!completedToday) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: completedToday
                          ? AppTheme.success.withOpacity(0.12)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      completedToday
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 22,
                      color: completedToday ? AppTheme.success : Colors.grey[400],
                    ),
                  ),
                ),

                SizedBox(width: 4),

                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.more_horiz,
                    size: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 10),
                          Text("Edit"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Delete",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 4),

            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondaryColor,
              ),
            ),

            SizedBox(height: 12),

            if (tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  final name = tag is Map ? tag['name'] ?? '' : tag.toString();
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.surfaceLightColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      name,
                      style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              ),

            SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded, color: AppTheme.warning, size: 18),
                    SizedBox(width: 4),
                    Text(
                      '$streak',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.textPrimaryColor),
                    ),
                  ],
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                color: color,
                backgroundColor: color.withOpacity(0.12),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
