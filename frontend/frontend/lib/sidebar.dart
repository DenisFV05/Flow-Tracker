import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'utils.dart';
import 'config/app_config.dart';
import 'views/login_screen.dart';

class ExampleSidebarX extends StatelessWidget {
  const ExampleSidebarX({super.key, required this.controller});

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: scaffoldBackgroundColor,
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        hoverTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: canvasColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: actionColor.withOpacity(0.37),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
          color: canvasColor,
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(width: 200, decoration: BoxDecoration(color: canvasColor)),
      footerDivider: divider,
      headerBuilder: (context, extended) => SizedBox(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(extended ? 8 : 4),
                  decoration: BoxDecoration(
                    color: bgIcons,
                    borderRadius: BorderRadius.circular(extended ? 12 : 8),
                  ),
                  child: Icon(
                    Icons.local_fire_department_outlined,
                    color: white,
                    size: extended ? 35 : 25,
                  ),
                ),
                if (extended)
                  const SizedBox(width: 8),
                if (extended)
                  const Text(
                    'Flow Tracker',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      items: [
        const SidebarXItem(icon: Icons.dashboard, label: 'Dashboard'),
        const SidebarXItem(icon: Icons.bar_chart, label: 'Estadístiques'),
        const SidebarXItem(icon: Icons.feed_outlined, label: 'Feed'),
        const SidebarXItem(icon: Icons.people, label: 'Amics'),
        const SidebarXItem(icon: Icons.person, label: 'Perfil'),
      ],
      footerItems: [
        SidebarXItem(
          icon: Icons.logout,
          label: 'Tancar sessió',
          onTap: () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tancar sessió'),
        content: const Text('Segur que vols tancar la sessió?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel·lar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AppConfig.instance.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tancar'),
          ),
        ],
      ),
    );
  }
}
