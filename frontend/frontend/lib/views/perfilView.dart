import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habitsProvider.dart';
import 'inputEstil.dart';
import 'package:flowTracker/utils.dart';

class perfilView extends StatefulWidget {
  const perfilView({super.key});

  @override
  State<perfilView> createState() => _perfilViewState();
}

class _perfilViewState extends State<perfilView> {
  final _nameController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HabitProvider>();
      provider.loadProfile();
      final profile = provider.userProfile;
      if (profile.isNotEmpty) {
        _nameController.text = profile['name'] ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      await context.read<HabitProvider>().updateProfile(
        name: _nameController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualitzat!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final profile = provider.userProfile;
    final loading = provider.profileLoading;

    if (loading && profile.isEmpty) {
      return Container(
        color: const Color(0xFFF5F7FA),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final name = profile['name'] ?? '';
    final username = profile['username'] ?? '';
    final email = profile['email'] ?? '';
    final avatar = profile['avatar'];

    return Container(
      color: const Color(0xFFF5F7FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildProfileForm(name, username, email, avatar),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: _buildStatsCard(),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileForm(name, username, email, avatar),
                const SizedBox(height: 24),
                _buildStatsCard(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileForm(String name, String username, String email, String? avatar) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perfil',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: bgIcons.withOpacity(0.15),
              backgroundImage: avatar != null ? NetworkImage(avatar) : null,
              child: avatar == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 32, color: bgIcons),
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 24),

          const Text('Nom', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: inputEstil.base("Nom", "El teu nom"),
          ),

          const SizedBox(height: 16),

          const Text('Username', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            '@$username',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),

          const SizedBox(height: 16),

          const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            email,
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _saveProfile,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Guardar canvis'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final stats = context.watch<HabitProvider>().dashboardStats;
    final loading = context.watch<HabitProvider>().loading;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalHabits = stats['totalHabits'] ?? 0;
    final totalLogs = stats['totalLogs'] ?? 0;
    final completedLogs = stats['completedLogs'] ?? 0;
    final rate = stats['overallCompletionRate'] ?? 0;
    final longestStreak = stats['longestStreak'] ?? 0;
    final todayCompleted = stats['todayCompleted'] ?? 0;
    final todayTotal = stats['todayTotal'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadístiques',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _statRow('Hàbits totals', '$totalHabits'),
          const SizedBox(height: 14),
          _statRow('Registres totals', '$totalLogs'),
          const SizedBox(height: 14),
          _statRow('Completats', '$completedLogs'),
          const SizedBox(height: 14),
          _statRow('Percentatge global', '${rate.toStringAsFixed(1)}%'),
          const SizedBox(height: 14),
          _statRow('Ratxa màxima', '$longestStreak dies'),
          const SizedBox(height: 14),
          _statRow('Avui', '$todayCompleted/$todayTotal'),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      ],
    );
  }
}
