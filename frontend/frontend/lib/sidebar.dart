import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
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
          color: const Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: const Color(0xFF2A3547),
        textStyle: const TextStyle(color: Color(0xFF90A4AE)),
        selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        hoverTextStyle: const TextStyle(color: Colors.white),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF1976D2)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E88E5).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF90A4AE),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 220,
        decoration: BoxDecoration(color: Color(0xFF1A2332)),
      ),
      footerDivider: Divider(color: Colors.white.withOpacity(0.1), height: 1),
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E88E5), Color(0xFF1976D2)],
                    ),
                    borderRadius: BorderRadius.circular(extended ? 12 : 8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E88E5).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: extended ? 35 : 25,
                  ),
                ),
                if (extended) const SizedBox(width: 8),
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
      items: const [
        SidebarXItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
        SidebarXItem(icon: Icons.bar_chart_rounded, label: 'Estadístiques'),
        SidebarXItem(icon: Icons.feed_rounded, label: 'Feed'),
        SidebarXItem(icon: Icons.people_rounded, label: 'Amics'),
        SidebarXItem(icon: Icons.person_rounded, label: 'Perfil'),
      ],
      footerItems: [
        SidebarXItem(
          icon: Icons.logout_rounded,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tancar sessió', style: TextStyle(color: Color(0xFF1A2332))),
        content: const Text('Segur que vols tancar la sessió?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel·lar', style: TextStyle(color: Color(0xFF1E88E5))),
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
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tancar'),
          ),
        ],
      ),
    );
  }
}
