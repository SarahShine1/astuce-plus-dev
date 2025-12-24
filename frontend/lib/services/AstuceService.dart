import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AstuceService {
  //static const String baseUrl = 'http://10.0.2.2:8000/api/astuces';
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
      
      // ✅ Include token if available to get est_favori status
      final token = await _getToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle paginated responses
        final results = data is Map ? (data['results'] as List? ?? data) : data;
        print("✅ Astuces fetched: ${results.length} items");
        return results;
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
      
      // ✅ Include token to get est_favori status
      final token = await _getToken();
      final headers = {'Content-Type': 'application/json'};
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

  // ========== PROPOSITIONS ==========
  Future<Map<String, dynamic>?> getPropositionDetails(int propositionId) async {
    try {
      final url = Uri.parse('$baseUrl/propositions/$propositionId/');
      print("🌐 Fetching proposition details from: $url");
      
      final token = await _getToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        url,
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Proposition details fetched successfully");
        return data;
      } else {
        print("❌ Failed to fetch proposition details: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching proposition details: $e");
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
    double? fiabilitePercue,
  }) async {
    try {
      final body = <String, dynamic>{
        'note': note,
      };
      
      if (commentaire != null && commentaire.isNotEmpty) {
        body['commentaire'] = commentaire;
      }
      if (fiabilitePercue != null) {
        body['fiabilite_percue'] = fiabilitePercue;
      }
      
      print("📤 Evaluating astuce $astuceId with body: $body");
      
      final response = await http.post(
        Uri.parse('$baseUrl/astuces/$astuceId/evaluer/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      
      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? error['detail'] ?? 'Failed to evaluate: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error in evaluerAstuce: $e");
      throw Exception('Erreur de connexion: $e');
    }
  }
  
  // ========== FAVORIS ==========
  
  /// Récupère les favoris de l'utilisateur
  Future<List<dynamic>> getMesFavoris(String accessToken) async {
    try {
      print("🌐 Fetching user favorites...");
      
      final response = await http.get(
        Uri.parse('$baseUrl/favoris/mes_favoris/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(const Duration(seconds: 10));
      
      print("📥 Favorites response status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Favorites fetched: ${data.length} items");
        return data;
      } else {
        print("❌ Failed to load favorites: ${response.statusCode}");
        print("Response: ${response.body}");
        throw Exception('Failed to load favorites: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching favorites: $e");
      throw Exception('Erreur de connexion: $e');
    }
  }
  
  /// Ajoute ou retire une astuce des favoris
  Future<Map<String, dynamic>> toggleFavori({
    required int astuceId,
    required String accessToken,
  }) async {
    try {
      print("🔄 Toggling favorite for astuce $astuceId");
      
      final response = await http.post(
        Uri.parse('$baseUrl/astuces/$astuceId/toggle_favori/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(const Duration(seconds: 10));
      
      print("📥 Toggle favorite response: ${response.statusCode}");
      print("📥 Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("❌ Failed to toggle favorite: ${response.statusCode}");
        throw Exception('Failed to toggle favorite: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error toggling favorite: $e");
      throw Exception('Erreur de connexion: $e');
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
        Uri.parse('$baseUrl/rechercher/'),
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
        Uri.parse('$baseUrl/propositions/mes_propositions/'),
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
  
   // ========== CRÉER UNE PROPOSITION ==========
  Future<Map<String, dynamic>> creerProposition({
    required String accessToken,
    required String titre,
    required String description,
    String? source,
    required String niveauDifficulte,
    required List<int> categoriesIds,
    required List<Map<String, String>> termes,
    dynamic imageFile,
  }) async {
    try {
      print("📤 Creating proposition with data...");

      // Créer la requête multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/propositions/'),
      );

      // Ajouter les champs texte
      request.fields['titre'] = titre;
      request.fields['description'] = description;
      request.fields['source'] = source ?? '';
      request.fields['niveau_difficulte'] = niveauDifficulte;
      
      // Ajouter les categories (comme JSON array)
      request.fields['categories_ids'] = jsonEncode(categoriesIds);
      
      // Ajouter les termes (comme JSON string)
      request.fields['nouveaux_termes'] = jsonEncode(termes);

      // Ajouter l'image si elle existe
      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile(
            'image',
            imageFile.openRead(),
            bytes.length,
            filename: 'proposition_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
        print("📸 Image ajoutée au formulaire");
      }

      // Ajouter le token d'auth
      request.headers['Authorization'] = 'Bearer $accessToken';

      // Envoyer la requête
      final response = await request.send().timeout(const Duration(seconds: 15));
      final responseData = await response.stream.bytesToString();

      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: $responseData");

      if (response.statusCode == 201) {
        final data = jsonDecode(responseData);
        print("✅ Proposition created successfully");
        return {
          'success': true,
          'data': data,
          'message': 'Proposition créée avec succès ! Elle sera examinée par un modérateur.'
        };
      } else {
        final error = jsonDecode(responseData);
        throw Exception(error['error'] ?? 'Erreur lors de la création: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error creating proposition: $e");
      throw Exception('Erreur de connexion: $e');
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

  // ========== TERMES ==========
  Future<List<dynamic>> getTermes({String? search}) async {
    try {
      String url = '$baseUrl/termes/';
      if (search != null && search.isNotEmpty) {
        url += '?search=$search';
      }
      
      final uri = Uri.parse(url);
      print("🌐 Fetching termes from: $uri");
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Termes fetched: ${data.length} items");
        return data;
      } else {
        print("❌ Failed to fetch termes: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Error fetching termes: $e");
      return [];
    }
  }
}