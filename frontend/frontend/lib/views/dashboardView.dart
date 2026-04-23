import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habitsProvider.dart';
import '../widgets/habits/HabitCard.dart';
import '../widgets/stats/StatsGrid.dart';
import '../widgets/stats/quickStats.dart';
import '../widgets/SectionTitle.dart';

class DashboardView extends StatelessWidget {
  final String serverUrl;

  const DashboardView({super.key, required this.serverUrl});

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitProvider>().habits;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text("Add Habit"),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StatsGrid(),
            const SizedBox(height: 20),

            /// ---------- RESPONSIVE SECTION ----------
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;

                /// ================= DESKTOP / TABLET =================
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// LEFT - HABITS
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionTitle(title: "Today's Habits"),
                            const SizedBox(height: 10),

                            ...habits.map(
                              (habit) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: HabitCard(
                                  title: habit.title,
                                  subtitle: habit.subtitle,
                                  progress: habit.progress,
                                  color: habit.completedToday
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      /// RIGHT - QUICK STATS
                      const Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionTitle(title: "Quick Stats"),
                            SizedBox(height: 10),
                            QuickStats(),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                /// ================= MOBILE =================
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(title: "Today's Habits"),
                    const SizedBox(height: 10),

                    ...habits.map(
                      (habit) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HabitCard(
                          title: habit.title,
                          subtitle: habit.subtitle,
                          progress: habit.progress,
                          color: habit.completedToday
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const SectionTitle(title: "Quick Stats"),
                    const SizedBox(height: 10),
                    const QuickStats(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
