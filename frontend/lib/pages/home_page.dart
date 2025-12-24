import 'package:flutter/material.dart';
import 'package:frontend/pages/astuce_page.dart';
import 'package:frontend/services/AstuceService.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends StatefulWidget {
  final int? userId;
  final String? userName;
  final String? userAvatar;
  final bool isAdmin;
  final bool isGuest;

  const HomePage({
    Key? key,
    this.userId,
    this.userName = "Utilisateur",
    this.userAvatar,
    this.isAdmin = false,
    this.isGuest = false,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF053F5C);
  static const Color secondaryBlue = Color(0xFF429EBD);
  static const Color accentOrange = Color(0xFFF7AD19);
  static const Color lightGray = Color(0xFFF8F9FA);

  List<dynamic> astuces = [];
  List<dynamic> filteredAstuces = [];
  List<dynamic> categories = [];
  String selectedCategory = "Toutes";
  bool isLoading = true;
  String searchQuery = "";
  String _sortBy = '-date_publication';

  final AstuceService _astuceService = AstuceService();
  final storage = const FlutterSecureStorage();
  String? accessToken;

  final TextEditingController _searchController = TextEditingController();
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _animationController!.forward();
    _loadToken();
    fetchAstuces();
  }

  Future<void> _loadToken() async {
    accessToken = await storage.read(key: 'access_token');
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchAstuces() async {
    setState(() {
      isLoading = true;
    });

    try {
      final categoriesData = await _astuceService.getCategories();
      final astucesData = await _astuceService.getAstuces(ordering: _sortBy);

      setState(() {
        categories = [
          {"id": 0, "nom": "Toutes"},
          ...categoriesData,
        ];
        astuces = astucesData;
        filterAstuces();
        isLoading = false;
      });
      
      print("✅ Data loaded successfully");
      print("   Categories: ${categories.length}");
      print("   Astuces: ${astuces.length}");
      
      // DEBUG: Log image URLs
      for (var astuce in astuces.take(3)) {
        print("   Astuce: ${astuce['titre']}");
        print("   Image URL: ${astuce['image_url']}");
        print("   Image field: ${astuce['image']}");
      }
    } catch (e) {
      print("❌ Error loading data: $e");
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper pour créer un avatar avec fallback
  ImageProvider? _getAvatarImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'null') {
      return NetworkImage(imageUrl);
    }
    return null;
  }

  // Widget d'avatar avec fallback
  Widget _buildAvatarWidget(String? imageUrl, {double radius = 20}) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: _getAvatarImage(imageUrl),
      backgroundColor: Colors.grey[300],
      child: _getAvatarImage(imageUrl) == null
          ? const Icon(Icons.person, color: Colors.white, size: 24)
          : null,
    );
  }

  // Widget pour afficher image astuce avec fallback
  Widget _buildAstuceImageWidget(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'null') {
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 180,
            color: Colors.grey[200],
            child: Icon(
              Icons.lightbulb_outline,
              size: 60,
              color: Colors.grey[400],
            ),
          );
        },
      );
    }
    return Container(
      width: double.infinity,
      height: 180,
      color: Colors.grey[200],
      child: Icon(
        Icons.lightbulb_outline,
        size: 60,
        color: Colors.grey[400],
      ),
    );
  }

  void filterAstuces() {
    List<dynamic> filtered = astuces;

    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((astuce) {
        final titre = astuce["titre"]?.toLowerCase() ?? "";
        final description = astuce["description"]?.toLowerCase() ?? "";
        return titre.contains(searchQuery.toLowerCase()) ||
            description.contains(searchQuery.toLowerCase());
      }).toList();
    }

    if (selectedCategory != "Toutes") {
      filtered = filtered.where((astuce) {
        final astuceCategories = astuce["categories"] as List?;
        if (astuceCategories == null || astuceCategories.isEmpty) return false;
        return astuceCategories.any((cat) => cat["nom"] == selectedCategory);
      }).toList();
    }

    setState(() {
      filteredAstuces = filtered;
    });
  }

  Future<void> _toggleFavori(int astuceId) async {
    if (widget.isGuest || accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connectez-vous pour ajouter aux favoris'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Trouver et inverser l'état localement pour UX immédiate
      final astuce = astuces.firstWhere((a) => a["id"] == astuceId);
      final wasFiltered = filteredAstuces.contains(astuce);
      
      // Inverser l'état immédiatement dans la UI
      setState(() {
        astuce["est_favori"] = !(astuce["est_favori"] ?? false);
      });

      // Appeler l'API
      final result = await _astuceService.toggleFavori(
        astuceId: astuceId,
        accessToken: accessToken!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Favori mis à jour'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        // Recharger pour synchroniser avec le serveur
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) fetchAstuces();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // Recharger pour rétablir l'état correct en cas d'erreur
        fetchAstuces();
      }
    }
  }

  void _navigateToAstuceDetail(dynamic astuce) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AstucePage(
          astuceId: astuce["id"],
          username: widget.userName,
          isAdmin: widget.isAdmin,
        ),
      ),
    ).then((_) => fetchAstuces()); // Refresh on return
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchAstuces,
              child: CustomScrollView(
                slivers: [
                  _buildCustomAppBar(),
                  _buildSearchBar(),
                  if (astuces.isNotEmpty) ...[
                    _buildFilterSection(),
                    if (filteredAstuces.isEmpty)
                      SliverFillRemaining(child: _buildNoResultsState())
                    else
                      _buildAstucesGrid(),
                  ] else
                    SliverFillRemaining(child: _buildEmptyState()),
                ],
              ),
            ),
    );
  }

  Widget _buildCustomAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryBlue, secondaryBlue],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildAvatarWidget(widget.userAvatar, radius: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bienvenue 👋",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              widget.userName ?? "Utilisateur",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!widget.isGuest)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: IconButton(
                            icon: const Icon(Icons.notifications_none,
                                color: Colors.white),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: accentOrange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: primaryBlue),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: primaryBlue),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          searchQuery = "";
                        });
                        filterAstuces();
                      },
                    )
                  : null,
              hintText: "Chercher une astuce...",
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.white,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
              filterAstuces();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Catégories",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort, color: primaryBlue),
                  onSelected: (value) {
                    setState(() {
                      _sortBy = value;
                      fetchAstuces();
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: '-date_publication',
                      child: Row(
                        children: [
                          Icon(Icons.access_time,
                              color: _sortBy == '-date_publication'
                                  ? accentOrange
                                  : Colors.grey),
                          const SizedBox(width: 8),
                          const Text('Plus récentes'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'date_publication',
                      child: Row(
                        children: [
                          Icon(Icons.history,
                              color: _sortBy == 'date_publication'
                                  ? accentOrange
                                  : Colors.grey),
                          const SizedBox(width: 8),
                          const Text('Plus anciennes'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'titre',
                      child: Row(
                        children: [
                          Icon(Icons.sort_by_alpha,
                              color: _sortBy == 'titre'
                                  ? accentOrange
                                  : Colors.grey),
                          const SizedBox(width: 8),
                          const Text('Titre A-Z'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: '-titre',
                      child: Row(
                        children: [
                          Icon(Icons.sort_by_alpha,
                              color: _sortBy == '-titre'
                                  ? accentOrange
                                  : Colors.grey),
                          const SizedBox(width: 8),
                          const Text('Titre Z-A'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: '-score_fiabilite',
                      child: Row(
                        children: [
                          Icon(Icons.star,
                              color: _sortBy == '-score_fiabilite'
                                  ? accentOrange
                                  : Colors.grey),
                          const SizedBox(width: 8),
                          const Text('Mieux notées'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final categoryName = category["nom"] ?? "";
                  final isSelected = selectedCategory == categoryName;
                  
                  final count = categoryName == "Toutes"
                      ? astuces.length
                      : astuces.where((ast) {
                          final astuceCategories = ast["categories"] as List?;
                          if (astuceCategories == null) return false;
                          return astuceCategories.any((cat) => cat["nom"] == categoryName);
                        }).length;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(
                        "$categoryName ($count)",
                        style: TextStyle(
                          color: isSelected ? Colors.white : primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selectedColor: accentOrange,
                      backgroundColor: Colors.white,
                      checkmarkColor: Colors.white,
                      elevation: isSelected ? 4 : 2,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = categoryName;
                          filterAstuces();
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAstucesGrid() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return FadeTransition(
              opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
              child: SlideTransition(
                position: _animationController != null
                    ? Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animationController!,
                        curve: Interval(
                          index * 0.1 > 1.0 ? 1.0 : index * 0.1,
                          1.0,
                        ),
                      ))
                    : const AlwaysStoppedAnimation(Offset.zero),
                child: _buildAstuceTile(filteredAstuces[index]),
              ),
            );
          },
          childCount: filteredAstuces.length,
        ),
      ),
    );
  }

  Widget _buildAstuceTile(dynamic astuce) {
    final bool isValidated = astuce["valide"] ?? false;
    final double averageRating = (astuce["average_rating"] ?? 0.0).toDouble();
    
    final categories = astuce["categories"] as List?;
    final categorieName = (categories != null && categories.isNotEmpty) 
        ? categories[0]["nom"] 
        : "Autre";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToAstuceDetail(astuce),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: _buildAstuceImageWidget(astuce["image_url"]),
                  ),
                  if (isValidated)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.verified, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              "Validée",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentOrange,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        categorieName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      astuce["titre"] ?? "Sans titre",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: primaryBlue,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      astuce["description"] ?? "Pas de description",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: averageRating > 0
                              ? Colors.amber
                              : Colors.grey[300],
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          averageRating > 0
                              ? "${averageRating.toStringAsFixed(1)}/5"
                              : "Non notée",
                          style: TextStyle(
                            color: averageRating > 0
                                ? primaryBlue
                                : Colors.grey[500],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              "Aucun résultat",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              searchQuery.isNotEmpty
                  ? "Aucune astuce ne correspond à \"$searchQuery\""
                  : "Aucune astuce dans cette catégorie",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  searchQuery = '';
                  selectedCategory = 'Toutes';
                  filterAstuces();
                });
              },
              child: Text(
                "Réinitialiser les filtres",
                style: TextStyle(
                  color: accentOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Aucune astuce disponible",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Les astuces s'afficheront ici dès qu'elles seront disponibles.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: fetchAstuces,
                icon: const Icon(Icons.refresh),
                label: const Text("Actualiser"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}