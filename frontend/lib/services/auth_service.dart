import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // 🔹 For Android Emulator use 10.0.2.2
  //static const String baseUrl = 'http://10.0.2.2:8000/api/users';
  // 🔹 For real device, use your computer's IP (e.g., 192.168.1.XXX)
  static const String baseUrl = 'http://192.168.137.1:8000/api/users';


  
  // 🟢 Register - matches your Django register endpoint
  Future<http.Response> register({
    required String username,
    required String email,
    required String password,
    String? password2,
    String? nom,
    int? age,
  }) async {
    final url = Uri.parse('$baseUrl/register/');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'nom': nom,
          'age': age,
        }),
      );
      
      return response;
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // 🟢 Login - matches your Django login endpoint
  Future<http.Response> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login/');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      return response;
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // 🟢 Get User Profile
  Future<http.Response> getProfile(String accessToken) async {
    final url = Uri.parse('$baseUrl/profile/');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      
      return response;
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // 🟢 Update Profile
  Future<http.Response> updateProfile(String accessToken, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/profile/');
    
    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(data),
      );
      
      return response;
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // 🟢 Get All Users
  Future<http.Response> getAllUsers(String accessToken) async {
    final url = Uri.parse('$baseUrl/users/');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      
      return response;
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // 🟢 Get Single User by ID
  Future<http.Response> getUserById(String accessToken, int userId) async {
    final url = Uri.parse('$baseUrl/users/$userId/');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      
      return response;
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // 🟢 Refresh Token
  Future<http.Response> refreshToken(String refreshToken) async {
    final url = Uri.parse('$baseUrl/refresh/');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );
      
      return response;
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}
