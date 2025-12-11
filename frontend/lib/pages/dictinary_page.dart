import 'package:flutter/material.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  static const Color primaryBlue = Color(0xFF053F5C);
  static const Color secondaryBlue = Color(0xFF429EBD);

  final TextEditingController _searchController = TextEditingController();

  // ✅ Exemple de termes (à remplacer par ceux de la base plus tard)
  final List<Map<String, String>> _termes = [
    {'mot': 'API', 'definition': 'Interface permettant la communication entre deux applications.'},
    {'mot': 'Backend', 'definition': 'Partie serveur d’une application.'},
    {'mot': 'Frontend', 'definition': 'Partie visible d’une application, utilisée par l’utilisateur.'},
    {'mot': 'UI', 'definition': 'Interface utilisateur d’une application.'},
    {'mot': 'Base de données', 'definition': 'Système permettant de stocker et gérer les informations.'},
  ];

  late List<Map<String, String>> _filteredTermes;

  @override
  void initState() {
    super.initState();
    // ✅ Trie alphabétiquement selon le mot
    _termes.sort((a, b) => a['mot']!.toLowerCase().compareTo(b['mot']!.toLowerCase()));
    _filteredTermes = List.from(_termes);
  }

  void _filterTerms(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTermes = List.from(_termes);
      } else {
        _filteredTermes = _termes
            .where((terme) =>
        terme['mot']!.toLowerCase().contains(query.toLowerCase()) ||
            terme['definition']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // ✅ Barre supérieure
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
              title: const Text(
                'Dictionnaire',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue, secondaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // ✅ Barre de recherche
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterTerms,
                decoration: InputDecoration(
                  hintText: 'Rechercher un terme...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // ✅ Liste triée des termes
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final terme = _filteredTermes[index];
                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            terme['mot']!,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            terme['definition']!,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: _filteredTermes.length,
            ),
          ),
        ],
      ),
    );
  }
}
