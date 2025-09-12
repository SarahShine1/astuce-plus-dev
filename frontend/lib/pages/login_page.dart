import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login() {
    String email = emailController.text;
    String password = passwordController.text;

    // Pour l'instant on fait un print, plus tard tu connecteras au backend
    if (email.isNotEmpty && password.isNotEmpty) {
      print("Email: $email | Password: $password");
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF053F5C),
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Champ Email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Champ Mot de passe
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mot de passe",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Bouton Connexion
            ElevatedButton(
              onPressed: _login,
              child: const Text("Se connecter"),
            ),

            const SizedBox(height: 10),

            // Lien vers Inscription
            TextButton(
              onPressed: () {
                // Tu pourras ajouter une navigation vers RegisterPage
                print("Aller vers la page d'inscription");
              },
              child: const Text("Pas encore de compte ? Inscrivez-vous"),
            ),
          ],
        ),
      ),
    );
  }
}
