import 'package:flutter/material.dart';

import '../widgets/home/body.dart';

import '../widgets/navBar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Body(),
      // bottomNavigationBar: NavBar(),
    );
  }
}
