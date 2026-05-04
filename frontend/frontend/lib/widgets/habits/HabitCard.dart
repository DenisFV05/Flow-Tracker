import 'package:flutter/material.dart';

class HabitCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final int streak;
  final List<dynamic> tags;
  final Color color;
  final VoidCallback? onTap;

  const HabitCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.streak,
    required this.tags,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A2332),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF546E7A),
              ),
            ),

            const SizedBox(height: 12),

            if (tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  final name = tag is Map ? tag['name'] ?? '' : tag.toString();
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      name,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF1E88E5), fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF9800), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$streak',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A2332)),
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

            const SizedBox(height: 10),

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
