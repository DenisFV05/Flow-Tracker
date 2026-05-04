import 'package:flutter/material.dart';
import '../sidebar.dart';
import '../screens.dart';
import '../utils.dart';
import 'package:sidebarx/sidebarx.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  static const _titles = [
    'Dashboard',
    'Estadístiques',
    'Feed',
    'Amics',
    'Perfil',
  ];

  static const _icons = [
    Icons.dashboard_rounded,
    Icons.bar_chart_rounded,
    Icons.feed_rounded,
    Icons.people_rounded,
    Icons.person_rounded,
  ];

  String _getTitle(int index) {
    if (index >= 0 && index < _titles.length) {
      return _titles[index];
    }
    return 'Flow Tracker';
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      key: _key,
      appBar: isSmallScreen
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFF1E88E5),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getTitle(_controller.selectedIndex),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
              leading: IconButton(
                onPressed: () => _key.currentState?.openDrawer(),
                icon: const Icon(Icons.menu, color: Colors.black87),
              ),
            )
          : null,
      drawer: ExampleSidebarX(controller: _controller),
      body: Row(
        children: [
          if (!isSmallScreen)
            ExampleSidebarX(controller: _controller),
          Expanded(
            child: ScreensExample(controller: _controller),
          ),
        ],
      ),
    );
  }
}
