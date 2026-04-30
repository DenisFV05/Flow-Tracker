import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/User.dart';
import '../models/habitsProvider.dart';
import 'inputEstil.dart';

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
    final profile = context.read<HabitProvider>().userProfile;
    if (profile.isNotEmpty) {
      _nameController.text = profile['name'] ?? '';
    }
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
          const SnackBar(content: Text('Perfil actualitzat!')),
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

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final name = profile['name'] ?? '';
    final username = profile['username'] ?? '';
    final email = profile['email'] ?? '';
    final avatar = profile['avatar'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadProfile(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// AVATAR
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                child: avatar == null
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 32),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            /// NAME
            const Text(
              'Nom',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: inputEstil.base("Nom", "El teu nom"),
            ),

            const SizedBox(height: 16),

            /// USERNAME (read-only)
            const Text(
              'Username',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '@$username',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),

            /// EMAIL (read-only)
            const Text(
              'Email',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            /// SAVE BUTTON
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
      ),
    );
  }
}
}