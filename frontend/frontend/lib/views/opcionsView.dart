import 'package:flutter/material.dart';


class OpcionsView extends StatelessWidget {
  const OpcionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Opcions',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}