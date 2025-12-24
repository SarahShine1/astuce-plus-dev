import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/pages/change_password_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/services/UserService.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
const Color accentOrange = Color(0xFFF7AD19);


final UserService _userService = UserService();
final storage = const FlutterSecureStorage();

const Color primaryBlue = Color(0xFF1565C0);
const Color lightBlue = Color(0xFF64B5F6);
const Color greyBackground = Color(0xFFF5F5F5);

class EditProfilePage extends StatefulWidget {
  final String? initialName;
  final String? initialUsername;
  final String? initialEmail;
  final String? initialBio;
  final String? initialPhone;
  final String? initialProfileImage;
  final String? initialInterests;

  const EditProfilePage({
    Key? key,
    this.initialName,
    this.initialUsername,
    this.initialEmail,
    this.initialBio,
    this.initialPhone,
    this.initialProfileImage,
    this.initialInterests,
  }) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> with TickerProviderStateMixin {
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController bioController;
  late TextEditingController phoneController;
  late TextEditingController interestsController;
  String? profileImagePath;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName ?? "");
    usernameController = TextEditingController(text: widget.initialUsername ?? "");
    emailController = TextEditingController(text: widget.initialEmail ?? "");
    bioController = TextEditingController(text: widget.initialBio ?? "");
    phoneController = TextEditingController(text: widget.initialPhone ?? "");
    interestsController = TextEditingController(text: widget.initialInterests ?? "");
    profileImagePath = widget.initialProfileImage;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    bioController.dispose();
    phoneController.dispose();
    interestsController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatarImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choisir une photo de profil',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImagePickerOption(
                    icon: Icons.camera_alt,
                    label: 'Caméra',
                    onTap: () => _pickAvatarFromSource(ImageSource.camera),
                  ),
                  _buildImagePickerOption(
                    icon: Icons.photo_library,
                    label: 'Galerie',
                    onTap: () => _pickAvatarFromSource(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAvatarFromSource(ImageSource source) async {
    Navigator.pop(context);
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        profileImagePath = pickedImage.path;
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choisir une photo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImagePickerOption(
                    icon: Icons.camera_alt,
                    label: 'Caméra',
                    onTap: () => _pickImageFromSource(ImageSource.camera),
                  ),
                  _buildImagePickerOption(
                    icon: Icons.photo_library,
                    label: 'Galerie',
                    onTap: () => _pickImageFromSource(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: lightBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: lightBlue.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: primaryBlue),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    Navigator.pop(context);
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        profileImagePath = pickedImage.path;
      });
    }
  }

  // Replace the _saveProfile method
Future<void> _saveProfile() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final accessToken = await storage.read(key: 'access_token');
    
    if (accessToken == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expirée, veuillez vous reconnecter'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Update profile via API
    File? avatarFile = profileImagePath != null && !profileImagePath!.startsWith('http')
        ? File(profileImagePath!)
        : null;

    final result = await _userService.updateProfile(
      accessToken: accessToken,
      nom: nameController.text,
      email: emailController.text,
      bio: bioController.text,
      phone: phoneController.text,  // 🆕 ADDED
      centresInteret: interestsController.text,  // 🆕 ADDED
      avatarFile: avatarFile,  // 🆕 ADDED
    );

    if (result != null && mounted) {
      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, {
        'name': nameController.text,
        'username': usernameController.text,
        'email': emailController.text,
        'bio': bioController.text,
        'phone': phoneController.text,
        'interests': interestsController.text,
        'profileImage': profileImagePath,
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la mise à jour'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    print("❌ Error saving profile: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: lightBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primaryBlue, size: 20),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    int delay = 0,
  }) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _fadeAnimation.value) * 50),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: EdgeInsets.only(bottom: 20, top: delay * 2.0),
              child: TextField(
                controller: controller,
                maxLines: maxLines,
                decoration: _inputDecoration(label, icon),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greyBackground,
      body: CustomScrollView(
        slivers: [
          // AppBar avec effet de parallaxe
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Modifier le profil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryBlue,
                      lightBlue,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.check, color: Colors.white),
                  onPressed: _isLoading ? null : _saveProfile,
                ),
              ),
            ],
          ),

          // Contenu principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Photo de profil avec animation
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _fadeAnimation.value,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryBlue.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 55,
                                    backgroundImage: profileImagePath != null
                                        ? FileImage(File(profileImagePath!))
                                        : null,
                                    backgroundColor: lightBlue.withOpacity(0.3),
                                    child: profileImagePath == null
                                        ? Icon(
                                      Icons.person,
                                      size: 60,
                                      color: primaryBlue,
                                    )
                                        : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _pickAvatarImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: primaryBlue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Formulaires avec animations décalées
                  _buildAnimatedTextField(
                    controller: nameController,
                    label: "Nom complet",
                    icon: Icons.person_outline,
                    delay: 1,
                  ),

                  _buildAnimatedTextField(
                    controller: usernameController,
                    label: "Nom d'utilisateur",
                    icon: Icons.account_circle_outlined,
                    delay: 2,
                  ),

                  _buildAnimatedTextField(
                    controller: emailController,
                    label: "Email",
                    icon: Icons.email_outlined,
                    delay: 3,
                  ),

                  _buildAnimatedTextField(
                    controller: phoneController,
                    label: "Téléphone",
                    icon: Icons.phone_outlined,
                    delay: 4,
                  ),

                  _buildAnimatedTextField(
                    controller: bioController,
                    label: "Bio",
                    icon: Icons.info_outline,
                    maxLines: 3,
                    delay: 5,
                  ),

                  _buildAnimatedTextField(
                    controller: interestsController,
                    label: "Centres d'intérêt",
                    icon: Icons.star_outline,
                    maxLines: 2,
                    delay: 6,
                  ),

                  const SizedBox(height: 40),

                  // Bouton de sauvegarde alternatif (en bas)
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - _fadeAnimation.value) * 50),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [accentOrange, accentOrange],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),

                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                'Sauvegarder les modifications',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}