import 'package:flutter/material.dart';

class QuickStats extends StatelessWidget {
  const QuickStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total habits tracked: ",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text("4", style: TextStyle(fontWeight: FontWeight.bold)),

          SizedBox(height: 10),

          Text("Completed today: ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              )),
          Text("2/4",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              )),

          SizedBox(height: 10),

          Text("This week: ",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text("21/28",
              style: TextStyle(fontWeight: FontWeight.bold)),

          SizedBox(height: 10),

          Text("This month: ",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text("89/112",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
