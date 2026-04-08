import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'utils.dart';

class ExampleSidebarX extends StatelessWidget { //https://pub.dev/packages/sidebarx/example
  const ExampleSidebarX({Key? key, required this.controller}) : super(key: key);

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
          gradient: const LinearGradient(
            colors: [accentCanvasColor, canvasColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
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
                  child: Image.asset('assets/images/placeholder.png'),

        ),
      ),
      items: [
        SidebarXItem(icon: Icons.dashboard, label: 'Dashboard', onTap: () => debugPrint('Home')),
        const SidebarXItem(icon: Icons.feed_outlined, label: 'Feed'),
        const SidebarXItem(icon: Icons.people, label: 'Amics'),
        const SidebarXItem(icon: Icons.settings,label: 'Opcions'),

      ],
    );
  }

}
