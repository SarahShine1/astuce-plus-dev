import 'package:flutter/material.dart';
import 'package:frontend/pages/astuce_page.dart';
import 'package:frontend/services/AstuceService.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

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
  bool _isAscending = false;

  final AstuceService _astuceService = AstuceService();

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
    fetchAstuces();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchAstuces() async {
    await Future.delayed(const Duration(seconds: 1));
     setState(() {
      isLoading = true;
    });

     try {
      // Récupérer les catégories
      final categoriesData = await _astuceService.getCategories();
      
      // Récupérer les astuces
      final astucesData = await _astuceService.getAstuces(
        ordering: _sortBy,
      );

      setState(() {
        categories = [
          {"id": 0, "nom": "Toutes"}, // Catégorie "Toutes" manuelle
          ...categoriesData,
        ];
        
        astuces = astucesData;
        filterAstuces();
        isLoading = false;
      });
      
      print("✅ Data loaded successfully");
      print("   Categories: ${categories.length}");
      print("   Astuces: ${astuces.length}");
    } catch (e) {
      print("❌ Error loading data: $e");
      setState(() {
        isLoading = false;
      });
      
      
    }
  }
  

  void filterAstuces() {
    List<dynamic> filtered = astuces;

    // Filtrage par recherche
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((astuce) {
        final titre = astuce["titre"]?.toLowerCase() ?? "";
        final description = astuce["description"]?.toLowerCase() ?? "";
        return titre.contains(searchQuery.toLowerCase()) ||
            description.contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Filtrage par catégorie
    if (selectedCategory != "Toutes") {
      filtered = filtered
          .where((astuce) => astuce["categorie"] == selectedCategory)
          .toList();
    }

    // Tri
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'title':
          comparison = (a["titre"] ?? "").compareTo(b["titre"] ?? "");
          break;
        case 'category':
          comparison =
              (a["categorie"] ?? "").compareTo(b["categorie"] ?? "");
          break;
        case 'date':
        default:
          comparison = 0;
          break;
      }
      return _isAscending ? comparison : -comparison;
    });

    setState(() {
      filteredAstuces = filtered;
    });
  }

  void _navigateToAstuceDetail(dynamic astuce) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AstucePage(
          username: widget.userName,
          isAdmin: widget.isAdmin,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
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
    );
  }

  // AppBar personnalisée avec nom et avatar
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
                // Profil utilisateur
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: widget.userAvatar != null
                            ? NetworkImage(widget.userAvatar!)
                            : null,
                        child: widget.userAvatar == null
                            ? const Icon(Icons.person,
                            color: Colors.white, size: 24)
                            : null,
                      ),
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
                // Icône notifications
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
                          onPressed: () {
                            // Action notifications
                          },
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

  // Barre de recherche
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
              prefixIcon:
              const Icon(Icons.search, color: primaryBlue),
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

  // Section des filtres par catégorie
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
                      if (value == _sortBy) {
                        _isAscending = !_isAscending;
                      } else {
                        _sortBy = value;
                        _isAscending = false;
                      }
                      filterAstuces();
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'date',
                      child: Row(
                        children: [
                          Icon(Icons.access_time,
                              color: _sortBy == 'date'
                                  ? accentOrange
                                  : Colors.grey),
                          const SizedBox(width: 8),
                          const Text('Date'),
                          if (_sortBy == 'date') ...[
                            const Spacer(),
                            Icon(
                                _isAscending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 16),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'title',
                      child: Row(
                        children: [
                          Icon(Icons.title,
                              color: _sortBy == 'title'
                                  ? accentOrange
                                  : Colors.grey),
                          const SizedBox(width: 8),
                          const Text('Titre'),
                          if (_sortBy == 'title') ...[
                            const Spacer(),
                            Icon(
                                _isAscending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 16),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'category',
                      child: Row(
                        children: [
                          Icon(Icons.category,
                              color: _sortBy == 'category'
                                  ? accentOrange
                                  : Colors.grey),
                          const SizedBox(width: 8),
                          const Text('Catégorie'),
                          if (_sortBy == 'category') ...[
                            const Spacer(),
                            Icon(
                                _isAscending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 16),
                          ],
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
                  final isSelected = selectedCategory == category;
                  final count = category == "Toutes"
                      ? astuces.length
                      : astuces
                      .where((ast) => ast["categorie"] == category)
                      .length;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(
                        "$category ($count)",
                        style: TextStyle(
                          color:
                          isSelected ? Colors.white : primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selectedColor: accentOrange,
                      backgroundColor: Colors.white,
                      checkmarkColor: Colors.white,
                      elevation: isSelected ? 4 : 2,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = category;
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

  // Grille des astuces
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
                  curve: Interval(index * 0.1, 1.0),
                ))
                    : const AlwaysStoppedAnimation(Offset.zero),
                child: _buildAstuceTile(filteredAstuces[index], index),
              ),
            );
          },
          childCount: filteredAstuces.length,
        ),
      ),
    );
  }

  // Carte d'astuce
  Widget _buildAstuceTile(dynamic astuce, int index) {
    final bool isValidated = astuce["est_validee"] ?? false;
    final double note = (astuce["note_moyenne"] ?? 0.0).toDouble();

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
              // Image en haut avec badge de validation
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      astuce["image_url"] ?? "https://via.placeholder.com/400x200",
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Badge de validation
                  if (isValidated)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  // Badge catégorie
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                        astuce["categorie"] ?? "Autre",
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
              // Contenu
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
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
                    // Description
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
                    // Note et action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Note
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: note > 0 ? Colors.amber : Colors.grey[300],
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              note > 0 ? note.toStringAsFixed(1) : "Non notée",
                              style: TextStyle(
                                color: note > 0 ? primaryBlue : Colors.grey[500],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        // Bouton favori
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.favorite_border, color: Colors.red, size: 22),
                            onPressed: () {},
                            tooltip: "Ajouter aux favoris",
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
            ],
          ),
        ),
      ),
    );
  }
}

// Importez votre AstucePage ici
// import 'votre_fichier_astuce_page.dart';