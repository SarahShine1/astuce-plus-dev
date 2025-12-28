import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/services/AstuceService.dart';
import 'dart:io';

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> with TickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF053F5C);
  static const Color secondaryBlue = Color(0xFF429EBD);
  static const Color accentOrange = Color(0xFFF7AD19);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;

  final AstuceService _astuceService = AstuceService();
  final storage = const FlutterSecureStorage();
  String? accessToken;

  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sourceController = TextEditingController();

  int? _categorieSelectionnee;
  String? _niveauDifficulte;
  static const Map<String, String> niveauMap = {
    'Débutant': 'debutant',
    'Intermédiaire': 'intermediaire',
    'Expert': 'expert',
  };
  List<File?> _images = [];
  List<Map<String, TextEditingController>> _termes = [];

  List<dynamic> _categories = [];
  bool _isLoadingCategories = true;
  bool _isSubmitting = false;

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
    _loadCategories();
  }

  Future<void> _loadToken() async {
    accessToken = await storage.read(key: 'access_token');
    if (accessToken == null) {
      if (mounted) {
        _showErrorSnackbar('Vous devez être connecté pour proposer une astuce');
        Navigator.pop(context);
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _astuceService.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      _showErrorSnackbar('Erreur lors du chargement des catégories');
    }
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _titreController.dispose();
    _descriptionController.dispose();
    _sourceController.dispose();
    for (var t in _termes) {
      t['nom']!.dispose();
      t['definition']!.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _images.add(File(photo.path));
      });
    }
  }

  void _ajouterTerme() {
    setState(() {
      _termes.add({
        'nom': TextEditingController(),
        'definition': TextEditingController(),
      });
    });
  }

  void _supprimerTerme(int index) {
    setState(() {
      _termes[index]['nom']!.dispose();
      _termes[index]['definition']!.dispose();
      _termes.removeAt(index);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submitForm() async {

    print("🔵 1. _submitForm() appelé");
  
  if (_formKey.currentState!.validate()) {
    print("✅ 2. Formulaire validé");
    
    if (_categorieSelectionnee == null) {
      print("❌ Catégorie non sélectionnée");
      _showErrorSnackbar('Veuillez sélectionner une catégorie');
      return;
    }
    print("✅ 3. Catégorie sélectionnée: $_categorieSelectionnee");
    
    if (_niveauDifficulte == null) {
      print("❌ Niveau de difficulté non sélectionné");
      _showErrorSnackbar('Veuillez sélectionner un niveau de difficulté');
      return;
    }
    print("✅ 4. Niveau sélectionné: $_niveauDifficulte");

    if (accessToken == null) {
      print("❌ Token manquant");
      _showErrorSnackbar('Session expirée, veuillez vous reconnecter');
      return;
    }
    print("✅ 5. Token présent");

    setState(() {
      _isSubmitting = true;
    });

    try {
      print("🔵 6. Préparation des termes...");
      
      // Préparer les termes
      List<Map<String, String>> termesData = [];
      for (var t in _termes) {
        if (t['nom']!.text.isNotEmpty && t['definition']!.text.isNotEmpty) {
          termesData.add({
            'terme': t['nom']!.text,
            'definition': t['definition']!.text,
          });
        }
      }
      print("✅ 7. ${termesData.length} termes préparés");

      print("🔵 8. Appel API creerProposition...");
      print("   - Titre: ${_titreController.text}");
      print("   - Description: ${_descriptionController.text.substring(0, 50)}...");
      print("   - Niveau: $_niveauDifficulte");
      print("   - Catégories: [$_categorieSelectionnee]");
      print("   - Termes: ${termesData.length}");
      print("   - Image: ${_images.isNotEmpty ? 'Oui' : 'Non'}");
      
      // Appeler l'API
      final result = await _astuceService.creerProposition(
        accessToken: accessToken!,
        titre: _titreController.text,
        description: _descriptionController.text,
        source: _sourceController.text.isEmpty ? null : _sourceController.text,
        niveauDifficulte: _niveauDifficulte!,
        categoriesIds: [_categorieSelectionnee!],
        termes: termesData,
        imageFile: _images.isNotEmpty ? _images.first : null,
      );

      print("🎉 9. API retournée avec succès!");
      print("   Result: $result");

      setState(() {
        _isSubmitting = false;
      });

      if (result['success'] == true) {
        print("✅ 10. Proposition créée avec succès");
        _showSuccessSnackbar(result['message']);
        _resetForm();
      } else {
        print("❌ 10. Échec (success != true)");
      }
    } catch (e) {
      print("❌ ERREUR lors de la création: $e");
      setState(() {
        _isSubmitting = false;
      });
      _showErrorSnackbar('Erreur: $e');
    }
  } else {
    print("❌ Formulaire invalide");
  }




    if (_formKey.currentState!.validate()) {
      if (_categorieSelectionnee == null) {
        _showErrorSnackbar('Veuillez sélectionner une catégorie');
        return;
      }
      if (_niveauDifficulte == null) {
        _showErrorSnackbar('Veuillez sélectionner un niveau de difficulté');
        return;
      }

      if (accessToken == null) {
        _showErrorSnackbar('Session expirée, veuillez vous reconnecter');
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        // Préparer les termes
        List<Map<String, String>> termesData = [];
        for (var t in _termes) {
          if (t['nom']!.text.isNotEmpty && t['definition']!.text.isNotEmpty) {
            termesData.add({
              'terme': t['nom']!.text,
              'definition': t['definition']!.text,
            });
          }
        }

        // Appeler l'API
        final result = await _astuceService.creerProposition(
          accessToken: accessToken!,
          titre: _titreController.text,
          description: _descriptionController.text,
          source: _sourceController.text.isEmpty ? null : _sourceController.text,
          niveauDifficulte: _niveauDifficulte!,
          categoriesIds: [_categorieSelectionnee!],
          termes: termesData,
          imageFile: _images.isNotEmpty ? _images.first : null,
        );

        setState(() {
          _isSubmitting = false;
        });

        if (result['success'] == true) {
          _showSuccessSnackbar(result['message']);
          _resetForm();
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        _showErrorSnackbar('Erreur: $e');
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _titreController.clear();
      _descriptionController.clear();
      _sourceController.clear();
      _categorieSelectionnee = null;
      _niveauDifficulte = null;
      _images = [];

      _termes.forEach((t) {
        t['nom']!.dispose();
        t['definition']!.dispose();
      });
      _termes = [];
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCategories) {
      return Scaffold(
        backgroundColor: lightGray,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: lightGray,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(0.0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Titre Descriptif *'),
                      const SizedBox(height: 12),
                      _buildTitreField(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Catégorie *'),
                      const SizedBox(height: 12),
                      _buildCategorieDropdown(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Niveau de Difficulté *'),
                      const SizedBox(height: 12),
                      _buildDifficultyChips(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Description Détaillée *'),
                      const SizedBox(height: 8),
                      _buildDescriptionField(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Source (optionnel)'),
                      const SizedBox(height: 12),
                      _buildSourceField(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Images (bientôt disponible)'),
                      const SizedBox(height: 12),
                      _buildMediaSection(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Définition des termes clés'),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          for (int i = 0; i < _termes.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _termes[i]['nom'],
                                      decoration: InputDecoration(
                                        labelText: 'Nom du terme',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _termes[i]['definition'],
                                      decoration: InputDecoration(
                                        labelText: 'Définition',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _supprimerTerme(i),
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _ajouterTerme,
                              icon: const Icon(Icons.add),
                              label: const Text('Ajouter un terme'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          "Proposer une Astuce",
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
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: primaryBlue,
      ),
    );
  }

  Widget _buildTitreField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFormField(
          controller: _titreController,
          maxLength: 100,
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Entrez un titre descriptif',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: secondaryBlue, width: 2),
            ),
            filled: true,
            fillColor: cardBackground,
            counter: const SizedBox.shrink(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Le titre est obligatoire';
            }
            if (value.length < 10) {
              return 'Le titre doit contenir au moins 10 caractères';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          '${_titreController.text.length}/100',
          style: TextStyle(
            fontSize: 12,
            color: _titreController.text.length < 10 ? Colors.red : accentOrange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorieDropdown() {
    return DropdownButtonFormField<int>(
      value: _categorieSelectionnee,
      items: _categories.map<DropdownMenuItem<int>>((category) {
        return DropdownMenuItem<int>(
          value: category['id'],
          child: Text(category['nom']),
        );
      }).toList(),
      onChanged: (int? value) {
        setState(() {
          _categorieSelectionnee = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Sélectionnez une catégorie',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondaryBlue, width: 2),
        ),
        filled: true,
        fillColor: cardBackground,
        prefixIcon: const Icon(Icons.category, color: accentOrange),
      ),
    );
  }

  Widget _buildDifficultyChips() {
    return Wrap(
      spacing: 12,
      children: ['Débutant', 'Intermédiaire', 'Expert'].map((niveauDisplay) {
        final niveauBackend = niveauMap[niveauDisplay]!;
        return FilterChip(
          label: Text(
            niveauDisplay,
            style: TextStyle(
              color: _niveauDifficulte == niveauBackend ? Colors.white : primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: _niveauDifficulte == niveauBackend,
          onSelected: (selected) {
            setState(() {
              _niveauDifficulte = selected ? niveauBackend : null;
            });
          },
          selectedColor: accentOrange,
          backgroundColor: Colors.white,
          checkmarkColor: Colors.white,
          elevation: _niveauDifficulte == niveauBackend ? 4 : 2,
          side: BorderSide(
            color: _niveauDifficulte == niveauBackend ? accentOrange : Colors.grey[300]!,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Décrivez votre astuce en détail...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: secondaryBlue, width: 2),
            ),
            filled: true,
            fillColor: cardBackground,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La description est obligatoire';
            }
            if (value.length < 50) {
              return 'La description doit contenir au moins 50 caractères';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          '${_descriptionController.text.length}/50 min',
          style: TextStyle(
            fontSize: 12,
            color: _descriptionController.text.length < 50
                ? Colors.red
                : accentOrange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSourceField() {
    return TextFormField(
      controller: _sourceController,
      decoration: InputDecoration(
        hintText: 'Ex: www.exemple.com',
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondaryBlue, width: 2),
        ),
        filled: true,
        fillColor: cardBackground,
        prefixIcon: const Icon(Icons.link, color: accentOrange),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          if (_images.isEmpty || _images[0] == null)
            GestureDetector(
              onTap: _pickImage,
              child: Column(
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 40,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajouter une image',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Appuyez pour sélectionner une image',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _images[0]!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.edit),
                      label: const Text('Changer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryBlue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _images = [];
                        });
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Supprimer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Proposer'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _resetForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[400],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Réinitialiser'),
          ),
        ),
      ],
    );
  }
}