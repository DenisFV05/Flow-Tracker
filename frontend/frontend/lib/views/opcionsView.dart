import 'package:flowTracker/models/themeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/habitsProvider.dart';
import '../models/themeProvider.dart';

class Opcionsview extends StatelessWidget {
  const Opcionsview({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Aparença',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.light_mode),
                  Switch(
                    value: provider.isDarkMode,
                    onChanged: (value) => provider.toggleTheme(value),
                  ),
                  const Icon(Icons.dark_mode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
