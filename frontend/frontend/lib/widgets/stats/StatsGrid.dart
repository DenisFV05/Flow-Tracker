import 'package:flutter/material.dart';
import 'StatCard.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: StatCard(title: "Ratxa actual", value: "1")),
        SizedBox(width: 10),
        Expanded(child: StatCard(title: "Progres d'avui", value: "2/6")),
        SizedBox(width: 10),
        Expanded(child: StatCard(title: "Ritme Setmanal", value: "50%")),
        SizedBox(width: 10),
        Expanded(child: StatCard(title: "Assoliments", value: "8")),
      ],
    );
  }
}
