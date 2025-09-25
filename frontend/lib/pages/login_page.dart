import 'package:flutter/material.dart';
import 'package:frontend/pages/signup_page.dart';
import 'package:frontend/pages/forgot_password_page.dart';
import 'package:frontend/services/auth_service.dart';
import 'dart:convert';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _rememberMe = false;

  void _login() async {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        final response = await AuthService().login(email, password);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          String accessToken = data["access"];
          String refreshToken = data["refresh"];

          // 👉 Here you could save tokens securely with flutter_secure_storage
          print("✅ Login success: $accessToken");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Connexion réussie")),
          );

          // Example: Navigate to home page
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur: ${response.body}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de connexion: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
    }
  }


  void _signInWithGoogle() {
    print("Connexion avec Google");
    // Implémentez ici la logique d'authentification Google
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
                        // Titre principal
                        const Text(
                          "Se connecter",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF053F5C),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Lien vers Inscription avec style personnalisé
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => SignupPage()));
                          },
                          child: RichText(
                            text: const TextSpan(
                              text: "Vous n'avez pas de compte ? ",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
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

                        // Champ Email avec bordure bleue au focus
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF053F5C), width: 2.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Champ Mot de passe avec bordure bleue au focus
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

                        // Se souvenir de moi et Mot de passe oublié
                        Column(
                          children: [
                            // Se souvenir de moi
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
                            // Mot de passe oublié
                            Align(
                              alignment: Alignment.center,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => ForgotPasswordPage())
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

                        // Bouton Connexion
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: const Color(0xFFF7AD19),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Se connecter"),
                        ),
                        const SizedBox(height: 15),

                        // Divider avec "OU"
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

                        // Bouton Google
                        OutlinedButton.icon(
                          onPressed: _signInWithGoogle,
                          icon: const Icon(
                            Icons.account_circle,
                            color: Colors.red,
                          ),
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
        ) );
    }
}