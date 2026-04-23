import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habitsProvider.dart';
import '../utils/storage.dart';
import 'login_screen.dart';
import 'dashboardView.dart';
import 'amicsView.dart';
import 'feedView.dart';
import 'opcionsView.dart';

class HomeScreen extends StatefulWidget {
  final String serverUrl;
  final String token;

  const HomeScreen({
    super.key,
    required this.serverUrl,
    required this.token,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HabitProvider>(
      create: (_) => HabitProvider()..init(widget.serverUrl, widget.token),
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            const DashboardView(),
            const AmicsView(),
            const FeedView(),
            OpcionsView(onLogout: _logout),
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
      ),
    );
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
}