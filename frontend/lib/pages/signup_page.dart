import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _acceptTerms = false;

  void _signup() async {
    String name = nameController.text;
    String birthDate = birthDateController.text;
    String email = emailController.text;
    String password = passwordController.text;

    if (name.isNotEmpty && birthDate.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      bool success = await ApiService.register(
        name: name,
        email: email,
        password: password,
        birthDate: birthDate,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Inscription réussie 🎉")),
        );
        Navigator.pop(context); // retour à login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de l’inscription ❌")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
    }
  }


  void _signUpWithGoogle() {
    print("Inscription avec Google");
    // Implémentez ici la logique d'authentification Google
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF7AD19),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      birthDateController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
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
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 350),
                  padding: const EdgeInsets.all(16),
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
                        "S'inscrire",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF053F5C),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Lien vers Connexion
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: "Vous avez déjà un compte ? ",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: "Se connecter",
                                style: TextStyle(
                                  color: Color(0xFFF7AD19),
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Champ Nom complet
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Nom complet",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF053F5C), width: 2.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Champ Email
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF053F5C), width: 2.0),
                          ),
                          prefixIcon: Icon(Icons.email, color: Color(0xFF053F5C)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Champ Date de naissance
                      TextField(
                        controller: birthDateController,
                        readOnly: true,
                        onTap: _selectDate,
                        decoration: const InputDecoration(
                          labelText: "Date de naissance",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF053F5C), width: 2.0),
                          ),
                          suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF053F5C)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 12),



                      // Champ Mot de passe
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Mot de passe",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF053F5C), width: 2.0),
                          ),
                          prefixIcon: Icon(Icons.lock, color: Color(0xFF053F5C)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 12),

// Champ Confirmation mot de passe
                      TextField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Confirmer le mot de passe",
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF053F5C), width: 2.0),
                          ),
                          prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF053F5C)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: (value) {
                          if (value != passwordController.text) {
                            // tu peux afficher un message ou changer la couleur de bordure plus tard
                            print("Les mots de passe ne correspondent pas");
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                /*      // Accepter les conditions
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (bool? value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFFF7AD19),
                          ),
                          const Expanded(
                            child: Text(
                              "J'accepte les conditions d'utilisation",
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),*/

                      // Bouton Inscription
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF7AD19),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "S'inscrire",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

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
                      const SizedBox(height: 12),

                      // Bouton Google
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: OutlinedButton.icon(
                          onPressed: _signUpWithGoogle,
                          icon: const Icon(
                            Icons.account_circle,
                            color: Colors.red,
                          ),
                          label: const Text(
                            "S'inscrire avec Google",
                            style: TextStyle(color: Colors.black87),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
    }
}