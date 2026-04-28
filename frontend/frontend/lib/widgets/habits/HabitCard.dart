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
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black12,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TÍTULO
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            /// DESCRIPCIÓN
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 12),

            /// TAGS
            if (tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  return Chip(
                    label: Text(
                      tag['name'] ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),

            const SizedBox(height: 12),

            /// STREAK + %
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "🔥 $streak días",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "$percentage%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// PROGRESS BAR
            LinearProgressIndicator(
              value: progress,
              color: color,
              backgroundColor: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }
}
