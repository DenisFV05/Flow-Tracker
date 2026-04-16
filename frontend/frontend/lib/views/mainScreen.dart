import 'package:flutter/material.dart';
import '../sidebar.dart';
import '../screens.dart';
import '../utils.dart';
import 'package:sidebarx/sidebarx.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      key: _key,
      appBar: isSmallScreen
          ? AppBar(
              backgroundColor: canvasColor,
              title: Text(getTitleByIndex(_controller.selectedIndex)),
              leading: IconButton(
                onPressed: () => _key.currentState?.openDrawer(),
                icon: const Icon(Icons.menu),
              ),
            )
          : null,
      drawer: ExampleSidebarX(controller: _controller),
      body: Row(
        children: [
          if (!isSmallScreen)
            ExampleSidebarX(controller: _controller),
          Expanded(
            child: Center(
              child: ScreensExample(controller: _controller),
            ),
          ),
        ],
      ),
    );
  }
}
