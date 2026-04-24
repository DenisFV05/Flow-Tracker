import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habitsProvider.dart';
import '../widgets/habits/HabitCard.dart';
import '../widgets/stats/StatsGrid.dart';
import '../widgets/SectionTitle.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final habits = habitProvider.habits;
    final loading = habitProvider.loading;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Avui"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => _showAddHabitDialog(context, habitProvider),
              icon: const Icon(Icons.add),
              label: const Text("Afegir"),
            ),
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : habits.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text("No tens hàbits encara"),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddHabitDialog(context, habitProvider),
                        icon: const Icon(Icons.add),
                        label: const Text("Crear hàbit"),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => habitProvider.loadHabits(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: habits.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatsGrid(),
                            SizedBox(height: 16),
                            SectionTitle(title: "Hàbits"),
                            SizedBox(height: 8),
                          ],
                        );
                      }
                      final habit = habits[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HabitCard(
                          title: habit.name,
                          subtitle: habit.description ?? '',
                          progress: 0.0,
                          color: habit.completedToday ? Colors.green : Colors.orange,
                          onTap: () => _toggleHabit(context, habitProvider, habit.id),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _showAddHabitDialog(BuildContext context, HabitProvider provider) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Nou hàbit"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nom"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Descripció"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel·lar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                provider.addHabit(
                  nameController.text,
                  descController.text.isEmpty ? null : descController.text,
                  [],
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text("Crear"),
          ),
        ],
      ),
    );
  }

  void _toggleHabit(BuildContext context, HabitProvider provider, String habitId) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    provider.toggleHabitCompletion(habitId, today);
  }
}