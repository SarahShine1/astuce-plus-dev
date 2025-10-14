import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _categorieSelectionnee;
  String? _niveauDifficulte;
  List<TextEditingController> _etapesControllers = [TextEditingController()];
  List<File?> _images = [];
  List<Map<String, TextEditingController>> _termes = [];

  final List<String> _categories = [
    'Santé',
    'Bien-être',
    'Cuisine',
    'Maison',
    'Beauté',
    'Productivité',
    'Technologie',
    'Finances',
    'Loisirs'
  ];

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
    _animationController!.dispose();
    _titreController.dispose();
    _descriptionController.dispose();
    for (var controller in _etapesControllers) {
      controller.dispose();
    }
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

  void _addEtape() {
    setState(() {
      _etapesControllers.add(TextEditingController());
    });
  }

  void _removeEtape(int index) {
    if (_etapesControllers.length > 1) {
      setState(() {
        _etapesControllers[index].dispose();
        _etapesControllers.removeAt(index);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_categorieSelectionnee == null) {
        _showErrorSnackbar('Veuillez sélectionner une catégorie');
        return;
      }
      if (_niveauDifficulte == null) {
        _showErrorSnackbar('Veuillez sélectionner un niveau de difficulté');
        return;
      }

      String message = 'Astuce créée: ${_titreController.text}';

      if (_termes.isNotEmpty) {
        message += '\nTermes ajoutés au dictionnaire:';
        for (var t in _termes) {
          message += '\n- ${t['nom']!.text}: ${t['definition']!.text}';
        }
      }

      _showSuccessSnackbar(message);

      // Réinitialisation
      _formKey.currentState!.reset();
      setState(() {
        _titreController.clear();
        _descriptionController.clear();
        _categorieSelectionnee = null;
        _niveauDifficulte = null;

        // Réinitialiser étapes
        _etapesControllers.forEach((c) => c.dispose());
        _etapesControllers = [TextEditingController()];

        // Réinitialiser images
        _images = [];

        // Réinitialiser termes
        _termes.forEach((t) {
          t['nom']!.dispose();
          t['definition']!.dispose();
        });
        _termes = [];
      });
    }
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
    return Scaffold(
      backgroundColor: lightGray,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation ?? AlwaysStoppedAnimation(0.0),
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
                      _buildSectionTitle('Étapes de Mise en Œuvre'),
                      const SizedBox(height: 12),
                      _buildEtapesSection(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Images ou Vidéos'),
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
          "Créer une Astuce",
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
      style: TextStyle(
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
            if (value.length < 50) {
              return 'Le titre doit contenir au moins 50 caractères';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          '${_titreController.text.length}/100',
          style: TextStyle(
            fontSize: 12,
            color:
            _titreController.text.length < 50 ? Colors.red : accentOrange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorieDropdown() {
    return DropdownButtonFormField<String>(
      value: _categorieSelectionnee,
      items: _categories.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? value) {
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
      children: ['Débutant', 'Intermédiaire', 'Expert'].map((niveau) {
        return FilterChip(
          label: Text(
            niveau,
            style: TextStyle(
              color: _niveauDifficulte == niveau ? Colors.white : primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: _niveauDifficulte == niveau,
          onSelected: (selected) {
            setState(() {
              _niveauDifficulte = selected ? niveau : null;
            });
          },
          selectedColor: accentOrange,
          backgroundColor: Colors.white,
          checkmarkColor: Colors.white,
          elevation: _niveauDifficulte == niveau ? 4 : 2,
          side: BorderSide(
            color: _niveauDifficulte == niveau ? accentOrange : Colors.grey[300]!,
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
            if (value.length < 300) {
              return 'La description doit contenir au moins 300 caractères';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          '${_descriptionController.text.length}/300 min',
          style: TextStyle(
            fontSize: 12,
            color: _descriptionController.text.length < 300
                ? Colors.red
                : accentOrange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEtapesSection() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _etapesControllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _etapesControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Étape ${index + 1}',
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
                          borderSide: const BorderSide(
                            color: secondaryBlue,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: cardBackground,
                      ),
                    ),
                  ),
                  if (_etapesControllers.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: IconButton(
                        onPressed: () => _removeEtape(index),
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 20),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _addEtape,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une étape'),
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
    );
  }

  Widget _buildMediaSection() {
    return Column(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (int i = 0; i < _images.length; i++)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _images[i]!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: -5,
                    right: -5,
                    child: IconButton(
                      onPressed: () => _removeImage(i),
                      icon: const Icon(Icons.cancel, color: Colors.red),
                    ),
                  ),
                ],
              ),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: const Icon(Icons.add_a_photo, color: Colors.grey),
              ),
            ),
            GestureDetector(
              onTap: _takePhoto,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Publier'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _formKey.currentState!.reset();
              setState(() {
                _titreController.clear();
                _descriptionController.clear();
                _categorieSelectionnee = null;
                _niveauDifficulte = null;

                _etapesControllers.forEach((c) => c.dispose());
                _etapesControllers = [TextEditingController()];

                _images = [];

                _termes.forEach((t) {
                  t['nom']!.dispose();
                  t['definition']!.dispose();
                });
                _termes = [];
              });
            },
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
