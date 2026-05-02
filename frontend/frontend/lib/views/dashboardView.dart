import 'package:flowTracker/services/habits_service.dart';
import 'package:flowTracker/widgets/habits/HabitDetailView.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/habits/HabitCard.dart';
import '../widgets/stats/StatsGrid.dart';
import '../widgets/stats/quickStats.dart';
import '../widgets/SectionTitle.dart';

import '../models/habitsProvider.dart';
import 'crearHabit.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();

    final habits = provider.habits;
    final loading = provider.loading;

    final dashboardStats = provider.dashboardStats;
    final habitStats = provider.habitStats;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => showCrearHabitPopup(context),
              icon: const Icon(Icons.add),
              label: const Text("Afegir habit"),
            ),
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// =========================
                  /// 📊 STATS GLOBALES
                  /// =========================
                  StatsGrid(
                    totalHabits: dashboardStats['totalHabits'] ?? 0,
                    todayCompleted: dashboardStats['todayCompleted'] ?? 0,
                    totalToday: dashboardStats['todayTotal'] ?? 0,
                    longestStreak: dashboardStats['longestStreak'] ?? 0,
                  ),

                  const SizedBox(height: 20),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 700;

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// =========================
                            /// 🧠 HABITS
                            /// =========================
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SectionTitle(title: "Habits d'avui"),
                                  const SizedBox(height: 10),

                                  if (habits.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Text(
                                        "Encara no tens hàbits 👀",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),

                                  ...habits.map((habit) {
                                    final stats =
                                        habitStats[habit['id']] as Map<String, dynamic>? ?? {};

                                    final progress =
                                        ((stats['completionRate'] ?? 0) / 100)
                                            .toDouble();

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: HabitCard(
                                        title: habit['name'] ?? '',
                                        subtitle: habit['description'] ?? '',
                                        progress: progress,
                                        streak: stats['currentStreak'] ?? 0,
                                        tags: habit['tags'] ?? [],
                                        color: Colors.orange,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  HabitDetailView(habit: habit),
                                            ),
                                          );
                                        },
                                          onDelete: () async {
                                            final id = habit['id'].toString();

                                            await context.read<HabitProvider>().deleteHabit(id);
                                          }

                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            /// =========================
                            /// ⚡ QUICK STATS
                            /// =========================
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SectionTitle(title: "Resum"),
                                  SizedBox(height: 10),
                                  QuickStats(),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      /// =========================
                      /// 📱 MOBILE
                      /// =========================
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionTitle(title: "Habits d'avui"),
                          const SizedBox(height: 10),

                          if (habits.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                "Encara no tens hàbits 👀",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),

                          ...habits.map((habit) {
                            final stats =
                                habitStats[habit['id']] as Map<String, dynamic>? ?? {};

                            final progress =
                                ((stats['completionRate'] ?? 0) / 100)
                                    .toDouble();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: HabitCard(
                                title: habit['name'] ?? '',
                                subtitle: habit['description'] ?? '',
                                progress: progress,
                                streak: stats['currentStreak'] ?? 0,
                                tags: habit['tags'] ?? [],
                                color: Colors.orange,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          HabitDetailView(habit: habit),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),

                          const SizedBox(height: 20),

                          SectionTitle(title: "Resum"),
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

/// =========================
/// ➕ POPUP CREAR HABIT
/// =========================
void showCrearHabitPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: CrearHabitForm(),
        ),
      );
    },
  );
}
