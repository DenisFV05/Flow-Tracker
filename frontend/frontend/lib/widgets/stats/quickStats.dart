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
          Text("Habits totals rastrejats: ",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text("4", style: TextStyle(fontWeight: FontWeight.bold)),

          SizedBox(height: 10),

          Text("Completats avui: ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              )),
          Text("2/6",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              )),

          SizedBox(height: 10),

          Text("Aquesta setmana: ",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text("20/30",
              style: TextStyle(fontWeight: FontWeight.bold)),

          SizedBox(height: 10),

          Text("Aquest mes: ",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text("100/112",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
