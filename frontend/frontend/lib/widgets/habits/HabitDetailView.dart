import 'package:flowTracker/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/habitProvider.dart';

class HabitDetailView extends StatefulWidget {
  final dynamic habit;

  const HabitDetailView({
    super.key,
    required this.habit,
  });

  @override
  State<HabitDetailView> createState() => _HabitDetailViewState();
}

class _HabitDetailViewState extends State<HabitDetailView> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;

    final stats =
        context.watch<HabitProvider>().habitStats[habit['id']] ?? {};

    final progress =
        ((stats['completionRate'] ?? 0) / 100).toDouble();

    final streak = stats['currentStreak'] ?? 0;

    final tags = habit['tags'] ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        title: const Text(
          "Detalls de l'hàbit",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.primary,
                    AppTheme.primaryDarker,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// ICON
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.track_changes_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// NAME
                  Text(
                    habit['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// DESCRIPTION
                  Text(
                    habit['description'] ?? 'Sense descripció',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// STREAK
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Racha actual",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),

                          Text(
                            "$streak dies",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// PROGRESS CARD
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: const [
                      Icon(
                        Icons.bar_chart_rounded,
                        color: AppTheme.primary,
                      ),

                      SizedBox(width: 10),

                      Text(
                        "Progrés",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 14,
                      color: AppTheme.primary,
                      backgroundColor:
                          AppTheme.primary.withOpacity(0.12),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${(progress * 100).toInt()}%",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// TAGS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: const [
                      Icon(
                        Icons.sell_rounded,
                        color: AppTheme.primary,
                      ),

                      SizedBox(width: 10),

                      Text(
                        "Tags",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: tags.isNotEmpty
                        ? tags.map<Widget>((tag) {
                            final name = tag is Map
                                ? tag['name']
                                : tag.toString();

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.primary.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: Text(
                                name,
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList()
                        : [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: const Text("Sense tags"),
                            ),
                          ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            /// BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,

              child: ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        setState(() => loading = true);

                        try {
                          await context
                              .read<HabitProvider>()
                              .toggleHabit(
                                habit['id'],
                                true,
                              );

                          await context
                              .read<HabitProvider>()
                              .loadDashboard();

                          if (mounted) Navigator.pop(context);

                        } catch (e) {

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Error actualitzant hàbit"),
                            ),
                          );

                        } finally {
                          setState(() => loading = false);
                        }
                      },

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Marcar com feta",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}