import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habitsProvider.dart';

class AmicsView extends StatefulWidget {
  const AmicsView({super.key});

  @override
  State<AmicsView> createState() => _AmicsViewState();
}

class _AmicsViewState extends State<AmicsView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Amics"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Sol·licituds rebudes",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text("No tens sol·licituds pendents"),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Els teus amics",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.people),
              title: const Text("No tens amics encara"),
              subtitle: const Text("Busca usuaris per afegir amics"),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Buscar amics"),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: "Nom d'usuari",
            hintText: "Introdueix el nom d'usuari",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel·lar"),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement search
              Navigator.pop(context);
            },
            child: const Text("Buscar"),
          ),
        ],
      ),
    );
  }
}