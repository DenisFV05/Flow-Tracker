import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habitsProvider.dart';

class OpcionsView extends StatelessWidget {
  final VoidCallback onLogout;

  const OpcionsView({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final user = provider.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(user?.name ?? 'Usuari'),
              subtitle: Text(user?.email ?? ''),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.analytics),
                  title: const Text("Estadístiques"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Aviat!")),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Configuració"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Aviat!")),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text("Tancar sessió"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}