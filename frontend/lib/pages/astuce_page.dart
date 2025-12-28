import 'package:flutter/material.dart';
import 'package:frontend/services/AstuceService.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AstucePage extends StatefulWidget {
  final int astuceId;
  final bool isAdmin;
  final String? username;

  const AstucePage({
    Key? key,
    required this.astuceId,
    required this.username,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  State<AstucePage> createState() => _AstucePageState();
}

class _AstucePageState extends State<AstucePage> with TickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF053F5C);
  static const Color secondaryBlue = Color(0xFF429EBD);
  static const Color accentOrange = Color(0xFFF7AD19);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;

  final AstuceService _astuceService = AstuceService();
  final storage = const FlutterSecureStorage();
  
  bool isLoading = true;
  Map<String, dynamic>? astuceDetails;
  String? accessToken;
  
  bool estFavori = false;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentCommentairePage = 0;

  bool get estInvite => widget.username == null || widget.username!.isEmpty || widget.username == "Invité";

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    accessToken = await storage.read(key: 'access_token');
    await _loadAstuceDetails();
  }

  Future<void> _loadAstuceDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final details = await _astuceService.getAstuceDetails(widget.astuceId);
      
      if (details != null) {
        print("📦 Astuce Details: $details");
        
        // ✅ Correctly extract est_favori from the response
        final astuceData = details['astuce'];
        final isFavorite = astuceData?['est_favori'] ?? false;
        
        print("❤️ Est Favori: $isFavorite");
        
        setState(() {
          astuceDetails = details;
          estFavori = isFavorite;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors du chargement de l\'astuce'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("❌ Error loading astuce: $e");
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double get moyenneCommentaires {
    if (astuceDetails == null) return 0.0;
    final moyenne = astuceDetails!['moyenne_note'];
    if (moyenne == null) return 0.0;
    return moyenne is int ? moyenne.toDouble() : moyenne.toDouble();
  }

  List<dynamic> get evaluations {
    if (astuceDetails == null) return [];
    return astuceDetails!['evaluations'] ?? [];
  }

  Map<String, dynamic>? get astuce {
    if (astuceDetails == null) return null;
    return astuceDetails!['astuce'];
  }

  Future<void> _toggleFavori() async {
    if (estInvite) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connectez-vous pour ajouter aux favoris.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expirée, veuillez vous reconnecter'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print("🔄 Toggling favorite for astuce ${widget.astuceId}");
      print("🔄 Current state: estFavori = $estFavori");
      
      final result = await _astuceService.toggleFavori(
        astuceId: widget.astuceId,
        accessToken: accessToken!,
      );

      print("📥 Toggle result: $result");
      
      // ✅ Use the response from backend to determine new state
      final newState = result['est_favori'] ?? !estFavori;
      final message = result['message'] ?? (newState ? 'Ajouté aux favoris' : 'Retiré des favoris');
      
      print("✅ New favorite state: $newState");

      setState(() {
        estFavori = newState;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  estFavori ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: estFavori ? Colors.red.shade600 : Colors.grey.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("❌ Error toggling favorite: $e");
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

  Future<void> _ajouterAvis() async {
    if (estInvite) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour ajouter un commentaire.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expirée, veuillez vous reconnecter'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _buildAvisDialog(),
    );
  }

  Widget _buildAvisDialog() {
    final commentaireController = TextEditingController();
    int note = 5;
    double? fiabilitePercue;

    return StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Ajouter un avis',
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: commentaireController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Votre avis',
                  labelStyle: const TextStyle(color: secondaryBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: secondaryBlue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Note',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final isFilled = index < note;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            note = index + 1;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            isFilled ? Icons.star : Icons.star_border,
                            color: accentOrange,
                            size: 28,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fiabilité perçue (optionnel)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Pourcentage (0-100)',
                      labelStyle: const TextStyle(color: secondaryBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: secondaryBlue, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null && parsed >= 0 && parsed <= 100) {
                        fiabilitePercue = parsed;
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (commentaireController.text.isNotEmpty) {
                try {
                  await _astuceService.evaluerAstuce(
                    astuceId: widget.astuceId,
                    accessToken: accessToken!,
                    note: note,
                    commentaire: commentaireController.text,
                    fiabilitePercue: fiabilitePercue,
                  );

                  Navigator.pop(context);
                  await _loadAstuceDetails();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Text('Avis ajouté avec succès'),
                          ],
                        ),
                        backgroundColor: Colors.green.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                } catch (e) {
                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Veuillez remplir le commentaire'),
                    backgroundColor: Colors.orange.shade700,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Ajouter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: lightGray,
        appBar: AppBar(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (astuceDetails == null || astuce == null) {
      return Scaffold(
        backgroundColor: lightGray,
        appBar: AppBar(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Astuce introuvable'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: lightGray,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: cardBackground,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.description, 
                                      color: accentOrange, size: 24),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                astuce!['description'] ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.7,
                                  color: Colors.grey[800],
                                  letterSpacing: 0.3,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildInfoCard(),
                      const SizedBox(height: 20),

                      _buildAvisSection(),
                      const SizedBox(height: 20),

                      if (!estInvite) _buildActionButtons(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          astuce!['titre'] ?? 'Sans titre',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final valide = astuce!['valide'] ?? false;
    final categories = astuce!['categories'] as List? ?? [];
    final categoriesText = categories.map((c) => c['nom']).join(', ');
    final createur = astuce!['createur'] ?? 'Anonyme';
    final source = astuce!['source'];
    final datePublication = astuce!['date_publication'];
    
    String formattedDate = 'Non spécifiée';
    if (datePublication != null) {
      try {
        final date = DateTime.parse(datePublication);
        formattedDate = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        formattedDate = 'Non spécifiée';
      }
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(Icons.calendar_today, 'Date de publication', 
                formattedDate, primaryBlue),
            const Divider(height: 16),
            if (categoriesText.isNotEmpty) ...[
              _buildInfoRow(Icons.category, 'Catégories', 
                  categoriesText, secondaryBlue),
              const Divider(height: 16),
            ],
            _buildInfoRow(Icons.verified, 'Statut',
                valide ? 'Validée' : 'En attente', 
                valide ? Colors.green : Colors.orange),
            const Divider(height: 16),
            _buildInfoRow(Icons.person, 'Créateur', createur, primaryBlue),
            if (source != null && source.toString().isNotEmpty) ...[
              const Divider(height: 16),
              _buildInfoRow(Icons.link, 'Source', source, primaryBlue),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avis utilisateurs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < moyenneCommentaires.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: accentOrange,
                          size: 16,
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${moyenneCommentaires.toStringAsFixed(1)}/5',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accentOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (!estInvite)
              ElevatedButton.icon(
                onPressed: _ajouterAvis,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (evaluations.isNotEmpty)
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentCommentairePage = index;
                });
              },
              itemCount: evaluations.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildCommentaireCard(evaluations[index]),
                );
              },
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Aucun avis pour le moment',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        if (evaluations.isNotEmpty) const SizedBox(height: 12),
        if (evaluations.isNotEmpty)
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(evaluations.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentCommentairePage == index
                        ? accentOrange
                        : Colors.grey[300],
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentaireCard(Map<String, dynamic> evaluation) {
    final note = evaluation['note'] ?? 0;
    final username = evaluation['utilisateur'] ?? 'Utilisateur';
    final commentaire = evaluation['commentaire'] ?? '';
    final fiabilitePercue = evaluation['fiabilite_percue'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < note ? Icons.star : Icons.star_border,
                      color: accentOrange,
                      size: 18,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (commentaire.isNotEmpty)
              Text(
                commentaire,
                style: const TextStyle(color: Colors.black87),
              ),
            if (fiabilitePercue != null) ...[
              const SizedBox(height: 8),
              Text(
                'Fiabilité perçue: ${fiabilitePercue.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _toggleFavori,
                icon: Icon(
                  estFavori ? Icons.favorite : Icons.favorite_border,
                ),
                label: const Text('Favoris'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      estFavori ? Colors.red.shade600 : Colors.grey[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implémenter le partage
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité de partage à venir'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Partager'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}