import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../providers/habitProvider.dart';

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

  final List<String> defaultTags = [
    'Esport',
    'Estudis',
    'Salut',
    'Lectura',
    'Treball'
  ];

  String? selectedTag;
  final List<String> _customTags = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descripcioController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  void _addCustomTag() {
    final tag = _customTagController.text.trim();
    if (tag.isEmpty) return;
    if (_customTags.contains(tag)) return;
    setState(() {
      _customTags.add(tag);
      _customTagController.clear();
    });
  }

  void _removeCustomTag(String tag) {
    setState(() {
      _customTags.remove(tag);
    });
  }

  Future<void> _crearHabit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final description = _descripcioController.text.trim();

      final List<String> tags = [];

      if (selectedTag != null) {
        tags.add(selectedTag!);
      }

      tags.addAll(_customTags);

      try {
        await context.read<HabitProvider>().addHabit(
          name,
          description,
          tags,
        );

        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
          selectedTag = isSelected ? null : tag;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Crear nou habit',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  'Afegeix un nou habit, utilitza les etiquetes per organitzar-ho.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Nom de l'habit",
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  decoration: InputDecoration(
                    hintText: 'exemple: Correr al matí',
                    filled: true,
                    fillColor: AppTheme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Descripció (opcional)',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descripcioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'exemple: 1 hora de camí tots els dies.',
                    filled: true,
                    fillColor: AppTheme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Etiquetes',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
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

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _customTagController,
                        decoration: InputDecoration(
                          hintText: 'Afegir una etiqueta custom...',
                          filled: true,
                          fillColor: AppTheme.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _addCustomTag,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Afegir'),
                    ),
                  ],
                ),

                if (_customTags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _customTags.map((tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 13, color: Colors.white)),
                      backgroundColor: AppTheme.primary,
                      deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                      onDeleted: () => _removeCustomTag(tag),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    )).toList(),
                  ),
                ],

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.textSecondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Cancel·lar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _crearHabit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Crear Habit'),
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
