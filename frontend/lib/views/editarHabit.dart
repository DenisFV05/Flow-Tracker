import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../providers/habitProvider.dart';


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
  final List<String> _customTags = [];

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.initialName;
    _descripcioController.text = widget.initialDescription;

    for (final tag in widget.initialTags) {
      if (defaultTags.contains(tag)) {
        selectedTag = tag;
      } else {
        _customTags.add(tag);
      }
    }
  }

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

  Future<void> _editarHabit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final description = _descripcioController.text.trim();

      final List<String> tags = [];

      if (selectedTag != null) {
        tags.add(selectedTag!);
      }

      tags.addAll(_customTags);

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
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
        padding: EdgeInsets.all(24),
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
                    Text(
                      'Editar habit',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: context.textSecondaryColor),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                Text(
                  'Modifica el teu habit i actualitza les etiquetes.',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textSecondaryColor,
                  ),
                ),

                SizedBox(height: 24),

                Text(
                  "Nom de l'habit",
                  style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimaryColor),
                ),
                SizedBox(height: 8),
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
                    filled: true,
                    fillColor: context.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),

                SizedBox(height: 18),

                Text(
                  'Descripció (opcional)',
                  style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimaryColor),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _descripcioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Exemple: 1 hora de camí tots els dies.',
                    filled: true,
                    fillColor: context.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),

                SizedBox(height: 18),

                Text(
                  'Etiquetes',
                  style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimaryColor),
                ),
                SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: defaultTags
                      .map((tag) => _buildTag(tag))
                      .toList(),
                ),

                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _customTagController,
                        decoration: InputDecoration(
                          hintText: 'Afegir una etiqueta custom...',
                          filled: true,
                          fillColor: context.backgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _addCustomTag,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Afegir'),
                    ),
                  ],
                ),

                if (_customTags.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _customTags.map((tag) => Chip(
                      label: Text(tag, style: TextStyle(fontSize: 13, color: context.surfaceColor)),
                      backgroundColor: AppTheme.primary,
                      deleteIcon: Icon(Icons.close, size: 16, color: context.surfaceColor),
                      onDeleted: () => _removeCustomTag(tag),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.symmetric(horizontal: 4),
                    )).toList(),
                  ),
                ],

                SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.textSecondaryColor,
                        side: BorderSide(color: context.textSecondaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text('Cancel·lar'),
                    ),

                    SizedBox(width: 12),

                    ElevatedButton(
                      onPressed: _editarHabit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Guardar canvis'),
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
