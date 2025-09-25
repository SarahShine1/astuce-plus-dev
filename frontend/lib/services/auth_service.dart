import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://10.0.2.2:8000/api/auth"; // pour émulateur Android
  // si tu testes avec ton téléphone : mets l’IP de ton PC

  // 🔑 Inscription
  Future<http.Response> register(String username, String email, String password) async {
    final url = Uri.parse("$baseUrl/register/");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );
  }

  // 🔑 Connexion
  Future<http.Response> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/login/");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );
  }

  // 🔄 Rafraîchir le token
  Future<http.Response> refresh(String refreshToken) async {
    final url = Uri.parse("$baseUrl/refresh/");
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refresh": refreshToken}),
    );
  }
}
