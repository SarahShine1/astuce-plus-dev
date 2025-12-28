import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../pages/home_page.dart';
import '../pages/search_page.dart';
import 'package:frontend/pages/post_page.dart';
import '../pages/saved_page.dart';
import '../pages/profile_page.dart';
import '../widgets/custom_bottom_navbar.dart';
import 'package:frontend/pages/dictinary_page.dart';
import 'package:frontend/services/UserService.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0;
  final storage = const FlutterSecureStorage();
  final UserService _userService = UserService();
  
  // User data
  String? username;
  String? userEmail;
  String? userAvatar;
  bool isGuest = true;
  bool isAdmin = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final accessToken = await storage.read(key: 'access_token');
      
      if (accessToken != null && accessToken.isNotEmpty) {
        // User is authenticated
        final profileData = await _userService.getProfile(accessToken);
        
        if (profileData != null) {
          setState(() {
            username = profileData['username'] ?? 'Utilisateur';
            userEmail = profileData['email'];
            isGuest = false;
            isAdmin = profileData['role'] == 'moderateur' || 
                     profileData['is_staff'] == true;
            isLoading = false;
          });
          
          // Save username for later use
          await storage.write(key: 'username', value: username);
        } else {
          // Token might be invalid
          _setGuestMode();
        }
      } else {
        // No token, guest mode
        _setGuestMode();
      }
    } catch (e) {
      print("❌ Error loading user data: $e");
      _setGuestMode();
    }
  }

  void _setGuestMode() {
    setState(() {
      username = 'Invité';
      isGuest = true;
      isAdmin = false;
      isLoading = false;
    });
  }

  List<Widget> get _pages => [
    HomePage(
      userName: username,
      userAvatar: userAvatar,
      isGuest: isGuest,
      isAdmin: isAdmin,
    ),
    DictionaryPage(),
    PostPage(),
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
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}