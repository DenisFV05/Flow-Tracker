import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habitsProvider.dart';
import '../utils/settings_manager.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final settings = await SettingsManager.loadSettings();
    final serverUrl = settings['serverUrl'] ?? 'http://localhost:3000';
    final token = settings['token'];

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      final provider = HabitProvider()..init(serverUrl, token);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: provider,
            child: HomeScreen(serverUrl: serverUrl, token: token),
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Flow Tracker'),
          ],
        ),
      ),
    );
  }
}