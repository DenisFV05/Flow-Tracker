import 'package:flutter/material.dart';
import 'StatCard.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: StatCard(title: "Current Streak", value: "12")),
        SizedBox(width: 10),
        Expanded(child: StatCard(title: "Today Progress", value: "2/4")),
        SizedBox(width: 10),
        Expanded(child: StatCard(title: "Weekly Rate", value: "78%")),
        SizedBox(width: 10),
        Expanded(child: StatCard(title: "Achievements", value: "8")),
      ],
    );
  }
}
