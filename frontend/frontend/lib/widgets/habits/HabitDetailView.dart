import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/habitsProvider.dart';
import '../../widgets/stats/heatmap.dart';
import '../../widgets/stats/weekly_chart.dart';
import '../../views/editarHabit.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar hàbit', style: TextStyle(color: Color(0xFF1A2332))),
        content: Text('Segur que vols eliminar "${widget.habit['name']}"? Aquesta acció no es pot desfer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel·lar', style: TextStyle(color: Color(0xFF1E88E5))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          habit['name'] ?? 'Detalls hàbit',
          style: const TextStyle(color: Color(0xFF1A2332), fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1A2332)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar hàbit',
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFE53935)),
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
                color: Color(0xFF1A2332),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              habit['description'] ?? 'Sense descripció',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF546E7A),
              ),
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              children: tags.isNotEmpty
                  ? tags.map<Widget>((tag) {
                      final name = tag is Map ? tag['name'] : tag.toString();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1E88E5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList()
                  : [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Sense etiquetes",
                          style: TextStyle(fontSize: 12, color: Color(0xFF546E7A)),
                        ),
                      ),
                    ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Ratxa actual',
                    '$streak dies',
                    Icons.local_fire_department_rounded,
                    const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Ratxa màxima',
                    '$maxStreak dies',
                    Icons.emoji_events_rounded,
                    const Color(0xFFFF9800),
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
                    Icons.check_circle_rounded,
                    const Color(0xFF43A047),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Percentatge',
                    '${(progress * 100).round()}%',
                    Icons.analytics_rounded,
                    const Color(0xFF1E88E5),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Progrés",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1A2332)),
            ),
            const SizedBox(height: 10),

            Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: const Color(0xFF1E88E5).withOpacity(0.12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Aquesta setmana",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1A2332)),
            ),
            const SizedBox(height: 10),

            _chartsLoading
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5))),
                  )
                : _weeklyData.isNotEmpty
                    ? WeeklyChart(days: _weeklyData)
                    : _emptyChart('No hi ha dades aquesta setmana'),

            const SizedBox(height: 24),

            const Text(
              "Aquest mes",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1A2332)),
            ),
            const SizedBox(height: 10),

            _chartsLoading
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5))),
                  )
                : _monthlyData.isNotEmpty
                    ? MonthlyChart(days: _monthlyData)
                    : _emptyChart('No hi ha dades aquest mes'),

            const SizedBox(height: 24),

            Text(
              "Heatmap $_heatmapYear",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1A2332)),
            ),
            const SizedBox(height: 10),

            _chartsLoading
                ? const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF1E88E5))),
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
                    : const Icon(Icons.check_rounded),
                label: _loading
                    ? const Text('Marcant...')
                    : const Text("Marcar com feta avui"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2332),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
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
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Color(0xFF1E88E5)),
        ),
      ),
    );
  }
}
