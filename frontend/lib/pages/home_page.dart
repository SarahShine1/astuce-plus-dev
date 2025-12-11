import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/pages/astuce_page.dart';
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
    this.userName,
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

  // Authentication (from your version)
  final storage = const FlutterSecureStorage();
  String displayName = 'Invité';
  bool isGuest = true;
  
  // Astuce logic (from friend's version)
  List<dynamic> astuces = [];
  List<dynamic> filteredAstuces = [];
  List<String> categories = [];
  String selectedCategory = "Toutes";
  bool isLoading = true;
  String searchQuery = "";
  String _sortBy = 'date';
  bool _isAscending = false;

  final TextEditingController _searchController = TextEditingController();
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations (friend's version)
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _animationController!.forward();
    
    // Load user (your version) THEN fetch astuces
    _loadUser().then((_) {
      fetchAstuces();
    });
  }

  // Your authentication method
  Future<void> _loadUser() async {
    final data = await storage.read(key: 'user_data');
    final token = await storage.read(key: 'access_token');
    
    setState(() {
      if (data != null) {
        final u = jsonDecode(data);
        displayName = u['nom'] ?? u['username'] ?? 'Utilisateur';
        isGuest = token == null || token.isEmpty;
      } else {
        displayName = 'Invité';
        isGuest = true;
      }
    });
  }

  // Friend's astuce fetching method
  Future<void> fetchAstuces() async {
    await Future.delayed(const Duration(seconds: 1));

    final data = [
      {
        "id": 1,
        "titre": "Optimiser sa journée avec la méthode Pomodoro",
        "description":
            "Travaillez par sessions de 25 minutes séparées de petites pauses. Cela aide à rester concentré et productif.",
        "categorie": "Productivité",
        "image_url":
            "https://images.unsplash.com/photo-1506784983877-45594efa4cbe?auto=format&fit=crop&w=400&q=60",
        "note_moyenne": 4.5,
        "est_validee": true,
      },
      {
        "id": 2,
        "titre": "Recycler ses bocaux pour ranger ses fournitures",
        "description":
            "Ne jetez plus vos bocaux en verre ! Utilisez-les pour ranger stylos, boutons ou épices.",
        "categorie": "Vie quotidienne",
        "image_url":
            "https://images.unsplash.com/photo-1591270551370-6e1d6b0b2c8f?auto=format&fit=crop&w=400&q=60",
        "note_moyenne": 4.2,
        "est_validee": true,
      },
      {
        "id": 3,
        "titre": "Sauvegarder ses notes de cours efficacement",
        "description":
            "Numérisez vos notes avec une app comme Notion ou Google Keep pour éviter de les perdre.",
        "categorie": "Études",
        "image_url":
            "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?auto=format&fit=crop&w=400&q=60",
        "note_moyenne": 3.8,
        "est_validee": false,
      },
      {
        "id": 4,
        "titre": "Apprendre à coder 30 minutes par jour",
        "description":
            "Une pratique régulière est plus efficace que de longues sessions irrégulières. La constance est la clé.",
        "categorie": "Technologie",
        "image_url":
            "https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=400&q=60",
        "note_moyenne": 4.8,
        "est_validee": true,
      },
      {
        "id": 5,
        "titre": "Respirer profondément pour mieux gérer le stress",
        "description":
            "Quelques respirations lentes et profondes aident à calmer le système nerveux et réduire la tension.",
        "categorie": "Bien-être",
        "image_url":
            "https://images.unsplash.com/photo-1551829142-26e3b305307a?auto=format&fit=crop&w=400&q=60",
        "note_moyenne": 4.6,
        "est_validee": true,
      },
      {
        "id": 6,
        "titre": "Désactiver les notifications inutiles",
        "description":
            "Moins d'interruptions = plus de concentration. Supprimez les notifications non essentielles.",
        "categorie": "Productivité",
        "image_url":
            "https://images.unsplash.com/photo-1573497019114-07b0642f49b9?auto=format&fit=crop&w=400&q=60",
        "note_moyenne": 4.0,
        "est_validee": false,
      },
      {
        "id": 7,
        "titre": "Faire des listes de tâches réalisables",
        "description":
            "Divisez vos grandes tâches en sous-tâches concrètes pour éviter la procrastination.",
        "categorie": "Productivité",
        "image_url":
            "https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?auto=format&fit=crop&w=400&q=60",
        "note_moyenne": 0.0,
        "est_validee": false,
      },
      {
        "id": 8,
        "titre": "Utiliser la lumière naturelle pour mieux étudier",
        "description":
            "La lumière du jour améliore la concentration et réduit la fatigue visuelle.",
        "categorie": "Études",
        "image_url":
            "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=400&q=60",
        "note_moyenne": 4.3,
        "est_validee": true,
      },
    ];

    final catSet = <String>{"Toutes"};
    for (var astuce in data) {
      if (astuce["categorie"] != null) {
        catSet.add(astuce["categorie"].toString());
      }
    }

    setState(() {
      astuces = data;
      categories = catSet.toList();
      filterAstuces();
      isLoading = false;
    });
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
          username: widget.userName ?? displayName,
          isAdmin: widget.isAdmin,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use displayName from storage if widget.userName is not provided
    final userName = widget.userName ?? displayName;
    final userAvatar = widget.userAvatar;
    final isGuestUser = widget.isGuest || isGuest;

    return Scaffold(
      backgroundColor: lightGray,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildCustomAppBar(userName, userAvatar, isGuestUser),
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
  Widget _buildCustomAppBar(String userName, String? userAvatar, bool isGuestUser) {
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
                        backgroundImage: userAvatar != null
                            ? NetworkImage(userAvatar)
                            : null,
                        child: userAvatar == null
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
                              isGuestUser ? "Invité" : userName,
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