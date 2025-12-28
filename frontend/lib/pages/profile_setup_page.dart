import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/pages/home_page.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController bioController = TextEditingController();
  File? _image;

  final List<String> categories = [
    'Technologie',
    'Éducation',
    'Santé',
    'Art & Design',
    'Business',
    'Lifestyle',
    'Voyage',
    'Science',
    'Sport',
    'Culture'
  ];

  List<String> selectedCategories = [];

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  void _toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  void _saveProfile() {
    if (bioController.text.isEmpty || selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    print("Bio: ${bioController.text}");
    print("Intérêts: $selectedCategories");
    print("Image: ${_image?.path}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil enregistré ✅")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Color(0xFF053F5C)),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF053F5C),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 350),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ---------- Titre ----------
                  const Text(
                    "Complétez votre profil",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF053F5C),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ---------- Photo ----------
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      backgroundColor: Colors.grey.shade200,
                      child: _image == null
                          ? const Icon(Icons.add_a_photo,
                          size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ---------- Bio ----------
                  _buildTextField(
                    controller: bioController,
                    label: "Bio",
                    icon: Icons.info_outline,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // ---------- Centres d’intérêt ----------
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Choisissez vos centres d’intérêt",
                      style: TextStyle(
                        color: Color(0xFF053F5C),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      final isSelected = selectedCategories.contains(category);
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        selectedColor: const Color(0xFFF7AD19),
                        backgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onSelected: (_) => _toggleCategory(category),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 30),

                  // ---------- Bouton Enregistrer ----------
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7AD19),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Enregistrer",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF053F5C), width: 2.0),
        ),
        prefixIcon: icon != null ? Icon(icon, color: Color(0xFF053F5C)) : null,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}
