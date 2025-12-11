import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF053F5C);
  static const Color secondaryBlue = Color(0xFF429EBD);
  static const Color accentOrange = Color(0xFFF7AD19);
  static const Color lightGray = Color(0xFFF8F9FA);

  final storage = const FlutterSecureStorage();
  String displayName = 'Invité';
  int _bottomIndex = 0;
  bool isGuest = true;
  String selectedCategory = 'Technologie';
  int selectedTab = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    'Cuisine',
    'Maison',
    'Etudes',
    'Santé',
    'Créativité',
    'Technologie',
    'Carrière',
  ];

  final List<Map<String, String>> posts = [
    {
      'title': 'Accélérer son PC sans logiciel',
      'desc': "Désactivez les programmes qui se lancent automatiquement au démarrage…",
      'image': 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=1200',
      'author': 'Yumna Azzahra',
      'rating': '4.5',
    },
    {
      'title': 'Organisation bureau efficace',
      'desc': "Améliorez votre productivité avec quelques ajustements simples…",
      'image': 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?q=80&w=1200',
      'author': 'Jean Martin',
      'rating': '4.3',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final data = await storage.read(key: 'user_data');
    final token = await storage.read(key: 'access_token');
    if (data != null) {
      final u = jsonDecode(data);
      setState(() {
        displayName = u['nom'] ?? u['username'] ?? 'Utilisateur';
        isGuest = token == null || token.isEmpty;
      });
    } else {
      setState(() {
        isGuest = token == null || token.isEmpty;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(child: _buildSearch()),
          SliverToBoxAdapter(child: _buildCategories()),
          SliverToBoxAdapter(child: _buildTabs()),
          _buildPostList(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      title: const Text(''),
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(radius: 18, backgroundColor: Colors.grey),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bienvenue, 👋', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(displayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Icon(Icons.notifications_none, color: Colors.black87),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher une astuce',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Parcourir par catégorie', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((c) {
                final selected = c == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: selected,
                    selectedColor: accentOrange,
                    labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
                    onSelected: (_) => setState(() => selectedCategory = c),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['All', 'Populaires', 'Récentes', 'Mieux notées'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final sel = i == selectedTab;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = i),
              child: Text(
                tabs[i],
                style: TextStyle(color: sel ? Colors.black : Colors.grey, fontWeight: sel ? FontWeight.w600 : FontWeight.w400),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPostList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _postCard(posts[index]),
        childCount: posts.length,
      ),
    );
  }

  Widget _postCard(Map<String, String> p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(p['image']!, height: 160, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p['title']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(p['desc']!, style: TextStyle(color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(p['rating']!),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10)),
                        child: const Text('Validée par IA + Modérateur', style: TextStyle(color: Colors.green, fontSize: 10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const CircleAvatar(radius: 12, backgroundColor: Colors.grey),
                      const SizedBox(width: 6),
                      Text(p['author']!),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final itemsGuest = const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
    ];
    final itemsUser = const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
      BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Ajouter'),
      BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favoris'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
    ];

    return BottomNavigationBar(
      currentIndex: _bottomIndex,
      selectedItemColor: accentOrange,
      unselectedItemColor: Colors.grey,
      items: isGuest ? itemsGuest : itemsUser,
      onTap: (i) {
        setState(() => _bottomIndex = i);
        if (isGuest) {
          if (i == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (i == 1) {
            Navigator.pushReplacementNamed(context, '/search');
          } else if (i == 2) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        } else {
          if (i == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (i == 1) {
            Navigator.pushReplacementNamed(context, '/search');
          } else if (i == 2) {
            Navigator.pushReplacementNamed(context, '/astuce');
          } else if (i == 3) {
            Navigator.pushReplacementNamed(context, '/favorites');
          } else if (i == 4) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        }
      },
    );
  }
}
