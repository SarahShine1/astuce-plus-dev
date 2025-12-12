import 'package:flutter/material.dart';
import 'package:frontend/pages/signup_page.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/forgot_password_page.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:frontend/components/navbar.dart'; // Si MainNavigationWrapper est dans navbar.dart


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController(); // Changed from email
  final TextEditingController passwordController = TextEditingController();
  final storage = const FlutterSecureStorage(); // For secure token storage
  bool _rememberMe = false;
  bool _isLoading = false;

  void _login() async {
    String username = usernameController.text.trim(); // Changed from email
    String password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService().login(username, password);

      if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  String accessToken = data["access"];
  String refreshToken = data["refresh"];
  Map<String, dynamic> user = data["user"];

  // Save tokens securely
  await storage.write(key: 'access_token', value: accessToken);
  await storage.write(key: 'refresh_token', value: refreshToken);
  await storage.write(key: 'user_data', value: jsonEncode(user));

  if (_rememberMe) {
    await storage.write(key: 'remember_me', value: 'true');
  }

  print("✅ Login success for user: ${user['username']}");

  if (!mounted) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Bienvenue ${user['username']}!")),
  );

  // 🚀 Navigation vers MainNavigationWrapper (avec navbar)
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (context) => MainNavigationWrapper(),
  ),
  (route) => false, // Supprime toutes les routes précédentes
);
} else {
        final errorData = jsonDecode(response.body);
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${errorData['error'] ?? 'Connexion échouée'}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _signInWithGoogle() {
    print("Connexion avec Google");
    // Implement Google authentication logic here
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          focusColor: Color(0xFF053F5C),
          labelStyle: TextStyle(color: Color(0xFF053F5C)),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF053F5C),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Se connecter",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF053F5C),
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SignupPage()),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: "Vous n'avez pas de compte ? ",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                            children: [
                              TextSpan(
                                text: "S'inscrire",
                                style: TextStyle(
                                  color: Color(0xFFF7AD19),
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Changed to Username field
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: "Nom d'utilisateur",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF053F5C), width: 2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Mot de passe",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF053F5C), width: 2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                activeColor: const Color(0xFFF7AD19),
                              ),
                              const Text(
                                "Se souvenir de moi",
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
                                );
                              },
                              child: const Text(
                                "Mot de passe oublié ?",
                                style: TextStyle(
                                  color: Color(0xFFF7AD19),
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Login button with loading indicator
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: const Color(0xFFF7AD19),
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Se connecter"),
                      ),
                      const SizedBox(height: 15),

                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "OU",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 15),

                      OutlinedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: const Icon(Icons.account_circle, color: Colors.red),
                        label: const Text(
                          "Continuer avec Google",
                          style: TextStyle(color: Colors.black87),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
