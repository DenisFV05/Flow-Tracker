import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/tag_bar_chart.dart';

/// Pantalla d'estadístiques d'etiquetes.
/// Mostra una barra lateral amb les etiquetes disponibles
/// i un gràfic de barres amb CustomPainter per comparar-les.
class StatsScreen extends StatefulWidget {
  final String serverUrl;
  final String token;

  const StatsScreen({
    super.key,
    required this.serverUrl,
    required this.token,
  });

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, int> _tagData = {};
  Set<String> _selectedTags = {};
  bool _isLoading = true;
  String _errorMessage = '';

  // Paleta de colors per a les etiquetes
  static const List<Color> _palette = [
    Color(0xFF6366F1), // Indigo
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEF4444), // Red
    Color(0xFF06B6D4), // Cyan
    Color(0xFF22C55E), // Green
    Color(0xFFF97316), // Orange
    Color(0xFF3B82F6), // Blue
    Color(0xFFA855F7), // Purple
    Color(0xFF10B981), // Emerald
    Color(0xFFE11D48), // Rose
    Color(0xFF0EA5E9), // Sky
    Color(0xFFD946EF), // Fuchsia
  ];

  Map<String, Color> _tagColors = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  /// Assignar colors únics a cada etiqueta
  void _assignColors() {
    int index = 0;
    _tagColors = {};
    for (final tag in _tagData.keys) {
      _tagColors[tag] = _palette[index % _palette.length];
      index++;
    }
  }

  /// Carregar estadístiques del servidor
  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('${widget.serverUrl}/api/admin/estadistiques/tags'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final tagsData = data['data']['tags'] as List;
          final Map<String, int> tagMap = {};
          for (final item in tagsData) {
            tagMap[item['tag'] as String] = item['count'] as int;
          }
          setState(() {
            _tagData = tagMap;
            // Seleccionar les 5 primeres per defecte
            _selectedTags = tagMap.keys.take(5).toSet();
            _assignColors();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Error al carregar estadístiques';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Error del servidor: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de connexió: $e';
        _isLoading = false;
      });
    }
  }

  /// Alternar selecció d'una etiqueta
  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  /// Seleccionar totes les etiquetes
  void _selectAll() {
    setState(() {
      _selectedTags = _tagData.keys.toSet();
    });
  }

  /// Deseleccionar totes les etiquetes
  void _deselectAll() {
    setState(() {
      _selectedTags = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Estadístiques d\'Etiquetes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualitzar',
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStats,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _tagData.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No hi ha dades d\'etiquetes',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Envia imatges per analitzar i generar etiquetes',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        // Barra lateral amb etiquetes
                        _buildSidebar(),
                        // Gràfic principal
                        Expanded(child: _buildChart()),
                      ],
                    ),
    );
  }

  /// Construir la barra lateral amb les etiquetes
  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Capçalera
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Etiquetes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedTags.length} de ${_tagData.length} seleccionades',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          // Botons seleccionar/deseleccionar tot
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: _selectAll,
                    icon: const Icon(Icons.check_box, size: 16),
                    label: const Text('Tot', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: _deselectAll,
                    icon: const Icon(Icons.check_box_outline_blank, size: 16),
                    label: const Text('Cap', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Llista d'etiquetes
          Expanded(
            child: ListView.builder(
              itemCount: _tagData.length,
              itemBuilder: (context, index) {
                final tag = _tagData.keys.elementAt(index);
                final count = _tagData[tag]!;
                final color = _tagColors[tag] ?? Colors.grey;
                final isSelected = _selectedTags.contains(tag);

                return ListTile(
                  dense: true,
                  leading: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.transparent,
                      border: Border.all(color: color, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  title: Text(
                    tag,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.black : Colors.grey.shade600,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.15) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        color: isSelected ? color : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () => _toggleTag(tag),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construir el gràfic de barres amb CustomPainter
  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Títol del gràfic
          Row(
            children: [
              const Icon(Icons.bar_chart, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Comparativa d\'Etiquetes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_tagData.values.fold(0, (a, b) => a + b)} anàlisis totals',
                  style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Gràfic
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: TagBarChartPainter(
                tagData: _tagData,
                tagColors: _tagColors,
                selectedTags: _selectedTags,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
