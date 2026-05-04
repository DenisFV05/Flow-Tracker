import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'inputEstil.dart';
import 'package:flowTracker/models/habitsProvider.dart';

class EditarHabit extends StatefulWidget {
  final dynamic habit;

  const EditarHabit({super.key, required this.habit});

  @override
  State<EditarHabit> createState() => _EditarHabitFormState();
}

class _EditarHabitFormState extends State<EditarHabit> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descripcioController;
  late final TextEditingController _tagController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final habit = widget.habit;
    _nameController = TextEditingController(text: habit['name'] ?? '');
    _descripcioController = TextEditingController(text: habit['description'] ?? '');
    final tags = habit['tags'] as List<dynamic>? ?? [];
    _tagController = TextEditingController(
      text: tags.isNotEmpty ? tags.map((t) => t is Map ? t['name'] : t.toString()).join(', ') : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descripcioController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _updateHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text;
      final description = _descripcioController.text;
      final tagString = _tagController.text;
      final tags = tagString
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      await context.read<HabitProvider>().editHabit(
        widget.habit['id'],
        name,
        description,
        tags,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Hàbit actualitzat correctament'),
            backgroundColor: const Color(0xFF1E88E5),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error actualitzant hàbit: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Editar hàbit",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2332),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Modifica les dades de l'hàbit",
              style: TextStyle(color: Color(0xFF546E7A)),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              decoration: inputEstil.base(
                "NOM DE L'HÀBIT",
                "Escriu un nom",
              ),
              validator: (value) => value!.isEmpty ? "Requerit" : null,
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _descripcioController,
              decoration: inputEstil.base(
                "DESCRIPCIÓ",
                "Escriu una descripció",
              ),
              maxLines: 3,
              validator: (value) => value!.isEmpty ? "Requerit" : null,
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _tagController,
              decoration: inputEstil.base(
                "ETIQUETES",
                "Separa amb comes (ex: esport, salut)",
              ),
              validator: (value) => value!.isEmpty ? "Requerit" : null,
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF546E7A),
                    side: const BorderSide(color: Color(0xFFCFD8DC)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text("CANCEL·LAR"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("GUARDAR"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
