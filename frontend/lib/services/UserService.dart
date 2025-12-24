import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UserService {
  // Replace with your actual backend URL
  //static const String baseUrl = 'http://10.0.2.2:8000/api/users';
  static const String baseUrl = 'http://192.168.137.1:8000/api/users';
  
  /// Update user profile
  Future<Map<String, dynamic>?> updateProfile({
    required String accessToken,
    String? nom,
    String? email,
    String? bio,
    String? phone,
    int? age,
    String? centresInteret,
    File? avatarFile,
  }) async {
    try {
      // Si avatarFile est fourni, utiliser multipart
      if (avatarFile != null) {
        var request = http.MultipartRequest('PATCH', Uri.parse('$baseUrl/profile/'))
          ..headers['Authorization'] = 'Bearer $accessToken';

        if (nom != null) request.fields['nom'] = nom;
        if (email != null) request.fields['email'] = email;
        if (bio != null) request.fields['bio'] = bio;
        if (phone != null) request.fields['phone'] = phone;
        if (age != null) request.fields['age'] = age.toString();
        if (centresInteret != null) request.fields['centres_interet'] = centresInteret;

        request.files.add(
          await http.MultipartFile.fromPath(
            'avatar',
            avatarFile.path,
          ),
        );

        var response = await request.send();
        print('📤 Update Profile Response: ${response.statusCode}');

        var responseBody = await response.stream.bytesToString();
        print('📄 Response Body: $responseBody');

        if (response.statusCode == 200) {
          return jsonDecode(responseBody);
        } else {
          print('❌ Update failed: $responseBody');
          return null;
        }
      } else {
        // Sans avatar, utiliser JSON
        final Map<String, dynamic> body = {};
        
        if (nom != null) body['nom'] = nom;
        if (email != null) body['email'] = email;
        if (bio != null) body['bio'] = bio;
        if (phone != null) body['phone'] = phone;
        if (age != null) body['age'] = age;
        if (centresInteret != null) body['centres_interet'] = centresInteret;
        
        final response = await http.patch(
          Uri.parse('$baseUrl/profile/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(body),
        );
        
        print('📤 Update Profile Response: ${response.statusCode}');
        print('📄 Response Body: ${response.body}');
        
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          print('❌ Update failed: ${response.body}');
          return null;
        }
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      return null;
    }
  }
  
  /// Get user's created astuces
  Future<List<dynamic>?> getUserAstuces(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/astuces/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      
      print('📤 Get User Astuces Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        print('❌ Failed to get astuces: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting user astuces: $e');
      return null;
    }
  }
  
  /// Get user's evaluations
  Future<List<dynamic>?> getUserEvaluations(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/evaluations/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      
      print('📤 Get User Evaluations Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        print('❌ Failed to get evaluations: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting user evaluations: $e');
      return null;
    }
  }

  /// Get user's propositions
  Future<List<dynamic>?> getUserPropositions(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/propositions/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      
      print('📤 Get User Propositions Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        print('❌ Failed to get propositions: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting user propositions: $e');
      return null;
    }
  }
  
  /// Get user profile
  Future<Map<String, dynamic>?> getProfile(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Error getting profile: $e');
      return null;
    }
  }
}