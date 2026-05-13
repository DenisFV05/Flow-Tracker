import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../sidebar.dart';
import '../screens.dart';
import 'package:sidebarx/sidebarx.dart';
import '../providers/notifications_provider.dart';
import 'notificationsView.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  static const _titles = [
    'Dashboard',
    'Estadístiques',
    'Feed',
    'Notificacions',
    'Amics',
    'Perfil',
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
              backgroundColor: context.surfaceColor,
              elevation: 0,
              title: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: AppTheme.primary,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        _getTitle(_controller.selectedIndex),
                        style: TextStyle(
                          color: context.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
              leading: IconButton(
                onPressed: () => _key.currentState?.openDrawer(),
                icon: Icon(Icons.menu, color: context.textPrimaryColor),
              ),
              actions: [
                Consumer<NotificationsProvider>(
                  builder: (context, notifProvider, _) {
                    final count = notifProvider.unreadCount;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications, color: context.textPrimaryColor),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => NotificationsView()),
                            );
                          },
                        ),
                        if (count > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  count > 9 ? '9+' : '$count',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
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
