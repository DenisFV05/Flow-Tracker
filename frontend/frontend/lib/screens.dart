import 'package:flowTracker/views/perfilView.dart';
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

import 'views/dashboardView.dart';
import 'views/feedView.dart';
import 'views/amicsView.dart';
import 'views/opcionsView.dart';

class ScreensExample extends StatelessWidget {
  const ScreensExample({super.key, required this.controller});

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        switch (controller.selectedIndex) {
          case 0: return const DashboardView();
          case 1: return const FeedView();
          case 2: return const AmicsView();
          case 3: return const OpcionsView();
          case 4: return const perfilView();
          default: return const Center(child: Text('Not found'));
        }
      },
    );
  }
}
