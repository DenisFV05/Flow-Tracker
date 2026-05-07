import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flowTracker/models/habitsProvider.dart';

class Editarhabit extends StatefulWidget {
  final String habitId;
  final String initialName;
  final String initialDescription;
  final List<String> initialTags;

  const Editarhabit({
    super.key,
    required this.habitId,
    required this.initialName,
    required this.initialDescription,
    required this.initialTags,
  });

  @override
  State<Editarhabit> createState() => EditarhabitFormState();
}

class EditarhabitFormState extends State<Editarhabit> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descripcioController = TextEditingController();
  final _customTagController = TextEditingController();

  final List<String> defaultTags = [
    'Esport',
    'Estudis',
    'Salut',
    'Lectura',
    'Treball',
  ];

  String? selectedTag;

  @override
  void initState() {
    super.initState();

    // Cargar datos actuales del hábito
    _nameController.text = widget.initialName;
    _descripcioController.text = widget.initialDescription;

    if (widget.initialTags.isNotEmpty) {
      selectedTag = widget.initialTags.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descripcioController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  Future<void> _editarHabit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final description = _descripcioController.text.trim();

      final List<String> tags = [];

      if (selectedTag != null) {
        tags.add(selectedTag!);
      }

      if (_customTagController.text.trim().isNotEmpty) {
        tags.add(_customTagController.text.trim());
      }

      try {
        await context.read<HabitProvider>().editHabit(
          widget.habitId,
          name,
          description,
          tags,
        );

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error editando hábito'),
          ),
        );
      }
    }
  }

  Widget _buildTag(String tag) {
    final isSelected = selectedTag == tag;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTag = tag;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E88E5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFFFFF)
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? const Color(0xFFFFFFFF)
                : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Editar habit',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  'Modifica el teu habit i actualitza les etiquetes.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 24),

                /// Nombre
                const Text(
                  "Nom de l'habit",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Exemple: Correr al matí',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF4FD1B5),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                /// Descripción
                const Text(
                  'Descripció (opcional)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _descripcioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'Exemple: 1 hora de camí tots els dies.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                /// Tags
                const Text(
                  'Etiquetes',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: defaultTags
                      .map((tag) => _buildTag(tag))
                      .toList(),
                ),

                const SizedBox(height: 16),

                /// Custom tag
                TextFormField(
                  controller: _customTagController,
                  decoration: InputDecoration(
                    hintText: 'Afegir una etiqueta custom...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                /// Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),

                    const SizedBox(width: 12),

                    ElevatedButton(
                      onPressed: _editarHabit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                           const Color(0xFF1E88E5) ,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Text(
                        'Guardar canvis',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
