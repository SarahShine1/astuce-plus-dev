import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/services/AstuceService.dart';
import 'package:frontend/pages/astuce_page.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({Key? key}) : super(key: key);

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  static const Color primaryBlue = Color(0xFF053F5C);
  static const Color secondaryBlue = Color(0xFF429EBD);
  static const Color accentOrange = Color(0xFFF7AD19);
  static const Color lightGray = Color(0xFFF8F9FA);

  final AstuceService _astuceService = AstuceService();
  final storage = const FlutterSecureStorage();
  
  List<dynamic> favoris = [];
  bool isLoading = true;
  String? accessToken;
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    accessToken = await storage.read(key: 'access_token');
    username = await storage.read(key: 'username');
    
    if (accessToken != null) {
      _loadFavoris();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadFavoris() async {
    if (accessToken == null) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final data = await _astuceService.getMesFavoris(accessToken!);
      setState(() {
        favoris = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeFavorite(int astuceId) async {
    if (accessToken == null) return;

    try {
      await _astuceService.toggleFavori(
        astuceId: astuceId,
        accessToken: accessToken!,
      );

      setState(() {
        favoris.removeWhere((astuce) => astuce['id'] == astuceId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Retiré des favoris'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToDetail(dynamic astuce) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AstucePage(
          astuceId: astuce['id'],
          username: username,
          isAdmin: false,
        ),
      ),
    ).then((_) => _loadFavoris()); // Refresh on return
  }

  @override
  Widget build(BuildContext context) {
    if (accessToken == null) {
      return _buildGuestView();
    }

    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        title: const Text('Mes Favoris'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoris.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadFavoris,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favoris.length,
                    itemBuilder: (context, index) {
                      return _buildFavoriteCard(favoris[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildGuestView() {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        title: const Text('Mes Favoris'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 100,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Connectez-vous pour voir vos favoris',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Enregistrez vos astuces préférées pour y accéder rapidement',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun favori',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ajoutez des astuces à vos favoris pour les retrouver ici',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(dynamic astuce) {
    final categories = astuce['categories'] as List?;
    final categoryName = (categories != null && categories.isNotEmpty)
        ? categories[0]['nom']
        : 'Autre';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToDetail(astuce),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentOrange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        categoryName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => _removeFavorite(astuce['id']),
                      tooltip: 'Retirer des favoris',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  astuce['titre'] ?? 'Sans titre',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  astuce['description'] ?? 'Pas de description',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}