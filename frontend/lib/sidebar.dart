import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'views/login_screen.dart';

class ExampleSidebarX extends StatelessWidget {
  const ExampleSidebarX({super.key, required this.controller});

  final SidebarXController controller;

  static const double _expandedWidth = 260;
  static const double _collapsedWidth = 70;

  static const _items = [
    (icon: Icons.dashboard_rounded, label: 'Dashboard'),
    (icon: Icons.bar_chart_rounded, label: 'Estadístiques'),
    (icon: Icons.feed_rounded, label: 'Feed'),
    (icon: Icons.notifications_rounded, label: 'Notificacions'),
    (icon: Icons.people_rounded, label: 'Amics'),
    (icon: Icons.person_rounded, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final extended = controller.extended;
        final width = extended ? _expandedWidth : _collapsedWidth;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          height: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              color: context.sidebarColor,
              borderRadius: BorderRadius.zero,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                SizedBox(
                  height: 140,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(extended ? 10 : 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primaryDark],
                              ),
                              borderRadius: BorderRadius.circular(extended ? 14 : 10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.local_fire_department_rounded,
                              color: context.onSidebarColor,
                              size: extended ? 38 : 28,
                            ),
                          ),
                          if (extended) const SizedBox(width: 12),
                          if (extended)
                            Text(
                              'Flow Tracker',
                              style: TextStyle(
                                color: context.onSidebarColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Items (scrolling if needed but usually fits) ──
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(_items.length, (index) {
                        final item = _items[index];
                        final selected = controller.selectedIndex == index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _SidebarItem(
                            icon: item.icon,
                            label: item.label,
                            selected: selected,
                            extended: extended,
                            onTap: () => controller.selectIndex(index),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                // ── Footer divider ──
                Divider(color: context.onSidebarColor.withOpacity(0.1), height: 1),

                // ── Logout ──
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _SidebarItem(
                    icon: Icons.logout_rounded,
                    label: 'Tancar sessió',
                    selected: false,
                    extended: extended,
                    onTap: () => _showLogoutDialog(context),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Tancar sessió', style: TextStyle(color: context.textPrimaryColor)),
        content: const Text('Segur que vols tancar la sessió?'),
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
            child: const Text('Tancar'),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
            decoration: widget.selected
                ? BoxDecoration(
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
                        offset: const Offset(0, 2),
                      ),
                    ],
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _hovered ? const Color(0xFF2A3547) : Colors.transparent,
                  ),
            child: Row(
              mainAxisAlignment: widget.extended ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 22,
                  color: widget.selected
                      ? context.onSidebarColor
                      : const Color(0xFF90A4AE),
                ),
                if (widget.extended) ...[
                  const SizedBox(width: 25),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.selected
                            ? context.onSidebarColor
                            : const Color(0xFF90A4AE),
                        fontWeight: widget.selected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
