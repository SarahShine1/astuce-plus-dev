import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/search_page.dart';
import 'package:frontend/pages/post_page.dart';
import '../pages/saved_page.dart';
import '../pages/profile_page.dart';
import '../widgets/custom_bottom_navbar.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages =  [
    HomePage(),
    SearchPage(),
    PostPage(), // ✅ ta page de partage
    SavedPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // ✅ affichage dynamique
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
