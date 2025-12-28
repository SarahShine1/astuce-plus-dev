import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/services/auth_service.dart';

const Color primaryBlue = Color(0xFF1565C0);
const Color lightBlue = Color(0xFF64B5F6);
const Color greyBackground = Color(0xFFF5F5F5);
const Color accentOrange = Color(0xFFF7AD19);

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  final storage = const FlutterSecureStorage();
  String? accessToken;

  bool _isObscureCurrent = true;
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _animationController.forward();
    _loadToken();
  }

  Future<void> _loadToken() async {
    accessToken = await storage.read(key: 'access_token');
    if (accessToken == null) {
      if (mounted) {
        _showErrorSnackbar('Session expirée, veuillez vous reconnecter');
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 8) {
      return 'Minimum 8 caractères requis';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Doit contenir majuscule, minuscule et chiffre';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != newPasswordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  Future<void> _saveNewPassword() async {
    if (_formKey.currentState!.validate()) {
      if (accessToken == null) {
        _showErrorSnackbar('Session expirée, veuillez vous reconnecter');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _authService.changePassword(
          accessToken: accessToken!,
          currentPassword: currentPasswordController.text,
          newPassword: newPasswordController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          _showSuccessSnackbar("Mot de passe changé avec succès !");
          
          // Vider les champs
          currentPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();
          
          // Retourner après 2 secondes
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        } else {
          final errorMsg = response.body.contains('Current password is incorrect')
              ? 'Le mot de passe actuel est incorrect'
              : 'Erreur lors du changement de mot de passe';
          _showErrorSnackbar(errorMsg);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackbar('Erreur de connexion: $e');
      }
    } else {
      _shakeController.forward().then((_) => _shakeController.reverse());
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
              child: Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              child: Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, bool obscure, VoidCallback toggle) {
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
      suffixIcon: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: lightBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: primaryBlue,
            size: 20,
          ),
        ),
        onPressed: toggle,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator,
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
              child: TextFormField(
                controller: controller,
                obscureText: obscure,
                validator: validator,
                decoration: _inputDecoration(label, icon, obscure, toggle),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    String password = newPasswordController.text;
    int strength = 0;
    List<String> requirements = [];

    if (password.length >= 8) {
      strength++;
    } else {
      requirements.add("8+ caractères");
    }

    if (RegExp(r'[A-Z]').hasMatch(password)) {
      strength++;
    } else {
      requirements.add("Majuscule");
    }

    if (RegExp(r'[a-z]').hasMatch(password)) {
      strength++;
    } else {
      requirements.add("Minuscule");
    }

    if (RegExp(r'\d').hasMatch(password)) {
      strength++;
    } else {
      requirements.add("Chiffre");
    }

    Color strengthColor = strength <= 1 ? Colors.red :
    strength <= 2 ? Colors.orange :
    strength <= 3 ? Colors.yellow[700]! : Colors.green;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: strengthColor, size: 16),
              const SizedBox(width: 8),
              Text(
                "Force du mot de passe",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: strengthColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: strength / 4,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
          ),
          if (requirements.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "Manque: ${requirements.join(', ')}",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
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
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryBlue, lightBlue],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.security,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Changer le mot de passe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ),

          // Contenu principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message d'information
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, (1 - _fadeAnimation.value) * 30),
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 30),
                              decoration: BoxDecoration(
                                color: lightBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: lightBlue.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: primaryBlue),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Assurez-vous de choisir un mot de passe fort pour protéger votre compte.",
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontSize: 14,
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

                    // Champs de mot de passe avec animations
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: Column(
                            children: [
                              _buildAnimatedTextField(
                                controller: currentPasswordController,
                                label: "Mot de passe actuel",
                                icon: Icons.lock_outline,
                                obscure: _isObscureCurrent,
                                toggle: () => setState(() {
                                  _isObscureCurrent = !_isObscureCurrent;
                                }),
                                validator: (value) =>
                                value!.isEmpty ? "Entrez votre mot de passe actuel" : null,
                                delay: 1,
                              ),

                              _buildAnimatedTextField(
                                controller: newPasswordController,
                                label: "Nouveau mot de passe",
                                icon: Icons.lock,
                                obscure: _isObscureNew,
                                toggle: () => setState(() {
                                  _isObscureNew = !_isObscureNew;
                                }),
                                validator: _validatePassword,
                                delay: 2,
                              ),

                              // Indicateur de force du mot de passe
                              if (newPasswordController.text.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: _buildPasswordStrengthIndicator(),
                                ),

                              _buildAnimatedTextField(
                                controller: confirmPasswordController,
                                label: "Confirmer le nouveau mot de passe",
                                icon: Icons.lock_clock,
                                obscure: _isObscureConfirm,
                                toggle: () => setState(() {
                                  _isObscureConfirm = !_isObscureConfirm;
                                }),
                                validator: _validateConfirmPassword,
                                delay: 3,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Bouton de sauvegarde
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
                                  colors: [accentOrange,accentOrange],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(16),

                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveNewPassword,
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
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.security, color: Colors.white),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Mettre à jour le mot de passe',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}