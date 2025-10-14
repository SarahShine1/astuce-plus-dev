import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/pages/profile_setup_page.dart';
import 'dart:async';


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
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _signup() async {
    String name = nameController.text.trim();
    String birthDate = birthDateController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || birthDate.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("Veuillez remplir tous les champs");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Les mots de passe ne correspondent pas");
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success = await ApiService.register(
        name: name,
        email: email,
        password: password,
        birthDate: birthDate,
      ).timeout(const Duration(seconds: 10)); // ✅ évite blocage infini

      setState(() => _isLoading = false);

      if (success) {
        _showSnackBar("Inscription réussie 🎉");
        Navigator.pushReplacementNamed(context, '/home'); // ✅ Navigation directe vers Home
      } else {
        _showSnackBar("Échec de l’inscription ❌");
      }
    } on TimeoutException {
      setState(() => _isLoading = false);
      _showSnackBar("Le serveur ne répond pas. Réessayez plus tard.");
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Erreur : $e");
    }
  }


  void _signUpWithGoogle() {
    print("Inscription avec Google");
    // À implémenter plus tard
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
            colorScheme: const ColorScheme.light(primary: Color(0xFFF7AD19)),
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
          labelStyle: TextStyle(color: Color(0xFF053F5C)),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF053F5C),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 350),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "S'inscrire",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF053F5C),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bouton vers connexion
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text.rich(
                      TextSpan(
                        text: "Vous avez déjà un compte ? ",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
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

                  // Champs
                  _buildTextField(
                    controller: nameController,
                    label: "Nom complet",
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: emailController,
                    label: "Email",
                    icon: Icons.email,
                    inputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: birthDateController,
                    label: "Date de naissance",
                    icon: Icons.calendar_today,
                    readOnly: true,
                    onTap: _selectDate,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: passwordController,
                    label: "Mot de passe",
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: confirmPasswordController,
                    label: "Confirmer le mot de passe",
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),

                  // Bouton Inscription
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7AD19),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "S'inscrire",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // OU
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "OU",
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
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
                      icon: const Icon(Icons.account_circle, color: Colors.red),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool obscureText = false,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF053F5C), width: 2.0),
        ),
        prefixIcon: icon != null ? Icon(icon, color: Color(0xFF053F5C)) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
