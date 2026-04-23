import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habitsProvider.dart';

class FeedView extends StatelessWidget {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dynamic_feed, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text("El feed dels teus amics"),
            const SizedBox(height: 8),
            const Text(
              "quan els teus amics completin hàbits,\nho veuràs aquí",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}