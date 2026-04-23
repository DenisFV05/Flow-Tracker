import 'package:flutter/material.dart';

class HabitDetailView extends StatelessWidget {
  final dynamic habit;

  const HabitDetailView({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    final tags = habit['tags'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(habit['name'] ?? 'Detalls habits'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              habit['name'] ?? '',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              habit['description'] ?? 'Sense descripció',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Progres",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: 0.5, 
              minHeight: 10,
              color: Colors.orange,

            ),

            const SizedBox(height: 30),

            const Text(
              "Tags",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              children: tags.isNotEmpty
                  ? tags.map<Widget>((tag) {
                      return Chip(
                        label: Text(
                          tag['name'] ?? tag.toString(),
                        ),
                      );
                    }).toList()
                  : [
                      const Chip(label: Text("Sense tags")),
                    ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                },
                child: const Text("Marcar com feta"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
