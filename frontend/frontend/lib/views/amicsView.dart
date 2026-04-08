import 'package:flutter/material.dart';
import '../utils.dart'; 

class AmicsView extends StatelessWidget {
  const AmicsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Amics',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
