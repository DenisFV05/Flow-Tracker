import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'inputEstil.dart';
import 'package:flowTracker/utils.dart';
import 'package:flowTracker/models/habitsProvider.dart';

class CrearHabitForm extends StatefulWidget {
  const CrearHabitForm({super.key});

  @override
  State<CrearHabitForm> createState() => _CrearHabitFormState();
}

class _CrearHabitFormState extends State<CrearHabitForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descripcioController = TextEditingController();
  final _tagsController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descripcioController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _crearHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text;
      final description = _descripcioController.text;
      final tagString = _tagsController.text;
      final tags = tagString
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      if (tags.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Afegeix almenys una etiqueta")),
        );
        return;
      }

      await context.read<HabitProvider>().addHabit(
        name,
        description,
        tags,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hàbit creat correctament")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creant hàbit: $e")),
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
              "Crear hàbit nou",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Omple els camps per crear un nou hàbit"),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              decoration: inputEstil.base(
                "NOM DE L'HÀBIT",
                "Escriu un nom",
              ),
              validator: (value) =>
                  value!.isEmpty ? "Requerit" : null,
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _descripcioController,
              decoration: inputEstil.base(
                "DESCRIPCIÓ",
                "Escriu una descripció",
              ),
              maxLines: 3,
              validator: (value) =>
                  value!.isEmpty ? "Requerit" : null,
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _tagsController,
              decoration: inputEstil.base(
                "ETIQUETES",
                "Separa amb comes (ex: esport, salut)",
              ),
              validator: (value) =>
                  value!.isEmpty ? "Requerit" : null,
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text("CANCEL·LAR"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _crearHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bgIcons,
                    foregroundColor: white,
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
                      : const Text("CREAR"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
