import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habitsProvider.dart';

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
      appBar: AppBar(
        title: Text(habit['name'] ?? 'Detalls hàbit'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// NAME
            Text(
              habit['name'] ?? '',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              habit['description'] ?? 'Sense descripció',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            /// STREAK
            Row(
              children: [
                const Icon(Icons.local_fire_department,
                    color: Colors.orange),
                const SizedBox(width: 6),
                Text(
                  "Racha: $streak dies",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),
            /// PROGRESS
            const Text(
              "Progrés",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              color: Colors.orange,
              backgroundColor: Colors.orange.withOpacity(0.2),
            ),

            const SizedBox(height: 30),

            /// TAGS
            const Text(
              "Tags",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              children: tags.isNotEmpty
                  ? tags.map<Widget>((tag) {
                      final name = tag is Map
                          ? tag['name']
                          : tag.toString();

                      return Chip(label: Text(name));
                    }).toList()
                  : [const Chip(label: Text("Sense tags"))],
            ),

            const SizedBox(height: 30),

            /// ======================
            /// BUTTON
            /// ======================
            SizedBox(
              width: double.infinity,
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

                          await context.read<HabitProvider>().loadDashboard();

                          if (mounted) Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Error actualitzant hàbit"),
                            ),
                          );
                        } finally {
                          setState(() => loading = false);
                        }
                      },
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Marcar com feta"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
