import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'utils.dart';

class ExampleSidebarX extends StatelessWidget { //https://pub.dev/packages/sidebarx/example
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
          // gradient: const LinearGradient(
          //   colors: [accentCanvasColor, canvasColor],
          // ),
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
            ],
          ),
          
        ),
      ),
    ),
      items: [
        SidebarXItem(icon: Icons.dashboard, label: 'Dashboard', onTap: () => debugPrint('Home')),
        const SidebarXItem(icon: Icons.feed_outlined, label: 'Feed'),
        const SidebarXItem(icon: Icons.people, label: 'Amics'),
        const SidebarXItem(icon: Icons.settings,label: 'Opcions'),
        const SidebarXItem(icon: Icons.person,label: 'Perfil'),

      ],
    );
  }

}
