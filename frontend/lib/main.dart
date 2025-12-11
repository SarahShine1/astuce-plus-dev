import 'package:flutter/material.dart';
import 'package:frontend/pages/dictinary_page.dart';
import 'package:frontend/pages/edit_profile_page.dart';
import 'package:frontend/pages/forgot_password_page.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/onloading_page.dart';
import 'package:frontend/pages/post_page.dart';
import 'package:frontend/pages/saved_page.dart';
import 'package:frontend/pages/signup_page.dart';
import 'package:frontend/pages/welcome_page.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:frontend/components/navbar.dart';
import 'package:frontend/pages/profile_setup_page.dart';
import 'package:frontend/pages/astuce_page.dart';
import 'package:frontend/pages/experts/dashboard.dart';

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
      home: OnloadingPage(), // ✅ Ajoute le username ici


    );
  }
}
