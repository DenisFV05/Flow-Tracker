import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habitsProvider.dart';
import '../services/api_service.dart';
import '../utils/storage.dart';
import 'login_screen.dart';
import 'dashboardView.dart';
import 'amicsView.dart';
import 'feedView.dart';
import 'opcionsView.dart';

class HomeScreen extends StatefulWidget {
  final String serverUrl;

  const HomeScreen({super.key, required this.serverUrl});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadHabits();
    });
  }

  Future<void> _logout() async {
    await Storage.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardView(serverUrl: widget.serverUrl),
          const AmicsView(),
          const FeedView(),
          const OpcionsView(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Avui'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Amics'),
          NavigationDestination(icon: Icon(Icons.dynamic_feed), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Perfil'),
        ],
      ),
    );
  }
}