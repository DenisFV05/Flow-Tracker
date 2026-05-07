import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/habitsProvider.dart';
import 'inputEstil.dart';

class perfilView extends StatefulWidget {
  const perfilView({super.key});

  @override
  State<perfilView> createState() => _perfilViewState();
}

class _perfilViewState extends State<perfilView> {
  final _nameController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  bool _saving = false;
  File? _selectedImage;
  bool _showDebug = false;

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
        final avatar = profile['avatar'];
        if (avatar != null && !avatar.startsWith('data:')) {
          _avatarUrlController.text = avatar;
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final ext = result.files.first.extension?.toLowerCase() ?? 'png';
      setState(() {
        _selectedImage = file;
        _avatarUrlController.text = 'data:image/$ext;base64,$base64Image';
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      final avatar = _avatarUrlController.text.trim().isNotEmpty
          ? _avatarUrlController.text.trim()
          : null;
      await context.read<HabitProvider>().updateProfile(
        name: _nameController.text,
        avatar: avatar,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perfil actualitzat!'),
            backgroundColor: AppTheme.primary,
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
        color: AppTheme.background,
        child: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final name = profile['name'] ?? '';
    final username = profile['username'] ?? '';
    final email = profile['email'] ?? '';
    final avatar = profile['avatar'];
    final avatarPreview = _avatarUrlController.text.isNotEmpty
        ? _avatarUrlController.text
        : avatar;

    return Container(
      color: AppTheme.background,
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
                    child: _buildProfileForm(name, username, email, avatarPreview),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsCard(),
                        const SizedBox(height: 16),
                        _buildDebugPanel(),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileForm(name, username, email, avatarPreview),
                const SizedBox(height: 24),
                _buildStatsCard(),
                const SizedBox(height: 24),
                _buildDebugPanel(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileForm(String name, String username, String email, String? avatarPreview) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perfil',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primary, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppTheme.surfaceLight,
                    backgroundImage: avatarPreview != null && avatarPreview.isNotEmpty
                        ? (avatarPreview.startsWith('data:')
                            ? MemoryImage(base64Decode(avatarPreview.split(',').last))
                            : NetworkImage(avatarPreview))
                        : null,
                    child: (avatarPreview == null || avatarPreview.isEmpty)
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 32, color: AppTheme.primary, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _showAvatarOptions,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text('Nom', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'El teu nom',
              filled: true,
              fillColor: AppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),

          const SizedBox(height: 16),

          const Text('Username', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(
            '@$username',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),

          const SizedBox(height: 16),

          const Text('Email', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
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

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Foto de perfil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppTheme.primary),
                title: const Text('Seleccionar imatge'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.link_rounded, color: AppTheme.primary),
                title: const Text('URL de la imatge'),
                onTap: () {
                  Navigator.pop(context);
                  _showAvatarUrlDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: Colors.red),
                title: const Text('Eliminar foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _avatarUrlController.clear();
                    _selectedImage = null;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAvatarUrlDialog() {
    final controller = TextEditingController(text: _avatarUrlController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('URL de la imatge', style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://exemple.com/foto.jpg',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel·lar', style: TextStyle(color: AppTheme.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _avatarUrlController.text = controller.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final stats = context.watch<HabitProvider>().dashboardStats;
    final loading = context.watch<HabitProvider>().loading;

    if (loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
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
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadístiques',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 20),
          _statRow(Icons.track_changes_rounded, 'Hàbits totals', '$totalHabits', AppTheme.primary),
          const SizedBox(height: 12),
          _statRow(Icons.description_rounded, 'Registres totals', '$totalLogs', AppTheme.success),
          const SizedBox(height: 12),
          _statRow(Icons.check_circle_rounded, 'Completats', '$completedLogs', AppTheme.purple),
          const SizedBox(height: 12),
          _statRow(Icons.percent_rounded, 'Percentatge global', '${rate.toStringAsFixed(1)}%', AppTheme.warning),
          const SizedBox(height: 12),
          _statRow(Icons.local_fire_department_rounded, 'Ratxa màxima', '$longestStreak dies', AppTheme.warning),
          const SizedBox(height: 12),
          _statRow(Icons.today_rounded, 'Avui', '$todayCompleted/$todayTotal', AppTheme.primary),
        ],
      ),
    );
  }

  Widget _statRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _buildDebugPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showDebug = !_showDebug),
            child: Row(
              children: [
                const Icon(Icons.bug_report_rounded, size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Mode desenvolupador',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const Spacer(),
                Icon(_showDebug ? Icons.expand_less : Icons.expand_more, size: 20, color: Colors.grey[500]),
              ],
            ),
          ),
          if (_showDebug) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Simular ratxes i registres en dates passades',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Crea un hàbit al Dashboard si encara no en tens',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
            const Text(
              '2. Usa "Marcar hàbit avui" per registrar el hàbit per avui',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
            const Text(
              '3. Usa els altres botons per crear registres en dies anteriors i augmentar la ratxa',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            _debugButton('Marcar hàbit avui', AppTheme.success, _markToday),
            const SizedBox(height: 4),
            Text(
              'Registra el primer hàbit de la llista per avui. És el punt de partida per crear ratxes.',
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            _debugButton('Afegir registre ahir', AppTheme.primary, _simulatePastDay),
            const SizedBox(height: 4),
            Text(
              'Crea un registre per ahir. Si ja tens un registre avui, la ratxa augmentarà a 2.',
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            _debugButton('Afegir registre fa 7 dies', AppTheme.purple, _simulateWeekAgo),
            const SizedBox(height: 4),
            Text(
              'Crea un registre fa 7 dies. No afecta la ratxa actual però omple el heatmap.',
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            _debugButton('Crear ratxa de 8 dies', AppTheme.warning, _simulate7DaysAgo),
            const SizedBox(height: 4),
            Text(
              'Registra el hàbit durant 8 dies seguits (fa 7 dies fins avui). Veurem la ratxa pujar a 8.',
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _debugButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  Future<void> _markToday() async {
    final provider = context.read<HabitProvider>();
    if (provider.habits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crea un hàbit primer')),
      );
      return;
    }
    final habit = provider.habits.first;
    await provider.toggleHabit(habit['id'], true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${habit['name']} marcat per avui!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  Future<void> _simulatePastDay() async {
    final provider = context.read<HabitProvider>();
    if (provider.habits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crea un hàbit primer')),
      );
      return;
    }
    final habitId = provider.habits.first['id'];
    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T').first;
    await provider.api.logHabit(habitId, yesterday, true);
    await provider.loadDashboard();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hàbit registrat per ahir ($yesterday)'),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  Future<void> _simulateWeekAgo() async {
    final provider = context.read<HabitProvider>();
    if (provider.habits.isEmpty) return;
    final habitId = provider.habits.first['id'];
    final date = DateTime.now().subtract(const Duration(days: 7)).toIso8601String().split('T').first;
    await provider.api.logHabit(habitId, date, true);
    await provider.loadDashboard();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hàbit registrat fa 7 dies ($date)'),
          backgroundColor: AppTheme.purple,
        ),
      );
    }
  }

  Future<void> _simulate7DaysAgo() async {
    final provider = context.read<HabitProvider>();
    if (provider.habits.isEmpty) return;
    final habitId = provider.habits.first['id'];
    for (int i = 7; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i)).toIso8601String().split('T').first;
      await provider.api.logHabit(habitId, date, true);
    }
    await provider.loadDashboard();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrats 8 dies seguits! Ratxa de 8.'),
          backgroundColor: AppTheme.warning,
        ),
      );
    }
  }
}
