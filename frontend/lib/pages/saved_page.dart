import 'package:flutter/material.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> with TickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF053F5C);
  static const Color secondaryBlue = Color(0xFF429EBD);
  static const Color accentOrange = Color(0xFFF7AD19);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;

  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  // Variables pour les fonctionnalités
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Toutes';
  String _sortBy = 'date'; // 'date', 'title', 'category'
  bool _isAscending = false;
  bool _isSearching = false;

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
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Données d'exemple avec plus de contenu
  List<Map<String, dynamic>> allFavorites = [
    {
      "title": "Astuce rangement cuisine",
      "category": "Cuisine",
      "date": "20 Septembre 2025",
      "image": "assets/kitchen.jpg",
      "description": "Optimisez l'espace de votre cuisine avec des astuces simples",
      "icon": Icons.kitchen,
      "color": Colors.green,
      "dateTime": DateTime(2025, 9, 20),
    },
    {
      "title": "Exercice rapide à la maison",
      "category": "Santé & Fitness",
      "date": "18 Septembre 2025",
      "image": "assets/fitness.jpg",
      "description": "15 minutes d'exercices quotidiens pour rester en forme",
      "icon": Icons.fitness_center,
      "color": Colors.blue,
      "dateTime": DateTime(2025, 9, 18),
    },
    {
      "title": "Optimiser son bureau",
      "category": "Organisation",
      "date": "15 Septembre 2025",
      "image": "assets/desk.jpg",
      "description": "Créez un espace de travail productif et inspirant",
      "icon": Icons.desk,
      "color": Colors.purple,
      "dateTime": DateTime(2025, 9, 15),
    },
    {
      "title": "Jardinage en appartement",
      "category": "Maison & Jardin",
      "date": "12 Septembre 2025",
      "image": "assets/plants.jpg",
      "description": "Cultivez vos propres plantes même en espace réduit",
      "icon": Icons.eco,
      "color": Colors.green,
      "dateTime": DateTime(2025, 9, 12),
    },
    {
      "title": "Recette pain maison",
      "category": "Cuisine",
      "date": "10 Septembre 2025",
      "image": "assets/bread.jpg",
      "description": "Pain fait maison sans machine à pain",
      "icon": Icons.bakery_dining,
      "color": Colors.orange,
      "dateTime": DateTime(2025, 9, 10),
    },
    {
      "title": "Méditation quotidienne",
      "category": "Santé & Fitness",
      "date": "08 Septembre 2025",
      "image": "assets/meditation.jpg",
      "description": "Techniques de méditation pour débutants",
      "icon": Icons.self_improvement,
      "color": Colors.indigo,
      "dateTime": DateTime(2025, 9, 8),
    },
  ];

  // Getters pour les données filtrées
  List<String> get categories {
    Set<String> cats = {'Toutes'};
    cats.addAll(allFavorites.map((fav) => fav['category'] as String));
    return cats.toList();
  }

  List<Map<String, dynamic>> get filteredFavorites {
    List<Map<String, dynamic>> filtered = allFavorites;

    // Filtrage par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((fav) {
        return fav['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            fav['description'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            fav['category'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filtrage par catégorie
    if (_selectedCategory != 'Toutes') {
      filtered = filtered.where((fav) => fav['category'] == _selectedCategory).toList();
    }

    // Tri
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'title':
          comparison = a['title'].toString().compareTo(b['title'].toString());
          break;
        case 'category':
          comparison = a['category'].toString().compareTo(b['category'].toString());
          break;
        case 'date':
        default:
          comparison = a['dateTime'].compareTo(b['dateTime']);
          break;
      }
      return _isAscending ? comparison : -comparison;
    });

    return filtered;
  }

  void _removeFavorite(int originalIndex) {
    final removedItem = filteredFavorites[originalIndex];
    final globalIndex = allFavorites.indexOf(removedItem);

    setState(() {
      allFavorites.removeAt(globalIndex);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "\"${removedItem["title"]}\" retiré des favoris",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: "Annuler",
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              allFavorites.insert(globalIndex, removedItem);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          if (allFavorites.isNotEmpty) ...[
            _buildFilterSection(),
            if (filteredFavorites.isEmpty)
              SliverFillRemaining(child: _buildNoResultsState())
            else
              _buildFavoritesList(),
          ] else
            SliverFillRemaining(child: _buildEmptyState()),
        ],
      ),
    );
  }

  // AppBar avec recherche
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: _isSearching ? 160 : 120,
      floating: false,
      pinned: true,
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _searchQuery = '';
              }
            });
          },
        ),
        if (allFavorites.isNotEmpty && !_isSearching)
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                if (value == _sortBy) {
                  _isAscending = !_isAscending;
                } else {
                  _sortBy = value;
                  _isAscending = false;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: _sortBy == 'date' ? accentOrange : Colors.grey),
                    const SizedBox(width: 8),
                    Text('Date'),
                    if (_sortBy == 'date') ...[
                      const Spacer(),
                      Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                    ],
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'title',
                child: Row(
                  children: [
                    Icon(Icons.title, color: _sortBy == 'title' ? accentOrange : Colors.grey),
                    const SizedBox(width: 8),
                    Text('Titre'),
                    if (_sortBy == 'title') ...[
                      const Spacer(),
                      Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                    ],
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'category',
                child: Row(
                  children: [
                    Icon(Icons.category, color: _sortBy == 'category' ? accentOrange : Colors.grey),
                    const SizedBox(width: 8),
                    Text('Catégorie'),
                    if (_sortBy == 'category') ...[
                      const Spacer(),
                      Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                    ],
                  ],
                ),
              ),
            ],
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: _isSearching
            ? null
            : const Text(
          "Mes Favoris",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryBlue, secondaryBlue],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_isSearching)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Rechercher dans vos favoris...",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                )
              else if (allFavorites.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, right: 16),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${filteredFavorites.length} astuce${filteredFavorites.length > 1 ? 's' : ''}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Section des filtres par catégorie
  Widget _buildFilterSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Catégories",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategory == category;
                  final count = category == 'Toutes'
                      ? allFavorites.length
                      : allFavorites.where((fav) => fav['category'] == category).length;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(
                        "$category ($count)",
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
                          _selectedCategory = category;
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

  // Liste des favoris
  Widget _buildFavoritesList() {
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
                  begin: Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController!,
                  curve: Interval(index * 0.1, 1.0),
                ))
                    : const AlwaysStoppedAnimation(Offset.zero),
                child: _buildFavoriteCard(filteredFavorites[index], index),
              ),
            );
          },
          childCount: filteredFavorites.length,
        ),
      ),
    );
  }

  // Carte favoris
  Widget _buildFavoriteCard(Map<String, dynamic> fav, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: cardBackground,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Action lors du tap sur la carte
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône avec couleur thématique
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: (fav["color"] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    fav["icon"] as IconData,
                    color: fav["color"] as Color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Contenu principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fav["title"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryBlue,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fav["description"]!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accentOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              fav["category"]!,
                              style: TextStyle(
                                color: accentOrange,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              fav["date"]!,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Bouton favori
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => _removeFavorite(index),
                    tooltip: "Retirer des favoris",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Aucun résultat trouvé
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
              _searchQuery.isNotEmpty
                  ? "Aucun favori ne correspond à \"$_searchQuery\""
                  : "Aucun favori dans cette catégorie",
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
                  _searchQuery = '';
                  _selectedCategory = 'Toutes';
                  _isSearching = false;
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

  // État vide
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
                  Icons.favorite_border,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Aucun favori pour l'instant",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Découvrez des astuces incroyables et ajoutez-les en favoris pour les retrouver facilement ici.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentOrange, accentOrange],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: accentOrange.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.explore, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Explorer les astuces",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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