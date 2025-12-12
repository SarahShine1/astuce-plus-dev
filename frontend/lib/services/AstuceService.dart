import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AstuceService {
  static const String baseUrl = 'http://192.168.137.1:8000/api/astuces';
  final storage = const FlutterSecureStorage();

  // Méthode pour obtenir le token d'authentification
  Future<String?> _getToken() async {
    return await storage.read(key: 'access_token');
  }

  // ========== CATÉGORIES ==========
  Future<List<dynamic>> getCategories() async {
    try {
      final url = Uri.parse('$baseUrl/categories/');
      print("🌐 Fetching categories from: $url");
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Categories fetched: ${data.length} items");
        return data;
      } else {
        print("❌ Failed to fetch categories: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching categories: $e");
      return [];
    }
  }

  // ========== ASTUCES ==========
  Future<List<dynamic>> getAstuces({
    String? category,
    String? search,
    String? ordering,
  }) async {
    try {
      String url = '$baseUrl/astuces/';
      final params = <String>[];
      
      if (category != null && category != "Toutes") {
        params.add('categories=$category');
      }
      
      if (search != null && search.isNotEmpty) {
        params.add('search=$search');
      }
      
      if (ordering != null) {
        params.add('ordering=$ordering');
      }
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }
      
      final uri = Uri.parse(url);
      print("🌐 Fetching astuces from: $uri");
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Astuces fetched: ${data.length} items");
        return data;
      } else {
        print("❌ Failed to fetch astuces: ${response.statusCode}");
        print("Response body: ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching astuces: $e");
      return [];
    }
  }

  // ========== DÉTAILS D'UNE ASTUCE ==========
  Future<Map<String, dynamic>?> getAstuceDetails(int astuceId) async {
    try {
      final url = Uri.parse('$baseUrl/astuces/$astuceId/details/');
      print("🌐 Fetching astuce details from: $url");
      
      final token = await _getToken();
      final headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        url,
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Astuce details fetched successfully");
        return data;
      } else {
        print("❌ Failed to fetch astuce details: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching astuce details: $e");
      return null;
    }
  }

  // ========== ÉVALUATIONS ==========
  
  /// Évalue une astuce (note + commentaire)
  Future<Map<String, dynamic>> evaluerAstuce({
    required int astuceId,
    required String accessToken,
    required int note,
    String? commentaire,
    double? fiabilitePerdue,
  }) async {
    try {
      final body = <String, dynamic>{
        'note': note,
      };
      
      if (commentaire != null && commentaire.isNotEmpty) {
        body['commentaire'] = commentaire;
      }
      if (fiabilitePerdue != null) {
        body['fiabilite_percue'] = fiabilitePerdue;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/astuces/astuces/$astuceId/evaluer/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to evaluate: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  // ========== FAVORIS ==========
  
  /// Récupère les favoris de l'utilisateur
  Future<List<dynamic>> getMesFavoris(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/astuces/favoris/mes_favoris/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load favorites: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  /// Ajoute ou retire une astuce des favoris
  Future<Map<String, dynamic>> toggleFavori({
    required int astuceId,
    required String accessToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/astuces/astuces/$astuceId/toggle_favori/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to toggle favorite: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  // ========== RECHERCHE ==========
  
  /// Recherche des astuces avec mots-clés et/ou catégorie
  Future<Map<String, dynamic>> rechercherAstuces({
    String? accessToken,
    String? motsCles,
    int? categorieId,
  }) async {
    try {
      final body = <String, dynamic>{};
      
      if (motsCles != null && motsCles.isNotEmpty) {
        body['mots_cles'] = motsCles;
      }
      if (categorieId != null) {
        body['categorie_id'] = categorieId;
      }
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/astuces/rechercher/'),
        headers: headers,
        body: jsonEncode(body),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to search: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  // ========== PROPOSITIONS ==========
  
  /// Récupère les propositions de l'utilisateur
  Future<List<dynamic>> getMesPropositions(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/astuces/propositions/mes_propositions/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load propositions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  /// Soumet une nouvelle proposition d'astuce
  Future<Map<String, dynamic>> creerProposition({
    required String accessToken,
    required String contenu,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/astuces/propositions/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'contenu': contenu}),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create proposition: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  
  
  /// Calcule la note moyenne d'une astuce
  double calculerNoteMoyenne(Map<String, dynamic> astuceDetails) {
    try {
      final evaluations = astuceDetails['evaluations'] as List;
      if (evaluations.isEmpty) return 0.0;
      
      final sum = evaluations.fold<double>(0.0, (total, eval) {
        return total + (eval['note'] as int).toDouble();
      });
      
      return sum / evaluations.length;
    } catch (e) {
      return 0.0;
    }
  }
}