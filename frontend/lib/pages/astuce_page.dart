import 'package:flutter/material.dart';

class AstucePage extends StatefulWidget {

  final bool isAdmin; // Pour savoir si l'utilisateur est admin
  final String? username; // Nom d'utilisateur connecté
  const AstucePage({
    Key? key,
    required this.username,
    this.isAdmin = false,
  }) : super(key: key);


  @override
  State<AstucePage> createState() => _AstucePageState();
}

class _AstucePageState extends State<AstucePage>

    with TickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF053F5C);
  static const Color secondaryBlue = Color(0xFF429EBD);
  static const Color accentOrange = Color(0xFFF7AD19);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;

  bool estFavori = false;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  int _currentCommentairePage = 0;

  final String titre = 'Comment réduire le stress au quotidien';
  final String description =
      'Cette astuce vous guide pour réduire le stress grâce à des techniques simples comme la respiration consciente, la méditation quotidienne, et l\'organisation de votre emploi du temps. Suivez ces étapes pour un mieux-être général et une meilleure productivité.';
  final String source = 'www.exemple-astuce.com';
  final double scoreIA = 4.5;
  final String moderateurNom = 'Sophie Durand';
  final String moderateurStatut = 'Expert Bien-être';
  final String niveauExperience = 'Débutant';

  final List<String> mediaUrls = [
    'https://picsum.photos/300/200',
    'https://picsum.photos/300/200',
  ];

  final List<String> etapes = [
    'Prendre 5 minutes pour respirer profondément.',
    'Pratiquer la méditation ou la relaxation guidée.',
    'Organiser son emploi du temps pour éviter la surcharge.',
  ];

  final Map<String, String> termes = {
    'Stress': 'État de tension mentale ou émotionnelle.',
    'Méditation': 'Pratique visant à calmer l\'esprit et améliorer le focus.',
  };

  late List<Map<String, dynamic>> _commentaires = [
    {'nom': 'Alice', 'commentaire': 'Super astuce, très utile !', 'note': 5},
    {'nom': 'Mohamed', 'commentaire': 'Je l\'ai testée et ça marche bien.', 'note': 4},
    {'nom': 'Sara', 'commentaire': 'Peut-être un peu compliqué à suivre.', 'note': 3},
    {'nom': 'Jean', 'commentaire': 'Vraiment transformateur pour moi !', 'note': 5},
    {'nom': 'Lisa', 'commentaire': 'Bonne introduction au sujet.', 'note': 4},
  ];
  bool get estInvite => widget.username == null || widget.username!.isEmpty;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double get moyenneCommentaires {
    if (_commentaires.isEmpty) return 0;
    int total = 0;
    for (var commentaire in _commentaires) {
      final note = commentaire['note'];
      if (note != null && note is int) {
        total += note;
      }
    }
    return _commentaires.isEmpty ? 0 : total / _commentaires.length;
  }

  void _toggleFavori() {
    setState(() {
      estFavori = !estFavori;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(estFavori ? Icons.favorite : Icons.favorite_border,
                color: Colors.white),
            const SizedBox(width: 12),
            Text(estFavori ? 'Ajouté aux favoris' : 'Retiré des favoris'),
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

  void _ajouterAvis() {
    if (estInvite) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour ajouter un commentaire.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // ✅ Si connecté → ouvrir la boîte de dialogue d’ajout de commentaire
    _buildAvisDialog();
  }


  void _supprimerCommentaire(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le commentaire ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _commentaires.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  Widget _buildAvisDialog() {
    final nomController = TextEditingController();
    final commentaireController = TextEditingController();
    int note = 5; // valeur par défaut

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
                  // Ligne d'étoiles interactives
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final isFilled = index < note;
                      return GestureDetector(
                        onTap: () {
                          // Mettre à jour la note locale dans le dialog
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
            onPressed: () {
              if (nomController.text.isNotEmpty &&
                  commentaireController.text.isNotEmpty) {
                // Mettre à jour la liste des commentaires dans le State parent
                setState(() {
                  _commentaires.add({
                    'nom': nomController.text,
                    'commentaire': commentaireController.text,
                    'note': note,
                  });
                });
                Navigator.pop(context);
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
              } else {
                // Indiquer qu'il manque des champs
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Veuillez remplir tous les champs'),
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
    return Scaffold(
      backgroundColor: lightGray,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Media
                if (mediaUrls.isNotEmpty)
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(16),
                      itemCount: mediaUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              mediaUrls[index],
                              width: 280,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre


                      // Description
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Informations principales en cartes
                      _buildInfoCard(),
                      const SizedBox(height: 20),

                      // Étapes
                      if (etapes.isNotEmpty) ...[
                        Text(
                          'Étapes de mise en œuvre',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (int i = 0; i < etapes.length; i++)
                          _buildEtapeCard(i, etapes[i]),
                        const SizedBox(height: 20),
                      ],

                      // Termes clés
                      if (termes.isNotEmpty) ...[
                        Text(
                          'Définition des termes clés',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (var entry in termes.entries)
                          _buildTermeCard(entry.key, entry.value),
                        const SizedBox(height: 20),
                      ],

                      // Avis utilisateurs avec carrousel
                      _buildAvisSection(),
                      const SizedBox(height: 20),

                      // Boutons d'action
                      _buildActionButtons(),
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
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16), // ✅ déplace le titre à gauche
        title: Text(
          titre,
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
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(Icons.smart_toy, 'Score IA', '$scoreIA/5', accentOrange),
            const Divider(height: 16),
            _buildInfoRow(Icons.school, 'Niveau', niveauExperience, secondaryBlue),
            const Divider(height: 16),
            _buildInfoRow(Icons.verified, 'Validé par',
                '$moderateurNom ($moderateurStatut)', Colors.green),
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

  Widget _buildEtapeCard(int index, String etape) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cardBackground,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentOrange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  etape,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermeCard(String terme, String definition) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: secondaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: secondaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              terme,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              definition,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
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
                          index < moyenneCommentaires.toInt()
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
        if (_commentaires.isNotEmpty)
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentCommentairePage = index;
                });
              },
              itemCount: _commentaires.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildCommentaireCard(_commentaires[index]),
                );
              },
            ),
          ),
        if (_commentaires.isNotEmpty) const SizedBox(height: 12),
        if (_commentaires.isNotEmpty)
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_commentaires.length, (index) {
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

  Widget _buildCommentaireCard(Map<String, dynamic> commentaire) {
    final note = commentaire['note'] ?? 0;
    final username = commentaire['username'] ?? 'Utilisateur';

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
            // Ligne du haut : username + étoiles + bouton supprimer (admin)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF053F5C), // primaryBlue
                  ),
                ),
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < note ? Icons.star : Icons.star_border,
                          color: Color(0xFFF7AD19), // accentOrange
                          size: 18,
                        );
                      }),
                    ),
                    if (widget.isAdmin)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () {
                          setState(() {
                            _commentaires.remove(commentaire);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Commentaire supprimé'),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Le texte du commentaire
            Text(
              commentaire['commentaire'] ?? '',
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                if (widget.username == null || widget.username!.isEmpty) {
                  // 🔒 Si invité → afficher un message d’erreur
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Connectez-vous pour ajouter aux favoris.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                } else {
                  // ✅ Si connecté → basculer le favori
                  _toggleFavori();
                }
              },
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
                onPressed: () {},
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

