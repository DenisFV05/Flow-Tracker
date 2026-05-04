import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habitsProvider.dart';
import '../../widgets/stats/heatmap.dart';
import '../../widgets/stats/weekly_chart.dart';
import '../../views/editarHabit.dart';
import 'package:flowTracker/utils.dart';

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
  bool _loading = false;
  List<dynamic> _weeklyData = [];
  List<dynamic> _monthlyData = [];
  List<dynamic> _heatmapData = [];
  int _heatmapYear = DateTime.now().year;
  bool _chartsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCharts();
  }

  Future<void> _loadCharts() async {
    setState(() => _chartsLoading = true);
    try {
      final provider = context.read<HabitProvider>();
      final results = await Future.wait([
        provider.getHabitWeekly(widget.habit['id']),
        provider.getHabitMonthly(widget.habit['id']),
        provider.getHabitHeatmap(widget.habit['id']),
      ]);

      if (mounted) {
        setState(() {
          _weeklyData = (results[0] as Map<String, dynamic>)['days'] as List<dynamic>? ?? [];
          _monthlyData = (results[1] as Map<String, dynamic>)['days'] as List<dynamic>? ?? [];
          final heatmapResult = results[2] as Map<String, dynamic>;
          _heatmapData = heatmapResult['data'] as List<dynamic>? ?? [];
          _heatmapYear = heatmapResult['year'] ?? DateTime.now().year;
          _chartsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _chartsLoading = false);
      }
    }
  }

  Future<void> _toggleHabit() async {
    setState(() => _loading = true);

    try {
      await context.read<HabitProvider>().toggleHabit(
        widget.habit['id'],
        true,
      );

      await _loadCharts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error actualitzant hàbit")),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showEditDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: EditarHabit(habit: widget.habit),
      ),
    ).then((_) {
      context.read<HabitProvider>().loadDashboard();
    });
  }

  Future<void> _deleteHabit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar hàbit'),
        content: Text('Segur que vols eliminar "${widget.habit['name']}"? Aquesta acció no es pot desfer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel·lar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await context.read<HabitProvider>().deleteHabit(widget.habit['id']);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error eliminant hàbit: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final stats = context.watch<HabitProvider>().habitStats[habit['id']] ?? {};
    final progress = ((stats['completionRate'] ?? 0) / 100).toDouble();
    final streak = stats['currentStreak'] ?? 0;
    final maxStreak = stats['maxStreak'] ?? 0;
    final totalDays = stats['totalDays'] ?? 0;
    final completedDays = stats['completedDays'] ?? 0;
    final tags = habit['tags'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(habit['name'] ?? 'Detalls hàbit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar hàbit',
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Eliminar hàbit',
            onPressed: _deleteHabit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            Wrap(
              spacing: 8,
              children: tags.isNotEmpty
                  ? tags.map<Widget>((tag) {
                      final name = tag is Map
                          ? tag['name']
                          : tag.toString();
                      return Chip(
                        label: Text(name),
                        backgroundColor: bgIcons.withOpacity(0.1),
                      );
                    }).toList()
                  : [const Chip(label: Text("Sense etiquetes"))],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Ratxa actual',
                    '$streak dies',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Ratxa màxima',
                    '$maxStreak dies',
                    Icons.emoji_events,
                    Colors.amber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Dies completats',
                    '$completedDays/$totalDays',
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Percentatge',
                    '${(progress * 100).round()}%',
                    Icons.analytics,
                    Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Progrés",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              color: bgIcons,
              backgroundColor: bgIcons.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),

            const SizedBox(height: 24),

            const Text(
              "Aquesta setmana",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            _chartsLoading
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _weeklyData.isNotEmpty
                    ? WeeklyChart(days: _weeklyData)
                    : _emptyChart('No hi ha dades aquesta setmana'),

            const SizedBox(height: 24),

            const Text(
              "Aquest mes",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            _chartsLoading
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _monthlyData.isNotEmpty
                    ? MonthlyChart(days: _monthlyData)
                    : _emptyChart('No hi ha dades aquest mes'),

            const SizedBox(height: 24),

              Text(
                "Heatmap $_heatmapYear",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            const SizedBox(height: 10),

            _chartsLoading
                ? const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _heatmapData.isNotEmpty
                    ? HabitHeatmap(heatmapData: _heatmapData, year: _heatmapYear)
                    : _emptyChart('No hi ha dades encara'),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _toggleHabit,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: _loading
                    ? const Text('Marcant...')
                    : const Text("Marcar com feta avui"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bgIcons,
                  foregroundColor: white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Colors.black12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyChart(String message) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }
}
