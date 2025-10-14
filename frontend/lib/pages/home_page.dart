import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Bienvenue sur la page d’accueil 👋',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
