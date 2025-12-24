import 'package:flutter/material.dart';
import '../services/AstuceService.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  static const Color primaryBlue = Color(0xFF053F5C);
  static const Color secondaryBlue = Color(0xFF429EBD);

  final TextEditingController _searchController = TextEditingController();
  final AstuceService _astuceService = AstuceService();

  List<Map<String, dynamic>> _termes = [];
  List<Map<String, dynamic>> _filteredTermes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTermes();
  }

  Future<void> _loadTermes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final termes = await _astuceService.getTermes();
      setState(() {
        _termes = termes.map((terme) => {
          'mot': terme['terme'] ?? '',
          'definition': terme['definition'] ?? '',
        }).toList();
        // Trie alphabétiquement selon le mot
        _termes.sort((a, b) => a['mot']!.toLowerCase().compareTo(b['mot']!.toLowerCase()));
        _filteredTermes = List.from(_termes);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des termes: $e';
        _isLoading = false;
      });
    }
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

  Future<void> _searchTermes(String query) async {
    if (query.isEmpty) {
      _loadTermes();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final termes = await _astuceService.getTermes(search: query);
      setState(() {
        _termes = termes.map((terme) => {
          'mot': terme['terme'] ?? '',
          'definition': terme['definition'] ?? '',
        }).toList();
        _filteredTermes = List.from(_termes);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la recherche: $e';
        _isLoading = false;
      });
    }
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
                onSubmitted: _searchTermes,
                decoration: InputDecoration(
                  hintText: 'Rechercher un terme...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadTermes,
                  ),
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

          // ✅ Gestion du chargement et des erreurs
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (_errorMessage != null)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTermes,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_filteredTermes.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Aucun terme trouvé',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
            )
          else

          // ✅ Liste triée des termes avec lettres
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                // Get the current letter group
                final terme = _filteredTermes[index];
                final currentLetter = (terme['mot'] ?? '').isEmpty 
                    ? '#' 
                    : (terme['mot']![0].toUpperCase());
                
                // Check if previous terme starts with different letter
                final previousLetter = index > 0
                    ? (_filteredTermes[index - 1]['mot'] ?? '').isEmpty
                        ? '#'
                        : (_filteredTermes[index - 1]['mot']![0].toUpperCase())
                    : null;
                
                final showLetter = previousLetter != currentLetter;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showLetter)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          currentLetter,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    Padding(
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
                                terme['mot'] ?? '',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                terme['definition'] ?? '',
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
                    ),
                  ],
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
