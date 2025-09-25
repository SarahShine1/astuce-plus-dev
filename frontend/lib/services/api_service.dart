import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api"; // pour Android Emulator
  // Si tu testes sur un vrai téléphone : mets ton IP locale (ex: 192.168.1.10)

  static Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String birthDate,
  }) async {
    final url = Uri.parse("$baseUrl/auth/register/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": name,
        "email": email,
        "password": password,
        "birth_date": birthDate,
      }),
    );

    if (response.statusCode == 201) {
      return true; // inscrit avec succès
    } else {
      print("Erreur ${response.statusCode}: ${response.body}");
      return false;
    }
  }
}
