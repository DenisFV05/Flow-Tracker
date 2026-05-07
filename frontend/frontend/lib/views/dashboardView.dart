import 'dart:async';
import 'package:flowTracker/views/editarHabit.dart';
import 'package:flowTracker/widgets/habits/HabitDetailView.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';

import '../widgets/habits/HabitCard.dart';
import '../widgets/stats/StatsGrid.dart';
import '../widgets/stats/todayProgress.dart';

import '../models/habitsProvider.dart';
import 'crearHabit.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  Timer? _timeTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadDashboard();
    });

    _timeTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timeTimer?.cancel();
    super.dispose();
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
      color: AppTheme.background,
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppTheme.primary,
        child: loading && habits.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
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
                                        'Progrés d\'avui',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TodayProgress(habits: habits, habitStats: habitStats),
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
                              'Progrés d\'avui',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TodayProgress(habits: habits, habitStats: habitStats),
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
    IconData greetingIcon;
    if (hour < 12) {
      greeting = 'Bon dia';
      greetingIcon = Icons.wb_sunny_rounded;
    } else if (hour < 18) {
      greeting = 'Bona tarda';
      greetingIcon = Icons.wb_cloudy_rounded;
    } else {
      greeting = 'Bona nit';
      greetingIcon = Icons.nights_stay_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDarker],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
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
            child: Icon(
              greetingIcon,
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
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: () => showCrearHabitPopup(context),
              icon: const Icon(Icons.add_circle_outline, size: 20, color: AppTheme.primary),
              label: const Text('Afegir', style: TextStyle(color: AppTheme.primary)),
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
                color: AppTheme.primary,

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HabitDetailView(habit: habit),
                    ),
                  );
                },

                onDelete: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('Eliminar hábit'),
                      content: Text('Segur que vols eliminar "${habit['name'] ?? ''}"? Els registres i publicacions associats també es perdran.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel·lar')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  if (!mounted) return;
                  final id = habit['id'].toString();
                  await context
                      .read<HabitProvider>()
                      .deleteHabit(id);
                },

                onEdit: () async {
                  await showDialog(
                    context: context,
                    builder: (_) => Editarhabit(
                      habitId: habit['id'].toString(),
                      initialName: habit['name'] ?? '',
                      initialDescription:
                          habit['description'] ?? '',
                      initialTags: (habit['tags'] as List<dynamic>)
                          .map((tag) => tag['name'].toString())
                          .toList(),
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
            color: AppTheme.primary.withOpacity(0.06),
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
              color: AppTheme.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.track_changes_rounded, size: 40, color: AppTheme.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Encara no tens hàbits',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
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
              backgroundColor: AppTheme.primary,
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
