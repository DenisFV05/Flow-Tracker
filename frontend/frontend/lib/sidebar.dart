import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'views/login_screen.dart';

class ExampleSidebarX extends StatelessWidget {
  const ExampleSidebarX({super.key, required this.controller});

  final SidebarXController controller;

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: controller,
      theme: SidebarXTheme(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.sidebarColor,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: Color(0xFF2A3547),
        textStyle: TextStyle(color: Color(0xFF90A4AE)),
        selectedTextStyle: TextStyle(color: context.onSidebarColor, fontWeight: FontWeight.w600),
        hoverTextStyle: TextStyle(color: context.onSidebarColor),
        itemTextPadding: EdgeInsets.only(left: 30),
        selectedItemTextPadding: EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        iconTheme: IconThemeData(
          color: Color(0xFF90A4AE),
          size: 20,
        ),
        selectedIconTheme: IconThemeData(
          color: context.onSidebarColor,
          size: 20,
        ),
      ),
      extendedTheme: SidebarXTheme(
        width: 220,
        decoration: BoxDecoration(color: context.sidebarColor),
      ),
      footerDivider: Divider(color: context.onSidebarColor.withOpacity(0.1), height: 1),
      headerBuilder: (context, extended) => SizedBox(
        height: 100,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(extended ? 8 : 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(extended ? 12 : 8),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: context.onSidebarColor,
                    size: extended ? 35 : 25,
                  ),
                ),
                if (extended) SizedBox(width: 8),
                if (extended)
                  Text(
                    'Flow Tracker',
                    style: TextStyle(
                      color: context.onSidebarColor,
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
        title: Text('Tancar sessió', style: TextStyle(color: context.textPrimaryColor)),
        content: Text('Segur que vols tancar la sessió?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel·lar', style: TextStyle(color: AppTheme.primary)),
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
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Tancar'),
          ),
        ],
      ),
    );
  }
}
