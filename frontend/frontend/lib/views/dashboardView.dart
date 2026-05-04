import 'package:flowTracker/widgets/habits/HabitDetailView.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/habits/HabitCard.dart';
import '../widgets/stats/StatsGrid.dart';
import '../widgets/stats/quickStats.dart';

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
      color: const Color(0xFFF0F7FF),
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFF1E88E5),
        child: loading && habits.isEmpty
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5)))
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
                    const SizedBox(height: 28),
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
                                    const Text(
                                      'Resum',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A2332),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
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
                            const SizedBox(height: 28),
                            const Text(
                              'Resum',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A2332),
                              ),
                            ),
                            const SizedBox(height: 16),
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.track_changes_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Segueix els teus hàbits d\'avui',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList(List<dynamic> habits, Map<String, dynamic> habitStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hàbits d\'avui',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2332),
              ),
            ),
            TextButton.icon(
              onPressed: () => showCrearHabitPopup(context),
              icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF1E88E5)),
              label: const Text('Afegir', style: TextStyle(color: Color(0xFF1E88E5))),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (habits.isEmpty)
          _emptyHabits()
        else
          ...habits.map((habit) {
            final stats = habitStats[habit['id']] as Map<String, dynamic>? ?? {};
            final progress = ((stats['completionRate'] ?? 0) / 100).toDouble();

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: HabitCard(
                title: habit['name'] ?? '',
                subtitle: habit['description'] ?? '',
                progress: progress,
                streak: stats['currentStreak'] ?? 0,
                tags: habit['tags'] ?? [],
                color: const Color(0xFF1E88E5),
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

  Widget _emptyHabits() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.track_changes_rounded, size: 40, color: Color(0xFF1E88E5)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Encara no tens hàbits',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2332),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea el teu primer hàbit per començar a fer seguiment',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => showCrearHabitPopup(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Crear hàbit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: CrearHabitForm(),
        ),
      );
    },
  );
}
