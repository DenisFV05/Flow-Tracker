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

  Future<void> _refresh() async {
    await context.read<HabitProvider>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();

    final habits = provider.habits;
    final loading = provider.loading;

    final dashboardStats = provider.dashboardStats;
    final habitStats = provider.habitStats;

    return Container(
      color: const Color(0xFFF5F7FA),
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: loading && habits.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(),
                    const SizedBox(height: 24),
                    StatsGrid(
                      totalHabits: dashboardStats['totalHabits'] ?? 0,
                      todayCompleted: dashboardStats['todayCompleted'] ?? 0,
                      totalToday: dashboardStats['todayTotal'] ?? 0,
                      longestStreak: dashboardStats['longestStreak'] ?? 0,
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;

                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildHabitsList(habits, habitStats),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SectionTitle(title: "Resum"),
                                    const SizedBox(height: 12),
                                    const QuickStats(),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHabitsList(habits, habitStats),
                            const SizedBox(height: 24),
                            SectionTitle(title: "Resum"),
                            const SizedBox(height: 12),
                            const QuickStats(),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Bon dia';
    } else if (hour < 18) {
      greeting = 'Bona tarda';
    } else {
      greeting = 'Bona nit';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Segueix els teus hàbits d\'avui',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitsList(List<dynamic> habits, Map<String, dynamic> habitStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionTitle(title: "Hàbits d'avui"),
            TextButton.icon(
              onPressed: () => showCrearHabitPopup(context),
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('Afegir'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00B089),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (habits.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.track_changes_outlined,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Encara no tens hàbits',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crea el teu primer hàbit per començar a fer seguiment',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => showCrearHabitPopup(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Crear hàbit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B089),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...habits.map((habit) {
            final stats = habitStats[habit['id']] as Map<String, dynamic>? ?? {};
            final progress = ((stats['completionRate'] ?? 0) / 100).toDouble();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HabitCard(
                title: habit['name'] ?? '',
                subtitle: habit['description'] ?? '',
                progress: progress,
                streak: stats['currentStreak'] ?? 0,
                tags: habit['tags'] ?? [],
                color: const Color(0xFF00B089),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HabitDetailView(habit: habit),
                    ),
                  );
                },
              ),
            );
          }),
      ],
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
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: CrearHabitForm(),
        ),
      );
    },
  );
}
