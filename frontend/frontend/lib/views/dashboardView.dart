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

    // Cargar datos al abrir pantalla
    Future.microtask(() {
      context.read<HabitProvider>().loadHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final habits = provider.habits;
    final loading = provider.loading;

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
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StatsGrid(),
                  const SizedBox(height: 20),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 700;

                      // 🖥️ DESKTOP
                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // HABITS
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SectionTitle(title: "Habits d'avui"),
                                  const SizedBox(height: 10),

                                  ...habits.map((habit) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: HabitCard(
                                        title: habit['name'],
                                        subtitle: habit['description'],
                                        progress: 0.5,
                                        color: Colors.orange,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => HabitDetailView(habit: habit),
                                            ),
                                          );
                                        },
                                      )

                                    );
                                  }),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            // STATS
                            const Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SectionTitle(title: "Resum d'stats"),
                                  SizedBox(height: 10),
                                  QuickStats(),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      // 📱 MOBILE
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle(title: "Habits d'avui"),
                          const SizedBox(height: 10),

                          ...habits.map((habit) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: HabitCard(
                                title: habit['name'] ?? '',
                                subtitle: habit['description'] ?? '',
                                progress: 0.5,
                                color: Colors.orange,
                              ),
                            );
                          }),

                          const SizedBox(height: 20),

                          const SectionTitle(title: "Resum d'stats"),
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

/// Popup creación hábito
void showCrearHabitPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: CrearHabitForm(),
          ),
        ),
      );
    },
  );
}
