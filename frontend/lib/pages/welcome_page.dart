import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/pages/onloading_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();

    // Wait 3 seconds then navigate to OnloadingPage
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnloadingPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF053F5C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.star, size: 80, color: Colors.amber),
            SizedBox(height: 20),
            Text(
              'Bienvenue sur Astuce+',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 36.0),
              child: Text(
                'Vos astuces pratiques au quotidien',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.amber),
          ],
        ),

      ),
    );
  }
}

