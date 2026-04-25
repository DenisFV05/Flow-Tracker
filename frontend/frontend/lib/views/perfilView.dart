import 'package:flutter/material.dart';


class perfilView extends StatelessWidget {
  const perfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Perfil',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}