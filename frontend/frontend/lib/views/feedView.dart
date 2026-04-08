import 'package:flutter/material.dart';
import '../utils.dart'; 


class FeedView extends StatelessWidget {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: 20,
      itemBuilder: (context, index) => Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
