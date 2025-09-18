import 'package:flutter/material.dart';
import 'package:frontend/pages/welcome_page.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:frontend/components/navbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home:  MainNavigationWrapper()// ✅ no const here
    );
  }
}
