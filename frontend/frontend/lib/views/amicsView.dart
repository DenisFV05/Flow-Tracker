import 'package:flutter/material.dart';

import '../models/mockHabits.dart';
import '../widgets/habits/HabitCard.dart';
import '../widgets/stats/StatsGrid.dart';
import '../widgets/stats/quickStats.dart';
import '../widgets/SectionTitle.dart';
import 'package:provider/provider.dart';
import '../models/habitsProvider.dart';
import 'crearHabit.dart';
class AmicsView extends StatelessWidget {
  const AmicsView({super.key});

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitProvider>().habits;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Amics"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () {showCrearHabitPopup(context);},
              icon: const Icon(Icons.add),
              label: const Text("Afegir amic"),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;

                /// DESKTOP
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionTitle(title: "Els teus amics"),
                            const SizedBox(height: 10),

                            ...habits.map(
                              (habit) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: HabitCard(
                                  title: habit.title,
                                  subtitle: habit.subtitle,
                                  progress: habit.progress,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      const Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionTitle(title: "SOLICITUTS D'AMISTAT"),
                            SizedBox(height: 10),
                            QuickStats(),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                /// MOVIL
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(title: "Habits d'avui"),
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
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: CrearHabitForm(),
          ),
        ),
      );
    },
  );
}