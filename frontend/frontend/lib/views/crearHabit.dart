import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'inputEstil.dart';
import 'package:flowTracker/utils.dart';
import 'package:flowTracker/models/habit.dart';
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
  final _customTagController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descripcioController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  void _crearHabit() {

    if (_formKey.currentState!.validate()) {
      Habit newHabit = Habit(
        id: DateTime.now().toString(),
        title: _nameController.text,
        subtitle: _descripcioController.text,
        tags: [_customTagController.text],
        progress: 0.0,
        completedToday: false,
      );

      context.read<HabitProvider>().addHabit(newHabit);

      // cerrar popup y devolver resultado opcional
      Navigator.pop(context);
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
              "Crear habit nou",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Omple els camps per crear un nou habit"),
            const SizedBox(height: 20),

            /// NOM
            TextFormField(
              controller: _nameController,
              decoration: inputEstil.base(
                "NOM DE L'HABIT",
                "Escriu un nom",
              ),
              validator: (value) =>
                  value!.isEmpty ? "Requerit" : null,
            ),

            const SizedBox(height: 12),

            /// DESCRIPCIÓN
            TextFormField(
              controller: _descripcioController,
              decoration: inputEstil.base(
                "DESCRIPCIÓ",
                "Escriu una descripció",
              ),
              validator: (value) =>
                  value!.isEmpty ? "Requerit" : null,
            ),

            const SizedBox(height: 12),

            /// TAG
            TextFormField(
              controller: _customTagController,
              decoration: inputEstil.base(
                "ETIQUETA CUSTOM",
                "Crea una etiqueta",
              ),
              validator: (value) =>
                  value!.isEmpty ? "Requerit" : null,
            ),

            const SizedBox(height: 25),

            /// BOTONES
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text("CANCELAR"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _crearHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bgIcons,
                    foregroundColor: white,
                  ),
                  child: const Text("CREAR"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
